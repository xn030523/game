package repository

import (
	"farm-game/config"
	"farm-game/models"
	"time"

	"gorm.io/gorm"
)

type AuctionRepository struct {
	db *gorm.DB
}

func NewAuctionRepository() *AuctionRepository {
	return &AuctionRepository{db: config.GetDB()}
}

// GetActiveAuctions 获取进行中的拍卖
func (r *AuctionRepository) GetActiveAuctions(itemType string, page, pageSize int) ([]models.Auction, int64, error) {
	var auctions []models.Auction
	var total int64

	query := r.db.Model(&models.Auction{}).Where("status = 'active' AND end_at > ?", time.Now())
	if itemType != "" {
		query = query.Where("item_type = ?", itemType)
	}

	query.Count(&total)
	err := query.Preload("Seller").
		Order("end_at ASC").
		Offset((page - 1) * pageSize).Limit(pageSize).
		Find(&auctions).Error

	return auctions, total, err
}

// GetAuctionByID 根据ID获取拍卖
func (r *AuctionRepository) GetAuctionByID(id uint) (*models.Auction, error) {
	var auction models.Auction
	err := r.db.Preload("Seller").Preload("HighestBidderUser").First(&auction, id).Error
	if err != nil {
		return nil, err
	}
	return &auction, nil
}

// GetUserAuctions 获取用户的拍卖
func (r *AuctionRepository) GetUserAuctions(userID uint, status string) ([]models.Auction, error) {
	var auctions []models.Auction
	query := r.db.Where("seller_id = ?", userID)
	if status != "" {
		query = query.Where("status = ?", status)
	}
	err := query.Order("created_at DESC").Find(&auctions).Error
	return auctions, err
}

// GetUserBidAuctions 获取用户参与竞拍的拍卖
func (r *AuctionRepository) GetUserBidAuctions(userID uint) ([]models.Auction, error) {
	var auctions []models.Auction
	err := r.db.Where("highest_bidder = ? AND status = 'active'", userID).Find(&auctions).Error
	return auctions, err
}

// CreateAuction 创建拍卖
func (r *AuctionRepository) CreateAuction(auction *models.Auction) error {
	return r.db.Create(auction).Error
}

// UpdateAuction 更新拍卖
func (r *AuctionRepository) UpdateAuction(auction *models.Auction) error {
	return r.db.Save(auction).Error
}

// CreateBid 创建出价记录
func (r *AuctionRepository) CreateBid(bid *models.AuctionBid) error {
	return r.db.Create(bid).Error
}

// GetAuctionBids 获取拍卖的出价记录
func (r *AuctionRepository) GetAuctionBids(auctionID uint) ([]models.AuctionBid, error) {
	var bids []models.AuctionBid
	err := r.db.Where("auction_id = ?", auctionID).
		Preload("User").Order("created_at DESC").Find(&bids).Error
	return bids, err
}

// GetExpiredAuctions 获取已过期的拍卖
func (r *AuctionRepository) GetExpiredAuctions() ([]models.Auction, error) {
	var auctions []models.Auction
	err := r.db.Where("status = 'active' AND end_at <= ?", time.Now()).Find(&auctions).Error
	return auctions, err
}
