package repository

import (
	"farm-game/config"
	"farm-game/models"
	"farm-game/utils"
	"fmt"
	"sync"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type MarketRepository struct {
	db *gorm.DB
}

var (
	marketRepoInstance *MarketRepository
	marketRepoOnce     sync.Once
)

func NewMarketRepository() *MarketRepository {
	marketRepoOnce.Do(func() {
		marketRepoInstance = &MarketRepository{db: config.GetDB()}
	})
	return marketRepoInstance
}

// GetMarketStatus 获取市场状态（带缓存）
func (r *MarketRepository) GetMarketStatus(itemType string, itemID uint) (*models.MarketStatus, error) {
	cacheKey := fmt.Sprintf("market:%s:%d", itemType, itemID)
	if cached, ok := utils.GlobalCache.Get(cacheKey); ok {
		return cached.(*models.MarketStatus), nil
	}
	var status models.MarketStatus
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("item_type = ? AND item_id = ?", itemType, itemID).First(&status).Error
	if err != nil {
		return nil, err
	}
	utils.GlobalCache.Set(cacheKey, &status, 30*time.Second)
	return &status, nil
}

// GetAllMarketStatus 获取所有市场状态
func (r *MarketRepository) GetAllMarketStatus(itemType string) ([]models.MarketStatus, error) {
	var statuses []models.MarketStatus
	err := r.db.Where("item_type = ?", itemType).Find(&statuses).Error
	return statuses, err
}

// UpdateMarketStatus 更新市场状态
func (r *MarketRepository) UpdateMarketStatus(status *models.MarketStatus) error {
	return r.db.Save(status).Error
}

// AddPriceHistory 添加价格历史
func (r *MarketRepository) AddPriceHistory(history *models.PriceHistory) error {
	return r.db.Create(history).Error
}

// GetPriceHistory 获取价格历史
func (r *MarketRepository) GetPriceHistory(itemType string, itemID uint, limit int) ([]models.PriceHistory, error) {
	var histories []models.PriceHistory
	err := r.db.Where("item_type = ? AND item_id = ?", itemType, itemID).
		Order("recorded_at DESC").Limit(limit).Find(&histories).Error
	return histories, err
}

// GetActiveMarketEvents 获取活跃的市场事件
func (r *MarketRepository) GetActiveMarketEvents() ([]models.MarketEvent, error) {
	var events []models.MarketEvent
	err := r.db.Where("is_active = ? AND start_at <= NOW() AND end_at >= NOW()", true).Find(&events).Error
	return events, err
}

// GetPriceRule 获取价格规则
func (r *MarketRepository) GetPriceRule(itemType string, itemID uint) (*models.PriceRule, error) {
	var rule models.PriceRule
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("item_type = ? AND item_id = ?", itemType, itemID).First(&rule).Error
	if err != nil {
		return nil, err
	}
	return &rule, nil
}

// UpdateBuyVolume 更新买入量（需求增加，价格上涨）- 优化版
func (r *MarketRepository) UpdateBuyVolume(itemType string, itemID uint, quantity int) {
	cacheKey := fmt.Sprintf("market:%s:%d", itemType, itemID)
	utils.GlobalCache.Delete(cacheKey)

	var status models.MarketStatus
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("item_type = ? AND item_id = ?", itemType, itemID).First(&status).Error
	if err != nil {
		status = models.MarketStatus{
			ItemType:     itemType,
			ItemID:       itemID,
			CurrentRate:  1.0,
			BuyVolume24h: int64(quantity),
		}
		if itemType == "seed" {
			var seed models.Seed
			if r.db.First(&seed, itemID).Error == nil {
				status.CurrentPrice = seed.BasePrice
			}
		}
		r.db.Create(&status)
		return
	}
	// 使用原子更新
	priceChange := float64(quantity) / 10.0 * 0.01 * status.CurrentPrice
	r.db.Model(&status).Updates(map[string]interface{}{
		"buy_volume24h": gorm.Expr("buy_volume24h + ?", quantity),
		"current_price": gorm.Expr("current_price + ?", priceChange),
	})
}

// UpdateSellVolume 更新卖出量（供给增加，价格下跌）- 优化版
func (r *MarketRepository) UpdateSellVolume(itemType string, itemID uint, quantity int) {
	cacheKey := fmt.Sprintf("market:%s:%d", itemType, itemID)
	utils.GlobalCache.Delete(cacheKey)

	var status models.MarketStatus
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("item_type = ? AND item_id = ?", itemType, itemID).First(&status).Error
	if err != nil {
		status = models.MarketStatus{
			ItemType:      itemType,
			ItemID:        itemID,
			CurrentRate:   1.0,
			SellVolume24h: int64(quantity),
		}
		if itemType == "crop" {
			var crop models.Crop
			if r.db.First(&crop, itemID).Error == nil {
				status.CurrentPrice = crop.BaseSellPrice
			}
		}
		r.db.Create(&status)
		return
	}
	// 使用原子更新
	priceChange := float64(quantity) / 10.0 * 0.01 * status.CurrentPrice
	newPrice := status.CurrentPrice - priceChange
	// 价格不能低于基础价格的50%
	if itemType == "crop" {
		var crop models.Crop
		if r.db.First(&crop, itemID).Error == nil {
			minPrice := crop.BaseSellPrice * 0.5
			if newPrice < minPrice {
				newPrice = minPrice
			}
		}
	}
	r.db.Model(&status).Updates(map[string]interface{}{
		"sell_volume24h": gorm.Expr("sell_volume24h + ?", quantity),
		"current_price":  newPrice,
	})
}
