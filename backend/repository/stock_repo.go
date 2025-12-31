package repository

import (
	"farm-game/config"
	"farm-game/models"
	"time"

	"gorm.io/gorm"
)

type StockRepository struct {
	db *gorm.DB
}

func NewStockRepository() *StockRepository {
	return &StockRepository{db: config.GetDB()}
}

// === 股票相关 ===

// GetAllStocks 获取所有股票
func (r *StockRepository) GetAllStocks() ([]models.Stock, error) {
	var stocks []models.Stock
	err := r.db.Where("is_active = ?", true).Find(&stocks).Error
	return stocks, err
}

// GetStockByID 根据ID获取股票
func (r *StockRepository) GetStockByID(id uint) (*models.Stock, error) {
	var stock models.Stock
	err := r.db.First(&stock, id).Error
	if err != nil {
		return nil, err
	}
	return &stock, nil
}

// GetStockByCode 根据代码获取股票
func (r *StockRepository) GetStockByCode(code string) (*models.Stock, error) {
	var stock models.Stock
	err := r.db.Where("code = ?", code).First(&stock).Error
	if err != nil {
		return nil, err
	}
	return &stock, nil
}

// UpdateStock 更新股票
func (r *StockRepository) UpdateStock(stock *models.Stock) error {
	return r.db.Save(stock).Error
}

// === 股票价格K线 ===

// AddStockPrice 添加价格记录
func (r *StockRepository) AddStockPrice(price *models.StockPrice) error {
	return r.db.Create(price).Error
}

// GetStockPrices 获取K线数据
func (r *StockRepository) GetStockPrices(stockID uint, periodType string, limit int) ([]models.StockPrice, error) {
	var prices []models.StockPrice
	err := r.db.Where("stock_id = ? AND period_type = ?", stockID, periodType).
		Order("recorded_at DESC").Limit(limit).Find(&prices).Error
	return prices, err
}

// GetTodayKLine 获取今天的K线数据
func (r *StockRepository) GetTodayKLine(stockID uint, date string) (*models.StockPrice, error) {
	var price models.StockPrice
	err := r.db.Where("stock_id = ? AND period_type = '1d' AND DATE(recorded_at) = ?", stockID, date).First(&price).Error
	if err != nil {
		return nil, err
	}
	return &price, nil
}

// CreateStockPrice 创建K线记录
func (r *StockRepository) CreateStockPrice(price *models.StockPrice) error {
	return r.db.Create(price).Error
}

// UpdateStockPrice 更新K线记录
func (r *StockRepository) UpdateStockPrice(price *models.StockPrice) error {
	return r.db.Save(price).Error
}

// GetStockNews 获取股票新闻
func (r *StockRepository) GetStockNews(limit int) ([]models.StockNews, error) {
	var news []models.StockNews
	err := r.db.Order("created_at DESC").Limit(limit).Find(&news).Error
	return news, err
}

// GetProfitsByDate 获取指定日期盈亏
func (r *StockRepository) GetProfitsByDate(userID uint, date string) ([]models.StockProfit, error) {
	var profits []models.StockProfit
	err := r.db.Where("user_id = ? AND DATE(created_at) = ?", userID, date).
		Order("created_at DESC").Find(&profits).Error
	return profits, err
}

// GetAllProfits 获取全部历史盈亏
func (r *StockRepository) GetAllProfits(userID uint) ([]models.StockProfit, error) {
	var profits []models.StockProfit
	err := r.db.Where("user_id = ?", userID).
		Order("created_at DESC").Limit(500).Find(&profits).Error
	return profits, err
}

// === 用户现货持仓 ===

// GetUserStocks 获取用户所有持仓
func (r *StockRepository) GetUserStocks(userID uint) ([]models.UserStock, error) {
	var stocks []models.UserStock
	err := r.db.Where("user_id = ? AND shares > 0", userID).Preload("Stock").Find(&stocks).Error
	return stocks, err
}

// GetUserStock 获取用户指定股票持仓
func (r *StockRepository) GetUserStock(userID, stockID uint) (*models.UserStock, error) {
	var stock models.UserStock
	err := r.db.Where("user_id = ? AND stock_id = ?", userID, stockID).First(&stock).Error
	if err != nil {
		return nil, err
	}
	return &stock, nil
}

// CreateUserStock 创建用户持仓
func (r *StockRepository) CreateUserStock(stock *models.UserStock) error {
	return r.db.Create(stock).Error
}

// UpdateUserStock 更新用户持仓
func (r *StockRepository) UpdateUserStock(stock *models.UserStock) error {
	return r.db.Save(stock).Error
}

// === 杠杆仓位 ===

// GetUserLeveragePositions 获取用户杠杆仓位
func (r *StockRepository) GetUserLeveragePositions(userID uint, status string) ([]models.UserLeveragePosition, error) {
	var positions []models.UserLeveragePosition
	query := r.db.Where("user_id = ?", userID)
	if status != "" {
		query = query.Where("status = ?", status)
	}
	err := query.Preload("Stock").Find(&positions).Error
	return positions, err
}

// GetLeveragePosition 获取指定仓位
func (r *StockRepository) GetLeveragePosition(id uint) (*models.UserLeveragePosition, error) {
	var position models.UserLeveragePosition
	err := r.db.Preload("Stock").First(&position, id).Error
	if err != nil {
		return nil, err
	}
	return &position, nil
}

// CreateLeveragePosition 创建杠杆仓位
func (r *StockRepository) CreateLeveragePosition(position *models.UserLeveragePosition) error {
	return r.db.Create(position).Error
}

// UpdateLeveragePosition 更新杠杆仓位
func (r *StockRepository) UpdateLeveragePosition(position *models.UserLeveragePosition) error {
	return r.db.Save(position).Error
}

// GetOpenPositionsForLiquidation 获取需要检查强平的仓位
func (r *StockRepository) GetOpenPositionsForLiquidation(stockID uint) ([]models.UserLeveragePosition, error) {
	var positions []models.UserLeveragePosition
	err := r.db.Where("stock_id = ? AND status = 'open'", stockID).Find(&positions).Error
	return positions, err
}

// === 交易订单 ===

// CreateStockOrder 创建交易订单
func (r *StockRepository) CreateStockOrder(order *models.StockOrder) error {
	return r.db.Create(order).Error
}

// GetUserStockOrders 获取用户交易记录
func (r *StockRepository) GetUserStockOrders(userID uint, limit int) ([]models.StockOrder, error) {
	var orders []models.StockOrder
	err := r.db.Where("user_id = ?", userID).
		Preload("Stock").Order("created_at DESC").Limit(limit).Find(&orders).Error
	return orders, err
}

// === 用户股票统计 ===

// GetUserStockStats 获取用户股票统计
func (r *StockRepository) GetUserStockStats(userID uint) (*models.UserStockStats, error) {
	var stats models.UserStockStats
	err := r.db.Where("user_id = ?", userID).First(&stats).Error
	if err != nil {
		return nil, err
	}
	return &stats, nil
}

// CreateUserStockStats 创建用户股票统计
func (r *StockRepository) CreateUserStockStats(stats *models.UserStockStats) error {
	return r.db.Create(stats).Error
}

// UpdateUserStockStats 更新用户股票统计
func (r *StockRepository) UpdateUserStockStats(stats *models.UserStockStats) error {
	stats.UpdatedAt = time.Now()
	return r.db.Save(stats).Error
}

// === 排行榜 ===

// GetStockRankings 获取股票排行榜
func (r *StockRepository) GetStockRankings(rankType string, limit int) ([]models.StockRanking, error) {
	var rankings []models.StockRanking
	err := r.db.Where("rank_type = ?", rankType).
		Preload("User").Order("rank_position ASC").Limit(limit).Find(&rankings).Error
	return rankings, err
}

// UpdateStockRankings 更新排行榜
func (r *StockRepository) UpdateStockRankings(rankType string, rankings []models.StockRanking) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// 删除旧排行
		if err := tx.Where("rank_type = ?", rankType).Delete(&models.StockRanking{}).Error; err != nil {
			return err
		}
		// 插入新排行
		for i := range rankings {
			rankings[i].RankType = rankType
			rankings[i].RankPosition = i + 1
			rankings[i].UpdatedAt = time.Now()
			if err := tx.Create(&rankings[i]).Error; err != nil {
				return err
			}
		}
		return nil
	})
}
