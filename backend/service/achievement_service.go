package service

import (
	"encoding/json"
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"time"
)

type AchievementService struct {
	achievementRepo *repository.AchievementRepository
	userRepo        *repository.UserRepository
	farmRepo        *repository.FarmRepository
}

func NewAchievementService() *AchievementService {
	return &AchievementService{
		achievementRepo: repository.NewAchievementRepository(),
		userRepo:        repository.NewUserRepository(),
		farmRepo:        repository.NewFarmRepository(),
	}
}

// === 成就系统 ===

// GetAllAchievements 获取所有成就定义
func (s *AchievementService) GetAllAchievements() ([]models.Achievement, error) {
	return s.achievementRepo.GetAllAchievements()
}

// GetUserAchievements 获取用户成就进度
func (s *AchievementService) GetUserAchievements(userID uint) ([]models.UserAchievement, error) {
	return s.achievementRepo.GetUserAchievements(userID)
}

// UpdateAchievementProgress 更新成就进度
func (s *AchievementService) UpdateAchievementProgress(userID uint, conditionType string, increment int) error {
	// 获取所有相关成就
	achievements, _ := s.achievementRepo.GetAllAchievements()

	for _, achievement := range achievements {
		if achievement.ConditionType != conditionType {
			continue
		}

		ua, err := s.achievementRepo.GetUserAchievementByID(userID, achievement.ID)
		if err != nil {
			// 创建用户成就记录
			ua = &models.UserAchievement{
				UserID:        userID,
				AchievementID: achievement.ID,
				Progress:      0,
			}
			s.achievementRepo.CreateUserAchievement(ua)
		}

		if ua.IsCompleted {
			continue
		}

		ua.Progress += increment
		if ua.Progress >= achievement.ConditionValue {
			ua.Progress = achievement.ConditionValue
			ua.IsCompleted = true
			now := time.Now()
			ua.CompletedAt = &now
		}

		s.achievementRepo.UpdateUserAchievement(ua)
	}

	return nil
}

// ClaimAchievementReward 领取成就奖励
func (s *AchievementService) ClaimAchievementReward(userID, achievementID uint) error {
	ua, err := s.achievementRepo.GetUserAchievementByID(userID, achievementID)
	if err != nil {
		return errors.New("成就不存在")
	}

	if !ua.IsCompleted {
		return errors.New("成就未完成")
	}

	if ua.IsClaimed {
		return errors.New("奖励已领取")
	}

	achievement := ua.Achievement

	// 发放奖励
	if achievement.RewardType == "gold" {
		s.userRepo.UpdateGold(userID, float64(achievement.RewardValue))
	} else if achievement.RewardType == "item" && achievement.RewardItemID != nil {
		s.farmRepo.AddToInventory(userID, "seed", *achievement.RewardItemID, achievement.RewardValue)
	}

	// 增加成就点数
	user, _ := s.userRepo.FindByID(userID)
	if user != nil {
		user.AchievementPoints += achievement.Points
		s.userRepo.Update(user)
	}

	// 标记已领取
	now := time.Now()
	ua.IsClaimed = true
	ua.ClaimedAt = &now

	return s.achievementRepo.UpdateUserAchievement(ua)
}

// === 邮件系统 ===

// GetUserMails 获取用户邮件
func (s *AchievementService) GetUserMails(userID uint, limit int) ([]models.Mail, error) {
	return s.achievementRepo.GetUserMails(userID, limit)
}

// ReadMail 阅读邮件
func (s *AchievementService) ReadMail(userID, mailID uint) (*models.Mail, error) {
	mail, err := s.achievementRepo.GetMailByID(mailID)
	if err != nil {
		return nil, errors.New("邮件不存在")
	}

	if mail.UserID != userID {
		return nil, errors.New("无权操作")
	}

	mail.IsRead = true
	s.achievementRepo.UpdateMail(mail)

	return mail, nil
}

// ClaimMailAttachments 领取邮件附件
func (s *AchievementService) ClaimMailAttachments(userID, mailID uint) error {
	mail, err := s.achievementRepo.GetMailByID(mailID)
	if err != nil {
		return errors.New("邮件不存在")
	}

	if mail.UserID != userID {
		return errors.New("无权操作")
	}

	if mail.IsClaimed {
		return errors.New("附件已领取")
	}

	if mail.Attachments == "" {
		return errors.New("没有附件")
	}

	// 解析附件
	var attachments []struct {
		Type     string `json:"type"`
		ItemID   uint   `json:"item_id"`
		Quantity int    `json:"quantity"`
		Gold     int    `json:"gold"`
	}

	if err := json.Unmarshal([]byte(mail.Attachments), &attachments); err != nil {
		return errors.New("附件格式错误")
	}

	// 发放附件
	for _, att := range attachments {
		if att.Type == "gold" {
			s.userRepo.UpdateGold(userID, float64(att.Gold))
		} else {
			s.farmRepo.AddToInventory(userID, att.Type, att.ItemID, att.Quantity)
		}
	}

	mail.IsClaimed = true
	return s.achievementRepo.UpdateMail(mail)
}

// DeleteMail 删除邮件
func (s *AchievementService) DeleteMail(userID, mailID uint) error {
	mail, err := s.achievementRepo.GetMailByID(mailID)
	if err != nil {
		return errors.New("邮件不存在")
	}

	if mail.UserID != userID {
		return errors.New("无权操作")
	}

	return s.achievementRepo.DeleteMail(mailID)
}

// SendSystemMail 发送系统邮件
func (s *AchievementService) SendSystemMail(userID uint, title, content string, attachments string) error {
	mail := &models.Mail{
		UserID:      userID,
		Title:       title,
		Content:     content,
		MailType:    "system",
		Attachments: attachments,
	}
	return s.achievementRepo.CreateMail(mail)
}

// GetUnreadMailCount 获取未读邮件数
func (s *AchievementService) GetUnreadMailCount(userID uint) (int64, error) {
	return s.achievementRepo.GetUnreadMailCount(userID)
}

// === 签到系统 ===

// Checkin 签到
func (s *AchievementService) Checkin(userID uint) (int, error) {
	// 检查是否已签到
	existing, _ := s.achievementRepo.GetTodayCheckin(userID)
	if existing != nil {
		return 0, errors.New("今日已签到")
	}

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return 0, errors.New("用户不存在")
	}

	stats, _ := s.userRepo.GetUserStats(userID)
	if stats == nil {
		return 0, errors.New("用户统计不存在")
	}

	today := time.Now()
	dayOfMonth := today.Day()

	// 计算连续签到天数
	consecutiveDays := 1
	if stats.LastLoginDate != nil {
		lastDate, _ := time.Parse("2006-01-02", *stats.LastLoginDate)
		if today.Sub(lastDate).Hours() < 48 {
			consecutiveDays = stats.ConsecutiveDays + 1
		}
	}

	// 计算奖励（连续签到越多，奖励越高）
	baseReward := 50
	reward := baseReward + (consecutiveDays-1)*10
	if reward > 200 {
		reward = 200
	}

	// 创建签到记录
	checkin := &models.DailyCheckin{
		UserID:      userID,
		CheckinDate: today.Format("2006-01-02"),
		DayOfMonth:  dayOfMonth,
	}
	if err := s.achievementRepo.CreateCheckin(checkin); err != nil {
		return 0, err
	}

	// 发放奖励
	s.userRepo.UpdateGold(userID, float64(reward))

	// 更新用户统计
	todayStr := today.Format("2006-01-02")
	stats.LoginDays++
	stats.ConsecutiveDays = consecutiveDays
	stats.LastLoginDate = &todayStr
	s.userRepo.UpdateUserStats(stats)

	// 更新贡献值
	user.Contribution++
	s.userRepo.Update(user)

	// 更新成就进度
	s.UpdateAchievementProgress(userID, "login_days", 1)
	s.UpdateAchievementProgress(userID, "consecutive_days", 0) // 特殊处理

	return reward, nil
}

// GetMonthCheckins 获取本月签到记录
func (s *AchievementService) GetMonthCheckins(userID uint) ([]models.DailyCheckin, error) {
	now := time.Now()
	return s.achievementRepo.GetMonthCheckins(userID, now.Year(), int(now.Month()))
}

// === 排行榜 ===

// GetRankings 获取排行榜
func (s *AchievementService) GetRankings(rankType string, limit int) ([]models.Ranking, error) {
	return s.achievementRepo.GetRankings(rankType, limit)
}
