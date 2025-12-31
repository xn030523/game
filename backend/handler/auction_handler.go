package handler

import (
	"farm-game/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type AuctionHandler struct {
	auctionService *service.AuctionService
}

func NewAuctionHandler() *AuctionHandler {
	return &AuctionHandler{
		auctionService: service.NewAuctionService(),
	}
}

// GetAuctions 获取拍卖列表
func (h *AuctionHandler) GetAuctions(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	auctions, total, err := h.auctionService.GetActiveAuctions(page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"auctions": auctions,
		"total":    total,
		"page":     page,
	})
}

// GetAuctionDetail 获取拍卖详情
func (h *AuctionHandler) GetAuctionDetail(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)

	auction, bids, err := h.auctionService.GetAuctionDetail(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"auction": auction,
		"bids":    bids,
	})
}

// CreateAuction 上架拍卖
func (h *AuctionHandler) CreateAuction(c *gin.Context) {
	uid, _ := c.Get("userID")
	userID := uid.(uint)

	var req struct {
		ItemType    string   `json:"item_type" binding:"required"`
		ItemID      uint     `json:"item_id" binding:"required"`
		Quantity    int      `json:"quantity" binding:"required,min=1"`
		StartPrice  float64  `json:"start_price" binding:"required,min=1"`
		BuyoutPrice *float64 `json:"buyout_price"`
		Duration    int      `json:"duration" binding:"required,min=1,max=72"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	auction, err := h.auctionService.CreateAuction(
		userID, req.ItemType, req.ItemID, req.Quantity,
		req.StartPrice, req.BuyoutPrice, req.Duration,
	)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "上架成功",
		"auction": auction,
	})
}

// PlaceBid 出价
func (h *AuctionHandler) PlaceBid(c *gin.Context) {
	uid, _ := c.Get("userID")
	userID := uid.(uint)
	auctionID, _ := strconv.ParseUint(c.Param("id"), 10, 32)

	var req struct {
		BidPrice float64 `json:"bid_price" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	if err := h.auctionService.PlaceBid(userID, uint(auctionID), req.BidPrice); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "出价成功"})
}

// Buyout 一口价购买
func (h *AuctionHandler) Buyout(c *gin.Context) {
	uid, _ := c.Get("userID")
	userID := uid.(uint)
	auctionID, _ := strconv.ParseUint(c.Param("id"), 10, 32)

	if err := h.auctionService.Buyout(userID, uint(auctionID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "购买成功"})
}

// CancelAuction 取消拍卖
func (h *AuctionHandler) CancelAuction(c *gin.Context) {
	uid, _ := c.Get("userID")
	userID := uid.(uint)
	auctionID, _ := strconv.ParseUint(c.Param("id"), 10, 32)

	if err := h.auctionService.CancelAuction(userID, uint(auctionID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "取消成功"})
}

// GetMyAuctions 获取我的拍卖
func (h *AuctionHandler) GetMyAuctions(c *gin.Context) {
	uid, _ := c.Get("userID")
	userID := uid.(uint)

	selling, bidding, err := h.auctionService.GetMyAuctions(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"selling": selling,
		"bidding": bidding,
	})
}

// GetAuctionHistory 获取拍卖历史记录
func (h *AuctionHandler) GetAuctionHistory(c *gin.Context) {
	uid, _ := c.Get("userID")
	userID := uid.(uint)
	limitStr := c.DefaultQuery("limit", "50")
	limit, _ := strconv.Atoi(limitStr)

	sold, bought, err := h.auctionService.GetAuctionHistory(userID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"sold":   sold,
		"bought": bought,
	})
}
