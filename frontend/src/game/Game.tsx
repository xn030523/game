import { useEffect, useRef } from 'react';
import { Application, Container } from 'pixi.js';
import { createFarmScene, TILE_SIZE } from './scenes/FarmScene';
import { Player } from './Player';
import { FarmSystem } from './FarmSystem';

const MAP_SIZE = 16;
const SCALE = 3;

export function Game() {
  const containerRef = useRef<HTMLDivElement>(null);
  const appRef = useRef<Application | null>(null);

  useEffect(() => {
    if (!containerRef.current || appRef.current) return;

    const initGame = async () => {
      const app = new Application();
      
      await app.init({
        width: MAP_SIZE * TILE_SIZE * SCALE,
        height: MAP_SIZE * TILE_SIZE * SCALE,
        backgroundColor: 0x1a1a2e,
      });

      appRef.current = app;
      containerRef.current?.appendChild(app.canvas);

      // 游戏容器（用于统一缩放）
      const gameContainer = new Container();
      gameContainer.scale.set(SCALE);
      app.stage.addChild(gameContainer);

      // 加载农场场景
      const farmScene = await createFarmScene();
      gameContainer.addChild(farmScene);

      // 添加种植系统
      const farmSystem = new FarmSystem();
      await farmSystem.init(farmScene.getCollisionMap(), farmScene.getMapWidth());
      gameContainer.addChild(farmSystem);

      // 添加玩家
      const player = new Player();
      player.setTileMap(farmScene); // 设置地图用于碰撞检测
      gameContainer.addChild(player);

      // 鼠标点击事件
      app.stage.eventMode = 'static';
      app.stage.hitArea = app.screen;
      app.stage.on('pointerdown', (e) => {
        const x = e.global.x / SCALE;
        const y = e.global.y / SCALE;
        
        // 右键收获
        if (e.button === 2) {
          farmSystem.harvest(x, y);
          return;
        }
        
        // 左键：先尝试种植，如果不能种植则移动
        if (!farmSystem.plant(x, y)) {
          player.moveTo(x, y);
        }
      });

      // 禁用右键菜单
      app.canvas.addEventListener('contextmenu', (e) => e.preventDefault());

      // 游戏循环
      app.ticker.add(() => {
        player.update();
        farmSystem.update();
      });
    };

    initGame();

    return () => {
      if (appRef.current) {
        appRef.current.destroy(true);
        appRef.current = null;
      }
    };
  }, []);

  return (
    <div 
      ref={containerRef} 
      style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center',
        minHeight: '100vh',
        backgroundColor: '#1a1a2e'
      }} 
    />
  );
}
