import { useEffect, useRef, useCallback, useState } from 'react'
import { Application, Assets, TilingSprite, Sprite, Container } from 'pixi.js'
import { useUser } from '../contexts/UserContext'
import { useToast } from './Toast'
import { api } from '../services/api'
import { ws } from '../services/websocket'
import type { Seed } from '../types'
import './Game.css'

const TILE_SIZE = 16
const SCALE = 3
const WIDTH = window.innerWidth
const HEIGHT = window.innerHeight

interface GameProps {
  onOpenMarket?: () => void
}

export default function Game({ onOpenMarket }: GameProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const appRef = useRef<Application | null>(null)
  const farmContainerRef = useRef<Container | null>(null)
  const [appReady, setAppReady] = useState(false)
  const { user, farms, inventory, refreshFarms, refreshInventory, refreshProfile } = useUser()
  const { showToast } = useToast()
  
  // 种植面板状态
  const [plantPanel, setPlantPanel] = useState<{ show: boolean; slotIndex: number }>({ show: false, slotIndex: -1 })
  const [seeds, setSeeds] = useState<Seed[]>([])
  const [planting, setPlanting] = useState(false)
  
  // 获取仓库中的种子（数量大于0）
  const seedItems = inventory.filter(i => i.item_type === 'seed' && i.quantity > 0)

  // 计算最接近正方形的行列数
  const getGridSize = useCallback((count: number) => {
    const cols = Math.ceil(Math.sqrt(count))
    const rows = Math.ceil(count / cols)
    return { cols, rows }
  }, [])

  useEffect(() => {
    const initGame = async () => {
      if (!containerRef.current || appRef.current) return

      const app = new Application()
      await app.init({
        width: WIDTH,
        height: HEIGHT,
        backgroundColor: 0x1a1a2e,
      })
      
      containerRef.current.appendChild(app.canvas)
      appRef.current = app

      // 加载贴图
      const grassTexture = await Assets.load('/tiny-nong/Tiles/tile_0000.png')
      
      // 铺满草地
      const grassLayer = new TilingSprite({
        texture: grassTexture,
        width: WIDTH,
        height: HEIGHT,
      })
      grassLayer.tileScale.set(SCALE)
      app.stage.addChild(grassLayer)

      // 创建农田容器
      const farmContainer = new Container()
      app.stage.addChild(farmContainer)
      farmContainerRef.current = farmContainer
      
      setAppReady(true)
    }

    initGame()

    return () => {
      if (appRef.current) {
        appRef.current.destroy(true)
        appRef.current = null
        setAppReady(false)
      }
    }
  }, [])

  // 当农田数据变化时更新渲染
  useEffect(() => {
    const updateFarms = async () => {
      if (!appReady || !appRef.current || !farmContainerRef.current) return

      const farmContainer = farmContainerRef.current
      farmContainer.removeChildren()

      const farmSlots = user?.farm_slots || 4
      const { cols, rows } = getGridSize(farmSlots)

      const dirtTexture = await Assets.load('/tiny-nong/Tiles/tile_0025.png')
      
      const farmSize = TILE_SIZE * SCALE * 2 // 每块农田大小
      const gap = 8
      const totalWidth = cols * farmSize + (cols - 1) * gap
      const totalHeight = rows * farmSize + (rows - 1) * gap
      const startX = (WIDTH - totalWidth) / 2
      const startY = (HEIGHT - totalHeight) / 2 + 50 // 留出顶部空间

      for (let i = 0; i < farmSlots; i++) {
        const row = Math.floor(i / cols)
        const col = i % cols
        const farm = farms.find(f => f.slot_index === i)

        // 泥土底层
        const dirt = new TilingSprite({
          texture: dirtTexture,
          width: farmSize,
          height: farmSize,
        })
        dirt.tileScale.set(SCALE)
        dirt.x = startX + col * (farmSize + gap)
        dirt.y = startY + row * (farmSize + gap)
        dirt.eventMode = 'static'
        dirt.cursor = 'pointer'
        
        // 点击事件
        const slotIndex = i
        dirt.on('pointerdown', () => {
          handleFarmClick(slotIndex, farm)
        })

        farmContainer.addChild(dirt)

        // 如果有作物且不是空地，显示作物
        if (farm && farm.status !== 'empty' && farm.seed_id && farm.seed) {
          try {
            const cropTexture = await Assets.load(`${farm.seed.icon}/${farm.stage}.png`)
            const cropSprite = new Sprite(cropTexture)
            cropSprite.x = dirt.x + farmSize / 2
            cropSprite.y = dirt.y + farmSize / 2
            cropSprite.anchor.set(0.5)
            cropSprite.scale.set(SCALE)
            farmContainer.addChild(cropSprite)
          } catch (e) {
            console.log('作物图片加载失败')
          }

          // 状态文字提示
          const { Text } = await import('pixi.js')
          const statusText = farm.status === 'mature' ? '可收获' : '成长中'
          const textColor = farm.status === 'mature' ? 0x00ff00 : 0xffff00
          const text = new Text({ 
            text: statusText, 
            style: { 
              fontSize: 14, 
              fill: textColor,
              fontWeight: 'bold',
              stroke: { color: 0x000000, width: 3 }
            } 
          })
          text.anchor.set(0.5)
          text.x = dirt.x + farmSize / 2
          text.y = dirt.y + farmSize - 12
          farmContainer.addChild(text)
        }
      }
    }

    updateFarms()
  }, [appReady, user?.farm_slots, farms, getGridSize])

  // 加载种子数据
  useEffect(() => {
    api.getSeeds().then(data => setSeeds(data.seeds || [])).catch(() => {})
  }, [])

  // 定时刷新农田状态（每10秒）
  useEffect(() => {
    const timer = setInterval(() => {
      refreshFarms()
    }, 10000)
    return () => clearInterval(timer)
  }, [refreshFarms])

  // 监听作物成熟通知
  useEffect(() => {
    const unsub = ws.on('crop_mature', () => {
      showToast('有作物成熟了！', 'success')
      refreshFarms()
    })
    return unsub
  }, [refreshFarms, showToast])

  const handleFarmClick = async (slotIndex: number, farm: typeof farms[0] | undefined) => {
    if (!farm || farm.status === 'empty') {
      // 空地：打开种植面板
      setPlantPanel({ show: true, slotIndex })
    } else if (farm.status === 'mature') {
      // 成熟：收获
      try {
        const result = await api.harvest(slotIndex)
        showToast(`收获 ${result.result.crop_name} x${result.result.yield}`, 'success')
        refreshFarms()
        refreshInventory()
        refreshProfile()
      } catch (e) {
        showToast((e as Error).message, 'error')
      }
    } else if (farm.status === 'growing') {
      showToast('作物还在生长中...', 'info')
    }
  }

  const handlePlant = async (seedId: number) => {
    if (planting) return
    setPlanting(true)
    try {
      await api.plant(plantPanel.slotIndex, seedId)
      showToast('种植成功！', 'success')
      refreshFarms()
      refreshInventory()
      setPlantPanel({ show: false, slotIndex: -1 })
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setPlanting(false)
    }
  }

  const getSeedInfo = (seedId: number) => seeds.find(s => s.id === seedId)

  return (
    <>
      <div ref={containerRef} />
      
      {/* 种植面板 */}
      {plantPanel.show && (
        <div className="plant-panel-overlay" onClick={() => setPlantPanel({ show: false, slotIndex: -1 })}>
          <div className="plant-panel" onClick={e => e.stopPropagation()}>
            <div className="plant-panel-header">
              <h3>选择种子</h3>
              <button className="plant-panel-close" onClick={() => setPlantPanel({ show: false, slotIndex: -1 })}>×</button>
            </div>
            <div className="plant-panel-body">
              {seedItems.length === 0 ? (
                <div className="plant-panel-empty">
                  <p>背包中没有种子</p>
                  <button 
                    className="plant-panel-btn"
                    onClick={() => {
                      setPlantPanel({ show: false, slotIndex: -1 })
                      onOpenMarket?.()
                    }}
                  >
                    去商店购买
                  </button>
                </div>
              ) : (
                <div className="plant-panel-grid">
                  {seedItems.map(item => {
                    const seed = getSeedInfo(item.item_id)
                    return (
                      <div 
                        key={item.id} 
                        className="plant-panel-item"
                        onClick={() => handlePlant(item.item_id)}
                      >
                        {seed?.icon && (
                          <img src={`${seed.icon}/0.png`} alt={seed.name} />
                        )}
                        <span className="plant-panel-item-name">{seed?.name || `种子#${item.item_id}`}</span>
                        <span className="plant-panel-item-qty">×{item.quantity}</span>
                      </div>
                    )
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  )
}
