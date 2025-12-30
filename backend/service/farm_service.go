package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"farm-game/ws"
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

// SeedWithPrice 带实时价格的种子
type SeedWithPrice struct {
	models.Seed
	CurrentPrice  float64 `json:"current_price"`
	PriceChange   float64 `json:"price_change"`   // 涨跌幅 %
	BuyVolume     int64   `json:"buy_volume"`     // 24h买入量
	SellVolume    int64   `json:"sell_volume"`    // 24h卖出量
	Trend         string  `json:"trend"`          // up/down/stable
}

// GetSeedsWithPrice 获取种子列表（含实时价格）
func (s *FarmService) GetSeedsWithPrice(userLevel int) ([]SeedWithPrice, error) {
	seeds, err := s.farmRepo.GetSeedsByLevel(userLevel)
	if err != nil {
		return nil, err
	}
	
	result := make([]SeedWithPrice, len(seeds))
	for i, seed := range seeds {
		result[i].Seed = seed
		// 获取市场价格
		status, err := s.marketRepo.GetMarketStatus("seed", seed.ID)
		if err != nil {
			result[i].CurrentPrice = seed.BasePrice
			result[i].PriceChange = 0
			result[i].Trend = "stable"
		} else {
			result[i].CurrentPrice = status.CurrentPrice
			result[i].PriceChange = (status.CurrentPrice - seed.BasePrice) / seed.BasePrice * 100
			result[i].BuyVolume = status.BuyVolume24h
			result[i].SellVolume = status.SellVolume24h
			result[i].Trend = status.Trend
		}
	}
	return result, nil
}

// CropWithPrice 带实时价格的作物
type CropWithPrice struct {
	models.Crop
	CurrentPrice float64 `json:"current_price"`
	PriceChange  float64 `json:"price_change"`
	BuyVolume    int64   `json:"buy_volume"`
	SellVolume   int64   `json:"sell_volume"`
	Trend        string  `json:"trend"`
}

// GetCropsWithPrice 获取作物列表（含实时价格）
func (s *FarmService) GetCropsWithPrice() ([]CropWithPrice, error) {
	crops, err := s.farmRepo.GetAllCrops()
	if err != nil {
		return nil, err
	}
	result := make([]CropWithPrice, len(crops))
	for i, crop := range crops {
		result[i].Crop = crop
		status, err := s.marketRepo.GetMarketStatus("crop", crop.ID)
		if err != nil {
			result[i].CurrentPrice = crop.BaseSellPrice
			result[i].Trend = "stable"
		} else {
			result[i].CurrentPrice = status.CurrentPrice
			result[i].PriceChange = (status.CurrentPrice - crop.BaseSellPrice) / crop.BaseSellPrice * 100
			result[i].BuyVolume = status.BuyVolume24h
			result[i].SellVolume = status.SellVolume24h
			result[i].Trend = status.Trend
		}
	}
	return result, nil
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
		farm.Stage = seed.Stages - 1 // 贴图从0开始，成熟是最后一张
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
	var currentPrice float64
	if err != nil {
		currentPrice = seed.BasePrice
	} else {
		currentPrice = marketStatus.CurrentPrice
	}

	// 计算带滑点的总成本（每10个涨1%）
	totalCost := 0.0
	tempPrice := currentPrice
	for i := 0; i < quantity; i++ {
		totalCost += tempPrice
		// 每买1个，价格涨0.1%
		tempPrice *= 1.001
	}

	if user.Gold < totalCost {
		return errors.New("金币不足")
	}

	// 扣除金币
	if err := s.userRepo.UpdateGold(userID, -totalCost); err != nil {
		return err
	}

	// 更新市场交易量（买入增加需求，价格上涨）
	s.marketRepo.UpdateBuyVolume("seed", seedID, quantity)

	// WebSocket 广播价格更新
	s.broadcastPriceUpdate("seed", seedID)

	// 添加到仓库
	return s.farmRepo.AddToInventory(userID, "seed", seedID, quantity)
}

// broadcastPriceUpdate 广播价格更新
func (s *FarmService) broadcastPriceUpdate(itemType string, itemID uint) {
	status, err := s.marketRepo.GetMarketStatus(itemType, itemID)
	if err != nil {
		return
	}
	ws.GameHub.Broadcast(ws.NewMessage(ws.MsgTypeMarketUpdate, map[string]interface{}{
		"item_type":     itemType,
		"item_id":       itemID,
		"current_price": status.CurrentPrice,
		"buy_volume":    status.BuyVolume24h,
		"sell_volume":   status.SellVolume24h,
		"trend":         status.Trend,
	}))
}

// Plant 种植
func (s *FarmService) Plant(userID uint, slotIndex int, seedID uint) error {
	// 检查用户农田数量
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return errors.New("用户不存在")
	}
	if slotIndex >= user.FarmSlots {
		return errors.New("农田格子不存在")
	}

	// 获取或创建农田
	farm, err := s.farmRepo.GetUserFarmBySlot(userID, slotIndex)
	if err != nil {
		// 农田不存在，自动创建
		farm = &models.UserFarm{
			UserID:    userID,
			SlotIndex: slotIndex,
			Status:    "empty",
		}
		if err := s.farmRepo.CreateUserFarm(farm); err != nil {
			return errors.New("创建农田失败")
		}
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

	// 固定产量1个
	yield := 1

	// 添加作物到仓库
	if err := s.farmRepo.AddToInventory(userID, "crop", crop.ID, yield); err != nil {
		return nil, err
	}

	// 根据稀有度计算种子掉落概率
	// 1普通=80%, 2良好=50%, 3稀有=30%, 4史诗=15%, 5传说=10%
	seed, _ := s.farmRepo.GetSeedByID(*farm.SeedID)
	dropRates := map[int]int{1: 80, 2: 50, 3: 30, 4: 15, 5: 10}
	dropRate := dropRates[seed.Rarity]
	if dropRate == 0 {
		dropRate = 80
	}
	seedDropped := 0
	if rand.Intn(100) < dropRate {
		seedDropped = 1
		s.farmRepo.AddToInventory(userID, "seed", *farm.SeedID, 1)
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
		stats.ContributionPoints += 10 // 每次收获+10贡献值
		s.userRepo.UpdateUserStats(stats)
	}

	// 同步更新用户表的贡献值
	user, _ := s.userRepo.FindByID(userID)
	if user != nil {
		user.Contribution += 10
		s.userRepo.Update(user)
	}

	// 检查成就
	s.checkHarvestAchievements(userID, stats)

	return &HarvestResult{
		CropID:      crop.ID,
		CropName:    crop.Name,
		Yield:       yield,
		SeedDropped: seedDropped,
		SeedName:    seed.Name,
	}, nil
}

type HarvestResult struct {
	CropID      uint   `json:"crop_id"`
	CropName    string `json:"crop_name"`
	Yield       int    `json:"yield"`
	SeedDropped int    `json:"seed_dropped"`
	SeedName    string `json:"seed_name"`
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
	var currentPrice float64
	if err != nil {
		currentPrice = crop.BaseSellPrice
	} else {
		currentPrice = marketStatus.CurrentPrice
	}

	// 计算带滑点的总收益（每卖1个，价格跌0.1%）
	totalEarning := 0.0
	tempPrice := currentPrice
	for i := 0; i < quantity; i++ {
		totalEarning += tempPrice
		tempPrice *= 0.999
	}

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

	// 更新市场交易量（卖出增加供给，价格下跌）
	s.marketRepo.UpdateSellVolume("crop", cropID, quantity)

	// WebSocket 广播价格更新
	s.broadcastPriceUpdate("crop", cropID)

	return totalEarning, nil
}

// RecycleSeed 回收种子（30%价格）
func (s *FarmService) RecycleSeed(userID uint, seedID uint, quantity int) (float64, error) {
	// 检查仓库
	item, err := s.farmRepo.GetUserInventoryItem(userID, "seed", seedID)
	if err != nil || item.Quantity < quantity {
		return 0, errors.New("种子数量不足")
	}

	seed, err := s.farmRepo.GetSeedByID(seedID)
	if err != nil {
		return 0, errors.New("种子不存在")
	}

	// 回收价格是原价的30%
	recyclePrice := seed.BasePrice * 0.3
	totalEarning := recyclePrice * float64(quantity)

	// 扣除种子
	if err := s.farmRepo.RemoveFromInventory(userID, "seed", seedID, quantity); err != nil {
		return 0, err
	}

	// 增加金币
	if err := s.userRepo.UpdateGold(userID, totalEarning); err != nil {
		return 0, err
	}

	return totalEarning, nil
}

// GetUserInventory 获取用户仓库
func (s *FarmService) GetUserInventory(userID uint) ([]models.UserInventory, error) {
	return s.farmRepo.GetUserInventory(userID)
}

// checkHarvestAchievements 检查收获相关成就
func (s *FarmService) checkHarvestAchievements(userID uint, stats *models.UserStats) {
	if stats == nil {
		return
	}
	
	achievementRepo := repository.NewAchievementRepository()
	
	// 检查收获次数成就
	harvestAchievements := []struct {
		code  string
		count int
	}{
		{"first_harvest", 1},
		{"harvest_10", 10},
		{"harvest_100", 100},
		{"harvest_1000", 1000},
	}
	
	for _, a := range harvestAchievements {
		if stats.TotalHarvested >= a.count {
			// 检查是否已获得
			ua, _ := achievementRepo.GetUserAchievement(userID, a.code)
			if ua == nil {
				// 未获得，尝试解锁
				achievement, _ := achievementRepo.GetAchievementByCode(a.code)
				if achievement != nil {
					achievementRepo.UnlockAchievement(userID, achievement.ID)
					// 增加成就点数
					stats.AchievementPoints += achievement.Points
					s.userRepo.UpdateUserStats(stats)
					// 同步更新用户表
					user, _ := s.userRepo.FindByID(userID)
					if user != nil {
						user.AchievementPoints += achievement.Points
						s.userRepo.Update(user)
					}
				}
			}
		}
	}
}
