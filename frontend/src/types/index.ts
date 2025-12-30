// 用户
export interface User {
  id: number
  linuxdo_id: string
  charity_id: string
  nickname: string
  avatar: string
  level: number
  gold: number
  farm_slots: number
  contribution: number
  achievement_points: number
}

export interface UserStats {
  total_planted: number
  total_harvested: number
  total_sold: number
  total_bought: number
  total_gold_earned: number
  total_gold_spent: number
  total_friends: number
  total_stolen: number
  login_days: number
  consecutive_days: number
}

// 种子和作物
export interface Seed {
  id: number
  name: string
  description: string
  icon: string
  base_price: number
  current_price: number
  price_change: number   // 涨跌幅 %
  buy_volume: number     // 24h买入量
  sell_volume: number    // 24h卖出量
  trend: string          // up/down/stable
  growth_time: number
  stages: number
  unlock_level: number
}

export interface Crop {
  id: number
  seed_id: number
  name: string
  icon: string
  base_sell_price: number
  current_price: number
  price_change: number
  buy_volume: number
  sell_volume: number
  trend: string
  yield_min: number
  yield_max: number
}

// 农田
export interface Farm {
  id: number
  slot_index: number
  seed_id: number | null
  planted_at: string | null
  stage: number
  status: 'empty' | 'growing' | 'mature' | 'withered'
  seed?: Seed
}

// 仓库物品
export interface InventoryItem {
  id: number
  item_type: 'seed' | 'crop' | 'tool' | 'material'
  item_id: number
  item_name?: string
  quantity: number
}

// 股票
export interface Stock {
  id: number
  code: string
  name: string
  current_price: number
  change_percent: number
  trend: 'up' | 'down' | 'stable'
  max_leverage: number
}

export interface UserStock {
  id: number
  stock_id: number
  shares: number
  avg_cost: number
  realized_profit: number
  stock?: Stock
}

export interface LeveragePosition {
  id: number
  stock_id: number
  position_type: 'long' | 'short'
  leverage: number
  shares: number
  entry_price: number
  margin: number
  liquidation_price: number
  unrealized_profit: number
  status: 'open' | 'closed' | 'liquidated'
  stock?: Stock
}

// 拍卖
export interface Auction {
  id: number
  seller_id: number
  seller?: { nickname: string }
  item_type: string
  item_id: number
  item_name?: string
  quantity: number
  start_price: number
  current_price: number
  buyout_price: number | null
  highest_bidder: number | null
  bidder?: { nickname: string }
  bid_count: number
  status: 'active' | 'sold' | 'expired' | 'cancelled'
  start_at: string
  end_at: string
}

// 黑市
export interface BlackmarketItem {
  id: number
  name: string
  description: string
  icon: string
  item_type: string
  price: number
  total_stock: number
  sold_count: number
  unlock_level: number
}

// 好友
export interface Friend {
  id: number
  nickname: string
  avatar: string
  level: number
}

// 成就
export interface Achievement {
  id: number
  name: string
  description: string
  icon: string
  category: string
  condition_value: number
  reward_type: string
  reward_value: number
  points: number
}

export interface UserAchievement {
  id: number
  achievement_id: number
  progress: number
  is_completed: boolean
  is_claimed: boolean
  achievement?: Achievement
}

// 聊天消息
export interface ChatMessage {
  id: number
  user_id: number
  nickname?: string
  avatar?: string
  content: string
  created_at: string
  user?: {
    nickname: string
    avatar: string
  }
}

// 排行榜
export interface RankingItem {
  rank_position: number
  user_id: number
  score: number
  user?: User
}

// WebSocket 消息
export interface WSMessage {
  type: string
  data: Record<string, unknown>
  timestamp: number
}
