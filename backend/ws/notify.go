package ws

import (
	"fmt"
	"strconv"
)

// NotifyService 通知服务
type NotifyService struct {
	hub *Hub
}

// NewNotifyService 创建通知服务
func NewNotifyService() *NotifyService {
	return &NotifyService{hub: GameHub}
}

// 全局通知服务实例
var Notify *NotifyService

// InitNotify 初始化通知服务
func InitNotify() {
	Notify = NewNotifyService()
}

// === 通用通知 ===

// SendToUser 发送消息给指定用户
func (n *NotifyService) SendToUser(userID uint, msgType string, data map[string]interface{}) {
	if n.hub == nil {
		return
	}
	n.hub.SendToUser(strconv.FormatUint(uint64(userID), 10), NewMessage(msgType, data))
}

// Broadcast 广播消息给所有用户
func (n *NotifyService) Broadcast(msgType string, data map[string]interface{}) {
	if n.hub == nil {
		return
	}
	n.hub.Broadcast(NewMessage(msgType, data))
}

// === 邮件通知 ===

// NotifyNewMail 通知新邮件
func (n *NotifyService) NotifyNewMail(userID uint, mailID uint, title string) {
	n.SendToUser(userID, MsgTypeMailNew, map[string]interface{}{
		"mail_id": mailID,
		"title":   title,
	})
}

// === 好友通知 ===

// NotifyFriendRequest 通知好友申请
func (n *NotifyService) NotifyFriendRequest(userID uint, fromUserID uint, fromNickname string) {
	n.SendToUser(userID, MsgTypeFriendReq, map[string]interface{}{
		"from_user_id": fromUserID,
		"from_nickname": fromNickname,
	})
}

// NotifyFriendMessage 通知好友消息
func (n *NotifyService) NotifyFriendMessage(userID uint, fromUserID uint, fromNickname string, content string) {
	n.SendToUser(userID, MsgTypeFriendMsg, map[string]interface{}{
		"from_user_id":  fromUserID,
		"from_nickname": fromNickname,
		"content":       content,
	})
}

// === 拍卖通知 ===

// NotifyAuctionBid 通知拍卖被出价
func (n *NotifyService) NotifyAuctionBid(sellerID uint, auctionID uint, itemName string, bidPrice float64, bidderName string) {
	n.SendToUser(sellerID, MsgTypeAuctionBid, map[string]interface{}{
		"auction_id": auctionID,
		"item_name":  itemName,
		"bid_price":  bidPrice,
		"bidder":     bidderName,
	})
}

// NotifyAuctionOutbid 通知被人超越出价
func (n *NotifyService) NotifyAuctionOutbid(userID uint, auctionID uint, itemName string, newPrice float64) {
	n.SendToUser(userID, MsgTypeAuctionBid, map[string]interface{}{
		"auction_id": auctionID,
		"item_name":  itemName,
		"new_price":  newPrice,
		"outbid":     true,
	})
}

// NotifyAuctionEnd 通知拍卖结束
func (n *NotifyService) NotifyAuctionEnd(userID uint, auctionID uint, itemName string, won bool, finalPrice float64) {
	n.SendToUser(userID, MsgTypeAuctionEnd, map[string]interface{}{
		"auction_id":  auctionID,
		"item_name":   itemName,
		"won":         won,
		"final_price": finalPrice,
	})
}

// === 股票通知 ===

// NotifyStockPriceUpdate 广播股票价格更新
func (n *NotifyService) NotifyStockPriceUpdate(stockID uint, code string, price float64, changePercent float64) {
	n.Broadcast(MsgTypeStockPrice, map[string]interface{}{
		"stock_id":       stockID,
		"code":           code,
		"price":          price,
		"change_percent": changePercent,
	})
}

// NotifyLiquidation 通知强平
func (n *NotifyService) NotifyLiquidation(userID uint, positionID uint, stockName string, lossAmount float64) {
	n.SendToUser(userID, MsgTypeLiquidation, map[string]interface{}{
		"position_id": positionID,
		"stock_name":  stockName,
		"loss_amount": lossAmount,
		"message":     fmt.Sprintf("您的%s仓位已被强平，损失 %.2f 金币", stockName, lossAmount),
	})
}

// NotifyStockAlert 通知股票预警
func (n *NotifyService) NotifyStockAlert(userID uint, stockName string, alertType string, currentPrice float64) {
	n.SendToUser(userID, MsgTypeStockAlert, map[string]interface{}{
		"stock_name":    stockName,
		"alert_type":    alertType,
		"current_price": currentPrice,
	})
}

// === 成就通知 ===

// NotifyAchievement 通知成就达成
func (n *NotifyService) NotifyAchievement(userID uint, achievementID uint, name string, points int) {
	n.SendToUser(userID, MsgTypeAchievement, map[string]interface{}{
		"achievement_id": achievementID,
		"name":           name,
		"points":         points,
	})
}

// NotifyLevelUp 通知升级
func (n *NotifyService) NotifyLevelUp(userID uint, newLevel int, rewardGold int) {
	n.SendToUser(userID, MsgTypeLevelUp, map[string]interface{}{
		"new_level":   newLevel,
		"reward_gold": rewardGold,
	})
}

// === 农场通知 ===

// NotifyCropMature 通知作物成熟
func (n *NotifyService) NotifyCropMature(userID uint, slotIndex int, cropName string) {
	n.SendToUser(userID, MsgTypeCropMature, map[string]interface{}{
		"slot_index": slotIndex,
		"crop_name":  cropName,
	})
}

// NotifyCropStolen 通知作物被偷
func (n *NotifyService) NotifyCropStolen(userID uint, thiefName string, cropName string, amount int) {
	n.SendToUser(userID, MsgTypeCropStolen, map[string]interface{}{
		"thief_name": thiefName,
		"crop_name":  cropName,
		"amount":     amount,
	})
}

// === 市场通知 ===

// NotifyMarketUpdate 广播市场价格更新
func (n *NotifyService) NotifyMarketUpdate(itemType string, itemID uint, itemName string, newPrice float64, trend string) {
	n.Broadcast(MsgTypeMarketUpdate, map[string]interface{}{
		"item_type": itemType,
		"item_id":   itemID,
		"item_name": itemName,
		"new_price": newPrice,
		"trend":     trend,
	})
}

// NotifyBlackmarketRefresh 广播黑市刷新
func (n *NotifyService) NotifyBlackmarketRefresh(batchID uint, itemCount int) {
	n.Broadcast(MsgTypeBlackmarketNew, map[string]interface{}{
		"batch_id":   batchID,
		"item_count": itemCount,
		"message":    "黑市已刷新，快来抢购！",
	})
}

// === 聊天消息 ===

// BroadcastChat 广播聊天消息
func (n *NotifyService) BroadcastChat(channel string, userID uint, nickname string, avatar string, content string) {
	n.Broadcast(MsgTypeChat, map[string]interface{}{
		"channel":  channel,
		"user_id":  userID,
		"nickname": nickname,
		"avatar":   avatar,
		"content":  content,
	})
}

// SendPrivateChat 发送私聊
func (n *NotifyService) SendPrivateChat(toUserID uint, fromUserID uint, fromNickname string, content string) {
	n.SendToUser(toUserID, MsgTypeChatPrivate, map[string]interface{}{
		"from_user_id":  fromUserID,
		"from_nickname": fromNickname,
		"content":       content,
	})
}
