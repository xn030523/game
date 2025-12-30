package main

import (
	"farm-game/config"
	"farm-game/cron"
	"farm-game/router"
	"farm-game/ws"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	// 加载配置
	config.Load()

	// 初始化数据库
	config.InitDB()

	// 初始化 WebSocket Hub
	ws.Init()
	ws.InitNotify()

	// 初始化定时任务
	cron.Init()

	// 设置路由
	r := router.SetupRouter()

	// 优雅关闭
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
		<-sigChan
		log.Println("收到关闭信号，正在关闭...")
		cron.Stop()
		os.Exit(0)
	}()

	// 启动服务
	log.Printf("服务启动在 :%s", config.AppConfig.ServerPort)
	if err := r.Run(":" + config.AppConfig.ServerPort); err != nil {
		log.Fatal("服务启动失败:", err)
	}
}
