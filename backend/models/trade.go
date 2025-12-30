package models

import "time"

// TradeLog 交易记录表
type TradeLog struct {
	ID           uint      `json:"id" gorm:"primaryKey"`
	UserID       uint      `json:"user_id" gorm:"not null;index"`
	TradeType    string    `json:"trade_type" gorm:"type:enum('buy','sell','auction','transfer','gift');not null"`
	ItemType     string    `json:"item_type" gorm:"type:enum('seed','crop','tool','material');not null"`
	ItemID       uint      `json:"item_id" gorm:"not null"`
	Quantity     int       `json:"quantity" gorm:"not null"`
	UnitPrice    float64   `json:"unit_price" gorm:"type:decimal(10,2);not null"`
	TotalPrice   float64   `json:"total_price" gorm:"type:decimal(20,2);not null"`
	TargetUserID *uint     `json:"target_user_id"`
	Remark       string    `json:"remark"`
	CreatedAt    time.Time `json:"created_at"`

	User       User  `json:"user" gorm:"foreignKey:UserID"`
	TargetUser *User `json:"target_user" gorm:"foreignKey:TargetUserID"`
}

func (TradeLog) TableName() string {
	return "trade_logs"
}

// Auction 拍卖表
type Auction struct {
	ID            uint       `json:"id" gorm:"primaryKey"`
	SellerID      uint       `json:"seller_id" gorm:"not null;index"`
	ItemType      string     `json:"item_type" gorm:"type:enum('seed','crop','tool','material');not null"`
	ItemID        uint       `json:"item_id" gorm:"not null"`
	ItemName      string     `json:"item_name" gorm:"-"`
	Quantity      int        `json:"quantity" gorm:"default:1"`
	StartPrice    float64    `json:"start_price" gorm:"type:decimal(10,2);not null"`
	CurrentPrice  float64    `json:"current_price" gorm:"type:decimal(10,2);not null"`
	BuyoutPrice   *float64   `json:"buyout_price" gorm:"type:decimal(10,2)"`
	HighestBidder *uint      `json:"highest_bidder"`
	BidCount      int        `json:"bid_count" gorm:"default:0"`
	Status        string     `json:"status" gorm:"type:enum('pending','active','sold','expired','cancelled');default:'pending'"`
	StartAt       time.Time  `json:"start_at"`
	EndAt         time.Time  `json:"end_at"`
	CreatedAt     time.Time  `json:"created_at"`

	Seller *User `json:"seller" gorm:"foreignKey:SellerID"`
	Bidder *User `json:"bidder" gorm:"foreignKey:HighestBidder"`
}

func (Auction) TableName() string {
	return "auctions"
}

// AuctionBid 拍卖出价记录
type AuctionBid struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	AuctionID uint      `json:"auction_id" gorm:"not null;index"`
	UserID    uint      `json:"user_id" gorm:"not null"`
	BidPrice  float64   `json:"bid_price" gorm:"type:decimal(10,2);not null"`
	CreatedAt time.Time `json:"created_at"`

	Auction Auction `json:"auction" gorm:"foreignKey:AuctionID"`
	User    User    `json:"user" gorm:"foreignKey:UserID"`
}

func (AuctionBid) TableName() string {
	return "auction_bids"
}
