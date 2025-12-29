import { Container, Graphics, Text, TextStyle } from 'pixi.js';

export class GameUI extends Container {
  private username: Text;
  
  constructor(leftWidth: number, rightWidth: number, screenHeight: number) {
    super();
    
    const padding = 15;
    
    // ========== 左侧面板 ==========
    const leftPanel = new Container();
    leftPanel.x = 0;
    this.addChild(leftPanel);
    
    // 左侧背景
    const leftBg = new Graphics();
    leftBg.rect(0, 0, leftWidth, screenHeight);
    leftBg.fill(0x1a1a2e);
    leftPanel.addChild(leftBg);
    
    // 人物名字（左上）
    const nameStyle = new TextStyle({
      fontFamily: 'Arial',
      fontSize: 16,
      fill: 0xffffff,
    });
    this.username = new Text({ text: '玩家001', style: nameStyle });
    this.username.x = padding;
    this.username.y = padding;
    leftPanel.addChild(this.username);
    
    // 背包按钮（左下）
    const bagBtn = this.createButton('背包', padding, screenHeight - 60, leftWidth - padding * 2, 40);
    bagBtn.on('pointerdown', () => console.log('打开背包'));
    leftPanel.addChild(bagBtn);
    
    // ========== 右侧面板 ==========
    const rightPanel = new Container();
    rightPanel.x = leftWidth; // 临时，需要外部设置
    this.addChild(rightPanel);
    this.rightPanel = rightPanel;
    this.rightWidth = rightWidth;
    
    // 右侧背景
    const rightBg = new Graphics();
    rightBg.rect(0, 0, rightWidth, screenHeight);
    rightBg.fill(0x1a1a2e);
    rightPanel.addChild(rightBg);
    
    // 小地图占位（右上）
    const minimapBg = new Graphics();
    minimapBg.roundRect(padding, padding, rightWidth - padding * 2, 100, 5);
    minimapBg.fill(0x2d3748);
    minimapBg.stroke({ width: 1, color: 0x4a5568 });
    rightPanel.addChild(minimapBg);
    
    const minimapLabel = new Text({ text: '小地图', style: new TextStyle({ fontSize: 12, fill: 0x888888 }) });
    minimapLabel.x = padding + 10;
    minimapLabel.y = padding + 10;
    rightPanel.addChild(minimapLabel);
    
    // 聊天区域（右下）
    const chatBg = new Graphics();
    chatBg.roundRect(padding, screenHeight - 150, rightWidth - padding * 2, 130, 5);
    chatBg.fill(0x2d3748);
    chatBg.stroke({ width: 1, color: 0x4a5568 });
    rightPanel.addChild(chatBg);
    
    const chatLabel = new Text({ text: '聊天', style: new TextStyle({ fontSize: 12, fill: 0x888888 }) });
    chatLabel.x = padding + 10;
    chatLabel.y = screenHeight - 140;
    rightPanel.addChild(chatLabel);
  }
  
  private rightPanel: Container;
  private rightWidth: number;
  
  // 设置右侧面板位置
  setRightPanelX(x: number): void {
    this.rightPanel.x = x;
  }
  
  private createButton(label: string, x: number, y: number, width: number, height: number): Container {
    const btn = new Container();
    btn.x = x;
    btn.y = y;
    btn.eventMode = 'static';
    btn.cursor = 'pointer';
    
    const bg = new Graphics();
    bg.roundRect(0, 0, width, height, 8);
    bg.fill(0x4a5568);
    bg.stroke({ width: 2, color: 0x718096 });
    btn.addChild(bg);
    
    const style = new TextStyle({
      fontFamily: 'Arial',
      fontSize: 14,
      fill: 0xffffff,
    });
    const text = new Text({ text: label, style });
    text.anchor.set(0.5);
    text.x = width / 2;
    text.y = height / 2;
    btn.addChild(text);
    
    btn.on('pointerover', () => bg.tint = 0xaaaaaa);
    btn.on('pointerout', () => bg.tint = 0xffffff);
    
    return btn;
  }
  
  setUsername(name: string): void {
    this.username.text = name;
  }
}
