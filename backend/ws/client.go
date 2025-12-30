package ws

import (
	"log"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
)

const (
	// 写入等待时间
	writeWait = 10 * time.Second

	// 读取 pong 的等待时间
	pongWait = 60 * time.Second

	// ping 发送间隔（必须小于 pongWait）
	pingPeriod = (pongWait * 9) / 10

	// 最大消息大小
	maxMessageSize = 4096

	// 发送缓冲区大小
	sendBufferSize = 256
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	// 允许所有来源（生产环境应该限制）
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// Client WebSocket 客户端连接
type Client struct {
	hub *Hub

	// WebSocket 连接
	conn *websocket.Conn

	// 发送消息的缓冲通道
	send chan []byte

	// 用户ID
	UserID string

	// 额外数据
	Data map[string]interface{}
}

// NewClient 创建新的客户端
func NewClient(hub *Hub, conn *websocket.Conn, userID string) *Client {
	return &Client{
		hub:    hub,
		conn:   conn,
		send:   make(chan []byte, sendBufferSize),
		UserID: userID,
		Data:   make(map[string]interface{}),
	}
}

// readPump 从 WebSocket 读取消息
func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, data, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket 读取错误: %v", err)
			}
			break
		}

		// 解析并处理消息
		c.handleMessage(data)
	}
}

// writePump 向 WebSocket 写入消息
func (c *Client) writePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				// Hub 关闭了通道
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// 批量发送队列中的消息
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte{'\n'})
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// handleMessage 处理收到的消息
func (c *Client) handleMessage(data []byte) {
	msg, err := ParseMessage(data)
	if err != nil {
		log.Printf("消息解析失败: %v", err)
		c.SendError("invalid_message", "消息格式错误")
		return
	}

	// 根据消息类型分发处理
	handler, ok := messageHandlers[msg.Type]
	if !ok {
		log.Printf("未知消息类型: %s", msg.Type)
		c.SendError("unknown_type", "未知的消息类型")
		return
	}

	handler(c, msg)
}

// Send 发送消息给客户端
func (c *Client) Send(msg *Message) {
	data, err := msg.ToJSON()
	if err != nil {
		log.Printf("消息序列化失败: %v", err)
		return
	}

	select {
	case c.send <- data:
	default:
		// 缓冲区满，关闭连接
		c.hub.unregister <- c
	}
}

// SendError 发送错误消息
func (c *Client) SendError(code string, message string) {
	c.Send(&Message{
		Type: MsgTypeError,
		Data: map[string]interface{}{
			"code":    code,
			"message": message,
		},
	})
}

// ServeWs 处理 WebSocket 连接请求
func ServeWs(hub *Hub, w http.ResponseWriter, r *http.Request, userID string) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket 升级失败: %v", err)
		return
	}

	client := NewClient(hub, conn, userID)
	hub.register <- client

	// 启动读写协程
	go client.writePump()
	go client.readPump()

	// 发送连接成功消息
	client.Send(&Message{
		Type: MsgTypeConnected,
		Data: map[string]interface{}{
			"user_id": userID,
			"message": "连接成功",
		},
	})
}
