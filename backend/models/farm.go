package models

import "time"

// Seed 种子表
type Seed struct {
	ID          uint    `json:"id" gorm:"primaryKey"`
	Name        string  `json:"name" gorm:"not null"`
	Description string  `json:"description"`
	Icon        string  `json:"icon"`
	BasePrice   float64 `json:"base_price" gorm:"type:decimal(10,2);not null"`
	PriceMin    float64 `json:"price_min" gorm:"type:decimal(10,2);not null"`
	PriceMax    float64 `json:"price_max" gorm:"type:decimal(10,2);not null"`
	GrowthTime  int     `json:"growth_time" gorm:"not null"`
	Stages      int     `json:"stages" gorm:"default:5"`
	Season      string  `json:"season"`
	UnlockLevel int     `json:"unlock_level" gorm:"default:1"`
	IsActive    bool    `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

func (Seed) TableName() string {
	return "seeds"
}

// Crop 作物表
type Crop struct {
	ID            uint    `json:"id" gorm:"primaryKey"`
	SeedID        uint    `json:"seed_id" gorm:"not null"`
	Name          string  `json:"name" gorm:"not null"`
	Description   string  `json:"description"`
	Icon          string  `json:"icon"`
	BaseSellPrice float64 `json:"base_sell_price" gorm:"type:decimal(10,2);not null"`
	SellPriceMin  float64 `json:"sell_price_min" gorm:"type:decimal(10,2);not null"`
	SellPriceMax  float64 `json:"sell_price_max" gorm:"type:decimal(10,2);not null"`
	YieldMin      int     `json:"yield_min" gorm:"default:1"`
	YieldMax      int     `json:"yield_max" gorm:"default:3"`
	ExpReward     int     `json:"exp_reward" gorm:"default:10"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`

	Seed Seed `json:"seed" gorm:"foreignKey:SeedID"`
}

func (Crop) TableName() string {
	return "crops"
}

// UserFarm 用户农田表
type UserFarm struct {
	ID        uint       `json:"id" gorm:"primaryKey"`
	UserID    uint       `json:"user_id" gorm:"not null;index"`
	SlotIndex int        `json:"slot_index" gorm:"not null"`
	SeedID    *uint      `json:"seed_id"`
	PlantedAt *time.Time `json:"planted_at"`
	Stage     int        `json:"stage" gorm:"default:0"`
	Status    string     `json:"status" gorm:"type:enum('empty','growing','mature','withered');default:'empty'"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`

	Seed *Seed `json:"seed" gorm:"foreignKey:SeedID"`
}

func (UserFarm) TableName() string {
	return "user_farms"
}

// UserInventory 用户仓库表
type UserInventory struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"not null;index"`
	ItemType  string    `json:"item_type" gorm:"type:enum('seed','crop','tool','material');not null"`
	ItemID    uint      `json:"item_id" gorm:"not null"`
	Quantity  int       `json:"quantity" gorm:"default:0"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (UserInventory) TableName() string {
	return "user_inventory"
}
