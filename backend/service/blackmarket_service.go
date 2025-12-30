package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"math/rand"
	"time"
)

type BlackmarketService struct {
	blackmarketRepo *repository.BlackmarketRepository
	farmRepo        *repository.FarmRepository
	userRepo        *repository.UserRepository
}

func NewBlackmarketService() *BlackmarketService {
	return &BlackmarketService{
		blackmarketRepo: repository.NewBlackmarketRepository(),
		farmRepo:        repository.NewFarmRepository(),
		userRepo:        repository.NewUserRepository(),
	}
}

// GetCurrentBatch 获取当前批次及商品
func (s *BlackmarketService) GetCurrentBatch() (*models.BlackmarketBatch, []models.BlackmarketItem, error) {
	batch, err := s.blackmarketRepo.GetActiveBatch()
	if err != nil {
		return nil, nil, errors.New("黑市暂未开放")
	}

	items, err := s.blackmarketRepo.GetBatchItems(batch.ID)
	if err != nil {
		return nil, nil, err
	}

	return batch, items, nil
}

// BuyItem 购买商品
func (s *BlackmarketService) BuyItem(userID, itemID uint, quantity int) error {
	batch, err := s.blackmarketRepo.GetActiveBatch()
	if err != nil {
		return errors.New("黑市暂未开放")
	}

	item, err := s.blackmarketRepo.GetItemByID(itemID)
	if err != nil {
		return errors.New("商品不存在")
	}

	if item.BatchID != batch.ID {
		return errors.New("商品已过期")
	}

	// 检查库存
	remainingStock := item.TotalStock - item.SoldCount
	if remainingStock < quantity {
		return errors.New("库存不足")
	}

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return errors.New("用户不存在")
	}

	// 检查等级
	if user.Level < item.UnlockLevel {
		return errors.New("等级不足")
	}

	totalPrice := item.Price * float64(quantity)
	if user.Gold < totalPrice {
		return errors.New("金币不足")
	}

	// 扣除库存(原子操作)
	if err := s.blackmarketRepo.IncrementSoldCount(itemID, quantity); err != nil {
		return errors.New("购买失败，请重试")
	}

	// 扣除金币
	if err := s.userRepo.UpdateGold(userID, -totalPrice); err != nil {
		return err
	}

	// 添加物品到仓库
	if item.ItemID != nil {
		if err := s.farmRepo.AddToInventory(userID, item.ItemType, *item.ItemID, quantity); err != nil {
			return err
		}
	}

	// 记录交易
	log := &models.BlackmarketLog{
		UserID:     userID,
		BatchID:    batch.ID,
		ItemID:     itemID,
		Quantity:   quantity,
		Price:      item.Price,
		TotalPrice: totalPrice,
	}
	return s.blackmarketRepo.CreateLog(log)
}

// GetUserPurchaseHistory 获取用户购买记录
func (s *BlackmarketService) GetUserPurchaseHistory(userID uint, limit int) ([]models.BlackmarketLog, error) {
	return s.blackmarketRepo.GetUserLogs(userID, limit)
}

// RefreshBatch 刷新黑市批次(定时任务调用)
func (s *BlackmarketService) RefreshBatch() error {
	// 停用旧批次
	s.blackmarketRepo.DeactivateOldBatches()

	// 创建新批次
	now := time.Now()
	batch := &models.BlackmarketBatch{
		StartAt:  now,
		EndAt:    now.Add(4 * time.Hour), // 4小时刷新一次
		IsActive: true,
	}

	if err := s.blackmarketRepo.CreateBatch(batch); err != nil {
		return err
	}

	// 生成随机商品
	items := s.generateRandomItems(batch.ID)
	for _, item := range items {
		s.blackmarketRepo.CreateItem(&item)
	}

	return nil
}

// generateRandomItems 生成随机商品
func (s *BlackmarketService) generateRandomItems(batchID uint) []models.BlackmarketItem {
	// 这里简化处理，实际应该从配置或数据库读取可能的商品列表
	seeds, _ := s.farmRepo.GetAllSeeds()
	
	var items []models.BlackmarketItem
	
	// 随机选择3-6个种子作为黑市商品
	numItems := 3 + rand.Intn(4)
	selectedIndexes := make(map[int]bool)
	
	for len(items) < numItems && len(selectedIndexes) < len(seeds) {
		idx := rand.Intn(len(seeds))
		if selectedIndexes[idx] {
			continue
		}
		selectedIndexes[idx] = true
		
		seed := seeds[idx]
		// 黑市价格为基础价格的60%-80%
		discount := 0.6 + rand.Float64()*0.2
		price := seed.BasePrice * discount
		
		item := models.BlackmarketItem{
			BatchID:     batchID,
			Name:        seed.Name + "(黑市)",
			Description: "黑市特供 " + seed.Name,
			Icon:        seed.Icon,
			ItemType:    "seed",
			ItemID:      &seed.ID,
			Price:       price,
			TotalStock:  50 + rand.Intn(150), // 50-200库存
			UnlockLevel: seed.UnlockLevel,
		}
		items = append(items, item)
	}

	// 添加一些特殊商品
	specialItems := []models.BlackmarketItem{
		{
			BatchID:     batchID,
			Name:        "神秘种子袋",
			Description: "随机获得一种高级种子",
			ItemType:    "special",
			Price:       500,
			TotalStock:  20,
			UnlockLevel: 5,
		},
		{
			BatchID:     batchID,
			Name:        "金色肥料",
			Description: "使用后作物生长时间减半",
			ItemType:    "tool",
			Price:       200,
			TotalStock:  50,
			UnlockLevel: 3,
		},
	}

	items = append(items, specialItems...)
	return items
}

// GetNextRefreshTime 获取下次刷新时间
func (s *BlackmarketService) GetNextRefreshTime() *time.Time {
	batch, err := s.blackmarketRepo.GetActiveBatch()
	if err != nil {
		return nil
	}
	return &batch.EndAt
}
