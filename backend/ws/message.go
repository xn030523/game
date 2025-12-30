package ws

import (
	"encoding/json"
	"time"
)

// 消息类型常量
const (
	// 系统消息
	MsgTypeConnected = "connected" // 连接成功
	MsgTypeError     = "error"     // 错误
	MsgTypePing      = "ping"      // 心跳
	MsgTypePong      = "pong"      // 心跳响应

	// 聊天消息
	MsgTypeChat       = "chat"        // 世界聊天
	MsgTypeChatPrivate = "chat_private" // 私聊

	// 玩家消息
	MsgTypePlayerJoin  = "player_join"  // 玩家加入
	MsgTypePlayerLeave = "player_leave" // 玩家离开
	MsgTypePlayerList  = "player_list"  // 在线玩家列表

	// 通知消息
	MsgTypeNotify       = "notify"        // 通用通知
	MsgTypeMailNew      = "mail_new"      // 新邮件
	MsgTypeFriendReq    = "friend_request" // 好友申请
	MsgTypeFriendMsg    = "friend_message" // 好友消息
	MsgTypeAuctionBid   = "auction_bid"   // 拍卖被出价
	MsgTypeAuctionEnd   = "auction_end"   // 拍卖结束
	MsgTypeStockAlert   = "stock_alert"   // 股票预警
	MsgTypeLiquidation  = "liquidation"   // 强平通知
	MsgTypeAchievement  = "achievement"   // 成就达成
	MsgTypeLevelUp      = "level_up"      // 升级通知

	// 市场消息
	MsgTypeMarketUpdate   = "market_update"   // 市场价格更新
	MsgTypeBlackmarketNew = "blackmarket_new" // 黑市刷新
	MsgTypeStockPrice     = "stock_price"     // 股票价格更新

	// 农场消息
	MsgTypeCropMature = "crop_mature" // 作物成熟
	MsgTypeCropStolen = "crop_stolen" // 作物被偷
)

// Message WebSocket 消息结构
type Message struct {
	Type      string                 `json:"type"`                 // 消息类型
	Data      map[string]interface{} `json:"data,omitempty"`       // 消息数据
	Timestamp int64                  `json:"timestamp,omitempty"`  // 时间戳
	RequestID string                 `json:"request_id,omitempty"` // 请求ID（用于请求-响应模式）
}

// NewMessage 创建新消息
func NewMessage(msgType string, data map[string]interface{}) *Message {
	return &Message{
		Type:      msgType,
		Data:      data,
		Timestamp: time.Now().UnixMilli(),
	}
}

// ToJSON 转换为 JSON
func (m *Message) ToJSON() ([]byte, error) {
	if m.Timestamp == 0 {
		m.Timestamp = time.Now().UnixMilli()
	}
	return json.Marshal(m)
}

// ParseMessage 解析 JSON 消息
func ParseMessage(data []byte) (*Message, error) {
	var msg Message
	err := json.Unmarshal(data, &msg)
	if err != nil {
		return nil, err
	}
	return &msg, nil
}

// GetString 从 Data 中获取字符串
func (m *Message) GetString(key string) string {
	if val, ok := m.Data[key]; ok {
		if str, ok := val.(string); ok {
			return str
		}
	}
	return ""
}

// GetInt 从 Data 中获取整数
func (m *Message) GetInt(key string) int {
	if val, ok := m.Data[key]; ok {
		switch v := val.(type) {
		case float64:
			return int(v)
		case int:
			return v
		}
	}
	return 0
}

// GetFloat 从 Data 中获取浮点数
func (m *Message) GetFloat(key string) float64 {
	if val, ok := m.Data[key]; ok {
		if f, ok := val.(float64); ok {
			return f
		}
	}
	return 0
}

// GetBool 从 Data 中获取布尔值
func (m *Message) GetBool(key string) bool {
	if val, ok := m.Data[key]; ok {
		if b, ok := val.(bool); ok {
			return b
		}
	}
	return false
}

// MessageHandler 消息处理函数类型
type MessageHandler func(client *Client, msg *Message)

// 消息处理函数映射
var messageHandlers = map[string]MessageHandler{
	MsgTypePing:       handlePing,
	MsgTypeChat:       handleChat,
	MsgTypePlayerList: handlePlayerList,
}

// RegisterHandler 注册消息处理函数
func RegisterHandler(msgType string, handler MessageHandler) {
	messageHandlers[msgType] = handler
}

// handlePing 处理心跳消息
func handlePing(client *Client, msg *Message) {
	client.Send(&Message{
		Type:      MsgTypePong,
		RequestID: msg.RequestID,
		Data: map[string]interface{}{
			"server_time": time.Now().UnixMilli(),
		},
	})
}

// handleChat 处理聊天消息
func handleChat(client *Client, msg *Message) {
	content := msg.GetString("content")
	if content == "" {
		client.SendError("empty_message", "消息内容不能为空")
		return
	}

	// 广播聊天消息
	GameHub.Broadcast(&Message{
		Type: MsgTypeChat,
		Data: map[string]interface{}{
			"user_id": client.UserID,
			"content": content,
		},
	})
}

// handlePlayerList 处理获取在线玩家列表
func handlePlayerList(client *Client, msg *Message) {
	users := GameHub.GetOnlineUsers()
	client.Send(&Message{
		Type:      MsgTypePlayerList,
		RequestID: msg.RequestID,
		Data: map[string]interface{}{
			"players": users,
			"count":   len(users),
		},
	})
}
