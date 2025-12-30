import type { WSMessage } from '../types'

type MessageHandler = (data: Record<string, unknown>) => void

class WebSocketService {
  private ws: WebSocket | null = null
  private handlers: Map<string, Set<MessageHandler>> = new Map()
  private reconnectTimer: number | null = null
  private reconnectAttempts = 0
  private maxReconnectAttempts = 5

  connect(token: string) {
    if (this.ws?.readyState === WebSocket.OPEN) return

    const wsUrl = import.meta.env.VITE_WS_URL || 'ws://localhost:8080/ws'
    this.ws = new WebSocket(`${wsUrl}?token=${token}`)

    this.ws.onopen = () => {
      console.log('WebSocket 已连接')
      this.reconnectAttempts = 0
    }

    this.ws.onmessage = (event) => {
      try {
        const message: WSMessage = JSON.parse(event.data)
        this.dispatch(message.type, message.data)
      } catch (e) {
        console.error('WebSocket 消息解析失败:', e)
      }
    }

    this.ws.onclose = () => {
      console.log('WebSocket 已断开')
      this.tryReconnect(token)
    }

    this.ws.onerror = (error) => {
      console.error('WebSocket 错误:', error)
    }
  }

  private tryReconnect(token: string) {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log('WebSocket 重连次数已达上限')
      return
    }

    this.reconnectAttempts++
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000)
    
    this.reconnectTimer = window.setTimeout(() => {
      console.log(`WebSocket 重连中... (第 ${this.reconnectAttempts} 次)`)
      this.connect(token)
    }, delay)
  }

  disconnect() {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = null
    }
    if (this.ws) {
      this.ws.close()
      this.ws = null
    }
  }

  send(type: string, data: Record<string, unknown> = {}) {
    if (this.ws?.readyState !== WebSocket.OPEN) {
      console.warn('WebSocket 未连接')
      return
    }

    this.ws.send(JSON.stringify({
      type,
      data,
      timestamp: Date.now(),
    }))
  }

  on(type: string, handler: MessageHandler) {
    if (!this.handlers.has(type)) {
      this.handlers.set(type, new Set())
    }
    this.handlers.get(type)!.add(handler)

    return () => {
      this.handlers.get(type)?.delete(handler)
    }
  }

  off(type: string, handler: MessageHandler) {
    this.handlers.get(type)?.delete(handler)
  }

  private dispatch(type: string, data: Record<string, unknown>) {
    const handlers = this.handlers.get(type)
    if (handlers) {
      handlers.forEach(handler => handler(data))
    }

    // 通用消息处理
    const allHandlers = this.handlers.get('*')
    if (allHandlers) {
      allHandlers.forEach(handler => handler({ type, ...data }))
    }
  }
}

export const ws = new WebSocketService()
