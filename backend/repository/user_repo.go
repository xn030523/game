package repository

import (
	"farm-game/config"
	"farm-game/models"

	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository() *UserRepository {
	return &UserRepository{db: config.GetDB()}
}

// FindByID 根据ID查找用户
func (r *UserRepository) FindByID(id uint) (*models.User, error) {
	var user models.User
	err := r.db.First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// FindByLinuxdoID 根据LinuxdoID查找用户
func (r *UserRepository) FindByLinuxdoID(linuxdoID string) (*models.User, error) {
	var user models.User
	err := r.db.Where("linuxdo_id = ?", linuxdoID).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// Create 创建用户
func (r *UserRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

// Update 更新用户
func (r *UserRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

// UpdateGold 更新用户金币
func (r *UserRepository) UpdateGold(userID uint, amount float64) error {
	return r.db.Model(&models.User{}).Where("id = ?", userID).
		Update("gold", gorm.Expr("gold + ?", amount)).Error
}

// GetUserStats 获取用户统计（不存在则自动创建）
func (r *UserRepository) GetUserStats(userID uint) (*models.UserStats, error) {
	var stats models.UserStats
	err := r.db.Where("user_id = ?", userID).First(&stats).Error
	if err != nil {
		// 不存在则创建
		stats = models.UserStats{UserID: userID}
		if err := r.db.Create(&stats).Error; err != nil {
			return nil, err
		}
	}
	return &stats, nil
}

// CreateUserStats 创建用户统计
func (r *UserRepository) CreateUserStats(stats *models.UserStats) error {
	return r.db.Create(stats).Error
}

// UpdateUserStats 更新用户统计
func (r *UserRepository) UpdateUserStats(stats *models.UserStats) error {
	return r.db.Model(stats).Updates(map[string]interface{}{
		"total_planted":       stats.TotalPlanted,
		"total_harvested":     stats.TotalHarvested,
		"total_sold":          stats.TotalSold,
		"total_bought":        stats.TotalBought,
		"total_gold_earned":   stats.TotalGoldEarned,
		"total_gold_spent":    stats.TotalGoldSpent,
		"login_days":          stats.LoginDays,
		"consecutive_days":    stats.ConsecutiveDays,
		"contribution_points": stats.ContributionPoints,
		"achievement_points":  stats.AchievementPoints,
	}).Error
}

// UpdateUserStatsLoginDate 单独更新登录日期
func (r *UserRepository) UpdateUserStatsLoginDate(statsID uint, date string) error {
	return r.db.Model(&models.UserStats{}).Where("id = ?", statsID).Update("last_login_date", date).Error
}

// GetLevelConfig 获取等级配置
func (r *UserRepository) GetLevelConfig(level int) (*models.LevelConfig, error) {
	var config models.LevelConfig
	err := r.db.Where("level = ?", level).First(&config).Error
	if err != nil {
		return nil, err
	}
	return &config, nil
}

// GetAllLevelConfigs 获取所有等级配置
func (r *UserRepository) GetAllLevelConfigs() ([]models.LevelConfig, error) {
	var configs []models.LevelConfig
	err := r.db.Order("level ASC").Find(&configs).Error
	return configs, err
}
