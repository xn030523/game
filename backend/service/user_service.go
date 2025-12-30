package service

import (
	"errors"
	"farm-game/models"
	"farm-game/repository"
)

type UserService struct {
	userRepo *repository.UserRepository
	farmRepo *repository.FarmRepository
}

func NewUserService() *UserService {
	return &UserService{
		userRepo: repository.NewUserRepository(),
		farmRepo: repository.NewFarmRepository(),
	}
}

// GetUserByID 根据ID获取用户
func (s *UserService) GetUserByID(id uint) (*models.User, error) {
	return s.userRepo.FindByID(id)
}

// GetUserByLinuxdoID 根据LinuxdoID获取用户
func (s *UserService) GetUserByLinuxdoID(linuxdoID string) (*models.User, error) {
	return s.userRepo.FindByLinuxdoID(linuxdoID)
}

// CreateUser 创建新用户
func (s *UserService) CreateUser(linuxdoID, nickname, avatar string) (*models.User, error) {
	user := &models.User{
		LinuxdoID: linuxdoID,
		Nickname:  nickname,
		Avatar:    avatar,
		Level:     1,
		Gold:      1000,
		FarmSlots: 4,
	}

	if err := s.userRepo.Create(user); err != nil {
		return nil, err
	}

	// 初始化用户统计
	stats := &models.UserStats{UserID: user.ID}
	if err := s.userRepo.CreateUserStats(stats); err != nil {
		return nil, err
	}

	// 初始化农田
	if err := s.farmRepo.InitUserFarms(user.ID, user.FarmSlots); err != nil {
		return nil, err
	}

	return user, nil
}

// LoginOrRegister 登录或注册
func (s *UserService) LoginOrRegister(linuxdoID, nickname, avatar string) (*models.User, bool, error) {
	user, err := s.userRepo.FindByLinuxdoID(linuxdoID)
	if err == nil {
		// 更新用户信息
		user.Nickname = nickname
		user.Avatar = avatar
		s.userRepo.Update(user)
		return user, false, nil
	}

	// 创建新用户
	user, err = s.CreateUser(linuxdoID, nickname, avatar)
	if err != nil {
		return nil, false, err
	}
	return user, true, nil
}

// UpdateGold 更新用户金币
func (s *UserService) UpdateGold(userID uint, amount float64) error {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return err
	}
	
	if user.Gold+amount < 0 {
		return errors.New("金币不足")
	}
	
	return s.userRepo.UpdateGold(userID, amount)
}

// GetUserStats 获取用户统计
func (s *UserService) GetUserStats(userID uint) (*models.UserStats, error) {
	return s.userRepo.GetUserStats(userID)
}

// CheckLevelUp 检查是否可以升级
func (s *UserService) CheckLevelUp(userID uint) (bool, error) {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return false, err
	}

	nextLevelConfig, err := s.userRepo.GetLevelConfig(user.Level + 1)
	if err != nil {
		return false, nil // 已是最高级
	}

	// 贡献值或成就点数达标即可升级
	if user.Contribution >= nextLevelConfig.ContributionRequired ||
		user.AchievementPoints >= nextLevelConfig.AchievementPointsRequired {
		return true, nil
	}

	return false, nil
}

// LevelUp 升级
func (s *UserService) LevelUp(userID uint) error {
	canLevelUp, err := s.CheckLevelUp(userID)
	if err != nil {
		return err
	}
	if !canLevelUp {
		return errors.New("不满足升级条件")
	}

	user, _ := s.userRepo.FindByID(userID)
	nextLevelConfig, _ := s.userRepo.GetLevelConfig(user.Level + 1)

	user.Level++
	user.Gold += float64(nextLevelConfig.RewardGold)

	return s.userRepo.Update(user)
}

// AutoLevelUp 自动升级（循环检查直到不能升级）
func (s *UserService) AutoLevelUp(userID uint) (int, error) {
	levelsGained := 0
	for {
		canLevelUp, _ := s.CheckLevelUp(userID)
		if !canLevelUp {
			break
		}
		user, _ := s.userRepo.FindByID(userID)
		nextLevelConfig, _ := s.userRepo.GetLevelConfig(user.Level + 1)
		if nextLevelConfig == nil {
			break
		}
		user.Level++
		user.Gold += float64(nextLevelConfig.RewardGold)
		s.userRepo.Update(user)
		levelsGained++
	}
	return levelsGained, nil
}

// GetFarmSlotPrice 计算扩展农田价格
func (s *UserService) GetFarmSlotPrice(slotIndex int) int {
	if slotIndex <= 4 {
		return 0
	}
	return (slotIndex - 4) * 1000
}

// ExpandFarmSlot 扩展农田
func (s *UserService) ExpandFarmSlot(userID uint) error {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return err
	}

	price := s.GetFarmSlotPrice(user.FarmSlots + 1)
	if user.Gold < float64(price) {
		return errors.New("金币不足")
	}

	// 扣除金币
	user.Gold -= float64(price)
	user.FarmSlots++

	if err := s.userRepo.Update(user); err != nil {
		return err
	}

	// 创建新农田
	farm := &models.UserFarm{
		UserID:    userID,
		SlotIndex: user.FarmSlots - 1,
		Status:    "empty",
	}
	return s.farmRepo.CreateUserFarm(farm)
}
