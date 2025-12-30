package models

import "time"

// Stock 股票定义表
type Stock struct {
	ID              uint      `json:"id" gorm:"primaryKey"`
	Code            string    `json:"code" gorm:"uniqueIndex;not null"`
	Name            string    `json:"name" gorm:"not null"`
	Description     string    `json:"description"`
	Icon            string    `json:"icon"`
	BasePrice       float64   `json:"base_price" gorm:"type:decimal(10,2);not null"`
	CurrentPrice    float64   `json:"current_price" gorm:"type:decimal(10,2);not null"`
	OpenPrice       *float64  `json:"open_price" gorm:"type:decimal(10,2)"`
	HighPrice       *float64  `json:"high_price" gorm:"type:decimal(10,2)"`
	LowPrice        *float64  `json:"low_price" gorm:"type:decimal(10,2)"`
	ClosePrice      *float64  `json:"close_price" gorm:"type:decimal(10,2)"`
	PriceMin        float64   `json:"price_min" gorm:"type:decimal(10,2);not null"`
	PriceMax        float64   `json:"price_max" gorm:"type:decimal(10,2);not null"`
	TotalShares     int64     `json:"total_shares" gorm:"not null"`
	AvailableShares int64     `json:"available_shares" gorm:"not null"`
	TodayVolume     int64     `json:"today_volume" gorm:"default:0"`
	TodayAmount     float64   `json:"today_amount" gorm:"type:decimal(20,2);default:0"`
	Volatility      float64   `json:"volatility" gorm:"type:decimal(5,2);default:0.10"`
	MaxLeverage     int       `json:"max_leverage" gorm:"default:10"`
	Trend           string    `json:"trend" gorm:"type:enum('up','down','stable');default:'stable'"`
	ChangePercent   float64   `json:"change_percent" gorm:"type:decimal(10,4);default:0"`
	IsActive        bool      `json:"is_active" gorm:"default:true"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

func (Stock) TableName() string {
	return "stocks"
}

// StockPrice 股票价格历史(K线)
type StockPrice struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	StockID    uint      `json:"stock_id" gorm:"not null;index"`
	Price      float64   `json:"price" gorm:"type:decimal(10,2);not null"`
	OpenPrice  *float64  `json:"open_price" gorm:"type:decimal(10,2)"`
	HighPrice  *float64  `json:"high_price" gorm:"type:decimal(10,2)"`
	LowPrice   *float64  `json:"low_price" gorm:"type:decimal(10,2)"`
	Volume     int64     `json:"volume" gorm:"default:0"`
	Amount     float64   `json:"amount" gorm:"type:decimal(20,2);default:0"`
	PeriodType string    `json:"period_type" gorm:"type:enum('1m','5m','15m','1h','1d');default:'1m'"`
	RecordedAt time.Time `json:"recorded_at"`

	Stock Stock `json:"stock" gorm:"foreignKey:StockID"`
}

func (StockPrice) TableName() string {
	return "stock_prices"
}

// UserStock 用户现货持仓表
type UserStock struct {
	ID             uint      `json:"id" gorm:"primaryKey"`
	UserID         uint      `json:"user_id" gorm:"not null;index"`
	StockID        uint      `json:"stock_id" gorm:"not null"`
	Shares         int64     `json:"shares" gorm:"default:0"`
	AvgCost        float64   `json:"avg_cost" gorm:"type:decimal(10,2);not null"`
	TotalCost      float64   `json:"total_cost" gorm:"type:decimal(20,2);not null"`
	RealizedProfit float64   `json:"realized_profit" gorm:"type:decimal(20,2);default:0"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`

	User  User  `json:"user" gorm:"foreignKey:UserID"`
	Stock Stock `json:"stock" gorm:"foreignKey:StockID"`
}

func (UserStock) TableName() string {
	return "user_stocks"
}

// UserLeveragePosition 用户杠杆仓位表
type UserLeveragePosition struct {
	ID               uint       `json:"id" gorm:"primaryKey"`
	UserID           uint       `json:"user_id" gorm:"not null;index"`
	StockID          uint       `json:"stock_id" gorm:"not null"`
	PositionType     string     `json:"position_type" gorm:"type:enum('long','short');not null"`
	Leverage         int        `json:"leverage" gorm:"not null"`
	Shares           int64      `json:"shares" gorm:"not null"`
	EntryPrice       float64    `json:"entry_price" gorm:"type:decimal(10,2);not null"`
	Margin           float64    `json:"margin" gorm:"type:decimal(20,2);not null"`
	LiquidationPrice float64    `json:"liquidation_price" gorm:"type:decimal(10,2);not null"`
	UnrealizedProfit float64    `json:"unrealized_profit" gorm:"type:decimal(20,2);default:0"`
	Status           string     `json:"status" gorm:"type:enum('open','closed','liquidated');default:'open'"`
	CreatedAt        time.Time  `json:"created_at"`
	ClosedAt         *time.Time `json:"closed_at"`

	User  User  `json:"user" gorm:"foreignKey:UserID"`
	Stock Stock `json:"stock" gorm:"foreignKey:StockID"`
}

func (UserLeveragePosition) TableName() string {
	return "user_leverage_positions"
}

// StockOrder 股票交易记录
type StockOrder struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	UserID      uint      `json:"user_id" gorm:"not null;index"`
	StockID     uint      `json:"stock_id" gorm:"not null;index"`
	OrderType   string    `json:"order_type" gorm:"type:enum('buy','sell','long_open','long_close','short_open','short_close');not null"`
	Leverage    int       `json:"leverage" gorm:"default:1"`
	Shares      int64     `json:"shares" gorm:"not null"`
	Price       float64   `json:"price" gorm:"type:decimal(10,2);not null"`
	TotalAmount float64   `json:"total_amount" gorm:"type:decimal(20,2);not null"`
	Margin      float64   `json:"margin" gorm:"type:decimal(20,2);default:0"`
	Profit      float64   `json:"profit" gorm:"type:decimal(20,2);default:0"`
	PositionID  *uint     `json:"position_id"`
	CreatedAt   time.Time `json:"created_at"`

	User  User  `json:"user" gorm:"foreignKey:UserID"`
	Stock Stock `json:"stock" gorm:"foreignKey:StockID"`
}

func (StockOrder) TableName() string {
	return "stock_orders"
}

// UserStockStats 用户股票统计表
type UserStockStats struct {
	ID              uint      `json:"id" gorm:"primaryKey"`
	UserID          uint      `json:"user_id" gorm:"uniqueIndex;not null"`
	TotalAssets     float64   `json:"total_assets" gorm:"type:decimal(20,2);default:0"`
	TotalProfit     float64   `json:"total_profit" gorm:"type:decimal(20,2);default:0"`
	TotalProfitRate float64   `json:"total_profit_rate" gorm:"type:decimal(10,4);default:0"`
	TodayProfit     float64   `json:"today_profit" gorm:"type:decimal(20,2);default:0"`
	TodayProfitRate float64   `json:"today_profit_rate" gorm:"type:decimal(10,4);default:0"`
	WinCount        int       `json:"win_count" gorm:"default:0"`
	LoseCount       int       `json:"lose_count" gorm:"default:0"`
	WinRate         float64   `json:"win_rate" gorm:"type:decimal(5,2);default:0"`
	MaxProfit       float64   `json:"max_profit" gorm:"type:decimal(20,2);default:0"`
	MaxLoss         float64   `json:"max_loss" gorm:"type:decimal(20,2);default:0"`
	TradeCount      int       `json:"trade_count" gorm:"default:0"`
	UpdatedAt       time.Time `json:"updated_at"`

	User User `json:"user" gorm:"foreignKey:UserID"`
}

func (UserStockStats) TableName() string {
	return "user_stock_stats"
}

// StockRanking 股票排行榜
type StockRanking struct {
	ID           uint      `json:"id" gorm:"primaryKey"`
	RankType     string    `json:"rank_type" gorm:"type:enum('assets','profit','profit_rate','win_rate','shares');not null"`
	StockID      *uint     `json:"stock_id"`
	UserID       uint      `json:"user_id" gorm:"not null"`
	RankPosition int       `json:"rank_position" gorm:"not null"`
	Score        float64   `json:"score" gorm:"type:decimal(20,4);not null"`
	UpdatedAt    time.Time `json:"updated_at"`

	User  User   `json:"user" gorm:"foreignKey:UserID"`
	Stock *Stock `json:"stock" gorm:"foreignKey:StockID"`
}

func (StockRanking) TableName() string {
	return "stock_rankings"
}
