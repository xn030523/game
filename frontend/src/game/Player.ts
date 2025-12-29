import { Container, Sprite, Texture, Assets } from 'pixi.js';
import { TILE_SIZE, TileMap } from './TileMap';

const PLAYER_SIZE = 32; // 显示大小
const PLAYER_COLOR = 'green'; // 可选: green, pink, yellow, purple, beige

export class Player extends Container {
  private speed: number = 1;
  private targetX: number = 0;
  private targetY: number = 0;
  private isMoving: boolean = false;
  private tileMap: TileMap | null = null;
  private sprite: Sprite | null = null;
  private textures: { idle: Texture; walkA: Texture; walkB: Texture } | null = null;
  private walkFrame: number = 0;
  private walkTimer: number = 0;

  constructor() {
    super();
    
    // 初始位置（地图中间）
    this.x = 8 * TILE_SIZE;
    this.y = 8 * TILE_SIZE;
    this.targetX = this.x;
    this.targetY = this.y;
  }

  async loadTextures(): Promise<void> {
    const idle = await Assets.load(`/characters/character_${PLAYER_COLOR}_idle.png`);
    const walkA = await Assets.load(`/characters/character_${PLAYER_COLOR}_walk_a.png`);
    const walkB = await Assets.load(`/characters/character_${PLAYER_COLOR}_walk_b.png`);
    
    this.textures = { idle, walkA, walkB };
    
    this.sprite = new Sprite(idle);
    this.sprite.anchor.set(0.5, 1); // 底部中心为锚点
    this.sprite.scale.set(PLAYER_SIZE / 128); // 缩放到合适大小
    this.addChild(this.sprite);
  }

  setTileMap(tileMap: TileMap): void {
    this.tileMap = tileMap;
  }

  // 设置移动目标（由外部调用）
  moveTo(x: number, y: number): void {
    const mapSize = 16 * TILE_SIZE;
    const newX = Math.max(0, Math.min(x - TILE_SIZE / 2, mapSize - TILE_SIZE));
    const newY = Math.max(0, Math.min(y - TILE_SIZE / 2, mapSize - TILE_SIZE));
    
    // 检查目标位置是否可通行
    if (this.tileMap && !this.tileMap.isWalkable(newX + TILE_SIZE / 2, newY + TILE_SIZE / 2)) {
      return; // 不可通行，不移动
    }
    
    this.targetX = newX;
    this.targetY = newY;
    this.isMoving = true;
  }

  update(): void {
    if (!this.sprite || !this.textures) return;

    if (!this.isMoving) {
      this.sprite.texture = this.textures.idle;
      return;
    }

    const dx = this.targetX - this.x;
    const dy = this.targetY - this.y;
    const distance = Math.sqrt(dx * dx + dy * dy);

    // 行走动画
    this.walkTimer++;
    if (this.walkTimer >= 10) {
      this.walkTimer = 0;
      this.walkFrame = 1 - this.walkFrame;
      this.sprite.texture = this.walkFrame === 0 ? this.textures.walkA : this.textures.walkB;
    }

    // 面向方向
    if (dx < 0) {
      this.sprite.scale.x = -PLAYER_SIZE / 128;
    } else if (dx > 0) {
      this.sprite.scale.x = PLAYER_SIZE / 128;
    }

    if (distance < this.speed) {
      this.x = this.targetX;
      this.y = this.targetY;
      this.isMoving = false;
    } else {
      const nextX = this.x + (dx / distance) * this.speed;
      const nextY = this.y + (dy / distance) * this.speed;
      
      // 检查下一步是否可通行
      if (this.tileMap && !this.tileMap.isWalkable(nextX + TILE_SIZE / 2, nextY + TILE_SIZE / 2)) {
        this.isMoving = false;
        return;
      }
      
      this.x = nextX;
      this.y = nextY;
    }
  }
}
