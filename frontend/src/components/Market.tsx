import { useState, useEffect, useCallback, useRef } from 'react'
import Modal from './Modal'
import { useUser } from '../contexts/UserContext'
import { useToast } from './Toast'
import { api } from '../services/api'
import { ws } from '../services/websocket'
import { dataCache } from '../stores/dataCache'
import type { Seed, Crop } from '../types'

interface MarketProps {
  isOpen: boolean
  onClose: () => void
}

export default function Market({ isOpen, onClose }: MarketProps) {
  const { user, inventory, refreshProfile, refreshInventory } = useUser()
  const { showToast } = useToast()
  const [tab, setTab] = useState<'buy' | 'sell' | 'recycle'>('buy')
  const [seeds, setSeeds] = useState<Seed[]>([])
  const [crops, setCrops] = useState<Crop[]>([])
  const [loading, setLoading] = useState(false)
  const [buying, setBuying] = useState<number | null>(null)
  const [selling, setSelling] = useState<number | null>(null)
  const [recycling, setRecycling] = useState<number | null>(null)
  const [quantities, setQuantities] = useState<Record<number, number>>({})
  const [sellQuantities, setSellQuantities] = useState<Record<number, number>>({})
  const [recycleQuantities, setRecycleQuantities] = useState<Record<number, number>>({})

  const cropItems = inventory.filter(i => i.item_type === 'crop' && i.quantity > 0)
  const seedItems = inventory.filter(i => i.item_type === 'seed' && i.quantity > 0)

  // 处理 WebSocket 价格更新
  const handlePriceUpdate = useCallback((data: Record<string, unknown>) => {
    if (data.item_type === 'seed') {
      setSeeds(prev => prev.map(seed => 
        seed.id === data.item_id 
          ? { 
              ...seed, 
              current_price: data.current_price as number,
              buy_volume: data.buy_volume as number,
              sell_volume: data.sell_volume as number,
              trend: data.trend as string,
              price_change: ((data.current_price as number) - seed.base_price) / seed.base_price * 100
            }
          : seed
      ))
    } else if (data.item_type === 'crop') {
      setCrops(prev => prev.map(crop => 
        crop.id === data.item_id 
          ? { 
              ...crop, 
              current_price: data.current_price as number,
              buy_volume: data.buy_volume as number,
              sell_volume: data.sell_volume as number,
              trend: data.trend as string,
              price_change: ((data.current_price as number) - crop.base_sell_price) / crop.base_sell_price * 100
            }
          : crop
      ))
    }
  }, [])

  const dataLoaded = useRef(false)

  useEffect(() => {
    if (isOpen) {
      if (!dataLoaded.current) {
        setLoading(true)
        Promise.all([dataCache.getSeeds(), dataCache.getCrops()])
          .then(([seedsData, cropsData]) => {
            setSeeds(seedsData)
            setCrops(cropsData)
            dataLoaded.current = true
          })
          .finally(() => setLoading(false))
      }
      refreshInventory()
    }
  }, [isOpen, refreshInventory])

  // 监听 WebSocket 价格更新
  useEffect(() => {
    const unsub = ws.on('market_update', handlePriceUpdate)
    return () => unsub()
  }, [handlePriceUpdate])

  const handleBuy = async (seedId: number) => {
    const quantity = quantities[seedId] || 1
    setBuying(seedId)
    try {
      await api.buySeed(seedId, quantity)
      showToast('购买成功！', 'success')
      refreshProfile()
      refreshInventory()
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setBuying(null)
    }
  }

  const handleSell = async (cropId: number, maxQty: number) => {
    const quantity = sellQuantities[cropId] || maxQty
    setSelling(cropId)
    try {
      const result = await api.sellCrop(cropId, quantity)
      showToast(`出售成功！+${result.earning.toFixed(0)} 金币`, 'success')
      refreshProfile()
      refreshInventory()
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setSelling(null)
    }
  }

  const getCropInfo = (cropId: number) => {
    return crops.find(c => c.id === cropId)
  }

  const getSeedInfo = (seedId: number) => {
    return seeds.find(s => s.id === seedId)
  }

  const handleRecycle = async (seedId: number, maxQty: number) => {
    const quantity = recycleQuantities[seedId] || maxQty
    setRecycling(seedId)
    try {
      const seed = getSeedInfo(seedId)
      const recyclePrice = (seed?.base_price || 10) * 0.3 * quantity
      await api.recycleSeed(seedId, quantity)
      showToast(`回收成功！+${recyclePrice.toFixed(0)} 金币`, 'success')
      refreshProfile()
      refreshInventory()
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setRecycling(null)
    }
  }

  return (
    <Modal title="交易市场" isOpen={isOpen} onClose={onClose}>
      <div style={{ marginBottom: 16, color: '#ffd700' }}>
        当前金币: {user?.gold.toFixed(2) || 0}
      </div>

      <div className="tabs">
        <button className={`tab ${tab === 'buy' ? 'active' : ''}`} onClick={() => setTab('buy')}>
          🛒 购买种子
        </button>
        <button className={`tab ${tab === 'sell' ? 'active' : ''}`} onClick={() => setTab('sell')}>
          💰 出售作物 ({cropItems.reduce((sum, i) => sum + i.quantity, 0)})
        </button>
        <button className={`tab ${tab === 'recycle' ? 'active' : ''}`} onClick={() => setTab('recycle')}>
          ♻️ 回收种子 ({seedItems.reduce((sum, i) => sum + i.quantity, 0)})
        </button>
      </div>

      {loading ? (
        <p style={{ textAlign: 'center' }}>加载中...</p>
      ) : tab === 'buy' ? (
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
              <div style={{ fontSize: '0.9rem', marginBottom: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
                <span>价格: <span style={{ color: '#ffd700' }}>{(seed.current_price || seed.base_price).toFixed(2)}</span></span>
                {seed.price_change !== 0 && (
                  <span style={{ 
                    color: seed.price_change > 0 ? '#4caf50' : '#f44336',
                    fontSize: '0.8rem'
                  }}>
                    {seed.price_change > 0 ? '↑' : '↓'}{Math.abs(seed.price_change).toFixed(1)}%
                  </span>
                )}
              </div>
              <p style={{ fontSize: '0.75rem', color: '#888', marginBottom: 4 }}>
                总买入量: {seed.buy_volume || 0}
              </p>
              <p style={{ fontSize: '0.85rem', color: '#888', marginBottom: 12 }}>
                生长时间: {Math.floor(seed.growth_time / 60)}分钟
              </p>
              
              <div style={{ display: 'flex', gap: 8 }}>
                <input
                  type="number"
                  min="1"
                  max="9999"
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
      ) : tab === 'sell' ? (
        <div className="grid grid-2">
          {cropItems.length === 0 ? (
            <p style={{ gridColumn: '1/-1', textAlign: 'center', color: '#888' }}>暂无可出售的作物</p>
          ) : (
            cropItems.map(item => {
              const crop = getCropInfo(item.item_id)
              return (
                <div key={item.id} className="card">
                  <div className="card-header">
                    {crop?.icon && (
                      <img 
                        src={`${crop.icon}/4.png`} 
                        alt={crop?.name}
                        style={{ width: 32, height: 32, imageRendering: 'pixelated' }}
                      />
                    )}
                    <h4 className="card-title" style={{ flex: 1, marginLeft: 8 }}>
                      {crop?.name || `作物#${item.item_id}`}
                    </h4>
                    <span style={{ color: '#ffd700' }}>×{item.quantity}</span>
                  </div>
                  <div style={{ fontSize: '0.9rem', marginBottom: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span>单价: <span style={{ color: '#4caf50' }}>{(crop?.current_price || crop?.base_sell_price || 15).toFixed(2)}</span></span>
                    {crop?.price_change !== 0 && crop?.price_change && (
                      <span style={{ 
                        color: crop.price_change > 0 ? '#4caf50' : '#f44336',
                        fontSize: '0.8rem'
                      }}>
                        {crop.price_change > 0 ? '↑' : '↓'}{Math.abs(crop.price_change).toFixed(1)}%
                      </span>
                    )}
                  </div>
                  <p style={{ fontSize: '0.75rem', color: '#888', marginBottom: 8 }}>
                    总卖出量: {crop?.sell_volume || 0}
                  </p>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <input
                      type="number"
                      min="1"
                      max={item.quantity}
                      value={sellQuantities[item.item_id] || item.quantity}
                      onChange={e => setSellQuantities({ ...sellQuantities, [item.item_id]: Math.min(parseInt(e.target.value) || 1, item.quantity) })}
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
                      disabled={selling === item.item_id}
                      onClick={() => handleSell(item.item_id, item.quantity)}
                    >
                      {selling === item.item_id ? '出售中...' : '出售'}
                    </button>
                  </div>
                </div>
              )
            })
          )}
        </div>
      ) : (
        <div className="grid grid-2">
          {seedItems.length === 0 ? (
            <p style={{ gridColumn: '1/-1', textAlign: 'center', color: '#888' }}>暂无可回收的种子</p>
          ) : (
            seedItems.map(item => {
              const seed = getSeedInfo(item.item_id)
              const recyclePrice = (seed?.base_price || 10) * 0.3
              return (
                <div key={item.id} className="card">
                  <div className="card-header">
                    {seed?.icon && (
                      <img 
                        src={`${seed.icon}/0.png`} 
                        alt={seed?.name}
                        style={{ width: 32, height: 32, imageRendering: 'pixelated' }}
                      />
                    )}
                    <h4 className="card-title" style={{ flex: 1, marginLeft: 8 }}>
                      {seed?.name || `种子#${item.item_id}`}
                    </h4>
                    <span style={{ color: '#ffd700' }}>×{item.quantity}</span>
                  </div>
                  <p style={{ fontSize: '0.9rem', marginBottom: 4 }}>
                    原价: <span style={{ color: '#888', textDecoration: 'line-through' }}>{seed?.base_price || 10}</span> 金币
                  </p>
                  <p style={{ fontSize: '0.9rem', marginBottom: 12 }}>
                    回收价: <span style={{ color: '#f44336' }}>{recyclePrice.toFixed(0)}</span> 金币 <span style={{ color: '#888', fontSize: '0.8rem' }}>(30%)</span>
                  </p>
                  
                  <div style={{ display: 'flex', gap: 8 }}>
                    <input
                      type="number"
                      min="1"
                      max={item.quantity}
                      value={recycleQuantities[item.item_id] || item.quantity}
                      onChange={e => setRecycleQuantities({ ...recycleQuantities, [item.item_id]: Math.min(parseInt(e.target.value) || 1, item.quantity) })}
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
                      className="btn btn-danger"
                      style={{ flex: 1 }}
                      disabled={recycling === item.item_id}
                      onClick={() => handleRecycle(item.item_id, item.quantity)}
                    >
                      {recycling === item.item_id ? '回收中...' : '回收'}
                    </button>
                  </div>
                </div>
              )
            })
          )}
        </div>
      )}
    </Modal>
  )
}
