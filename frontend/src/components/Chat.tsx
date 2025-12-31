import { useState, useEffect, useRef } from 'react'
import './Chat.css'
import { useToast } from './Toast'
import { api } from '../services/api'
import { ws } from '../services/websocket'
import type { ChatMessage } from '../types'

let chatMessagesLoaded = false
let chatMessagesCache: ChatMessage[] = []

export default function Chat() {
  const { showToast } = useToast()
  const [messages, setMessages] = useState<ChatMessage[]>(chatMessagesCache)
  const [input, setInput] = useState('')
  const [isOpen, setIsOpen] = useState(true)
  const [sending, setSending] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    // 加载历史消息（使用缓存避免重复请求）
    if (!chatMessagesLoaded) {
      api.getChatMessages().then(data => {
        const msgs = data.messages || []
        setMessages(msgs)
        chatMessagesCache = msgs
        chatMessagesLoaded = true
      }).catch(() => {})
    }

    // 监听新消息
    const unsub = ws.on('chat', (data) => {
      const msg = data as unknown as ChatMessage
      setMessages(prev => {
        const newMsgs = [...prev, msg]
        chatMessagesCache = newMsgs
        return newMsgs
      })
    })

    return unsub
  }, [])

  useEffect(() => {
    // 滚动到底部
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  const sendMessage = async () => {
    if (!input.trim() || sending) return
    setSending(true)
    try {
      await api.sendChatMessage('world', input.trim())
      setInput('')
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setSending(false)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') sendMessage()
  }

  return (
    <div className={`chat-container ${isOpen ? 'open' : 'closed'}`}>
      <div className="chat-header" onClick={() => setIsOpen(!isOpen)}>
        <span>💬 世界聊天</span>
        <span className="chat-toggle">{isOpen ? '▼' : '▲'}</span>
      </div>
      {isOpen && (
        <>
          <div className="chat-messages">
            {messages.length === 0 ? (
              <div className="chat-msg system">暂无消息</div>
            ) : (
              messages.map(msg => (
                <div key={msg.id} className="chat-msg">
                  <span className="chat-time">[{new Date(msg.created_at).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })}]</span>
                  <span className="chat-user">{msg.nickname || msg.user?.nickname || '匿名'}:</span>
                  <span className="chat-text">{msg.content}</span>
                </div>
              ))
            )}
            <div ref={messagesEndRef} />
          </div>
          <div className="chat-input-box">
            <input
              type="text"
              className="chat-input"
              placeholder="输入消息..."
              value={input}
              onChange={e => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={sending}
            />
            <button className="chat-send" onClick={sendMessage} disabled={sending}>
              {sending ? '...' : '发送'}
            </button>
          </div>
        </>
      )}
    </div>
  )
}
