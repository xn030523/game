package models

import "time"

// PriceRule 价格规则表
type PriceRule struct {
	ID           uint    `json:"id" gorm:"primaryKey"`
	ItemType     string  `json:"item_type" gorm:"type:enum('seed','crop');not null"`
	ItemID       uint    `json:"item_id" gorm:"not null"`
	BasePrice    float64 `json:"base_price" gorm:"type:decimal(10,2);not null"`
	MinRate      float64 `json:"min_rate" gorm:"type:decimal(5,2);default:0.50"`
	MaxRate      float64 `json:"max_rate" gorm:"type:decimal(5,2);default:2.00"`
	Volatility   float64 `json:"volatility" gorm:"type:decimal(5,2);default:0.10"`
	SupplyWeight float64 `json:"supply_weight" gorm:"type:decimal(5,2);default:1.00"`
	DemandWeight float64 `json:"demand_weight" gorm:"type:decimal(5,2);default:1.00"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

func (PriceRule) TableName() string {
	return "price_rules"
}

// MarketStatus 市场状态表
type MarketStatus struct {
	ID            uint    `json:"id" gorm:"primaryKey"`
	ItemType      string  `json:"item_type" gorm:"type:enum('seed','crop');not null"`
	ItemID        uint    `json:"item_id" gorm:"not null"`
	CurrentPrice  float64 `json:"current_price" gorm:"type:decimal(10,2);not null"`
	CurrentRate   float64 `json:"current_rate" gorm:"type:decimal(5,2);default:1.00"`
	TotalSupply   int64   `json:"total_supply" gorm:"default:0"`
	BuyVolume24h  int64   `json:"buy_volume_24h" gorm:"default:0"`
	SellVolume24h int64   `json:"sell_volume_24h" gorm:"default:0"`
	Trend         string  `json:"trend" gorm:"type:enum('up','down','stable');default:'stable'"`
	UpdatedAt     time.Time `json:"updated_at"`
}

func (MarketStatus) TableName() string {
	return "market_status"
}

// PriceHistory 价格历史表
type PriceHistory struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	ItemType   string    `json:"item_type" gorm:"type:enum('seed','crop');not null"`
	ItemID     uint      `json:"item_id" gorm:"not null"`
	Price      float64   `json:"price" gorm:"type:decimal(10,2);not null"`
	Rate       float64   `json:"rate" gorm:"type:decimal(5,2);not null"`
	RecordedAt time.Time `json:"recorded_at"`
}

func (PriceHistory) TableName() string {
	return "price_history"
}

// MarketEvent 市场事件表
type MarketEvent struct {
	ID            uint      `json:"id" gorm:"primaryKey"`
	Name          string    `json:"name" gorm:"not null"`
	Description   string    `json:"description"`
	AffectType    string    `json:"affect_type" gorm:"type:enum('seed','crop','all');not null"`
	AffectItems   string    `json:"affect_items" gorm:"type:json"`
	PriceModifier float64   `json:"price_modifier" gorm:"type:decimal(5,2);default:1.00"`
	StartAt       time.Time `json:"start_at"`
	EndAt         time.Time `json:"end_at"`
	IsActive      bool      `json:"is_active" gorm:"default:true"`
	CreatedAt     time.Time `json:"created_at"`
}

func (MarketEvent) TableName() string {
	return "market_events"
}
