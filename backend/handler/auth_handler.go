package handler

import (
	"farm-game/middleware"
	"farm-game/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	userService *service.UserService
}

func NewAuthHandler() *AuthHandler {
	return &AuthHandler{
		userService: service.NewUserService(),
	}
}

// LinuxdoCallback LinuxDo OAuth回调
func (h *AuthHandler) LinuxdoCallback(c *gin.Context) {
	var req struct {
		LinuxdoID string `json:"linuxdo_id" binding:"required"`
		Nickname  string `json:"nickname" binding:"required"`
		Avatar    string `json:"avatar"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "参数错误"})
		return
	}

	user, isNew, err := h.userService.LoginOrRegister(req.LinuxdoID, req.Nickname, req.Avatar)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "登录失败"})
		return
	}

	token, err := middleware.GenerateToken(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成token失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token":  token,
		"user":   user,
		"is_new": isNew,
	})
}

// DevLogin 开发环境登录（直接用账户名）
func (h *AuthHandler) DevLogin(c *gin.Context) {
	var req struct {
		Username string `json:"username" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请输入账户名"})
		return
	}

	// 用 username 作为 linuxdo_id，自动注册或登录
	user, isNew, err := h.userService.LoginOrRegister(req.Username, req.Username, "")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "登录失败"})
		return
	}

	token, err := middleware.GenerateToken(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成token失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token":  token,
		"user":   user,
		"is_new": isNew,
	})
}
