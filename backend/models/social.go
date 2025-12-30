package models

import "time"

// Friendship 好友关系表
type Friendship struct {
	ID         uint       `json:"id" gorm:"primaryKey"`
	UserID     uint       `json:"user_id" gorm:"not null;index"`
	FriendID   uint       `json:"friend_id" gorm:"not null"`
	Status     string     `json:"status" gorm:"type:enum('pending','accepted','blocked');default:'pending'"`
	CreatedAt  time.Time  `json:"created_at"`
	AcceptedAt *time.Time `json:"accepted_at"`

	User   User `json:"user" gorm:"foreignKey:UserID"`
	Friend User `json:"friend" gorm:"foreignKey:FriendID"`
}

func (Friendship) TableName() string {
	return "friendships"
}

// FriendMessage 好友消息表
type FriendMessage struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	FromUserID uint      `json:"from_user_id" gorm:"not null"`
	ToUserID   uint      `json:"to_user_id" gorm:"not null;index"`
	Content    string    `json:"content" gorm:"type:text;not null"`
	IsRead     bool      `json:"is_read" gorm:"default:false"`
	CreatedAt  time.Time `json:"created_at"`

	FromUser User `json:"from_user" gorm:"foreignKey:FromUserID"`
	ToUser   User `json:"to_user" gorm:"foreignKey:ToUserID"`
}

func (FriendMessage) TableName() string {
	return "friend_messages"
}

// FriendInteraction 好友互动记录
type FriendInteraction struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	UserID     uint      `json:"user_id" gorm:"not null;index"`
	FriendID   uint      `json:"friend_id" gorm:"not null"`
	Action     string    `json:"action" gorm:"type:enum('steal','gift');not null"`
	Reward     int       `json:"reward" gorm:"default:0"`
	TargetSlot *int      `json:"target_slot"`
	CreatedAt  time.Time `json:"created_at"`

	User   User `json:"user" gorm:"foreignKey:UserID"`
	Friend User `json:"friend" gorm:"foreignKey:FriendID"`
}

func (FriendInteraction) TableName() string {
	return "friend_interactions"
}

// ChatMessage 聊天记录表
type ChatMessage struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"not null;index"`
	Channel   string    `json:"channel" gorm:"type:enum('world','trade','guild');default:'world'"`
	Content   string    `json:"content" gorm:"type:text;not null"`
	CreatedAt time.Time `json:"created_at"`

	User User `json:"user" gorm:"foreignKey:UserID"`
}

func (ChatMessage) TableName() string {
	return "chat_messages"
}
