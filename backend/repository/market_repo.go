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
