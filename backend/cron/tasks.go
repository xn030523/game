package cron

import (
	"farm-game/config"
	"farm-game/models"
	"farm-game/ws"
	"log"
	"math"
	"math/rand"
	"time"

	"gorm.io/gorm"
)

// UpdateMarketPrices 更新市场价格
func UpdateMarketPrices() error {
	db := config.GetDB()

	// 获取所有市场状态
	var statuses []models.MarketStatus
	if err := db.Find(&statuses).Error; err != nil {
		return err
	}

	for _, status := range statuses {
		// 获取价格规则
		var rule models.PriceRule
		if err := db.Where("item_type = ? AND item_id = ?", status.ItemType, status.ItemID).First(&rule).Error; err != nil {
			continue
		}

		// 计算供需影响
		supplyFactor := 1.0
		if status.SellVolume24h > status.BuyVolume24h {
			// 供大于求，价格下跌
			supplyFactor = 1.0 - float64(status.SellVolume24h-status.BuyVolume24h)/10000.0*rule.SupplyWeight
		} else if status.BuyVolume24h > status.SellVolume24h {
			// 求大于供，价格上涨
			supplyFactor = 1.0 + float64(status.BuyVolume24h-status.SellVolume24h)/10000.0*rule.DemandWeight
		}

		// 添加随机波动
		randomFactor := 1.0 + (rand.Float64()-0.5)*rule.Volatility

		// 计算新价格
		newRate := status.CurrentRate * supplyFactor * randomFactor

		// 限制在最小最大范围内
		if newRate < rule.MinRate {
			newRate = rule.MinRate
		}
		if newRate > rule.MaxRate {
			newRate = rule.MaxRate
		}

		newPrice := rule.BasePrice * newRate

		// 确定趋势
		trend := "stable"
		if newPrice > status.CurrentPrice*1.01 {
			trend = "up"
		} else if newPrice < status.CurrentPrice*0.99 {
			trend = "down"
		}

		// 更新状态
		status.CurrentPrice = newPrice
		status.CurrentRate = newRate
		status.Trend = trend
		db.Save(&status)

		// 记录价格历史
		history := &models.PriceHistory{
			ItemType:   status.ItemType,
			ItemID:     status.ItemID,
			Price:      newPrice,
			Rate:       newRate,
			RecordedAt: time.Now(),
		}
		db.Create(history)

		// 推送价格更新
		if ws.Notify != nil {
			ws.Notify.NotifyMarketUpdate(status.ItemType, status.ItemID, "", newPrice, trend)
		}
	}

	// 重置24小时交易量
	db.Model(&models.MarketStatus{}).Updates(map[string]interface{}{
		"buy_volume_24h":  0,
		"sell_volume_24h": 0,
	})

	log.Println("市场价格更新完成")
	return nil
}

// UpdateStockPrices 更新股票价格
func UpdateStockPrices() error {
	db := config.GetDB()

	var stocks []models.Stock
	if err := db.Where("is_active = ?", true).Find(&stocks).Error; err != nil {
		return err
	}

	for _, stock := range stocks {
		// 随机波动
		volatility := stock.Volatility
		change := (rand.Float64() - 0.5) * 2 * volatility
		
		// 趋势延续
		if stock.Trend == "up" {
			change += 0.01
		} else if stock.Trend == "down" {
			change -= 0.01
		}

		newPrice := stock.CurrentPrice * (1 + change)

		// 限制价格范围
		if newPrice < stock.PriceMin {
			newPrice = stock.PriceMin
		}
		if newPrice > stock.PriceMax {
			newPrice = stock.PriceMax
		}

		// 更新OHLC
		if stock.OpenPrice == nil {
			stock.OpenPrice = &stock.CurrentPrice
		}
		if stock.HighPrice == nil || newPrice > *stock.HighPrice {
			stock.HighPrice = &newPrice
		}
		if stock.LowPrice == nil || newPrice < *stock.LowPrice {
			stock.LowPrice = &newPrice
		}

		// 计算涨跌幅
		changePercent := (newPrice - stock.CurrentPrice) / stock.CurrentPrice * 100

		// 确定趋势
		trend := "stable"
		if changePercent > 0.5 {
			trend = "up"
		} else if changePercent < -0.5 {
			trend = "down"
		}

		stock.CurrentPrice = newPrice
		stock.ChangePercent = changePercent
		stock.Trend = trend
		db.Save(&stock)

		// 记录K线数据
		kline := &models.StockPrice{
			StockID:    stock.ID,
			Price:      newPrice,
			OpenPrice:  stock.OpenPrice,
			HighPrice:  stock.HighPrice,
			LowPrice:   stock.LowPrice,
			Volume:     stock.TodayVolume,
			Amount:     stock.TodayAmount,
			PeriodType: "1m",
			RecordedAt: time.Now(),
		}
		db.Create(kline)

		// 推送价格更新
		if ws.Notify != nil {
			ws.Notify.NotifyStockPriceUpdate(stock.ID, stock.Code, newPrice, changePercent)
		}
	}

	log.Println("股票价格更新完成")
	return nil
}

// RefreshBlackmarket 刷新黑市
func RefreshBlackmarket() error {
	db := config.GetDB()

	// 停用旧批次
	db.Model(&models.BlackmarketBatch{}).Where("end_at < ?", time.Now()).Update("is_active", false)

	// 检查是否有活跃批次
	var activeBatch models.BlackmarketBatch
	err := db.Where("is_active = ? AND end_at > ?", true, time.Now()).First(&activeBatch).Error
	if err == nil {
		return nil // 还有活跃批次，不刷新
	}

	// 创建新批次
	now := time.Now()
	batch := &models.BlackmarketBatch{
		StartAt:  now,
		EndAt:    now.Add(4 * time.Hour),
		IsActive: true,
	}
	if err := db.Create(batch).Error; err != nil {
		return err
	}

	// 获取所有种子
	var seeds []models.Seed
	db.Where("is_active = ?", true).Find(&seeds)

	// 随机选择商品
	itemCount := 0
	numItems := 3 + rand.Intn(4)
	selectedMap := make(map[int]bool)

	for len(selectedMap) < numItems && len(selectedMap) < len(seeds) {
		idx := rand.Intn(len(seeds))
		if selectedMap[idx] {
			continue
		}
		selectedMap[idx] = true

		seed := seeds[idx]
		discount := 0.6 + rand.Float64()*0.2
		price := seed.BasePrice * discount

		item := &models.BlackmarketItem{
			BatchID:     batch.ID,
			Name:        seed.Name + "(黑市)",
			Description: "黑市特供 " + seed.Name,
			Icon:        seed.Icon,
			ItemType:    "seed",
			ItemID:      &seed.ID,
			Price:       price,
			TotalStock:  50 + rand.Intn(150),
			UnlockLevel: seed.UnlockLevel,
		}
		db.Create(item)
		itemCount++
	}

	// 添加特殊商品
	specialItems := []models.BlackmarketItem{
		{
			BatchID:     batch.ID,
			Name:        "神秘种子袋",
			Description: "随机获得一种高级种子",
			ItemType:    "special",
			Price:       500,
			TotalStock:  20,
			UnlockLevel: 5,
		},
	}
	for _, item := range specialItems {
		db.Create(&item)
		itemCount++
	}

	// 推送通知
	if ws.Notify != nil {
		ws.Notify.NotifyBlackmarketRefresh(batch.ID, itemCount)
	}

	log.Printf("黑市刷新完成，批次ID: %d, 商品数: %d", batch.ID, itemCount)
	return nil
}

// SettleAuctions 结算过期拍卖
func SettleAuctions() error {
	db := config.GetDB()

	var auctions []models.Auction
	if err := db.Where("status = 'active' AND end_at <= ?", time.Now()).Find(&auctions).Error; err != nil {
		return err
	}

	for _, auction := range auctions {
		if auction.HighestBidder != nil {
			// 有人出价，成交
			// 给卖家金币
			db.Model(&models.User{}).Where("id = ?", auction.SellerID).
				Update("gold", config.DB.Raw("gold + ?", auction.CurrentPrice))

			// 给买家物品
			var inventory models.UserInventory
			err := db.Where("user_id = ? AND item_type = ? AND item_id = ?",
				*auction.HighestBidder, auction.ItemType, auction.ItemID).First(&inventory).Error
			if err != nil {
				inventory = models.UserInventory{
					UserID:   *auction.HighestBidder,
					ItemType: auction.ItemType,
					ItemID:   auction.ItemID,
					Quantity: auction.Quantity,
				}
				db.Create(&inventory)
			} else {
				db.Model(&inventory).Update("quantity", config.DB.Raw("quantity + ?", auction.Quantity))
			}

			auction.Status = "sold"

			// 通知买卖双方
			if ws.Notify != nil {
				ws.Notify.NotifyAuctionEnd(auction.SellerID, auction.ID, "", true, auction.CurrentPrice)
				ws.Notify.NotifyAuctionEnd(*auction.HighestBidder, auction.ID, "", true, auction.CurrentPrice)
			}
		} else {
			// 无人出价，流拍，退还物品
			var inventory models.UserInventory
			err := db.Where("user_id = ? AND item_type = ? AND item_id = ?",
				auction.SellerID, auction.ItemType, auction.ItemID).First(&inventory).Error
			if err != nil {
				inventory = models.UserInventory{
					UserID:   auction.SellerID,
					ItemType: auction.ItemType,
					ItemID:   auction.ItemID,
					Quantity: auction.Quantity,
				}
				db.Create(&inventory)
			} else {
				db.Model(&inventory).Update("quantity", config.DB.Raw("quantity + ?", auction.Quantity))
			}

			auction.Status = "expired"

			// 通知卖家
			if ws.Notify != nil {
				ws.Notify.NotifyAuctionEnd(auction.SellerID, auction.ID, "", false, 0)
			}
		}

		db.Save(&auction)
	}

	if len(auctions) > 0 {
		log.Printf("拍卖结算完成，处理 %d 个拍卖", len(auctions))
	}
	return nil
}

// UpdateRankings 更新排行榜
func UpdateRankings() error {
	db := config.GetDB()

	// 金币排行
	updateRanking(db, "gold", "SELECT id as user_id, gold as score FROM users ORDER BY gold DESC LIMIT 100")

	// 等级排行
	updateRanking(db, "level", "SELECT id as user_id, level as score FROM users ORDER BY level DESC, contribution DESC LIMIT 100")

	// 贡献值排行
	updateRanking(db, "contribution", "SELECT id as user_id, contribution as score FROM users ORDER BY contribution DESC LIMIT 100")

	// 成就点数排行
	updateRanking(db, "achievement", "SELECT id as user_id, achievement_points as score FROM users ORDER BY achievement_points DESC LIMIT 100")

	// 收获排行
	updateRanking(db, "harvest", "SELECT user_id, total_harvested as score FROM user_stats ORDER BY total_harvested DESC LIMIT 100")

	// 交易排行
	updateRanking(db, "trade", "SELECT user_id, total_sold as score FROM user_stats ORDER BY total_sold DESC LIMIT 100")

	log.Println("排行榜更新完成")
	return nil
}

func updateRanking(db *gorm.DB, rankType string, query string) {
	type RankData struct {
		UserID uint
		Score  int64
	}

	var results []RankData
	db.Raw(query).Scan(&results)

	// 删除旧排行
	db.Where("rank_type = ?", rankType).Delete(&models.Ranking{})

	// 插入新排行
	for i, r := range results {
		ranking := &models.Ranking{
			RankType:     rankType,
			UserID:       r.UserID,
			RankPosition: i + 1,
			Score:        r.Score,
			UpdatedAt:    time.Now(),
		}
		db.Create(ranking)
	}
}

// CheckLiquidations 检查强平
func CheckLiquidations() error {
	db := config.GetDB()

	// 获取所有活跃股票
	var stocks []models.Stock
	if err := db.Where("is_active = ?", true).Find(&stocks).Error; err != nil {
		return err
	}

	for _, stock := range stocks {
		// 获取该股票的所有开放仓位
		var positions []models.UserLeveragePosition
		db.Where("stock_id = ? AND status = 'open'", stock.ID).Find(&positions)

		for _, position := range positions {
			shouldLiquidate := false

			if position.PositionType == "long" && stock.CurrentPrice <= position.LiquidationPrice {
				shouldLiquidate = true
			} else if position.PositionType == "short" && stock.CurrentPrice >= position.LiquidationPrice {
				shouldLiquidate = true
			}

			if shouldLiquidate {
				now := time.Now()
				position.Status = "liquidated"
				position.ClosedAt = &now
				position.UnrealizedProfit = -position.Margin
				db.Save(&position)

				// 更新用户统计
				var stats models.UserStockStats
				if err := db.Where("user_id = ?", position.UserID).First(&stats).Error; err == nil {
					stats.TotalProfit -= position.Margin
					stats.LoseCount++
					if position.Margin > math.Abs(stats.MaxLoss) {
						stats.MaxLoss = -position.Margin
					}
					db.Save(&stats)
				}

				// 推送强平通知
				if ws.Notify != nil {
					ws.Notify.NotifyLiquidation(position.UserID, position.ID, stock.Name, position.Margin)
				}

				log.Printf("强平仓位: UserID=%d, PositionID=%d, Stock=%s, Loss=%.2f",
					position.UserID, position.ID, stock.Name, position.Margin)
			}
		}
	}

	return nil
}

// CheckCropMature 检查作物成熟
func CheckCropMature() error {
	db := config.GetDB()

	// 获取所有正在生长的作物
	var farms []models.UserFarm
	if err := db.Where("status = 'growing'").Preload("Seed").Find(&farms).Error; err != nil {
		return err
	}

	now := time.Now()
	for _, farm := range farms {
		if farm.SeedID == nil || farm.PlantedAt == nil || farm.Seed == nil {
			continue
		}

		// 计算是否成熟
		elapsed := now.Sub(*farm.PlantedAt).Seconds()
		if int(elapsed) >= farm.Seed.GrowthTime {
			farm.Status = "mature"
			farm.Stage = farm.Seed.Stages
			db.Save(&farm)

			// 推送成熟通知
			if ws.Notify != nil {
				// 获取作物名称
				var crop models.Crop
				if err := db.Where("seed_id = ?", farm.SeedID).First(&crop).Error; err == nil {
					ws.Notify.NotifyCropMature(farm.UserID, farm.SlotIndex, crop.Name)
				}
			}
		}
	}

	return nil
}

// CleanupExpiredData 清理过期数据
func CleanupExpiredData() error {
	db := config.GetDB()

	// 清理30天前的价格历史
	thirtyDaysAgo := time.Now().AddDate(0, 0, -30)
	db.Where("recorded_at < ?", thirtyDaysAgo).Delete(&models.PriceHistory{})

	// 清理30天前的股票K线(保留日线)
	db.Where("recorded_at < ? AND period_type != '1d'", thirtyDaysAgo).Delete(&models.StockPrice{})

	// 清理过期邮件
	db.Where("expire_at < ?", time.Now()).Delete(&models.Mail{})

	// 清理7天前的聊天记录
	sevenDaysAgo := time.Now().AddDate(0, 0, -7)
	db.Where("created_at < ?", sevenDaysAgo).Delete(&models.ChatMessage{})

	log.Println("过期数据清理完成")
	return nil
}
