-- 农场游戏数据库结构
-- 创建数据库
CREATE DATABASE IF NOT EXISTS farm_game DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE farm_game;

-- ==================== 用户相关 ====================

-- 用户表
CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    linuxdo_id VARCHAR(100) NOT NULL UNIQUE COMMENT 'LinuxDo用户ID',
    charity_id VARCHAR(100) COMMENT '公益站ID',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar VARCHAR(255) COMMENT '头像URL',
    level INT DEFAULT 1 COMMENT '等级',
    gold DECIMAL(20,2) DEFAULT 1000.00 COMMENT '金币',
    farm_slots INT DEFAULT 4 COMMENT '农田格子数量',
    contribution INT DEFAULT 0 COMMENT '贡献值',
    achievement_points INT DEFAULT 0 COMMENT '成就点数',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_linuxdo_id (linuxdo_id),
    INDEX idx_charity_id (charity_id)
) ENGINE=InnoDB COMMENT='用户表';

-- 等级配置表
CREATE TABLE level_configs (
    level INT PRIMARY KEY COMMENT '等级',
    contribution_required INT NOT NULL COMMENT '所需贡献值',
    achievement_points_required INT NOT NULL COMMENT '所需成就点数',
    reward_gold INT DEFAULT 0 COMMENT '升级奖励金币'
) ENGINE=InnoDB COMMENT='等级配置表';

-- 用户统计表
CREATE TABLE user_stats (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    total_planted INT DEFAULT 0 COMMENT '总种植次数',
    total_harvested INT DEFAULT 0 COMMENT '总收获次数',
    total_sold INT DEFAULT 0 COMMENT '总售出数量',
    total_bought INT DEFAULT 0 COMMENT '总购买数量',
    total_gold_earned DECIMAL(20,2) DEFAULT 0 COMMENT '总赚取金币',
    total_gold_spent DECIMAL(20,2) DEFAULT 0 COMMENT '总花费金币',
    total_friends INT DEFAULT 0 COMMENT '好友数量',
    total_stolen INT DEFAULT 0 COMMENT '偷菜次数',
    login_days INT DEFAULT 0 COMMENT '登录天数',
    consecutive_days INT DEFAULT 0 COMMENT '连续登录天数',
    last_login_date DATE COMMENT '最后登录日期',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='用户统计表';

-- ==================== 种子和作物 ====================

-- 种子表
CREATE TABLE seeds (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL COMMENT '种子名称',
    description VARCHAR(255) COMMENT '描述',
    icon VARCHAR(255) COMMENT '图标路径',
    base_price DECIMAL(10,2) NOT NULL COMMENT '基础购买价格',
    price_min DECIMAL(10,2) NOT NULL COMMENT '最低价格',
    price_max DECIMAL(10,2) NOT NULL COMMENT '最高价格',
    growth_time INT NOT NULL COMMENT '成熟时间(秒)',
    stages INT DEFAULT 5 COMMENT '生长阶段数',
    season VARCHAR(20) COMMENT '适合季节(spring/summer/autumn/winter/all)',
    unlock_level INT DEFAULT 1 COMMENT '解锁等级',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否上架',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='种子表';

-- 作物表
CREATE TABLE crops (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    seed_id BIGINT UNSIGNED NOT NULL COMMENT '关联种子ID',
    name VARCHAR(50) NOT NULL COMMENT '作物名称',
    description VARCHAR(255) COMMENT '描述',
    icon VARCHAR(255) COMMENT '图标路径',
    base_sell_price DECIMAL(10,2) NOT NULL COMMENT '基础售价',
    sell_price_min DECIMAL(10,2) NOT NULL COMMENT '最低售价',
    sell_price_max DECIMAL(10,2) NOT NULL COMMENT '最高售价',
    yield_min INT DEFAULT 1 COMMENT '最少产量',
    yield_max INT DEFAULT 3 COMMENT '最多产量',
    exp_reward INT DEFAULT 10 COMMENT '收获经验',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seed_id) REFERENCES seeds(id)
) ENGINE=InnoDB COMMENT='作物表';

-- ==================== 市场价格系统 ====================

-- 价格规则表
CREATE TABLE price_rules (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    item_type ENUM('seed', 'crop') NOT NULL COMMENT '物品类型',
    item_id BIGINT UNSIGNED NOT NULL COMMENT '物品ID',
    base_price DECIMAL(10,2) NOT NULL COMMENT '基准价格',
    min_rate DECIMAL(5,2) DEFAULT 0.50 COMMENT '最低比率',
    max_rate DECIMAL(5,2) DEFAULT 2.00 COMMENT '最高比率',
    volatility DECIMAL(5,2) DEFAULT 0.10 COMMENT '波动系数',
    supply_weight DECIMAL(5,2) DEFAULT 1.00 COMMENT '供给影响权重',
    demand_weight DECIMAL(5,2) DEFAULT 1.00 COMMENT '需求影响权重',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_item (item_type, item_id)
) ENGINE=InnoDB COMMENT='价格规则表';

-- 市场状态表
CREATE TABLE market_status (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    item_type ENUM('seed', 'crop') NOT NULL COMMENT '物品类型',
    item_id BIGINT UNSIGNED NOT NULL COMMENT '物品ID',
    current_price DECIMAL(10,2) NOT NULL COMMENT '当前价格',
    current_rate DECIMAL(5,2) DEFAULT 1.00 COMMENT '当前比率',
    total_supply BIGINT DEFAULT 0 COMMENT '全服总存量',
    buy_volume_24h BIGINT DEFAULT 0 COMMENT '24小时购买量',
    sell_volume_24h BIGINT DEFAULT 0 COMMENT '24小时售出量',
    trend ENUM('up', 'down', 'stable') DEFAULT 'stable' COMMENT '价格趋势',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_item (item_type, item_id)
) ENGINE=InnoDB COMMENT='市场状态表';

-- 价格历史表
CREATE TABLE price_history (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    item_type ENUM('seed', 'crop') NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    rate DECIMAL(5,2) NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_item_time (item_type, item_id, recorded_at)
) ENGINE=InnoDB COMMENT='价格历史表';

-- 市场事件表
CREATE TABLE market_events (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL COMMENT '事件名称',
    description VARCHAR(255) COMMENT '事件描述',
    affect_type ENUM('seed', 'crop', 'all') NOT NULL COMMENT '影响类型',
    affect_items JSON COMMENT '影响的物品ID列表',
    price_modifier DECIMAL(5,2) DEFAULT 1.00 COMMENT '价格修正系数',
    start_at DATETIME NOT NULL COMMENT '开始时间',
    end_at DATETIME NOT NULL COMMENT '结束时间',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否生效',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='市场事件表';

-- ==================== 用户农场 ====================

-- 用户农田表
CREATE TABLE user_farms (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    slot_index INT NOT NULL COMMENT '农田格子索引',
    seed_id BIGINT UNSIGNED COMMENT '种植的种子ID',
    planted_at DATETIME COMMENT '种植时间',
    stage INT DEFAULT 0 COMMENT '当前生长阶段',
    status ENUM('empty', 'growing', 'mature', 'withered') DEFAULT 'empty' COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_slot (user_id, slot_index),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seed_id) REFERENCES seeds(id)
) ENGINE=InnoDB COMMENT='用户农田表';

-- 用户仓库表
CREATE TABLE user_inventory (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    item_type ENUM('seed', 'crop', 'tool', 'material') NOT NULL COMMENT '物品类型',
    item_id BIGINT UNSIGNED NOT NULL COMMENT '物品ID',
    quantity INT DEFAULT 0 COMMENT '数量',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_item (user_id, item_type, item_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='用户仓库表';

-- ==================== 交易系统 ====================

-- 交易记录表
CREATE TABLE trade_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    trade_type ENUM('buy', 'sell', 'auction', 'transfer', 'gift') NOT NULL COMMENT '交易类型',
    item_type ENUM('seed', 'crop', 'tool', 'material') NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL COMMENT '单价',
    total_price DECIMAL(20,2) NOT NULL COMMENT '总价',
    target_user_id BIGINT UNSIGNED COMMENT '交易对象',
    remark VARCHAR(255) COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_time (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB COMMENT='交易记录表';

-- 拍卖表
CREATE TABLE auctions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    seller_id BIGINT UNSIGNED NOT NULL COMMENT '卖家ID',
    item_type ENUM('seed', 'crop', 'tool', 'material') NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    start_price DECIMAL(10,2) NOT NULL COMMENT '起拍价',
    current_price DECIMAL(10,2) NOT NULL COMMENT '当前价',
    buyout_price DECIMAL(10,2) COMMENT '一口价',
    highest_bidder BIGINT UNSIGNED COMMENT '最高出价者',
    bid_count INT DEFAULT 0 COMMENT '出价次数',
    status ENUM('pending', 'active', 'sold', 'expired', 'cancelled') DEFAULT 'pending',
    start_at DATETIME NOT NULL,
    end_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_end_time (end_at),
    FOREIGN KEY (seller_id) REFERENCES users(id),
    FOREIGN KEY (highest_bidder) REFERENCES users(id)
) ENGINE=InnoDB COMMENT='拍卖表';

-- 拍卖出价记录
CREATE TABLE auction_bids (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    auction_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    bid_price DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_auction (auction_id),
    FOREIGN KEY (auction_id) REFERENCES auctions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB COMMENT='拍卖出价记录';

-- ==================== 好友系统 ====================

-- 好友关系表
CREATE TABLE friendships (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    friend_id BIGINT UNSIGNED NOT NULL,
    status ENUM('pending', 'accepted', 'blocked') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    accepted_at DATETIME,
    UNIQUE KEY uk_friendship (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='好友关系表';

-- 好友消息表
CREATE TABLE friend_messages (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    content TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_to_user (to_user_id, is_read),
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='好友消息表';

-- 好友互动记录
CREATE TABLE friend_interactions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL COMMENT '操作者',
    friend_id BIGINT UNSIGNED NOT NULL COMMENT '被操作者',
    action ENUM('steal', 'gift') NOT NULL COMMENT '互动类型',
    reward INT DEFAULT 0 COMMENT '获得奖励',
    target_slot INT COMMENT '目标农田格子',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_time (user_id, created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='好友互动记录';

-- ==================== 成就系统 ====================

-- 成就定义表
CREATE TABLE achievements (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL COMMENT '成就名称',
    description VARCHAR(255) COMMENT '成就描述',
    icon VARCHAR(255) COMMENT '图标',
    category ENUM('plant', 'trade', 'social', 'collect', 'special') NOT NULL COMMENT '分类',
    condition_type VARCHAR(50) NOT NULL COMMENT '条件类型',
    condition_value INT NOT NULL COMMENT '条件数值',
    reward_type ENUM('gold', 'item') NOT NULL COMMENT '奖励类型',
    reward_value INT NOT NULL COMMENT '奖励数值',
    reward_item_id BIGINT UNSIGNED COMMENT '奖励物品ID',
    points INT DEFAULT 10 COMMENT '成就点数',
    is_hidden TINYINT(1) DEFAULT 0 COMMENT '是否隐藏',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='成就定义表';

-- 用户成就表
CREATE TABLE user_achievements (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    achievement_id BIGINT UNSIGNED NOT NULL,
    progress INT DEFAULT 0 COMMENT '当前进度',
    is_completed TINYINT(1) DEFAULT 0,
    is_claimed TINYINT(1) DEFAULT 0 COMMENT '是否领取奖励',
    completed_at DATETIME,
    claimed_at DATETIME,
    UNIQUE KEY uk_user_achievement (user_id, achievement_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id)
) ENGINE=InnoDB COMMENT='用户成就表';

-- ==================== 邮件和签到 ====================

-- 邮件表
CREATE TABLE mails (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT,
    mail_type ENUM('system', 'reward', 'trade', 'friend') DEFAULT 'system',
    attachments JSON COMMENT '附件奖励',
    is_read TINYINT(1) DEFAULT 0,
    is_claimed TINYINT(1) DEFAULT 0,
    expire_at DATETIME COMMENT '过期时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id, is_read),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='邮件表';

-- 签到记录表
CREATE TABLE daily_checkins (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    checkin_date DATE NOT NULL,
    day_of_month INT NOT NULL COMMENT '本月第几天',
    reward_claimed TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_date (user_id, checkin_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='签到记录表';

-- ==================== 世界聊天 ====================

-- 聊天记录表
CREATE TABLE chat_messages (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    channel ENUM('world', 'trade', 'guild') DEFAULT 'world' COMMENT '频道',
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_channel_time (channel, created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='聊天记录表';

-- ==================== 股票交易所 ====================

-- 股票定义表
CREATE TABLE stocks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(10) NOT NULL UNIQUE COMMENT '股票代码',
    name VARCHAR(50) NOT NULL COMMENT '股票名称',
    description VARCHAR(255) COMMENT '描述',
    icon VARCHAR(255) COMMENT '图标',
    base_price DECIMAL(10,2) NOT NULL COMMENT '基准价格',
    current_price DECIMAL(10,2) NOT NULL COMMENT '当前价格',
    open_price DECIMAL(10,2) COMMENT '开盘价',
    high_price DECIMAL(10,2) COMMENT '最高价',
    low_price DECIMAL(10,2) COMMENT '最低价',
    close_price DECIMAL(10,2) COMMENT '收盘价',
    price_min DECIMAL(10,2) NOT NULL COMMENT '历史最低',
    price_max DECIMAL(10,2) NOT NULL COMMENT '历史最高',
    total_shares BIGINT NOT NULL COMMENT '总股本',
    available_shares BIGINT NOT NULL COMMENT '流通股本',
    today_volume BIGINT DEFAULT 0 COMMENT '今日成交量',
    today_amount DECIMAL(20,2) DEFAULT 0 COMMENT '今日成交额',
    volatility DECIMAL(5,2) DEFAULT 0.10 COMMENT '波动系数',
    max_leverage INT DEFAULT 10 COMMENT '最大杠杆倍数',
    trend ENUM('up', 'down', 'stable') DEFAULT 'stable' COMMENT '趋势',
    change_percent DECIMAL(10,4) DEFAULT 0 COMMENT '涨跌幅',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否上市',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='股票定义表';

-- 股票价格历史 (K线数据)
CREATE TABLE stock_prices (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    stock_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(10,2) NOT NULL COMMENT '收盘价',
    open_price DECIMAL(10,2) COMMENT '开盘价',
    high_price DECIMAL(10,2) COMMENT '最高价',
    low_price DECIMAL(10,2) COMMENT '最低价',
    volume BIGINT DEFAULT 0 COMMENT '成交量',
    amount DECIMAL(20,2) DEFAULT 0 COMMENT '成交额',
    period_type ENUM('1m', '5m', '15m', '1h', '1d') DEFAULT '1m' COMMENT '周期类型',
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_stock_time (stock_id, period_type, recorded_at),
    FOREIGN KEY (stock_id) REFERENCES stocks(id)
) ENGINE=InnoDB COMMENT='股票价格历史';

-- 用户持仓表 (现货)
CREATE TABLE user_stocks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    stock_id BIGINT UNSIGNED NOT NULL,
    shares BIGINT NOT NULL DEFAULT 0 COMMENT '持有股数',
    avg_cost DECIMAL(10,2) NOT NULL COMMENT '平均成本',
    total_cost DECIMAL(20,2) NOT NULL COMMENT '总成本',
    realized_profit DECIMAL(20,2) DEFAULT 0 COMMENT '已实现盈亏',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_stock (user_id, stock_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES stocks(id)
) ENGINE=InnoDB COMMENT='用户现货持仓表';

-- 用户杠杆仓位表
CREATE TABLE user_leverage_positions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    stock_id BIGINT UNSIGNED NOT NULL,
    position_type ENUM('long', 'short') NOT NULL COMMENT '做多/做空',
    leverage INT NOT NULL COMMENT '杠杆倍数',
    shares BIGINT NOT NULL COMMENT '持仓数量',
    entry_price DECIMAL(10,2) NOT NULL COMMENT '开仓价格',
    margin DECIMAL(20,2) NOT NULL COMMENT '保证金',
    liquidation_price DECIMAL(10,2) NOT NULL COMMENT '强平价格',
    unrealized_profit DECIMAL(20,2) DEFAULT 0 COMMENT '未实现盈亏',
    status ENUM('open', 'closed', 'liquidated') DEFAULT 'open' COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    closed_at DATETIME COMMENT '平仓时间',
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES stocks(id)
) ENGINE=InnoDB COMMENT='用户杠杆仓位表';

-- 股票交易记录
CREATE TABLE stock_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    stock_id BIGINT UNSIGNED NOT NULL,
    order_type ENUM('buy', 'sell', 'long_open', 'long_close', 'short_open', 'short_close') NOT NULL COMMENT '订单类型',
    leverage INT DEFAULT 1 COMMENT '杠杆倍数(现货为1)',
    shares BIGINT NOT NULL COMMENT '股数',
    price DECIMAL(10,2) NOT NULL COMMENT '成交价',
    total_amount DECIMAL(20,2) NOT NULL COMMENT '总金额',
    margin DECIMAL(20,2) DEFAULT 0 COMMENT '保证金',
    profit DECIMAL(20,2) DEFAULT 0 COMMENT '盈亏(平仓时)',
    position_id BIGINT UNSIGNED COMMENT '关联仓位ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_stock (stock_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (stock_id) REFERENCES stocks(id)
) ENGINE=InnoDB COMMENT='股票交易记录';

-- 用户股票统计表 (用于排行)
CREATE TABLE user_stock_stats (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    total_assets DECIMAL(20,2) DEFAULT 0 COMMENT '股票总资产',
    total_profit DECIMAL(20,2) DEFAULT 0 COMMENT '累计盈亏',
    total_profit_rate DECIMAL(10,4) DEFAULT 0 COMMENT '累计收益率',
    today_profit DECIMAL(20,2) DEFAULT 0 COMMENT '今日盈亏',
    today_profit_rate DECIMAL(10,4) DEFAULT 0 COMMENT '今日收益率',
    win_count INT DEFAULT 0 COMMENT '盈利次数',
    lose_count INT DEFAULT 0 COMMENT '亏损次数',
    win_rate DECIMAL(5,2) DEFAULT 0 COMMENT '胜率',
    max_profit DECIMAL(20,2) DEFAULT 0 COMMENT '单笔最大盈利',
    max_loss DECIMAL(20,2) DEFAULT 0 COMMENT '单笔最大亏损',
    trade_count INT DEFAULT 0 COMMENT '交易次数',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='用户股票统计表';

-- 股票排行榜
CREATE TABLE stock_rankings (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    rank_type ENUM('assets', 'profit', 'profit_rate', 'win_rate', 'shares') NOT NULL COMMENT '排行类型',
    stock_id BIGINT UNSIGNED COMMENT '股票ID(持股排行用)',
    user_id BIGINT UNSIGNED NOT NULL,
    rank_position INT NOT NULL COMMENT '排名',
    score DECIMAL(20,4) NOT NULL COMMENT '分数',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_type_stock_user (rank_type, stock_id, user_id),
    INDEX idx_type_rank (rank_type, stock_id, rank_position),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='股票排行榜';

-- ==================== 余额转换公益站 ====================

-- 公益站转换记录
CREATE TABLE charity_transfers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    transfer_type ENUM('in', 'out') NOT NULL COMMENT 'in=充入游戏, out=提取到公益站',
    amount DECIMAL(20,2) NOT NULL COMMENT '金额',
    charity_amount DECIMAL(20,2) NOT NULL COMMENT '公益站金额',
    exchange_rate DECIMAL(10,4) NOT NULL COMMENT '汇率',
    status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    remark VARCHAR(255) COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    INDEX idx_user (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB COMMENT='公益站转换记录';

-- ==================== 黑市商人 ====================

-- 黑市刷新批次表
CREATE TABLE blackmarket_batches (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    start_at DATETIME NOT NULL COMMENT '开始时间',
    end_at DATETIME NOT NULL COMMENT '结束时间',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否当前批次',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='黑市刷新批次表';

-- 黑市商品表 (每次刷新随机生成)
CREATE TABLE blackmarket_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    batch_id BIGINT UNSIGNED NOT NULL COMMENT '批次ID',
    name VARCHAR(50) NOT NULL COMMENT '商品名称',
    description VARCHAR(255) COMMENT '描述',
    icon VARCHAR(255) COMMENT '图标',
    item_type ENUM('seed', 'crop', 'tool', 'special') NOT NULL COMMENT '物品类型',
    item_id BIGINT UNSIGNED COMMENT '关联物品ID',
    price DECIMAL(10,2) NOT NULL COMMENT '黑市价格',
    total_stock INT NOT NULL COMMENT '全服总库存',
    sold_count INT DEFAULT 0 COMMENT '已售数量',
    unlock_level INT DEFAULT 1 COMMENT '解锁等级',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (batch_id) REFERENCES blackmarket_batches(id)
) ENGINE=InnoDB COMMENT='黑市商品表';

-- 黑市交易记录
CREATE TABLE blackmarket_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    batch_id BIGINT UNSIGNED NOT NULL COMMENT '批次ID',
    item_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(20,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_batch (batch_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (batch_id) REFERENCES blackmarket_batches(id),
    FOREIGN KEY (item_id) REFERENCES blackmarket_items(id)
) ENGINE=InnoDB COMMENT='黑市交易记录';

-- ==================== 排行榜 ====================

-- 排行榜缓存表
CREATE TABLE rankings (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    rank_type ENUM('gold', 'level', 'contribution', 'achievement', 'harvest', 'trade') NOT NULL COMMENT '排行类型',
    user_id BIGINT UNSIGNED NOT NULL,
    rank_position INT NOT NULL COMMENT '排名',
    score BIGINT NOT NULL COMMENT '分数',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_type_user (rank_type, user_id),
    INDEX idx_type_rank (rank_type, rank_position),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='排行榜缓存表';
