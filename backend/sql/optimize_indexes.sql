-- 性能优化索引
-- 执行前请备份数据库

-- user_inventory 复合索引（解决频繁查询）
CREATE INDEX IF NOT EXISTS idx_inventory_user_type_item ON user_inventory(user_id, item_type, item_id);

-- user_farms 复合索引
CREATE INDEX IF NOT EXISTS idx_farms_user_slot ON user_farms(user_id, slot_index);
CREATE INDEX IF NOT EXISTS idx_farms_status ON user_farms(status);

-- market_status 复合索引（高频查询）
CREATE INDEX IF NOT EXISTS idx_market_type_item ON market_status(item_type, item_id);

-- stock_prices K线查询优化
CREATE INDEX IF NOT EXISTS idx_stock_prices_query ON stock_prices(stock_id, period_type, recorded_at DESC);

-- user_stocks 持仓查询
CREATE INDEX IF NOT EXISTS idx_user_stocks_user ON user_stocks(user_id, stock_id);

-- user_leverage_positions 仓位查询
CREATE INDEX IF NOT EXISTS idx_positions_user_status ON user_leverage_positions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_positions_stock_status ON user_leverage_positions(stock_id, status);

-- auctions 拍卖查询
CREATE INDEX IF NOT EXISTS idx_auctions_status_end ON auctions(status, end_at);

-- chat_messages 聊天记录
CREATE INDEX IF NOT EXISTS idx_chat_channel_time ON chat_messages(channel, created_at DESC);

-- price_history 价格历史
CREATE INDEX IF NOT EXISTS idx_price_history_item_time ON price_history(item_type, item_id, recorded_at DESC);
