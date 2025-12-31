package repository

import (
	"farm-game/config"
	"farm-game/models"

	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type FarmRepository struct {
	db *gorm.DB
}

func NewFarmRepository() *FarmRepository {
	return &FarmRepository{db: config.GetDB()}
}

// === 种子相关 ===

// GetAllSeeds 获取所有种子
func (r *FarmRepository) GetAllSeeds() ([]models.Seed, error) {
	var seeds []models.Seed
	err := r.db.Where("is_active = ?", true).Order("unlock_level ASC").Find(&seeds).Error
	return seeds, err
}

// GetSeedByID 根据ID获取种子
func (r *FarmRepository) GetSeedByID(id uint) (*models.Seed, error) {
	var seed models.Seed
	err := r.db.First(&seed, id).Error
	if err != nil {
		return nil, err
	}
	return &seed, nil
}

// GetSeedsByLevel 获取指定等级可解锁的种子
func (r *FarmRepository) GetSeedsByLevel(level int) ([]models.Seed, error) {
	var seeds []models.Seed
	err := r.db.Where("is_active = ? AND unlock_level <= ?", true, level).Find(&seeds).Error
	return seeds, err
}

// === 作物相关 ===

// GetAllCrops 获取所有作物
func (r *FarmRepository) GetAllCrops() ([]models.Crop, error) {
	var crops []models.Crop
	err := r.db.Preload("Seed").Find(&crops).Error
	return crops, err
}

// GetCropByID 根据ID获取作物
func (r *FarmRepository) GetCropByID(id uint) (*models.Crop, error) {
	var crop models.Crop
	err := r.db.Preload("Seed").First(&crop, id).Error
	if err != nil {
		return nil, err
	}
	return &crop, nil
}

// GetCropBySeedID 根据种子ID获取作物
func (r *FarmRepository) GetCropBySeedID(seedID uint) (*models.Crop, error) {
	var crop models.Crop
	err := r.db.Where("seed_id = ?", seedID).First(&crop).Error
	if err != nil {
		return nil, err
	}
	return &crop, nil
}

// === 用户农田相关 ===

// GetUserFarms 获取用户所有农田
func (r *FarmRepository) GetUserFarms(userID uint) ([]models.UserFarm, error) {
	var farms []models.UserFarm
	err := r.db.Where("user_id = ?", userID).Preload("Seed").Order("slot_index ASC").Find(&farms).Error
	return farms, err
}

// GetUserFarmBySlot 获取用户指定格子的农田
func (r *FarmRepository) GetUserFarmBySlot(userID uint, slotIndex int) (*models.UserFarm, error) {
	var farm models.UserFarm
	err := r.db.Where("user_id = ? AND slot_index = ?", userID, slotIndex).Preload("Seed").First(&farm).Error
	if err != nil {
		return nil, err
	}
	return &farm, nil
}

// CreateUserFarm 创建用户农田
func (r *FarmRepository) CreateUserFarm(farm *models.UserFarm) error {
	return r.db.Create(farm).Error
}

// UpdateUserFarm 更新用户农田
func (r *FarmRepository) UpdateUserFarm(farm *models.UserFarm) error {
	return r.db.Save(farm).Error
}

// InitUserFarms 初始化用户农田
func (r *FarmRepository) InitUserFarms(userID uint, slots int) error {
	for i := 0; i < slots; i++ {
		farm := &models.UserFarm{
			UserID:    userID,
			SlotIndex: i,
			Status:    "empty",
		}
		if err := r.db.Create(farm).Error; err != nil {
			return err
		}
	}
	return nil
}

// === 用户仓库相关 ===

// GetUserInventory 获取用户仓库
func (r *FarmRepository) GetUserInventory(userID uint) ([]models.UserInventory, error) {
	var inventory []models.UserInventory
	err := r.db.Where("user_id = ?", userID).Find(&inventory).Error
	return inventory, err
}

// GetUserInventoryItem 获取用户仓库指定物品
func (r *FarmRepository) GetUserInventoryItem(userID uint, itemType string, itemID uint) (*models.UserInventory, error) {
	var item models.UserInventory
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("user_id = ? AND item_type = ? AND item_id = ?", userID, itemType, itemID).First(&item).Error
	if err != nil {
		return nil, err
	}
	return &item, nil
}

// AddToInventory 添加物品到仓库
func (r *FarmRepository) AddToInventory(userID uint, itemType string, itemID uint, quantity int) error {
	var item models.UserInventory
	err := r.db.Session(&gorm.Session{Logger: logger.Discard}).Where("user_id = ? AND item_type = ? AND item_id = ?", userID, itemType, itemID).First(&item).Error
	
	if err == gorm.ErrRecordNotFound {
		item = models.UserInventory{
			UserID:   userID,
			ItemType: itemType,
			ItemID:   itemID,
			Quantity: quantity,
		}
		return r.db.Create(&item).Error
	}
	
	if err != nil {
		return err
	}
	
	return r.db.Model(&item).Update("quantity", gorm.Expr("quantity + ?", quantity)).Error
}

// RemoveFromInventory 从仓库移除物品
func (r *FarmRepository) RemoveFromInventory(userID uint, itemType string, itemID uint, quantity int) error {
	return r.db.Model(&models.UserInventory{}).
		Where("user_id = ? AND item_type = ? AND item_id = ? AND quantity >= ?", userID, itemType, itemID, quantity).
		Update("quantity", gorm.Expr("quantity - ?", quantity)).Error
}
