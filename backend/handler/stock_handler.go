package handler

import (
	"farm-game/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type StockHandler struct {
	stockService *service.StockService
}

func NewStockHandler() *StockHandler {
	return &StockHandler{
		stockService: service.NewStockService(),
	}
}

// GetStocks 获取所有股票
func (h *StockHandler) GetStocks(c *gin.Context) {
	stocks, err := h.stockService.GetAllStocks()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"stocks": stocks})
}

// GetStock 获取股票详情
func (h *StockHandler) GetStock(c *gin.Context) {
	idStr := c.Param("id")
	id, _ := strconv.ParseUint(idStr, 10, 32)

	stock, err := h.stockService.GetStockByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "股票不存在"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"stock": stock})
}

// GetKLine 获取K线数据
func (h *StockHandler) GetKLine(c *gin.Context) {
	idStr := c.Param("id")
	id, _ := strconv.ParseUint(idStr, 10, 32)
	periodType := c.DefaultQuery("period", "1m")
	limitStr := c.DefaultQuery("limit", "100")
	limit, _ := strconv.Atoi(limitStr)

	prices, err := h.stockService.GetStockKLine(uint(id), periodType, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"prices": prices})
}

// BuyStock 买入股票(现货)
func (h *StockHandler) BuyStock(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		StockID uint  `json:"stock_id" binding:"required"`
		Shares  int64 `json:"shares" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.stockService.BuyStock(userID.(uint), req.StockID, req.Shares)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "买入成功"})
}

// SellStock 卖出股票(现货)
func (h *StockHandler) SellStock(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		StockID uint  `json:"stock_id" binding:"required"`
		Shares  int64 `json:"shares" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	profit, err := h.stockService.SellStock(userID.(uint), req.StockID, req.Shares)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "卖出成功", "profit": profit})
}

// OpenLong 开多仓
func (h *StockHandler) OpenLong(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		StockID  uint    `json:"stock_id" binding:"required"`
		Leverage int     `json:"leverage" binding:"required,min=1,max=10"`
		Margin   float64 `json:"margin" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	position, err := h.stockService.OpenLongPosition(userID.(uint), req.StockID, req.Leverage, req.Margin)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "开仓成功", "position": position})
}

// OpenShort 开空仓
func (h *StockHandler) OpenShort(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		StockID  uint    `json:"stock_id" binding:"required"`
		Leverage int     `json:"leverage" binding:"required,min=1,max=10"`
		Margin   float64 `json:"margin" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	position, err := h.stockService.OpenShortPosition(userID.(uint), req.StockID, req.Leverage, req.Margin)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "开仓成功", "position": position})
}

// ClosePosition 平仓
func (h *StockHandler) ClosePosition(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		PositionID uint `json:"position_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	profit, err := h.stockService.ClosePosition(userID.(uint), req.PositionID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "平仓成功", "profit": profit})
}

// GetMyStocks 获取我的现货持仓
func (h *StockHandler) GetMyStocks(c *gin.Context) {
	userID, _ := c.Get("userID")

	stocks, err := h.stockService.GetUserStocks(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"stocks": stocks})
}

// GetMyPositions 获取我的杠杆仓位
func (h *StockHandler) GetMyPositions(c *gin.Context) {
	userID, _ := c.Get("userID")
	status := c.DefaultQuery("status", "open")

	positions, err := h.stockService.GetUserPositions(userID.(uint), status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"positions": positions})
}

// GetMyStats 获取我的统计
func (h *StockHandler) GetMyStats(c *gin.Context) {
	userID, _ := c.Get("userID")

	stats, err := h.stockService.GetUserStockStats(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	totalAssets := h.stockService.CalculateUserTotalAssets(userID.(uint))
	stats.TotalAssets = totalAssets

	c.JSON(http.StatusOK, gin.H{"stats": stats})
}

// GetRankings 获取排行榜
func (h *StockHandler) GetRankings(c *gin.Context) {
	rankType := c.DefaultQuery("type", "profit")
	limitStr := c.DefaultQuery("limit", "100")
	limit, _ := strconv.Atoi(limitStr)

	rankings, err := h.stockService.GetRankings(rankType, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"rankings": rankings})
}
