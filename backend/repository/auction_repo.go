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
func (r *AuctionRepository) GetActiveAuctions(page, pageSize int) ([]models.Auction, int64, error) {
	var auctions []models.Auction
	var total int64

	query := r.db.Model(&models.Auction{}).Where("status = ? AND end_at > ?", "active", time.Now())
	query.Count(&total)

	offset := (page - 1) * pageSize
	err := query.Preload("Seller").Preload("Bidder").
		Order("end_at ASC").Offset(offset).Limit(pageSize).Find(&auctions).Error

	return auctions, total, err
}

// GetAuctionByID 获取拍卖详情
func (r *AuctionRepository) GetAuctionByID(id uint) (*models.Auction, error) {
	var auction models.Auction
	err := r.db.Preload("Seller").Preload("Bidder").First(&auction, id).Error
	return &auction, err
}

// CreateAuction 创建拍卖
func (r *AuctionRepository) CreateAuction(auction *models.Auction) error {
	return r.db.Create(auction).Error
}

// UpdateAuction 更新拍卖
func (r *AuctionRepository) UpdateAuction(auction *models.Auction) error {
	return r.db.Save(auction).Error
}

// GetUserAuctions 获取用户的拍卖（卖家）
func (r *AuctionRepository) GetUserAuctions(userID uint) ([]models.Auction, error) {
	var auctions []models.Auction
	err := r.db.Where("seller_id = ?", userID).
		Preload("Bidder").Order("created_at DESC").Find(&auctions).Error
	return auctions, err
}

// GetUserBids 获取用户参与的竞拍
func (r *AuctionRepository) GetUserBids(userID uint) ([]models.Auction, error) {
	var auctions []models.Auction
	err := r.db.Where("highest_bidder = ? AND status = ?", userID, "active").
		Preload("Seller").Order("end_at ASC").Find(&auctions).Error
	return auctions, err
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

// GetExpiredAuctions 获取已过期但未处理的拍卖
func (r *AuctionRepository) GetExpiredAuctions() ([]models.Auction, error) {
	var auctions []models.Auction
	err := r.db.Where("status = ? AND end_at <= ?", "active", time.Now()).Find(&auctions).Error
	return auctions, err
}

// SearchAuctions 搜索拍卖
func (r *AuctionRepository) SearchAuctions(itemType string, keyword string) ([]models.Auction, error) {
	var auctions []models.Auction
	query := r.db.Where("status = ? AND end_at > ?", "active", time.Now())
	
	if itemType != "" {
		query = query.Where("item_type = ?", itemType)
	}
	
	err := query.Preload("Seller").Order("end_at ASC").Find(&auctions).Error
	return auctions, err
}
