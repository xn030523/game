package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"farm-game/ws"
	"math"
	"time"
)

type StockService struct {
	stockRepo *repository.StockRepository
	userRepo  *repository.UserRepository
}

func NewStockService() *StockService {
	return &StockService{
		stockRepo: repository.NewStockRepository(),
		userRepo:  repository.NewUserRepository(),
	}
}

// GetAllStocks 获取所有股票
func (s *StockService) GetAllStocks() ([]models.Stock, error) {
	return s.stockRepo.GetAllStocks()
}

// GetStockByID 获取股票详情
func (s *StockService) GetStockByID(id uint) (*models.Stock, error) {
	return s.stockRepo.GetStockByID(id)
}

// GetStockKLine 获取K线数据
func (s *StockService) GetStockKLine(stockID uint, periodType string, limit int) ([]models.StockPrice, error) {
	return s.stockRepo.GetStockPrices(stockID, periodType, limit)
}

// === 现货交易 ===

// BuyStock 买入股票(现货)
func (s *StockService) BuyStock(userID, stockID uint, shares int64) error {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return errors.New("用户不存在")
	}

	stock, err := s.stockRepo.GetStockByID(stockID)
	if err != nil {
		return errors.New("股票不存在")
	}

	if stock.AvailableShares < shares {
		return errors.New("可用股份不足")
	}

	totalCost := stock.CurrentPrice * float64(shares)
	if user.Gold < totalCost {
		return errors.New("金币不足")
	}

	// 扣除金币
	if err := s.userRepo.UpdateGold(userID, -totalCost); err != nil {
		return err
	}

	// 更新股票可用股份
	stock.AvailableShares -= shares
	stock.TodayVolume += shares
	stock.TodayAmount += totalCost
	if err := s.stockRepo.UpdateStock(stock); err != nil {
		return err
	}

	// 更新用户持仓
	userStock, err := s.stockRepo.GetUserStock(userID, stockID)
	if err != nil {
		// 创建新持仓
		userStock = &models.UserStock{
			UserID:    userID,
			StockID:   stockID,
			Shares:    shares,
			AvgCost:   stock.CurrentPrice,
			TotalCost: totalCost,
		}
		if err := s.stockRepo.CreateUserStock(userStock); err != nil {
			return err
		}
	} else {
		// 更新持仓
		newTotalCost := userStock.TotalCost + totalCost
		newShares := userStock.Shares + shares
		userStock.AvgCost = newTotalCost / float64(newShares)
		userStock.Shares = newShares
		userStock.TotalCost = newTotalCost
		if err := s.stockRepo.UpdateUserStock(userStock); err != nil {
			return err
		}
	}

	// 记录订单
	order := &models.StockOrder{
		UserID:      userID,
		StockID:     stockID,
		OrderType:   "buy",
		Shares:      shares,
		Price:       stock.CurrentPrice,
		TotalAmount: totalCost,
	}
	s.stockRepo.CreateStockOrder(order)

	// 买入推动价格上涨（每100股涨0.1%）
	s.updateStockPrice(stock, shares, true)
	return nil
}

// SellStock 卖出股票(现货)
func (s *StockService) SellStock(userID, stockID uint, shares int64) (float64, error) {
	userStock, err := s.stockRepo.GetUserStock(userID, stockID)
	if err != nil || userStock.Shares < shares {
		return 0, errors.New("持仓不足")
	}

	stock, err := s.stockRepo.GetStockByID(stockID)
	if err != nil {
		return 0, errors.New("股票不存在")
	}

	totalAmount := stock.CurrentPrice * float64(shares)
	profit := totalAmount - userStock.AvgCost*float64(shares)

	// 增加金币
	if err := s.userRepo.UpdateGold(userID, totalAmount); err != nil {
		return 0, err
	}

	// 更新股票可用股份
	stock.AvailableShares += shares
	stock.TodayVolume += shares
	stock.TodayAmount += totalAmount
	if err := s.stockRepo.UpdateStock(stock); err != nil {
		return 0, err
	}

	// 更新用户持仓
	userStock.Shares -= shares
	userStock.TotalCost -= userStock.AvgCost * float64(shares)
	userStock.RealizedProfit += profit
	if err := s.stockRepo.UpdateUserStock(userStock); err != nil {
		return 0, err
	}

	// 更新统计
	s.updateUserStats(userID, profit)

	// 记录订单
	order := &models.StockOrder{
		UserID:      userID,
		StockID:     stockID,
		OrderType:   "sell",
		Shares:      shares,
		Price:       stock.CurrentPrice,
		TotalAmount: totalAmount,
		Profit:      profit,
	}
	s.stockRepo.CreateStockOrder(order)

	// 卖出推动价格下跌（每100股跌0.1%）
	s.updateStockPrice(stock, shares, false)

	return profit, nil
}

// === 杠杆交易 ===

// OpenLongPosition 开多仓
func (s *StockService) OpenLongPosition(userID, stockID uint, leverage int, margin float64) (*models.UserLeveragePosition, error) {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return nil, errors.New("用户不存在")
	}

	stock, err := s.stockRepo.GetStockByID(stockID)
	if err != nil {
		return nil, errors.New("股票不存在")
	}

	if leverage > stock.MaxLeverage {
		return nil, errors.New("超过最大杠杆")
	}

	if user.Gold < margin {
		return nil, errors.New("保证金不足")
	}

	// 计算仓位
	shares := int64(margin * float64(leverage) / stock.CurrentPrice)
	liquidationPrice := stock.CurrentPrice * (1 - 0.9/float64(leverage))

	// 扣除保证金
	if err := s.userRepo.UpdateGold(userID, -margin); err != nil {
		return nil, err
	}

	position := &models.UserLeveragePosition{
		UserID:           userID,
		StockID:          stockID,
		PositionType:     "long",
		Leverage:         leverage,
		Shares:           shares,
		EntryPrice:       stock.CurrentPrice,
		Margin:           margin,
		LiquidationPrice: liquidationPrice,
		Status:           "open",
	}

	if err := s.stockRepo.CreateLeveragePosition(position); err != nil {
		return nil, err
	}

	// 记录订单
	order := &models.StockOrder{
		UserID:      userID,
		StockID:     stockID,
		OrderType:   "long_open",
		Leverage:    leverage,
		Shares:      shares,
		Price:       stock.CurrentPrice,
		TotalAmount: margin * float64(leverage),
		Margin:      margin,
		PositionID:  &position.ID,
	}
	s.stockRepo.CreateStockOrder(order)

	return position, nil
}

// OpenShortPosition 开空仓
func (s *StockService) OpenShortPosition(userID, stockID uint, leverage int, margin float64) (*models.UserLeveragePosition, error) {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return nil, errors.New("用户不存在")
	}

	stock, err := s.stockRepo.GetStockByID(stockID)
	if err != nil {
		return nil, errors.New("股票不存在")
	}

	if leverage > stock.MaxLeverage {
		return nil, errors.New("超过最大杠杆")
	}

	if user.Gold < margin {
		return nil, errors.New("保证金不足")
	}

	shares := int64(margin * float64(leverage) / stock.CurrentPrice)
	liquidationPrice := stock.CurrentPrice * (1 + 0.9/float64(leverage))

	if err := s.userRepo.UpdateGold(userID, -margin); err != nil {
		return nil, err
	}

	position := &models.UserLeveragePosition{
		UserID:           userID,
		StockID:          stockID,
		PositionType:     "short",
		Leverage:         leverage,
		Shares:           shares,
		EntryPrice:       stock.CurrentPrice,
		Margin:           margin,
		LiquidationPrice: liquidationPrice,
		Status:           "open",
	}

	if err := s.stockRepo.CreateLeveragePosition(position); err != nil {
		return nil, err
	}

	order := &models.StockOrder{
		UserID:      userID,
		StockID:     stockID,
		OrderType:   "short_open",
		Leverage:    leverage,
		Shares:      shares,
		Price:       stock.CurrentPrice,
		TotalAmount: margin * float64(leverage),
		Margin:      margin,
		PositionID:  &position.ID,
	}
	s.stockRepo.CreateStockOrder(order)

	return position, nil
}

// ClosePosition 平仓
func (s *StockService) ClosePosition(userID, positionID uint) (float64, error) {
	position, err := s.stockRepo.GetLeveragePosition(positionID)
	if err != nil {
		return 0, errors.New("仓位不存在")
	}

	if position.UserID != userID {
		return 0, errors.New("无权操作")
	}

	if position.Status != "open" {
		return 0, errors.New("仓位已关闭")
	}

	stock, _ := s.stockRepo.GetStockByID(position.StockID)

	// 计算盈亏
	var profit float64
	if position.PositionType == "long" {
		profit = (stock.CurrentPrice - position.EntryPrice) * float64(position.Shares)
	} else {
		profit = (position.EntryPrice - stock.CurrentPrice) * float64(position.Shares)
	}

	// 返还保证金+盈亏
	returnAmount := position.Margin + profit
	if returnAmount > 0 {
		s.userRepo.UpdateGold(userID, returnAmount)
	}

	// 更新仓位
	now := time.Now()
	position.Status = "closed"
	position.ClosedAt = &now
	position.UnrealizedProfit = profit
	s.stockRepo.UpdateLeveragePosition(position)

	// 更新统计
	s.updateUserStats(userID, profit)

	// 记录订单
	orderType := "long_close"
	if position.PositionType == "short" {
		orderType = "short_close"
	}
	order := &models.StockOrder{
		UserID:      userID,
		StockID:     position.StockID,
		OrderType:   orderType,
		Leverage:    position.Leverage,
		Shares:      position.Shares,
		Price:       stock.CurrentPrice,
		TotalAmount: returnAmount,
		Profit:      profit,
		PositionID:  &positionID,
	}
	s.stockRepo.CreateStockOrder(order)

	return profit, nil
}

// CheckAndLiquidate 检查并执行强平
func (s *StockService) CheckAndLiquidate(stockID uint, currentPrice float64) error {
	positions, err := s.stockRepo.GetOpenPositionsForLiquidation(stockID)
	if err != nil {
		return err
	}

	for _, position := range positions {
		shouldLiquidate := false
		if position.PositionType == "long" && currentPrice <= position.LiquidationPrice {
			shouldLiquidate = true
		} else if position.PositionType == "short" && currentPrice >= position.LiquidationPrice {
			shouldLiquidate = true
		}

		if shouldLiquidate {
			now := time.Now()
			position.Status = "liquidated"
			position.ClosedAt = &now
			position.UnrealizedProfit = -position.Margin // 亏损全部保证金
			s.stockRepo.UpdateLeveragePosition(&position)

			// 更新统计
			s.updateUserStats(position.UserID, -position.Margin)
		}
	}

	return nil
}

// GetUserPositions 获取用户杠杆仓位
func (s *StockService) GetUserPositions(userID uint, status string) ([]models.UserLeveragePosition, error) {
	positions, err := s.stockRepo.GetUserLeveragePositions(userID, status)
	if err != nil {
		return nil, err
	}

	// 计算未实现盈亏
	for i := range positions {
		if positions[i].Status == "open" {
			stock, _ := s.stockRepo.GetStockByID(positions[i].StockID)
			if stock != nil {
				if positions[i].PositionType == "long" {
					positions[i].UnrealizedProfit = (stock.CurrentPrice - positions[i].EntryPrice) * float64(positions[i].Shares)
				} else {
					positions[i].UnrealizedProfit = (positions[i].EntryPrice - stock.CurrentPrice) * float64(positions[i].Shares)
				}
			}
		}
	}

	return positions, nil
}

// GetUserStocks 获取用户现货持仓
func (s *StockService) GetUserStocks(userID uint) ([]models.UserStock, error) {
	return s.stockRepo.GetUserStocks(userID)
}

// GetUserStockStats 获取用户股票统计
func (s *StockService) GetUserStockStats(userID uint) (*models.UserStockStats, error) {
	stats, err := s.stockRepo.GetUserStockStats(userID)
	if err != nil {
		// 创建默认统计
		stats = &models.UserStockStats{UserID: userID}
		s.stockRepo.CreateUserStockStats(stats)
		return stats, nil
	}
	return stats, nil
}

// updateUserStats 更新用户统计
func (s *StockService) updateUserStats(userID uint, profit float64) {
	stats, _ := s.GetUserStockStats(userID)
	if stats == nil {
		return
	}

	stats.TotalProfit += profit
	stats.TodayProfit += profit
	stats.TradeCount++

	if profit > 0 {
		stats.WinCount++
		if profit > stats.MaxProfit {
			stats.MaxProfit = profit
		}
	} else if profit < 0 {
		stats.LoseCount++
		if profit < stats.MaxLoss {
			stats.MaxLoss = profit
		}
	}

	if stats.WinCount+stats.LoseCount > 0 {
		stats.WinRate = float64(stats.WinCount) / float64(stats.WinCount+stats.LoseCount) * 100
	}

	s.stockRepo.UpdateUserStockStats(stats)
}

// GetRankings 获取排行榜
func (s *StockService) GetRankings(rankType string, limit int) ([]models.StockRanking, error) {
	return s.stockRepo.GetStockRankings(rankType, limit)
}

// CalculateUserTotalAssets 计算用户股票总资产
func (s *StockService) CalculateUserTotalAssets(userID uint) float64 {
	var total float64

	// 现货持仓
	stocks, _ := s.stockRepo.GetUserStocks(userID)
	for _, us := range stocks {
		stock, _ := s.stockRepo.GetStockByID(us.StockID)
		if stock != nil {
			total += stock.CurrentPrice * float64(us.Shares)
		}
	}

	// 杠杆仓位保证金
	positions, _ := s.stockRepo.GetUserLeveragePositions(userID, "open")
	for _, p := range positions {
		total += p.Margin + p.UnrealizedProfit
	}

	return math.Max(0, total)
}

// updateStockPrice 根据交易更新股票价格并广播
func (s *StockService) updateStockPrice(stock *models.Stock, shares int64, isBuy bool) {
	oldPrice := stock.CurrentPrice
	// 每100股波动0.1%
	changePercent := float64(shares) / 100.0 * 0.001
	if !isBuy {
		changePercent = -changePercent
	}
	
	newPrice := oldPrice * (1 + changePercent)
	// 限制在涨跌停范围内（±10%）
	if stock.OpenPrice != nil {
		maxPrice := *stock.OpenPrice * 1.1
		minPrice := *stock.OpenPrice * 0.9
		if newPrice > maxPrice {
			newPrice = maxPrice
		} else if newPrice < minPrice {
			newPrice = minPrice
		}
		stock.ChangePercent = (newPrice - *stock.OpenPrice) / *stock.OpenPrice * 100
	}
	
	stock.CurrentPrice = newPrice
	s.stockRepo.UpdateStock(stock)
	
	// WebSocket 广播价格更新
	ws.GameHub.Broadcast(ws.NewMessage(ws.MsgTypeStockPrice, map[string]interface{}{
		"stock_id":       stock.ID,
		"code":           stock.Code,
		"current_price":  newPrice,
		"change_percent": stock.ChangePercent,
		"open_price":     stock.OpenPrice,
	}))
}
