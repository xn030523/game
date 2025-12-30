import { useState } from 'react'
import './TopBar.css'

const menuItems = [
  { id: 'warehouse', name: '仓库', icon: '📦' },
  { id: 'market', name: '交易市场', icon: '🏪' },
  { id: 'auction', name: '拍卖会', icon: '🔨' },
  { id: 'stock', name: '股票交易所', icon: '📈' },
  { id: 'charity', name: '余额转换公益站', icon: '❤️' },
  { id: 'ranking', name: '排行榜', icon: '🏆' },
  { id: 'blackmarket', name: '黑市商人', icon: '🎭' },
]

export default function TopBar() {
  const [active, setActive] = useState<string | null>(null)

  return (
    <div className="topbar-container">
      <div className="topbar-left">
        <span className="topbar-logo">🌾 农场游戏</span>
      </div>
      <div className="topbar-menu">
        {menuItems.map(item => (
          <button
            key={item.id}
            className={`topbar-btn ${active === item.id ? 'active' : ''}`}
            onClick={() => setActive(active === item.id ? null : item.id)}
          >
            <span>{item.icon}</span>
            <span className="btn-text">{item.name}</span>
          </button>
        ))}
      </div>
      <div className="topbar-right">
        <div className="topbar-user">
          <img src="/characters/character_green_idle.png" className="topbar-avatar" />
          <span>农场主</span>
        </div>
        <span className="topbar-info">⭐ Lv.1</span>
        <span className="topbar-coin">💰 1000</span>
      </div>
    </div>
  )
}
