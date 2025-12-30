package main

import (
	"farm-game/ws"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化 WebSocket Hub
	ws.Init()

	r := gin.Default()

	// CORS
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Authorization, Content-Type")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// WebSocket 路由
	r.GET("/ws", func(c *gin.Context) {
		// 从查询参数获取用户ID（生产环境应该从 JWT 验证）
		userID := c.Query("user_id")
		if userID == "" {
			userID = "anonymous"
		}
		ws.ServeWs(ws.GameHub, c.Writer, c.Request, userID)
	})

	// API 路由
	api := r.Group("/api")
	{
		// 获取在线人数
		api.GET("/online", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"count": ws.GameHub.GetOnlineCount(),
				"users": ws.GameHub.GetOnlineUsers(),
			})
		})
	}

	log.Println("服务器启动在 :8080")
	r.Run(":8080")
}
