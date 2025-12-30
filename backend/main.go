package main

import (
	"farm-game/controllers"
	"farm-game/database"
	"farm-game/middleware"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化数据库
	database.Init()

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

	// 公开路由
	auth := r.Group("/api/auth")
	{
		auth.GET("/linuxdo", controllers.GetLinuxDoAuthURL)
		auth.GET("/linuxdo/callback", controllers.LinuxDoCallback)
	}

	// 需要登录的路由
	api := r.Group("/api")
	api.Use(middleware.AuthRequired())
	{
		api.GET("/user", controllers.GetCurrentUser)
		api.POST("/user/bind-new", controllers.BindNewPlatform)
	}

	log.Println("服务器启动在 :8080")
	r.Run(":8080")
}
