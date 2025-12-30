import { useState } from 'react'
import './Chat.css'

interface Message {
  id: number
  user: string
  text: string
  time: string
}

const mockMessages: Message[] = [
  { id: 1, user: '系统', text: '欢迎来到农场游戏！', time: '10:00' },
  { id: 2, user: '农场主A', text: '大家好！', time: '10:01' },
  { id: 3, user: '农场主B', text: '今天收成不错', time: '10:02' },
]

export default function Chat() {
  const [messages, setMessages] = useState<Message[]>(mockMessages)
  const [input, setInput] = useState('')
  const [isOpen, setIsOpen] = useState(true)

  const sendMessage = () => {
    if (!input.trim()) return
    const newMsg: Message = {
      id: Date.now(),
      user: '农场主',
      text: input,
      time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
    }
    setMessages([...messages, newMsg])
    setInput('')
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
            {messages.map(msg => (
              <div key={msg.id} className={`chat-msg ${msg.user === '系统' ? 'system' : ''}`}>
                <span className="chat-time">[{msg.time}]</span>
                <span className="chat-user">{msg.user}:</span>
                <span className="chat-text">{msg.text}</span>
              </div>
            ))}
          </div>
          <div className="chat-input-box">
            <input
              type="text"
              className="chat-input"
              placeholder="输入消息..."
              value={input}
              onChange={e => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
            />
            <button className="chat-send" onClick={sendMessage}>发送</button>
          </div>
        </>
      )}
    </div>
  )
}
