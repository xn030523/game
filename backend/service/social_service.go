package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
	"math/rand"
	"time"
)

type SocialService struct {
	socialRepo *repository.SocialRepository
	userRepo   *repository.UserRepository
	farmRepo   *repository.FarmRepository
}

func NewSocialService() *SocialService {
	return &SocialService{
		socialRepo: repository.NewSocialRepository(),
		userRepo:   repository.NewUserRepository(),
		farmRepo:   repository.NewFarmRepository(),
	}
}

// === 好友系统 ===

// GetFriends 获取好友列表
func (s *SocialService) GetFriends(userID uint) ([]models.User, error) {
	friendships, err := s.socialRepo.GetFriends(userID)
	if err != nil {
		return nil, err
	}

	var friends []models.User
	for _, f := range friendships {
		if f.UserID == userID {
			friends = append(friends, f.Friend)
		} else {
			friends = append(friends, f.User)
		}
	}
	return friends, nil
}

// GetFriendRequests 获取好友申请
func (s *SocialService) GetFriendRequests(userID uint) ([]models.Friendship, error) {
	return s.socialRepo.GetFriendRequests(userID)
}

// SendFriendRequest 发送好友申请
func (s *SocialService) SendFriendRequest(userID, friendID uint) error {
	if userID == friendID {
		return errors.New("不能添加自己为好友")
	}

	// 检查对方是否存在
	_, err := s.userRepo.FindByID(friendID)
	if err != nil {
		return errors.New("用户不存在")
	}

	// 检查是否已经是好友
	existing, _ := s.socialRepo.GetFriendship(userID, friendID)
	if existing != nil {
		if existing.Status == "accepted" {
			return errors.New("已经是好友")
		}
		if existing.Status == "pending" {
			return errors.New("已发送过申请")
		}
		if existing.Status == "blocked" {
			return errors.New("已被对方拉黑")
		}
	}

	friendship := &models.Friendship{
		UserID:   userID,
		FriendID: friendID,
		Status:   "pending",
	}

	return s.socialRepo.CreateFriendship(friendship)
}

// AcceptFriendRequest 接受好友申请
func (s *SocialService) AcceptFriendRequest(userID, friendshipID uint) error {
	friendship, err := s.socialRepo.GetFriendship(userID, friendshipID)
	if err != nil {
		return errors.New("申请不存在")
	}

	if friendship.FriendID != userID {
		return errors.New("无权操作")
	}

	if friendship.Status != "pending" {
		return errors.New("申请状态错误")
	}

	now := time.Now()
	friendship.Status = "accepted"
	friendship.AcceptedAt = &now

	// 更新双方好友数量
	userStats, _ := s.userRepo.GetUserStats(friendship.UserID)
	friendStats, _ := s.userRepo.GetUserStats(friendship.FriendID)
	if userStats != nil {
		userStats.TotalFriends++
		s.userRepo.UpdateUserStats(userStats)
	}
	if friendStats != nil {
		friendStats.TotalFriends++
		s.userRepo.UpdateUserStats(friendStats)
	}

	return s.socialRepo.UpdateFriendship(friendship)
}

// RejectFriendRequest 拒绝好友申请
func (s *SocialService) RejectFriendRequest(userID, friendshipID uint) error {
	friendship, err := s.socialRepo.GetFriendship(userID, friendshipID)
	if err != nil {
		return errors.New("申请不存在")
	}

	if friendship.FriendID != userID {
		return errors.New("无权操作")
	}

	return s.socialRepo.DeleteFriendship(friendship.ID)
}

// RemoveFriend 删除好友
func (s *SocialService) RemoveFriend(userID, friendID uint) error {
	friendship, err := s.socialRepo.GetFriendship(userID, friendID)
	if err != nil {
		return errors.New("不是好友")
	}

	// 更新好友数量
	userStats, _ := s.userRepo.GetUserStats(userID)
	friendStats, _ := s.userRepo.GetUserStats(friendID)
	if userStats != nil && userStats.TotalFriends > 0 {
		userStats.TotalFriends--
		s.userRepo.UpdateUserStats(userStats)
	}
	if friendStats != nil && friendStats.TotalFriends > 0 {
		friendStats.TotalFriends--
		s.userRepo.UpdateUserStats(friendStats)
	}

	return s.socialRepo.DeleteFriendship(friendship.ID)
}

// === 好友消息 ===

// GetMessages 获取与好友的消息
func (s *SocialService) GetMessages(userID, friendID uint, limit int) ([]models.FriendMessage, error) {
	// 验证是否是好友
	friendship, err := s.socialRepo.GetFriendship(userID, friendID)
	if err != nil || friendship.Status != "accepted" {
		return nil, errors.New("不是好友")
	}

	// 标记已读
	s.socialRepo.MarkMessagesRead(userID, friendID)

	return s.socialRepo.GetMessages(userID, friendID, limit)
}

// SendMessage 发送消息
func (s *SocialService) SendMessage(userID, friendID uint, content string) error {
	if content == "" {
		return errors.New("消息不能为空")
	}

	// 验证是否是好友
	friendship, err := s.socialRepo.GetFriendship(userID, friendID)
	if err != nil || friendship.Status != "accepted" {
		return errors.New("不是好友")
	}

	message := &models.FriendMessage{
		FromUserID: userID,
		ToUserID:   friendID,
		Content:    content,
	}

	return s.socialRepo.CreateMessage(message)
}

// GetUnreadCount 获取未读消息数
func (s *SocialService) GetUnreadCount(userID uint) (int64, error) {
	return s.socialRepo.GetUnreadCount(userID)
}

// === 好友互动 ===

// StealCrop 偷菜
func (s *SocialService) StealCrop(userID, friendID uint, slotIndex int) (int, error) {
	// 验证是否是好友
	friendship, err := s.socialRepo.GetFriendship(userID, friendID)
	if err != nil || friendship.Status != "accepted" {
		return 0, errors.New("不是好友")
	}

	// 检查今日是否已偷过
	count, _ := s.socialRepo.GetTodayInteractions(userID, friendID, "steal")
	if count >= 3 {
		return 0, errors.New("今日偷取次数已达上限")
	}

	// 获取好友农田
	farm, err := s.farmRepo.GetUserFarmBySlot(friendID, slotIndex)
	if err != nil {
		return 0, errors.New("农田不存在")
	}

	if farm.Status != "mature" {
		return 0, errors.New("作物未成熟")
	}

	// 随机偷取1-2个
	stealAmount := 1 + rand.Intn(2)

	// 获取作物
	crop, _ := s.farmRepo.GetCropBySeedID(*farm.SeedID)
	if crop == nil {
		return 0, errors.New("作物不存在")
	}

	// 添加到自己仓库
	s.farmRepo.AddToInventory(userID, "crop", crop.ID, stealAmount)

	// 记录互动
	interaction := &models.FriendInteraction{
		UserID:     userID,
		FriendID:   friendID,
		Action:     "steal",
		Reward:     stealAmount,
		TargetSlot: &slotIndex,
	}
	s.socialRepo.CreateInteraction(interaction)

	// 更新统计
	stats, _ := s.userRepo.GetUserStats(userID)
	if stats != nil {
		stats.TotalStolen += stealAmount
		s.userRepo.UpdateUserStats(stats)
	}

	return stealAmount, nil
}

// === 世界聊天 ===

// GetChatMessages 获取聊天消息
func (s *SocialService) GetChatMessages(channel string, limit int) ([]models.ChatMessage, error) {
	return s.socialRepo.GetChatMessages(channel, limit)
}

// SendChatMessage 发送聊天消息
func (s *SocialService) SendChatMessage(userID uint, channel, content string) error {
	if content == "" {
		return errors.New("消息不能为空")
	}

	if len(content) > 500 {
		return errors.New("消息过长")
	}

	message := &models.ChatMessage{
		UserID:  userID,
		Channel: channel,
		Content: content,
	}

	return s.socialRepo.CreateChatMessage(message)
}
