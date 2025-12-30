import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react'
import type { User, UserStats, Farm, InventoryItem } from '../types'
import { api } from '../services/api'
import { ws } from '../services/websocket'

interface UserContextType {
  user: User | null
  stats: UserStats | null
  farms: Farm[]
  inventory: InventoryItem[]
  loading: boolean
  error: string | null
  login: (linuxdoId: string, nickname: string, avatar: string) => Promise<void>
  logout: () => void
  refreshProfile: () => Promise<void>
  refreshFarms: () => Promise<void>
  refreshInventory: () => Promise<void>
}

const UserContext = createContext<UserContextType | null>(null)

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [stats, setStats] = useState<UserStats | null>(null)
  const [farms, setFarms] = useState<Farm[]>([])
  const [inventory, setInventory] = useState<InventoryItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const refreshProfile = useCallback(async () => {
    try {
      const data = await api.getProfile()
      setUser(data.user)
      setStats(data.stats)
    } catch (e) {
      console.error('获取用户信息失败:', e)
    }
  }, [])

  const refreshFarms = useCallback(async () => {
    try {
      const data = await api.getFarms()
      setFarms(data.farms)
    } catch (e) {
      console.error('获取农田失败:', e)
    }
  }, [])

  const refreshInventory = useCallback(async () => {
    try {
      const data = await api.getInventory()
      setInventory(data.inventory)
    } catch (e) {
      console.error('获取仓库失败:', e)
    }
  }, [])

  const login = useCallback(async (linuxdoId: string, nickname: string, avatar: string) => {
    setLoading(true)
    setError(null)
    try {
      const data = await api.login(linuxdoId, nickname, avatar)
      setUser(data.user)
      ws.connect(data.token)
      await refreshFarms()
      await refreshInventory()
    } catch (e) {
      setError((e as Error).message)
      throw e
    } finally {
      setLoading(false)
    }
  }, [refreshFarms, refreshInventory])

  const logout = useCallback(() => {
    api.clearToken()
    ws.disconnect()
    setUser(null)
    setStats(null)
    setFarms([])
    setInventory([])
  }, [])

  // 初始化：检查本地 token
  useEffect(() => {
    const init = async () => {
      const token = api.getToken()
      if (token) {
        try {
          await refreshProfile()
          await refreshFarms()
          await refreshInventory()
          ws.connect(token)
        } catch {
          api.clearToken()
        }
      }
      setLoading(false)
    }
    init()
  }, [refreshProfile, refreshFarms, refreshInventory])

  // WebSocket 事件监听
  useEffect(() => {
    const unsubGold = ws.on('level_up', (data) => {
      if (user) {
        setUser({ ...user, level: data.new_level as number, gold: user.gold + (data.reward_gold as number) })
      }
    })

    const unsubCrop = ws.on('crop_mature', () => {
      refreshFarms()
    })

    return () => {
      unsubGold()
      unsubCrop()
    }
  }, [user, refreshFarms])

  return (
    <UserContext.Provider value={{
      user,
      stats,
      farms,
      inventory,
      loading,
      error,
      login,
      logout,
      refreshProfile,
      refreshFarms,
      refreshInventory,
    }}>
      {children}
    </UserContext.Provider>
  )
}

export function useUser() {
  const context = useContext(UserContext)
  if (!context) {
    throw new Error('useUser must be used within a UserProvider')
  }
  return context
}
