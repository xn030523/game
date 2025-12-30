import { useState, useEffect } from 'react'
import Modal from './Modal'
import { useUser } from '../contexts/UserContext'
import { api } from '../services/api'
import type { Seed } from '../types'

interface MarketProps {
  isOpen: boolean
  onClose: () => void
}

export default function Market({ isOpen, onClose }: MarketProps) {
  const { user, refreshProfile, refreshInventory } = useUser()
  const [seeds, setSeeds] = useState<Seed[]>([])
  const [loading, setLoading] = useState(false)
  const [buying, setBuying] = useState<number | null>(null)
  const [quantities, setQuantities] = useState<Record<number, number>>({})

  useEffect(() => {
    if (isOpen) {
      setLoading(true)
      api.getSeeds()
        .then(data => setSeeds(data.seeds))
        .finally(() => setLoading(false))
    }
  }, [isOpen])

  const handleBuy = async (seedId: number) => {
    const quantity = quantities[seedId] || 1
    setBuying(seedId)
    try {
      await api.buySeed(seedId, quantity)
      alert('购买成功！')
      refreshProfile()
      refreshInventory()
    } catch (e) {
      alert((e as Error).message)
    } finally {
      setBuying(null)
    }
  }

  return (
    <Modal title="种子商店" isOpen={isOpen} onClose={onClose}>
      <div style={{ marginBottom: 16, color: '#ffd700' }}>
        当前金币: {user?.gold.toFixed(2) || 0}
      </div>

      {loading ? (
        <p style={{ textAlign: 'center' }}>加载中...</p>
      ) : (
        <div className="grid grid-2">
          {seeds.map(seed => (
            <div key={seed.id} className="card">
              <div className="card-header">
                <img 
                  src={`${seed.icon}/0.png`} 
                  alt={seed.name}
                  style={{ width: 32, height: 32, imageRendering: 'pixelated' }}
                />
                <h4 className="card-title" style={{ flex: 1, marginLeft: 8 }}>{seed.name}</h4>
                <span style={{ color: seed.unlock_level <= (user?.level || 1) ? '#4caf50' : '#f44336' }}>
                  Lv.{seed.unlock_level}
                </span>
              </div>
              <p style={{ fontSize: '0.85rem', color: '#aaa', marginBottom: 8 }}>
                {seed.description}
              </p>
              <p style={{ fontSize: '0.9rem', marginBottom: 8 }}>
                价格: <span style={{ color: '#ffd700' }}>{seed.base_price}</span> 金币
              </p>
              <p style={{ fontSize: '0.85rem', color: '#888', marginBottom: 12 }}>
                生长时间: {Math.floor(seed.growth_time / 60)}分钟
              </p>
              
              <div style={{ display: 'flex', gap: 8 }}>
                <input
                  type="number"
                  min="1"
                  max="99"
                  value={quantities[seed.id] || 1}
                  onChange={e => setQuantities({ ...quantities, [seed.id]: parseInt(e.target.value) || 1 })}
                  style={{
                    width: 60,
                    padding: '6px 8px',
                    border: '2px solid #5c3a1e',
                    borderRadius: 4,
                    background: 'rgba(0,0,0,0.3)',
                    color: '#fff',
                    textAlign: 'center'
                  }}
                />
                <button
                  className="btn btn-primary"
                  style={{ flex: 1 }}
                  disabled={buying === seed.id || seed.unlock_level > (user?.level || 1)}
                  onClick={() => handleBuy(seed.id)}
                >
                  {buying === seed.id ? '购买中...' : '购买'}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </Modal>
  )
}
