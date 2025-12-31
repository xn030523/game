package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"farm-game/ws"
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
func (s *AuctionService) GetActiveAuctions(page, pageSize int) ([]models.Auction, int64, error) {
	auctions, total, err := s.auctionRepo.GetActiveAuctions(page, pageSize)
	if err != nil {
		return nil, 0, err
	}

	// 填充物品名称
	for i := range auctions {
		auctions[i].ItemName = s.getItemName(auctions[i].ItemType, auctions[i].ItemID)
	}

	return auctions, total, nil
}

// GetAuctionDetail 获取拍卖详情
func (s *AuctionService) GetAuctionDetail(id uint) (*models.Auction, []models.AuctionBid, error) {
	auction, err := s.auctionRepo.GetAuctionByID(id)
	if err != nil {
		return nil, nil, errors.New("拍卖不存在")
	}

	auction.ItemName = s.getItemName(auction.ItemType, auction.ItemID)
	bids, _ := s.auctionRepo.GetAuctionBids(id)

	return auction, bids, nil
}

// CreateAuction 上架拍卖
func (s *AuctionService) CreateAuction(userID uint, itemType string, itemID uint, quantity int, startPrice float64, buyoutPrice *float64, duration int) (*models.Auction, error) {
	// 检查物品数量
	item, err := s.farmRepo.GetUserInventoryItem(userID, itemType, itemID)
	if err != nil || item.Quantity < quantity {
		return nil, errors.New("物品数量不足")
	}

	// 验证价格
	if startPrice <= 0 {
		return nil, errors.New("起拍价必须大于0")
	}
	if buyoutPrice != nil && *buyoutPrice <= startPrice {
		return nil, errors.New("一口价必须大于起拍价")
	}

	// 扣除物品
	if err := s.farmRepo.RemoveFromInventory(userID, itemType, itemID, quantity); err != nil {
		return nil, err
	}

	// 创建拍卖
	now := time.Now()
	auction := &models.Auction{
		SellerID:     userID,
		ItemType:     itemType,
		ItemID:       itemID,
		Quantity:     quantity,
		StartPrice:   startPrice,
		BuyoutPrice:  buyoutPrice,
		CurrentPrice: startPrice,
		StartAt:      now,
		EndAt:        now.Add(time.Duration(duration) * time.Hour),
		Status:       "active",
	}

	if err := s.auctionRepo.CreateAuction(auction); err != nil {
		// 回滚物品
		s.farmRepo.AddToInventory(userID, itemType, itemID, quantity)
		return nil, err
	}

	auction.ItemName = s.getItemName(itemType, itemID)
	return auction, nil
}

// PlaceBid 出价
func (s *AuctionService) PlaceBid(userID uint, auctionID uint, bidPrice float64) error {
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

	// 检查金币
	user, _ := s.userRepo.FindByID(userID)
	if user.Gold < bidPrice {
		return errors.New("金币不足")
	}

	// 冻结金币
	if err := s.userRepo.UpdateGold(userID, -bidPrice); err != nil {
		return err
	}

	// 退还上一个出价者的金币
	if auction.HighestBidder != nil && *auction.HighestBidder != userID {
		s.userRepo.UpdateGold(*auction.HighestBidder, auction.CurrentPrice)
	}

	// 更新拍卖
	auction.CurrentPrice = bidPrice
	auction.HighestBidder = &userID
	auction.BidCount++

	// 如果剩余时间少于5分钟，延长5分钟
	remaining := time.Until(auction.EndAt)
	if remaining < 5*time.Minute {
		auction.EndAt = time.Now().Add(5 * time.Minute)
	}

	if err := s.auctionRepo.UpdateAuction(auction); err != nil {
		// 回滚金币
		s.userRepo.UpdateGold(userID, bidPrice)
		return err
	}

	// 记录出价
	bid := &models.AuctionBid{
		AuctionID: auctionID,
		UserID:    userID,
		BidPrice:  bidPrice,
		CreatedAt: time.Now(),
	}
	s.auctionRepo.CreateBid(bid)

	// WebSocket 通知
	s.broadcastAuctionUpdate(auction)

	return nil
}

// Buyout 一口价购买
func (s *AuctionService) Buyout(userID uint, auctionID uint) error {
	auction, err := s.auctionRepo.GetAuctionByID(auctionID)
	if err != nil {
		return errors.New("拍卖不存在")
	}

	if auction.Status != "active" {
		return errors.New("拍卖已结束")
	}
	if auction.BuyoutPrice == nil {
		return errors.New("此拍卖不支持一口价")
	}
	if auction.SellerID == userID {
		return errors.New("不能购买自己的物品")
	}

	buyoutPrice := *auction.BuyoutPrice

	// 如果买家是当前最高出价者，先退还他的出价
	if auction.HighestBidder != nil && *auction.HighestBidder == userID {
		s.userRepo.UpdateGold(userID, auction.CurrentPrice)
	}

	// 检查金币
	user, _ := s.userRepo.FindByID(userID)
	if user.Gold < buyoutPrice {
		return errors.New("金币不足")
	}

	// 扣除金币
	if err := s.userRepo.UpdateGold(userID, -buyoutPrice); err != nil {
		return err
	}

	// 退还之前出价者的金币（如果不是买家自己）
	if auction.HighestBidder != nil && *auction.HighestBidder != userID {
		s.userRepo.UpdateGold(*auction.HighestBidder, auction.CurrentPrice)
	}

	// 给卖家金币（扣5%手续费）
	sellerEarning := buyoutPrice * 0.95
	s.userRepo.UpdateGold(auction.SellerID, sellerEarning)

	// 给买家物品
	s.farmRepo.AddToInventory(userID, auction.ItemType, auction.ItemID, auction.Quantity)

	// 更新拍卖状态
	auction.Status = "sold"
	auction.CurrentPrice = buyoutPrice
	auction.HighestBidder = &userID
	s.auctionRepo.UpdateAuction(auction)

	// WebSocket 通知
	s.broadcastAuctionUpdate(auction)

	return nil
}

// CancelAuction 取消拍卖（无人出价时）
func (s *AuctionService) CancelAuction(userID uint, auctionID uint) error {
	auction, err := s.auctionRepo.GetAuctionByID(auctionID)
	if err != nil {
		return errors.New("拍卖不存在")
	}

	if auction.SellerID != userID {
		return errors.New("只能取消自己的拍卖")
	}
	if auction.Status != "active" {
		return errors.New("拍卖已结束")
	}
	if auction.BidCount > 0 {
		return errors.New("已有人出价，无法取消")
	}

	// 退还物品
	s.farmRepo.AddToInventory(userID, auction.ItemType, auction.ItemID, auction.Quantity)

	// 更新状态
	auction.Status = "cancelled"
	s.auctionRepo.UpdateAuction(auction)

	return nil
}

// GetMyAuctions 获取我的拍卖
func (s *AuctionService) GetMyAuctions(userID uint) ([]models.Auction, []models.Auction, error) {
	selling, err := s.auctionRepo.GetUserAuctions(userID)
	if err != nil {
		return nil, nil, err
	}
	for i := range selling {
		selling[i].ItemName = s.getItemName(selling[i].ItemType, selling[i].ItemID)
	}

	bidding, err := s.auctionRepo.GetUserBids(userID)
	if err != nil {
		return nil, nil, err
	}
	for i := range bidding {
		bidding[i].ItemName = s.getItemName(bidding[i].ItemType, bidding[i].ItemID)
	}

	return selling, bidding, nil
}

// GetAuctionHistory 获取拍卖历史记录
func (s *AuctionService) GetAuctionHistory(userID uint, limit int) ([]models.Auction, []models.Auction, error) {
	sold, bought, err := s.auctionRepo.GetUserAuctionHistory(userID, limit)
	if err != nil {
		return nil, nil, err
	}

	for i := range sold {
		sold[i].ItemName = s.getItemName(sold[i].ItemType, sold[i].ItemID)
	}
	for i := range bought {
		bought[i].ItemName = s.getItemName(bought[i].ItemType, bought[i].ItemID)
	}

	return sold, bought, nil
}

// ProcessExpiredAuctions 处理过期拍卖（定时任务调用）
func (s *AuctionService) ProcessExpiredAuctions() {
	auctions, _ := s.auctionRepo.GetExpiredAuctions()

	for _, auction := range auctions {
		if auction.BidCount > 0 && auction.HighestBidder != nil {
			// 有人出价，成交
			// 给卖家金币（扣5%手续费）
			sellerEarning := auction.CurrentPrice * 0.95
			s.userRepo.UpdateGold(auction.SellerID, sellerEarning)

			// 给买家物品
			s.farmRepo.AddToInventory(*auction.HighestBidder, auction.ItemType, auction.ItemID, auction.Quantity)

			auction.Status = "sold"
		} else {
			// 无人出价，流拍
			// 退还物品给卖家
			s.farmRepo.AddToInventory(auction.SellerID, auction.ItemType, auction.ItemID, auction.Quantity)

			auction.Status = "expired"
		}

		s.auctionRepo.UpdateAuction(&auction)
	}
}

// getItemName 获取物品名称
func (s *AuctionService) getItemName(itemType string, itemID uint) string {
	if itemType == "seed" {
		seed, err := s.farmRepo.GetSeedByID(itemID)
		if err == nil {
			return seed.Name
		}
	} else if itemType == "crop" {
		crop, err := s.farmRepo.GetCropByID(itemID)
		if err == nil {
			return crop.Name
		}
	}
	return "未知物品"
}

// broadcastAuctionUpdate WebSocket广播拍卖更新
func (s *AuctionService) broadcastAuctionUpdate(auction *models.Auction) {
	ws.GameHub.Broadcast(ws.NewMessage("auction_update", map[string]interface{}{
		"auction_id":    auction.ID,
		"current_price": auction.CurrentPrice,
		"bid_count":     auction.BidCount,
		"status":        auction.Status,
		"end_at":        auction.EndAt,
	}))
}
