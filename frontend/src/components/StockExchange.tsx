import { useState, useEffect, useRef } from 'react'
import { createChart } from 'lightweight-charts'
import type { IChartApi, CandlestickData, Time } from 'lightweight-charts'
import Modal from './Modal'
import { useUser } from '../contexts/UserContext'
import { useToast } from './Toast'
import { api } from '../services/api'
import { ws } from '../services/websocket'
import type { Stock, UserStock, LeveragePosition, KLineData } from '../types'

interface StockExchangeProps {
  isOpen: boolean
  onClose: () => void
}

export default function StockExchange({ isOpen, onClose }: StockExchangeProps) {
  const { user, refreshProfile } = useUser()
  const { showToast } = useToast()
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
  const [klineData, setKlineData] = useState<KLineData[]>([])
  const [news, setNews] = useState<{ title: string; effect: number; time: string }[]>([])
  const [insiderTip, setInsiderTip] = useState<{ message: string; stockName: string } | null>(null)
  const [todayProfit, setTodayProfit] = useState(0)
  const [showProfitDetail, setShowProfitDetail] = useState(false)
  const [profitList, setProfitList] = useState<{ id: number; stock_name: string; amount: number; change_percent: number; created_at: string }[]>([])
  const chartContainerRef = useRef<HTMLDivElement>(null)
  const chartRef = useRef<IChartApi | null>(null)
  const candleSeriesRef = useRef<ReturnType<IChartApi['addCandlestickSeries']> | null>(null)
  const todayCandleRef = useRef<{ open: number; high: number; low: number; close: number } | null>(null)
  const lastKlineUpdateRef = useRef<number>(0) // K线更新节流

  useEffect(() => {
    if (isOpen) {
      loadData()
      // 加载历史新闻
      api.getStockNews(20).then(data => {
        setNews((data.news || []).map(n => ({
          title: `[${n.stock_code}] ${n.title}`,
          effect: n.effect,
          time: new Date(n.created_at).toLocaleTimeString()
        })))
      }).catch(() => {})
      // 加载今日盈亏
      api.getTodayProfit().then(data => {
        setTodayProfit(data.total || 0)
        setProfitList(data.profits || [])
      }).catch(() => {})
    }
  }, [isOpen, tab])

  useEffect(() => {
    const unsub = ws.on('stock_price', (data) => {
      // 更新股票列表价格
      setStocks(prev => prev.map(s => 
        s.id === data.stock_id 
          ? { ...s, current_price: data.current_price as number, change_percent: data.change_percent as number }
          : s
      ))
      // 更新选中的股票价格
      setSelectedStock(prev => 
        prev && prev.id === data.stock_id 
          ? { ...prev, current_price: data.current_price as number, change_percent: data.change_percent as number }
          : prev
      )
      // 更新杠杆仓位盈亏
      const newPrice = data.current_price as number
      setPositions(prev => prev.map(p => {
        if (p.stock_id !== data.stock_id) return p
        const priceDiff = p.position_type === 'long' 
          ? newPrice - p.entry_price 
          : p.entry_price - newPrice
        const profit = priceDiff * p.shares
        return { ...p, unrealized_profit: profit }
      }))
      // 实时更新 K 线图最新蜡烛（使用后端传来的完整 OHLC 数据，节流500ms）
      const now = Date.now()
      if (selectedStock && data.stock_id === selectedStock.id && candleSeriesRef.current && now - lastKlineUpdateRef.current > 500) {
        lastKlineUpdateRef.current = now
        const today = new Date().toISOString().split('T')[0] as Time
        const price = data.current_price as number
        const openPrice = data.open_price as number | undefined
        const highPrice = data.high_price as number | undefined
        const lowPrice = data.low_price as number | undefined
        
        // 优先使用后端传来的 OHLC，否则用本地维护的
        if (openPrice !== undefined) {
          todayCandleRef.current = {
            open: openPrice,
            high: highPrice || price,
            low: lowPrice || price,
            close: price
          }
        } else if (!todayCandleRef.current) {
          todayCandleRef.current = { open: price, high: price, low: price, close: price }
        } else {
          todayCandleRef.current.close = price
          if (price > todayCandleRef.current.high) todayCandleRef.current.high = price
          if (price < todayCandleRef.current.low) todayCandleRef.current.low = price
        }
        
        candleSeriesRef.current.update({
          time: today,
          ...todayCandleRef.current
        })
      }
    })
    return unsub
  }, [selectedStock])

  // 监听新闻和内幕消息
  useEffect(() => {
    const unsubNews = ws.on('stock_news', (data) => {
      const newsItem = {
        title: `[${data.stock_code}] ${data.title}`,
        effect: data.effect as number,
        time: new Date().toLocaleTimeString()
      }
      setNews(prev => [newsItem, ...prev].slice(0, 10))
    })
    const unsubTip = ws.on('insider_tip', (data) => {
      setInsiderTip({ message: data.message as string, stockName: data.stock_name as string })
      setTimeout(() => setInsiderTip(null), 10000) // 10秒后消失
    })
    const unsubDividend = ws.on('dividend', (data) => {
      const amount = data.amount as number
      setTodayProfit(prev => prev + amount)
      setProfitList(prev => [{
        id: data.id as number,
        stock_name: data.stock_name as string,
        amount: amount,
        change_percent: data.change_percent as number,
        created_at: data.created_at as string
      }, ...prev])
      refreshProfile()
      showToast(data.message as string, amount > 0 ? 'success' : 'error')
    })
    return () => {
      unsubNews()
      unsubTip()
      unsubDividend()
    }
  }, [showToast])

  // 加载 K 线数据
  useEffect(() => {
    if (selectedStock) {
      todayCandleRef.current = null // 重置今日蜡烛
      api.getKLine(selectedStock.id, '1d', 30).then(data => {
        const prices = data.prices || []
        setKlineData(prices)
        // 初始化今日蜡烛
        if (prices.length > 0) {
          const today = new Date().toISOString().split('T')[0]
          const todayData = prices.find(p => p.recorded_at.startsWith(today))
          if (todayData) {
            todayCandleRef.current = {
              open: todayData.open_price || todayData.price,
              high: todayData.high_price || todayData.price,
              low: todayData.low_price || todayData.price,
              close: todayData.price
            }
          } else {
            // 没有今日数据，用当前价格初始化
            todayCandleRef.current = {
              open: selectedStock.current_price,
              high: selectedStock.current_price,
              low: selectedStock.current_price,
              close: selectedStock.current_price
            }
          }
        }
      }).catch(() => setKlineData([]))
    }
  }, [selectedStock])

  // 渲染 K 线图（当有数据时创建并填充）
  useEffect(() => {
    if (!chartContainerRef.current || !selectedStock || klineData.length === 0) return

    // 清理旧图表
    if (chartRef.current) {
      chartRef.current.remove()
      chartRef.current = null
      candleSeriesRef.current = null
    }

    // 创建图表
    try {
      const chart = createChart(chartContainerRef.current, {
        width: 350,
        height: 200,
        layout: { background: { color: '#1a1a2e' }, textColor: '#ffd700' },
        grid: { vertLines: { color: '#333' }, horzLines: { color: '#333' } },
        timeScale: { borderColor: '#444' },
      })
      chartRef.current = chart

      const candlestickSeries = chart.addCandlestickSeries({
        upColor: '#4caf50',
        downColor: '#f44336',
        borderUpColor: '#4caf50',
        borderDownColor: '#f44336',
        wickUpColor: '#4caf50',
        wickDownColor: '#f44336',
      })
      candleSeriesRef.current = candlestickSeries

      // 立即填充数据
      const chartData: CandlestickData<Time>[] = klineData
        .slice()
        .filter(k => k.price > 0)
        .sort((a, b) => new Date(a.recorded_at).getTime() - new Date(b.recorded_at).getTime())
        .map(k => ({
          time: k.recorded_at.split('T')[0] as Time,
          open: k.open_price || k.price,
          high: k.high_price || k.price,
          low: k.low_price || k.price,
          close: k.price,
        }))

      if (chartData.length > 0) {
        candlestickSeries.setData(chartData)
        chart.timeScale().fitContent()
      }
    } catch (e) {
      console.error('K线图创建失败:', e)
    }

    return () => {
      if (chartRef.current) {
        chartRef.current.remove()
        chartRef.current = null
        candleSeriesRef.current = null
      }
    }
  }, [selectedStock, klineData])

  // 清理图表实例
  useEffect(() => {
    return () => {
      if (chartRef.current) {
        chartRef.current.remove()
        chartRef.current = null
        candleSeriesRef.current = null
      }
    }
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
        const [posData, stockData] = await Promise.all([
          api.getMyPositions(),
          api.getStocks()
        ])
        setPositions(posData.positions)
        setStocks(stockData.stocks)
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
        showToast('买入成功！', 'success')
      } else if (tradeType === 'sell') {
        const result = await api.sellStock(selectedStock.id, shares)
        showToast(`卖出成功！盈亏: ${result.profit.toFixed(2)}`, result.profit >= 0 ? 'success' : 'info')
      } else if (tradeType === 'long') {
        await api.openLong(selectedStock.id, leverage, margin)
        showToast('开多成功！', 'success')
      } else if (tradeType === 'short') {
        await api.openShort(selectedStock.id, leverage, margin)
        showToast('开空成功！', 'success')
      }
      refreshProfile()
      loadData()
      setSelectedStock(null)
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const handleClosePosition = async (positionId: number) => {
    try {
      const result = await api.closePosition(positionId)
      showToast(`平仓成功！盈亏: ${result.profit.toFixed(2)}`, result.profit >= 0 ? 'success' : 'info')
      refreshProfile()
      loadData()
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const getTrendColor = (percent: number) => {
    if (percent > 0) return '#4caf50'
    if (percent < 0) return '#f44336'
    return '#888'
  }

  return (
    <Modal title="股票交易所" isOpen={isOpen} onClose={onClose}>
      <div style={{ marginBottom: 16, display: 'flex', gap: 16, alignItems: 'center' }}>
        <span style={{ color: '#ffd700' }}>可用资金: {user?.gold.toFixed(2) || 0}</span>
        <span style={{ color: todayProfit >= 0 ? '#4caf50' : '#f44336' }}>
          今日盈亏: {todayProfit >= 0 ? '+' : ''}{todayProfit.toFixed(2)}
        </span>
        <button 
          className="btn" 
          style={{ padding: '4px 8px', fontSize: 12 }}
          onClick={() => {
            setShowProfitDetail(!showProfitDetail)
            if (!showProfitDetail) {
              api.getTodayProfit('all').then(data => setProfitList(data.profits || []))
            }
          }}
        >
          📅 历史盈亏
        </button>
      </div>

      {/* 盈亏明细 */}
      {showProfitDetail && (
        <div style={{ 
          marginBottom: 16, 
          padding: 12, 
          background: 'rgba(0,0,0,0.4)', 
          borderRadius: 8,
          maxHeight: 200,
          overflowY: 'auto'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
            <span style={{ color: '#ffd700', fontWeight: 'bold' }}>📊 盈亏明细</span>
            <span style={{ color: '#888', cursor: 'pointer' }} onClick={() => setShowProfitDetail(false)}>关闭</span>
          </div>
          {profitList.length === 0 ? (
            <div style={{ color: '#888', fontSize: 12 }}>暂无记录</div>
          ) : (
            profitList.map(p => (
              <div key={p.id} style={{ 
                display: 'flex', 
                justifyContent: 'space-between', 
                fontSize: 12, 
                padding: '4px 0',
                borderBottom: '1px solid rgba(255,255,255,0.1)'
              }}>
                <span style={{ color: '#aaa', minWidth: 120 }}>
                  {new Date(p.created_at).toLocaleDateString()} {new Date(p.created_at).toLocaleTimeString()}
                </span>
                <span style={{ flex: 1, textAlign: 'center' }}>{p.stock_name}</span>
                <span style={{ color: p.amount >= 0 ? '#4caf50' : '#f44336', minWidth: 80, textAlign: 'right' }}>
                  {p.amount >= 0 ? '+' : ''}{p.amount.toFixed(2)}
                </span>
              </div>
            ))
          )}
        </div>
      )}

      {/* 内幕消息弹窗 */}
      {insiderTip && (
        <div style={{
          padding: '12px 16px',
          marginBottom: 16,
          background: 'linear-gradient(135deg, #ff6b6b, #ffa500)',
          borderRadius: 8,
          animation: 'pulse 1s infinite'
        }}>
          <div style={{ fontWeight: 'bold', marginBottom: 4 }}>🔥 内幕消息</div>
          <div style={{ fontSize: 14 }}>{insiderTip.message}</div>
        </div>
      )}

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
            <div className="stock-market-layout">
            <div className="stock-table-wrap">
            <table className="table">
              <thead>
                <tr>
                  <th>代码</th>
                  <th>名称</th>
                  <th>价格</th>
                  <th>涨跌</th>
                  <th>可买</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                {stocks.map(stock => (
                  <tr key={stock.id}>
                    <td>{stock.code}</td>
                    <td>{stock.name}</td>
                    <td>{(stock.current_price || 0).toFixed(2)}</td>
                    <td style={{ color: getTrendColor(stock.change_percent || 0) }}>
                      {(stock.change_percent || 0) > 0 ? '+' : ''}{(stock.change_percent || 0).toFixed(2)}%
                    </td>
                    <td style={{ fontSize: 11, color: '#888' }}>
                      {(stock.available_shares || 0) >= 10000 
                        ? `${((stock.available_shares || 0) / 10000).toFixed(0)}万`
                        : (stock.available_shares || 0)}
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
            </div>

            {/* 新闻滚动 */}
            <div className="stock-news-panel">
              <div style={{ color: '#ffd700', marginBottom: 10, fontWeight: 'bold', fontSize: 14 }}>📰 市场新闻</div>
              {news.length === 0 ? (
                <div style={{ color: '#888', fontSize: 12 }}>暂无新闻...</div>
              ) : (
                news.map((n, i) => (
                  <div key={i} className="stock-news-item" style={{ borderLeftColor: n.effect > 0 ? '#4caf50' : '#f44336' }}>
                    <div style={{ color: '#888', fontSize: 10, marginBottom: 2 }}>{n.time}</div>
                    <div style={{ color: n.effect > 0 ? '#4caf50' : '#f44336' }}>{n.title}</div>
                  </div>
                ))
              )}
            </div>
            </div>
          )}

          {tab === 'holdings' && (
            <table className="table">
              <thead>
                <tr>
                  <th>股票</th>
                  <th>持仓</th>
                  <th>成本</th>
                  <th>现价</th>
                  <th>浮动盈亏</th>
                </tr>
              </thead>
              <tbody>
                {myStocks.length === 0 ? (
                  <tr><td colSpan={5} style={{ textAlign: 'center' }}>暂无持仓</td></tr>
                ) : (
                  myStocks.map(s => {
                    const currentPrice = stocks.find(st => st.id === s.stock_id)?.current_price || s.stock?.current_price || 0
                    const floatProfit = (currentPrice - s.avg_cost) * s.shares
                    return (
                      <tr key={s.id}>
                        <td>{s.stock?.name || `#${s.stock_id}`}</td>
                        <td>{s.shares}</td>
                        <td>{s.avg_cost.toFixed(2)}</td>
                        <td>{currentPrice.toFixed(2)}</td>
                        <td style={{ color: floatProfit >= 0 ? '#4caf50' : '#f44336' }}>
                          {floatProfit >= 0 ? '+' : ''}{floatProfit.toFixed(2)}
                        </td>
                      </tr>
                    )
                  })
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
                  <th>开仓</th>
                  <th>现价</th>
                  <th>强平</th>
                  <th>盈亏</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                {positions.length === 0 ? (
                  <tr><td colSpan={8} style={{ textAlign: 'center' }}>暂无仓位</td></tr>
                ) : (
                  positions.map(p => {
                    const currentPrice = stocks.find(s => s.id === p.stock_id)?.current_price || p.stock?.current_price || 0
                    return (
                      <tr key={p.id}>
                        <td>{p.stock?.name || `#${p.stock_id}`}</td>
                        <td style={{ color: p.position_type === 'long' ? '#4caf50' : '#f44336' }}>
                          {p.position_type === 'long' ? '多' : '空'}
                        </td>
                        <td>{p.leverage}x</td>
                        <td>{p.entry_price.toFixed(2)}</td>
                        <td style={{ color: currentPrice >= p.entry_price ? '#4caf50' : '#f44336' }}>
                          {currentPrice.toFixed(2)}
                        </td>
                        <td style={{ color: '#f44336' }}>{p.liquidation_price.toFixed(2)}</td>
                        <td style={{ color: p.unrealized_profit >= 0 ? '#4caf50' : '#f44336' }}>
                          {p.unrealized_profit >= 0 ? '+' : ''}{p.unrealized_profit.toFixed(2)}
                        </td>
                        <td>
                          <button className="btn btn-danger" onClick={() => handleClosePosition(p.id)}>
                            平仓
                          </button>
                        </td>
                      </tr>
                    )
                  })
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
          <div className="card" style={{ width: '95%', maxWidth: 420 }} onClick={e => e.stopPropagation()}>
            <h3 style={{ color: '#ffd700', marginBottom: 16 }}>
              {selectedStock.name} ({selectedStock.code})
            </h3>
            <p>当前价格: {selectedStock.current_price.toFixed(2)}</p>

            {/* K线图 */}
            <div ref={chartContainerRef} style={{ marginBottom: 16, borderRadius: 8, overflow: 'hidden' }} />

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
