package ws

import (
	"log"
	"sync"
)

// Hub 管理所有 WebSocket 连接
type Hub struct {
	// 所有已连接的客户端
	clients map[*Client]bool

	// 用户ID到客户端的映射，支持一个用户多个连接
	userClients map[string]map[*Client]bool

	// 注册请求
	register chan *Client

	// 注销请求
	unregister chan *Client

	// 广播消息
	broadcast chan *Message

	// 互斥锁
	mu sync.RWMutex
}

// 全局 Hub 实例
var GameHub *Hub

// NewHub 创建新的 Hub
func NewHub() *Hub {
	return &Hub{
		clients:     make(map[*Client]bool),
		userClients: make(map[string]map[*Client]bool),
		register:    make(chan *Client),
		unregister:  make(chan *Client),
		broadcast:   make(chan *Message),
	}
}

// Init 初始化全局 Hub
func Init() {
	GameHub = NewHub()
	go GameHub.Run()
	log.Println("WebSocket Hub 已启动")
}

// Run 运行 Hub 主循环
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.registerClient(client)

		case client := <-h.unregister:
			h.unregisterClient(client)

		case message := <-h.broadcast:
			h.broadcastMessage(message)
		}
	}
}

// registerClient 注册客户端
func (h *Hub) registerClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	h.clients[client] = true

	// 添加到用户映射
	if client.UserID != "" {
		if h.userClients[client.UserID] == nil {
			h.userClients[client.UserID] = make(map[*Client]bool)
		}
		h.userClients[client.UserID][client] = true
	}

	log.Printf("客户端连接: UserID=%s, 当前连接数=%d", client.UserID, len(h.clients))
}

// unregisterClient 注销客户端
func (h *Hub) unregisterClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.clients[client]; ok {
		delete(h.clients, client)
		close(client.send)

		// 从用户映射中移除
		if client.UserID != "" {
			if clients, ok := h.userClients[client.UserID]; ok {
				delete(clients, client)
				if len(clients) == 0 {
					delete(h.userClients, client.UserID)
				}
			}
		}

		log.Printf("客户端断开: UserID=%s, 当前连接数=%d", client.UserID, len(h.clients))
	}
}

// broadcastMessage 广播消息给所有客户端
func (h *Hub) broadcastMessage(message *Message) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	data, err := message.ToJSON()
	if err != nil {
		log.Printf("消息序列化失败: %v", err)
		return
	}

	for client := range h.clients {
		select {
		case client.send <- data:
		default:
			// 发送缓冲区满，跳过
		}
	}
}

// SendToUser 发送消息给指定用户
func (h *Hub) SendToUser(userID string, message *Message) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	clients, ok := h.userClients[userID]
	if !ok {
		return
	}

	data, err := message.ToJSON()
	if err != nil {
		log.Printf("消息序列化失败: %v", err)
		return
	}

	for client := range clients {
		select {
		case client.send <- data:
		default:
			// 发送缓冲区满，跳过
		}
	}
}

// Broadcast 广播消息
func (h *Hub) Broadcast(message *Message) {
	h.broadcast <- message
}

// GetOnlineCount 获取在线人数
func (h *Hub) GetOnlineCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// GetOnlineUsers 获取在线用户ID列表
func (h *Hub) GetOnlineUsers() []string {
	h.mu.RLock()
	defer h.mu.RUnlock()

	users := make([]string, 0, len(h.userClients))
	for userID := range h.userClients {
		users = append(users, userID)
	}
	return users
}
