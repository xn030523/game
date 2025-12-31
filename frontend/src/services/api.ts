import type { User, UserStats, Seed, Crop, Farm, InventoryItem, Stock, UserStock, LeveragePosition, KLineData, Auction, BlackmarketItem, Friend, Achievement, UserAchievement, ChatMessage, RankingItem } from '../types'

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8080/api/v1'

class ApiService {
  private token: string | null = null

  setToken(token: string) {
    this.token = token
    localStorage.setItem('token', token)
  }

  getToken(): string | null {
    if (!this.token) {
      this.token = localStorage.getItem('token')
    }
    return this.token
  }

  clearToken() {
    this.token = null
    localStorage.removeItem('token')
  }

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    }

    const token = this.getToken()
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    const response = await fetch(`${API_BASE}${endpoint}`, {
      ...options,
      headers: { ...headers, ...options.headers },
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.error || '请求失败')
    }

    return data
  }

  // === 认证 ===
  async login(linuxdoId: string, nickname: string, avatar: string) {
    const data = await this.request<{ token: string; user: User; is_new: boolean }>('/auth/linuxdo/callback', {
      method: 'POST',
      body: JSON.stringify({ linuxdo_id: linuxdoId, nickname, avatar }),
    })
    this.setToken(data.token)
    return data
  }

  async devLogin(username: string) {
    const data = await this.request<{ token: string; user: User; is_new: boolean }>('/auth/dev-login', {
      method: 'POST',
      body: JSON.stringify({ username }),
    })
    this.setToken(data.token)
    return data
  }

  // === 用户 ===
  async getProfile() {
    return this.request<{ user: User; stats: UserStats }>('/user/profile')
  }

  async expandFarm() {
    return this.request<{ message: string }>('/user/expand-farm', { method: 'POST' })
  }

  async getFarmSlotPrice() {
    return this.request<{ current_slots: number; next_price: number }>('/user/farm-slot-price')
  }

  async levelUp() {
    return this.request<{ message: string }>('/user/level-up', { method: 'POST' })
  }

  // === 农场 ===
  async getSeeds() {
    return this.request<{ seeds: Seed[] }>('/farm/seeds')
  }

  async getCrops() {
    return this.request<{ crops: Crop[] }>('/farm/crops')
  }

  async getFarms() {
    return this.request<{ farms: Farm[] }>('/farm/farms')
  }

  async getInventory() {
    return this.request<{ inventory: InventoryItem[] }>('/farm/inventory')
  }

  async buySeed(seedId: number, quantity: number) {
    return this.request<{ message: string }>('/farm/buy-seed', {
      method: 'POST',
      body: JSON.stringify({ seed_id: seedId, quantity }),
    })
  }

  async plant(slotIndex: number, seedId: number) {
    return this.request<{ message: string }>('/farm/plant', {
      method: 'POST',
      body: JSON.stringify({ slot_index: slotIndex, seed_id: seedId }),
    })
  }

  async harvest(slotIndex: number) {
    return this.request<{ message: string; result: { crop_id: number; crop_name: string; yield: number; seed_dropped: number; seed_name: string } }>('/farm/harvest', {
      method: 'POST',
      body: JSON.stringify({ slot_index: slotIndex }),
    })
  }

  async sellCrop(cropId: number, quantity: number) {
    return this.request<{ message: string; earning: number }>('/farm/sell', {
      method: 'POST',
      body: JSON.stringify({ crop_id: cropId, quantity }),
    })
  }

  async recycleSeed(seedId: number, quantity: number) {
    return this.request<{ message: string; earning: number }>('/farm/recycle', {
      method: 'POST',
      body: JSON.stringify({ seed_id: seedId, quantity }),
    })
  }

  // === 股票 ===
  async getStocks() {
    return this.request<{ stocks: Stock[] }>('/stock/list')
  }

  async getStock(id: number) {
    return this.request<{ stock: Stock }>(`/stock/${id}`)
  }

  async getKLine(stockId: number, period = '1d', limit = 30) {
    return this.request<{ prices: KLineData[] }>(`/stock/${stockId}/kline?period=${period}&limit=${limit}`)
  }

  async getStockNews(limit = 20) {
    return this.request<{ news: { id: number; stock_code: string; stock_name: string; title: string; effect: number; created_at: string }[] }>(`/stock/news?limit=${limit}`)
  }

  async getTodayProfit(date = '') {
    const url = date ? `/stock/today-profit?date=${date}` : '/stock/today-profit'
    return this.request<{ profits: { id: number; stock_name: string; amount: number; change_percent: number; shares: number; created_at: string }[]; total: number }>(url)
  }

  async buyStock(stockId: number, shares: number) {
    return this.request<{ message: string }>('/stock/buy', {
      method: 'POST',
      body: JSON.stringify({ stock_id: stockId, shares }),
    })
  }

  async sellStock(stockId: number, shares: number) {
    return this.request<{ message: string; profit: number }>('/stock/sell', {
      method: 'POST',
      body: JSON.stringify({ stock_id: stockId, shares }),
    })
  }

  async openLong(stockId: number, leverage: number, margin: number) {
    return this.request<{ message: string; position: LeveragePosition }>('/stock/long', {
      method: 'POST',
      body: JSON.stringify({ stock_id: stockId, leverage, margin }),
    })
  }

  async openShort(stockId: number, leverage: number, margin: number) {
    return this.request<{ message: string; position: LeveragePosition }>('/stock/short', {
      method: 'POST',
      body: JSON.stringify({ stock_id: stockId, leverage, margin }),
    })
  }

  async closePosition(positionId: number) {
    return this.request<{ message: string; profit: number }>('/stock/close-position', {
      method: 'POST',
      body: JSON.stringify({ position_id: positionId }),
    })
  }

  async getMyStocks() {
    return this.request<{ stocks: UserStock[] }>('/stock/my-stocks')
  }

  async getMyPositions(status = 'open') {
    return this.request<{ positions: LeveragePosition[] }>(`/stock/my-positions?status=${status}`)
  }

  // === 拍卖 ===
  async getAuctions(itemType = '', page = 1) {
    return this.request<{ auctions: Auction[]; total: number }>(`/auction/list?item_type=${itemType}&page=${page}`)
  }

  async getAuction(id: number) {
    return this.request<{ auction: Auction; bids: unknown[] }>(`/auction/${id}`)
  }

  async createAuction(itemType: string, itemId: number, quantity: number, startPrice: number, buyoutPrice: number | null, duration: number) {
    return this.request<{ message: string; auction: Auction }>('/auction/create', {
      method: 'POST',
      body: JSON.stringify({ item_type: itemType, item_id: itemId, quantity, start_price: startPrice, buyout_price: buyoutPrice, duration }),
    })
  }

  async placeBid(auctionId: number, bidPrice: number) {
    return this.request<{ message: string }>(`/auction/${auctionId}/bid`, {
      method: 'POST',
      body: JSON.stringify({ bid_price: bidPrice }),
    })
  }

  async buyoutAuction(auctionId: number) {
    return this.request<{ message: string }>(`/auction/${auctionId}/buyout`, { method: 'POST' })
  }

  async cancelAuction(auctionId: number) {
    return this.request<{ message: string }>(`/auction/${auctionId}/cancel`, { method: 'POST' })
  }

  async getMyAuctions() {
    return this.request<{ selling: Auction[]; bidding: Auction[] }>('/auction/my')
  }

  // === 黑市 ===
  async getBlackmarket() {
    return this.request<{ batch: unknown; items: BlackmarketItem[]; next_refresh: string }>('/blackmarket')
  }

  async buyBlackmarketItem(itemId: number, quantity: number) {
    return this.request<{ message: string }>('/blackmarket/buy', {
      method: 'POST',
      body: JSON.stringify({ item_id: itemId, quantity }),
    })
  }

  // === 好友 ===
  async getFriends() {
    return this.request<{ friends: Friend[] }>('/friend/list')
  }

  async getFriendRequests() {
    return this.request<{ requests: unknown[] }>('/friend/requests')
  }

  async sendFriendRequest(friendId: number) {
    return this.request<{ message: string }>('/friend/request', {
      method: 'POST',
      body: JSON.stringify({ friend_id: friendId }),
    })
  }

  async acceptFriendRequest(id: number) {
    return this.request<{ message: string }>(`/friend/accept/${id}`, { method: 'POST' })
  }

  async stealCrop(friendId: number, slotIndex: number) {
    return this.request<{ message: string; amount: number }>('/friend/steal', {
      method: 'POST',
      body: JSON.stringify({ friend_id: friendId, slot_index: slotIndex }),
    })
  }

  // === 成就 ===
  async getAchievements() {
    return this.request<{ achievements: Achievement[] }>('/achievement/list')
  }

  async getMyAchievements() {
    return this.request<{ achievements: UserAchievement[] }>('/achievement/my')
  }

  async claimAchievement(id: number) {
    return this.request<{ message: string }>(`/achievement/${id}/claim`, { method: 'POST' })
  }

  // === 签到 ===
  async checkin() {
    return this.request<{ message: string; reward: number }>('/checkin', { method: 'POST' })
  }

  async getMonthCheckins() {
    return this.request<{ checkins: unknown[] }>('/checkin/month')
  }

  // === 聊天 ===
  async getChatMessages(channel = 'world', limit = 100) {
    return this.request<{ messages: ChatMessage[] }>(`/chat/messages?channel=${channel}&limit=${limit}`)
  }

  async sendChatMessage(channel: string, content: string) {
    return this.request<{ message: string }>('/chat/send', {
      method: 'POST',
      body: JSON.stringify({ channel, content }),
    })
  }

  // === 排行榜 ===
  async getRankings(type = 'gold', limit = 100) {
    return this.request<{ rankings: RankingItem[] }>(`/ranking?type=${type}&limit=${limit}`)
  }
}

export const api = new ApiService()
