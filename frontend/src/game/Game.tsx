import { useEffect, useRef } from 'react';
import { Application, Container, Rectangle } from 'pixi.js';
import { createFarmScene, TILE_SIZE } from './scenes/FarmScene';
import { Player } from './Player';
import { FarmSystem } from './FarmSystem';
import { GameUI } from './UI';

const MAP_SIZE = 16;
const SIDE_PANEL_WIDTH = 150; // 左右侧边栏宽度

export function Game() {
  const containerRef = useRef<HTMLDivElement>(null);
  const appRef = useRef<Application | null>(null);

  useEffect(() => {
    if (!containerRef.current || appRef.current) return;

    const initGame = async () => {
      const app = new Application();
      const mapBaseSize = MAP_SIZE * TILE_SIZE;
      
      // 计算响应式缩放（地图高度铺满屏幕）
      const calcScale = () => window.innerHeight / mapBaseSize;
      
      // 计算侧边栏宽度
      const calcSideWidth = () => {
        const scale = calcScale();
        const mapPixelWidth = mapBaseSize * scale;
        return (window.innerWidth - mapPixelWidth) / 2;
      };
      
      let scale = calcScale();
      
      await app.init({
        width: window.innerWidth,
        height: window.innerHeight,
        backgroundColor: 0x1a1a2e,
        resizeTo: window,
      });

      appRef.current = app;
      containerRef.current?.appendChild(app.canvas);

      // UI（左右侧边栏）
      const sideWidth = calcSideWidth();
      const ui = new GameUI(sideWidth, sideWidth, window.innerHeight);
      app.stage.addChild(ui);

      // 游戏容器（地图居中，高度铺满）
      const gameContainer = new Container();
      const updateLayout = () => {
        scale = calcScale();
        const mapPixelSize = mapBaseSize * scale;
        const newSideWidth = calcSideWidth();
        gameContainer.x = newSideWidth;
        gameContainer.y = 0;
        gameContainer.scale.set(scale);
        ui.setRightPanelX(newSideWidth + mapPixelSize);
      };
      updateLayout();
      app.stage.addChild(gameContainer);
      
      // 窗口大小改变时响应式调整
      window.addEventListener('resize', updateLayout);

      // 加载农场场景
      const farmScene = await createFarmScene();
      gameContainer.addChild(farmScene);

      // 添加种植系统
      const farmSystem = new FarmSystem();
      await farmSystem.init(farmScene.getCollisionMap(), farmScene.getMapWidth());
      gameContainer.addChild(farmSystem);

      // 添加玩家
      const player = new Player();
      await player.loadTextures();
      player.setTileMap(farmScene); // 设置地图用于碰撞检测
      gameContainer.addChild(player);

      // 鼠标点击事件（只在地图区域）
      gameContainer.eventMode = 'static';
      gameContainer.hitArea = new Rectangle(0, 0, MAP_SIZE * TILE_SIZE, MAP_SIZE * TILE_SIZE);
      gameContainer.on('pointerdown', (e) => {
        const currentScale = gameContainer.scale.x;
        const x = (e.global.x - gameContainer.x) / currentScale;
        const y = (e.global.y - gameContainer.y) / currentScale;
        
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
