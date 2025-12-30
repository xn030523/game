package models

import "time"

// Achievement 成就定义表
type Achievement struct {
	ID             uint   `json:"id" gorm:"primaryKey"`
	Name           string `json:"name" gorm:"not null"`
	Description    string `json:"description"`
	Icon           string `json:"icon"`
	Category       string `json:"category" gorm:"type:enum('plant','trade','social','collect','special');not null"`
	ConditionType  string `json:"condition_type" gorm:"not null"`
	ConditionValue int    `json:"condition_value" gorm:"not null"`
	RewardType     string `json:"reward_type" gorm:"type:enum('gold','item');not null"`
	RewardValue    int    `json:"reward_value" gorm:"not null"`
	RewardItemID   *uint  `json:"reward_item_id"`
	Points         int    `json:"points" gorm:"default:10"`
	IsHidden       bool   `json:"is_hidden" gorm:"default:false"`
	SortOrder      int    `json:"sort_order" gorm:"default:0"`
	CreatedAt      time.Time `json:"created_at"`
}

func (Achievement) TableName() string {
	return "achievements"
}

// UserAchievement 用户成就表
type UserAchievement struct {
	ID            uint       `json:"id" gorm:"primaryKey"`
	UserID        uint       `json:"user_id" gorm:"not null;index"`
	AchievementID uint       `json:"achievement_id" gorm:"not null"`
	Progress      int        `json:"progress" gorm:"default:0"`
	IsCompleted   bool       `json:"is_completed" gorm:"default:false"`
	IsClaimed     bool       `json:"is_claimed" gorm:"default:false"`
	CompletedAt   *time.Time `json:"completed_at"`
	ClaimedAt     *time.Time `json:"claimed_at"`

	Achievement Achievement `json:"achievement" gorm:"foreignKey:AchievementID"`
}

func (UserAchievement) TableName() string {
	return "user_achievements"
}

// Mail 邮件表
type Mail struct {
	ID          uint       `json:"id" gorm:"primaryKey"`
	UserID      uint       `json:"user_id" gorm:"not null;index"`
	Title       string     `json:"title" gorm:"not null"`
	Content     string     `json:"content" gorm:"type:text"`
	MailType    string     `json:"mail_type" gorm:"type:enum('system','reward','trade','friend');default:'system'"`
	Attachments string     `json:"attachments" gorm:"type:json"`
	IsRead      bool       `json:"is_read" gorm:"default:false"`
	IsClaimed   bool       `json:"is_claimed" gorm:"default:false"`
	ExpireAt    *time.Time `json:"expire_at"`
	CreatedAt   time.Time  `json:"created_at"`
}

func (Mail) TableName() string {
	return "mails"
}

// DailyCheckin 签到记录表
type DailyCheckin struct {
	ID            uint      `json:"id" gorm:"primaryKey"`
	UserID        uint      `json:"user_id" gorm:"not null;index"`
	CheckinDate   string    `json:"checkin_date" gorm:"type:date;not null"`
	DayOfMonth    int       `json:"day_of_month" gorm:"not null"`
	RewardClaimed bool      `json:"reward_claimed" gorm:"default:true"`
	CreatedAt     time.Time `json:"created_at"`
}

func (DailyCheckin) TableName() string {
	return "daily_checkins"
}

// Ranking 排行榜缓存表
type Ranking struct {
	ID           uint      `json:"id" gorm:"primaryKey"`
	RankType     string    `json:"rank_type" gorm:"type:enum('gold','level','contribution','achievement','harvest','trade');not null"`
	UserID       uint      `json:"user_id" gorm:"not null"`
	RankPosition int       `json:"rank_position" gorm:"not null"`
	Score        float64   `json:"score" gorm:"type:decimal(20,2);not null"`
	UpdatedAt    time.Time `json:"updated_at"`

	User User `json:"user" gorm:"foreignKey:UserID"`
}

func (Ranking) TableName() string {
	return "rankings"
}
