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
	itemType := c.Query("item_type")
	pageStr := c.DefaultQuery("page", "1")
	pageSizeStr := c.DefaultQuery("page_size", "20")

	page, _ := strconv.Atoi(pageStr)
	pageSize, _ := strconv.Atoi(pageSizeStr)

	auctions, total, err := h.auctionService.GetActiveAuctions(itemType, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"auctions": auctions,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

// GetAuction 获取拍卖详情
func (h *AuctionHandler) GetAuction(c *gin.Context) {
	idStr := c.Param("id")
	id, _ := strconv.ParseUint(idStr, 10, 32)

	auction, err := h.auctionService.GetAuctionByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "拍卖不存在"})
		return
	}

	bids, _ := h.auctionService.GetAuctionBids(uint(id))

	c.JSON(http.StatusOK, gin.H{
		"auction": auction,
		"bids":    bids,
	})
}

// CreateAuction 创建拍卖
func (h *AuctionHandler) CreateAuction(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		ItemType    string   `json:"item_type" binding:"required"`
		ItemID      uint     `json:"item_id" binding:"required"`
		Quantity    int      `json:"quantity" binding:"required,min=1"`
		StartPrice  float64  `json:"start_price" binding:"required,min=1"`
		BuyoutPrice *float64 `json:"buyout_price"`
		Duration    int      `json:"duration" binding:"required,min=1,max=72"` // 小时
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	auction, err := h.auctionService.CreateAuction(
		userID.(uint), req.ItemType, req.ItemID, req.Quantity,
		req.StartPrice, req.BuyoutPrice, req.Duration,
	)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "创建成功", "auction": auction})
}

// PlaceBid 出价
func (h *AuctionHandler) PlaceBid(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	id, _ := strconv.ParseUint(idStr, 10, 32)

	var req struct {
		BidPrice float64 `json:"bid_price" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.auctionService.PlaceBid(userID.(uint), uint(id), req.BidPrice)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "出价成功"})
}

// Buyout 一口价购买
func (h *AuctionHandler) Buyout(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	id, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.auctionService.Buyout(userID.(uint), uint(id))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "购买成功"})
}

// CancelAuction 取消拍卖
func (h *AuctionHandler) CancelAuction(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	id, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.auctionService.CancelAuction(userID.(uint), uint(id))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "取消成功"})
}

// GetMyAuctions 获取我的拍卖
func (h *AuctionHandler) GetMyAuctions(c *gin.Context) {
	userID, _ := c.Get("userID")
	status := c.Query("status")

	auctions, err := h.auctionService.GetUserAuctions(userID.(uint), status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"auctions": auctions})
}

// GetMyBids 获取我参与的拍卖
func (h *AuctionHandler) GetMyBids(c *gin.Context) {
	userID, _ := c.Get("userID")

	auctions, err := h.auctionService.GetUserBidAuctions(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"auctions": auctions})
}
