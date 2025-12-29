import { Container, Sprite, Assets } from 'pixi.js';
import { TILE_SIZE } from './TileMap';

// 可种植的瓷砖ID
const PLANTABLE_TILES = new Set([26]);

// 作物瓷砖ID（用于显示）
const CROP_TILES = [4, 5, 3]; // 小苗、成长、成熟

interface Crop {
  sprite: Sprite;
  tileX: number;
  tileY: number;
  stage: number; // 0=小苗, 1=成长, 2=成熟
  plantedAt: number;
}

export class FarmSystem extends Container {
  private crops: Map<string, Crop> = new Map();
  private cropTextures: Map<number, any> = new Map();
  private collisionMap: number[] = [];
  private mapWidth: number = 16;

  async init(collisionMap: number[], mapWidth: number): Promise<void> {
    this.collisionMap = collisionMap;
    this.mapWidth = mapWidth;

    // 预加载作物贴图
    for (const id of CROP_TILES) {
      const path = `/tiny-nong/Tiles/tile_${id.toString().padStart(4, '0')}.png`;
      this.cropTextures.set(id, await Assets.load(path));
    }
  }

  // 检查某个位置是否可种植
  canPlant(x: number, y: number): boolean {
    const tileX = Math.floor(x / TILE_SIZE);
    const tileY = Math.floor(y / TILE_SIZE);
    const key = `${tileX},${tileY}`;
    
    // 已经有作物了
    if (this.crops.has(key)) return false;
    
    // 检查是否是可种植的瓷砖
    const index = tileY * this.mapWidth + tileX;
    const tileId = this.collisionMap[index];
    return PLANTABLE_TILES.has(tileId);
  }

  // 种植作物
  plant(x: number, y: number): boolean {
    if (!this.canPlant(x, y)) return false;

    const tileX = Math.floor(x / TILE_SIZE);
    const tileY = Math.floor(y / TILE_SIZE);
    const key = `${tileX},${tileY}`;

    const texture = this.cropTextures.get(CROP_TILES[0]);
    const sprite = new Sprite(texture);
    sprite.x = tileX * TILE_SIZE;
    sprite.y = tileY * TILE_SIZE;
    this.addChild(sprite);

    const crop: Crop = {
      sprite,
      tileX,
      tileY,
      stage: 0,
      plantedAt: Date.now(),
    };
    this.crops.set(key, crop);

    return true;
  }

  // 更新作物状态（生长）
  update(): void {
    const now = Date.now();
    const GROW_TIME = 5000; // 5秒生长一个阶段

    for (const crop of this.crops.values()) {
      const elapsed = now - crop.plantedAt;
      const newStage = Math.min(2, Math.floor(elapsed / GROW_TIME));

      if (newStage !== crop.stage) {
        crop.stage = newStage;
        const texture = this.cropTextures.get(CROP_TILES[newStage]);
        crop.sprite.texture = texture;
      }
    }
  }

  // 收获作物
  harvest(x: number, y: number): boolean {
    const tileX = Math.floor(x / TILE_SIZE);
    const tileY = Math.floor(y / TILE_SIZE);
    const key = `${tileX},${tileY}`;

    const crop = this.crops.get(key);
    if (!crop || crop.stage < 2) return false; // 未成熟

    this.removeChild(crop.sprite);
    this.crops.delete(key);
    return true;
  }
}
