# 🌾 农场模拟游戏

一个基于 Go + React 的多人在线农场模拟游戏。

## 📦 技术栈

**后端**
- Go 1.21 + Gin 框架
- GORM + MySQL
- WebSocket 实时通信
- JWT 认证

**前端**
- React 18 + TypeScript
- Vite 构建工具
- WebSocket 客户端

## ✅ 已完成功能

### 🌱 核心玩法
- [x] 种植系统 - 购买种子、种植、浇水、收获
- [x] 动态农田 - 可扩展农田格子
- [x] 作物生长 - 多阶段生长动画
- [x] 种子掉落 - 收获时概率获得种子

### 💰 经济系统
- [x] 交易市场 - 买卖种子/作物
- [x] 动态价格 - 由交易驱动（非随机波动）
- [x] 批量滑点 - 大额交易价格递增/递减
- [x] WebSocket 实时价格推送

### 🔨 拍卖会
- [x] 上架物品 - 设置起拍价、一口价、持续时间
- [x] 竞拍出价 - 最后5分钟自动延时
- [x] 一口价购买
- [x] 5% 手续费

### 📊 玩家系统
- [x] 等级系统 - 贡献值/成就点升级
- [x] 成就系统 - 种植/收获/交易/登录成就
- [x] 每日签到 - 连续登录奖励
- [x] 排行榜 - 金币/等级/贡献榜

### 💬 社交功能
- [x] 世界聊天

## 🚧 后续开发计划

### 第一阶段 - 核心功能完善
- [ ] 📈 股票交易所 - 虚拟股票买卖、K线图
- [ ] ❤️ 公益站 - 金币捐赠换贡献值
- [ ] 🎭 黑市商人 - 稀有物品、随机刷新
- [ ] 👥 好友系统 - 添加好友、访问农场
- [ ] 🥕 偷菜功能 - 偷取好友成熟作物

### 第二阶段 - 玩法扩展
- [ ] 🐾 宠物系统 - 宠物养成、技能
- [ ] 🏠 农场装饰 - 自定义装扮
- [ ] 🎁 礼物系统 - 玩家间赠送
- [ ] 📜 任务系统 - 每日/周常任务

### 第三阶段 - 体验优化
- [ ] 🔔 通知弹窗 - 成就解锁、升级提示
- [ ] 📱 移动端适配
- [ ] 🌍 多语言支持

## 🛠️ 本地开发

### 环境要求
- Go 1.21+
- Node.js 18+
- MySQL 8.0+

### 后端启动

```bash
cd backend

# 复制配置文件
cp .env.example .env
# 编辑 .env 填写数据库密码

# 运行
go run main.go
```

### 前端启动

```bash
cd frontend

# 安装依赖
npm install

# 开发模式
npm run dev

# 构建
npm run build
```

### 数据库初始化

首次启动后端会自动创建数据库和导入初始数据。

也可手动导入：
```bash
mysql -u root -p farm_game < backend/sql/farm_game_full.sql
```

## 🤝 如何加入开发

### 1. Fork 项目
点击右上角 Fork 按钮，复制到自己的仓库。

### 2. Clone 到本地
```bash
git clone https://github.com/你的用户名/game.git
cd game
```

### 3. 创建功能分支
```bash
git checkout -b feature/你的功能名
```

### 4. 开发并提交
```bash
git add .
git commit -m "feat: 添加xxx功能"
```

### 5. 推送并创建 PR
```bash
git push origin feature/你的功能名
```
然后在 GitHub 上创建 Pull Request。

### 代码规范
- 后端：遵循 Go 官方代码风格
- 前端：使用 ESLint + Prettier
- 提交信息：使用 [Conventional Commits](https://www.conventionalcommits.org/)
  - `feat:` 新功能
  - `fix:` 修复 Bug
  - `docs:` 文档更新
  - `style:` 代码格式
  - `refactor:` 重构

### 目录结构

```
game/
├── backend/                # 后端代码
│   ├── config/            # 配置
│   ├── handler/           # HTTP 处理器
│   ├── middleware/        # 中间件
│   ├── models/            # 数据模型
│   ├── repository/        # 数据库操作
│   ├── service/           # 业务逻辑
│   ├── ws/                # WebSocket
│   ├── cron/              # 定时任务
│   └── sql/               # SQL 文件
├── frontend/              # 前端代码
│   ├── src/
│   │   ├── components/    # 组件
│   │   ├── pages/         # 页面
│   │   ├── services/      # API 服务
│   │   ├── contexts/      # React Context
│   │   └── types/         # TypeScript 类型
│   └── public/            # 静态资源
└── README.md
```

## 📄 License

MIT License
