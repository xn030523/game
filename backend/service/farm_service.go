package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"math/rand"
	"time"
)

type FarmService struct {
	farmRepo   *repository.FarmRepository
	userRepo   *repository.UserRepository
	marketRepo *repository.MarketRepository
}

func NewFarmService() *FarmService {
	return &FarmService{
		farmRepo:   repository.NewFarmRepository(),
		userRepo:   repository.NewUserRepository(),
		marketRepo: repository.NewMarketRepository(),
	}
}

// GetSeeds 获取用户可购买的种子列表
func (s *FarmService) GetSeeds(userLevel int) ([]models.Seed, error) {
	return s.farmRepo.GetSeedsByLevel(userLevel)
}

// GetUserFarms 获取用户农田
func (s *FarmService) GetUserFarms(userID uint) ([]models.UserFarm, error) {
	farms, err := s.farmRepo.GetUserFarms(userID)
	if err != nil {
		return nil, err
	}

	// 更新生长状态
	for i := range farms {
		s.updateFarmStatus(&farms[i])
	}

	return farms, nil
}

// updateFarmStatus 更新农田状态
func (s *FarmService) updateFarmStatus(farm *models.UserFarm) {
	if farm.Status != "growing" || farm.SeedID == nil || farm.PlantedAt == nil {
		return
	}

	seed, err := s.farmRepo.GetSeedByID(*farm.SeedID)
	if err != nil {
		return
	}

	elapsed := time.Since(*farm.PlantedAt).Seconds()
	stageTime := float64(seed.GrowthTime) / float64(seed.Stages)
	
	newStage := int(elapsed / stageTime)
	if newStage >= seed.Stages {
		farm.Stage = seed.Stages
		farm.Status = "mature"
	} else {
		farm.Stage = newStage
	}

	s.farmRepo.UpdateUserFarm(farm)
}

// BuySeed 购买种子
func (s *FarmService) BuySeed(userID uint, seedID uint, quantity int) error {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return err
	}

	seed, err := s.farmRepo.GetSeedByID(seedID)
	if err != nil {
		return errors.New("种子不存在")
	}

	if user.Level < seed.UnlockLevel {
		return errors.New("等级不足，无法购买")
	}

	// 获取当前市场价格
	marketStatus, err := s.marketRepo.GetMarketStatus("seed", seedID)
	var price float64
	if err != nil {
		price = seed.BasePrice
	} else {
		price = marketStatus.CurrentPrice
	}

	totalCost := price * float64(quantity)
	if user.Gold < totalCost {
		return errors.New("金币不足")
	}

	// 扣除金币
	if err := s.userRepo.UpdateGold(userID, -totalCost); err != nil {
		return err
	}

	// 添加到仓库
	return s.farmRepo.AddToInventory(userID, "seed", seedID, quantity)
}

// Plant 种植
func (s *FarmService) Plant(userID uint, slotIndex int, seedID uint) error {
	// 检查农田
	farm, err := s.farmRepo.GetUserFarmBySlot(userID, slotIndex)
	if err != nil {
		return errors.New("农田不存在")
	}

	if farm.Status != "empty" {
		return errors.New("农田不为空")
	}

	// 检查仓库是否有种子
	item, err := s.farmRepo.GetUserInventoryItem(userID, "seed", seedID)
	if err != nil || item.Quantity < 1 {
		return errors.New("种子不足")
	}

	// 扣除种子
	if err := s.farmRepo.RemoveFromInventory(userID, "seed", seedID, 1); err != nil {
		return err
	}

	// 更新农田
	now := time.Now()
	farm.SeedID = &seedID
	farm.PlantedAt = &now
	farm.Stage = 0
	farm.Status = "growing"

	// 更新用户统计
	stats, _ := s.userRepo.GetUserStats(userID)
	if stats != nil {
		stats.TotalPlanted++
		s.userRepo.UpdateUserStats(stats)
	}

	return s.farmRepo.UpdateUserFarm(farm)
}

// Harvest 收获
func (s *FarmService) Harvest(userID uint, slotIndex int) (*HarvestResult, error) {
	farm, err := s.farmRepo.GetUserFarmBySlot(userID, slotIndex)
	if err != nil {
		return nil, errors.New("农田不存在")
	}

	if farm.Status != "mature" {
		return nil, errors.New("作物未成熟")
	}

	// 获取作物信息
	crop, err := s.farmRepo.GetCropBySeedID(*farm.SeedID)
	if err != nil {
		return nil, errors.New("作物不存在")
	}

	// 计算产量
	yield := crop.YieldMin + rand.Intn(crop.YieldMax-crop.YieldMin+1)

	// 添加作物到仓库
	if err := s.farmRepo.AddToInventory(userID, "crop", crop.ID, yield); err != nil {
		return nil, err
	}

	// 清空农田
	farm.SeedID = nil
	farm.PlantedAt = nil
	farm.Stage = 0
	farm.Status = "empty"

	if err := s.farmRepo.UpdateUserFarm(farm); err != nil {
		return nil, err
	}

	// 更新用户统计
	stats, _ := s.userRepo.GetUserStats(userID)
	if stats != nil {
		stats.TotalHarvested++
		s.userRepo.UpdateUserStats(stats)
	}

	return &HarvestResult{
		CropID:   crop.ID,
		CropName: crop.Name,
		Yield:    yield,
	}, nil
}

type HarvestResult struct {
	CropID   uint   `json:"crop_id"`
	CropName string `json:"crop_name"`
	Yield    int    `json:"yield"`
}

// SellCrop 出售作物
func (s *FarmService) SellCrop(userID uint, cropID uint, quantity int) (float64, error) {
	// 检查仓库
	item, err := s.farmRepo.GetUserInventoryItem(userID, "crop", cropID)
	if err != nil || item.Quantity < quantity {
		return 0, errors.New("作物数量不足")
	}

	crop, err := s.farmRepo.GetCropByID(cropID)
	if err != nil {
		return 0, errors.New("作物不存在")
	}

	// 获取当前市场价格
	marketStatus, err := s.marketRepo.GetMarketStatus("crop", cropID)
	var price float64
	if err != nil {
		price = crop.BaseSellPrice
	} else {
		price = marketStatus.CurrentPrice
	}

	totalEarning := price * float64(quantity)

	// 扣除作物
	if err := s.farmRepo.RemoveFromInventory(userID, "crop", cropID, quantity); err != nil {
		return 0, err
	}

	// 增加金币
	if err := s.userRepo.UpdateGold(userID, totalEarning); err != nil {
		return 0, err
	}

	// 更新用户统计
	stats, _ := s.userRepo.GetUserStats(userID)
	if stats != nil {
		stats.TotalSold += quantity
		stats.TotalGoldEarned += totalEarning
		s.userRepo.UpdateUserStats(stats)
	}

	return totalEarning, nil
}

// GetUserInventory 获取用户仓库
func (s *FarmService) GetUserInventory(userID uint) ([]models.UserInventory, error) {
	return s.farmRepo.GetUserInventory(userID)
}
