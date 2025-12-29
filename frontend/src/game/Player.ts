import { Container, Graphics } from 'pixi.js';
import { TILE_SIZE, TileMap } from './TileMap';

export class Player extends Container {
  private speed: number = 3;
  private targetX: number = 0;
  private targetY: number = 0;
  private isMoving: boolean = false;
  private tileMap: TileMap | null = null;

  constructor() {
    super();
    
    // 用彩色方块代替人物（后续可换成贴图）
    const body = new Graphics();
    body.fill(0x4a90d9);
    body.roundRect(2, 2, TILE_SIZE - 4, TILE_SIZE - 4, 3);
    body.fill();
    this.addChild(body);

    // 初始位置（地图中间）
    this.x = 8 * TILE_SIZE;
    this.y = 8 * TILE_SIZE;
    this.targetX = this.x;
    this.targetY = this.y;
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
    if (!this.isMoving) return;

    const dx = this.targetX - this.x;
    const dy = this.targetY - this.y;
    const distance = Math.sqrt(dx * dx + dy * dy);

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
