package cron

import (
	"farm-game/config"
	"farm-game/models"
	"farm-game/ws"
	"fmt"
	"log"
	"math"
	"math/rand"
	"time"

	"gorm.io/gorm"
)

// ResetMarketVolume 重置24小时交易量（每日零点）
func ResetMarketVolume() error {
	db := config.GetDB()
	db.Model(&models.MarketStatus{}).Where("1=1").Updates(map[string]interface{}{
		"buy_volume24h":  0,
		"sell_volume24h": 0,
	})
	log.Println("市场24h交易量已重置")
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
	var count int64
	db.Model(&models.BlackmarketBatch{}).Where("is_active = ? AND end_at > ?", true, time.Now()).Count(&count)
	if count > 0 {
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
		Score  float64
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
	maturedUsers := make(map[uint]bool)
	for _, farm := range farms {
		if farm.SeedID == nil || farm.PlantedAt == nil || farm.Seed == nil {
			continue
		}

		// 计算是否成熟
		elapsed := now.Sub(*farm.PlantedAt).Seconds()
		if int(elapsed) >= farm.Seed.GrowthTime {
			farm.Status = "mature"
			farm.Stage = farm.Seed.Stages - 1
			db.Save(&farm)
			maturedUsers[farm.UserID] = true

			// 推送成熟通知
			if ws.Notify != nil {
				var crop models.Crop
				if err := db.Where("seed_id = ?", farm.SeedID).First(&crop).Error; err == nil {
					ws.Notify.NotifyCropMature(farm.UserID, farm.SlotIndex, crop.Name)
				}
			}
		}
	}

	// 给有作物成熟的用户发送farm_update通知
	for userID := range maturedUsers {
		if ws.GameHub != nil {
			ws.GameHub.SendToUser(fmt.Sprintf("%d", userID), ws.NewMessage("farm_update", map[string]interface{}{
				"user_id": userID,
			}))
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

// StockTick 股票实时波动（每3秒）
func StockTick() error {
	db := config.GetDB()

	var stocks []models.Stock
	if err := db.Where("is_active = ?", true).Find(&stocks).Error; err != nil {
		return err
	}

	for _, stock := range stocks {
		// 基于波动率的随机波动（-0.3% ~ +0.3%）
		volatility := stock.Volatility
		if volatility == 0 {
			volatility = 0.05
		}
		change := (rand.Float64() - 0.5) * volatility * 0.1
		newPrice := stock.CurrentPrice * (1 + change)

		// 做市商机制：价格偏离基准价超过80%时强制回调
		deviation := (newPrice - stock.BasePrice) / stock.BasePrice
		if deviation > 0.8 {
			// 价格过高，强制回调
			newPrice = newPrice * 0.95
		} else if deviation < -0.8 {
			// 价格过低，强制拉升
			newPrice = newPrice * 1.05
		}

		// 限制在价格区间内
		if newPrice < stock.PriceMin {
			newPrice = stock.PriceMin
		}
		if newPrice > stock.PriceMax {
			newPrice = stock.PriceMax
		}

		// 计算涨跌幅
		var changePercent float64
		if stock.OpenPrice != nil && *stock.OpenPrice > 0 {
			changePercent = (newPrice - *stock.OpenPrice) / *stock.OpenPrice * 100
		}

		// 更新最高最低价
		if stock.HighPrice == nil || newPrice > *stock.HighPrice {
			stock.HighPrice = &newPrice
		}
		if stock.LowPrice == nil || newPrice < *stock.LowPrice {
			stock.LowPrice = &newPrice
		}

		stock.CurrentPrice = newPrice
		stock.ChangePercent = changePercent
		db.Save(&stock)

		// 更新今日K线
		today := time.Now().Format("2006-01-02")
		var kline models.StockPrice
		err := db.Where("stock_id = ? AND period_type = '1d' AND DATE(recorded_at) = ?", stock.ID, today).First(&kline).Error
		if err == nil {
			// 更新现有K线
			kline.Price = newPrice
			if kline.HighPrice == nil || newPrice > *kline.HighPrice {
				kline.HighPrice = &newPrice
			}
			if kline.LowPrice == nil || newPrice < *kline.LowPrice {
				kline.LowPrice = &newPrice
			}
			db.Save(&kline)
		}

		// WebSocket 推送（带完整 OHLC 数据）
		if ws.GameHub != nil {
			data := map[string]interface{}{
				"stock_id":       stock.ID,
				"code":           stock.Code,
				"current_price":  newPrice,
				"change_percent": changePercent,
			}
			if stock.OpenPrice != nil {
				data["open_price"] = *stock.OpenPrice
			}
			if stock.HighPrice != nil {
				data["high_price"] = *stock.HighPrice
			}
			if stock.LowPrice != nil {
				data["low_price"] = *stock.LowPrice
			}
			ws.GameHub.Broadcast(ws.NewMessage(ws.MsgTypeStockPrice, data))
		}
	}
	return nil
}

// 按股票代码分类的新闻
var stockNewsByCode = map[string][]struct {
	Title  string
	Effect float64
}{
	"FARM": {
		{"农业部发布扶持政策，农场科技受益！", 0.06},
		{"智慧农业项目获政府补贴", 0.05},
		{"农场科技与大型超市签订供货协议", 0.07},
		{"农场设备老化，维护成本上升", -0.04},
		{"农业用地政策收紧，扩张受阻", -0.05},
		{"机构看好农场科技，大举买入", 0.04},
	},
	"SEED": {
		{"种子集团获得重大专利，股价飙升！", 0.08},
		{"新品种种子通过国家认证", 0.06},
		{"种子出口订单大增", 0.05},
		{"种子质量问题遭投诉", -0.06},
		{"竞争对手推出低价种子", -0.04},
		{"种子集团研发投入加大", 0.03},
	},
	"CROP": {
		{"国际粮价上涨，作物期货走强", 0.07},
		{"丰收季来临，作物供应充足", -0.03},
		{"干旱预警：作物产量或受影响", 0.06},
		{"暴雨灾害影响收成", -0.05},
		{"作物出口关税下调", 0.04},
		{"国际市场需求疲软", -0.04},
	},
	"GOLD": {
		{"黄金价格创新高，矿业股受益", 0.08},
		{"央行增持黄金储备", 0.06},
		{"金矿发现新矿脉，产能提升", 0.07},
		{"开采成本上升，利润承压", -0.05},
		{"黄金需求季节性下降", -0.04},
		{"国际金价震荡下行", -0.06},
	},
	"TECH": {
		{"科技创新获国家奖励，股价上扬", 0.07},
		{"新技术专利获批，市场看好", 0.06},
		{"与知名企业达成战略合作", 0.08},
		{"核心技术人员离职", -0.05},
		{"研发项目延期，进度落后", -0.04},
		{"科技产品销量不及预期", -0.06},
	},
}

// StockNewsEvent 随机新闻事件（每2分钟）
func StockNewsEvent() error {
	// 50%概率触发新闻
	if rand.Float64() > 0.5 {
		return nil
	}

	db := config.GetDB()

	var stocks []models.Stock
	if err := db.Where("is_active = ?", true).Find(&stocks).Error; err != nil {
		return err
	}
	if len(stocks) == 0 {
		return nil
	}

	// 随机选择一个股票
	stock := stocks[rand.Intn(len(stocks))]
	
	// 获取该股票对应的新闻列表
	newsList, ok := stockNewsByCode[stock.Code]
	if !ok || len(newsList) == 0 {
		return nil
	}
	
	// 6亏4赚：60%概率选利空新闻
	var badNews, goodNews []struct{ Title string; Effect float64 }
	for _, n := range newsList {
		if n.Effect < 0 {
			badNews = append(badNews, n)
		} else {
			goodNews = append(goodNews, n)
		}
	}
	
	var news struct{ Title string; Effect float64 }
	if rand.Float64() < 0.6 && len(badNews) > 0 {
		news = badNews[rand.Intn(len(badNews))]
	} else if len(goodNews) > 0 {
		news = goodNews[rand.Intn(len(goodNews))]
	} else {
		news = newsList[rand.Intn(len(newsList))]
	}

	// 应用新闻效果
	newPrice := stock.CurrentPrice * (1 + news.Effect)
	if newPrice < stock.PriceMin {
		newPrice = stock.PriceMin
	}
	if newPrice > stock.PriceMax {
		newPrice = stock.PriceMax
	}

	var changePercent float64
	if stock.OpenPrice != nil && *stock.OpenPrice > 0 {
		changePercent = (newPrice - *stock.OpenPrice) / *stock.OpenPrice * 100
	}

	stock.CurrentPrice = newPrice
	stock.ChangePercent = changePercent
	db.Save(&stock)

	// 保存新闻到数据库
	stockNews := &models.StockNews{
		StockID:   stock.ID,
		StockCode: stock.Code,
		StockName: stock.Name,
		Title:     news.Title,
		Effect:    news.Effect,
	}
	db.Create(stockNews)

	// 广播新闻和价格更新
	if ws.GameHub != nil {
		ws.GameHub.Broadcast(ws.NewMessage("stock_news", map[string]interface{}{
			"id":         stockNews.ID,
			"stock_id":   stock.ID,
			"stock_code": stock.Code,
			"stock_name": stock.Name,
			"title":      news.Title,
			"effect":     news.Effect,
			"new_price":  newPrice,
			"created_at": stockNews.CreatedAt,
		}))
		ws.GameHub.Broadcast(ws.NewMessage(ws.MsgTypeStockPrice, map[string]interface{}{
			"stock_id":       stock.ID,
			"code":           stock.Code,
			"current_price":  newPrice,
			"change_percent": changePercent,
		}))
	}

	log.Printf("股票新闻: [%s] %s, 价格变动 %.2f%%", stock.Code, news.Title, news.Effect*100)
	return nil
}

// StockDividend 股息分红（每10分钟）
func StockDividend() error {
	db := config.GetDB()

	// 获取所有持仓
	var holdings []models.UserStock
	if err := db.Where("shares > 0").Preload("Stock").Find(&holdings).Error; err != nil {
		return err
	}

	for _, h := range holdings {
		if h.Stock.ID == 0 {
			continue
		}
		
		// 根据股票涨跌决定盈亏：涨→分红，跌→扣钱
		changePercent := h.Stock.ChangePercent / 100 // 转为小数
		if changePercent == 0 {
			continue
		}
		
		// 盈亏 = 持仓数量 * 当前价格 * 涨跌幅 * 0.1
		amount := float64(h.Shares) * h.Stock.CurrentPrice * changePercent * 0.1
		if amount > -0.01 && amount < 0.01 {
			continue
		}

		// 更新金币
		db.Model(&models.User{}).Where("id = ?", h.UserID).Update("gold", gorm.Expr("gold + ?", amount))

		// 保存盈亏记录
		profit := &models.StockProfit{
			UserID:        h.UserID,
			StockID:       h.StockID,
			StockName:     h.Stock.Name,
			Amount:        amount,
			ChangePercent: h.Stock.ChangePercent,
			Shares:        h.Shares,
		}
		db.Create(profit)

		// 通知玩家
		var message string
		if amount > 0 {
			message = fmt.Sprintf("您持有的%s盈利分红 +%.2f 金币", h.Stock.Name, amount)
		} else {
			message = fmt.Sprintf("您持有的%s亏损扣除 %.2f 金币", h.Stock.Name, amount)
		}

		if ws.GameHub != nil {
			ws.GameHub.SendToUser(fmt.Sprintf("%d", h.UserID), ws.NewMessage("dividend", map[string]interface{}{
				"id":             profit.ID,
				"stock_name":     h.Stock.Name,
				"shares":         h.Shares,
				"amount":         amount,
				"change_percent": h.Stock.ChangePercent,
				"is_profit":      amount > 0,
				"message":        message,
				"created_at":     profit.CreatedAt,
			}))
		}
	}

	log.Println("股息分红已发放")
	return nil
}

// 内幕消息列表
var insiderTips = []struct {
	Template string
	Effect   float64
}{
	{"内幕消息：%s即将发布重大利好，建议买入！", 0.10},
	{"小道消息：%s可能有大单买入，价格看涨", 0.08},
	{"传闻：%s正在洽谈重大合作", 0.06},
	{"警告：%s可能面临监管调查，谨慎持有", -0.08},
	{"消息：%s大股东计划减持，注意风险", -0.06},
	{"内部消息：%s业绩可能不及预期", -0.05},
}

// InsiderTip 内幕消息（每3分钟）
func InsiderTip() error {
	// 30%概率触发
	if rand.Float64() > 0.3 {
		return nil
	}

	db := config.GetDB()

	// 获取所有在线用户
	var users []models.User
	if err := db.Find(&users).Error; err != nil {
		return err
	}
	if len(users) == 0 {
		return nil
	}

	// 随机选择一个用户和一个股票
	user := users[rand.Intn(len(users))]

	var stocks []models.Stock
	if err := db.Where("is_active = ?", true).Find(&stocks).Error; err != nil {
		return err
	}
	if len(stocks) == 0 {
		return nil
	}

	stock := stocks[rand.Intn(len(stocks))]
	tip := insiderTips[rand.Intn(len(insiderTips))]

	message := fmt.Sprintf(tip.Template, stock.Name)

	// 发送内幕消息给随机用户
	if ws.GameHub != nil {
		ws.GameHub.SendToUser(fmt.Sprintf("%d", user.ID), ws.NewMessage("insider_tip", map[string]interface{}{
			"stock_id":   stock.ID,
			"stock_code": stock.Code,
			"stock_name": stock.Name,
			"message":    message,
			"effect":     tip.Effect,
		}))
	}

	// 延迟30-60秒后真的触发价格变动
	go func() {
		delay := time.Duration(30+rand.Intn(30)) * time.Second
		time.Sleep(delay)

		// 应用价格变动
		var s models.Stock
		if err := db.First(&s, stock.ID).Error; err != nil {
			return
		}

		newPrice := s.CurrentPrice * (1 + tip.Effect)
		if newPrice < s.PriceMin {
			newPrice = s.PriceMin
		}
		if newPrice > s.PriceMax {
			newPrice = s.PriceMax
		}

		var changePercent float64
		if s.OpenPrice != nil && *s.OpenPrice > 0 {
			changePercent = (newPrice - *s.OpenPrice) / *s.OpenPrice * 100
		}

		s.CurrentPrice = newPrice
		s.ChangePercent = changePercent
		db.Save(&s)

		// 广播价格更新
		if ws.GameHub != nil {
			ws.GameHub.Broadcast(ws.NewMessage(ws.MsgTypeStockPrice, map[string]interface{}{
				"stock_id":       s.ID,
				"code":           s.Code,
				"current_price":  newPrice,
				"change_percent": changePercent,
			}))
		}
	}()

	log.Printf("内幕消息发送给用户 %s: %s", user.Nickname, message)
	return nil
}
