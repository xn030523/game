import { useState, useEffect, useCallback } from 'react'
import { api } from '../services/api'
import { ws } from '../services/websocket'
import { useToast } from '../components/Toast'
import type { Auction as AuctionType, InventoryItem } from '../types'
import './Auction.css'

export default function Auction() {
  const { showToast } = useToast()
  const [auctions, setAuctions] = useState<AuctionType[]>([])
  const [myAuctions, setMyAuctions] = useState<{ selling: AuctionType[], bidding: AuctionType[] }>({ selling: [], bidding: [] })
  const [tab, setTab] = useState<'market' | 'my' | 'create'>('market')
  const [loading, setLoading] = useState(false)
  const [inventory, setInventory] = useState<InventoryItem[]>([])
  
  // 创建拍卖表单
  const [createForm, setCreateForm] = useState({
    item_type: 'seed',
    item_id: 0,
    quantity: 1,
    start_price: 10,
    buyout_price: '',
    duration: 24
  })

  // 出价表单
  const [bidPrice, setBidPrice] = useState<{ [key: number]: string }>({})

  // WebSocket 实时更新
  const handleAuctionUpdate = useCallback((raw: Record<string, unknown>) => {
    const data = raw as { auction_id: number; current_price: number; bid_count: number; status: string; end_at: string }
    setAuctions(prev => prev.map(a => 
      a.id === data.auction_id 
        ? { ...a, current_price: data.current_price, bid_count: data.bid_count, status: data.status as AuctionType['status'], end_at: data.end_at }
        : a
    ))
    setMyAuctions(prev => ({
      selling: prev.selling.map(a => a.id === data.auction_id ? { ...a, current_price: data.current_price, bid_count: data.bid_count, status: data.status as AuctionType['status'] } : a),
      bidding: prev.bidding.map(a => a.id === data.auction_id ? { ...a, current_price: data.current_price, bid_count: data.bid_count } : a)
    }))
  }, [])

  useEffect(() => {
    loadAuctions()
    ws.on('auction_update', handleAuctionUpdate)
    return () => ws.off('auction_update', handleAuctionUpdate)
  }, [handleAuctionUpdate])

  const loadAuctions = async () => {
    setLoading(true)
    try {
      const data = await api.getAuctions()
      setAuctions(data.auctions || [])
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setLoading(false)
    }
  }

  const loadMyAuctions = async () => {
    try {
      const data = await api.getMyAuctions()
      setMyAuctions({ selling: data.selling || [], bidding: data.bidding || [] })
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const loadInventory = async () => {
    try {
      const data = await api.getInventory()
      setInventory(data.inventory || [])
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const handleTabChange = (newTab: 'market' | 'my' | 'create') => {
    setTab(newTab)
    if (newTab === 'my') loadMyAuctions()
    if (newTab === 'create') loadInventory()
  }

  const handleCreateAuction = async () => {
    if (!createForm.item_id) {
      showToast('请选择物品', 'error')
      return
    }
    try {
      await api.createAuction(
        createForm.item_type,
        createForm.item_id,
        createForm.quantity,
        createForm.start_price,
        createForm.buyout_price ? parseFloat(createForm.buyout_price) : null,
        createForm.duration
      )
      showToast('上架成功', 'success')
      setTab('market')
      loadAuctions()
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const handleBid = async (auctionId: number) => {
    const price = parseFloat(bidPrice[auctionId] || '0')
    if (!price) {
      showToast('请输入出价', 'error')
      return
    }
    try {
      await api.placeBid(auctionId, price)
      showToast('出价成功', 'success')
      loadAuctions()
      setBidPrice({ ...bidPrice, [auctionId]: '' })
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const handleBuyout = async (auctionId: number) => {
    try {
      await api.buyoutAuction(auctionId)
      showToast('购买成功', 'success')
      loadAuctions()
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const handleCancel = async (auctionId: number) => {
    try {
      await api.cancelAuction(auctionId)
      showToast('取消成功', 'success')
      loadMyAuctions()
    } catch (e) {
      showToast((e as Error).message, 'error')
    }
  }

  const formatTime = (dateStr: string) => {
    const end = new Date(dateStr)
    const now = new Date()
    const diff = end.getTime() - now.getTime()
    if (diff <= 0) return '已结束'
    const hours = Math.floor(diff / 3600000)
    const mins = Math.floor((diff % 3600000) / 60000)
    return `${hours}小时${mins}分`
  }

  const filteredInventory = inventory.filter(i => i.item_type === createForm.item_type && i.quantity > 0)

  return (
    <div className="auction-container">
      <div className="auction-header">
        <h2>🔨 拍卖会</h2>
        <div className="auction-tabs">
          <button className={tab === 'market' ? 'active' : ''} onClick={() => handleTabChange('market')}>拍卖大厅</button>
          <button className={tab === 'my' ? 'active' : ''} onClick={() => handleTabChange('my')}>我的拍卖</button>
          <button className={tab === 'create' ? 'active' : ''} onClick={() => handleTabChange('create')}>上架物品</button>
        </div>
      </div>

      {tab === 'market' && (
        <div className="auction-list">
          {loading ? <div className="loading">加载中...</div> : auctions.length === 0 ? (
            <div className="empty">暂无拍卖</div>
          ) : (
            auctions.map(auction => (
              <div key={auction.id} className="auction-card">
                <div className="auction-item-info">
                  <span className="item-name">{auction.item_name} x{auction.quantity}</span>
                  <span className="seller">卖家: {auction.seller?.nickname || '未知'}</span>
                </div>
                <div className="auction-price-info">
                  <div className="price-row">
                    <span>起拍价:</span>
                    <span className="price">{auction.start_price.toFixed(2)}</span>
                  </div>
                  <div className="price-row current">
                    <span>当前价:</span>
                    <span className="price">{auction.current_price.toFixed(2)}</span>
                  </div>
                  {auction.buyout_price && (
                    <div className="price-row buyout">
                      <span>一口价:</span>
                      <span className="price">{auction.buyout_price.toFixed(2)}</span>
                    </div>
                  )}
                </div>
                <div className="auction-status">
                  <span>出价次数: {auction.bid_count}</span>
                  <span>剩余: {formatTime(auction.end_at)}</span>
                  {auction.bidder && <span>领先: {auction.bidder.nickname}</span>}
                </div>
                <div className="auction-actions">
                  <input
                    type="number"
                    placeholder={`最低 ${(auction.current_price + 1).toFixed(0)}`}
                    value={bidPrice[auction.id] || ''}
                    onChange={e => setBidPrice({ ...bidPrice, [auction.id]: e.target.value })}
                  />
                  <button onClick={() => handleBid(auction.id)}>出价</button>
                  {auction.buyout_price && (
                    <button className="buyout-btn" onClick={() => handleBuyout(auction.id)}>
                      一口价
                    </button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {tab === 'my' && (
        <div className="my-auctions">
          <h3>我上架的</h3>
          {myAuctions.selling.length === 0 ? <div className="empty">暂无上架</div> : (
            myAuctions.selling.map(auction => (
              <div key={auction.id} className="auction-card mini">
                <span>{auction.item_name} x{auction.quantity}</span>
                <span>当前: {auction.current_price.toFixed(2)}</span>
                <span>出价: {auction.bid_count}次</span>
                <span>{auction.status === 'active' ? formatTime(auction.end_at) : auction.status}</span>
                {auction.status === 'active' && auction.bid_count === 0 && (
                  <button onClick={() => handleCancel(auction.id)}>取消</button>
                )}
              </div>
            ))
          )}

          <h3>我竞拍的</h3>
          {myAuctions.bidding.length === 0 ? <div className="empty">暂无竞拍</div> : (
            myAuctions.bidding.map(auction => (
              <div key={auction.id} className="auction-card mini">
                <span>{auction.item_name} x{auction.quantity}</span>
                <span>当前: {auction.current_price.toFixed(2)}</span>
                <span>{formatTime(auction.end_at)}</span>
              </div>
            ))
          )}
        </div>
      )}

      {tab === 'create' && (
        <div className="create-auction">
          <div className="form-row">
            <label>物品类型</label>
            <select value={createForm.item_type} onChange={e => setCreateForm({ ...createForm, item_type: e.target.value, item_id: 0 })}>
              <option value="seed">种子</option>
              <option value="crop">作物</option>
            </select>
          </div>
          <div className="form-row">
            <label>选择物品</label>
            <select value={createForm.item_id} onChange={e => setCreateForm({ ...createForm, item_id: parseInt(e.target.value) })}>
              <option value={0}>请选择</option>
              {filteredInventory.map(item => (
                <option key={item.item_id} value={item.item_id}>
                  {item.item_name} (库存: {item.quantity})
                </option>
              ))}
            </select>
          </div>
          <div className="form-row">
            <label>数量</label>
            <input type="number" min={1} value={createForm.quantity} onChange={e => setCreateForm({ ...createForm, quantity: parseInt(e.target.value) || 1 })} />
          </div>
          <div className="form-row">
            <label>起拍价</label>
            <input type="number" min={1} value={createForm.start_price} onChange={e => setCreateForm({ ...createForm, start_price: parseFloat(e.target.value) || 1 })} />
          </div>
          <div className="form-row">
            <label>一口价 (可选)</label>
            <input type="number" placeholder="不设置则无一口价" value={createForm.buyout_price} onChange={e => setCreateForm({ ...createForm, buyout_price: e.target.value })} />
          </div>
          <div className="form-row">
            <label>持续时间</label>
            <select value={createForm.duration} onChange={e => setCreateForm({ ...createForm, duration: parseInt(e.target.value) })}>
              <option value={6}>6小时</option>
              <option value={12}>12小时</option>
              <option value={24}>24小时</option>
              <option value={48}>48小时</option>
              <option value={72}>72小时</option>
            </select>
          </div>
          <button className="create-btn" onClick={handleCreateAuction}>上架拍卖</button>
        </div>
      )}
    </div>
  )
}
