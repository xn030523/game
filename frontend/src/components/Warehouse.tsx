import { useState, useEffect, useRef } from 'react'
import Modal from './Modal'
import { useUser } from '../contexts/UserContext'
import { useToast } from './Toast'
import { api } from '../services/api'
import { dataCache } from '../stores/dataCache'
import type { Seed } from '../types'

interface WarehouseProps {
  isOpen: boolean
  onClose: () => void
}

export default function Warehouse({ isOpen, onClose }: WarehouseProps) {
  const { inventory, refreshInventory } = useUser()
  const { showToast } = useToast()
  const [tab, setTab] = useState<'seed' | 'crop'>('seed')
  const [seeds, setSeeds] = useState<Seed[]>([])
  const [selling, setSelling] = useState<number | null>(null)

  const dataLoaded = useRef(false)

  useEffect(() => {
    if (isOpen && !dataLoaded.current) {
      dataCache.getSeeds().then(data => {
        setSeeds(data)
        dataLoaded.current = true
      })
    }
  }, [isOpen])

  const seedItems = inventory.filter(i => i.item_type === 'seed' && i.quantity > 0)
  const cropItems = inventory.filter(i => i.item_type === 'crop' && i.quantity > 0)

  const getSeedInfo = (seedId: number) => seeds.find(s => s.id === seedId)

  const handleSell = async (cropId: number, quantity: number) => {
    setSelling(cropId)
    try {
      const result = await api.sellCrop(cropId, quantity)
      showToast(`出售成功！+${result.earning} 金币`, 'success')
      refreshInventory()
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setSelling(null)
    }
  }

  return (
    <Modal title="仓库" isOpen={isOpen} onClose={onClose}>
      <div className="tabs">
        <button className={`tab ${tab === 'seed' ? 'active' : ''}`} onClick={() => setTab('seed')}>
          种子 ({seedItems.reduce((sum, i) => sum + i.quantity, 0)})
        </button>
        <button className={`tab ${tab === 'crop' ? 'active' : ''}`} onClick={() => setTab('crop')}>
          作物 ({cropItems.reduce((sum, i) => sum + i.quantity, 0)})
        </button>
      </div>

      {tab === 'seed' && (
        <div className="grid grid-3">
          {seedItems.length === 0 ? (
            <p style={{ gridColumn: '1/-1', textAlign: 'center', color: '#888' }}>暂无种子</p>
          ) : (
            seedItems.map(item => {
              const seed = getSeedInfo(item.item_id)
              return (
                <div key={item.id} className="card">
                  <div className="card-header">
                    {seed?.icon && (
                      <img 
                        src={`${seed.icon}/0.png`} 
                        alt={seed.name}
                        style={{ width: 32, height: 32, imageRendering: 'pixelated', marginRight: 8 }}
                      />
                    )}
                    <span style={{ flex: 1 }}>{seed?.name || `种子#${item.item_id}`}</span>
                    <span style={{ color: '#ffd700' }}>×{item.quantity}</span>
                  </div>
                  <p style={{ fontSize: '0.85rem', color: '#aaa', margin: 0 }}>
                    {seed?.description || ''}
                  </p>
                </div>
              )
            })
          )}
        </div>
      )}

      {tab === 'crop' && (
        <div className="grid grid-3">
          {cropItems.length === 0 ? (
            <p style={{ gridColumn: '1/-1', textAlign: 'center', color: '#888' }}>暂无作物</p>
          ) : (
            cropItems.map(item => (
              <div key={item.id} className="card">
                <div className="card-header">
                  <span>作物#{item.item_id}</span>
                  <span style={{ color: '#ffd700' }}>×{item.quantity}</span>
                </div>
                <button
                  className="btn btn-primary"
                  style={{ width: '100%', marginTop: 8 }}
                  disabled={selling === item.item_id}
                  onClick={() => handleSell(item.item_id, item.quantity)}
                >
                  {selling === item.item_id ? '出售中...' : '全部出售'}
                </button>
              </div>
            ))
          )}
        </div>
      )}
    </Modal>
  )
}
