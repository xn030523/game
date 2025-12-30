package handler

import (
	"farm-game/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

type FarmHandler struct {
	farmService *service.FarmService
	userService *service.UserService
}

func NewFarmHandler() *FarmHandler {
	return &FarmHandler{
		farmService: service.NewFarmService(),
		userService: service.NewUserService(),
	}
}

// GetSeeds 获取可购买的种子列表
func (h *FarmHandler) GetSeeds(c *gin.Context) {
	userID, _ := c.Get("userID")
	user, err := h.userService.GetUserByID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	seeds, err := h.farmService.GetSeeds(user.Level)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"seeds": seeds})
}

// GetFarms 获取用户农田
func (h *FarmHandler) GetFarms(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	farms, err := h.farmService.GetUserFarms(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"farms": farms})
}

// BuySeed 购买种子
func (h *FarmHandler) BuySeed(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	var req struct {
		SeedID   uint `json:"seed_id" binding:"required"`
		Quantity int  `json:"quantity" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.farmService.BuySeed(userID.(uint), req.SeedID, req.Quantity)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "购买成功"})
}

// Plant 种植
func (h *FarmHandler) Plant(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	var req struct {
		SlotIndex int  `json:"slot_index" binding:"required,min=0"`
		SeedID    uint `json:"seed_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.farmService.Plant(userID.(uint), req.SlotIndex, req.SeedID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "种植成功"})
}

// Harvest 收获
func (h *FarmHandler) Harvest(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	var req struct {
		SlotIndex int `json:"slot_index" binding:"required,min=0"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	result, err := h.farmService.Harvest(userID.(uint), req.SlotIndex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "收获成功",
		"result":  result,
	})
}

// SellCrop 出售作物
func (h *FarmHandler) SellCrop(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	var req struct {
		CropID   uint `json:"crop_id" binding:"required"`
		Quantity int  `json:"quantity" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	earning, err := h.farmService.SellCrop(userID.(uint), req.CropID, req.Quantity)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "出售成功",
		"earning": earning,
	})
}

// GetInventory 获取仓库
func (h *FarmHandler) GetInventory(c *gin.Context) {
	userID, _ := c.Get("userID")
	
	inventory, err := h.farmService.GetUserInventory(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"inventory": inventory})
}
