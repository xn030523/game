import './TopBar.css'
import { useUser } from '../contexts/UserContext'
import type { ModalType } from '../App'

const menuItems: { id: ModalType; name: string; icon: string }[] = [
  { id: 'warehouse', name: '仓库', icon: '📦' },
  { id: 'market', name: '交易市场', icon: '🏪' },
  { id: 'auction', name: '拍卖会', icon: '🔨' },
  { id: 'stock', name: '股票交易所', icon: '📈' },
  { id: 'charity', name: '余额转换公益站', icon: '❤️' },
  { id: 'ranking', name: '排行榜', icon: '🏆' },
  { id: 'blackmarket', name: '黑市商人', icon: '🎭' },
]

interface TopBarProps {
  onMenuClick: (modal: ModalType) => void
}

export default function TopBar({ onMenuClick }: TopBarProps) {
  const { user } = useUser()

  return (
    <div className="topbar-container">
      <div className="topbar-left">
        <span className="topbar-logo">🌾 农场游戏</span>
      </div>
      <div className="topbar-menu">
        {menuItems.map(item => (
          <button
            key={item.id}
            className="topbar-btn"
            onClick={() => onMenuClick(item.id)}
          >
            <span>{item.icon}</span>
            <span className="btn-text">{item.name}</span>
          </button>
        ))}
      </div>
      <div className="topbar-right">
        <div className="topbar-user">
          <img src={user?.avatar || '/characters/character_green_idle.png'} className="topbar-avatar" />
          <span>{user?.nickname || '游客'}</span>
        </div>
        <span className="topbar-info">⭐ Lv.{user?.level || 1}</span>
        <span className="topbar-coin">💰 {user?.gold?.toFixed(0) || 0}</span>
      </div>
    </div>
  )
}
