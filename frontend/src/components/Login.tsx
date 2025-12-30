import { useState } from 'react'
import { api } from '../services/api'
import './Login.css'

interface LoginProps {
  onSuccess: () => void
}

export default function Login({ onSuccess }: LoginProps) {
  const [username, setUsername] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!username.trim()) {
      setError('请输入账户名')
      return
    }

    setLoading(true)
    setError('')

    try {
      const data = await api.devLogin(username.trim())
      api.setToken(data.token)
      onSuccess()
    } catch (err) {
      setError((err as Error).message || '登录失败')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="login-overlay">
      <div className="login-box">
        <h2>🌾 农场游戏</h2>
        <p className="login-tip">开发模式：输入任意账户名即可登录</p>
        
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="输入账户名"
            value={username}
            onChange={e => setUsername(e.target.value)}
            autoFocus
          />
          {error && <p className="login-error">{error}</p>}
          <button type="submit" disabled={loading}>
            {loading ? '登录中...' : '进入游戏'}
          </button>
        </form>
      </div>
    </div>
  )
}
