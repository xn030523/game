import { Container, Sprite, Texture, Assets } from 'pixi.js';

export const TILE_SIZE = 16;

interface TiledLayer {
  data?: number[];
  layers?: TiledLayer[];
  width: number;
  height: number;
  visible: boolean;
  type: string;
}

interface TiledMap {
  width: number;
  height: number;
  layers: TiledLayer[];
}

// 不可通行的瓷砖ID（房子等）
const BLOCKED_TILES = new Set([
  49, 50, 51, 52, 61, 62, 63, 64, 73, 74, 86, 76,  // 房子1
  53, 54, 55, 56, 65, 66, 67, 68, 77, 78, 90, 80,  // 房子2
]);

export class TileMap extends Container {
  private tileTextures: Map<number, Texture> = new Map();
  private mapWidth: number = 0;
  private mapHeight: number = 0;
  private collisionMap: number[] = [];

  async loadFromTiled(jsonPath: string): Promise<void> {
    const response = await fetch(jsonPath);
    const mapData: TiledMap = await response.json();
    
    this.mapWidth = mapData.width;
    this.mapHeight = mapData.height;

    // 收集所有用到的瓷砖 ID
    const tileIds = new Set<number>();
    this.collectTileIds(mapData.layers, tileIds);

    // 加载瓷砖纹理
    for (const id of tileIds) {
      if (id > 0) {
        const fileId = id - 1; // Tiled ID 从 1 开始，文件从 0 开始
        const path = `/tiny-nong/Tiles/tile_${fileId.toString().padStart(4, '0')}.png`;
        try {
          const texture = await Assets.load(path);
          this.tileTextures.set(id, texture);
        } catch (e) {
          console.warn(`Failed to load tile ${fileId}`);
        }
      }
    }

    // 保存碰撞数据并渲染图层
    this.buildCollisionMap(mapData.layers);
    this.renderLayers(mapData.layers);
  }

  private buildCollisionMap(layers: TiledLayer[]): void {
    // 反转顺序：底层先，上层后（上层覆盖底层）
    const reversed = [...layers].reverse();
    for (const layer of reversed) {
      if (layer.layers) {
        this.buildCollisionMap(layer.layers);
      } else if (layer.data) {
        // 合并所有图层的碰撞数据
        if (this.collisionMap.length === 0) {
          this.collisionMap = [...layer.data];
        } else {
          for (let i = 0; i < layer.data.length; i++) {
            if (layer.data[i] !== 0) {
              this.collisionMap[i] = layer.data[i];
            }
          }
        }
      }
    }
  }

  // 检查某个像素位置是否可通行
  isWalkable(x: number, y: number): boolean {
    const tileX = Math.floor(x / TILE_SIZE);
    const tileY = Math.floor(y / TILE_SIZE);
    
    if (tileX < 0 || tileX >= this.mapWidth || tileY < 0 || tileY >= this.mapHeight) {
      return false;
    }
    
    const index = tileY * this.mapWidth + tileX;
    const tileId = this.collisionMap[index];
    return !BLOCKED_TILES.has(tileId);
  }

  private collectTileIds(layers: TiledLayer[], ids: Set<number>): void {
    for (const layer of layers) {
      if (layer.layers) {
        this.collectTileIds(layer.layers, ids);
      } else if (layer.data) {
        for (const id of layer.data) {
          ids.add(id);
        }
      }
    }
  }

  private renderLayers(layers: TiledLayer[]): void {
    // 反转顺序：底层先渲染，上层后渲染
    const reversed = [...layers].reverse();
    for (const layer of reversed) {
      if (layer.layers) {
        this.renderLayers(layer.layers);
      } else if (layer.data) {
        this.renderLayer(layer.data, layer.width);
      }
    }
  }

  private renderLayer(data: number[], width: number): void {
    for (let i = 0; i < data.length; i++) {
      const tileId = data[i];
      if (tileId === 0) continue;
      
      const texture = this.tileTextures.get(tileId);
      if (texture) {
        const sprite = new Sprite(texture);
        sprite.x = (i % width) * TILE_SIZE;
        sprite.y = Math.floor(i / width) * TILE_SIZE;
        this.addChild(sprite);
      }
    }
  }

  getWidth(): number {
    return this.mapWidth * TILE_SIZE;
  }

  getHeight(): number {
    return this.mapHeight * TILE_SIZE;
  }

  getCollisionMap(): number[] {
    return this.collisionMap;
  }

  getMapWidth(): number {
    return this.mapWidth;
  }
}
