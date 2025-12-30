import { useState } from 'react'
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
  const { user, stats } = useUser()
  const [showProfile, setShowProfile] = useState(false)

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
        <div className="topbar-user" onClick={() => setShowProfile(!showProfile)} style={{ cursor: 'pointer' }}>
          <img src={user?.avatar || '/characters/character_green_idle.png'} className="topbar-avatar" />
          <span>{user?.nickname || '游客'}</span>
        </div>
        <span className="topbar-info">⭐ Lv.{user?.level || 1}</span>
        <span className="topbar-coin">💰 {user?.gold?.toFixed(2) || 0}</span>
      </div>

      {showProfile && (
        <div className="profile-panel" onClick={() => setShowProfile(false)}>
          <div className="profile-content" onClick={e => e.stopPropagation()}>
            <h3>👤 个人信息</h3>
            <div className="profile-row"><span>昵称:</span><span>{user?.nickname}</span></div>
            <div className="profile-row"><span>等级:</span><span>Lv.{user?.level}</span></div>
            <div className="profile-row"><span>金币:</span><span>{user?.gold?.toFixed(2)}</span></div>
            <div className="profile-row"><span>农田格数:</span><span>{user?.farm_slots}</span></div>
            <div className="profile-row"><span>贡献值:</span><span>{user?.contribution}</span></div>
            <div className="profile-row"><span>成就点数:</span><span>{user?.achievement_points}</span></div>
            {stats && (
              <>
                <h4 style={{ marginTop: 12, color: '#ffd700' }}>📊 统计</h4>
                <div className="profile-row"><span>种植次数:</span><span>{stats.total_planted}</span></div>
                <div className="profile-row"><span>收获次数:</span><span>{stats.total_harvested}</span></div>
                <div className="profile-row"><span>登录天数:</span><span>{stats.login_days}</span></div>
                <div className="profile-row"><span>连续登录:</span><span>{stats.consecutive_days}天</span></div>
              </>
            )}
            <button className="profile-close" onClick={() => setShowProfile(false)}>关闭</button>
          </div>
        </div>
      )}
    </div>
  )
}
