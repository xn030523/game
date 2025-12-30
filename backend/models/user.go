package models

import "time"

// User 用户表
type User struct {
	ID                uint      `json:"id" gorm:"primaryKey"`
	LinuxdoID         string    `json:"linuxdo_id" gorm:"uniqueIndex;not null"`
	CharityID         string    `json:"charity_id" gorm:"index"`
	Nickname          string    `json:"nickname"`
	Avatar            string    `json:"avatar"`
	Level             int       `json:"level" gorm:"default:1"`
	Gold              float64   `json:"gold" gorm:"type:decimal(20,2);default:1000"`
	FarmSlots         int       `json:"farm_slots" gorm:"default:4"`
	Contribution      int       `json:"contribution" gorm:"default:0"`
	AchievementPoints int       `json:"achievement_points" gorm:"default:0"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

func (User) TableName() string {
	return "users"
}

// LevelConfig 等级配置表
type LevelConfig struct {
	Level                     int `json:"level" gorm:"primaryKey"`
	ContributionRequired      int `json:"contribution_required"`
	AchievementPointsRequired int `json:"achievement_points_required"`
	RewardGold                int `json:"reward_gold"`
}

func (LevelConfig) TableName() string {
	return "level_configs"
}

// UserStats 用户统计表
type UserStats struct {
	ID              uint      `json:"id" gorm:"primaryKey"`
	UserID          uint      `json:"user_id" gorm:"uniqueIndex"`
	TotalPlanted    int       `json:"total_planted" gorm:"default:0"`
	TotalHarvested  int       `json:"total_harvested" gorm:"default:0"`
	TotalSold       int       `json:"total_sold" gorm:"default:0"`
	TotalBought     int       `json:"total_bought" gorm:"default:0"`
	TotalGoldEarned float64   `json:"total_gold_earned" gorm:"type:decimal(20,2);default:0"`
	TotalGoldSpent  float64   `json:"total_gold_spent" gorm:"type:decimal(20,2);default:0"`
	TotalFriends    int       `json:"total_friends" gorm:"default:0"`
	TotalStolen     int       `json:"total_stolen" gorm:"default:0"`
	LoginDays       int       `json:"login_days" gorm:"default:0"`
	ConsecutiveDays int       `json:"consecutive_days" gorm:"default:0"`
	LastLoginDate   *string   `json:"last_login_date"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

func (UserStats) TableName() string {
	return "user_stats"
}
