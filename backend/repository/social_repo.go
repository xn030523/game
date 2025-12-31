package repository

import (
	"farm-game/config"
	"farm-game/models"
	"sync"

	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type SocialRepository struct {
	db *gorm.DB
}

var (
	socialRepoInstance *SocialRepository
	socialRepoOnce     sync.Once
)

func NewSocialRepository() *SocialRepository {
	socialRepoOnce.Do(func() {
		socialRepoInstance = &SocialRepository{db: config.GetDB()}
	})
	return socialRepoInstance
}

// === 好友关系 ===

// GetFriendship 获取好友关系
func (r *SocialRepository) GetFriendship(userID, friendID uint) (*models.Friendship, error) {
	var friendship models.Friendship
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)",
		userID, friendID, friendID, userID).First(&friendship).Error
	if err != nil {
		return nil, err
	}
	return &friendship, nil
}

// GetFriends 获取好友列表
func (r *SocialRepository) GetFriends(userID uint) ([]models.Friendship, error) {
	var friendships []models.Friendship
	err := r.db.Where("(user_id = ? OR friend_id = ?) AND status = 'accepted'", userID, userID).
		Preload("User").Preload("Friend").Find(&friendships).Error
	return friendships, err
}

// GetFriendRequests 获取好友申请
func (r *SocialRepository) GetFriendRequests(userID uint) ([]models.Friendship, error) {
	var friendships []models.Friendship
	err := r.db.Where("friend_id = ? AND status = 'pending'", userID).
		Preload("User").Find(&friendships).Error
	return friendships, err
}

// CreateFriendship 创建好友关系
func (r *SocialRepository) CreateFriendship(friendship *models.Friendship) error {
	return r.db.Create(friendship).Error
}

// UpdateFriendship 更新好友关系
func (r *SocialRepository) UpdateFriendship(friendship *models.Friendship) error {
	return r.db.Save(friendship).Error
}

// DeleteFriendship 删除好友关系
func (r *SocialRepository) DeleteFriendship(id uint) error {
	return r.db.Delete(&models.Friendship{}, id).Error
}

// === 好友消息 ===

// GetMessages 获取与好友的消息
func (r *SocialRepository) GetMessages(userID, friendID uint, limit int) ([]models.FriendMessage, error) {
	var messages []models.FriendMessage
	err := r.db.Where(
		"(from_user_id = ? AND to_user_id = ?) OR (from_user_id = ? AND to_user_id = ?)",
		userID, friendID, friendID, userID,
	).Preload("FromUser").Order("created_at DESC").Limit(limit).Find(&messages).Error
	return messages, err
}

// CreateMessage 创建消息
func (r *SocialRepository) CreateMessage(message *models.FriendMessage) error {
	return r.db.Create(message).Error
}

// MarkMessagesRead 标记消息已读
func (r *SocialRepository) MarkMessagesRead(userID, fromUserID uint) error {
	return r.db.Model(&models.FriendMessage{}).
		Where("to_user_id = ? AND from_user_id = ? AND is_read = false", userID, fromUserID).
		Update("is_read", true).Error
}

// GetUnreadCount 获取未读消息数
func (r *SocialRepository) GetUnreadCount(userID uint) (int64, error) {
	var count int64
	err := r.db.Model(&models.FriendMessage{}).
		Where("to_user_id = ? AND is_read = false", userID).Count(&count).Error
	return count, err
}

// === 好友互动 ===

// CreateInteraction 创建互动记录
func (r *SocialRepository) CreateInteraction(interaction *models.FriendInteraction) error {
	return r.db.Create(interaction).Error
}

// GetTodayInteractions 获取今日互动记录
func (r *SocialRepository) GetTodayInteractions(userID, friendID uint, action string) (int64, error) {
	var count int64
	err := r.db.Model(&models.FriendInteraction{}).
		Where("user_id = ? AND friend_id = ? AND action = ? AND DATE(created_at) = CURDATE()",
			userID, friendID, action).Count(&count).Error
	return count, err
}

// === 聊天消息 ===

// GetChatMessages 获取聊天消息
func (r *SocialRepository) GetChatMessages(channel string, limit int) ([]models.ChatMessage, error) {
	var messages []models.ChatMessage
	err := r.db.Where("channel = ?", channel).
		Preload("User").Order("created_at DESC").Limit(limit).Find(&messages).Error
	return messages, err
}

// CreateChatMessage 创建聊天消息
func (r *SocialRepository) CreateChatMessage(message *models.ChatMessage) error {
	return r.db.Create(message).Error
}
