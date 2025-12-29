import { useEffect, useRef } from 'react';
import { Application } from 'pixi.js';
import { createFarmScene, TILE_SIZE } from './scenes/FarmScene';

const MAP_SIZE = 16;
const SCALE = 3; // 放大3倍方便查看

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

      // 加载农场场景
      const farmScene = await createFarmScene();
      farmScene.scale.set(SCALE);
      app.stage.addChild(farmScene);
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
