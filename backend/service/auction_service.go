package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"time"
)

type AuctionService struct {
	auctionRepo *repository.AuctionRepository
	farmRepo    *repository.FarmRepository
	userRepo    *repository.UserRepository
}

func NewAuctionService() *AuctionService {
	return &AuctionService{
		auctionRepo: repository.NewAuctionRepository(),
		farmRepo:    repository.NewFarmRepository(),
		userRepo:    repository.NewUserRepository(),
	}
}

// GetActiveAuctions 获取进行中的拍卖
func (s *AuctionService) GetActiveAuctions(itemType string, page, pageSize int) ([]models.Auction, int64, error) {
	return s.auctionRepo.GetActiveAuctions(itemType, page, pageSize)
}

// GetAuctionByID 获取拍卖详情
func (s *AuctionService) GetAuctionByID(id uint) (*models.Auction, error) {
	return s.auctionRepo.GetAuctionByID(id)
}

// GetAuctionBids 获取出价记录
func (s *AuctionService) GetAuctionBids(auctionID uint) ([]models.AuctionBid, error) {
	return s.auctionRepo.GetAuctionBids(auctionID)
}

// CreateAuction 创建拍卖
func (s *AuctionService) CreateAuction(userID uint, itemType string, itemID uint, quantity int, startPrice float64, buyoutPrice *float64, duration int) (*models.Auction, error) {
	// 检查仓库是否有物品
	item, err := s.farmRepo.GetUserInventoryItem(userID, itemType, itemID)
	if err != nil || item.Quantity < quantity {
		return nil, errors.New("物品数量不足")
	}

	// 扣除物品
	if err := s.farmRepo.RemoveFromInventory(userID, itemType, itemID, quantity); err != nil {
		return nil, err
	}

	now := time.Now()
	auction := &models.Auction{
		SellerID:     userID,
		ItemType:     itemType,
		ItemID:       itemID,
		Quantity:     quantity,
		StartPrice:   startPrice,
		CurrentPrice: startPrice,
		BuyoutPrice:  buyoutPrice,
		Status:       "active",
		StartAt:      now,
		EndAt:        now.Add(time.Duration(duration) * time.Hour),
	}

	if err := s.auctionRepo.CreateAuction(auction); err != nil {
		// 回滚物品
		s.farmRepo.AddToInventory(userID, itemType, itemID, quantity)
		return nil, err
	}

	return auction, nil
}

// PlaceBid 出价
func (s *AuctionService) PlaceBid(userID, auctionID uint, bidPrice float64) error {
	auction, err := s.auctionRepo.GetAuctionByID(auctionID)
	if err != nil {
		return errors.New("拍卖不存在")
	}

	if auction.Status != "active" {
		return errors.New("拍卖已结束")
	}

	if time.Now().After(auction.EndAt) {
		return errors.New("拍卖已过期")
	}

	if auction.SellerID == userID {
		return errors.New("不能竞拍自己的物品")
	}

	if bidPrice <= auction.CurrentPrice {
		return errors.New("出价必须高于当前价格")
	}

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return errors.New("用户不存在")
	}

	if user.Gold < bidPrice {
		return errors.New("金币不足")
	}

	// 退还上一个出价者的金币
	if auction.HighestBidder != nil && *auction.HighestBidder != userID {
		s.userRepo.UpdateGold(*auction.HighestBidder, auction.CurrentPrice)
	}

	// 扣除当前出价者金币
	if err := s.userRepo.UpdateGold(userID, -bidPrice); err != nil {
		return err
	}

	// 更新拍卖
	auction.CurrentPrice = bidPrice
	auction.HighestBidder = &userID
	auction.BidCount++

	// 记录出价
	bid := &models.AuctionBid{
		AuctionID: auctionID,
		UserID:    userID,
		BidPrice:  bidPrice,
	}
	s.auctionRepo.CreateBid(bid)

	return s.auctionRepo.UpdateAuction(auction)
}

// Buyout 一口价购买
func (s *AuctionService) Buyout(userID, auctionID uint) error {
	auction, err := s.auctionRepo.GetAuctionByID(auctionID)
	if err != nil {
		return errors.New("拍卖不存在")
	}

	if auction.Status != "active" {
		return errors.New("拍卖已结束")
	}

	if auction.BuyoutPrice == nil {
		return errors.New("该拍卖不支持一口价")
	}

	if auction.SellerID == userID {
		return errors.New("不能购买自己的物品")
	}

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return errors.New("用户不存在")
	}

	if user.Gold < *auction.BuyoutPrice {
		return errors.New("金币不足")
	}

	// 退还上一个出价者的金币
	if auction.HighestBidder != nil {
		s.userRepo.UpdateGold(*auction.HighestBidder, auction.CurrentPrice)
	}

	// 扣除买家金币
	if err := s.userRepo.UpdateGold(userID, -*auction.BuyoutPrice); err != nil {
		return err
	}

	// 给卖家金币
	s.userRepo.UpdateGold(auction.SellerID, *auction.BuyoutPrice)

	// 给买家物品
	s.farmRepo.AddToInventory(userID, auction.ItemType, auction.ItemID, auction.Quantity)

	// 更新拍卖状态
	auction.Status = "sold"
	auction.CurrentPrice = *auction.BuyoutPrice
	auction.HighestBidder = &userID

	return s.auctionRepo.UpdateAuction(auction)
}

// CancelAuction 取消拍卖
func (s *AuctionService) CancelAuction(userID, auctionID uint) error {
	auction, err := s.auctionRepo.GetAuctionByID(auctionID)
	if err != nil {
		return errors.New("拍卖不存在")
	}

	if auction.SellerID != userID {
		return errors.New("无权操作")
	}

	if auction.Status != "active" {
		return errors.New("拍卖已结束")
	}

	if auction.BidCount > 0 {
		return errors.New("已有出价，无法取消")
	}

	// 返还物品
	s.farmRepo.AddToInventory(userID, auction.ItemType, auction.ItemID, auction.Quantity)

	auction.Status = "cancelled"
	return s.auctionRepo.UpdateAuction(auction)
}

// ProcessExpiredAuctions 处理过期拍卖
func (s *AuctionService) ProcessExpiredAuctions() error {
	auctions, err := s.auctionRepo.GetExpiredAuctions()
	if err != nil {
		return err
	}

	for _, auction := range auctions {
		if auction.HighestBidder != nil {
			// 有人出价，成交
			s.userRepo.UpdateGold(auction.SellerID, auction.CurrentPrice)
			s.farmRepo.AddToInventory(*auction.HighestBidder, auction.ItemType, auction.ItemID, auction.Quantity)
			auction.Status = "sold"
		} else {
			// 无人出价，流拍
			s.farmRepo.AddToInventory(auction.SellerID, auction.ItemType, auction.ItemID, auction.Quantity)
			auction.Status = "expired"
		}
		s.auctionRepo.UpdateAuction(&auction)
	}

	return nil
}

// GetUserAuctions 获取用户的拍卖
func (s *AuctionService) GetUserAuctions(userID uint, status string) ([]models.Auction, error) {
	return s.auctionRepo.GetUserAuctions(userID, status)
}

// GetUserBidAuctions 获取用户参与的拍卖
func (s *AuctionService) GetUserBidAuctions(userID uint) ([]models.Auction, error) {
	return s.auctionRepo.GetUserBidAuctions(userID)
}
