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

export class TileMap extends Container {
  private tileTextures: Map<number, Texture> = new Map();
  private mapWidth: number = 0;
  private mapHeight: number = 0;

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

    // 渲染图层
    this.renderLayers(mapData.layers);
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
}
