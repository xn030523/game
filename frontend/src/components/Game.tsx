import { useEffect, useRef } from 'react'
import { Application, Assets, TilingSprite } from 'pixi.js'

const TILE_SIZE = 16
const SCALE = 3 // 放大倍数，让像素风更清晰
const WIDTH = window.innerWidth
const HEIGHT = window.innerHeight

export default function Game() {
  const containerRef = useRef<HTMLDivElement>(null)
  const appRef = useRef<Application | null>(null)

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
      const dirtTexture = await Assets.load('/tiny-nong/Tiles/tile_0025.png')
      
      // 铺满草地
      const grassLayer = new TilingSprite({
        texture: grassTexture,
        width: WIDTH,
        height: HEIGHT,
      })
      grassLayer.tileScale.set(SCALE)
      app.stage.addChild(grassLayer)

      // 四块泥土农田
      const farmSize = TILE_SIZE * SCALE * 3 // 每块农田 3x3 格
      const gap = 20 // 间距
      const startX = (WIDTH - (farmSize * 2 + gap)) / 2
      const startY = (HEIGHT - (farmSize * 2 + gap)) / 2

      for (let row = 0; row < 2; row++) {
        for (let col = 0; col < 2; col++) {
          const dirt = new TilingSprite({
            texture: dirtTexture,
            width: farmSize,
            height: farmSize,
          })
          dirt.tileScale.set(SCALE)
          dirt.x = startX + col * (farmSize + gap)
          dirt.y = startY + row * (farmSize + gap)
          app.stage.addChild(dirt)
        }
      }
    }

    initGame()

    return () => {
      if (appRef.current) {
        appRef.current.destroy(true)
        appRef.current = null
      }
    }
  }, [])

  return <div ref={containerRef} />
}
