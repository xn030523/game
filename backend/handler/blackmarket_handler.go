package handler

import (
	"farm-game/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type BlackmarketHandler struct {
	blackmarketService *service.BlackmarketService
}

func NewBlackmarketHandler() *BlackmarketHandler {
	return &BlackmarketHandler{
		blackmarketService: service.NewBlackmarketService(),
	}
}

// GetCurrentBatch 获取当前黑市
func (h *BlackmarketHandler) GetCurrentBatch(c *gin.Context) {
	batch, items, err := h.blackmarketService.GetCurrentBatch()
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	nextRefresh := h.blackmarketService.GetNextRefreshTime()

	c.JSON(http.StatusOK, gin.H{
		"batch":        batch,
		"items":        items,
		"next_refresh": nextRefresh,
	})
}

// BuyItem 购买商品
func (h *BlackmarketHandler) BuyItem(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		ItemID   uint `json:"item_id" binding:"required"`
		Quantity int  `json:"quantity" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.blackmarketService.BuyItem(userID.(uint), req.ItemID, req.Quantity)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "购买成功"})
}

// GetPurchaseHistory 获取购买记录
func (h *BlackmarketHandler) GetPurchaseHistory(c *gin.Context) {
	userID, _ := c.Get("userID")
	limitStr := c.DefaultQuery("limit", "50")
	limit, _ := strconv.Atoi(limitStr)

	logs, err := h.blackmarketService.GetUserPurchaseHistory(userID.(uint), limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"logs": logs})
}
