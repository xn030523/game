package repository

import (
	"farm-game/config"
	"farm-game/models"
	"time"

	"gorm.io/gorm"
)

type AchievementRepository struct {
	db *gorm.DB
}

func NewAchievementRepository() *AchievementRepository {
	return &AchievementRepository{db: config.GetDB()}
}

// === 成就定义 ===

// GetAllAchievements 获取所有成就
func (r *AchievementRepository) GetAllAchievements() ([]models.Achievement, error) {
	var achievements []models.Achievement
	err := r.db.Order("category, sort_order").Find(&achievements).Error
	return achievements, err
}

// GetAchievementByID 根据ID获取成就
func (r *AchievementRepository) GetAchievementByID(id uint) (*models.Achievement, error) {
	var achievement models.Achievement
	err := r.db.First(&achievement, id).Error
	if err != nil {
		return nil, err
	}
	return &achievement, nil
}

// GetAchievementsByCategory 根据分类获取成就
func (r *AchievementRepository) GetAchievementsByCategory(category string) ([]models.Achievement, error) {
	var achievements []models.Achievement
	err := r.db.Where("category = ?", category).Order("sort_order").Find(&achievements).Error
	return achievements, err
}

// === 用户成就 ===

// GetUserAchievements 获取用户成就列表
func (r *AchievementRepository) GetUserAchievements(userID uint) ([]models.UserAchievement, error) {
	var userAchievements []models.UserAchievement
	err := r.db.Where("user_id = ?", userID).Preload("Achievement").Find(&userAchievements).Error
	return userAchievements, err
}

// GetUserAchievement 获取用户指定成就
func (r *AchievementRepository) GetUserAchievement(userID, achievementID uint) (*models.UserAchievement, error) {
	var ua models.UserAchievement
	err := r.db.Where("user_id = ? AND achievement_id = ?", userID, achievementID).
		Preload("Achievement").First(&ua).Error
	if err != nil {
		return nil, err
	}
	return &ua, nil
}

// CreateUserAchievement 创建用户成就
func (r *AchievementRepository) CreateUserAchievement(ua *models.UserAchievement) error {
	return r.db.Create(ua).Error
}

// UpdateUserAchievement 更新用户成就
func (r *AchievementRepository) UpdateUserAchievement(ua *models.UserAchievement) error {
	return r.db.Save(ua).Error
}

// InitUserAchievements 初始化用户成就
func (r *AchievementRepository) InitUserAchievements(userID uint) error {
	achievements, err := r.GetAllAchievements()
	if err != nil {
		return err
	}

	for _, a := range achievements {
		ua := &models.UserAchievement{
			UserID:        userID,
			AchievementID: a.ID,
			Progress:      0,
		}
		if err := r.db.Create(ua).Error; err != nil {
			return err
		}
	}
	return nil
}

// === 邮件 ===

// GetUserMails 获取用户邮件
func (r *AchievementRepository) GetUserMails(userID uint, limit int) ([]models.Mail, error) {
	var mails []models.Mail
	err := r.db.Where("user_id = ? AND (expire_at IS NULL OR expire_at > ?)", userID, time.Now()).
		Order("created_at DESC").Limit(limit).Find(&mails).Error
	return mails, err
}

// GetMailByID 根据ID获取邮件
func (r *AchievementRepository) GetMailByID(id uint) (*models.Mail, error) {
	var mail models.Mail
	err := r.db.First(&mail, id).Error
	if err != nil {
		return nil, err
	}
	return &mail, nil
}

// CreateMail 创建邮件
func (r *AchievementRepository) CreateMail(mail *models.Mail) error {
	return r.db.Create(mail).Error
}

// UpdateMail 更新邮件
func (r *AchievementRepository) UpdateMail(mail *models.Mail) error {
	return r.db.Save(mail).Error
}

// DeleteMail 删除邮件
func (r *AchievementRepository) DeleteMail(id uint) error {
	return r.db.Delete(&models.Mail{}, id).Error
}

// GetUnreadMailCount 获取未读邮件数
func (r *AchievementRepository) GetUnreadMailCount(userID uint) (int64, error) {
	var count int64
	err := r.db.Model(&models.Mail{}).
		Where("user_id = ? AND is_read = false AND (expire_at IS NULL OR expire_at > ?)", userID, time.Now()).
		Count(&count).Error
	return count, err
}

// === 签到 ===

// GetTodayCheckin 获取今日签到
func (r *AchievementRepository) GetTodayCheckin(userID uint) (*models.DailyCheckin, error) {
	var checkin models.DailyCheckin
	today := time.Now().Format("2006-01-02")
	err := r.db.Where("user_id = ? AND checkin_date = ?", userID, today).First(&checkin).Error
	if err != nil {
		return nil, err
	}
	return &checkin, nil
}

// GetMonthCheckins 获取本月签到记录
func (r *AchievementRepository) GetMonthCheckins(userID uint, year, month int) ([]models.DailyCheckin, error) {
	var checkins []models.DailyCheckin
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, 0)

	err := r.db.Where("user_id = ? AND checkin_date >= ? AND checkin_date < ?",
		userID, startDate.Format("2006-01-02"), endDate.Format("2006-01-02")).
		Order("checkin_date").Find(&checkins).Error
	return checkins, err
}

// CreateCheckin 创建签到记录
func (r *AchievementRepository) CreateCheckin(checkin *models.DailyCheckin) error {
	return r.db.Create(checkin).Error
}

// === 排行榜 ===

// GetRankings 获取排行榜
func (r *AchievementRepository) GetRankings(rankType string, limit int) ([]models.Ranking, error) {
	var rankings []models.Ranking
	err := r.db.Where("rank_type = ?", rankType).
		Preload("User").Order("rank_position ASC").Limit(limit).Find(&rankings).Error
	return rankings, err
}

// UpdateRankings 更新排行榜
func (r *AchievementRepository) UpdateRankings(rankType string, rankings []models.Ranking) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Where("rank_type = ?", rankType).Delete(&models.Ranking{}).Error; err != nil {
			return err
		}
		for i := range rankings {
			rankings[i].RankType = rankType
			rankings[i].RankPosition = i + 1
			rankings[i].UpdatedAt = time.Now()
			if err := tx.Create(&rankings[i]).Error; err != nil {
				return err
			}
		}
		return nil
	})
}
