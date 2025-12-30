package handler

import (
	"farm-game/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type SocialHandler struct {
	socialService *service.SocialService
}

func NewSocialHandler() *SocialHandler {
	return &SocialHandler{
		socialService: service.NewSocialService(),
	}
}

// === 好友系统 ===

// GetFriends 获取好友列表
func (h *SocialHandler) GetFriends(c *gin.Context) {
	userID, _ := c.Get("userID")

	friends, err := h.socialService.GetFriends(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"friends": friends})
}

// GetFriendRequests 获取好友申请
func (h *SocialHandler) GetFriendRequests(c *gin.Context) {
	userID, _ := c.Get("userID")

	requests, err := h.socialService.GetFriendRequests(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"requests": requests})
}

// SendFriendRequest 发送好友申请
func (h *SocialHandler) SendFriendRequest(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		FriendID uint `json:"friend_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.socialService.SendFriendRequest(userID.(uint), req.FriendID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "申请已发送"})
}

// AcceptFriendRequest 接受好友申请
func (h *SocialHandler) AcceptFriendRequest(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	friendshipID, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.socialService.AcceptFriendRequest(userID.(uint), uint(friendshipID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "已接受"})
}

// RejectFriendRequest 拒绝好友申请
func (h *SocialHandler) RejectFriendRequest(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	friendshipID, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.socialService.RejectFriendRequest(userID.(uint), uint(friendshipID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "已拒绝"})
}

// RemoveFriend 删除好友
func (h *SocialHandler) RemoveFriend(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	friendID, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.socialService.RemoveFriend(userID.(uint), uint(friendID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "已删除"})
}

// === 好友消息 ===

// GetMessages 获取与好友的消息
func (h *SocialHandler) GetMessages(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	friendID, _ := strconv.ParseUint(idStr, 10, 32)
	limitStr := c.DefaultQuery("limit", "50")
	limit, _ := strconv.Atoi(limitStr)

	messages, err := h.socialService.GetMessages(userID.(uint), uint(friendID), limit)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"messages": messages})
}

// SendMessage 发送消息
func (h *SocialHandler) SendMessage(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	friendID, _ := strconv.ParseUint(idStr, 10, 32)

	var req struct {
		Content string `json:"content" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.socialService.SendMessage(userID.(uint), uint(friendID), req.Content)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "发送成功"})
}

// GetUnreadCount 获取未读消息数
func (h *SocialHandler) GetUnreadCount(c *gin.Context) {
	userID, _ := c.Get("userID")

	count, _ := h.socialService.GetUnreadCount(userID.(uint))

	c.JSON(http.StatusOK, gin.H{"unread_count": count})
}

// === 好友互动 ===

// StealCrop 偷菜
func (h *SocialHandler) StealCrop(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		FriendID  uint `json:"friend_id" binding:"required"`
		SlotIndex int  `json:"slot_index" binding:"required,min=0"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	amount, err := h.socialService.StealCrop(userID.(uint), req.FriendID, req.SlotIndex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "偷取成功", "amount": amount})
}

// === 世界聊天 ===

// GetChatMessages 获取聊天消息
func (h *SocialHandler) GetChatMessages(c *gin.Context) {
	channel := c.DefaultQuery("channel", "world")
	limitStr := c.DefaultQuery("limit", "100")
	limit, _ := strconv.Atoi(limitStr)

	messages, err := h.socialService.GetChatMessages(channel, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"messages": messages})
}

// SendChatMessage 发送聊天消息
func (h *SocialHandler) SendChatMessage(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		Channel string `json:"channel" binding:"required"`
		Content string `json:"content" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	err := h.socialService.SendChatMessage(userID.(uint), req.Channel, req.Content)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "发送成功"})
}
