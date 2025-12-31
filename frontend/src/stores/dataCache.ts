import { api } from '../services/api'
import type { Seed, Crop } from '../types'

interface CacheItem<T> {
  data: T
  expireAt: number
}

class DataCache {
  private cache: Map<string, CacheItem<unknown>> = new Map()
  private pendingRequests: Map<string, Promise<unknown>> = new Map()

  private set<T>(key: string, data: T, ttlMs: number = 5 * 60 * 1000) {
    this.cache.set(key, {
      data,
      expireAt: Date.now() + ttlMs
    })
  }

  private get<T>(key: string): T | null {
    const item = this.cache.get(key)
    if (!item) return null
    if (Date.now() > item.expireAt) {
      this.cache.delete(key)
      return null
    }
    return item.data as T
  }

  async getSeeds(): Promise<Seed[]> {
    const cached = this.get<Seed[]>('seeds')
    if (cached) return cached

    const pending = this.pendingRequests.get('seeds')
    if (pending) return pending as Promise<Seed[]>

    const request = api.getSeeds().then(data => {
      const seeds = data.seeds || []
      this.set('seeds', seeds)
      this.pendingRequests.delete('seeds')
      return seeds
    }).catch(err => {
      this.pendingRequests.delete('seeds')
      throw err
    })

    this.pendingRequests.set('seeds', request)
    return request
  }

  async getCrops(): Promise<Crop[]> {
    const cached = this.get<Crop[]>('crops')
    if (cached) return cached

    const pending = this.pendingRequests.get('crops')
    if (pending) return pending as Promise<Crop[]>

    const request = api.getCrops().then(data => {
      const crops = data.crops || []
      this.set('crops', crops)
      this.pendingRequests.delete('crops')
      return crops
    }).catch(err => {
      this.pendingRequests.delete('crops')
      throw err
    })

    this.pendingRequests.set('crops', request)
    return request
  }

  getSeedById(id: number): Seed | undefined {
    const seeds = this.get<Seed[]>('seeds')
    return seeds?.find(s => s.id === id)
  }

  getCropById(id: number): Crop | undefined {
    const crops = this.get<Crop[]>('crops')
    return crops?.find(c => c.id === id)
  }

  invalidate(key?: string) {
    if (key) {
      this.cache.delete(key)
    } else {
      this.cache.clear()
    }
  }
}

export const dataCache = new DataCache()
