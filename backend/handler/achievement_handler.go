package handler

import (
	"farm-game/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type AchievementHandler struct {
	achievementService *service.AchievementService
}

func NewAchievementHandler() *AchievementHandler {
	return &AchievementHandler{
		achievementService: service.NewAchievementService(),
	}
}

// === 成就系统 ===

// GetAchievements 获取成就列表
func (h *AchievementHandler) GetAchievements(c *gin.Context) {
	achievements, err := h.achievementService.GetAllAchievements()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"achievements": achievements})
}

// GetMyAchievements 获取我的成就进度
func (h *AchievementHandler) GetMyAchievements(c *gin.Context) {
	userID, _ := c.Get("userID")

	achievements, err := h.achievementService.GetUserAchievements(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"achievements": achievements})
}

// ClaimAchievementReward 领取成就奖励
func (h *AchievementHandler) ClaimAchievementReward(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	achievementID, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.achievementService.ClaimAchievementReward(userID.(uint), uint(achievementID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "领取成功"})
}

// === 邮件系统 ===

// GetMails 获取邮件列表
func (h *AchievementHandler) GetMails(c *gin.Context) {
	userID, _ := c.Get("userID")
	limitStr := c.DefaultQuery("limit", "50")
	limit, _ := strconv.Atoi(limitStr)

	mails, err := h.achievementService.GetUserMails(userID.(uint), limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	unreadCount, _ := h.achievementService.GetUnreadMailCount(userID.(uint))

	c.JSON(http.StatusOK, gin.H{
		"mails":        mails,
		"unread_count": unreadCount,
	})
}

// ReadMail 阅读邮件
func (h *AchievementHandler) ReadMail(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	mailID, _ := strconv.ParseUint(idStr, 10, 32)

	mail, err := h.achievementService.ReadMail(userID.(uint), uint(mailID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"mail": mail})
}

// ClaimMailAttachments 领取邮件附件
func (h *AchievementHandler) ClaimMailAttachments(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	mailID, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.achievementService.ClaimMailAttachments(userID.(uint), uint(mailID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "领取成功"})
}

// DeleteMail 删除邮件
func (h *AchievementHandler) DeleteMail(c *gin.Context) {
	userID, _ := c.Get("userID")
	idStr := c.Param("id")
	mailID, _ := strconv.ParseUint(idStr, 10, 32)

	err := h.achievementService.DeleteMail(userID.(uint), uint(mailID))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

// === 签到系统 ===

// Checkin 签到
func (h *AchievementHandler) Checkin(c *gin.Context) {
	userID, _ := c.Get("userID")

	reward, err := h.achievementService.Checkin(userID.(uint))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "签到成功",
		"reward":  reward,
	})
}

// GetMonthCheckins 获取本月签到记录
func (h *AchievementHandler) GetMonthCheckins(c *gin.Context) {
	userID, _ := c.Get("userID")

	checkins, err := h.achievementService.GetMonthCheckins(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"checkins": checkins})
}

// === 排行榜 ===

// GetRankings 获取排行榜
func (h *AchievementHandler) GetRankings(c *gin.Context) {
	rankType := c.DefaultQuery("type", "gold")
	limitStr := c.DefaultQuery("limit", "100")
	limit, _ := strconv.Atoi(limitStr)

	rankings, err := h.achievementService.GetRankings(rankType, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"rankings": rankings})
}
