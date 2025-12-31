package repository

import (
	"farm-game/config"
	"farm-game/models"
	"sync"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type BlackmarketRepository struct {
	db *gorm.DB
}

var (
	blackmarketRepoInstance *BlackmarketRepository
	blackmarketRepoOnce     sync.Once
)

func NewBlackmarketRepository() *BlackmarketRepository {
	blackmarketRepoOnce.Do(func() {
		blackmarketRepoInstance = &BlackmarketRepository{db: config.GetDB()}
	})
	return blackmarketRepoInstance
}

// === 批次相关 ===

// GetActiveBatch 获取当前活跃批次
func (r *BlackmarketRepository) GetActiveBatch() (*models.BlackmarketBatch, error) {
	var batch models.BlackmarketBatch
	now := time.Now()
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("is_active = ? AND start_at <= ? AND end_at > ?", true, now, now).First(&batch).Error
	if err != nil {
		return nil, err
	}
	return &batch, nil
}

// CreateBatch 创建批次
func (r *BlackmarketRepository) CreateBatch(batch *models.BlackmarketBatch) error {
	return r.db.Create(batch).Error
}

// UpdateBatch 更新批次
func (r *BlackmarketRepository) UpdateBatch(batch *models.BlackmarketBatch) error {
	return r.db.Save(batch).Error
}

// DeactivateOldBatches 停用旧批次
func (r *BlackmarketRepository) DeactivateOldBatches() error {
	return r.db.Model(&models.BlackmarketBatch{}).Where("end_at < ?", time.Now()).Update("is_active", false).Error
}

// === 商品相关 ===

// GetBatchItems 获取批次商品
func (r *BlackmarketRepository) GetBatchItems(batchID uint) ([]models.BlackmarketItem, error) {
	var items []models.BlackmarketItem
	err := r.db.Where("batch_id = ?", batchID).Find(&items).Error
	return items, err
}

// GetItemByID 根据ID获取商品
func (r *BlackmarketRepository) GetItemByID(id uint) (*models.BlackmarketItem, error) {
	var item models.BlackmarketItem
	err := r.db.First(&item, id).Error
	if err != nil {
		return nil, err
	}
	return &item, nil
}

// CreateItem 创建商品
func (r *BlackmarketRepository) CreateItem(item *models.BlackmarketItem) error {
	return r.db.Create(item).Error
}

// UpdateItem 更新商品
func (r *BlackmarketRepository) UpdateItem(item *models.BlackmarketItem) error {
	return r.db.Save(item).Error
}

// IncrementSoldCount 增加售出数量(原子操作)
func (r *BlackmarketRepository) IncrementSoldCount(itemID uint, quantity int) error {
	return r.db.Model(&models.BlackmarketItem{}).
		Where("id = ? AND total_stock - sold_count >= ?", itemID, quantity).
		Update("sold_count", gorm.Expr("sold_count + ?", quantity)).Error
}

// === 交易记录 ===

// CreateLog 创建交易记录
func (r *BlackmarketRepository) CreateLog(log *models.BlackmarketLog) error {
	return r.db.Create(log).Error
}

// GetUserLogs 获取用户交易记录
func (r *BlackmarketRepository) GetUserLogs(userID uint, limit int) ([]models.BlackmarketLog, error) {
	var logs []models.BlackmarketLog
	err := r.db.Where("user_id = ?", userID).
		Preload("Item").Order("created_at DESC").Limit(limit).Find(&logs).Error
	return logs, err
}

// GetUserBatchPurchases 获取用户在某批次的购买记录
func (r *BlackmarketRepository) GetUserBatchPurchases(userID, batchID uint) ([]models.BlackmarketLog, error) {
	var logs []models.BlackmarketLog
	err := r.db.Where("user_id = ? AND batch_id = ?", userID, batchID).Find(&logs).Error
	return logs, err
}
