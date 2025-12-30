import { useState, useEffect } from 'react'
import Modal from './Modal'
import { useUser } from '../contexts/UserContext'
import { api } from '../services/api'
import { ws } from '../services/websocket'
import type { Stock, UserStock, LeveragePosition } from '../types'

interface StockExchangeProps {
  isOpen: boolean
  onClose: () => void
}

export default function StockExchange({ isOpen, onClose }: StockExchangeProps) {
  const { user, refreshProfile } = useUser()
  const [tab, setTab] = useState<'market' | 'holdings' | 'positions'>('market')
  const [stocks, setStocks] = useState<Stock[]>([])
  const [myStocks, setMyStocks] = useState<UserStock[]>([])
  const [positions, setPositions] = useState<LeveragePosition[]>([])
  const [loading, setLoading] = useState(false)
  const [selectedStock, setSelectedStock] = useState<Stock | null>(null)
  const [tradeType, setTradeType] = useState<'buy' | 'sell' | 'long' | 'short'>('buy')
  const [shares, setShares] = useState(100)
  const [leverage, setLeverage] = useState(1)
  const [margin, setMargin] = useState(100)

  useEffect(() => {
    if (isOpen) {
      loadData()
    }
  }, [isOpen, tab])

  useEffect(() => {
    const unsub = ws.on('stock_price', (data) => {
      setStocks(prev => prev.map(s => 
        s.id === data.stock_id 
          ? { ...s, current_price: data.price as number, change_percent: data.change_percent as number }
          : s
      ))
    })
    return unsub
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      if (tab === 'market') {
        const data = await api.getStocks()
        setStocks(data.stocks)
      } else if (tab === 'holdings') {
        const data = await api.getMyStocks()
        setMyStocks(data.stocks)
      } else {
        const data = await api.getMyPositions()
        setPositions(data.positions)
      }
    } finally {
      setLoading(false)
    }
  }

  const handleTrade = async () => {
    if (!selectedStock) return
    
    try {
      if (tradeType === 'buy') {
        await api.buyStock(selectedStock.id, shares)
        alert('买入成功！')
      } else if (tradeType === 'sell') {
        const result = await api.sellStock(selectedStock.id, shares)
        alert(`卖出成功！盈亏: ${result.profit.toFixed(2)}`)
      } else if (tradeType === 'long') {
        await api.openLong(selectedStock.id, leverage, margin)
        alert('开多成功！')
      } else if (tradeType === 'short') {
        await api.openShort(selectedStock.id, leverage, margin)
        alert('开空成功！')
      }
      refreshProfile()
      loadData()
      setSelectedStock(null)
    } catch (e) {
      alert((e as Error).message)
    }
  }

  const handleClosePosition = async (positionId: number) => {
    try {
      const result = await api.closePosition(positionId)
      alert(`平仓成功！盈亏: ${result.profit.toFixed(2)}`)
      refreshProfile()
      loadData()
    } catch (e) {
      alert((e as Error).message)
    }
  }

  const getTrendColor = (trend: string, percent: number) => {
    if (trend === 'up' || percent > 0) return '#4caf50'
    if (trend === 'down' || percent < 0) return '#f44336'
    return '#888'
  }

  return (
    <Modal title="股票交易所" isOpen={isOpen} onClose={onClose}>
      <div style={{ marginBottom: 16, color: '#ffd700' }}>
        可用资金: {user?.gold.toFixed(2) || 0}
      </div>

      <div className="tabs">
        <button className={`tab ${tab === 'market' ? 'active' : ''}`} onClick={() => setTab('market')}>
          市场行情
        </button>
        <button className={`tab ${tab === 'holdings' ? 'active' : ''}`} onClick={() => setTab('holdings')}>
          我的持仓
        </button>
        <button className={`tab ${tab === 'positions' ? 'active' : ''}`} onClick={() => setTab('positions')}>
          杠杆仓位
        </button>
      </div>

      {loading ? (
        <p style={{ textAlign: 'center' }}>加载中...</p>
      ) : (
        <>
          {tab === 'market' && (
            <table className="table">
              <thead>
                <tr>
                  <th>代码</th>
                  <th>名称</th>
                  <th>价格</th>
                  <th>涨跌</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                {stocks.map(stock => (
                  <tr key={stock.id}>
                    <td>{stock.code}</td>
                    <td>{stock.name}</td>
                    <td>{stock.current_price.toFixed(2)}</td>
                    <td style={{ color: getTrendColor(stock.trend, stock.change_percent) }}>
                      {stock.change_percent > 0 ? '+' : ''}{stock.change_percent.toFixed(2)}%
                    </td>
                    <td>
                      <button className="btn" onClick={() => { setSelectedStock(stock); setTradeType('buy') }}>
                        交易
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}

          {tab === 'holdings' && (
            <table className="table">
              <thead>
                <tr>
                  <th>股票</th>
                  <th>持仓</th>
                  <th>成本</th>
                  <th>盈亏</th>
                </tr>
              </thead>
              <tbody>
                {myStocks.length === 0 ? (
                  <tr><td colSpan={4} style={{ textAlign: 'center' }}>暂无持仓</td></tr>
                ) : (
                  myStocks.map(s => (
                    <tr key={s.id}>
                      <td>{s.stock?.name || `#${s.stock_id}`}</td>
                      <td>{s.shares}</td>
                      <td>{s.avg_cost.toFixed(2)}</td>
                      <td style={{ color: s.realized_profit >= 0 ? '#4caf50' : '#f44336' }}>
                        {s.realized_profit.toFixed(2)}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          )}

          {tab === 'positions' && (
            <table className="table">
              <thead>
                <tr>
                  <th>股票</th>
                  <th>方向</th>
                  <th>杠杆</th>
                  <th>保证金</th>
                  <th>盈亏</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                {positions.length === 0 ? (
                  <tr><td colSpan={6} style={{ textAlign: 'center' }}>暂无仓位</td></tr>
                ) : (
                  positions.map(p => (
                    <tr key={p.id}>
                      <td>{p.stock?.name || `#${p.stock_id}`}</td>
                      <td style={{ color: p.position_type === 'long' ? '#4caf50' : '#f44336' }}>
                        {p.position_type === 'long' ? '做多' : '做空'}
                      </td>
                      <td>{p.leverage}x</td>
                      <td>{p.margin.toFixed(2)}</td>
                      <td style={{ color: p.unrealized_profit >= 0 ? '#4caf50' : '#f44336' }}>
                        {p.unrealized_profit.toFixed(2)}
                      </td>
                      <td>
                        <button className="btn btn-danger" onClick={() => handleClosePosition(p.id)}>
                          平仓
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          )}
        </>
      )}

      {/* 交易弹窗 */}
      {selectedStock && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0,0,0,0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1001
        }} onClick={() => setSelectedStock(null)}>
          <div className="card" style={{ minWidth: 300, maxWidth: 400 }} onClick={e => e.stopPropagation()}>
            <h3 style={{ color: '#ffd700', marginBottom: 16 }}>
              {selectedStock.name} ({selectedStock.code})
            </h3>
            <p>当前价格: {selectedStock.current_price.toFixed(2)}</p>

            <div className="tabs" style={{ marginBottom: 16 }}>
              <button className={`tab ${tradeType === 'buy' ? 'active' : ''}`} onClick={() => setTradeType('buy')}>买入</button>
              <button className={`tab ${tradeType === 'sell' ? 'active' : ''}`} onClick={() => setTradeType('sell')}>卖出</button>
              <button className={`tab ${tradeType === 'long' ? 'active' : ''}`} onClick={() => setTradeType('long')}>做多</button>
              <button className={`tab ${tradeType === 'short' ? 'active' : ''}`} onClick={() => setTradeType('short')}>做空</button>
            </div>

            {(tradeType === 'buy' || tradeType === 'sell') && (
              <div className="form-group">
                <label>数量</label>
                <input type="number" min="1" value={shares} onChange={e => setShares(parseInt(e.target.value) || 0)} />
                <p style={{ fontSize: '0.85rem', color: '#888', marginTop: 4 }}>
                  总价: {(shares * selectedStock.current_price).toFixed(2)}
                </p>
              </div>
            )}

            {(tradeType === 'long' || tradeType === 'short') && (
              <>
                <div className="form-group">
                  <label>杠杆倍数</label>
                  <select value={leverage} onChange={e => setLeverage(parseInt(e.target.value))}>
                    {[1, 2, 3, 5, 10].filter(l => l <= selectedStock.max_leverage).map(l => (
                      <option key={l} value={l}>{l}x</option>
                    ))}
                  </select>
                </div>
                <div className="form-group">
                  <label>保证金</label>
                  <input type="number" min="1" value={margin} onChange={e => setMargin(parseInt(e.target.value) || 0)} />
                  <p style={{ fontSize: '0.85rem', color: '#888', marginTop: 4 }}>
                    可开仓位: {(margin * leverage / selectedStock.current_price).toFixed(0)} 股
                  </p>
                </div>
              </>
            )}

            <div style={{ display: 'flex', gap: 8, marginTop: 16 }}>
              <button className="btn" style={{ flex: 1 }} onClick={() => setSelectedStock(null)}>取消</button>
              <button className="btn btn-primary" style={{ flex: 1 }} onClick={handleTrade}>确认</button>
            </div>
          </div>
        </div>
      )}
    </Modal>
  )
}
