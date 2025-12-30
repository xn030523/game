package router

import (
	"farm-game/config"
	"farm-game/handler"
	"farm-game/middleware"
	"farm-game/ws"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()

	// 全局中间件
	r.Use(middleware.CORSMiddleware())

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "online": ws.GameHub.GetOnlineCount()})
	})

	// WebSocket 连接
	r.GET("/ws", func(c *gin.Context) {
		// 从查询参数获取token，验证用户
		token := c.Query("token")
		if token == "" {
			c.JSON(401, gin.H{"error": "未提供token"})
			return
		}

		// 解析token获取用户ID
		claims := &middleware.Claims{}
		_, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
			return []byte(config.AppConfig.JWTSecret), nil
		})
		if err != nil {
			c.JSON(401, gin.H{"error": "无效的token"})
			return
		}

		userID := strconv.FormatUint(uint64(claims.UserID), 10)
		ws.ServeWs(ws.GameHub, c.Writer, c.Request, userID)
	})

	// API v1
	v1 := r.Group("/api/v1")
	{
		// 公开接口
		public := v1.Group("")
		{
			public.POST("/auth/linuxdo/callback", handler.NewAuthHandler().LinuxdoCallback)
		}

		// 需要认证的接口
		auth := v1.Group("")
		auth.Use(middleware.AuthMiddleware())
		{
			// 用户相关
			userHandler := handler.NewUserHandler()
			auth.GET("/user/profile", userHandler.GetProfile)
			auth.GET("/user/:id", userHandler.GetUserByID)
			auth.POST("/user/expand-farm", userHandler.ExpandFarm)
			auth.GET("/user/farm-slot-price", userHandler.GetFarmSlotPrice)
			auth.GET("/user/check-level-up", userHandler.CheckLevelUp)
			auth.POST("/user/level-up", userHandler.LevelUp)

			// 农场相关
			farmHandler := handler.NewFarmHandler()
			auth.GET("/farm/seeds", farmHandler.GetSeeds)
			auth.GET("/farm/farms", farmHandler.GetFarms)
			auth.POST("/farm/buy-seed", farmHandler.BuySeed)
			auth.POST("/farm/plant", farmHandler.Plant)
			auth.POST("/farm/harvest", farmHandler.Harvest)
			auth.POST("/farm/sell", farmHandler.SellCrop)
			auth.GET("/farm/inventory", farmHandler.GetInventory)

			// 股票交易所
			stockHandler := handler.NewStockHandler()
			auth.GET("/stock/list", stockHandler.GetStocks)
			auth.GET("/stock/:id", stockHandler.GetStock)
			auth.GET("/stock/:id/kline", stockHandler.GetKLine)
			auth.POST("/stock/buy", stockHandler.BuyStock)
			auth.POST("/stock/sell", stockHandler.SellStock)
			auth.POST("/stock/long", stockHandler.OpenLong)
			auth.POST("/stock/short", stockHandler.OpenShort)
			auth.POST("/stock/close-position", stockHandler.ClosePosition)
			auth.GET("/stock/my-stocks", stockHandler.GetMyStocks)
			auth.GET("/stock/my-positions", stockHandler.GetMyPositions)
			auth.GET("/stock/my-stats", stockHandler.GetMyStats)
			auth.GET("/stock/rankings", stockHandler.GetRankings)

			// 拍卖行
			auctionHandler := handler.NewAuctionHandler()
			auth.GET("/auction/list", auctionHandler.GetAuctions)
			auth.GET("/auction/:id", auctionHandler.GetAuction)
			auth.POST("/auction/create", auctionHandler.CreateAuction)
			auth.POST("/auction/:id/bid", auctionHandler.PlaceBid)
			auth.POST("/auction/:id/buyout", auctionHandler.Buyout)
			auth.POST("/auction/:id/cancel", auctionHandler.CancelAuction)
			auth.GET("/auction/my-auctions", auctionHandler.GetMyAuctions)
			auth.GET("/auction/my-bids", auctionHandler.GetMyBids)

			// 黑市
			blackmarketHandler := handler.NewBlackmarketHandler()
			auth.GET("/blackmarket", blackmarketHandler.GetCurrentBatch)
			auth.POST("/blackmarket/buy", blackmarketHandler.BuyItem)
			auth.GET("/blackmarket/history", blackmarketHandler.GetPurchaseHistory)

			// 好友系统
			socialHandler := handler.NewSocialHandler()
			auth.GET("/friend/list", socialHandler.GetFriends)
			auth.GET("/friend/requests", socialHandler.GetFriendRequests)
			auth.POST("/friend/request", socialHandler.SendFriendRequest)
			auth.POST("/friend/accept/:id", socialHandler.AcceptFriendRequest)
			auth.POST("/friend/reject/:id", socialHandler.RejectFriendRequest)
			auth.DELETE("/friend/:id", socialHandler.RemoveFriend)
			auth.GET("/friend/:id/messages", socialHandler.GetMessages)
			auth.POST("/friend/:id/message", socialHandler.SendMessage)
			auth.GET("/friend/unread-count", socialHandler.GetUnreadCount)
			auth.POST("/friend/steal", socialHandler.StealCrop)

			// 世界聊天
			auth.GET("/chat/messages", socialHandler.GetChatMessages)
			auth.POST("/chat/send", socialHandler.SendChatMessage)

			// 成就系统
			achievementHandler := handler.NewAchievementHandler()
			auth.GET("/achievement/list", achievementHandler.GetAchievements)
			auth.GET("/achievement/my", achievementHandler.GetMyAchievements)
			auth.POST("/achievement/:id/claim", achievementHandler.ClaimAchievementReward)

			// 邮件系统
			auth.GET("/mail/list", achievementHandler.GetMails)
			auth.GET("/mail/:id", achievementHandler.ReadMail)
			auth.POST("/mail/:id/claim", achievementHandler.ClaimMailAttachments)
			auth.DELETE("/mail/:id", achievementHandler.DeleteMail)

			// 签到系统
			auth.POST("/checkin", achievementHandler.Checkin)
			auth.GET("/checkin/month", achievementHandler.GetMonthCheckins)

			// 排行榜
			auth.GET("/ranking", achievementHandler.GetRankings)
		}
	}

	return r
}
