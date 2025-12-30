package cron

import (
	"log"
	"time"
)

// Scheduler 定时任务调度器
type Scheduler struct {
	tasks    map[string]*Task
	stopChan chan struct{}
	running  bool
}

// Task 定时任务
type Task struct {
	Name     string
	Interval time.Duration
	Handler  func() error
	LastRun  time.Time
	Running  bool
}

var scheduler *Scheduler

// Init 初始化调度器
func Init() {
	scheduler = &Scheduler{
		tasks:    make(map[string]*Task),
		stopChan: make(chan struct{}),
	}

	// 注册所有定时任务
	registerTasks()

	// 启动调度器
	go scheduler.run()
	log.Println("定时任务调度器已启动")
}

// Stop 停止调度器
func Stop() {
	if scheduler != nil && scheduler.running {
		close(scheduler.stopChan)
		scheduler.running = false
		log.Println("定时任务调度器已停止")
	}
}

// registerTasks 注册所有定时任务
func registerTasks() {
	// 黑市刷新 - 每4小时
	scheduler.Register("blackmarket_refresh", 4*time.Hour, RefreshBlackmarket)

	// 拍卖结算 - 每1分钟检查
	scheduler.Register("auction_settlement", 1*time.Minute, SettleAuctions)

	// 排行榜更新 - 每10分钟
	scheduler.Register("ranking_update", 10*time.Minute, UpdateRankings)

	// 股票强平检查 - 每30秒
	scheduler.Register("liquidation_check", 30*time.Second, CheckLiquidations)

	// 作物成熟检查 - 每1分钟
	scheduler.Register("crop_mature_check", 1*time.Minute, CheckCropMature)

	// 清理过期数据 - 每1小时
	scheduler.Register("cleanup_expired", 1*time.Hour, CleanupExpiredData)
}

// Register 注册任务
func (s *Scheduler) Register(name string, interval time.Duration, handler func() error) {
	s.tasks[name] = &Task{
		Name:     name,
		Interval: interval,
		Handler:  handler,
	}
	log.Printf("注册定时任务: %s, 间隔: %v", name, interval)
}

// run 运行调度器
func (s *Scheduler) run() {
	s.running = true
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-s.stopChan:
			return
		case now := <-ticker.C:
			for _, task := range s.tasks {
				if task.Running {
					continue
				}
				if now.Sub(task.LastRun) >= task.Interval {
					go s.executeTask(task)
				}
			}
		}
	}
}

// executeTask 执行任务
func (s *Scheduler) executeTask(task *Task) {
	task.Running = true
	task.LastRun = time.Now()

	defer func() {
		task.Running = false
		if r := recover(); r != nil {
			log.Printf("定时任务 %s 发生panic: %v", task.Name, r)
		}
	}()

	if err := task.Handler(); err != nil {
		log.Printf("定时任务 %s 执行失败: %v", task.Name, err)
	}
}

// RunTask 手动执行任务
func RunTask(name string) error {
	if scheduler == nil {
		return nil
	}
	task, ok := scheduler.tasks[name]
	if !ok {
		return nil
	}
	return task.Handler()
}
