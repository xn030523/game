package models

import "time"

// BlackmarketBatch 黑市刷新批次表
type BlackmarketBatch struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	StartAt   time.Time `json:"start_at" gorm:"not null"`
	EndAt     time.Time `json:"end_at" gorm:"not null"`
	IsActive  bool      `json:"is_active" gorm:"default:true"`
	CreatedAt time.Time `json:"created_at"`
}

func (BlackmarketBatch) TableName() string {
	return "blackmarket_batches"
}

// BlackmarketItem 黑市商品表
type BlackmarketItem struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	BatchID     uint      `json:"batch_id" gorm:"not null;index"`
	Name        string    `json:"name" gorm:"not null"`
	Description string    `json:"description"`
	Icon        string    `json:"icon"`
	ItemType    string    `json:"item_type" gorm:"type:enum('seed','crop','tool','special');not null"`
	ItemID      *uint     `json:"item_id"`
	Price       float64   `json:"price" gorm:"type:decimal(10,2);not null"`
	TotalStock  int       `json:"total_stock" gorm:"not null"`
	SoldCount   int       `json:"sold_count" gorm:"default:0"`
	UnlockLevel int       `json:"unlock_level" gorm:"default:1"`
	CreatedAt   time.Time `json:"created_at"`

	Batch BlackmarketBatch `json:"batch" gorm:"foreignKey:BatchID"`
}

func (BlackmarketItem) TableName() string {
	return "blackmarket_items"
}

// BlackmarketLog 黑市交易记录
type BlackmarketLog struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	UserID     uint      `json:"user_id" gorm:"not null;index"`
	BatchID    uint      `json:"batch_id" gorm:"not null;index"`
	ItemID     uint      `json:"item_id" gorm:"not null"`
	Quantity   int       `json:"quantity" gorm:"not null"`
	Price      float64   `json:"price" gorm:"type:decimal(10,2);not null"`
	TotalPrice float64   `json:"total_price" gorm:"type:decimal(20,2);not null"`
	CreatedAt  time.Time `json:"created_at"`

	User  User            `json:"user" gorm:"foreignKey:UserID"`
	Batch BlackmarketBatch `json:"batch" gorm:"foreignKey:BatchID"`
	Item  BlackmarketItem `json:"item" gorm:"foreignKey:ItemID"`
}

func (BlackmarketLog) TableName() string {
	return "blackmarket_logs"
}

// CharityTransfer 公益站转换记录
type CharityTransfer struct {
	ID            uint       `json:"id" gorm:"primaryKey"`
	UserID        uint       `json:"user_id" gorm:"not null;index"`
	TransferType  string     `json:"transfer_type" gorm:"type:enum('in','out');not null"`
	Amount        float64    `json:"amount" gorm:"type:decimal(20,2);not null"`
	CharityAmount float64    `json:"charity_amount" gorm:"type:decimal(20,2);not null"`
	ExchangeRate  float64    `json:"exchange_rate" gorm:"type:decimal(10,4);not null"`
	Status        string     `json:"status" gorm:"type:enum('pending','completed','failed');default:'pending'"`
	Remark        string     `json:"remark"`
	CreatedAt     time.Time  `json:"created_at"`
	CompletedAt   *time.Time `json:"completed_at"`

	User User `json:"user" gorm:"foreignKey:UserID"`
}

func (CharityTransfer) TableName() string {
	return "charity_transfers"
}
