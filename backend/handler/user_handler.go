package handler

import (
	"farm-game/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	userService *service.UserService
}

func NewUserHandler() *UserHandler {
	return &UserHandler{
		userService: service.NewUserService(),
	}
}

// GetProfile 获取用户信息
func (h *UserHandler) GetProfile(c *gin.Context) {
	userID, _ := c.Get("userID")
	user, err := h.userService.GetUserByID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	stats, _ := h.userService.GetUserStats(user.ID)

	c.JSON(http.StatusOK, gin.H{
		"user":  user,
		"stats": stats,
	})
}

// GetUserByID 根据ID获取用户信息
func (h *UserHandler) GetUserByID(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	user, err := h.userService.GetUserByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}

// ExpandFarm 扩展农田
func (h *UserHandler) ExpandFarm(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	err := h.userService.ExpandFarmSlot(userID.(uint))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "扩展成功"})
}

// GetFarmSlotPrice 获取扩展农田价格
func (h *UserHandler) GetFarmSlotPrice(c *gin.Context) {
	userID, _ := c.Get("userID")
	user, err := h.userService.GetUserByID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	price := h.userService.GetFarmSlotPrice(user.FarmSlots + 1)

	c.JSON(http.StatusOK, gin.H{
		"current_slots": user.FarmSlots,
		"next_price":    price,
	})
}

// CheckLevelUp 检查升级
func (h *UserHandler) CheckLevelUp(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	canLevelUp, err := h.userService.CheckLevelUp(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"can_level_up": canLevelUp})
}

// LevelUp 升级
func (h *UserHandler) LevelUp(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	err := h.userService.LevelUp(userID.(uint))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "升级成功"})
}
