package repository

import (
	"farm-game/config"
	"farm-game/models"

	"gorm.io/gorm"
)

type MarketRepository struct {
	db *gorm.DB
}

func NewMarketRepository() *MarketRepository {
	return &MarketRepository{db: config.GetDB()}
}

// GetMarketStatus 获取市场状态
func (r *MarketRepository) GetMarketStatus(itemType string, itemID uint) (*models.MarketStatus, error) {
	var status models.MarketStatus
	err := r.db.Where("item_type = ? AND item_id = ?", itemType, itemID).First(&status).Error
	if err != nil {
		return nil, err
	}
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
	err := r.db.Where("item_type = ? AND item_id = ?", itemType, itemID).First(&rule).Error
	if err != nil {
		return nil, err
	}
	return &rule, nil
}

// UpdateBuyVolume 更新买入量（需求增加，价格上涨）
func (r *MarketRepository) UpdateBuyVolume(itemType string, itemID uint, quantity int) {
	var status models.MarketStatus
	err := r.db.Where("item_type = ? AND item_id = ?", itemType, itemID).First(&status).Error
	if err != nil {
		// 不存在则创建
		status = models.MarketStatus{
			ItemType:     itemType,
			ItemID:       itemID,
			CurrentRate:  1.0,
			BuyVolume24h: int64(quantity),
		}
		// 获取基础价格
		if itemType == "seed" {
			var seed models.Seed
			if r.db.First(&seed, itemID).Error == nil {
				status.CurrentPrice = seed.BasePrice
			}
		}
		r.db.Create(&status)
		return
	}
	status.BuyVolume24h += int64(quantity)
	// 买入越多，价格越高（每10个交易量涨1%）
	priceChange := float64(quantity) / 10.0 * 0.01 * status.CurrentPrice
	status.CurrentPrice += priceChange
	r.db.Save(&status)
}

// UpdateSellVolume 更新卖出量（供给增加，价格下跌）
func (r *MarketRepository) UpdateSellVolume(itemType string, itemID uint, quantity int) {
	var status models.MarketStatus
	err := r.db.Where("item_type = ? AND item_id = ?", itemType, itemID).First(&status).Error
	if err != nil {
		// 不存在则创建
		status = models.MarketStatus{
			ItemType:      itemType,
			ItemID:        itemID,
			CurrentRate:   1.0,
			SellVolume24h: int64(quantity),
		}
		// 获取基础价格
		if itemType == "crop" {
			var crop models.Crop
			if r.db.First(&crop, itemID).Error == nil {
				status.CurrentPrice = crop.BaseSellPrice
			}
		}
		r.db.Create(&status)
		return
	}
	status.SellVolume24h += int64(quantity)
	// 卖出越多，价格越低（每10个交易量跌1%）
	priceChange := float64(quantity) / 10.0 * 0.01 * status.CurrentPrice
	status.CurrentPrice -= priceChange
	// 价格不能低于基础价格的50%
	if itemType == "crop" {
		var crop models.Crop
		if r.db.First(&crop, itemID).Error == nil {
			minPrice := crop.BaseSellPrice * 0.5
			if status.CurrentPrice < minPrice {
				status.CurrentPrice = minPrice
			}
		}
	}
	r.db.Save(&status)
}
