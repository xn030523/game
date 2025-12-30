-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: farm_game
-- ------------------------------------------------------
-- Server version	8.0.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `achievements`
--

DROP TABLE IF EXISTS `achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '成就名称',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '成就描述',
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图标',
  `category` enum('plant','trade','social','collect','special') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类',
  `condition_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '条件类型',
  `condition_value` int(11) NOT NULL COMMENT '条件数值',
  `reward_type` enum('gold','item') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '奖励类型',
  `reward_value` int(11) NOT NULL COMMENT '奖励数值',
  `reward_item_id` bigint(20) unsigned DEFAULT NULL COMMENT '奖励物品ID',
  `points` int(11) DEFAULT '10' COMMENT '成就点数',
  `is_hidden` tinyint(1) DEFAULT '0' COMMENT '是否隐藏',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='成就定义表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES (1,'total_planted_1','初出茅庐','完成第一次种植','🌱','plant','total_planted',1,'gold',100,NULL,5,0,0,'2025-12-30 15:38:31'),(2,'total_planted_50','勤劳农夫','累计种植50次','👨‍🌾','plant','total_planted',50,'gold',500,NULL,10,0,0,'2025-12-30 15:38:31'),(3,'total_planted_500','种植大师','累计种植500次','🏆','plant','total_planted',500,'gold',2000,NULL,20,0,0,'2025-12-30 15:38:31'),(4,'harvest_100','丰收季节','累计收获100次','🌾','plant','total_harvested',100,'gold',1000,NULL,15,0,0,'2025-12-30 15:38:31'),(5,'total_sold_1','初次交易','完成第一笔交易','💰','trade','total_sold',1,'gold',100,NULL,5,0,0,'2025-12-30 15:38:31'),(6,'total_sold_50','商业新手','累计售出50个物品','📦','trade','total_sold',50,'gold',500,NULL,10,0,0,'2025-12-30 15:38:31'),(7,'total_sold_1000','商业大亨','累计售出1000个物品','🏪','trade','total_sold',1000,'gold',5000,NULL,30,0,0,'2025-12-30 15:38:31'),(8,'total_bought_100','购物达人','累计购买100个物品','🛒','trade','total_bought',100,'gold',800,NULL,12,0,0,'2025-12-30 15:38:31'),(9,'total_friends_1','结交好友','添加第一个好友','👋','social','total_friends',1,'gold',200,NULL,5,0,0,'2025-12-30 15:38:31'),(10,'total_friends_10','人缘好','拥有10个好友','🤝','social','total_friends',10,'gold',1000,NULL,15,0,0,'2025-12-30 15:38:31'),(11,'total_friends_50','社交达人','拥有50个好友','🎉','social','total_friends',50,'gold',3000,NULL,25,0,0,'2025-12-30 15:38:31'),(12,'total_stolen_100','神偷','成功偷菜100次','🥷','social','total_stolen',100,'gold',2000,NULL,20,0,0,'2025-12-30 15:38:31'),(13,'total_gold_earned_10000','小有积蓄','累计赚取10000金币','💵','collect','total_gold_earned',10000,'gold',500,NULL,10,0,0,'2025-12-30 15:38:31'),(14,'total_gold_earned_100000','富甲一方','累计赚取100000金币','💎','collect','total_gold_earned',100000,'gold',5000,NULL,30,0,0,'2025-12-30 15:38:31'),(15,'total_gold_earned_1000000','亿万富翁','累计赚取1000000金币','👑','collect','total_gold_earned',1000000,'gold',50000,NULL,50,0,0,'2025-12-30 15:38:31'),(16,'consecutive_days_7','坚持不懈','连续登录7天','📅','special','consecutive_days',7,'gold',1000,NULL,10,0,0,'2025-12-30 15:38:31'),(17,'consecutive_days_30','月度达人','连续登录30天','🗓️','special','consecutive_days',30,'gold',5000,NULL,25,0,0,'2025-12-30 15:38:31'),(18,'login_days_365','年度玩家','累计登录365天','🎖️','special','login_days',365,'gold',50000,NULL,50,0,0,'2025-12-30 15:38:31'),(19,'first_harvest','首次收获','收获第一个作物','🌾','plant','total_harvested',1,'gold',100,NULL,5,0,0,'2025-12-30 18:59:22'),(20,'harvest_10','小有收获','累计收获10次','🌽','plant','total_harvested',10,'gold',500,NULL,10,0,0,'2025-12-30 18:59:22'),(21,'harvest_1000','收获大师','累计收获1000次','🏆','plant','total_harvested',1000,'gold',10000,NULL,50,0,0,'2025-12-30 18:59:22');
/*!40000 ALTER TABLE `achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction_bids`
--

DROP TABLE IF EXISTS `auction_bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction_bids` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `auction_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `bid_price` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_auction` (`auction_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `auction_bids_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `auctions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `auction_bids_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拍卖出价记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction_bids`
--

LOCK TABLES `auction_bids` WRITE;
/*!40000 ALTER TABLE `auction_bids` DISABLE KEYS */;
/*!40000 ALTER TABLE `auction_bids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auctions`
--

DROP TABLE IF EXISTS `auctions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auctions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `seller_id` bigint(20) unsigned NOT NULL COMMENT '卖家ID',
  `item_type` enum('seed','crop','tool','material') COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT '1',
  `start_price` decimal(10,2) NOT NULL COMMENT '起拍价',
  `current_price` decimal(10,2) NOT NULL COMMENT '当前价',
  `buyout_price` decimal(10,2) DEFAULT NULL COMMENT '一口价',
  `highest_bidder` bigint(20) unsigned DEFAULT NULL COMMENT '最高出价者',
  `bid_count` int(11) DEFAULT '0' COMMENT '出价次数',
  `status` enum('pending','active','sold','expired','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `start_at` datetime NOT NULL,
  `end_at` datetime NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_end_time` (`end_at`),
  KEY `seller_id` (`seller_id`),
  KEY `highest_bidder` (`highest_bidder`),
  CONSTRAINT `auctions_ibfk_1` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`),
  CONSTRAINT `auctions_ibfk_2` FOREIGN KEY (`highest_bidder`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拍卖表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auctions`
--

LOCK TABLES `auctions` WRITE;
/*!40000 ALTER TABLE `auctions` DISABLE KEYS */;
INSERT INTO `auctions` VALUES (1,2,'seed',1,2,10.00,10.00,11.00,NULL,0,'active','2025-12-30 19:32:33','2025-12-31 19:32:33','2025-12-30 19:32:33');
/*!40000 ALTER TABLE `auctions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blackmarket_batches`
--

DROP TABLE IF EXISTS `blackmarket_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blackmarket_batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `start_at` datetime NOT NULL COMMENT '开始时间',
  `end_at` datetime NOT NULL COMMENT '结束时间',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否当前批次',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='黑市刷新批次表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blackmarket_batches`
--

LOCK TABLES `blackmarket_batches` WRITE;
/*!40000 ALTER TABLE `blackmarket_batches` DISABLE KEYS */;
INSERT INTO `blackmarket_batches` VALUES (1,'2025-12-30 15:38:32','2025-12-30 19:38:32',1,'2025-12-30 15:38:32');
/*!40000 ALTER TABLE `blackmarket_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blackmarket_items`
--

DROP TABLE IF EXISTS `blackmarket_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blackmarket_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `batch_id` bigint(20) unsigned NOT NULL COMMENT '批次ID',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品名称',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '描述',
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图标',
  `item_type` enum('seed','crop','tool','special') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品类型',
  `item_id` bigint(20) unsigned DEFAULT NULL COMMENT '关联物品ID',
  `price` decimal(10,2) NOT NULL COMMENT '黑市价格',
  `total_stock` int(11) NOT NULL COMMENT '全服总库存',
  `sold_count` int(11) DEFAULT '0' COMMENT '已售数量',
  `unlock_level` int(11) DEFAULT '1' COMMENT '解锁等级',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `batch_id` (`batch_id`),
  CONSTRAINT `blackmarket_items_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `blackmarket_batches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='黑市商品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blackmarket_items`
--

LOCK TABLES `blackmarket_items` WRITE;
/*!40000 ALTER TABLE `blackmarket_items` DISABLE KEYS */;
INSERT INTO `blackmarket_items` VALUES (1,1,'茄子种子(黑市)','黑市特供 茄子种子','/crops/eggplant','seed',14,31.00,107,0,15,'2025-12-30 15:38:32'),(2,1,'葡萄种子(黑市)','黑市特供 葡萄种子','/crops/grape','seed',19,48.45,156,0,22,'2025-12-30 15:38:32'),(3,1,'远古果实种子(黑市)','黑市特供 远古果实种子','/crops/ancient-fruit','seed',25,120.24,138,0,40,'2025-12-30 15:38:32'),(4,1,'芜菁种子(黑市)','黑市特供 芜菁种子','/crops/turnip','seed',6,9.25,108,0,3,'2025-12-30 15:38:32'),(5,1,'蓝莓种子(黑市)','黑市特供 蓝莓种子','/crops/blueberry','seed',12,31.89,102,0,10,'2025-12-30 15:38:32'),(6,1,'番茄种子(黑市)','黑市特供 番茄种子','/crops/tomato','seed',7,15.77,138,0,5,'2025-12-30 15:38:32'),(7,1,'神秘种子袋','随机获得一种高级种子','','special',NULL,500.00,20,0,5,'2025-12-30 15:38:32');
/*!40000 ALTER TABLE `blackmarket_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blackmarket_logs`
--

DROP TABLE IF EXISTS `blackmarket_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blackmarket_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `batch_id` bigint(20) unsigned NOT NULL COMMENT '批次ID',
  `item_id` bigint(20) unsigned NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `total_price` decimal(20,2) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_batch` (`batch_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `blackmarket_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `blackmarket_logs_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `blackmarket_batches` (`id`),
  CONSTRAINT `blackmarket_logs_ibfk_3` FOREIGN KEY (`item_id`) REFERENCES `blackmarket_items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='黑市交易记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blackmarket_logs`
--

LOCK TABLES `blackmarket_logs` WRITE;
/*!40000 ALTER TABLE `blackmarket_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `blackmarket_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `charity_transfers`
--

DROP TABLE IF EXISTS `charity_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `charity_transfers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `transfer_type` enum('in','out') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'in=充入游戏, out=提取到公益站',
  `amount` decimal(20,2) NOT NULL COMMENT '金额',
  `charity_amount` decimal(20,2) NOT NULL COMMENT '公益站金额',
  `exchange_rate` decimal(10,4) NOT NULL COMMENT '汇率',
  `status` enum('pending','completed','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `charity_transfers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公益站转换记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charity_transfers`
--

LOCK TABLES `charity_transfers` WRITE;
/*!40000 ALTER TABLE `charity_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `charity_transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `channel` enum('world','trade','guild') COLLATE utf8mb4_unicode_ci DEFAULT 'world' COMMENT '频道',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_channel_time` (`channel`,`created_at`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='聊天记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
INSERT INTO `chat_messages` VALUES (1,2,'world','你好','2025-12-30 16:07:44'),(2,2,'world','你好啊','2025-12-30 16:08:06'),(3,2,'world','你是谁','2025-12-30 16:11:43'),(4,1,'world','什么','2025-12-30 16:11:58'),(5,2,'world','你是谁','2025-12-30 16:12:02'),(6,1,'world','我是你爹','2025-12-30 16:12:09'),(7,1,'world','你是谁','2025-12-30 16:13:25'),(8,2,'world','什么什么','2025-12-30 16:13:33');
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crops`
--

DROP TABLE IF EXISTS `crops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crops` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `seed_id` bigint(20) unsigned NOT NULL COMMENT '关联种子ID',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '作物名称',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '描述',
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图标路径',
  `base_sell_price` decimal(10,2) NOT NULL COMMENT '基础售价',
  `sell_price_min` decimal(10,2) NOT NULL COMMENT '最低售价',
  `sell_price_max` decimal(10,2) NOT NULL COMMENT '最高售价',
  `yield_min` int(11) DEFAULT '1' COMMENT '最少产量',
  `yield_max` int(11) DEFAULT '3' COMMENT '最多产量',
  `exp_reward` int(11) DEFAULT '10' COMMENT '收获经验',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `seed_id` (`seed_id`),
  CONSTRAINT `crops_ibfk_1` FOREIGN KEY (`seed_id`) REFERENCES `seeds` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作物表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crops`
--

LOCK TABLES `crops` WRITE;
/*!40000 ALTER TABLE `crops` DISABLE KEYS */;
INSERT INTO `crops` VALUES (1,1,'土豆','金黄的土豆','/crops/potato',25.00,12.00,50.00,1,3,5,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(2,2,'胡萝卜','橙色的胡萝卜','/crops/carrot',35.00,18.00,70.00,1,3,8,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(3,3,'萝卜','白嫩的萝卜','/crops/radish',28.00,14.00,56.00,1,3,6,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(4,4,'洋葱','辛辣的洋葱','/crops/onion',40.00,20.00,80.00,1,2,10,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(5,5,'菠菜','新鲜的菠菜','/crops/spinach',45.00,22.00,90.00,1,3,10,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(6,6,'芜菁','紫白的芜菁','/crops/turnip',32.00,16.00,64.00,1,2,8,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(7,7,'番茄','红彤彤的番茄','/crops/tomato',60.00,30.00,120.00,1,4,15,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(8,8,'玉米','金黄的玉米棒','/crops/corn',70.00,35.00,140.00,1,3,18,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(9,9,'小麦','饱满的麦穗','/crops/wheat',45.00,22.00,90.00,2,5,12,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(10,10,'辣椒','火红的辣椒','/crops/hot-pepper',80.00,40.00,160.00,1,3,20,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(11,11,'甜瓜','香甜的甜瓜','/crops/melon',120.00,60.00,240.00,1,2,30,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(12,12,'蓝莓','一篮蓝莓','/crops/blueberry',100.00,50.00,200.00,2,5,25,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(13,13,'向日葵','金色的向日葵','/crops/sunflower',90.00,45.00,180.00,1,2,22,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(14,14,'茄子','紫色的茄子','/crops/eggplant',90.00,45.00,180.00,1,3,22,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(15,15,'南瓜','巨大的南瓜','/crops/pumpkin',150.00,75.00,300.00,1,2,35,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(16,16,'甜菜','深红的甜菜','/crops/beet',80.00,40.00,160.00,1,2,20,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(17,17,'蔓越莓','酸甜的蔓越莓','/crops/cranberries',130.00,65.00,260.00,2,4,30,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(18,18,'山药','滋补的山药','/crops/yam',120.00,60.00,240.00,1,2,28,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(19,19,'葡萄','一串紫葡萄','/crops/grape',180.00,90.00,360.00,1,3,40,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(20,20,'朝鲜蓟','珍贵的朝鲜蓟','/crops/artichoke',160.00,80.00,320.00,1,2,35,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(21,21,'草莓','鲜红的草莓','/crops/strawberry',200.00,100.00,400.00,2,4,45,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(22,22,'咖啡豆','香浓的咖啡豆','/crops/coffee-bean',250.00,125.00,500.00,1,3,55,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(23,23,'菠萝','金黄的菠萝','/crops/pineapple',300.00,150.00,600.00,1,2,65,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(24,24,'杨星果','星形的神秘果实','/crops/starfruit',400.00,200.00,800.00,1,2,80,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(25,25,'远古果实','散发古老气息的果实','/crops/ancient-fruit',600.00,300.00,1200.00,1,2,100,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(26,26,'甜宝石浆果','闪耀如宝石的浆果','/crops/sweet-gem-berry',1500.00,750.00,3000.00,1,1,200,'2025-12-30 15:38:31','2025-12-30 15:38:31');
/*!40000 ALTER TABLE `crops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_checkins`
--

DROP TABLE IF EXISTS `daily_checkins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_checkins` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `checkin_date` date NOT NULL,
  `day_of_month` int(11) NOT NULL COMMENT '本月第几天',
  `reward_claimed` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`checkin_date`),
  CONSTRAINT `daily_checkins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='签到记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_checkins`
--

LOCK TABLES `daily_checkins` WRITE;
/*!40000 ALTER TABLE `daily_checkins` DISABLE KEYS */;
INSERT INTO `daily_checkins` VALUES (1,2,'2025-12-30',30,1,'2025-12-30 18:48:14');
/*!40000 ALTER TABLE `daily_checkins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friend_interactions`
--

DROP TABLE IF EXISTS `friend_interactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_interactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL COMMENT '操作者',
  `friend_id` bigint(20) unsigned NOT NULL COMMENT '被操作者',
  `action` enum('steal','gift') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '互动类型',
  `reward` int(11) DEFAULT '0' COMMENT '获得奖励',
  `target_slot` int(11) DEFAULT NULL COMMENT '目标农田格子',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_time` (`user_id`,`created_at`),
  KEY `friend_id` (`friend_id`),
  CONSTRAINT `friend_interactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friend_interactions_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='好友互动记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_interactions`
--

LOCK TABLES `friend_interactions` WRITE;
/*!40000 ALTER TABLE `friend_interactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `friend_interactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friend_messages`
--

DROP TABLE IF EXISTS `friend_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint(20) unsigned NOT NULL,
  `to_user_id` bigint(20) unsigned NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_to_user` (`to_user_id`,`is_read`),
  KEY `from_user_id` (`from_user_id`),
  CONSTRAINT `friend_messages_ibfk_1` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friend_messages_ibfk_2` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='好友消息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_messages`
--

LOCK TABLES `friend_messages` WRITE;
/*!40000 ALTER TABLE `friend_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `friend_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friendships`
--

DROP TABLE IF EXISTS `friendships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friendships` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `friend_id` bigint(20) unsigned NOT NULL,
  `status` enum('pending','accepted','blocked') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `accepted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_friendship` (`user_id`,`friend_id`),
  KEY `friend_id` (`friend_id`),
  CONSTRAINT `friendships_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friendships_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='好友关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friendships`
--

LOCK TABLES `friendships` WRITE;
/*!40000 ALTER TABLE `friendships` DISABLE KEYS */;
/*!40000 ALTER TABLE `friendships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `level_configs`
--

DROP TABLE IF EXISTS `level_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `level_configs` (
  `level` int(11) NOT NULL COMMENT '等级',
  `contribution_required` int(11) NOT NULL COMMENT '所需贡献值',
  `achievement_points_required` int(11) NOT NULL COMMENT '所需成就点数',
  `reward_gold` int(11) DEFAULT '0' COMMENT '升级奖励金币',
  PRIMARY KEY (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='等级配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `level_configs`
--

LOCK TABLES `level_configs` WRITE;
/*!40000 ALTER TABLE `level_configs` DISABLE KEYS */;
INSERT INTO `level_configs` VALUES (1,0,0,0),(2,50,10,100),(3,150,25,200),(4,300,45,300),(5,500,70,500),(6,800,100,600),(7,1200,140,700),(8,1700,190,800),(9,2300,250,900),(10,3000,320,1000),(15,6000,550,1500),(20,10000,850,2000),(25,15000,1200,3000),(30,22000,1600,4000),(35,30000,2100,5000),(40,40000,2700,6000),(45,52000,3400,7000),(50,66000,4200,10000);
/*!40000 ALTER TABLE `level_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mails`
--

DROP TABLE IF EXISTS `mails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mails` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci,
  `mail_type` enum('system','reward','trade','friend') COLLATE utf8mb4_unicode_ci DEFAULT 'system',
  `attachments` json DEFAULT NULL COMMENT '附件奖励',
  `is_read` tinyint(1) DEFAULT '0',
  `is_claimed` tinyint(1) DEFAULT '0',
  `expire_at` datetime DEFAULT NULL COMMENT '过期时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`,`is_read`),
  CONSTRAINT `mails_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='邮件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mails`
--

LOCK TABLES `mails` WRITE;
/*!40000 ALTER TABLE `mails` DISABLE KEYS */;
/*!40000 ALTER TABLE `mails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `market_events`
--

DROP TABLE IF EXISTS `market_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `market_events` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '事件名称',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '事件描述',
  `affect_type` enum('seed','crop','all') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '影响类型',
  `affect_items` json DEFAULT NULL COMMENT '影响的物品ID列表',
  `price_modifier` decimal(5,2) DEFAULT '1.00' COMMENT '价格修正系数',
  `start_at` datetime NOT NULL COMMENT '开始时间',
  `end_at` datetime NOT NULL COMMENT '结束时间',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否生效',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='市场事件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `market_events`
--

LOCK TABLES `market_events` WRITE;
/*!40000 ALTER TABLE `market_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `market_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `market_status`
--

DROP TABLE IF EXISTS `market_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `market_status` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `item_type` enum('seed','crop') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品类型',
  `item_id` bigint(20) unsigned NOT NULL COMMENT '物品ID',
  `current_price` decimal(10,2) NOT NULL COMMENT '当前价格',
  `current_rate` decimal(5,2) DEFAULT '1.00' COMMENT '当前比率',
  `total_supply` bigint(20) DEFAULT '0' COMMENT '全服总存量',
  `trend` enum('up','down','stable') COLLATE utf8mb4_unicode_ci DEFAULT 'stable' COMMENT '价格趋势',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `buy_volume24h` bigint(20) DEFAULT '0',
  `sell_volume24h` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item` (`item_type`,`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='市场状态表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `market_status`
--

LOCK TABLES `market_status` WRITE;
/*!40000 ALTER TABLE `market_status` DISABLE KEYS */;
INSERT INTO `market_status` VALUES (1,'seed',1,10.13,1.00,0,'stable','2025-12-30 19:04:47',11,0),(2,'seed',2,17.04,1.14,0,'down','2025-12-30 18:29:07',0,0),(3,'seed',3,10.04,0.84,0,'up','2025-12-30 18:29:07',0,0),(4,'seed',4,20.16,1.12,0,'stable','2025-12-30 18:29:07',0,0),(5,'seed',5,19.95,1.00,0,'stable','2025-12-30 18:29:07',0,0),(6,'seed',6,14.94,1.07,0,'up','2025-12-30 18:29:07',0,0),(7,'seed',7,23.50,0.94,0,'stable','2025-12-30 18:29:07',0,0),(8,'seed',8,27.43,0.90,0,'down','2025-12-30 19:17:04',11,0),(9,'seed',9,22.76,1.14,0,'down','2025-12-30 18:29:07',0,0),(10,'seed',10,36.00,1.03,0,'down','2025-12-30 18:29:07',0,0),(11,'seed',11,42.83,0.86,0,'down','2025-12-30 18:29:07',0,0),(12,'seed',12,46.62,1.04,0,'up','2025-12-30 18:29:07',0,0),(13,'seed',13,39.32,0.98,0,'stable','2025-12-30 18:29:07',0,0),(14,'seed',14,35.91,0.90,0,'down','2025-12-30 18:29:07',0,0),(15,'seed',15,61.72,1.03,0,'up','2025-12-30 18:29:07',0,0),(16,'seed',16,28.77,0.82,0,'up','2025-12-30 18:29:07',0,0),(17,'seed',17,45.88,0.83,0,'up','2025-12-30 18:29:07',0,0),(18,'seed',18,53.65,1.07,0,'up','2025-12-30 18:29:07',0,0),(19,'seed',19,68.10,0.97,0,'up','2025-12-30 18:29:07',0,0),(20,'seed',20,63.88,0.98,0,'up','2025-12-30 18:29:07',0,0),(21,'seed',21,71.80,0.90,0,'up','2025-12-30 18:29:07',0,0),(22,'seed',22,75.72,0.76,0,'down','2025-12-30 18:29:07',0,0),(23,'seed',23,99.82,0.83,0,'up','2025-12-30 18:29:07',0,0),(24,'seed',24,166.61,1.11,0,'down','2025-12-30 18:29:07',0,0),(25,'seed',25,220.16,1.10,0,'up','2025-12-30 18:29:07',0,0),(26,'seed',26,466.29,0.93,0,'up','2025-12-30 18:29:07',0,0),(32,'crop',1,22.41,0.94,0,'up','2025-12-30 19:16:54',0,51),(33,'crop',2,37.73,1.08,0,'up','2025-12-30 18:29:07',0,0),(34,'crop',3,24.49,0.87,0,'down','2025-12-30 18:29:07',0,0),(35,'crop',4,42.65,1.07,0,'down','2025-12-30 18:29:07',0,0),(36,'crop',5,41.75,0.93,0,'down','2025-12-30 18:29:07',0,0),(37,'crop',6,32.37,1.01,0,'stable','2025-12-30 18:29:07',0,0),(38,'crop',7,61.08,1.02,0,'down','2025-12-30 18:29:07',0,0),(39,'crop',8,66.58,0.95,0,'up','2025-12-30 18:29:07',0,0),(40,'crop',9,47.59,1.06,0,'up','2025-12-30 18:29:07',0,0),(41,'crop',10,67.14,0.84,0,'down','2025-12-30 18:29:07',0,0),(42,'crop',11,142.39,1.19,0,'down','2025-12-30 18:29:07',0,0),(43,'crop',12,103.00,1.03,0,'up','2025-12-30 18:29:07',0,0),(44,'crop',13,69.37,0.77,0,'down','2025-12-30 18:29:07',0,0),(45,'crop',14,95.02,1.06,0,'down','2025-12-30 18:29:07',0,0),(46,'crop',15,159.83,1.07,0,'up','2025-12-30 18:29:07',0,0),(47,'crop',16,96.39,1.20,0,'up','2025-12-30 18:29:07',0,0),(48,'crop',17,118.19,0.91,0,'up','2025-12-30 18:29:07',0,0),(49,'crop',18,134.42,1.12,0,'up','2025-12-30 18:29:07',0,0),(50,'crop',19,184.17,1.02,0,'stable','2025-12-30 18:29:07',0,0),(51,'crop',20,162.67,1.02,0,'down','2025-12-30 18:29:07',0,0),(52,'crop',21,172.31,0.86,0,'up','2025-12-30 18:29:07',0,0),(53,'crop',22,244.98,0.98,0,'up','2025-12-30 18:29:07',0,0),(54,'crop',23,337.81,1.13,0,'down','2025-12-30 18:29:07',0,0),(55,'crop',24,432.55,1.08,0,'down','2025-12-30 18:29:07',0,0),(56,'crop',25,712.33,1.19,0,'up','2025-12-30 18:29:07',0,0),(57,'crop',26,1949.86,1.30,0,'up','2025-12-30 18:29:07',0,0);
/*!40000 ALTER TABLE `market_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price_history`
--

DROP TABLE IF EXISTS `price_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `price_history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `item_type` enum('seed','crop') COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `rate` decimal(5,2) NOT NULL,
  `recorded_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_item_time` (`item_type`,`item_id`,`recorded_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2393 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='价格历史表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price_history`
--

LOCK TABLES `price_history` WRITE;
/*!40000 ALTER TABLE `price_history` DISABLE KEYS */;
INSERT INTO `price_history` VALUES (1,'seed',1,9.53,0.95,'2025-12-30 15:38:32'),(2,'seed',2,14.68,0.98,'2025-12-30 15:38:32'),(3,'seed',3,11.71,0.98,'2025-12-30 15:38:32'),(4,'seed',4,17.95,1.00,'2025-12-30 15:38:32'),(5,'seed',5,20.68,1.03,'2025-12-30 15:38:32'),(6,'seed',6,14.38,1.03,'2025-12-30 15:38:32'),(7,'seed',7,25.11,1.00,'2025-12-30 15:38:32'),(8,'seed',8,31.00,1.03,'2025-12-30 15:38:32'),(9,'seed',9,19.17,0.96,'2025-12-30 15:38:32'),(10,'seed',10,34.80,0.99,'2025-12-30 15:38:32'),(11,'seed',11,47.86,0.96,'2025-12-30 15:38:32'),(12,'seed',12,42.79,0.95,'2025-12-30 15:38:32'),(13,'seed',13,38.66,0.97,'2025-12-30 15:38:32'),(14,'seed',14,40.34,1.01,'2025-12-30 15:38:32'),(15,'seed',15,62.86,1.05,'2025-12-30 15:38:32'),(16,'seed',16,35.17,1.00,'2025-12-30 15:38:32'),(17,'seed',17,57.41,1.04,'2025-12-30 15:38:32'),(18,'seed',18,48.10,0.96,'2025-12-30 15:38:32'),(19,'seed',19,71.60,1.02,'2025-12-30 15:38:33'),(20,'seed',20,65.69,1.01,'2025-12-30 15:38:33'),(21,'seed',21,82.97,1.04,'2025-12-30 15:38:33'),(22,'seed',22,97.05,0.97,'2025-12-30 15:38:33'),(23,'seed',23,122.24,1.02,'2025-12-30 15:38:33'),(24,'seed',24,145.74,0.97,'2025-12-30 15:38:33'),(25,'seed',25,204.42,1.02,'2025-12-30 15:38:33'),(26,'seed',26,498.25,1.00,'2025-12-30 15:38:33'),(27,'crop',1,24.81,0.99,'2025-12-30 15:38:33'),(28,'crop',2,37.09,1.06,'2025-12-30 15:38:33'),(29,'crop',3,28.68,1.02,'2025-12-30 15:38:33'),(30,'crop',4,40.43,1.01,'2025-12-30 15:38:33'),(31,'crop',5,44.09,0.98,'2025-12-30 15:38:33'),(32,'crop',6,32.18,1.01,'2025-12-30 15:38:33'),(33,'crop',7,60.98,1.02,'2025-12-30 15:38:33'),(34,'crop',8,74.52,1.06,'2025-12-30 15:38:33'),(35,'crop',9,44.25,0.98,'2025-12-30 15:38:33'),(36,'crop',10,80.71,1.01,'2025-12-30 15:38:33'),(37,'crop',11,123.72,1.03,'2025-12-30 15:38:33'),(38,'crop',12,102.86,1.03,'2025-12-30 15:38:33'),(39,'crop',13,84.58,0.94,'2025-12-30 15:38:33'),(40,'crop',14,88.78,0.99,'2025-12-30 15:38:33'),(41,'crop',15,156.98,1.05,'2025-12-30 15:38:33'),(42,'crop',16,81.83,1.02,'2025-12-30 15:38:33'),(43,'crop',17,128.80,0.99,'2025-12-30 15:38:33'),(44,'crop',18,125.06,1.04,'2025-12-30 15:38:33'),(45,'crop',19,192.53,1.07,'2025-12-30 15:38:33'),(46,'crop',20,159.92,1.00,'2025-12-30 15:38:33'),(47,'crop',21,199.77,1.00,'2025-12-30 15:38:33'),(48,'crop',22,260.08,1.04,'2025-12-30 15:38:33'),(49,'crop',23,296.50,0.99,'2025-12-30 15:38:33'),(50,'crop',24,428.59,1.07,'2025-12-30 15:38:33'),(51,'crop',25,620.25,1.03,'2025-12-30 15:38:33'),(52,'crop',26,1561.83,1.04,'2025-12-30 15:38:33'),(53,'seed',1,9.54,0.95,'2025-12-30 15:43:33'),(54,'seed',2,14.79,0.99,'2025-12-30 15:43:33'),(55,'seed',3,12.00,1.00,'2025-12-30 15:43:33'),(56,'seed',4,18.07,1.00,'2025-12-30 15:43:33'),(57,'seed',5,19.63,0.98,'2025-12-30 15:43:33'),(58,'seed',6,13.31,0.95,'2025-12-30 15:43:33'),(59,'seed',7,24.02,0.96,'2025-12-30 15:43:33'),(60,'seed',8,30.90,1.03,'2025-12-30 15:43:33'),(61,'seed',9,20.90,1.04,'2025-12-30 15:43:33'),(62,'seed',10,34.39,0.98,'2025-12-30 15:43:34'),(63,'seed',11,48.82,0.98,'2025-12-30 15:43:34'),(64,'seed',12,44.82,1.00,'2025-12-30 15:43:34'),(65,'seed',13,38.07,0.95,'2025-12-30 15:43:34'),(66,'seed',14,38.43,0.96,'2025-12-30 15:43:34'),(67,'seed',15,59.57,0.99,'2025-12-30 15:43:34'),(68,'seed',16,36.41,1.04,'2025-12-30 15:43:34'),(69,'seed',17,57.32,1.04,'2025-12-30 15:43:34'),(70,'seed',18,48.89,0.98,'2025-12-30 15:43:34'),(71,'seed',19,71.69,1.02,'2025-12-30 15:43:34'),(72,'seed',20,64.91,1.00,'2025-12-30 15:43:34'),(73,'seed',21,76.40,0.96,'2025-12-30 15:43:34'),(74,'seed',22,104.43,1.04,'2025-12-30 15:43:34'),(75,'seed',23,118.76,0.99,'2025-12-30 15:43:34'),(76,'seed',24,143.97,0.96,'2025-12-30 15:43:34'),(77,'seed',25,209.05,1.05,'2025-12-30 15:43:34'),(78,'seed',26,510.87,1.02,'2025-12-30 15:43:34'),(79,'crop',1,24.61,0.98,'2025-12-30 15:43:34'),(80,'crop',2,36.66,1.05,'2025-12-30 15:43:34'),(81,'crop',3,29.02,1.04,'2025-12-30 15:43:34'),(82,'crop',4,40.25,1.01,'2025-12-30 15:43:34'),(83,'crop',5,47.13,1.05,'2025-12-30 15:43:34'),(84,'crop',6,32.22,1.01,'2025-12-30 15:43:34'),(85,'crop',7,64.38,1.07,'2025-12-30 15:43:34'),(86,'crop',8,72.87,1.04,'2025-12-30 15:43:34'),(87,'crop',9,47.51,1.06,'2025-12-30 15:43:34'),(88,'crop',10,76.99,0.96,'2025-12-30 15:43:34'),(89,'crop',11,124.10,1.03,'2025-12-30 15:43:34'),(90,'crop',12,106.84,1.07,'2025-12-30 15:43:34'),(91,'crop',13,90.28,1.00,'2025-12-30 15:43:34'),(92,'crop',14,88.85,0.99,'2025-12-30 15:43:34'),(93,'crop',15,147.79,0.99,'2025-12-30 15:43:34'),(94,'crop',16,75.40,0.94,'2025-12-30 15:43:34'),(95,'crop',17,132.21,1.02,'2025-12-30 15:43:34'),(96,'crop',18,122.60,1.02,'2025-12-30 15:43:34'),(97,'crop',19,187.49,1.04,'2025-12-30 15:43:34'),(98,'crop',20,159.77,1.00,'2025-12-30 15:43:34'),(99,'crop',21,195.61,0.98,'2025-12-30 15:43:34'),(100,'crop',22,237.03,0.95,'2025-12-30 15:43:34'),(101,'crop',23,314.87,1.05,'2025-12-30 15:43:34'),(102,'crop',24,419.22,1.05,'2025-12-30 15:43:34'),(103,'crop',25,637.52,1.06,'2025-12-30 15:43:34'),(104,'crop',26,1479.21,0.99,'2025-12-30 15:43:34'),(105,'seed',1,10.42,1.04,'2025-12-30 15:48:34'),(106,'seed',2,15.62,1.04,'2025-12-30 15:48:34'),(107,'seed',3,12.50,1.04,'2025-12-30 15:48:34'),(108,'seed',4,18.15,1.01,'2025-12-30 15:48:34'),(109,'seed',5,20.97,1.05,'2025-12-30 15:48:34'),(110,'seed',6,13.40,0.96,'2025-12-30 15:48:34'),(111,'seed',7,25.79,1.03,'2025-12-30 15:48:34'),(112,'seed',8,28.56,0.95,'2025-12-30 15:48:34'),(113,'seed',9,19.02,0.95,'2025-12-30 15:48:34'),(114,'seed',10,35.24,1.01,'2025-12-30 15:48:34'),(115,'seed',11,50.02,1.00,'2025-12-30 15:48:34'),(116,'seed',12,44.29,0.98,'2025-12-30 15:48:34'),(117,'seed',13,41.21,1.03,'2025-12-30 15:48:34'),(118,'seed',14,40.20,1.01,'2025-12-30 15:48:34'),(119,'seed',15,58.96,0.98,'2025-12-30 15:48:34'),(120,'seed',16,34.61,0.99,'2025-12-30 15:48:34'),(121,'seed',17,56.38,1.03,'2025-12-30 15:48:34'),(122,'seed',18,51.28,1.03,'2025-12-30 15:48:35'),(123,'seed',19,66.71,0.95,'2025-12-30 15:48:35'),(124,'seed',20,67.85,1.04,'2025-12-30 15:48:35'),(125,'seed',21,77.72,0.97,'2025-12-30 15:48:35'),(126,'seed',22,100.96,1.01,'2025-12-30 15:48:35'),(127,'seed',23,116.26,0.97,'2025-12-30 15:48:35'),(128,'seed',24,144.85,0.97,'2025-12-30 15:48:35'),(129,'seed',25,209.40,1.05,'2025-12-30 15:48:35'),(130,'seed',26,499.72,1.00,'2025-12-30 15:48:35'),(131,'crop',1,24.56,0.98,'2025-12-30 15:48:35'),(132,'crop',2,33.97,0.97,'2025-12-30 15:48:35'),(133,'crop',3,26.54,0.95,'2025-12-30 15:48:35'),(134,'crop',4,41.29,1.03,'2025-12-30 15:48:35'),(135,'crop',5,47.90,1.06,'2025-12-30 15:48:35'),(136,'crop',6,29.71,0.93,'2025-12-30 15:48:35'),(137,'crop',7,61.05,1.02,'2025-12-30 15:48:35'),(138,'crop',8,70.25,1.00,'2025-12-30 15:48:35'),(139,'crop',9,43.66,0.97,'2025-12-30 15:48:35'),(140,'crop',10,74.13,0.93,'2025-12-30 15:48:35'),(141,'crop',11,127.54,1.06,'2025-12-30 15:48:35'),(142,'crop',12,102.89,1.03,'2025-12-30 15:48:35'),(143,'crop',13,95.32,1.06,'2025-12-30 15:48:35'),(144,'crop',14,91.25,1.01,'2025-12-30 15:48:35'),(145,'crop',15,159.36,1.06,'2025-12-30 15:48:35'),(146,'crop',16,81.78,1.02,'2025-12-30 15:48:35'),(147,'crop',17,124.05,0.95,'2025-12-30 15:48:35'),(148,'crop',18,126.89,1.06,'2025-12-30 15:48:35'),(149,'crop',19,191.12,1.06,'2025-12-30 15:48:35'),(150,'crop',20,157.81,0.99,'2025-12-30 15:48:35'),(151,'crop',21,200.02,1.00,'2025-12-30 15:48:35'),(152,'crop',22,234.49,0.94,'2025-12-30 15:48:35'),(153,'crop',23,281.74,0.94,'2025-12-30 15:48:35'),(154,'crop',24,417.06,1.04,'2025-12-30 15:48:35'),(155,'crop',25,628.56,1.05,'2025-12-30 15:48:35'),(156,'crop',26,1424.17,0.95,'2025-12-30 15:48:35'),(157,'seed',1,9.92,0.99,'2025-12-30 15:53:35'),(158,'seed',2,14.26,0.95,'2025-12-30 15:53:35'),(159,'seed',3,12.34,1.03,'2025-12-30 15:53:35'),(160,'seed',4,17.42,0.97,'2025-12-30 15:53:35'),(161,'seed',5,20.40,1.02,'2025-12-30 15:53:35'),(162,'seed',6,13.63,0.97,'2025-12-30 15:53:35'),(163,'seed',7,23.80,0.95,'2025-12-30 15:53:35'),(164,'seed',8,29.87,1.00,'2025-12-30 15:53:35'),(165,'seed',9,20.37,1.02,'2025-12-30 15:53:35'),(166,'seed',10,35.46,1.01,'2025-12-30 15:53:35'),(167,'seed',11,47.58,0.95,'2025-12-30 15:53:35'),(168,'seed',12,42.97,0.95,'2025-12-30 15:53:35'),(169,'seed',13,40.32,1.01,'2025-12-30 15:53:35'),(170,'seed',14,38.94,0.97,'2025-12-30 15:53:35'),(171,'seed',15,61.69,1.03,'2025-12-30 15:53:36'),(172,'seed',16,35.12,1.00,'2025-12-30 15:53:36'),(173,'seed',17,56.43,1.03,'2025-12-30 15:53:36'),(174,'seed',18,50.67,1.01,'2025-12-30 15:53:36'),(175,'seed',19,69.18,0.99,'2025-12-30 15:53:36'),(176,'seed',20,63.77,0.98,'2025-12-30 15:53:36'),(177,'seed',21,80.61,1.01,'2025-12-30 15:53:36'),(178,'seed',22,96.78,0.97,'2025-12-30 15:53:36'),(179,'seed',23,115.20,0.96,'2025-12-30 15:53:36'),(180,'seed',24,150.82,1.01,'2025-12-30 15:53:36'),(181,'seed',25,192.63,0.96,'2025-12-30 15:53:36'),(182,'seed',26,483.11,0.97,'2025-12-30 15:53:36'),(183,'crop',1,23.83,0.95,'2025-12-30 15:53:36'),(184,'crop',2,36.99,1.06,'2025-12-30 15:53:36'),(185,'crop',3,27.58,0.98,'2025-12-30 15:53:36'),(186,'crop',4,41.16,1.03,'2025-12-30 15:53:36'),(187,'crop',5,45.06,1.00,'2025-12-30 15:53:36'),(188,'crop',6,34.26,1.07,'2025-12-30 15:53:36'),(189,'crop',7,64.43,1.07,'2025-12-30 15:53:36'),(190,'crop',8,71.44,1.02,'2025-12-30 15:53:36'),(191,'crop',9,42.75,0.95,'2025-12-30 15:53:36'),(192,'crop',10,81.46,1.02,'2025-12-30 15:53:36'),(193,'crop',11,118.91,0.99,'2025-12-30 15:53:36'),(194,'crop',12,100.02,1.00,'2025-12-30 15:53:36'),(195,'crop',13,86.20,0.96,'2025-12-30 15:53:36'),(196,'crop',14,93.27,1.04,'2025-12-30 15:53:36'),(197,'crop',15,159.90,1.07,'2025-12-30 15:53:36'),(198,'crop',16,77.57,0.97,'2025-12-30 15:53:36'),(199,'crop',17,129.66,1.00,'2025-12-30 15:53:36'),(200,'crop',18,124.51,1.04,'2025-12-30 15:53:36'),(201,'crop',19,171.23,0.95,'2025-12-30 15:53:36'),(202,'crop',20,169.92,1.06,'2025-12-30 15:53:36'),(203,'crop',21,199.02,1.00,'2025-12-30 15:53:36'),(204,'crop',22,249.49,1.00,'2025-12-30 15:53:36'),(205,'crop',23,294.09,0.98,'2025-12-30 15:53:36'),(206,'crop',24,404.62,1.01,'2025-12-30 15:53:36'),(207,'crop',25,639.44,1.07,'2025-12-30 15:53:36'),(208,'crop',26,1494.54,1.00,'2025-12-30 15:53:36'),(209,'seed',1,9.65,0.96,'2025-12-30 15:58:36'),(210,'seed',2,14.92,0.99,'2025-12-30 15:58:36'),(211,'seed',3,11.44,0.95,'2025-12-30 15:58:36'),(212,'seed',4,17.10,0.95,'2025-12-30 15:58:36'),(213,'seed',5,19.11,0.96,'2025-12-30 15:58:36'),(214,'seed',6,13.34,0.95,'2025-12-30 15:58:36'),(215,'seed',7,24.08,0.96,'2025-12-30 15:58:36'),(216,'seed',8,31.04,1.03,'2025-12-30 15:58:36'),(217,'seed',9,20.28,1.01,'2025-12-30 15:58:36'),(218,'seed',10,34.91,1.00,'2025-12-30 15:58:36'),(219,'seed',11,50.73,1.01,'2025-12-30 15:58:36'),(220,'seed',12,45.35,1.01,'2025-12-30 15:58:36'),(221,'seed',13,38.96,0.97,'2025-12-30 15:58:36'),(222,'seed',14,39.41,0.99,'2025-12-30 15:58:36'),(223,'seed',15,58.76,0.98,'2025-12-30 15:58:36'),(224,'seed',16,34.52,0.99,'2025-12-30 15:58:36'),(225,'seed',17,57.30,1.04,'2025-12-30 15:58:36'),(226,'seed',18,47.72,0.95,'2025-12-30 15:58:36'),(227,'seed',19,67.87,0.97,'2025-12-30 15:58:37'),(228,'seed',20,64.79,1.00,'2025-12-30 15:58:37'),(229,'seed',21,83.07,1.04,'2025-12-30 15:58:37'),(230,'seed',22,101.23,1.01,'2025-12-30 15:58:37'),(231,'seed',23,125.51,1.05,'2025-12-30 15:58:37'),(232,'seed',24,145.19,0.97,'2025-12-30 15:58:37'),(233,'seed',25,199.71,1.00,'2025-12-30 15:58:37'),(234,'seed',26,520.16,1.04,'2025-12-30 15:58:37'),(235,'crop',1,25.13,1.01,'2025-12-30 15:58:37'),(236,'crop',2,36.49,1.04,'2025-12-30 15:58:37'),(237,'crop',3,30.10,1.07,'2025-12-30 15:58:37'),(238,'crop',4,42.67,1.07,'2025-12-30 15:58:37'),(239,'crop',5,43.08,0.96,'2025-12-30 15:58:37'),(240,'crop',6,32.29,1.01,'2025-12-30 15:58:37'),(241,'crop',7,63.11,1.05,'2025-12-30 15:58:37'),(242,'crop',8,72.01,1.03,'2025-12-30 15:58:37'),(243,'crop',9,46.15,1.03,'2025-12-30 15:58:37'),(244,'crop',10,76.66,0.96,'2025-12-30 15:58:37'),(245,'crop',11,112.59,0.94,'2025-12-30 15:58:37'),(246,'crop',12,94.73,0.95,'2025-12-30 15:58:37'),(247,'crop',13,89.81,1.00,'2025-12-30 15:58:37'),(248,'crop',14,93.69,1.04,'2025-12-30 15:58:37'),(249,'crop',15,153.75,1.02,'2025-12-30 15:58:37'),(250,'crop',16,76.48,0.96,'2025-12-30 15:58:37'),(251,'crop',17,126.40,0.97,'2025-12-30 15:58:37'),(252,'crop',18,119.60,1.00,'2025-12-30 15:58:37'),(253,'crop',19,175.43,0.97,'2025-12-30 15:58:37'),(254,'crop',20,151.67,0.95,'2025-12-30 15:58:37'),(255,'crop',21,189.07,0.95,'2025-12-30 15:58:37'),(256,'crop',22,252.30,1.01,'2025-12-30 15:58:37'),(257,'crop',23,308.48,1.03,'2025-12-30 15:58:37'),(258,'crop',24,425.65,1.06,'2025-12-30 15:58:37'),(259,'crop',25,636.88,1.06,'2025-12-30 15:58:37'),(260,'crop',26,1408.53,0.94,'2025-12-30 15:58:37'),(261,'seed',1,9.56,0.96,'2025-12-30 16:00:52'),(262,'seed',2,15.62,1.04,'2025-12-30 16:00:52'),(263,'seed',3,12.29,1.02,'2025-12-30 16:00:52'),(264,'seed',4,17.81,0.99,'2025-12-30 16:00:52'),(265,'seed',5,19.60,0.98,'2025-12-30 16:00:52'),(266,'seed',6,14.55,1.04,'2025-12-30 16:00:52'),(267,'seed',7,25.47,1.02,'2025-12-30 16:00:52'),(268,'seed',8,29.43,0.98,'2025-12-30 16:00:52'),(269,'seed',9,19.82,0.99,'2025-12-30 16:00:52'),(270,'seed',10,34.55,0.99,'2025-12-30 16:00:52'),(271,'seed',11,50.86,1.02,'2025-12-30 16:00:52'),(272,'seed',12,47.09,1.05,'2025-12-30 16:00:52'),(273,'seed',13,40.39,1.01,'2025-12-30 16:00:52'),(274,'seed',14,40.08,1.00,'2025-12-30 16:00:52'),(275,'seed',15,59.78,1.00,'2025-12-30 16:00:52'),(276,'seed',16,33.85,0.97,'2025-12-30 16:00:52'),(277,'seed',17,56.82,1.03,'2025-12-30 16:00:52'),(278,'seed',18,49.16,0.98,'2025-12-30 16:00:52'),(279,'seed',19,69.58,0.99,'2025-12-30 16:00:52'),(280,'seed',20,67.72,1.04,'2025-12-30 16:00:52'),(281,'seed',21,81.84,1.02,'2025-12-30 16:00:53'),(282,'seed',22,96.95,0.97,'2025-12-30 16:00:53'),(283,'seed',23,125.03,1.04,'2025-12-30 16:00:53'),(284,'seed',24,142.85,0.95,'2025-12-30 16:00:53'),(285,'seed',25,195.03,0.98,'2025-12-30 16:00:53'),(286,'seed',26,500.06,1.00,'2025-12-30 16:00:53'),(287,'crop',1,26.86,1.07,'2025-12-30 16:00:53'),(288,'crop',2,34.79,0.99,'2025-12-30 16:00:53'),(289,'crop',3,28.28,1.01,'2025-12-30 16:00:53'),(290,'crop',4,40.95,1.02,'2025-12-30 16:00:53'),(291,'crop',5,47.82,1.06,'2025-12-30 16:00:53'),(292,'crop',6,32.47,1.01,'2025-12-30 16:00:53'),(293,'crop',7,61.45,1.02,'2025-12-30 16:00:53'),(294,'crop',8,66.32,0.95,'2025-12-30 16:00:53'),(295,'crop',9,41.69,0.93,'2025-12-30 16:00:53'),(296,'crop',10,84.71,1.06,'2025-12-30 16:00:53'),(297,'crop',11,121.90,1.02,'2025-12-30 16:00:53'),(298,'crop',12,102.50,1.03,'2025-12-30 16:00:53'),(299,'crop',13,91.08,1.01,'2025-12-30 16:00:53'),(300,'crop',14,88.12,0.98,'2025-12-30 16:00:53'),(301,'crop',15,147.50,0.98,'2025-12-30 16:00:53'),(302,'crop',16,77.10,0.96,'2025-12-30 16:00:53'),(303,'crop',17,125.40,0.96,'2025-12-30 16:00:53'),(304,'crop',18,119.33,0.99,'2025-12-30 16:00:53'),(305,'crop',19,168.86,0.94,'2025-12-30 16:00:53'),(306,'crop',20,167.95,1.05,'2025-12-30 16:00:53'),(307,'crop',21,213.51,1.07,'2025-12-30 16:00:53'),(308,'crop',22,250.57,1.00,'2025-12-30 16:00:53'),(309,'crop',23,287.63,0.96,'2025-12-30 16:00:53'),(310,'crop',24,413.45,1.03,'2025-12-30 16:00:53'),(311,'crop',25,642.84,1.07,'2025-12-30 16:00:53'),(312,'crop',26,1427.63,0.95,'2025-12-30 16:00:53'),(313,'seed',1,9.80,0.98,'2025-12-30 16:05:53'),(314,'seed',2,15.69,1.05,'2025-12-30 16:05:53'),(315,'seed',3,11.45,0.95,'2025-12-30 16:05:53'),(316,'seed',4,17.92,1.00,'2025-12-30 16:05:53'),(317,'seed',5,20.66,1.03,'2025-12-30 16:05:53'),(318,'seed',6,14.29,1.02,'2025-12-30 16:05:53'),(319,'seed',7,24.95,1.00,'2025-12-30 16:05:53'),(320,'seed',8,29.05,0.97,'2025-12-30 16:05:53'),(321,'seed',9,19.06,0.95,'2025-12-30 16:05:53'),(322,'seed',10,34.96,1.00,'2025-12-30 16:05:53'),(323,'seed',11,52.48,1.05,'2025-12-30 16:05:53'),(324,'seed',12,45.99,1.02,'2025-12-30 16:05:53'),(325,'seed',13,41.67,1.04,'2025-12-30 16:05:53'),(326,'seed',14,38.03,0.95,'2025-12-30 16:05:53'),(327,'seed',15,60.58,1.01,'2025-12-30 16:05:53'),(328,'seed',16,33.43,0.96,'2025-12-30 16:05:53'),(329,'seed',17,54.85,1.00,'2025-12-30 16:05:53'),(330,'seed',18,50.76,1.02,'2025-12-30 16:05:53'),(331,'seed',19,72.64,1.04,'2025-12-30 16:05:53'),(332,'seed',20,62.62,0.96,'2025-12-30 16:05:53'),(333,'seed',21,76.16,0.95,'2025-12-30 16:05:53'),(334,'seed',22,99.05,0.99,'2025-12-30 16:05:53'),(335,'seed',23,119.21,0.99,'2025-12-30 16:05:54'),(336,'seed',24,152.94,1.02,'2025-12-30 16:05:54'),(337,'seed',25,190.21,0.95,'2025-12-30 16:05:54'),(338,'seed',26,524.90,1.05,'2025-12-30 16:05:54'),(339,'crop',1,24.29,0.97,'2025-12-30 16:05:54'),(340,'crop',2,34.30,0.98,'2025-12-30 16:05:54'),(341,'crop',3,28.61,1.02,'2025-12-30 16:05:54'),(342,'crop',4,39.58,0.99,'2025-12-30 16:05:54'),(343,'crop',5,41.87,0.93,'2025-12-30 16:05:54'),(344,'crop',6,31.93,1.00,'2025-12-30 16:05:54'),(345,'crop',7,61.33,1.02,'2025-12-30 16:05:54'),(346,'crop',8,65.31,0.93,'2025-12-30 16:05:54'),(347,'crop',9,45.16,1.00,'2025-12-30 16:05:54'),(348,'crop',10,76.32,0.95,'2025-12-30 16:05:54'),(349,'crop',11,111.50,0.93,'2025-12-30 16:05:54'),(350,'crop',12,97.83,0.98,'2025-12-30 16:05:54'),(351,'crop',13,84.79,0.94,'2025-12-30 16:05:54'),(352,'crop',14,89.54,0.99,'2025-12-30 16:05:54'),(353,'crop',15,161.23,1.07,'2025-12-30 16:05:54'),(354,'crop',16,79.73,1.00,'2025-12-30 16:05:54'),(355,'crop',17,133.37,1.03,'2025-12-30 16:05:54'),(356,'crop',18,119.55,1.00,'2025-12-30 16:05:54'),(357,'crop',19,183.29,1.02,'2025-12-30 16:05:54'),(358,'crop',20,167.72,1.05,'2025-12-30 16:05:54'),(359,'crop',21,203.98,1.02,'2025-12-30 16:05:54'),(360,'crop',22,260.00,1.04,'2025-12-30 16:05:54'),(361,'crop',23,290.61,0.97,'2025-12-30 16:05:54'),(362,'crop',24,419.53,1.05,'2025-12-30 16:05:54'),(363,'crop',25,580.95,0.97,'2025-12-30 16:05:54'),(364,'crop',26,1516.08,1.01,'2025-12-30 16:05:54'),(365,'seed',1,10.19,1.02,'2025-12-30 16:10:54'),(366,'seed',2,15.61,1.04,'2025-12-30 16:10:54'),(367,'seed',3,12.46,1.04,'2025-12-30 16:10:54'),(368,'seed',4,18.48,1.03,'2025-12-30 16:10:54'),(369,'seed',5,19.86,0.99,'2025-12-30 16:10:54'),(370,'seed',6,14.35,1.03,'2025-12-30 16:10:54'),(371,'seed',7,25.94,1.04,'2025-12-30 16:10:54'),(372,'seed',8,31.02,1.03,'2025-12-30 16:10:54'),(373,'seed',9,20.53,1.03,'2025-12-30 16:10:54'),(374,'seed',10,34.08,0.97,'2025-12-30 16:10:54'),(375,'seed',11,49.05,0.98,'2025-12-30 16:10:54'),(376,'seed',12,46.73,1.04,'2025-12-30 16:10:54'),(377,'seed',13,39.81,1.00,'2025-12-30 16:10:54'),(378,'seed',14,40.67,1.02,'2025-12-30 16:10:54'),(379,'seed',15,59.89,1.00,'2025-12-30 16:10:54'),(380,'seed',16,34.30,0.98,'2025-12-30 16:10:54'),(381,'seed',17,56.31,1.02,'2025-12-30 16:10:54'),(382,'seed',18,48.27,0.97,'2025-12-30 16:10:54'),(383,'seed',19,70.67,1.01,'2025-12-30 16:10:54'),(384,'seed',20,67.46,1.04,'2025-12-30 16:10:54'),(385,'seed',21,79.77,1.00,'2025-12-30 16:10:54'),(386,'seed',22,95.85,0.96,'2025-12-30 16:10:54'),(387,'seed',23,117.89,0.98,'2025-12-30 16:10:54'),(388,'seed',24,152.82,1.02,'2025-12-30 16:10:54'),(389,'seed',25,206.48,1.03,'2025-12-30 16:10:54'),(390,'seed',26,487.85,0.98,'2025-12-30 16:10:54'),(391,'crop',1,24.72,0.99,'2025-12-30 16:10:54'),(392,'crop',2,35.52,1.01,'2025-12-30 16:10:55'),(393,'crop',3,27.18,0.97,'2025-12-30 16:10:55'),(394,'crop',4,40.23,1.01,'2025-12-30 16:10:55'),(395,'crop',5,47.75,1.06,'2025-12-30 16:10:55'),(396,'crop',6,31.81,0.99,'2025-12-30 16:10:55'),(397,'crop',7,62.76,1.05,'2025-12-30 16:10:55'),(398,'crop',8,70.49,1.01,'2025-12-30 16:10:55'),(399,'crop',9,44.34,0.99,'2025-12-30 16:10:55'),(400,'crop',10,77.49,0.97,'2025-12-30 16:10:55'),(401,'crop',11,115.96,0.97,'2025-12-30 16:10:55'),(402,'crop',12,102.09,1.02,'2025-12-30 16:10:55'),(403,'crop',13,93.61,1.04,'2025-12-30 16:10:55'),(404,'crop',14,91.96,1.02,'2025-12-30 16:10:55'),(405,'crop',15,140.17,0.93,'2025-12-30 16:10:55'),(406,'crop',16,75.91,0.95,'2025-12-30 16:10:55'),(407,'crop',17,139.66,1.07,'2025-12-30 16:10:55'),(408,'crop',18,121.38,1.01,'2025-12-30 16:10:55'),(409,'crop',19,192.06,1.07,'2025-12-30 16:10:55'),(410,'crop',20,151.98,0.95,'2025-12-30 16:10:55'),(411,'crop',21,202.22,1.01,'2025-12-30 16:10:55'),(412,'crop',22,241.69,0.97,'2025-12-30 16:10:55'),(413,'crop',23,305.65,1.02,'2025-12-30 16:10:55'),(414,'crop',24,428.74,1.07,'2025-12-30 16:10:55'),(415,'crop',25,599.23,1.00,'2025-12-30 16:10:55'),(416,'crop',26,1430.35,0.95,'2025-12-30 16:10:55'),(417,'seed',1,9.89,0.99,'2025-12-30 16:11:16'),(418,'seed',2,15.72,1.05,'2025-12-30 16:11:16'),(419,'seed',3,12.37,1.03,'2025-12-30 16:11:16'),(420,'seed',4,17.60,0.98,'2025-12-30 16:11:17'),(421,'seed',5,20.97,1.05,'2025-12-30 16:11:17'),(422,'seed',6,13.60,0.97,'2025-12-30 16:11:17'),(423,'seed',7,24.90,1.00,'2025-12-30 16:11:17'),(424,'seed',8,31.31,1.04,'2025-12-30 16:11:17'),(425,'seed',9,20.74,1.04,'2025-12-30 16:11:17'),(426,'seed',10,34.02,0.97,'2025-12-30 16:11:17'),(427,'seed',11,48.72,0.97,'2025-12-30 16:11:17'),(428,'seed',12,46.24,1.03,'2025-12-30 16:11:17'),(429,'seed',13,39.54,0.99,'2025-12-30 16:11:17'),(430,'seed',14,38.23,0.96,'2025-12-30 16:11:17'),(431,'seed',15,58.81,0.98,'2025-12-30 16:11:17'),(432,'seed',16,34.46,0.98,'2025-12-30 16:11:17'),(433,'seed',17,54.13,0.98,'2025-12-30 16:11:17'),(434,'seed',18,49.03,0.98,'2025-12-30 16:11:17'),(435,'seed',19,68.80,0.98,'2025-12-30 16:11:17'),(436,'seed',20,63.69,0.98,'2025-12-30 16:11:17'),(437,'seed',21,81.03,1.01,'2025-12-30 16:11:17'),(438,'seed',22,95.42,0.95,'2025-12-30 16:11:17'),(439,'seed',23,125.84,1.05,'2025-12-30 16:11:17'),(440,'seed',24,150.60,1.00,'2025-12-30 16:11:17'),(441,'seed',25,201.11,1.01,'2025-12-30 16:11:17'),(442,'seed',26,495.44,0.99,'2025-12-30 16:11:17'),(443,'crop',1,26.24,1.05,'2025-12-30 16:11:17'),(444,'crop',2,33.85,0.97,'2025-12-30 16:11:17'),(445,'crop',3,26.96,0.96,'2025-12-30 16:11:17'),(446,'crop',4,40.21,1.01,'2025-12-30 16:11:17'),(447,'crop',5,42.37,0.94,'2025-12-30 16:11:17'),(448,'crop',6,30.03,0.94,'2025-12-30 16:11:17'),(449,'crop',7,55.94,0.93,'2025-12-30 16:11:17'),(450,'crop',8,70.49,1.01,'2025-12-30 16:11:17'),(451,'crop',9,44.25,0.98,'2025-12-30 16:11:17'),(452,'crop',10,74.87,0.94,'2025-12-30 16:11:17'),(453,'crop',11,117.75,0.98,'2025-12-30 16:11:17'),(454,'crop',12,95.48,0.95,'2025-12-30 16:11:17'),(455,'crop',13,95.08,1.06,'2025-12-30 16:11:17'),(456,'crop',14,94.33,1.05,'2025-12-30 16:11:17'),(457,'crop',15,143.77,0.96,'2025-12-30 16:11:17'),(458,'crop',16,76.02,0.95,'2025-12-30 16:11:17'),(459,'crop',17,138.68,1.07,'2025-12-30 16:11:17'),(460,'crop',18,120.18,1.00,'2025-12-30 16:11:17'),(461,'crop',19,179.68,1.00,'2025-12-30 16:11:17'),(462,'crop',20,151.02,0.94,'2025-12-30 16:11:17'),(463,'crop',21,192.51,0.96,'2025-12-30 16:11:17'),(464,'crop',22,253.30,1.01,'2025-12-30 16:11:17'),(465,'crop',23,314.86,1.05,'2025-12-30 16:11:17'),(466,'crop',24,385.44,0.96,'2025-12-30 16:11:17'),(467,'crop',25,612.19,1.02,'2025-12-30 16:11:17'),(468,'crop',26,1498.87,1.00,'2025-12-30 16:11:17'),(469,'seed',1,9.98,1.00,'2025-12-30 16:16:17'),(470,'seed',2,15.56,1.04,'2025-12-30 16:16:17'),(471,'seed',3,11.44,0.95,'2025-12-30 16:16:17'),(472,'seed',4,18.42,1.02,'2025-12-30 16:16:18'),(473,'seed',5,19.09,0.95,'2025-12-30 16:16:18'),(474,'seed',6,14.25,1.02,'2025-12-30 16:16:18'),(475,'seed',7,24.11,0.96,'2025-12-30 16:16:18'),(476,'seed',8,28.51,0.95,'2025-12-30 16:16:18'),(477,'seed',9,20.16,1.01,'2025-12-30 16:16:18'),(478,'seed',10,35.98,1.03,'2025-12-30 16:16:18'),(479,'seed',11,51.88,1.04,'2025-12-30 16:16:18'),(480,'seed',12,45.04,1.00,'2025-12-30 16:16:18'),(481,'seed',13,41.90,1.05,'2025-12-30 16:16:18'),(482,'seed',14,38.92,0.97,'2025-12-30 16:16:18'),(483,'seed',15,60.25,1.00,'2025-12-30 16:16:18'),(484,'seed',16,35.83,1.02,'2025-12-30 16:16:18'),(485,'seed',17,55.83,1.02,'2025-12-30 16:16:18'),(486,'seed',18,47.82,0.96,'2025-12-30 16:16:18'),(487,'seed',19,72.23,1.03,'2025-12-30 16:16:18'),(488,'seed',20,65.64,1.01,'2025-12-30 16:16:18'),(489,'seed',21,81.93,1.02,'2025-12-30 16:16:18'),(490,'seed',22,102.27,1.02,'2025-12-30 16:16:18'),(491,'seed',23,118.47,0.99,'2025-12-30 16:16:18'),(492,'seed',24,143.68,0.96,'2025-12-30 16:16:18'),(493,'seed',25,190.13,0.95,'2025-12-30 16:16:18'),(494,'seed',26,509.33,1.02,'2025-12-30 16:16:18'),(495,'crop',1,25.22,1.01,'2025-12-30 16:16:18'),(496,'crop',2,35.50,1.01,'2025-12-30 16:16:18'),(497,'crop',3,28.20,1.01,'2025-12-30 16:16:18'),(498,'crop',4,41.50,1.04,'2025-12-30 16:16:18'),(499,'crop',5,41.69,0.93,'2025-12-30 16:16:18'),(500,'crop',6,30.92,0.97,'2025-12-30 16:16:18'),(501,'crop',7,60.41,1.01,'2025-12-30 16:16:18'),(502,'crop',8,71.87,1.03,'2025-12-30 16:16:18'),(503,'crop',9,41.72,0.93,'2025-12-30 16:16:18'),(504,'crop',10,74.48,0.93,'2025-12-30 16:16:18'),(505,'crop',11,115.92,0.97,'2025-12-30 16:16:18'),(506,'crop',12,97.69,0.98,'2025-12-30 16:16:18'),(507,'crop',13,91.79,1.02,'2025-12-30 16:16:18'),(508,'crop',14,89.97,1.00,'2025-12-30 16:16:18'),(509,'crop',15,150.90,1.01,'2025-12-30 16:16:18'),(510,'crop',16,78.28,0.98,'2025-12-30 16:16:18'),(511,'crop',17,123.57,0.95,'2025-12-30 16:16:18'),(512,'crop',18,127.56,1.06,'2025-12-30 16:16:18'),(513,'crop',19,175.10,0.97,'2025-12-30 16:16:18'),(514,'crop',20,166.63,1.04,'2025-12-30 16:16:18'),(515,'crop',21,201.92,1.01,'2025-12-30 16:16:18'),(516,'crop',22,251.01,1.00,'2025-12-30 16:16:18'),(517,'crop',23,293.49,0.98,'2025-12-30 16:16:18'),(518,'crop',24,376.89,0.94,'2025-12-30 16:16:18'),(519,'crop',25,593.14,0.99,'2025-12-30 16:16:18'),(520,'crop',26,1540.06,1.03,'2025-12-30 16:16:18'),(521,'seed',1,10.24,1.02,'2025-12-30 16:21:18'),(522,'seed',2,14.42,0.96,'2025-12-30 16:21:18'),(523,'seed',3,12.52,1.04,'2025-12-30 16:21:18'),(524,'seed',4,17.67,0.98,'2025-12-30 16:21:18'),(525,'seed',5,19.76,0.99,'2025-12-30 16:21:19'),(526,'seed',6,13.81,0.99,'2025-12-30 16:21:19'),(527,'seed',7,23.93,0.96,'2025-12-30 16:21:19'),(528,'seed',8,30.91,1.03,'2025-12-30 16:21:19'),(529,'seed',9,19.97,1.00,'2025-12-30 16:21:19'),(530,'seed',10,36.65,1.05,'2025-12-30 16:21:19'),(531,'seed',11,48.25,0.97,'2025-12-30 16:21:19'),(532,'seed',12,46.66,1.04,'2025-12-30 16:21:19'),(533,'seed',13,39.14,0.98,'2025-12-30 16:21:19'),(534,'seed',14,39.96,1.00,'2025-12-30 16:21:19'),(535,'seed',15,59.64,0.99,'2025-12-30 16:21:19'),(536,'seed',16,35.61,1.02,'2025-12-30 16:21:19'),(537,'seed',17,57.12,1.04,'2025-12-30 16:21:19'),(538,'seed',18,49.54,0.99,'2025-12-30 16:21:19'),(539,'seed',19,73.38,1.05,'2025-12-30 16:21:19'),(540,'seed',20,63.59,0.98,'2025-12-30 16:21:19'),(541,'seed',21,80.90,1.01,'2025-12-30 16:21:19'),(542,'seed',22,99.25,0.99,'2025-12-30 16:21:19'),(543,'seed',23,119.19,0.99,'2025-12-30 16:21:19'),(544,'seed',24,150.85,1.01,'2025-12-30 16:21:19'),(545,'seed',25,193.77,0.97,'2025-12-30 16:21:19'),(546,'seed',26,514.73,1.03,'2025-12-30 16:21:19'),(547,'crop',1,24.71,0.99,'2025-12-30 16:21:19'),(548,'crop',2,33.09,0.95,'2025-12-30 16:21:19'),(549,'crop',3,28.39,1.01,'2025-12-30 16:21:19'),(550,'crop',4,38.69,0.97,'2025-12-30 16:21:19'),(551,'crop',5,41.81,0.93,'2025-12-30 16:21:19'),(552,'crop',6,29.62,0.93,'2025-12-30 16:21:19'),(553,'crop',7,62.65,1.04,'2025-12-30 16:21:19'),(554,'crop',8,73.13,1.04,'2025-12-30 16:21:19'),(555,'crop',9,43.97,0.98,'2025-12-30 16:21:19'),(556,'crop',10,85.60,1.07,'2025-12-30 16:21:19'),(557,'crop',11,124.04,1.03,'2025-12-30 16:21:19'),(558,'crop',12,97.70,0.98,'2025-12-30 16:21:19'),(559,'crop',13,87.40,0.97,'2025-12-30 16:21:19'),(560,'crop',14,94.00,1.04,'2025-12-30 16:21:19'),(561,'crop',15,147.96,0.99,'2025-12-30 16:21:19'),(562,'crop',16,74.20,0.93,'2025-12-30 16:21:19'),(563,'crop',17,126.73,0.97,'2025-12-30 16:21:19'),(564,'crop',18,121.77,1.01,'2025-12-30 16:21:19'),(565,'crop',19,168.87,0.94,'2025-12-30 16:21:19'),(566,'crop',20,151.62,0.95,'2025-12-30 16:21:19'),(567,'crop',21,214.90,1.07,'2025-12-30 16:21:19'),(568,'crop',22,265.31,1.06,'2025-12-30 16:21:19'),(569,'crop',23,307.68,1.03,'2025-12-30 16:21:19'),(570,'crop',24,401.53,1.00,'2025-12-30 16:21:19'),(571,'crop',25,615.26,1.03,'2025-12-30 16:21:19'),(572,'crop',26,1501.93,1.00,'2025-12-30 16:21:19'),(573,'seed',1,10.17,1.02,'2025-12-30 16:21:29'),(574,'seed',2,15.67,1.04,'2025-12-30 16:21:29'),(575,'seed',3,12.33,1.03,'2025-12-30 16:21:29'),(576,'seed',4,17.46,0.97,'2025-12-30 16:21:29'),(577,'seed',5,20.21,1.01,'2025-12-30 16:21:29'),(578,'seed',6,14.45,1.03,'2025-12-30 16:21:29'),(579,'seed',7,23.84,0.95,'2025-12-30 16:21:29'),(580,'seed',8,28.84,0.96,'2025-12-30 16:21:29'),(581,'seed',9,19.24,0.96,'2025-12-30 16:21:29'),(582,'seed',10,33.72,0.96,'2025-12-30 16:21:29'),(583,'seed',11,49.34,0.99,'2025-12-30 16:21:30'),(584,'seed',12,44.17,0.98,'2025-12-30 16:21:30'),(585,'seed',13,41.42,1.04,'2025-12-30 16:21:30'),(586,'seed',14,38.31,0.96,'2025-12-30 16:21:30'),(587,'seed',15,57.83,0.96,'2025-12-30 16:21:30'),(588,'seed',16,34.57,0.99,'2025-12-30 16:21:30'),(589,'seed',17,53.99,0.98,'2025-12-30 16:21:30'),(590,'seed',18,48.36,0.97,'2025-12-30 16:21:30'),(591,'seed',19,66.80,0.95,'2025-12-30 16:21:30'),(592,'seed',20,62.63,0.96,'2025-12-30 16:21:30'),(593,'seed',21,83.95,1.05,'2025-12-30 16:21:30'),(594,'seed',22,99.44,0.99,'2025-12-30 16:21:30'),(595,'seed',23,119.65,1.00,'2025-12-30 16:21:30'),(596,'seed',24,150.28,1.00,'2025-12-30 16:21:30'),(597,'seed',25,193.99,0.97,'2025-12-30 16:21:30'),(598,'seed',26,476.24,0.95,'2025-12-30 16:21:30'),(599,'crop',1,23.67,0.95,'2025-12-30 16:21:30'),(600,'crop',2,33.09,0.95,'2025-12-30 16:21:30'),(601,'crop',3,27.92,1.00,'2025-12-30 16:21:30'),(602,'crop',4,38.01,0.95,'2025-12-30 16:21:30'),(603,'crop',5,46.39,1.03,'2025-12-30 16:21:30'),(604,'crop',6,31.82,0.99,'2025-12-30 16:21:30'),(605,'crop',7,56.02,0.93,'2025-12-30 16:21:30'),(606,'crop',8,72.80,1.04,'2025-12-30 16:21:30'),(607,'crop',9,42.50,0.94,'2025-12-30 16:21:30'),(608,'crop',10,79.59,0.99,'2025-12-30 16:21:30'),(609,'crop',11,121.32,1.01,'2025-12-30 16:21:30'),(610,'crop',12,106.00,1.06,'2025-12-30 16:21:30'),(611,'crop',13,86.41,0.96,'2025-12-30 16:21:30'),(612,'crop',14,90.58,1.01,'2025-12-30 16:21:30'),(613,'crop',15,141.85,0.95,'2025-12-30 16:21:30'),(614,'crop',16,81.14,1.01,'2025-12-30 16:21:30'),(615,'crop',17,120.72,0.93,'2025-12-30 16:21:30'),(616,'crop',18,123.73,1.03,'2025-12-30 16:21:30'),(617,'crop',19,169.13,0.94,'2025-12-30 16:21:30'),(618,'crop',20,149.92,0.94,'2025-12-30 16:21:30'),(619,'crop',21,202.83,1.01,'2025-12-30 16:21:30'),(620,'crop',22,256.37,1.03,'2025-12-30 16:21:30'),(621,'crop',23,285.97,0.95,'2025-12-30 16:21:30'),(622,'crop',24,397.68,0.99,'2025-12-30 16:21:30'),(623,'crop',25,618.33,1.03,'2025-12-30 16:21:30'),(624,'crop',26,1530.84,1.02,'2025-12-30 16:21:30'),(625,'seed',1,9.68,0.97,'2025-12-30 16:26:30'),(626,'seed',2,15.51,1.03,'2025-12-30 16:26:30'),(627,'seed',3,12.29,1.02,'2025-12-30 16:26:30'),(628,'seed',4,17.32,0.96,'2025-12-30 16:26:30'),(629,'seed',5,20.37,1.02,'2025-12-30 16:26:30'),(630,'seed',6,14.54,1.04,'2025-12-30 16:26:30'),(631,'seed',7,24.73,0.99,'2025-12-30 16:26:30'),(632,'seed',8,31.34,1.04,'2025-12-30 16:26:31'),(633,'seed',9,20.22,1.01,'2025-12-30 16:26:31'),(634,'seed',10,34.66,0.99,'2025-12-30 16:26:31'),(635,'seed',11,51.49,1.03,'2025-12-30 16:26:31'),(636,'seed',12,43.66,0.97,'2025-12-30 16:26:31'),(637,'seed',13,41.03,1.03,'2025-12-30 16:26:31'),(638,'seed',14,41.57,1.04,'2025-12-30 16:26:31'),(639,'seed',15,61.39,1.02,'2025-12-30 16:26:31'),(640,'seed',16,35.91,1.03,'2025-12-30 16:26:31'),(641,'seed',17,54.03,0.98,'2025-12-30 16:26:31'),(642,'seed',18,49.20,0.98,'2025-12-30 16:26:31'),(643,'seed',19,69.86,1.00,'2025-12-30 16:26:31'),(644,'seed',20,66.80,1.03,'2025-12-30 16:26:31'),(645,'seed',21,76.55,0.96,'2025-12-30 16:26:31'),(646,'seed',22,99.64,1.00,'2025-12-30 16:26:31'),(647,'seed',23,119.01,0.99,'2025-12-30 16:26:31'),(648,'seed',24,147.03,0.98,'2025-12-30 16:26:31'),(649,'seed',25,195.93,0.98,'2025-12-30 16:26:31'),(650,'seed',26,513.97,1.03,'2025-12-30 16:26:31'),(651,'crop',1,24.14,0.97,'2025-12-30 16:26:31'),(652,'crop',2,32.97,0.94,'2025-12-30 16:26:31'),(653,'crop',3,29.96,1.07,'2025-12-30 16:26:31'),(654,'crop',4,40.84,1.02,'2025-12-30 16:26:31'),(655,'crop',5,42.58,0.95,'2025-12-30 16:26:31'),(656,'crop',6,32.72,1.02,'2025-12-30 16:26:31'),(657,'crop',7,60.27,1.00,'2025-12-30 16:26:31'),(658,'crop',8,70.71,1.01,'2025-12-30 16:26:31'),(659,'crop',9,41.77,0.93,'2025-12-30 16:26:31'),(660,'crop',10,74.05,0.93,'2025-12-30 16:26:31'),(661,'crop',11,127.94,1.07,'2025-12-30 16:26:31'),(662,'crop',12,93.69,0.94,'2025-12-30 16:26:31'),(663,'crop',13,84.92,0.94,'2025-12-30 16:26:31'),(664,'crop',14,95.82,1.06,'2025-12-30 16:26:31'),(665,'crop',15,140.54,0.94,'2025-12-30 16:26:31'),(666,'crop',16,82.87,1.04,'2025-12-30 16:26:31'),(667,'crop',17,121.87,0.94,'2025-12-30 16:26:31'),(668,'crop',18,113.16,0.94,'2025-12-30 16:26:31'),(669,'crop',19,190.42,1.06,'2025-12-30 16:26:31'),(670,'crop',20,161.85,1.01,'2025-12-30 16:26:31'),(671,'crop',21,188.87,0.94,'2025-12-30 16:26:31'),(672,'crop',22,237.94,0.95,'2025-12-30 16:26:31'),(673,'crop',23,305.99,1.02,'2025-12-30 16:26:31'),(674,'crop',24,399.66,1.00,'2025-12-30 16:26:31'),(675,'crop',25,576.97,0.96,'2025-12-30 16:26:31'),(676,'crop',26,1606.56,1.07,'2025-12-30 16:26:31'),(677,'seed',1,9.96,1.00,'2025-12-30 16:31:31'),(678,'seed',2,14.58,0.97,'2025-12-30 16:31:31'),(679,'seed',3,11.65,0.97,'2025-12-30 16:31:31'),(680,'seed',4,17.94,1.00,'2025-12-30 16:31:31'),(681,'seed',5,20.83,1.04,'2025-12-30 16:31:31'),(682,'seed',6,13.77,0.98,'2025-12-30 16:31:31'),(683,'seed',7,25.48,1.02,'2025-12-30 16:31:31'),(684,'seed',8,30.09,1.00,'2025-12-30 16:31:31'),(685,'seed',9,20.35,1.02,'2025-12-30 16:31:31'),(686,'seed',10,33.73,0.96,'2025-12-30 16:31:31'),(687,'seed',11,48.89,0.98,'2025-12-30 16:31:31'),(688,'seed',12,46.86,1.04,'2025-12-30 16:31:32'),(689,'seed',13,40.11,1.00,'2025-12-30 16:31:32'),(690,'seed',14,41.98,1.05,'2025-12-30 16:31:32'),(691,'seed',15,58.19,0.97,'2025-12-30 16:31:32'),(692,'seed',16,34.75,0.99,'2025-12-30 16:31:32'),(693,'seed',17,54.87,1.00,'2025-12-30 16:31:32'),(694,'seed',18,49.84,1.00,'2025-12-30 16:31:32'),(695,'seed',19,70.13,1.00,'2025-12-30 16:31:32'),(696,'seed',20,64.85,1.00,'2025-12-30 16:31:32'),(697,'seed',21,76.20,0.95,'2025-12-30 16:31:32'),(698,'seed',22,102.35,1.02,'2025-12-30 16:31:32'),(699,'seed',23,115.02,0.96,'2025-12-30 16:31:32'),(700,'seed',24,143.19,0.95,'2025-12-30 16:31:32'),(701,'seed',25,205.24,1.03,'2025-12-30 16:31:32'),(702,'seed',26,514.55,1.03,'2025-12-30 16:31:32'),(703,'crop',1,23.55,0.94,'2025-12-30 16:31:32'),(704,'crop',2,33.20,0.95,'2025-12-30 16:31:32'),(705,'crop',3,26.48,0.95,'2025-12-30 16:31:32'),(706,'crop',4,40.09,1.00,'2025-12-30 16:31:32'),(707,'crop',5,46.86,1.04,'2025-12-30 16:31:32'),(708,'crop',6,33.59,1.05,'2025-12-30 16:31:32'),(709,'crop',7,57.09,0.95,'2025-12-30 16:31:32'),(710,'crop',8,66.43,0.95,'2025-12-30 16:31:32'),(711,'crop',9,44.21,0.98,'2025-12-30 16:31:32'),(712,'crop',10,74.38,0.93,'2025-12-30 16:31:32'),(713,'crop',11,125.06,1.04,'2025-12-30 16:31:32'),(714,'crop',12,105.09,1.05,'2025-12-30 16:31:32'),(715,'crop',13,89.23,0.99,'2025-12-30 16:31:32'),(716,'crop',14,93.20,1.04,'2025-12-30 16:31:32'),(717,'crop',15,139.73,0.93,'2025-12-30 16:31:32'),(718,'crop',16,83.50,1.04,'2025-12-30 16:31:32'),(719,'crop',17,133.36,1.03,'2025-12-30 16:31:32'),(720,'crop',18,121.93,1.02,'2025-12-30 16:31:32'),(721,'crop',19,185.56,1.03,'2025-12-30 16:31:32'),(722,'crop',20,155.68,0.97,'2025-12-30 16:31:32'),(723,'crop',21,202.86,1.01,'2025-12-30 16:31:32'),(724,'crop',22,237.96,0.95,'2025-12-30 16:31:32'),(725,'crop',23,300.13,1.00,'2025-12-30 16:31:32'),(726,'crop',24,384.58,0.96,'2025-12-30 16:31:32'),(727,'crop',25,633.66,1.06,'2025-12-30 16:31:32'),(728,'crop',26,1404.19,0.94,'2025-12-30 16:31:32'),(729,'seed',1,9.58,0.96,'2025-12-30 16:36:32'),(730,'seed',2,14.75,0.98,'2025-12-30 16:36:32'),(731,'seed',3,11.93,0.99,'2025-12-30 16:36:32'),(732,'seed',4,18.20,1.01,'2025-12-30 16:36:32'),(733,'seed',5,19.29,0.96,'2025-12-30 16:36:32'),(734,'seed',6,14.43,1.03,'2025-12-30 16:36:32'),(735,'seed',7,24.21,0.97,'2025-12-30 16:36:32'),(736,'seed',8,29.32,0.98,'2025-12-30 16:36:32'),(737,'seed',9,20.54,1.03,'2025-12-30 16:36:32'),(738,'seed',10,36.64,1.05,'2025-12-30 16:36:32'),(739,'seed',11,51.87,1.04,'2025-12-30 16:36:33'),(740,'seed',12,45.94,1.02,'2025-12-30 16:36:33'),(741,'seed',13,38.49,0.96,'2025-12-30 16:36:33'),(742,'seed',14,41.20,1.03,'2025-12-30 16:36:33'),(743,'seed',15,60.79,1.01,'2025-12-30 16:36:33'),(744,'seed',16,33.79,0.97,'2025-12-30 16:36:33'),(745,'seed',17,53.60,0.97,'2025-12-30 16:36:33'),(746,'seed',18,48.80,0.98,'2025-12-30 16:36:33'),(747,'seed',19,69.68,1.00,'2025-12-30 16:36:33'),(748,'seed',20,62.38,0.96,'2025-12-30 16:36:33'),(749,'seed',21,78.74,0.98,'2025-12-30 16:36:33'),(750,'seed',22,103.52,1.04,'2025-12-30 16:36:33'),(751,'seed',23,125.01,1.04,'2025-12-30 16:36:33'),(752,'seed',24,156.90,1.05,'2025-12-30 16:36:33'),(753,'seed',25,209.17,1.05,'2025-12-30 16:36:33'),(754,'seed',26,485.17,0.97,'2025-12-30 16:36:33'),(755,'crop',1,24.89,1.00,'2025-12-30 16:36:33'),(756,'crop',2,35.51,1.01,'2025-12-30 16:36:33'),(757,'crop',3,29.86,1.07,'2025-12-30 16:36:33'),(758,'crop',4,38.87,0.97,'2025-12-30 16:36:33'),(759,'crop',5,47.94,1.07,'2025-12-30 16:36:33'),(760,'crop',6,32.17,1.01,'2025-12-30 16:36:33'),(761,'crop',7,56.88,0.95,'2025-12-30 16:36:33'),(762,'crop',8,73.95,1.06,'2025-12-30 16:36:33'),(763,'crop',9,44.34,0.99,'2025-12-30 16:36:33'),(764,'crop',10,83.22,1.04,'2025-12-30 16:36:33'),(765,'crop',11,111.28,0.93,'2025-12-30 16:36:33'),(766,'crop',12,105.23,1.05,'2025-12-30 16:36:33'),(767,'crop',13,90.18,1.00,'2025-12-30 16:36:33'),(768,'crop',14,87.29,0.97,'2025-12-30 16:36:33'),(769,'crop',15,153.27,1.02,'2025-12-30 16:36:33'),(770,'crop',16,85.19,1.06,'2025-12-30 16:36:33'),(771,'crop',17,123.82,0.95,'2025-12-30 16:36:33'),(772,'crop',18,118.20,0.99,'2025-12-30 16:36:33'),(773,'crop',19,190.58,1.06,'2025-12-30 16:36:33'),(774,'crop',20,171.50,1.07,'2025-12-30 16:36:33'),(775,'crop',21,214.89,1.07,'2025-12-30 16:36:33'),(776,'crop',22,257.42,1.03,'2025-12-30 16:36:33'),(777,'crop',23,305.00,1.02,'2025-12-30 16:36:33'),(778,'crop',24,390.46,0.98,'2025-12-30 16:36:33'),(779,'crop',25,603.21,1.01,'2025-12-30 16:36:33'),(780,'crop',26,1483.50,0.99,'2025-12-30 16:36:33'),(781,'seed',1,9.82,0.98,'2025-12-30 16:41:33'),(782,'seed',2,15.70,1.05,'2025-12-30 16:41:33'),(783,'seed',3,12.57,1.05,'2025-12-30 16:41:33'),(784,'seed',4,18.12,1.01,'2025-12-30 16:41:33'),(785,'seed',5,20.41,1.02,'2025-12-30 16:41:33'),(786,'seed',6,13.83,0.99,'2025-12-30 16:41:33'),(787,'seed',7,25.65,1.03,'2025-12-30 16:41:33'),(788,'seed',8,31.41,1.05,'2025-12-30 16:41:33'),(789,'seed',9,20.23,1.01,'2025-12-30 16:41:33'),(790,'seed',10,35.08,1.00,'2025-12-30 16:41:33'),(791,'seed',11,50.37,1.01,'2025-12-30 16:41:33'),(792,'seed',12,45.62,1.01,'2025-12-30 16:41:34'),(793,'seed',13,38.47,0.96,'2025-12-30 16:41:34'),(794,'seed',14,38.07,0.95,'2025-12-30 16:41:34'),(795,'seed',15,58.42,0.97,'2025-12-30 16:41:34'),(796,'seed',16,34.55,0.99,'2025-12-30 16:41:34'),(797,'seed',17,57.02,1.04,'2025-12-30 16:41:34'),(798,'seed',18,50.10,1.00,'2025-12-30 16:41:34'),(799,'seed',19,67.59,0.97,'2025-12-30 16:41:34'),(800,'seed',20,67.18,1.03,'2025-12-30 16:41:34'),(801,'seed',21,80.31,1.00,'2025-12-30 16:41:34'),(802,'seed',22,102.10,1.02,'2025-12-30 16:41:34'),(803,'seed',23,117.85,0.98,'2025-12-30 16:41:34'),(804,'seed',24,156.95,1.05,'2025-12-30 16:41:34'),(805,'seed',25,190.02,0.95,'2025-12-30 16:41:34'),(806,'seed',26,514.55,1.03,'2025-12-30 16:41:34'),(807,'crop',1,25.89,1.04,'2025-12-30 16:41:34'),(808,'crop',2,32.73,0.94,'2025-12-30 16:41:34'),(809,'crop',3,28.19,1.01,'2025-12-30 16:41:34'),(810,'crop',4,40.81,1.02,'2025-12-30 16:41:34'),(811,'crop',5,44.84,1.00,'2025-12-30 16:41:34'),(812,'crop',6,33.76,1.06,'2025-12-30 16:41:34'),(813,'crop',7,56.77,0.95,'2025-12-30 16:41:34'),(814,'crop',8,69.88,1.00,'2025-12-30 16:41:34'),(815,'crop',9,45.06,1.00,'2025-12-30 16:41:34'),(816,'crop',10,77.95,0.97,'2025-12-30 16:41:34'),(817,'crop',11,116.43,0.97,'2025-12-30 16:41:34'),(818,'crop',12,106.54,1.07,'2025-12-30 16:41:34'),(819,'crop',13,87.55,0.97,'2025-12-30 16:41:34'),(820,'crop',14,87.35,0.97,'2025-12-30 16:41:34'),(821,'crop',15,141.80,0.95,'2025-12-30 16:41:34'),(822,'crop',16,80.39,1.00,'2025-12-30 16:41:34'),(823,'crop',17,125.19,0.96,'2025-12-30 16:41:34'),(824,'crop',18,116.57,0.97,'2025-12-30 16:41:34'),(825,'crop',19,166.80,0.93,'2025-12-30 16:41:34'),(826,'crop',20,149.07,0.93,'2025-12-30 16:41:34'),(827,'crop',21,206.16,1.03,'2025-12-30 16:41:34'),(828,'crop',22,243.84,0.98,'2025-12-30 16:41:34'),(829,'crop',23,292.62,0.98,'2025-12-30 16:41:34'),(830,'crop',24,380.26,0.95,'2025-12-30 16:41:34'),(831,'crop',25,638.94,1.06,'2025-12-30 16:41:34'),(832,'crop',26,1451.22,0.97,'2025-12-30 16:41:34'),(833,'seed',1,10.23,1.02,'2025-12-30 16:46:34'),(834,'seed',2,14.79,0.99,'2025-12-30 16:46:34'),(835,'seed',3,12.37,1.03,'2025-12-30 16:46:34'),(836,'seed',4,18.32,1.02,'2025-12-30 16:46:35'),(837,'seed',5,19.78,0.99,'2025-12-30 16:46:35'),(838,'seed',6,13.89,0.99,'2025-12-30 16:46:35'),(839,'seed',7,25.66,1.03,'2025-12-30 16:46:35'),(840,'seed',8,31.34,1.04,'2025-12-30 16:46:35'),(841,'seed',9,19.20,0.96,'2025-12-30 16:46:35'),(842,'seed',10,33.94,0.97,'2025-12-30 16:46:35'),(843,'seed',11,47.64,0.95,'2025-12-30 16:46:35'),(844,'seed',12,43.17,0.96,'2025-12-30 16:46:35'),(845,'seed',13,38.40,0.96,'2025-12-30 16:46:35'),(846,'seed',14,39.32,0.98,'2025-12-30 16:46:35'),(847,'seed',15,58.07,0.97,'2025-12-30 16:46:35'),(848,'seed',16,34.31,0.98,'2025-12-30 16:46:35'),(849,'seed',17,57.13,1.04,'2025-12-30 16:46:35'),(850,'seed',18,50.66,1.01,'2025-12-30 16:46:35'),(851,'seed',19,70.47,1.01,'2025-12-30 16:46:35'),(852,'seed',20,67.27,1.03,'2025-12-30 16:46:35'),(853,'seed',21,81.88,1.02,'2025-12-30 16:46:35'),(854,'seed',22,95.33,0.95,'2025-12-30 16:46:35'),(855,'seed',23,119.27,0.99,'2025-12-30 16:46:35'),(856,'seed',24,143.79,0.96,'2025-12-30 16:46:35'),(857,'seed',25,190.33,0.95,'2025-12-30 16:46:35'),(858,'seed',26,511.12,1.02,'2025-12-30 16:46:35'),(859,'crop',1,24.68,0.99,'2025-12-30 16:46:35'),(860,'crop',2,35.95,1.03,'2025-12-30 16:46:35'),(861,'crop',3,26.17,0.93,'2025-12-30 16:46:35'),(862,'crop',4,41.79,1.04,'2025-12-30 16:46:35'),(863,'crop',5,42.20,0.94,'2025-12-30 16:46:35'),(864,'crop',6,33.27,1.04,'2025-12-30 16:46:35'),(865,'crop',7,58.33,0.97,'2025-12-30 16:46:35'),(866,'crop',8,73.03,1.04,'2025-12-30 16:46:35'),(867,'crop',9,45.17,1.00,'2025-12-30 16:46:35'),(868,'crop',10,83.34,1.04,'2025-12-30 16:46:35'),(869,'crop',11,113.03,0.94,'2025-12-30 16:46:35'),(870,'crop',12,95.70,0.96,'2025-12-30 16:46:35'),(871,'crop',13,84.64,0.94,'2025-12-30 16:46:35'),(872,'crop',14,92.20,1.02,'2025-12-30 16:46:35'),(873,'crop',15,153.57,1.02,'2025-12-30 16:46:35'),(874,'crop',16,76.41,0.96,'2025-12-30 16:46:35'),(875,'crop',17,124.01,0.95,'2025-12-30 16:46:35'),(876,'crop',18,119.67,1.00,'2025-12-30 16:46:35'),(877,'crop',19,169.53,0.94,'2025-12-30 16:46:35'),(878,'crop',20,153.05,0.96,'2025-12-30 16:46:35'),(879,'crop',21,213.37,1.07,'2025-12-30 16:46:35'),(880,'crop',22,248.87,1.00,'2025-12-30 16:46:35'),(881,'crop',23,282.48,0.94,'2025-12-30 16:46:35'),(882,'crop',24,378.88,0.95,'2025-12-30 16:46:35'),(883,'crop',25,565.70,0.94,'2025-12-30 16:46:35'),(884,'crop',26,1500.64,1.00,'2025-12-30 16:46:35'),(885,'seed',1,10.15,1.02,'2025-12-30 16:48:10'),(886,'seed',2,15.03,1.00,'2025-12-30 16:48:10'),(887,'seed',3,11.76,0.98,'2025-12-30 16:48:10'),(888,'seed',4,17.76,0.99,'2025-12-30 16:48:10'),(889,'seed',5,19.62,0.98,'2025-12-30 16:48:10'),(890,'seed',6,13.54,0.97,'2025-12-30 16:48:10'),(891,'seed',7,24.19,0.97,'2025-12-30 16:48:10'),(892,'seed',8,29.47,0.98,'2025-12-30 16:48:10'),(893,'seed',9,19.52,0.98,'2025-12-30 16:48:10'),(894,'seed',10,36.24,1.04,'2025-12-30 16:48:10'),(895,'seed',11,52.03,1.04,'2025-12-30 16:48:10'),(896,'seed',12,43.37,0.96,'2025-12-30 16:48:10'),(897,'seed',13,40.19,1.00,'2025-12-30 16:48:10'),(898,'seed',14,41.73,1.04,'2025-12-30 16:48:10'),(899,'seed',15,58.50,0.97,'2025-12-30 16:48:10'),(900,'seed',16,35.19,1.01,'2025-12-30 16:48:10'),(901,'seed',17,56.03,1.02,'2025-12-30 16:48:10'),(902,'seed',18,52.09,1.04,'2025-12-30 16:48:10'),(903,'seed',19,69.09,0.99,'2025-12-30 16:48:10'),(904,'seed',20,64.64,0.99,'2025-12-30 16:48:10'),(905,'seed',21,83.96,1.05,'2025-12-30 16:48:10'),(906,'seed',22,95.68,0.96,'2025-12-30 16:48:10'),(907,'seed',23,117.84,0.98,'2025-12-30 16:48:10'),(908,'seed',24,148.47,0.99,'2025-12-30 16:48:10'),(909,'seed',25,192.57,0.96,'2025-12-30 16:48:10'),(910,'seed',26,479.26,0.96,'2025-12-30 16:48:10'),(911,'crop',1,26.08,1.04,'2025-12-30 16:48:10'),(912,'crop',2,33.72,0.96,'2025-12-30 16:48:10'),(913,'crop',3,28.03,1.00,'2025-12-30 16:48:10'),(914,'crop',4,42.32,1.06,'2025-12-30 16:48:10'),(915,'crop',5,47.71,1.06,'2025-12-30 16:48:10'),(916,'crop',6,30.95,0.97,'2025-12-30 16:48:10'),(917,'crop',7,60.59,1.01,'2025-12-30 16:48:10'),(918,'crop',8,67.98,0.97,'2025-12-30 16:48:10'),(919,'crop',9,47.36,1.05,'2025-12-30 16:48:10'),(920,'crop',10,74.88,0.94,'2025-12-30 16:48:10'),(921,'crop',11,124.08,1.03,'2025-12-30 16:48:10'),(922,'crop',12,105.68,1.06,'2025-12-30 16:48:10'),(923,'crop',13,87.76,0.98,'2025-12-30 16:48:10'),(924,'crop',14,87.07,0.97,'2025-12-30 16:48:10'),(925,'crop',15,151.23,1.01,'2025-12-30 16:48:10'),(926,'crop',16,85.94,1.07,'2025-12-30 16:48:10'),(927,'crop',17,126.21,0.97,'2025-12-30 16:48:10'),(928,'crop',18,112.17,0.93,'2025-12-30 16:48:10'),(929,'crop',19,182.05,1.01,'2025-12-30 16:48:10'),(930,'crop',20,164.18,1.03,'2025-12-30 16:48:10'),(931,'crop',21,196.80,0.98,'2025-12-30 16:48:10'),(932,'crop',22,234.07,0.94,'2025-12-30 16:48:10'),(933,'crop',23,290.28,0.97,'2025-12-30 16:48:10'),(934,'crop',24,397.29,0.99,'2025-12-30 16:48:10'),(935,'crop',25,627.77,1.05,'2025-12-30 16:48:10'),(936,'crop',26,1402.26,0.93,'2025-12-30 16:48:10'),(937,'seed',1,9.87,0.99,'2025-12-30 16:50:40'),(938,'seed',2,15.24,1.02,'2025-12-30 16:50:41'),(939,'seed',3,11.41,0.95,'2025-12-30 16:50:41'),(940,'seed',4,18.14,1.01,'2025-12-30 16:50:41'),(941,'seed',5,19.93,1.00,'2025-12-30 16:50:41'),(942,'seed',6,13.52,0.97,'2025-12-30 16:50:41'),(943,'seed',7,25.23,1.01,'2025-12-30 16:50:41'),(944,'seed',8,30.49,1.02,'2025-12-30 16:50:41'),(945,'seed',9,19.67,0.98,'2025-12-30 16:50:41'),(946,'seed',10,35.44,1.01,'2025-12-30 16:50:41'),(947,'seed',11,51.42,1.03,'2025-12-30 16:50:41'),(948,'seed',12,46.53,1.03,'2025-12-30 16:50:41'),(949,'seed',13,40.23,1.01,'2025-12-30 16:50:41'),(950,'seed',14,39.08,0.98,'2025-12-30 16:50:41'),(951,'seed',15,62.11,1.04,'2025-12-30 16:50:41'),(952,'seed',16,36.48,1.04,'2025-12-30 16:50:41'),(953,'seed',17,55.35,1.01,'2025-12-30 16:50:41'),(954,'seed',18,51.21,1.02,'2025-12-30 16:50:41'),(955,'seed',19,67.49,0.96,'2025-12-30 16:50:41'),(956,'seed',20,62.26,0.96,'2025-12-30 16:50:41'),(957,'seed',21,81.98,1.02,'2025-12-30 16:50:41'),(958,'seed',22,101.86,1.02,'2025-12-30 16:50:41'),(959,'seed',23,123.54,1.03,'2025-12-30 16:50:41'),(960,'seed',24,153.74,1.02,'2025-12-30 16:50:41'),(961,'seed',25,208.11,1.04,'2025-12-30 16:50:41'),(962,'seed',26,499.34,1.00,'2025-12-30 16:50:41'),(963,'crop',1,24.20,0.97,'2025-12-30 16:50:41'),(964,'crop',2,35.39,1.01,'2025-12-30 16:50:41'),(965,'crop',3,29.21,1.04,'2025-12-30 16:50:41'),(966,'crop',4,42.22,1.06,'2025-12-30 16:50:41'),(967,'crop',5,46.07,1.02,'2025-12-30 16:50:41'),(968,'crop',6,32.70,1.02,'2025-12-30 16:50:41'),(969,'crop',7,63.86,1.06,'2025-12-30 16:50:41'),(970,'crop',8,68.20,0.97,'2025-12-30 16:50:41'),(971,'crop',9,46.79,1.04,'2025-12-30 16:50:41'),(972,'crop',10,78.25,0.98,'2025-12-30 16:50:41'),(973,'crop',11,121.40,1.01,'2025-12-30 16:50:41'),(974,'crop',12,93.34,0.93,'2025-12-30 16:50:41'),(975,'crop',13,88.62,0.98,'2025-12-30 16:50:41'),(976,'crop',14,96.11,1.07,'2025-12-30 16:50:41'),(977,'crop',15,155.55,1.04,'2025-12-30 16:50:41'),(978,'crop',16,79.01,0.99,'2025-12-30 16:50:41'),(979,'crop',17,125.02,0.96,'2025-12-30 16:50:41'),(980,'crop',18,123.28,1.03,'2025-12-30 16:50:41'),(981,'crop',19,178.87,0.99,'2025-12-30 16:50:41'),(982,'crop',20,162.49,1.02,'2025-12-30 16:50:41'),(983,'crop',21,191.37,0.96,'2025-12-30 16:50:41'),(984,'crop',22,267.53,1.07,'2025-12-30 16:50:41'),(985,'crop',23,288.70,0.96,'2025-12-30 16:50:41'),(986,'crop',24,414.44,1.04,'2025-12-30 16:50:41'),(987,'crop',25,644.18,1.07,'2025-12-30 16:50:41'),(988,'crop',26,1570.97,1.05,'2025-12-30 16:50:41'),(989,'seed',1,9.80,0.98,'2025-12-30 16:55:41'),(990,'seed',2,14.71,0.98,'2025-12-30 16:55:42'),(991,'seed',3,11.76,0.98,'2025-12-30 16:55:42'),(992,'seed',4,17.41,0.97,'2025-12-30 16:55:42'),(993,'seed',5,20.37,1.02,'2025-12-30 16:55:42'),(994,'seed',6,13.88,0.99,'2025-12-30 16:55:42'),(995,'seed',7,23.92,0.96,'2025-12-30 16:55:42'),(996,'seed',8,30.41,1.01,'2025-12-30 16:55:42'),(997,'seed',9,19.76,0.99,'2025-12-30 16:55:42'),(998,'seed',10,36.66,1.05,'2025-12-30 16:55:42'),(999,'seed',11,49.32,0.99,'2025-12-30 16:55:42'),(1000,'seed',12,44.58,0.99,'2025-12-30 16:55:42'),(1001,'seed',13,39.77,0.99,'2025-12-30 16:55:42'),(1002,'seed',14,40.87,1.02,'2025-12-30 16:55:42'),(1003,'seed',15,61.79,1.03,'2025-12-30 16:55:42'),(1004,'seed',16,34.96,1.00,'2025-12-30 16:55:42'),(1005,'seed',17,57.42,1.04,'2025-12-30 16:55:42'),(1006,'seed',18,48.92,0.98,'2025-12-30 16:55:42'),(1007,'seed',19,71.27,1.02,'2025-12-30 16:55:42'),(1008,'seed',20,66.78,1.03,'2025-12-30 16:55:42'),(1009,'seed',21,79.23,0.99,'2025-12-30 16:55:42'),(1010,'seed',22,100.20,1.00,'2025-12-30 16:55:42'),(1011,'seed',23,115.37,0.96,'2025-12-30 16:55:42'),(1012,'seed',24,149.76,1.00,'2025-12-30 16:55:42'),(1013,'seed',25,191.22,0.96,'2025-12-30 16:55:42'),(1014,'seed',26,519.52,1.04,'2025-12-30 16:55:42'),(1015,'crop',1,26.22,1.05,'2025-12-30 16:55:42'),(1016,'crop',2,33.95,0.97,'2025-12-30 16:55:42'),(1017,'crop',3,26.81,0.96,'2025-12-30 16:55:42'),(1018,'crop',4,42.79,1.07,'2025-12-30 16:55:42'),(1019,'crop',5,44.62,0.99,'2025-12-30 16:55:42'),(1020,'crop',6,33.07,1.03,'2025-12-30 16:55:42'),(1021,'crop',7,56.83,0.95,'2025-12-30 16:55:42'),(1022,'crop',8,64.87,0.93,'2025-12-30 16:55:42'),(1023,'crop',9,48.10,1.07,'2025-12-30 16:55:42'),(1024,'crop',10,78.95,0.99,'2025-12-30 16:55:42'),(1025,'crop',11,118.26,0.99,'2025-12-30 16:55:42'),(1026,'crop',12,100.05,1.00,'2025-12-30 16:55:42'),(1027,'crop',13,87.63,0.97,'2025-12-30 16:55:42'),(1028,'crop',14,84.12,0.93,'2025-12-30 16:55:42'),(1029,'crop',15,147.36,0.98,'2025-12-30 16:55:42'),(1030,'crop',16,81.06,1.01,'2025-12-30 16:55:42'),(1031,'crop',17,138.39,1.06,'2025-12-30 16:55:42'),(1032,'crop',18,124.93,1.04,'2025-12-30 16:55:42'),(1033,'crop',19,168.02,0.93,'2025-12-30 16:55:42'),(1034,'crop',20,164.82,1.03,'2025-12-30 16:55:42'),(1035,'crop',21,207.59,1.04,'2025-12-30 16:55:42'),(1036,'crop',22,251.03,1.00,'2025-12-30 16:55:42'),(1037,'crop',23,279.60,0.93,'2025-12-30 16:55:42'),(1038,'crop',24,417.53,1.04,'2025-12-30 16:55:42'),(1039,'crop',25,563.03,0.94,'2025-12-30 16:55:42'),(1040,'crop',26,1506.71,1.00,'2025-12-30 16:55:42'),(1041,'seed',1,10.37,1.04,'2025-12-30 17:00:33'),(1042,'seed',2,15.24,1.02,'2025-12-30 17:00:33'),(1043,'seed',3,12.52,1.04,'2025-12-30 17:00:33'),(1044,'seed',4,17.35,0.96,'2025-12-30 17:00:33'),(1045,'seed',5,20.71,1.04,'2025-12-30 17:00:33'),(1046,'seed',6,13.96,1.00,'2025-12-30 17:00:33'),(1047,'seed',7,24.76,0.99,'2025-12-30 17:00:33'),(1048,'seed',8,28.73,0.96,'2025-12-30 17:00:33'),(1049,'seed',9,20.41,1.02,'2025-12-30 17:00:33'),(1050,'seed',10,36.03,1.03,'2025-12-30 17:00:33'),(1051,'seed',11,47.86,0.96,'2025-12-30 17:00:33'),(1052,'seed',12,45.84,1.02,'2025-12-30 17:00:33'),(1053,'seed',13,39.59,0.99,'2025-12-30 17:00:33'),(1054,'seed',14,39.11,0.98,'2025-12-30 17:00:33'),(1055,'seed',15,62.49,1.04,'2025-12-30 17:00:33'),(1056,'seed',16,33.41,0.95,'2025-12-30 17:00:33'),(1057,'seed',17,55.50,1.01,'2025-12-30 17:00:33'),(1058,'seed',18,48.27,0.97,'2025-12-30 17:00:33'),(1059,'seed',19,66.66,0.95,'2025-12-30 17:00:33'),(1060,'seed',20,68.00,1.05,'2025-12-30 17:00:33'),(1061,'seed',21,82.58,1.03,'2025-12-30 17:00:33'),(1062,'seed',22,96.73,0.97,'2025-12-30 17:00:33'),(1063,'seed',23,119.44,1.00,'2025-12-30 17:00:33'),(1064,'seed',24,145.88,0.97,'2025-12-30 17:00:33'),(1065,'seed',25,200.78,1.00,'2025-12-30 17:00:33'),(1066,'seed',26,503.23,1.01,'2025-12-30 17:00:33'),(1067,'crop',1,25.40,1.02,'2025-12-30 17:00:33'),(1068,'crop',2,35.50,1.01,'2025-12-30 17:00:33'),(1069,'crop',3,26.69,0.95,'2025-12-30 17:00:33'),(1070,'crop',4,39.26,0.98,'2025-12-30 17:00:33'),(1071,'crop',5,46.84,1.04,'2025-12-30 17:00:33'),(1072,'crop',6,33.41,1.04,'2025-12-30 17:00:33'),(1073,'crop',7,61.87,1.03,'2025-12-30 17:00:33'),(1074,'crop',8,74.14,1.06,'2025-12-30 17:00:33'),(1075,'crop',9,42.89,0.95,'2025-12-30 17:00:33'),(1076,'crop',10,81.77,1.02,'2025-12-30 17:00:33'),(1077,'crop',11,120.78,1.01,'2025-12-30 17:00:33'),(1078,'crop',12,96.90,0.97,'2025-12-30 17:00:33'),(1079,'crop',13,87.75,0.98,'2025-12-30 17:00:33'),(1080,'crop',14,83.70,0.93,'2025-12-30 17:00:33'),(1081,'crop',15,147.08,0.98,'2025-12-30 17:00:33'),(1082,'crop',16,84.78,1.06,'2025-12-30 17:00:34'),(1083,'crop',17,130.48,1.00,'2025-12-30 17:00:34'),(1084,'crop',18,118.72,0.99,'2025-12-30 17:00:34'),(1085,'crop',19,190.46,1.06,'2025-12-30 17:00:34'),(1086,'crop',20,157.29,0.98,'2025-12-30 17:00:34'),(1087,'crop',21,187.88,0.94,'2025-12-30 17:00:34'),(1088,'crop',22,255.49,1.02,'2025-12-30 17:00:34'),(1089,'crop',23,280.05,0.93,'2025-12-30 17:00:34'),(1090,'crop',24,425.37,1.06,'2025-12-30 17:00:34'),(1091,'crop',25,635.66,1.06,'2025-12-30 17:00:34'),(1092,'crop',26,1599.91,1.07,'2025-12-30 17:00:34'),(1093,'seed',1,10.29,1.03,'2025-12-30 17:05:34'),(1094,'seed',2,15.00,1.00,'2025-12-30 17:05:34'),(1095,'seed',3,12.14,1.01,'2025-12-30 17:05:34'),(1096,'seed',4,17.75,0.99,'2025-12-30 17:05:34'),(1097,'seed',5,19.02,0.95,'2025-12-30 17:05:34'),(1098,'seed',6,14.64,1.05,'2025-12-30 17:05:34'),(1099,'seed',7,24.00,0.96,'2025-12-30 17:05:34'),(1100,'seed',8,29.37,0.98,'2025-12-30 17:05:34'),(1101,'seed',9,20.26,1.01,'2025-12-30 17:05:34'),(1102,'seed',10,33.46,0.96,'2025-12-30 17:05:34'),(1103,'seed',11,52.46,1.05,'2025-12-30 17:05:34'),(1104,'seed',12,45.45,1.01,'2025-12-30 17:05:34'),(1105,'seed',13,41.60,1.04,'2025-12-30 17:05:34'),(1106,'seed',14,40.81,1.02,'2025-12-30 17:05:34'),(1107,'seed',15,57.45,0.96,'2025-12-30 17:05:34'),(1108,'seed',16,34.90,1.00,'2025-12-30 17:05:34'),(1109,'seed',17,57.12,1.04,'2025-12-30 17:05:34'),(1110,'seed',18,50.81,1.02,'2025-12-30 17:05:34'),(1111,'seed',19,68.31,0.98,'2025-12-30 17:05:34'),(1112,'seed',20,64.62,0.99,'2025-12-30 17:05:34'),(1113,'seed',21,80.33,1.00,'2025-12-30 17:05:34'),(1114,'seed',22,104.64,1.05,'2025-12-30 17:05:34'),(1115,'seed',23,114.60,0.96,'2025-12-30 17:05:34'),(1116,'seed',24,154.12,1.03,'2025-12-30 17:05:34'),(1117,'seed',25,191.46,0.96,'2025-12-30 17:05:34'),(1118,'seed',26,502.78,1.01,'2025-12-30 17:05:34'),(1119,'crop',1,23.91,0.96,'2025-12-30 17:05:34'),(1120,'crop',2,34.32,0.98,'2025-12-30 17:05:34'),(1121,'crop',3,27.71,0.99,'2025-12-30 17:05:34'),(1122,'crop',4,37.65,0.94,'2025-12-30 17:05:34'),(1123,'crop',5,43.02,0.96,'2025-12-30 17:05:34'),(1124,'crop',6,33.12,1.03,'2025-12-30 17:05:34'),(1125,'crop',7,61.28,1.02,'2025-12-30 17:05:34'),(1126,'crop',8,73.00,1.04,'2025-12-30 17:05:34'),(1127,'crop',9,46.16,1.03,'2025-12-30 17:05:34'),(1128,'crop',10,75.95,0.95,'2025-12-30 17:05:34'),(1129,'crop',11,124.03,1.03,'2025-12-30 17:05:34'),(1130,'crop',12,94.13,0.94,'2025-12-30 17:05:34'),(1131,'crop',13,91.93,1.02,'2025-12-30 17:05:34'),(1132,'crop',14,90.84,1.01,'2025-12-30 17:05:34'),(1133,'crop',15,155.94,1.04,'2025-12-30 17:05:35'),(1134,'crop',16,85.00,1.06,'2025-12-30 17:05:35'),(1135,'crop',17,123.32,0.95,'2025-12-30 17:05:35'),(1136,'crop',18,125.93,1.05,'2025-12-30 17:05:35'),(1137,'crop',19,193.05,1.07,'2025-12-30 17:05:35'),(1138,'crop',20,167.42,1.05,'2025-12-30 17:05:35'),(1139,'crop',21,193.91,0.97,'2025-12-30 17:05:35'),(1140,'crop',22,258.96,1.04,'2025-12-30 17:05:35'),(1141,'crop',23,320.84,1.07,'2025-12-30 17:05:35'),(1142,'crop',24,421.09,1.05,'2025-12-30 17:05:35'),(1143,'crop',25,591.74,0.99,'2025-12-30 17:05:35'),(1144,'crop',26,1457.98,0.97,'2025-12-30 17:05:35'),(1145,'seed',1,10.09,1.01,'2025-12-30 17:06:39'),(1146,'seed',2,14.81,0.99,'2025-12-30 17:06:39'),(1147,'seed',3,11.62,0.97,'2025-12-30 17:06:39'),(1148,'seed',4,17.10,0.95,'2025-12-30 17:06:39'),(1149,'seed',5,19.41,0.97,'2025-12-30 17:06:39'),(1150,'seed',6,13.84,0.99,'2025-12-30 17:06:39'),(1151,'seed',7,25.98,1.04,'2025-12-30 17:06:39'),(1152,'seed',8,29.59,0.99,'2025-12-30 17:06:39'),(1153,'seed',9,19.60,0.98,'2025-12-30 17:06:39'),(1154,'seed',10,33.37,0.95,'2025-12-30 17:06:39'),(1155,'seed',11,50.46,1.01,'2025-12-30 17:06:39'),(1156,'seed',12,46.31,1.03,'2025-12-30 17:06:39'),(1157,'seed',13,39.65,0.99,'2025-12-30 17:06:39'),(1158,'seed',14,38.67,0.97,'2025-12-30 17:06:39'),(1159,'seed',15,58.56,0.98,'2025-12-30 17:06:39'),(1160,'seed',16,34.89,1.00,'2025-12-30 17:06:39'),(1161,'seed',17,53.56,0.97,'2025-12-30 17:06:39'),(1162,'seed',18,51.17,1.02,'2025-12-30 17:06:39'),(1163,'seed',19,70.97,1.01,'2025-12-30 17:06:39'),(1164,'seed',20,66.88,1.03,'2025-12-30 17:06:39'),(1165,'seed',21,83.85,1.05,'2025-12-30 17:06:39'),(1166,'seed',22,96.14,0.96,'2025-12-30 17:06:39'),(1167,'seed',23,114.97,0.96,'2025-12-30 17:06:39'),(1168,'seed',24,155.04,1.03,'2025-12-30 17:06:39'),(1169,'seed',25,203.62,1.02,'2025-12-30 17:06:39'),(1170,'seed',26,495.32,0.99,'2025-12-30 17:06:39'),(1171,'crop',1,26.15,1.05,'2025-12-30 17:06:39'),(1172,'crop',2,34.05,0.97,'2025-12-30 17:06:39'),(1173,'crop',3,26.80,0.96,'2025-12-30 17:06:39'),(1174,'crop',4,37.04,0.93,'2025-12-30 17:06:40'),(1175,'crop',5,45.73,1.02,'2025-12-30 17:06:40'),(1176,'crop',6,29.79,0.93,'2025-12-30 17:06:40'),(1177,'crop',7,58.52,0.98,'2025-12-30 17:06:40'),(1178,'crop',8,64.75,0.93,'2025-12-30 17:06:40'),(1179,'crop',9,47.09,1.05,'2025-12-30 17:06:40'),(1180,'crop',10,76.42,0.96,'2025-12-30 17:06:40'),(1181,'crop',11,115.09,0.96,'2025-12-30 17:06:40'),(1182,'crop',12,98.59,0.99,'2025-12-30 17:06:40'),(1183,'crop',13,88.63,0.98,'2025-12-30 17:06:40'),(1184,'crop',14,90.90,1.01,'2025-12-30 17:06:40'),(1185,'crop',15,138.78,0.93,'2025-12-30 17:06:40'),(1186,'crop',16,76.56,0.96,'2025-12-30 17:06:40'),(1187,'crop',17,120.43,0.93,'2025-12-30 17:06:40'),(1188,'crop',18,126.22,1.05,'2025-12-30 17:06:40'),(1189,'crop',19,188.54,1.05,'2025-12-30 17:06:40'),(1190,'crop',20,150.94,0.94,'2025-12-30 17:06:40'),(1191,'crop',21,202.84,1.01,'2025-12-30 17:06:40'),(1192,'crop',22,239.98,0.96,'2025-12-30 17:06:40'),(1193,'crop',23,291.86,0.97,'2025-12-30 17:06:40'),(1194,'crop',24,393.34,0.98,'2025-12-30 17:06:40'),(1195,'crop',25,606.10,1.01,'2025-12-30 17:06:40'),(1196,'crop',26,1610.95,1.07,'2025-12-30 17:06:40'),(1197,'seed',1,10.30,1.03,'2025-12-30 17:11:40'),(1198,'seed',2,14.60,0.97,'2025-12-30 17:11:40'),(1199,'seed',3,12.55,1.05,'2025-12-30 17:11:40'),(1200,'seed',4,17.46,0.97,'2025-12-30 17:11:40'),(1201,'seed',5,20.82,1.04,'2025-12-30 17:11:40'),(1202,'seed',6,13.96,1.00,'2025-12-30 17:11:40'),(1203,'seed',7,25.46,1.02,'2025-12-30 17:11:40'),(1204,'seed',8,30.18,1.01,'2025-12-30 17:11:40'),(1205,'seed',9,20.57,1.03,'2025-12-30 17:11:40'),(1206,'seed',10,36.34,1.04,'2025-12-30 17:11:40'),(1207,'seed',11,49.30,0.99,'2025-12-30 17:11:40'),(1208,'seed',12,44.99,1.00,'2025-12-30 17:11:40'),(1209,'seed',13,39.75,0.99,'2025-12-30 17:11:40'),(1210,'seed',14,38.72,0.97,'2025-12-30 17:11:40'),(1211,'seed',15,57.02,0.95,'2025-12-30 17:11:40'),(1212,'seed',16,33.94,0.97,'2025-12-30 17:11:40'),(1213,'seed',17,53.27,0.97,'2025-12-30 17:11:40'),(1214,'seed',18,48.26,0.97,'2025-12-30 17:11:40'),(1215,'seed',19,70.84,1.01,'2025-12-30 17:11:40'),(1216,'seed',20,66.97,1.03,'2025-12-30 17:11:40'),(1217,'seed',21,79.62,1.00,'2025-12-30 17:11:40'),(1218,'seed',22,101.68,1.02,'2025-12-30 17:11:40'),(1219,'seed',23,124.26,1.04,'2025-12-30 17:11:40'),(1220,'seed',24,153.12,1.02,'2025-12-30 17:11:40'),(1221,'seed',25,205.05,1.03,'2025-12-30 17:11:40'),(1222,'seed',26,490.35,0.98,'2025-12-30 17:11:40'),(1223,'crop',1,23.42,0.94,'2025-12-30 17:11:40'),(1224,'crop',2,36.05,1.03,'2025-12-30 17:11:40'),(1225,'crop',3,26.31,0.94,'2025-12-30 17:11:40'),(1226,'crop',4,42.05,1.05,'2025-12-30 17:11:40'),(1227,'crop',5,44.54,0.99,'2025-12-30 17:11:40'),(1228,'crop',6,31.21,0.98,'2025-12-30 17:11:40'),(1229,'crop',7,62.04,1.03,'2025-12-30 17:11:40'),(1230,'crop',8,71.92,1.03,'2025-12-30 17:11:40'),(1231,'crop',9,42.31,0.94,'2025-12-30 17:11:40'),(1232,'crop',10,75.07,0.94,'2025-12-30 17:11:41'),(1233,'crop',11,118.84,0.99,'2025-12-30 17:11:41'),(1234,'crop',12,98.34,0.98,'2025-12-30 17:11:41'),(1235,'crop',13,86.92,0.97,'2025-12-30 17:11:41'),(1236,'crop',14,95.98,1.07,'2025-12-30 17:11:41'),(1237,'crop',15,153.11,1.02,'2025-12-30 17:11:41'),(1238,'crop',16,74.72,0.93,'2025-12-30 17:11:41'),(1239,'crop',17,126.17,0.97,'2025-12-30 17:11:41'),(1240,'crop',18,127.50,1.06,'2025-12-30 17:11:41'),(1241,'crop',19,186.65,1.04,'2025-12-30 17:11:41'),(1242,'crop',20,155.59,0.97,'2025-12-30 17:11:41'),(1243,'crop',21,189.47,0.95,'2025-12-30 17:11:41'),(1244,'crop',22,253.26,1.01,'2025-12-30 17:11:41'),(1245,'crop',23,283.63,0.95,'2025-12-30 17:11:41'),(1246,'crop',24,427.63,1.07,'2025-12-30 17:11:41'),(1247,'crop',25,612.25,1.02,'2025-12-30 17:11:41'),(1248,'crop',26,1466.91,0.98,'2025-12-30 17:11:41'),(1249,'seed',1,9.71,0.97,'2025-12-30 17:12:53'),(1250,'seed',2,15.20,1.01,'2025-12-30 17:12:53'),(1251,'seed',3,11.45,0.95,'2025-12-30 17:12:53'),(1252,'seed',4,18.14,1.01,'2025-12-30 17:12:53'),(1253,'seed',5,20.97,1.05,'2025-12-30 17:12:53'),(1254,'seed',6,13.48,0.96,'2025-12-30 17:12:53'),(1255,'seed',7,25.43,1.02,'2025-12-30 17:12:53'),(1256,'seed',8,31.31,1.04,'2025-12-30 17:12:53'),(1257,'seed',9,20.87,1.04,'2025-12-30 17:12:53'),(1258,'seed',10,36.32,1.04,'2025-12-30 17:12:53'),(1259,'seed',11,48.73,0.97,'2025-12-30 17:12:53'),(1260,'seed',12,44.52,0.99,'2025-12-30 17:12:53'),(1261,'seed',13,41.75,1.04,'2025-12-30 17:12:53'),(1262,'seed',14,38.24,0.96,'2025-12-30 17:12:53'),(1263,'seed',15,60.28,1.00,'2025-12-30 17:12:53'),(1264,'seed',16,35.68,1.02,'2025-12-30 17:12:53'),(1265,'seed',17,57.31,1.04,'2025-12-30 17:12:53'),(1266,'seed',18,50.49,1.01,'2025-12-30 17:12:53'),(1267,'seed',19,73.15,1.04,'2025-12-30 17:12:53'),(1268,'seed',20,64.99,1.00,'2025-12-30 17:12:53'),(1269,'seed',21,81.43,1.02,'2025-12-30 17:12:53'),(1270,'seed',22,98.06,0.98,'2025-12-30 17:12:53'),(1271,'seed',23,120.40,1.00,'2025-12-30 17:12:53'),(1272,'seed',24,148.26,0.99,'2025-12-30 17:12:53'),(1273,'seed',25,204.65,1.02,'2025-12-30 17:12:53'),(1274,'seed',26,524.76,1.05,'2025-12-30 17:12:53'),(1275,'crop',1,25.76,1.03,'2025-12-30 17:12:54'),(1276,'crop',2,35.99,1.03,'2025-12-30 17:12:54'),(1277,'crop',3,26.95,0.96,'2025-12-30 17:12:54'),(1278,'crop',4,38.29,0.96,'2025-12-30 17:12:54'),(1279,'crop',5,47.10,1.05,'2025-12-30 17:12:54'),(1280,'crop',6,32.42,1.01,'2025-12-30 17:12:54'),(1281,'crop',7,57.83,0.96,'2025-12-30 17:12:54'),(1282,'crop',8,73.96,1.06,'2025-12-30 17:12:54'),(1283,'crop',9,47.49,1.06,'2025-12-30 17:12:54'),(1284,'crop',10,79.45,0.99,'2025-12-30 17:12:54'),(1285,'crop',11,122.30,1.02,'2025-12-30 17:12:54'),(1286,'crop',12,96.04,0.96,'2025-12-30 17:12:54'),(1287,'crop',13,86.12,0.96,'2025-12-30 17:12:54'),(1288,'crop',14,92.49,1.03,'2025-12-30 17:12:54'),(1289,'crop',15,148.49,0.99,'2025-12-30 17:12:54'),(1290,'crop',16,77.86,0.97,'2025-12-30 17:12:54'),(1291,'crop',17,138.21,1.06,'2025-12-30 17:12:54'),(1292,'crop',18,113.49,0.95,'2025-12-30 17:12:54'),(1293,'crop',19,192.15,1.07,'2025-12-30 17:12:54'),(1294,'crop',20,148.13,0.93,'2025-12-30 17:12:54'),(1295,'crop',21,204.27,1.02,'2025-12-30 17:12:54'),(1296,'crop',22,246.21,0.98,'2025-12-30 17:12:54'),(1297,'crop',23,295.16,0.98,'2025-12-30 17:12:54'),(1298,'crop',24,423.36,1.06,'2025-12-30 17:12:54'),(1299,'crop',25,592.85,0.99,'2025-12-30 17:12:54'),(1300,'crop',26,1597.68,1.07,'2025-12-30 17:12:54'),(1301,'seed',1,10.20,1.02,'2025-12-30 17:17:54'),(1302,'seed',2,15.31,1.02,'2025-12-30 17:17:54'),(1303,'seed',3,11.66,0.97,'2025-12-30 17:17:54'),(1304,'seed',4,17.81,0.99,'2025-12-30 17:17:54'),(1305,'seed',5,20.97,1.05,'2025-12-30 17:17:54'),(1306,'seed',6,14.66,1.05,'2025-12-30 17:17:54'),(1307,'seed',7,23.89,0.96,'2025-12-30 17:17:54'),(1308,'seed',8,28.51,0.95,'2025-12-30 17:17:54'),(1309,'seed',9,19.63,0.98,'2025-12-30 17:17:54'),(1310,'seed',10,36.06,1.03,'2025-12-30 17:17:54'),(1311,'seed',11,48.39,0.97,'2025-12-30 17:17:54'),(1312,'seed',12,45.07,1.00,'2025-12-30 17:17:54'),(1313,'seed',13,38.22,0.96,'2025-12-30 17:17:54'),(1314,'seed',14,38.24,0.96,'2025-12-30 17:17:54'),(1315,'seed',15,61.42,1.02,'2025-12-30 17:17:54'),(1316,'seed',16,35.19,1.01,'2025-12-30 17:17:54'),(1317,'seed',17,57.35,1.04,'2025-12-30 17:17:54'),(1318,'seed',18,48.78,0.98,'2025-12-30 17:17:54'),(1319,'seed',19,68.77,0.98,'2025-12-30 17:17:54'),(1320,'seed',20,66.41,1.02,'2025-12-30 17:17:54'),(1321,'seed',21,79.45,0.99,'2025-12-30 17:17:54'),(1322,'seed',22,97.05,0.97,'2025-12-30 17:17:54'),(1323,'seed',23,121.70,1.01,'2025-12-30 17:17:54'),(1324,'seed',24,151.02,1.01,'2025-12-30 17:17:54'),(1325,'seed',25,208.30,1.04,'2025-12-30 17:17:54'),(1326,'seed',26,515.60,1.03,'2025-12-30 17:17:55'),(1327,'crop',1,26.03,1.04,'2025-12-30 17:17:55'),(1328,'crop',2,32.85,0.94,'2025-12-30 17:17:55'),(1329,'crop',3,29.99,1.07,'2025-12-30 17:17:55'),(1330,'crop',4,38.32,0.96,'2025-12-30 17:17:55'),(1331,'crop',5,48.01,1.07,'2025-12-30 17:17:55'),(1332,'crop',6,34.07,1.06,'2025-12-30 17:17:55'),(1333,'crop',7,63.94,1.07,'2025-12-30 17:17:55'),(1334,'crop',8,67.40,0.96,'2025-12-30 17:17:55'),(1335,'crop',9,42.47,0.94,'2025-12-30 17:17:55'),(1336,'crop',10,78.27,0.98,'2025-12-30 17:17:55'),(1337,'crop',11,128.48,1.07,'2025-12-30 17:17:55'),(1338,'crop',12,98.03,0.98,'2025-12-30 17:17:55'),(1339,'crop',13,86.42,0.96,'2025-12-30 17:17:55'),(1340,'crop',14,83.83,0.93,'2025-12-30 17:17:55'),(1341,'crop',15,139.42,0.93,'2025-12-30 17:17:55'),(1342,'crop',16,74.78,0.93,'2025-12-30 17:17:55'),(1343,'crop',17,132.78,1.02,'2025-12-30 17:17:55'),(1344,'crop',18,116.66,0.97,'2025-12-30 17:17:55'),(1345,'crop',19,174.92,0.97,'2025-12-30 17:17:55'),(1346,'crop',20,171.65,1.07,'2025-12-30 17:17:55'),(1347,'crop',21,205.86,1.03,'2025-12-30 17:17:55'),(1348,'crop',22,243.73,0.97,'2025-12-30 17:17:55'),(1349,'crop',23,307.19,1.02,'2025-12-30 17:17:55'),(1350,'crop',24,376.38,0.94,'2025-12-30 17:17:55'),(1351,'crop',25,615.30,1.03,'2025-12-30 17:17:55'),(1352,'crop',26,1566.97,1.04,'2025-12-30 17:17:55'),(1353,'seed',1,10.46,1.05,'2025-12-30 17:19:45'),(1354,'seed',2,14.30,0.95,'2025-12-30 17:19:45'),(1355,'seed',3,11.97,1.00,'2025-12-30 17:19:45'),(1356,'seed',4,17.82,0.99,'2025-12-30 17:19:45'),(1357,'seed',5,20.56,1.03,'2025-12-30 17:19:45'),(1358,'seed',6,14.28,1.02,'2025-12-30 17:19:45'),(1359,'seed',7,24.04,0.96,'2025-12-30 17:19:45'),(1360,'seed',8,30.64,1.02,'2025-12-30 17:19:45'),(1361,'seed',9,20.94,1.05,'2025-12-30 17:19:45'),(1362,'seed',10,36.07,1.03,'2025-12-30 17:19:45'),(1363,'seed',11,49.49,0.99,'2025-12-30 17:19:45'),(1364,'seed',12,45.37,1.01,'2025-12-30 17:19:45'),(1365,'seed',13,40.32,1.01,'2025-12-30 17:19:45'),(1366,'seed',14,40.52,1.01,'2025-12-30 17:19:45'),(1367,'seed',15,58.40,0.97,'2025-12-30 17:19:45'),(1368,'seed',16,34.93,1.00,'2025-12-30 17:19:45'),(1369,'seed',17,53.79,0.98,'2025-12-30 17:19:45'),(1370,'seed',18,50.03,1.00,'2025-12-30 17:19:45'),(1371,'seed',19,73.26,1.05,'2025-12-30 17:19:45'),(1372,'seed',20,63.92,0.98,'2025-12-30 17:19:45'),(1373,'seed',21,82.53,1.03,'2025-12-30 17:19:45'),(1374,'seed',22,102.40,1.02,'2025-12-30 17:19:45'),(1375,'seed',23,122.54,1.02,'2025-12-30 17:19:45'),(1376,'seed',24,142.54,0.95,'2025-12-30 17:19:45'),(1377,'seed',25,198.97,0.99,'2025-12-30 17:19:45'),(1378,'seed',26,493.40,0.99,'2025-12-30 17:19:45'),(1379,'crop',1,23.40,0.94,'2025-12-30 17:19:45'),(1380,'crop',2,36.04,1.03,'2025-12-30 17:19:45'),(1381,'crop',3,27.72,0.99,'2025-12-30 17:19:45'),(1382,'crop',4,42.77,1.07,'2025-12-30 17:19:45'),(1383,'crop',5,43.40,0.96,'2025-12-30 17:19:45'),(1384,'crop',6,30.19,0.94,'2025-12-30 17:19:45'),(1385,'crop',7,60.90,1.01,'2025-12-30 17:19:45'),(1386,'crop',8,74.34,1.06,'2025-12-30 17:19:45'),(1387,'crop',9,47.23,1.05,'2025-12-30 17:19:45'),(1388,'crop',10,79.74,1.00,'2025-12-30 17:19:45'),(1389,'crop',11,123.43,1.03,'2025-12-30 17:19:45'),(1390,'crop',12,102.65,1.03,'2025-12-30 17:19:45'),(1391,'crop',13,94.10,1.05,'2025-12-30 17:19:45'),(1392,'crop',14,94.16,1.05,'2025-12-30 17:19:45'),(1393,'crop',15,143.14,0.95,'2025-12-30 17:19:45'),(1394,'crop',16,77.07,0.96,'2025-12-30 17:19:45'),(1395,'crop',17,132.31,1.02,'2025-12-30 17:19:45'),(1396,'crop',18,126.78,1.06,'2025-12-30 17:19:45'),(1397,'crop',19,170.59,0.95,'2025-12-30 17:19:45'),(1398,'crop',20,166.09,1.04,'2025-12-30 17:19:45'),(1399,'crop',21,195.31,0.98,'2025-12-30 17:19:45'),(1400,'crop',22,232.06,0.93,'2025-12-30 17:19:45'),(1401,'crop',23,316.44,1.05,'2025-12-30 17:19:45'),(1402,'crop',24,419.83,1.05,'2025-12-30 17:19:45'),(1403,'crop',25,573.76,0.96,'2025-12-30 17:19:45'),(1404,'crop',26,1502.77,1.00,'2025-12-30 17:19:45'),(1405,'seed',1,9.72,0.97,'2025-12-30 17:24:46'),(1406,'seed',2,15.40,1.03,'2025-12-30 17:24:46'),(1407,'seed',3,11.84,0.99,'2025-12-30 17:24:46'),(1408,'seed',4,18.62,1.03,'2025-12-30 17:24:46'),(1409,'seed',5,20.97,1.05,'2025-12-30 17:24:46'),(1410,'seed',6,14.15,1.01,'2025-12-30 17:24:46'),(1411,'seed',7,26.12,1.04,'2025-12-30 17:24:46'),(1412,'seed',8,29.64,0.99,'2025-12-30 17:24:46'),(1413,'seed',9,19.15,0.96,'2025-12-30 17:24:46'),(1414,'seed',10,34.71,0.99,'2025-12-30 17:24:46'),(1415,'seed',11,49.12,0.98,'2025-12-30 17:24:46'),(1416,'seed',12,45.42,1.01,'2025-12-30 17:24:46'),(1417,'seed',13,38.71,0.97,'2025-12-30 17:24:46'),(1418,'seed',14,39.07,0.98,'2025-12-30 17:24:46'),(1419,'seed',15,60.96,1.02,'2025-12-30 17:24:46'),(1420,'seed',16,34.42,0.98,'2025-12-30 17:24:46'),(1421,'seed',17,52.60,0.96,'2025-12-30 17:24:46'),(1422,'seed',18,49.06,0.98,'2025-12-30 17:24:46'),(1423,'seed',19,69.91,1.00,'2025-12-30 17:24:46'),(1424,'seed',20,68.01,1.05,'2025-12-30 17:24:46'),(1425,'seed',21,81.91,1.02,'2025-12-30 17:24:46'),(1426,'seed',22,103.40,1.03,'2025-12-30 17:24:46'),(1427,'seed',23,116.27,0.97,'2025-12-30 17:24:46'),(1428,'seed',24,155.71,1.04,'2025-12-30 17:24:46'),(1429,'seed',25,192.95,0.96,'2025-12-30 17:24:46'),(1430,'seed',26,481.60,0.96,'2025-12-30 17:24:46'),(1431,'crop',1,26.36,1.05,'2025-12-30 17:24:46'),(1432,'crop',2,32.50,0.93,'2025-12-30 17:24:46'),(1433,'crop',3,26.24,0.94,'2025-12-30 17:24:46'),(1434,'crop',4,41.50,1.04,'2025-12-30 17:24:46'),(1435,'crop',5,42.09,0.94,'2025-12-30 17:24:46'),(1436,'crop',6,33.39,1.04,'2025-12-30 17:24:46'),(1437,'crop',7,63.86,1.06,'2025-12-30 17:24:46'),(1438,'crop',8,72.71,1.04,'2025-12-30 17:24:46'),(1439,'crop',9,45.45,1.01,'2025-12-30 17:24:46'),(1440,'crop',10,74.21,0.93,'2025-12-30 17:24:46'),(1441,'crop',11,122.06,1.02,'2025-12-30 17:24:46'),(1442,'crop',12,95.66,0.96,'2025-12-30 17:24:46'),(1443,'crop',13,94.10,1.05,'2025-12-30 17:24:46'),(1444,'crop',14,90.58,1.01,'2025-12-30 17:24:46'),(1445,'crop',15,150.04,1.00,'2025-12-30 17:24:46'),(1446,'crop',16,80.96,1.01,'2025-12-30 17:24:46'),(1447,'crop',17,132.61,1.02,'2025-12-30 17:24:46'),(1448,'crop',18,112.98,0.94,'2025-12-30 17:24:46'),(1449,'crop',19,184.38,1.02,'2025-12-30 17:24:46'),(1450,'crop',20,163.09,1.02,'2025-12-30 17:24:46'),(1451,'crop',21,209.23,1.05,'2025-12-30 17:24:46'),(1452,'crop',22,260.42,1.04,'2025-12-30 17:24:46'),(1453,'crop',23,296.22,0.99,'2025-12-30 17:24:46'),(1454,'crop',24,388.01,0.97,'2025-12-30 17:24:46'),(1455,'crop',25,602.64,1.00,'2025-12-30 17:24:46'),(1456,'crop',26,1451.82,0.97,'2025-12-30 17:24:46'),(1457,'seed',1,10.33,1.03,'2025-12-30 17:29:47'),(1458,'seed',2,15.67,1.04,'2025-12-30 17:29:47'),(1459,'seed',3,12.53,1.04,'2025-12-30 17:29:47'),(1460,'seed',4,17.81,0.99,'2025-12-30 17:29:47'),(1461,'seed',5,20.17,1.01,'2025-12-30 17:29:47'),(1462,'seed',6,14.38,1.03,'2025-12-30 17:29:47'),(1463,'seed',7,25.56,1.02,'2025-12-30 17:29:47'),(1464,'seed',8,28.62,0.95,'2025-12-30 17:29:47'),(1465,'seed',9,19.81,0.99,'2025-12-30 17:29:47'),(1466,'seed',10,33.99,0.97,'2025-12-30 17:29:47'),(1467,'seed',11,48.71,0.97,'2025-12-30 17:29:47'),(1468,'seed',12,44.82,1.00,'2025-12-30 17:29:47'),(1469,'seed',13,39.99,1.00,'2025-12-30 17:29:47'),(1470,'seed',14,41.25,1.03,'2025-12-30 17:29:47'),(1471,'seed',15,57.31,0.96,'2025-12-30 17:29:47'),(1472,'seed',16,34.79,0.99,'2025-12-30 17:29:47'),(1473,'seed',17,52.89,0.96,'2025-12-30 17:29:47'),(1474,'seed',18,49.10,0.98,'2025-12-30 17:29:47'),(1475,'seed',19,72.85,1.04,'2025-12-30 17:29:47'),(1476,'seed',20,66.19,1.02,'2025-12-30 17:29:47'),(1477,'seed',21,79.84,1.00,'2025-12-30 17:29:47'),(1478,'seed',22,95.60,0.96,'2025-12-30 17:29:47'),(1479,'seed',23,122.56,1.02,'2025-12-30 17:29:47'),(1480,'seed',24,153.66,1.02,'2025-12-30 17:29:47'),(1481,'seed',25,194.43,0.97,'2025-12-30 17:29:47'),(1482,'seed',26,488.25,0.98,'2025-12-30 17:29:47'),(1483,'crop',1,24.40,0.98,'2025-12-30 17:29:47'),(1484,'crop',2,32.60,0.93,'2025-12-30 17:29:47'),(1485,'crop',3,26.56,0.95,'2025-12-30 17:29:47'),(1486,'crop',4,40.56,1.01,'2025-12-30 17:29:47'),(1487,'crop',5,43.95,0.98,'2025-12-30 17:29:47'),(1488,'crop',6,30.58,0.96,'2025-12-30 17:29:47'),(1489,'crop',7,58.52,0.98,'2025-12-30 17:29:47'),(1490,'crop',8,74.28,1.06,'2025-12-30 17:29:47'),(1491,'crop',9,44.46,0.99,'2025-12-30 17:29:47'),(1492,'crop',10,82.06,1.03,'2025-12-30 17:29:47'),(1493,'crop',11,122.52,1.02,'2025-12-30 17:29:47'),(1494,'crop',12,96.09,0.96,'2025-12-30 17:29:47'),(1495,'crop',13,89.44,0.99,'2025-12-30 17:29:47'),(1496,'crop',14,90.57,1.01,'2025-12-30 17:29:47'),(1497,'crop',15,143.52,0.96,'2025-12-30 17:29:47'),(1498,'crop',16,79.00,0.99,'2025-12-30 17:29:47'),(1499,'crop',17,127.91,0.98,'2025-12-30 17:29:47'),(1500,'crop',18,112.59,0.94,'2025-12-30 17:29:47'),(1501,'crop',19,176.70,0.98,'2025-12-30 17:29:47'),(1502,'crop',20,171.16,1.07,'2025-12-30 17:29:47'),(1503,'crop',21,211.84,1.06,'2025-12-30 17:29:47'),(1504,'crop',22,258.12,1.03,'2025-12-30 17:29:47'),(1505,'crop',23,310.18,1.03,'2025-12-30 17:29:47'),(1506,'crop',24,389.78,0.97,'2025-12-30 17:29:47'),(1507,'crop',25,589.24,0.98,'2025-12-30 17:29:47'),(1508,'crop',26,1411.42,0.94,'2025-12-30 17:29:47'),(1509,'seed',1,9.64,0.96,'2025-12-30 17:33:00'),(1510,'seed',2,14.42,0.96,'2025-12-30 17:33:01'),(1511,'seed',3,11.74,0.98,'2025-12-30 17:33:01'),(1512,'seed',4,17.31,0.96,'2025-12-30 17:33:01'),(1513,'seed',5,20.74,1.04,'2025-12-30 17:33:01'),(1514,'seed',6,13.30,0.95,'2025-12-30 17:33:01'),(1515,'seed',7,25.50,1.02,'2025-12-30 17:33:01'),(1516,'seed',8,30.55,1.02,'2025-12-30 17:33:01'),(1517,'seed',9,19.83,0.99,'2025-12-30 17:33:01'),(1518,'seed',10,35.89,1.03,'2025-12-30 17:33:01'),(1519,'seed',11,47.79,0.96,'2025-12-30 17:33:01'),(1520,'seed',12,45.96,1.02,'2025-12-30 17:33:01'),(1521,'seed',13,40.24,1.01,'2025-12-30 17:33:01'),(1522,'seed',14,41.95,1.05,'2025-12-30 17:33:01'),(1523,'seed',15,61.91,1.03,'2025-12-30 17:33:01'),(1524,'seed',16,33.90,0.97,'2025-12-30 17:33:01'),(1525,'seed',17,53.74,0.98,'2025-12-30 17:33:01'),(1526,'seed',18,50.75,1.01,'2025-12-30 17:33:01'),(1527,'seed',19,67.04,0.96,'2025-12-30 17:33:01'),(1528,'seed',20,64.30,0.99,'2025-12-30 17:33:01'),(1529,'seed',21,82.14,1.03,'2025-12-30 17:33:01'),(1530,'seed',22,100.00,1.00,'2025-12-30 17:33:01'),(1531,'seed',23,115.59,0.96,'2025-12-30 17:33:01'),(1532,'seed',24,144.04,0.96,'2025-12-30 17:33:01'),(1533,'seed',25,202.85,1.01,'2025-12-30 17:33:01'),(1534,'seed',26,494.21,0.99,'2025-12-30 17:33:01'),(1535,'crop',1,23.81,0.95,'2025-12-30 17:33:01'),(1536,'crop',2,34.85,1.00,'2025-12-30 17:33:01'),(1537,'crop',3,29.01,1.04,'2025-12-30 17:33:01'),(1538,'crop',4,37.26,0.93,'2025-12-30 17:33:01'),(1539,'crop',5,43.04,0.96,'2025-12-30 17:33:01'),(1540,'crop',6,30.91,0.97,'2025-12-30 17:33:01'),(1541,'crop',7,60.79,1.01,'2025-12-30 17:33:01'),(1542,'crop',8,65.68,0.94,'2025-12-30 17:33:01'),(1543,'crop',9,45.19,1.00,'2025-12-30 17:33:01'),(1544,'crop',10,84.26,1.05,'2025-12-30 17:33:01'),(1545,'crop',11,117.13,0.98,'2025-12-30 17:33:01'),(1546,'crop',12,104.76,1.05,'2025-12-30 17:33:01'),(1547,'crop',13,87.93,0.98,'2025-12-30 17:33:01'),(1548,'crop',14,93.98,1.04,'2025-12-30 17:33:01'),(1549,'crop',15,160.67,1.07,'2025-12-30 17:33:01'),(1550,'crop',16,81.27,1.02,'2025-12-30 17:33:01'),(1551,'crop',17,133.29,1.03,'2025-12-30 17:33:01'),(1552,'crop',18,120.00,1.00,'2025-12-30 17:33:01'),(1553,'crop',19,187.47,1.04,'2025-12-30 17:33:01'),(1554,'crop',20,153.35,0.96,'2025-12-30 17:33:01'),(1555,'crop',21,208.43,1.04,'2025-12-30 17:33:01'),(1556,'crop',22,239.54,0.96,'2025-12-30 17:33:01'),(1557,'crop',23,295.66,0.99,'2025-12-30 17:33:01'),(1558,'crop',24,416.73,1.04,'2025-12-30 17:33:01'),(1559,'crop',25,588.63,0.98,'2025-12-30 17:33:01'),(1560,'crop',26,1453.69,0.97,'2025-12-30 17:33:01'),(1561,'seed',1,10.02,1.00,'2025-12-30 17:35:11'),(1562,'seed',2,14.30,0.95,'2025-12-30 17:35:11'),(1563,'seed',3,12.26,1.02,'2025-12-30 17:35:11'),(1564,'seed',4,17.69,0.98,'2025-12-30 17:35:11'),(1565,'seed',5,20.64,1.03,'2025-12-30 17:35:11'),(1566,'seed',6,14.36,1.03,'2025-12-30 17:35:11'),(1567,'seed',7,25.33,1.01,'2025-12-30 17:35:11'),(1568,'seed',8,30.78,1.03,'2025-12-30 17:35:11'),(1569,'seed',9,19.36,0.97,'2025-12-30 17:35:11'),(1570,'seed',10,33.29,0.95,'2025-12-30 17:35:11'),(1571,'seed',11,47.53,0.95,'2025-12-30 17:35:11'),(1572,'seed',12,44.09,0.98,'2025-12-30 17:35:11'),(1573,'seed',13,41.11,1.03,'2025-12-30 17:35:11'),(1574,'seed',14,39.43,0.99,'2025-12-30 17:35:11'),(1575,'seed',15,57.29,0.95,'2025-12-30 17:35:11'),(1576,'seed',16,35.97,1.03,'2025-12-30 17:35:11'),(1577,'seed',17,55.74,1.01,'2025-12-30 17:35:11'),(1578,'seed',18,48.46,0.97,'2025-12-30 17:35:11'),(1579,'seed',19,68.53,0.98,'2025-12-30 17:35:11'),(1580,'seed',20,67.19,1.03,'2025-12-30 17:35:11'),(1581,'seed',21,81.02,1.01,'2025-12-30 17:35:11'),(1582,'seed',22,99.53,1.00,'2025-12-30 17:35:11'),(1583,'seed',23,114.89,0.96,'2025-12-30 17:35:11'),(1584,'seed',24,155.93,1.04,'2025-12-30 17:35:11'),(1585,'seed',25,207.47,1.04,'2025-12-30 17:35:11'),(1586,'seed',26,519.19,1.04,'2025-12-30 17:35:11'),(1587,'crop',1,23.58,0.94,'2025-12-30 17:35:11'),(1588,'crop',2,33.98,0.97,'2025-12-30 17:35:11'),(1589,'crop',3,26.12,0.93,'2025-12-30 17:35:11'),(1590,'crop',4,40.76,1.02,'2025-12-30 17:35:11'),(1591,'crop',5,43.43,0.97,'2025-12-30 17:35:11'),(1592,'crop',6,34.07,1.06,'2025-12-30 17:35:11'),(1593,'crop',7,62.16,1.04,'2025-12-30 17:35:11'),(1594,'crop',8,72.62,1.04,'2025-12-30 17:35:11'),(1595,'crop',9,43.55,0.97,'2025-12-30 17:35:11'),(1596,'crop',10,82.29,1.03,'2025-12-30 17:35:11'),(1597,'crop',11,126.28,1.05,'2025-12-30 17:35:11'),(1598,'crop',12,93.12,0.93,'2025-12-30 17:35:11'),(1599,'crop',13,83.30,0.93,'2025-12-30 17:35:11'),(1600,'crop',14,89.84,1.00,'2025-12-30 17:35:11'),(1601,'crop',15,156.37,1.04,'2025-12-30 17:35:11'),(1602,'crop',16,82.36,1.03,'2025-12-30 17:35:11'),(1603,'crop',17,129.48,1.00,'2025-12-30 17:35:11'),(1604,'crop',18,119.42,1.00,'2025-12-30 17:35:11'),(1605,'crop',19,179.42,1.00,'2025-12-30 17:35:11'),(1606,'crop',20,162.43,1.02,'2025-12-30 17:35:11'),(1607,'crop',21,186.96,0.93,'2025-12-30 17:35:11'),(1608,'crop',22,243.67,0.97,'2025-12-30 17:35:11'),(1609,'crop',23,314.22,1.05,'2025-12-30 17:35:11'),(1610,'crop',24,377.03,0.94,'2025-12-30 17:35:11'),(1611,'crop',25,557.52,0.93,'2025-12-30 17:35:11'),(1612,'crop',26,1550.72,1.03,'2025-12-30 17:35:11'),(1613,'seed',1,10.16,1.02,'2025-12-30 17:40:12'),(1614,'seed',2,14.35,0.96,'2025-12-30 17:40:12'),(1615,'seed',3,11.53,0.96,'2025-12-30 17:40:12'),(1616,'seed',4,18.23,1.01,'2025-12-30 17:40:12'),(1617,'seed',5,20.07,1.00,'2025-12-30 17:40:12'),(1618,'seed',6,14.34,1.02,'2025-12-30 17:40:12'),(1619,'seed',7,24.62,0.98,'2025-12-30 17:40:12'),(1620,'seed',8,30.18,1.01,'2025-12-30 17:40:12'),(1621,'seed',9,19.49,0.97,'2025-12-30 17:40:12'),(1622,'seed',10,34.53,0.99,'2025-12-30 17:40:12'),(1623,'seed',11,47.63,0.95,'2025-12-30 17:40:12'),(1624,'seed',12,44.12,0.98,'2025-12-30 17:40:12'),(1625,'seed',13,39.30,0.98,'2025-12-30 17:40:12'),(1626,'seed',14,40.44,1.01,'2025-12-30 17:40:12'),(1627,'seed',15,58.83,0.98,'2025-12-30 17:40:12'),(1628,'seed',16,33.71,0.96,'2025-12-30 17:40:12'),(1629,'seed',17,57.04,1.04,'2025-12-30 17:40:12'),(1630,'seed',18,50.63,1.01,'2025-12-30 17:40:12'),(1631,'seed',19,71.75,1.02,'2025-12-30 17:40:12'),(1632,'seed',20,67.60,1.04,'2025-12-30 17:40:12'),(1633,'seed',21,80.27,1.00,'2025-12-30 17:40:12'),(1634,'seed',22,96.63,0.97,'2025-12-30 17:40:12'),(1635,'seed',23,115.89,0.97,'2025-12-30 17:40:12'),(1636,'seed',24,149.00,0.99,'2025-12-30 17:40:12'),(1637,'seed',25,203.03,1.02,'2025-12-30 17:40:12'),(1638,'seed',26,480.92,0.96,'2025-12-30 17:40:12'),(1639,'crop',1,23.85,0.95,'2025-12-30 17:40:12'),(1640,'crop',2,32.83,0.94,'2025-12-30 17:40:12'),(1641,'crop',3,29.03,1.04,'2025-12-30 17:40:12'),(1642,'crop',4,38.67,0.97,'2025-12-30 17:40:12'),(1643,'crop',5,41.65,0.93,'2025-12-30 17:40:12'),(1644,'crop',6,31.92,1.00,'2025-12-30 17:40:12'),(1645,'crop',7,59.43,0.99,'2025-12-30 17:40:12'),(1646,'crop',8,65.50,0.94,'2025-12-30 17:40:12'),(1647,'crop',9,43.94,0.98,'2025-12-30 17:40:12'),(1648,'crop',10,76.18,0.95,'2025-12-30 17:40:12'),(1649,'crop',11,127.01,1.06,'2025-12-30 17:40:12'),(1650,'crop',12,104.10,1.04,'2025-12-30 17:40:12'),(1651,'crop',13,90.26,1.00,'2025-12-30 17:40:12'),(1652,'crop',14,84.85,0.94,'2025-12-30 17:40:12'),(1653,'crop',15,142.71,0.95,'2025-12-30 17:40:12'),(1654,'crop',16,85.98,1.07,'2025-12-30 17:40:12'),(1655,'crop',17,130.46,1.00,'2025-12-30 17:40:12'),(1656,'crop',18,116.15,0.97,'2025-12-30 17:40:12'),(1657,'crop',19,171.05,0.95,'2025-12-30 17:40:12'),(1658,'crop',20,153.14,0.96,'2025-12-30 17:40:12'),(1659,'crop',21,206.20,1.03,'2025-12-30 17:40:12'),(1660,'crop',22,235.92,0.94,'2025-12-30 17:40:12'),(1661,'crop',23,308.15,1.03,'2025-12-30 17:40:12'),(1662,'crop',24,373.30,0.93,'2025-12-30 17:40:12'),(1663,'crop',25,572.95,0.95,'2025-12-30 17:40:12'),(1664,'crop',26,1483.83,0.99,'2025-12-30 17:40:12'),(1665,'seed',1,9.53,0.95,'2025-12-30 17:45:13'),(1666,'seed',2,14.89,0.99,'2025-12-30 17:45:13'),(1667,'seed',3,11.72,0.98,'2025-12-30 17:45:13'),(1668,'seed',4,17.70,0.98,'2025-12-30 17:45:13'),(1669,'seed',5,19.89,0.99,'2025-12-30 17:45:13'),(1670,'seed',6,13.72,0.98,'2025-12-30 17:45:13'),(1671,'seed',7,24.22,0.97,'2025-12-30 17:45:13'),(1672,'seed',8,28.75,0.96,'2025-12-30 17:45:13'),(1673,'seed',9,19.73,0.99,'2025-12-30 17:45:13'),(1674,'seed',10,33.62,0.96,'2025-12-30 17:45:13'),(1675,'seed',11,48.83,0.98,'2025-12-30 17:45:13'),(1676,'seed',12,43.59,0.97,'2025-12-30 17:45:13'),(1677,'seed',13,39.77,0.99,'2025-12-30 17:45:13'),(1678,'seed',14,40.08,1.00,'2025-12-30 17:45:13'),(1679,'seed',15,59.64,0.99,'2025-12-30 17:45:13'),(1680,'seed',16,34.64,0.99,'2025-12-30 17:45:13'),(1681,'seed',17,56.14,1.02,'2025-12-30 17:45:13'),(1682,'seed',18,52.44,1.05,'2025-12-30 17:45:13'),(1683,'seed',19,72.15,1.03,'2025-12-30 17:45:13'),(1684,'seed',20,66.64,1.03,'2025-12-30 17:45:13'),(1685,'seed',21,78.10,0.98,'2025-12-30 17:45:13'),(1686,'seed',22,96.58,0.97,'2025-12-30 17:45:13'),(1687,'seed',23,123.56,1.03,'2025-12-30 17:45:13'),(1688,'seed',24,146.74,0.98,'2025-12-30 17:45:13'),(1689,'seed',25,192.15,0.96,'2025-12-30 17:45:13'),(1690,'seed',26,481.67,0.96,'2025-12-30 17:45:13'),(1691,'crop',1,26.07,1.04,'2025-12-30 17:45:13'),(1692,'crop',2,34.11,0.97,'2025-12-30 17:45:13'),(1693,'crop',3,26.90,0.96,'2025-12-30 17:45:13'),(1694,'crop',4,38.12,0.95,'2025-12-30 17:45:13'),(1695,'crop',5,46.75,1.04,'2025-12-30 17:45:13'),(1696,'crop',6,33.52,1.05,'2025-12-30 17:45:13'),(1697,'crop',7,62.28,1.04,'2025-12-30 17:45:13'),(1698,'crop',8,71.26,1.02,'2025-12-30 17:45:13'),(1699,'crop',9,41.99,0.93,'2025-12-30 17:45:13'),(1700,'crop',10,83.66,1.05,'2025-12-30 17:45:13'),(1701,'crop',11,115.76,0.96,'2025-12-30 17:45:13'),(1702,'crop',12,98.61,0.99,'2025-12-30 17:45:13'),(1703,'crop',13,91.52,1.02,'2025-12-30 17:45:13'),(1704,'crop',14,90.23,1.00,'2025-12-30 17:45:13'),(1705,'crop',15,149.58,1.00,'2025-12-30 17:45:13'),(1706,'crop',16,80.22,1.00,'2025-12-30 17:45:13'),(1707,'crop',17,120.52,0.93,'2025-12-30 17:45:13'),(1708,'crop',18,114.60,0.95,'2025-12-30 17:45:13'),(1709,'crop',19,185.52,1.03,'2025-12-30 17:45:13'),(1710,'crop',20,171.62,1.07,'2025-12-30 17:45:13'),(1711,'crop',21,204.03,1.02,'2025-12-30 17:45:13'),(1712,'crop',22,254.80,1.02,'2025-12-30 17:45:13'),(1713,'crop',23,291.36,0.97,'2025-12-30 17:45:13'),(1714,'crop',24,425.10,1.06,'2025-12-30 17:45:13'),(1715,'crop',25,634.58,1.06,'2025-12-30 17:45:13'),(1716,'crop',26,1491.66,0.99,'2025-12-30 17:45:13'),(1717,'seed',1,9.63,0.96,'2025-12-30 17:50:07'),(1718,'seed',2,15.52,1.03,'2025-12-30 17:50:07'),(1719,'seed',3,12.36,1.03,'2025-12-30 17:50:07'),(1720,'seed',4,17.20,0.96,'2025-12-30 17:50:07'),(1721,'seed',5,20.07,1.00,'2025-12-30 17:50:07'),(1722,'seed',6,14.63,1.04,'2025-12-30 17:50:07'),(1723,'seed',7,24.17,0.97,'2025-12-30 17:50:07'),(1724,'seed',8,30.47,1.02,'2025-12-30 17:50:07'),(1725,'seed',9,20.79,1.04,'2025-12-30 17:50:07'),(1726,'seed',10,36.08,1.03,'2025-12-30 17:50:07'),(1727,'seed',11,51.47,1.03,'2025-12-30 17:50:07'),(1728,'seed',12,43.03,0.96,'2025-12-30 17:50:07'),(1729,'seed',13,38.59,0.96,'2025-12-30 17:50:07'),(1730,'seed',14,41.44,1.04,'2025-12-30 17:50:07'),(1731,'seed',15,60.84,1.01,'2025-12-30 17:50:07'),(1732,'seed',16,36.07,1.03,'2025-12-30 17:50:07'),(1733,'seed',17,57.32,1.04,'2025-12-30 17:50:07'),(1734,'seed',18,52.31,1.05,'2025-12-30 17:50:08'),(1735,'seed',19,68.62,0.98,'2025-12-30 17:50:08'),(1736,'seed',20,65.29,1.00,'2025-12-30 17:50:08'),(1737,'seed',21,78.06,0.98,'2025-12-30 17:50:08'),(1738,'seed',22,97.10,0.97,'2025-12-30 17:50:08'),(1739,'seed',23,116.29,0.97,'2025-12-30 17:50:08'),(1740,'seed',24,143.31,0.96,'2025-12-30 17:50:08'),(1741,'seed',25,197.25,0.99,'2025-12-30 17:50:08'),(1742,'seed',26,476.17,0.95,'2025-12-30 17:50:08'),(1743,'crop',1,26.68,1.07,'2025-12-30 17:50:08'),(1744,'crop',2,35.95,1.03,'2025-12-30 17:50:08'),(1745,'crop',3,29.13,1.04,'2025-12-30 17:50:08'),(1746,'crop',4,37.65,0.94,'2025-12-30 17:50:08'),(1747,'crop',5,45.80,1.02,'2025-12-30 17:50:08'),(1748,'crop',6,32.73,1.02,'2025-12-30 17:50:08'),(1749,'crop',7,60.49,1.01,'2025-12-30 17:50:08'),(1750,'crop',8,72.69,1.04,'2025-12-30 17:50:08'),(1751,'crop',9,42.08,0.94,'2025-12-30 17:50:08'),(1752,'crop',10,79.31,0.99,'2025-12-30 17:50:08'),(1753,'crop',11,113.75,0.95,'2025-12-30 17:50:08'),(1754,'crop',12,95.13,0.95,'2025-12-30 17:50:08'),(1755,'crop',13,89.18,0.99,'2025-12-30 17:50:08'),(1756,'crop',14,93.73,1.04,'2025-12-30 17:50:08'),(1757,'crop',15,140.37,0.94,'2025-12-30 17:50:08'),(1758,'crop',16,81.63,1.02,'2025-12-30 17:50:08'),(1759,'crop',17,137.99,1.06,'2025-12-30 17:50:08'),(1760,'crop',18,113.11,0.94,'2025-12-30 17:50:08'),(1761,'crop',19,178.24,0.99,'2025-12-30 17:50:08'),(1762,'crop',20,158.85,0.99,'2025-12-30 17:50:08'),(1763,'crop',21,202.91,1.01,'2025-12-30 17:50:08'),(1764,'crop',22,235.75,0.94,'2025-12-30 17:50:08'),(1765,'crop',23,309.12,1.03,'2025-12-30 17:50:08'),(1766,'crop',24,382.27,0.96,'2025-12-30 17:50:08'),(1767,'crop',25,608.27,1.01,'2025-12-30 17:50:08'),(1768,'crop',26,1565.78,1.04,'2025-12-30 17:50:08'),(1769,'seed',1,10.48,1.05,'2025-12-30 17:51:37'),(1770,'seed',2,15.55,1.04,'2025-12-30 17:51:37'),(1771,'seed',3,12.37,1.03,'2025-12-30 17:51:37'),(1772,'seed',4,17.80,0.99,'2025-12-30 17:51:37'),(1773,'seed',5,19.15,0.96,'2025-12-30 17:51:37'),(1774,'seed',6,14.23,1.02,'2025-12-30 17:51:37'),(1775,'seed',7,25.84,1.03,'2025-12-30 17:51:37'),(1776,'seed',8,30.07,1.00,'2025-12-30 17:51:37'),(1777,'seed',9,20.47,1.02,'2025-12-30 17:51:37'),(1778,'seed',10,33.35,0.95,'2025-12-30 17:51:37'),(1779,'seed',11,49.72,0.99,'2025-12-30 17:51:37'),(1780,'seed',12,43.80,0.97,'2025-12-30 17:51:37'),(1781,'seed',13,41.62,1.04,'2025-12-30 17:51:37'),(1782,'seed',14,39.50,0.99,'2025-12-30 17:51:37'),(1783,'seed',15,62.63,1.04,'2025-12-30 17:51:37'),(1784,'seed',16,36.19,1.03,'2025-12-30 17:51:37'),(1785,'seed',17,54.06,0.98,'2025-12-30 17:51:37'),(1786,'seed',18,50.86,1.02,'2025-12-30 17:51:37'),(1787,'seed',19,66.68,0.95,'2025-12-30 17:51:37'),(1788,'seed',20,66.82,1.03,'2025-12-30 17:51:37'),(1789,'seed',21,80.98,1.01,'2025-12-30 17:51:37'),(1790,'seed',22,95.43,0.95,'2025-12-30 17:51:37'),(1791,'seed',23,115.04,0.96,'2025-12-30 17:51:37'),(1792,'seed',24,156.96,1.05,'2025-12-30 17:51:37'),(1793,'seed',25,194.55,0.97,'2025-12-30 17:51:38'),(1794,'seed',26,497.82,1.00,'2025-12-30 17:51:38'),(1795,'crop',1,24.80,0.99,'2025-12-30 17:51:38'),(1796,'crop',2,34.08,0.97,'2025-12-30 17:51:38'),(1797,'crop',3,27.55,0.98,'2025-12-30 17:51:38'),(1798,'crop',4,38.60,0.96,'2025-12-30 17:51:38'),(1799,'crop',5,47.11,1.05,'2025-12-30 17:51:38'),(1800,'crop',6,29.75,0.93,'2025-12-30 17:51:38'),(1801,'crop',7,64.16,1.07,'2025-12-30 17:51:38'),(1802,'crop',8,74.88,1.07,'2025-12-30 17:51:38'),(1803,'crop',9,42.99,0.96,'2025-12-30 17:51:38'),(1804,'crop',10,80.65,1.01,'2025-12-30 17:51:38'),(1805,'crop',11,121.88,1.02,'2025-12-30 17:51:38'),(1806,'crop',12,101.92,1.02,'2025-12-30 17:51:38'),(1807,'crop',13,91.21,1.01,'2025-12-30 17:51:38'),(1808,'crop',14,96.22,1.07,'2025-12-30 17:51:38'),(1809,'crop',15,158.90,1.06,'2025-12-30 17:51:38'),(1810,'crop',16,77.58,0.97,'2025-12-30 17:51:38'),(1811,'crop',17,132.51,1.02,'2025-12-30 17:51:38'),(1812,'crop',18,115.31,0.96,'2025-12-30 17:51:38'),(1813,'crop',19,172.13,0.96,'2025-12-30 17:51:38'),(1814,'crop',20,152.92,0.96,'2025-12-30 17:51:38'),(1815,'crop',21,205.22,1.03,'2025-12-30 17:51:38'),(1816,'crop',22,264.47,1.06,'2025-12-30 17:51:38'),(1817,'crop',23,306.03,1.02,'2025-12-30 17:51:38'),(1818,'crop',24,402.70,1.01,'2025-12-30 17:51:38'),(1819,'crop',25,644.92,1.07,'2025-12-30 17:51:38'),(1820,'crop',26,1540.04,1.03,'2025-12-30 17:51:38'),(1821,'seed',1,10.04,1.00,'2025-12-30 17:53:15'),(1822,'seed',2,14.89,0.99,'2025-12-30 17:53:15'),(1823,'seed',3,12.60,1.05,'2025-12-30 17:53:15'),(1824,'seed',4,17.99,1.00,'2025-12-30 17:53:15'),(1825,'seed',5,20.04,1.00,'2025-12-30 17:53:16'),(1826,'seed',6,14.31,1.02,'2025-12-30 17:53:16'),(1827,'seed',7,25.12,1.00,'2025-12-30 17:53:16'),(1828,'seed',8,30.81,1.03,'2025-12-30 17:53:16'),(1829,'seed',9,20.82,1.04,'2025-12-30 17:53:16'),(1830,'seed',10,34.02,0.97,'2025-12-30 17:53:16'),(1831,'seed',11,48.85,0.98,'2025-12-30 17:53:16'),(1832,'seed',12,42.64,0.95,'2025-12-30 17:53:16'),(1833,'seed',13,42.23,1.06,'2025-12-30 17:53:16'),(1834,'seed',14,40.22,1.01,'2025-12-30 17:53:16'),(1835,'seed',15,60.38,1.01,'2025-12-30 17:53:16'),(1836,'seed',16,35.44,1.01,'2025-12-30 17:53:16'),(1837,'seed',17,53.25,0.97,'2025-12-30 17:53:16'),(1838,'seed',18,50.16,1.00,'2025-12-30 17:53:16'),(1839,'seed',19,65.11,0.93,'2025-12-30 17:53:16'),(1840,'seed',20,63.77,0.98,'2025-12-30 17:53:16'),(1841,'seed',21,77.02,0.96,'2025-12-30 17:53:16'),(1842,'seed',22,99.52,1.00,'2025-12-30 17:53:16'),(1843,'seed',23,117.47,0.98,'2025-12-30 17:53:16'),(1844,'seed',24,155.08,1.03,'2025-12-30 17:53:16'),(1845,'seed',25,188.11,0.94,'2025-12-30 17:53:16'),(1846,'seed',26,481.14,0.96,'2025-12-30 17:53:16'),(1847,'crop',1,24.13,0.97,'2025-12-30 17:53:16'),(1848,'crop',2,35.25,1.01,'2025-12-30 17:53:16'),(1849,'crop',3,28.60,1.02,'2025-12-30 17:53:16'),(1850,'crop',4,35.98,0.90,'2025-12-30 17:53:16'),(1851,'crop',5,43.74,0.97,'2025-12-30 17:53:16'),(1852,'crop',6,31.00,0.97,'2025-12-30 17:53:16'),(1853,'crop',7,68.02,1.13,'2025-12-30 17:53:16'),(1854,'crop',8,74.32,1.06,'2025-12-30 17:53:16'),(1855,'crop',9,44.69,0.99,'2025-12-30 17:53:16'),(1856,'crop',10,83.54,1.04,'2025-12-30 17:53:16'),(1857,'crop',11,121.94,1.02,'2025-12-30 17:53:17'),(1858,'crop',12,94.83,0.95,'2025-12-30 17:53:17'),(1859,'crop',13,85.42,0.95,'2025-12-30 17:53:17'),(1860,'crop',14,101.72,1.13,'2025-12-30 17:53:17'),(1861,'crop',15,167.00,1.11,'2025-12-30 17:53:17'),(1862,'crop',16,75.70,0.95,'2025-12-30 17:53:17'),(1863,'crop',17,140.90,1.08,'2025-12-30 17:53:17'),(1864,'crop',18,122.76,1.02,'2025-12-30 17:53:17'),(1865,'crop',19,177.10,0.98,'2025-12-30 17:53:17'),(1866,'crop',20,158.47,0.99,'2025-12-30 17:53:17'),(1867,'crop',21,203.23,1.02,'2025-12-30 17:53:17'),(1868,'crop',22,248.34,0.99,'2025-12-30 17:53:17'),(1869,'crop',23,325.44,1.08,'2025-12-30 17:53:17'),(1870,'crop',24,420.77,1.05,'2025-12-30 17:53:17'),(1871,'crop',25,662.91,1.10,'2025-12-30 17:53:17'),(1872,'crop',26,1524.84,1.02,'2025-12-30 17:53:17'),(1873,'seed',1,10.45,1.04,'2025-12-30 17:58:16'),(1874,'seed',2,14.70,0.98,'2025-12-30 17:58:16'),(1875,'seed',3,12.74,1.06,'2025-12-30 17:58:16'),(1876,'seed',4,18.72,1.04,'2025-12-30 17:58:16'),(1877,'seed',5,19.63,0.98,'2025-12-30 17:58:16'),(1878,'seed',6,13.63,0.97,'2025-12-30 17:58:17'),(1879,'seed',7,24.61,0.98,'2025-12-30 17:58:17'),(1880,'seed',8,29.66,0.99,'2025-12-30 17:58:17'),(1881,'seed',9,21.65,1.08,'2025-12-30 17:58:17'),(1882,'seed',10,34.52,0.99,'2025-12-30 17:58:17'),(1883,'seed',11,47.14,0.94,'2025-12-30 17:58:17'),(1884,'seed',12,41.90,0.93,'2025-12-30 17:58:17'),(1885,'seed',13,43.25,1.08,'2025-12-30 17:58:17'),(1886,'seed',14,40.38,1.01,'2025-12-30 17:58:17'),(1887,'seed',15,61.37,1.02,'2025-12-30 17:58:17'),(1888,'seed',16,34.80,0.99,'2025-12-30 17:58:17'),(1889,'seed',17,51.86,0.94,'2025-12-30 17:58:17'),(1890,'seed',18,51.71,1.03,'2025-12-30 17:58:17'),(1891,'seed',19,67.59,0.97,'2025-12-30 17:58:17'),(1892,'seed',20,61.76,0.95,'2025-12-30 17:58:17'),(1893,'seed',21,74.47,0.93,'2025-12-30 17:58:17'),(1894,'seed',22,100.28,1.00,'2025-12-30 17:58:17'),(1895,'seed',23,114.54,0.95,'2025-12-30 17:58:17'),(1896,'seed',24,158.74,1.06,'2025-12-30 17:58:17'),(1897,'seed',25,194.71,0.97,'2025-12-30 17:58:17'),(1898,'seed',26,493.40,0.99,'2025-12-30 17:58:17'),(1899,'crop',1,24.51,0.98,'2025-12-30 17:58:17'),(1900,'crop',2,36.07,1.03,'2025-12-30 17:58:17'),(1901,'crop',3,29.71,1.06,'2025-12-30 17:58:17'),(1902,'crop',4,38.29,0.96,'2025-12-30 17:58:17'),(1903,'crop',5,41.40,0.92,'2025-12-30 17:58:17'),(1904,'crop',6,31.94,1.00,'2025-12-30 17:58:17'),(1905,'crop',7,71.08,1.18,'2025-12-30 17:58:17'),(1906,'crop',8,69.15,0.99,'2025-12-30 17:58:17'),(1907,'crop',9,46.60,1.04,'2025-12-30 17:58:17'),(1908,'crop',10,86.74,1.08,'2025-12-30 17:58:17'),(1909,'crop',11,125.41,1.05,'2025-12-30 17:58:17'),(1910,'crop',12,94.79,0.95,'2025-12-30 17:58:18'),(1911,'crop',13,89.52,0.99,'2025-12-30 17:58:18'),(1912,'crop',14,107.51,1.19,'2025-12-30 17:58:18'),(1913,'crop',15,155.65,1.04,'2025-12-30 17:58:18'),(1914,'crop',16,75.65,0.95,'2025-12-30 17:58:18'),(1915,'crop',17,131.13,1.01,'2025-12-30 17:58:18'),(1916,'crop',18,125.90,1.05,'2025-12-30 17:58:18'),(1917,'crop',19,167.99,0.93,'2025-12-30 17:58:18'),(1918,'crop',20,160.49,1.00,'2025-12-30 17:58:18'),(1919,'crop',21,202.64,1.01,'2025-12-30 17:58:18'),(1920,'crop',22,243.41,0.97,'2025-12-30 17:58:18'),(1921,'crop',23,335.17,1.12,'2025-12-30 17:58:18'),(1922,'crop',24,421.95,1.05,'2025-12-30 17:58:18'),(1923,'crop',25,707.51,1.18,'2025-12-30 17:58:18'),(1924,'crop',26,1529.05,1.02,'2025-12-30 17:58:18'),(1925,'seed',1,10.22,1.02,'2025-12-30 17:59:38'),(1926,'seed',2,15.21,1.01,'2025-12-30 17:59:39'),(1927,'seed',3,12.35,1.03,'2025-12-30 17:59:39'),(1928,'seed',4,19.54,1.09,'2025-12-30 17:59:39'),(1929,'seed',5,20.05,1.00,'2025-12-30 17:59:39'),(1930,'seed',6,13.61,0.97,'2025-12-30 17:59:39'),(1931,'seed',7,23.55,0.94,'2025-12-30 17:59:39'),(1932,'seed',8,28.58,0.95,'2025-12-30 17:59:39'),(1933,'seed',9,22.23,1.11,'2025-12-30 17:59:39'),(1934,'seed',10,35.77,1.02,'2025-12-30 17:59:39'),(1935,'seed',11,45.88,0.92,'2025-12-30 17:59:39'),(1936,'seed',12,41.21,0.92,'2025-12-30 17:59:39'),(1937,'seed',13,42.80,1.07,'2025-12-30 17:59:39'),(1938,'seed',14,41.94,1.05,'2025-12-30 17:59:39'),(1939,'seed',15,61.00,1.02,'2025-12-30 17:59:39'),(1940,'seed',16,33.13,0.95,'2025-12-30 17:59:39'),(1941,'seed',17,49.23,0.90,'2025-12-30 17:59:39'),(1942,'seed',18,49.62,0.99,'2025-12-30 17:59:39'),(1943,'seed',19,68.10,0.97,'2025-12-30 17:59:39'),(1944,'seed',20,60.23,0.93,'2025-12-30 17:59:39'),(1945,'seed',21,72.16,0.90,'2025-12-30 17:59:39'),(1946,'seed',22,95.51,0.96,'2025-12-30 17:59:39'),(1947,'seed',23,113.65,0.95,'2025-12-30 17:59:39'),(1948,'seed',24,152.89,1.02,'2025-12-30 17:59:39'),(1949,'seed',25,197.56,0.99,'2025-12-30 17:59:39'),(1950,'seed',26,493.23,0.99,'2025-12-30 17:59:39'),(1951,'crop',1,23.62,0.94,'2025-12-30 17:59:39'),(1952,'crop',2,34.43,0.98,'2025-12-30 17:59:39'),(1953,'crop',3,29.50,1.05,'2025-12-30 17:59:39'),(1954,'crop',4,39.86,1.00,'2025-12-30 17:59:39'),(1955,'crop',5,43.70,0.97,'2025-12-30 17:59:39'),(1956,'crop',6,34.05,1.06,'2025-12-30 17:59:39'),(1957,'crop',7,72.03,1.20,'2025-12-30 17:59:39'),(1958,'crop',8,64.75,0.92,'2025-12-30 17:59:40'),(1959,'crop',9,43.69,0.97,'2025-12-30 17:59:40'),(1960,'crop',10,84.62,1.06,'2025-12-30 17:59:40'),(1961,'crop',11,129.10,1.08,'2025-12-30 17:59:40'),(1962,'crop',12,91.20,0.91,'2025-12-30 17:59:40'),(1963,'crop',13,84.11,0.93,'2025-12-30 17:59:40'),(1964,'crop',14,102.41,1.14,'2025-12-30 17:59:40'),(1965,'crop',15,166.62,1.11,'2025-12-30 17:59:40'),(1966,'crop',16,80.77,1.01,'2025-12-30 17:59:40'),(1967,'crop',17,126.84,0.98,'2025-12-30 17:59:40'),(1968,'crop',18,130.73,1.09,'2025-12-30 17:59:40'),(1969,'crop',19,163.40,0.91,'2025-12-30 17:59:40'),(1970,'crop',20,171.38,1.07,'2025-12-30 17:59:40'),(1971,'crop',21,210.65,1.05,'2025-12-30 17:59:40'),(1972,'crop',22,237.61,0.95,'2025-12-30 17:59:40'),(1973,'crop',23,329.99,1.10,'2025-12-30 17:59:40'),(1974,'crop',24,424.60,1.06,'2025-12-30 17:59:40'),(1975,'crop',25,699.35,1.17,'2025-12-30 17:59:40'),(1976,'crop',26,1583.45,1.06,'2025-12-30 17:59:40'),(1977,'seed',1,10.44,1.04,'2025-12-30 18:04:39'),(1978,'seed',2,15.13,1.01,'2025-12-30 18:04:39'),(1979,'seed',3,11.82,0.98,'2025-12-30 18:04:40'),(1980,'seed',4,19.91,1.11,'2025-12-30 18:04:40'),(1981,'seed',5,20.28,1.01,'2025-12-30 18:04:40'),(1982,'seed',6,13.84,0.99,'2025-12-30 18:04:40'),(1983,'seed',7,23.71,0.95,'2025-12-30 18:04:40'),(1984,'seed',8,28.28,0.94,'2025-12-30 18:04:40'),(1985,'seed',9,23.04,1.15,'2025-12-30 18:04:40'),(1986,'seed',10,35.60,1.02,'2025-12-30 18:04:40'),(1987,'seed',11,43.74,0.87,'2025-12-30 18:04:40'),(1988,'seed',12,41.35,0.92,'2025-12-30 18:04:40'),(1989,'seed',13,40.83,1.02,'2025-12-30 18:04:40'),(1990,'seed',14,42.17,1.05,'2025-12-30 18:04:40'),(1991,'seed',15,58.62,0.98,'2025-12-30 18:04:40'),(1992,'seed',16,31.68,0.91,'2025-12-30 18:04:40'),(1993,'seed',17,48.49,0.88,'2025-12-30 18:04:40'),(1994,'seed',18,49.00,0.98,'2025-12-30 18:04:40'),(1995,'seed',19,66.36,0.95,'2025-12-30 18:04:40'),(1996,'seed',20,62.88,0.97,'2025-12-30 18:04:40'),(1997,'seed',21,70.03,0.88,'2025-12-30 18:04:40'),(1998,'seed',22,93.46,0.93,'2025-12-30 18:04:40'),(1999,'seed',23,109.18,0.91,'2025-12-30 18:04:40'),(2000,'seed',24,158.00,1.05,'2025-12-30 18:04:40'),(2001,'seed',25,190.80,0.95,'2025-12-30 18:04:40'),(2002,'seed',26,471.68,0.94,'2025-12-30 18:04:40'),(2003,'crop',1,23.19,0.93,'2025-12-30 18:04:40'),(2004,'crop',2,31.98,0.91,'2025-12-30 18:04:40'),(2005,'crop',3,27.39,0.98,'2025-12-30 18:04:40'),(2006,'crop',4,42.60,1.06,'2025-12-30 18:04:40'),(2007,'crop',5,42.40,0.94,'2025-12-30 18:04:40'),(2008,'crop',6,31.68,0.99,'2025-12-30 18:04:40'),(2009,'crop',7,69.30,1.15,'2025-12-30 18:04:40'),(2010,'crop',8,63.72,0.91,'2025-12-30 18:04:40'),(2011,'crop',9,41.84,0.93,'2025-12-30 18:04:41'),(2012,'crop',10,83.61,1.05,'2025-12-30 18:04:41'),(2013,'crop',11,122.89,1.02,'2025-12-30 18:04:41'),(2014,'crop',12,84.59,0.85,'2025-12-30 18:04:41'),(2015,'crop',13,85.25,0.95,'2025-12-30 18:04:41'),(2016,'crop',14,110.26,1.23,'2025-12-30 18:04:41'),(2017,'crop',15,155.26,1.04,'2025-12-30 18:04:41'),(2018,'crop',16,77.37,0.97,'2025-12-30 18:04:41'),(2019,'crop',17,121.51,0.93,'2025-12-30 18:04:41'),(2020,'crop',18,127.39,1.06,'2025-12-30 18:04:41'),(2021,'crop',19,153.04,0.85,'2025-12-30 18:04:41'),(2022,'crop',20,170.38,1.06,'2025-12-30 18:04:41'),(2023,'crop',21,194.77,0.97,'2025-12-30 18:04:41'),(2024,'crop',22,237.69,0.95,'2025-12-30 18:04:41'),(2025,'crop',23,318.50,1.06,'2025-12-30 18:04:41'),(2026,'crop',24,453.00,1.13,'2025-12-30 18:04:41'),(2027,'crop',25,677.01,1.13,'2025-12-30 18:04:41'),(2028,'crop',26,1670.95,1.11,'2025-12-30 18:04:41'),(2029,'seed',1,10.55,1.05,'2025-12-30 18:07:35'),(2030,'seed',2,15.47,1.03,'2025-12-30 18:07:35'),(2031,'seed',3,11.19,0.93,'2025-12-30 18:07:35'),(2032,'seed',4,20.18,1.12,'2025-12-30 18:07:35'),(2033,'seed',5,20.76,1.04,'2025-12-30 18:07:35'),(2034,'seed',6,13.78,0.98,'2025-12-30 18:07:35'),(2035,'seed',7,24.00,0.96,'2025-12-30 18:07:35'),(2036,'seed',8,27.28,0.91,'2025-12-30 18:07:35'),(2037,'seed',9,22.21,1.11,'2025-12-30 18:07:35'),(2038,'seed',10,34.59,0.99,'2025-12-30 18:07:35'),(2039,'seed',11,41.35,0.83,'2025-12-30 18:07:35'),(2040,'seed',12,41.61,0.92,'2025-12-30 18:07:35'),(2041,'seed',13,39.50,0.99,'2025-12-30 18:07:35'),(2042,'seed',14,40.72,1.02,'2025-12-30 18:07:35'),(2043,'seed',15,59.18,0.99,'2025-12-30 18:07:35'),(2044,'seed',16,31.65,0.90,'2025-12-30 18:07:35'),(2045,'seed',17,47.19,0.86,'2025-12-30 18:07:35'),(2046,'seed',18,50.21,1.00,'2025-12-30 18:07:35'),(2047,'seed',19,68.09,0.97,'2025-12-30 18:07:35'),(2048,'seed',20,60.99,0.94,'2025-12-30 18:07:35'),(2049,'seed',21,68.10,0.85,'2025-12-30 18:07:35'),(2050,'seed',22,89.43,0.89,'2025-12-30 18:07:35'),(2051,'seed',23,104.40,0.87,'2025-12-30 18:07:35'),(2052,'seed',24,160.13,1.07,'2025-12-30 18:07:35'),(2053,'seed',25,193.74,0.97,'2025-12-30 18:07:35'),(2054,'seed',26,453.59,0.91,'2025-12-30 18:07:35'),(2055,'crop',1,22.59,0.90,'2025-12-30 18:07:35'),(2056,'crop',2,33.05,0.94,'2025-12-30 18:07:35'),(2057,'crop',3,27.71,0.99,'2025-12-30 18:07:35'),(2058,'crop',4,44.55,1.11,'2025-12-30 18:07:35'),(2059,'crop',5,41.74,0.93,'2025-12-30 18:07:35'),(2060,'crop',6,31.19,0.97,'2025-12-30 18:07:36'),(2061,'crop',7,67.98,1.13,'2025-12-30 18:07:36'),(2062,'crop',8,66.22,0.95,'2025-12-30 18:07:36'),(2063,'crop',9,44.16,0.98,'2025-12-30 18:07:36'),(2064,'crop',10,77.91,0.97,'2025-12-30 18:07:36'),(2065,'crop',11,129.69,1.08,'2025-12-30 18:07:36'),(2066,'crop',12,90.18,0.90,'2025-12-30 18:07:36'),(2067,'crop',13,80.71,0.90,'2025-12-30 18:07:36'),(2068,'crop',14,114.49,1.27,'2025-12-30 18:07:36'),(2069,'crop',15,149.57,1.00,'2025-12-30 18:07:36'),(2070,'crop',16,77.62,0.97,'2025-12-30 18:07:36'),(2071,'crop',17,127.87,0.98,'2025-12-30 18:07:36'),(2072,'crop',18,126.72,1.06,'2025-12-30 18:07:36'),(2073,'crop',19,154.71,0.86,'2025-12-30 18:07:36'),(2074,'crop',20,170.11,1.06,'2025-12-30 18:07:36'),(2075,'crop',21,183.61,0.92,'2025-12-30 18:07:36'),(2076,'crop',22,228.06,0.91,'2025-12-30 18:07:36'),(2077,'crop',23,336.24,1.12,'2025-12-30 18:07:36'),(2078,'crop',24,443.91,1.11,'2025-12-30 18:07:36'),(2079,'crop',25,685.36,1.14,'2025-12-30 18:07:36'),(2080,'crop',26,1569.50,1.05,'2025-12-30 18:07:36'),(2081,'seed',1,10.26,1.03,'2025-12-30 18:12:36'),(2082,'seed',2,16.01,1.07,'2025-12-30 18:12:36'),(2083,'seed',3,10.62,0.88,'2025-12-30 18:12:36'),(2084,'seed',4,20.88,1.16,'2025-12-30 18:12:36'),(2085,'seed',5,21.20,1.06,'2025-12-30 18:12:36'),(2086,'seed',6,14.15,1.01,'2025-12-30 18:12:36'),(2087,'seed',7,23.76,0.95,'2025-12-30 18:12:36'),(2088,'seed',8,28.18,0.94,'2025-12-30 18:12:36'),(2089,'seed',9,21.28,1.06,'2025-12-30 18:12:36'),(2090,'seed',10,33.45,0.96,'2025-12-30 18:12:36'),(2091,'seed',11,40.96,0.82,'2025-12-30 18:12:36'),(2092,'seed',12,41.27,0.92,'2025-12-30 18:12:36'),(2093,'seed',13,38.80,0.97,'2025-12-30 18:12:36'),(2094,'seed',14,38.97,0.97,'2025-12-30 18:12:36'),(2095,'seed',15,62.32,1.04,'2025-12-30 18:12:36'),(2096,'seed',16,31.35,0.90,'2025-12-30 18:12:36'),(2097,'seed',17,48.86,0.89,'2025-12-30 18:12:36'),(2098,'seed',18,49.83,1.00,'2025-12-30 18:12:36'),(2099,'seed',19,66.04,0.94,'2025-12-30 18:12:36'),(2100,'seed',20,60.26,0.93,'2025-12-30 18:12:36'),(2101,'seed',21,70.56,0.88,'2025-12-30 18:12:36'),(2102,'seed',22,85.84,0.86,'2025-12-30 18:12:36'),(2103,'seed',23,103.15,0.86,'2025-12-30 18:12:36'),(2104,'seed',24,167.45,1.12,'2025-12-30 18:12:36'),(2105,'seed',25,195.69,0.98,'2025-12-30 18:12:36'),(2106,'seed',26,436.36,0.87,'2025-12-30 18:12:36'),(2107,'crop',1,22.62,0.90,'2025-12-30 18:12:36'),(2108,'crop',2,30.74,0.88,'2025-12-30 18:12:36'),(2109,'crop',3,28.23,1.01,'2025-12-30 18:12:36'),(2110,'crop',4,45.79,1.14,'2025-12-30 18:12:36'),(2111,'crop',5,41.71,0.93,'2025-12-30 18:12:36'),(2112,'crop',6,31.88,1.00,'2025-12-30 18:12:37'),(2113,'crop',7,65.22,1.09,'2025-12-30 18:12:37'),(2114,'crop',8,62.27,0.89,'2025-12-30 18:12:37'),(2115,'crop',9,44.76,0.99,'2025-12-30 18:12:37'),(2116,'crop',10,81.57,1.02,'2025-12-30 18:12:37'),(2117,'crop',11,133.84,1.12,'2025-12-30 18:12:37'),(2118,'crop',12,95.99,0.96,'2025-12-30 18:12:37'),(2119,'crop',13,83.92,0.93,'2025-12-30 18:12:37'),(2120,'crop',14,110.11,1.22,'2025-12-30 18:12:37'),(2121,'crop',15,142.22,0.95,'2025-12-30 18:12:37'),(2122,'crop',16,79.27,0.99,'2025-12-30 18:12:37'),(2123,'crop',17,134.75,1.04,'2025-12-30 18:12:37'),(2124,'crop',18,132.94,1.11,'2025-12-30 18:12:37'),(2125,'crop',19,157.88,0.88,'2025-12-30 18:12:37'),(2126,'crop',20,179.24,1.12,'2025-12-30 18:12:37'),(2127,'crop',21,196.73,0.98,'2025-12-30 18:12:37'),(2128,'crop',22,240.23,0.96,'2025-12-30 18:12:37'),(2129,'crop',23,337.11,1.12,'2025-12-30 18:12:37'),(2130,'crop',24,451.48,1.13,'2025-12-30 18:12:37'),(2131,'crop',25,646.89,1.08,'2025-12-30 18:12:37'),(2132,'crop',26,1596.24,1.06,'2025-12-30 18:12:37'),(2133,'seed',1,9.90,0.99,'2025-12-30 18:14:05'),(2134,'seed',2,15.94,1.06,'2025-12-30 18:14:05'),(2135,'seed',3,10.68,0.89,'2025-12-30 18:14:05'),(2136,'seed',4,20.11,1.12,'2025-12-30 18:14:05'),(2137,'seed',5,21.09,1.05,'2025-12-30 18:14:05'),(2138,'seed',6,14.21,1.02,'2025-12-30 18:14:05'),(2139,'seed',7,22.57,0.90,'2025-12-30 18:14:05'),(2140,'seed',8,27.36,0.91,'2025-12-30 18:14:05'),(2141,'seed',9,21.92,1.10,'2025-12-30 18:14:05'),(2142,'seed',10,35.10,1.00,'2025-12-30 18:14:05'),(2143,'seed',11,40.97,0.82,'2025-12-30 18:14:05'),(2144,'seed',12,43.33,0.96,'2025-12-30 18:14:05'),(2145,'seed',13,40.72,1.02,'2025-12-30 18:14:05'),(2146,'seed',14,37.72,0.94,'2025-12-30 18:14:05'),(2147,'seed',15,61.99,1.03,'2025-12-30 18:14:05'),(2148,'seed',16,30.41,0.87,'2025-12-30 18:14:05'),(2149,'seed',17,47.76,0.87,'2025-12-30 18:14:05'),(2150,'seed',18,52.12,1.04,'2025-12-30 18:14:05'),(2151,'seed',19,67.41,0.96,'2025-12-30 18:14:05'),(2152,'seed',20,61.96,0.95,'2025-12-30 18:14:05'),(2153,'seed',21,71.61,0.90,'2025-12-30 18:14:05'),(2154,'seed',22,82.97,0.83,'2025-12-30 18:14:05'),(2155,'seed',23,102.50,0.85,'2025-12-30 18:14:05'),(2156,'seed',24,166.45,1.11,'2025-12-30 18:14:05'),(2157,'seed',25,203.87,1.02,'2025-12-30 18:14:05'),(2158,'seed',26,417.24,0.83,'2025-12-30 18:14:05'),(2159,'crop',1,21.38,0.86,'2025-12-30 18:14:05'),(2160,'crop',2,31.49,0.90,'2025-12-30 18:14:05'),(2161,'crop',3,27.04,0.97,'2025-12-30 18:14:05'),(2162,'crop',4,43.64,1.09,'2025-12-30 18:14:05'),(2163,'crop',5,44.04,0.98,'2025-12-30 18:14:05'),(2164,'crop',6,33.16,1.04,'2025-12-30 18:14:05'),(2165,'crop',7,63.70,1.06,'2025-12-30 18:14:06'),(2166,'crop',8,62.56,0.89,'2025-12-30 18:14:06'),(2167,'crop',9,45.91,1.02,'2025-12-30 18:14:06'),(2168,'crop',10,81.65,1.02,'2025-12-30 18:14:06'),(2169,'crop',11,141.05,1.18,'2025-12-30 18:14:06'),(2170,'crop',12,101.23,1.01,'2025-12-30 18:14:06'),(2171,'crop',13,80.31,0.89,'2025-12-30 18:14:06'),(2172,'crop',14,104.68,1.16,'2025-12-30 18:14:06'),(2173,'crop',15,136.19,0.91,'2025-12-30 18:14:06'),(2174,'crop',16,81.97,1.02,'2025-12-30 18:14:06'),(2175,'crop',17,132.82,1.02,'2025-12-30 18:14:06'),(2176,'crop',18,129.46,1.08,'2025-12-30 18:14:06'),(2177,'crop',19,158.36,0.88,'2025-12-30 18:14:06'),(2178,'crop',20,174.89,1.09,'2025-12-30 18:14:06'),(2179,'crop',21,188.20,0.94,'2025-12-30 18:14:06'),(2180,'crop',22,224.78,0.90,'2025-12-30 18:14:06'),(2181,'crop',23,336.87,1.12,'2025-12-30 18:14:06'),(2182,'crop',24,441.90,1.10,'2025-12-30 18:14:06'),(2183,'crop',25,657.33,1.10,'2025-12-30 18:14:06'),(2184,'crop',26,1627.02,1.08,'2025-12-30 18:14:06'),(2185,'seed',1,10.36,1.04,'2025-12-30 18:19:06'),(2186,'seed',2,16.37,1.09,'2025-12-30 18:19:06'),(2187,'seed',3,10.15,0.85,'2025-12-30 18:19:06'),(2188,'seed',4,20.64,1.15,'2025-12-30 18:19:06'),(2189,'seed',5,20.12,1.01,'2025-12-30 18:19:06'),(2190,'seed',6,14.29,1.02,'2025-12-30 18:19:06'),(2191,'seed',7,23.44,0.94,'2025-12-30 18:19:06'),(2192,'seed',8,26.18,0.87,'2025-12-30 18:19:06'),(2193,'seed',9,22.96,1.15,'2025-12-30 18:19:06'),(2194,'seed',10,36.40,1.04,'2025-12-30 18:19:06'),(2195,'seed',11,40.81,0.82,'2025-12-30 18:19:06'),(2196,'seed',12,43.24,0.96,'2025-12-30 18:19:06'),(2197,'seed',13,39.16,0.98,'2025-12-30 18:19:06'),(2198,'seed',14,38.03,0.95,'2025-12-30 18:19:06'),(2199,'seed',15,59.93,1.00,'2025-12-30 18:19:06'),(2200,'seed',16,30.10,0.86,'2025-12-30 18:19:06'),(2201,'seed',17,48.33,0.88,'2025-12-30 18:19:06'),(2202,'seed',18,51.77,1.04,'2025-12-30 18:19:06'),(2203,'seed',19,68.96,0.99,'2025-12-30 18:19:06'),(2204,'seed',20,58.78,0.90,'2025-12-30 18:19:06'),(2205,'seed',21,71.55,0.89,'2025-12-30 18:19:06'),(2206,'seed',22,79.05,0.79,'2025-12-30 18:19:06'),(2207,'seed',23,104.01,0.87,'2025-12-30 18:19:06'),(2208,'seed',24,174.49,1.16,'2025-12-30 18:19:06'),(2209,'seed',25,206.44,1.03,'2025-12-30 18:19:06'),(2210,'seed',26,424.66,0.85,'2025-12-30 18:19:06'),(2211,'crop',1,20.44,0.82,'2025-12-30 18:19:06'),(2212,'crop',2,32.55,0.93,'2025-12-30 18:19:06'),(2213,'crop',3,25.21,0.90,'2025-12-30 18:19:06'),(2214,'crop',4,45.99,1.15,'2025-12-30 18:19:06'),(2215,'crop',5,43.81,0.97,'2025-12-30 18:19:06'),(2216,'crop',6,32.24,1.01,'2025-12-30 18:19:06'),(2217,'crop',7,61.33,1.02,'2025-12-30 18:19:07'),(2218,'crop',8,58.66,0.84,'2025-12-30 18:19:07'),(2219,'crop',9,49.34,1.10,'2025-12-30 18:19:07'),(2220,'crop',10,78.88,0.99,'2025-12-30 18:19:07'),(2221,'crop',11,151.20,1.26,'2025-12-30 18:19:07'),(2222,'crop',12,108.43,1.08,'2025-12-30 18:19:07'),(2223,'crop',13,76.20,0.85,'2025-12-30 18:19:07'),(2224,'crop',14,101.90,1.13,'2025-12-30 18:19:07'),(2225,'crop',15,136.74,0.91,'2025-12-30 18:19:07'),(2226,'crop',16,86.60,1.08,'2025-12-30 18:19:07'),(2227,'crop',17,128.94,0.99,'2025-12-30 18:19:07'),(2228,'crop',18,136.70,1.14,'2025-12-30 18:19:07'),(2229,'crop',19,162.38,0.90,'2025-12-30 18:19:07'),(2230,'crop',20,162.88,1.02,'2025-12-30 18:19:07'),(2231,'crop',21,177.09,0.89,'2025-12-30 18:19:07'),(2232,'crop',22,237.51,0.95,'2025-12-30 18:19:07'),(2233,'crop',23,332.75,1.11,'2025-12-30 18:19:07'),(2234,'crop',24,448.76,1.12,'2025-12-30 18:19:07'),(2235,'crop',25,651.32,1.09,'2025-12-30 18:19:07'),(2236,'crop',26,1722.09,1.15,'2025-12-30 18:19:07'),(2237,'seed',1,10.39,1.04,'2025-12-30 18:21:19'),(2238,'seed',2,16.81,1.12,'2025-12-30 18:21:19'),(2239,'seed',3,9.87,0.82,'2025-12-30 18:21:19'),(2240,'seed',4,21.07,1.17,'2025-12-30 18:21:19'),(2241,'seed',5,20.60,1.03,'2025-12-30 18:21:19'),(2242,'seed',6,14.88,1.06,'2025-12-30 18:21:19'),(2243,'seed',7,23.11,0.92,'2025-12-30 18:21:19'),(2244,'seed',8,26.74,0.89,'2025-12-30 18:21:19'),(2245,'seed',9,23.23,1.16,'2025-12-30 18:21:19'),(2246,'seed',10,35.59,1.02,'2025-12-30 18:21:19'),(2247,'seed',11,42.49,0.85,'2025-12-30 18:21:19'),(2248,'seed',12,44.03,0.98,'2025-12-30 18:21:19'),(2249,'seed',13,38.45,0.96,'2025-12-30 18:21:19'),(2250,'seed',14,38.61,0.97,'2025-12-30 18:21:19'),(2251,'seed',15,62.14,1.04,'2025-12-30 18:21:19'),(2252,'seed',16,29.15,0.83,'2025-12-30 18:21:19'),(2253,'seed',17,47.16,0.86,'2025-12-30 18:21:19'),(2254,'seed',18,52.62,1.05,'2025-12-30 18:21:20'),(2255,'seed',19,68.69,0.98,'2025-12-30 18:21:20'),(2256,'seed',20,58.95,0.91,'2025-12-30 18:21:20'),(2257,'seed',21,70.91,0.89,'2025-12-30 18:21:20'),(2258,'seed',22,80.43,0.80,'2025-12-30 18:21:20'),(2259,'seed',23,101.80,0.85,'2025-12-30 18:21:20'),(2260,'seed',24,170.08,1.13,'2025-12-30 18:21:20'),(2261,'seed',25,215.54,1.08,'2025-12-30 18:21:20'),(2262,'seed',26,431.08,0.86,'2025-12-30 18:21:20'),(2263,'crop',1,21.16,0.85,'2025-12-30 18:21:20'),(2264,'crop',2,33.95,0.97,'2025-12-30 18:21:20'),(2265,'crop',3,25.60,0.91,'2025-12-30 18:21:20'),(2266,'crop',4,45.31,1.13,'2025-12-30 18:21:20'),(2267,'crop',5,42.93,0.95,'2025-12-30 18:21:20'),(2268,'crop',6,33.43,1.04,'2025-12-30 18:21:20'),(2269,'crop',7,60.49,1.01,'2025-12-30 18:21:20'),(2270,'crop',8,60.85,0.87,'2025-12-30 18:21:20'),(2271,'crop',9,46.51,1.03,'2025-12-30 18:21:20'),(2272,'crop',10,74.91,0.94,'2025-12-30 18:21:20'),(2273,'crop',11,154.70,1.29,'2025-12-30 18:21:20'),(2274,'crop',12,100.39,1.00,'2025-12-30 18:21:20'),(2275,'crop',13,72.99,0.81,'2025-12-30 18:21:20'),(2276,'crop',14,97.31,1.08,'2025-12-30 18:21:20'),(2277,'crop',15,144.11,0.96,'2025-12-30 18:21:20'),(2278,'crop',16,90.90,1.14,'2025-12-30 18:21:20'),(2279,'crop',17,119.35,0.92,'2025-12-30 18:21:20'),(2280,'crop',18,134.95,1.12,'2025-12-30 18:21:20'),(2281,'crop',19,172.44,0.96,'2025-12-30 18:21:20'),(2282,'crop',20,166.88,1.04,'2025-12-30 18:21:20'),(2283,'crop',21,167.03,0.84,'2025-12-30 18:21:20'),(2284,'crop',22,229.43,0.92,'2025-12-30 18:21:20'),(2285,'crop',23,348.94,1.16,'2025-12-30 18:21:20'),(2286,'crop',24,418.34,1.05,'2025-12-30 18:21:20'),(2287,'crop',25,667.50,1.11,'2025-12-30 18:21:21'),(2288,'crop',26,1796.59,1.20,'2025-12-30 18:21:21'),(2289,'seed',1,9.99,1.00,'2025-12-30 18:26:06'),(2290,'seed',2,17.55,1.17,'2025-12-30 18:26:06'),(2291,'seed',3,9.63,0.80,'2025-12-30 18:26:06'),(2292,'seed',4,20.05,1.11,'2025-12-30 18:26:06'),(2293,'seed',5,20.06,1.00,'2025-12-30 18:26:06'),(2294,'seed',6,14.38,1.03,'2025-12-30 18:26:06'),(2295,'seed',7,23.52,0.94,'2025-12-30 18:26:06'),(2296,'seed',8,27.96,0.93,'2025-12-30 18:26:06'),(2297,'seed',9,23.65,1.18,'2025-12-30 18:26:06'),(2298,'seed',10,36.48,1.04,'2025-12-30 18:26:06'),(2299,'seed',11,43.47,0.87,'2025-12-30 18:26:06'),(2300,'seed',12,46.09,1.02,'2025-12-30 18:26:06'),(2301,'seed',13,39.46,0.99,'2025-12-30 18:26:06'),(2302,'seed',14,37.79,0.94,'2025-12-30 18:26:07'),(2303,'seed',15,61.00,1.02,'2025-12-30 18:26:07'),(2304,'seed',16,28.16,0.80,'2025-12-30 18:26:07'),(2305,'seed',17,45.25,0.82,'2025-12-30 18:26:07'),(2306,'seed',18,52.02,1.04,'2025-12-30 18:26:07'),(2307,'seed',19,67.15,0.96,'2025-12-30 18:26:07'),(2308,'seed',20,61.31,0.94,'2025-12-30 18:26:07'),(2309,'seed',21,70.32,0.88,'2025-12-30 18:26:07'),(2310,'seed',22,77.48,0.77,'2025-12-30 18:26:07'),(2311,'seed',23,96.96,0.81,'2025-12-30 18:26:07'),(2312,'seed',24,169.34,1.13,'2025-12-30 18:26:07'),(2313,'seed',25,214.70,1.07,'2025-12-30 18:26:07'),(2314,'seed',26,444.51,0.89,'2025-12-30 18:26:07'),(2315,'crop',1,22.67,0.91,'2025-12-30 18:26:07'),(2316,'crop',2,36.04,1.03,'2025-12-30 18:26:07'),(2317,'crop',3,26.04,0.93,'2025-12-30 18:26:07'),(2318,'crop',4,45.23,1.13,'2025-12-30 18:26:07'),(2319,'crop',5,42.60,0.95,'2025-12-30 18:26:07'),(2320,'crop',6,32.17,1.01,'2025-12-30 18:26:07'),(2321,'crop',7,62.95,1.05,'2025-12-30 18:26:07'),(2322,'crop',8,64.66,0.92,'2025-12-30 18:26:07'),(2323,'crop',9,44.76,0.99,'2025-12-30 18:26:07'),(2324,'crop',10,69.77,0.87,'2025-12-30 18:26:07'),(2325,'crop',11,144.20,1.20,'2025-12-30 18:26:07'),(2326,'crop',12,100.68,1.01,'2025-12-30 18:26:07'),(2327,'crop',13,73.18,0.81,'2025-12-30 18:26:07'),(2328,'crop',14,102.96,1.14,'2025-12-30 18:26:07'),(2329,'crop',15,151.20,1.01,'2025-12-30 18:26:07'),(2330,'crop',16,91.15,1.14,'2025-12-30 18:26:07'),(2331,'crop',17,114.12,0.88,'2025-12-30 18:26:07'),(2332,'crop',18,125.96,1.05,'2025-12-30 18:26:07'),(2333,'crop',19,183.74,1.02,'2025-12-30 18:26:07'),(2334,'crop',20,166.36,1.04,'2025-12-30 18:26:08'),(2335,'crop',21,163.38,0.82,'2025-12-30 18:26:08'),(2336,'crop',22,235.65,0.94,'2025-12-30 18:26:08'),(2337,'crop',23,348.04,1.16,'2025-12-30 18:26:08'),(2338,'crop',24,439.86,1.10,'2025-12-30 18:26:08'),(2339,'crop',25,677.72,1.13,'2025-12-30 18:26:08'),(2340,'crop',26,1844.59,1.23,'2025-12-30 18:26:08'),(2341,'seed',1,10.02,1.00,'2025-12-30 18:26:44'),(2342,'seed',2,17.04,1.14,'2025-12-30 18:26:44'),(2343,'seed',3,10.04,0.84,'2025-12-30 18:26:44'),(2344,'seed',4,20.16,1.12,'2025-12-30 18:26:44'),(2345,'seed',5,19.95,1.00,'2025-12-30 18:26:44'),(2346,'seed',6,14.94,1.07,'2025-12-30 18:26:44'),(2347,'seed',7,23.50,0.94,'2025-12-30 18:26:44'),(2348,'seed',8,27.10,0.90,'2025-12-30 18:26:44'),(2349,'seed',9,22.76,1.14,'2025-12-30 18:26:44'),(2350,'seed',10,36.00,1.03,'2025-12-30 18:26:44'),(2351,'seed',11,42.83,0.86,'2025-12-30 18:26:44'),(2352,'seed',12,46.62,1.04,'2025-12-30 18:26:44'),(2353,'seed',13,39.32,0.98,'2025-12-30 18:26:44'),(2354,'seed',14,35.91,0.90,'2025-12-30 18:26:44'),(2355,'seed',15,61.72,1.03,'2025-12-30 18:26:44'),(2356,'seed',16,28.77,0.82,'2025-12-30 18:26:44'),(2357,'seed',17,45.88,0.83,'2025-12-30 18:26:44'),(2358,'seed',18,53.65,1.07,'2025-12-30 18:26:45'),(2359,'seed',19,68.10,0.97,'2025-12-30 18:26:45'),(2360,'seed',20,63.88,0.98,'2025-12-30 18:26:45'),(2361,'seed',21,71.80,0.90,'2025-12-30 18:26:45'),(2362,'seed',22,75.72,0.76,'2025-12-30 18:26:45'),(2363,'seed',23,99.82,0.83,'2025-12-30 18:26:45'),(2364,'seed',24,166.61,1.11,'2025-12-30 18:26:45'),(2365,'seed',25,220.16,1.10,'2025-12-30 18:26:45'),(2366,'seed',26,466.29,0.93,'2025-12-30 18:26:45'),(2367,'crop',1,23.50,0.94,'2025-12-30 18:26:45'),(2368,'crop',2,37.73,1.08,'2025-12-30 18:26:45'),(2369,'crop',3,24.49,0.87,'2025-12-30 18:26:45'),(2370,'crop',4,42.65,1.07,'2025-12-30 18:26:45'),(2371,'crop',5,41.75,0.93,'2025-12-30 18:26:45'),(2372,'crop',6,32.37,1.01,'2025-12-30 18:26:45'),(2373,'crop',7,61.08,1.02,'2025-12-30 18:26:45'),(2374,'crop',8,66.58,0.95,'2025-12-30 18:26:45'),(2375,'crop',9,47.59,1.06,'2025-12-30 18:26:45'),(2376,'crop',10,67.14,0.84,'2025-12-30 18:26:45'),(2377,'crop',11,142.39,1.19,'2025-12-30 18:26:45'),(2378,'crop',12,103.00,1.03,'2025-12-30 18:26:45'),(2379,'crop',13,69.37,0.77,'2025-12-30 18:26:45'),(2380,'crop',14,95.02,1.06,'2025-12-30 18:26:45'),(2381,'crop',15,159.83,1.07,'2025-12-30 18:26:45'),(2382,'crop',16,96.39,1.20,'2025-12-30 18:26:45'),(2383,'crop',17,118.19,0.91,'2025-12-30 18:26:45'),(2384,'crop',18,134.42,1.12,'2025-12-30 18:26:45'),(2385,'crop',19,184.17,1.02,'2025-12-30 18:26:45'),(2386,'crop',20,162.67,1.02,'2025-12-30 18:26:45'),(2387,'crop',21,172.31,0.86,'2025-12-30 18:26:45'),(2388,'crop',22,244.98,0.98,'2025-12-30 18:26:45'),(2389,'crop',23,337.81,1.13,'2025-12-30 18:26:45'),(2390,'crop',24,432.55,1.08,'2025-12-30 18:26:46'),(2391,'crop',25,712.33,1.19,'2025-12-30 18:26:46'),(2392,'crop',26,1949.86,1.30,'2025-12-30 18:26:46');
/*!40000 ALTER TABLE `price_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price_rules`
--

DROP TABLE IF EXISTS `price_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `price_rules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `item_type` enum('seed','crop') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品类型',
  `item_id` bigint(20) unsigned NOT NULL COMMENT '物品ID',
  `base_price` decimal(10,2) NOT NULL COMMENT '基准价格',
  `min_rate` decimal(5,2) DEFAULT '0.50' COMMENT '最低比率',
  `max_rate` decimal(5,2) DEFAULT '2.00' COMMENT '最高比率',
  `volatility` decimal(5,2) DEFAULT '0.10' COMMENT '波动系数',
  `supply_weight` decimal(5,2) DEFAULT '1.00' COMMENT '供给影响权重',
  `demand_weight` decimal(5,2) DEFAULT '1.00' COMMENT '需求影响权重',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item` (`item_type`,`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='价格规则表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price_rules`
--

LOCK TABLES `price_rules` WRITE;
/*!40000 ALTER TABLE `price_rules` DISABLE KEYS */;
INSERT INTO `price_rules` VALUES (1,'seed',1,10.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(2,'seed',2,15.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(3,'seed',3,12.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(4,'seed',4,18.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(5,'seed',5,20.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(6,'seed',6,14.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(7,'seed',7,25.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(8,'seed',8,30.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(9,'seed',9,20.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(10,'seed',10,35.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(11,'seed',11,50.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(12,'seed',12,45.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(13,'seed',13,40.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(14,'seed',14,40.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(15,'seed',15,60.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(16,'seed',16,35.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(17,'seed',17,55.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(18,'seed',18,50.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(19,'seed',19,70.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(20,'seed',20,65.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(21,'seed',21,80.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(22,'seed',22,100.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(23,'seed',23,120.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(24,'seed',24,150.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(25,'seed',25,200.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(26,'seed',26,500.00,0.50,2.00,0.10,1.00,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(32,'crop',1,25.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(33,'crop',2,35.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(34,'crop',3,28.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(35,'crop',4,40.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(36,'crop',5,45.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(37,'crop',6,32.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(38,'crop',7,60.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(39,'crop',8,70.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(40,'crop',9,45.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(41,'crop',10,80.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(42,'crop',11,120.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(43,'crop',12,100.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(44,'crop',13,90.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(45,'crop',14,90.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(46,'crop',15,150.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(47,'crop',16,80.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(48,'crop',17,130.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(49,'crop',18,120.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(50,'crop',19,180.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(51,'crop',20,160.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(52,'crop',21,200.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(53,'crop',22,250.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(54,'crop',23,300.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(55,'crop',24,400.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(56,'crop',25,600.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31'),(57,'crop',26,1500.00,0.50,2.00,0.15,1.20,1.00,'2025-12-30 15:38:31','2025-12-30 15:38:31');
/*!40000 ALTER TABLE `price_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rankings`
--

DROP TABLE IF EXISTS `rankings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rankings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `rank_type` enum('gold','level','contribution','achievement','harvest','trade') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '排行类型',
  `user_id` bigint(20) unsigned NOT NULL,
  `rank_position` int(11) NOT NULL COMMENT '排名',
  `score` bigint(20) NOT NULL COMMENT '分数',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type_user` (`rank_type`,`user_id`),
  KEY `idx_type_rank` (`rank_type`,`rank_position`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `rankings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=347 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='排行榜缓存表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rankings`
--

LOCK TABLES `rankings` WRITE;
/*!40000 ALTER TABLE `rankings` DISABLE KEYS */;
INSERT INTO `rankings` VALUES (337,'gold',2,1,2978,'2025-12-30 19:33:34'),(338,'gold',1,2,990,'2025-12-30 19:33:34'),(339,'level',2,1,6,'2025-12-30 19:33:34'),(340,'level',1,2,1,'2025-12-30 19:33:34'),(341,'contribution',2,1,843,'2025-12-30 19:33:34'),(342,'contribution',1,2,0,'2025-12-30 19:33:34'),(343,'achievement',2,1,47,'2025-12-30 19:33:34'),(344,'achievement',1,2,0,'2025-12-30 19:33:34'),(345,'harvest',2,1,57,'2025-12-30 19:33:34'),(346,'trade',2,1,59,'2025-12-30 19:33:34');
/*!40000 ALTER TABLE `rankings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seeds`
--

DROP TABLE IF EXISTS `seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seeds` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '种子名称',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '描述',
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图标路径',
  `base_price` decimal(10,2) NOT NULL COMMENT '基础购买价格',
  `price_min` decimal(10,2) NOT NULL COMMENT '最低价格',
  `price_max` decimal(10,2) NOT NULL COMMENT '最高价格',
  `growth_time` int(11) NOT NULL COMMENT '成熟时间(秒)',
  `stages` int(11) DEFAULT '5' COMMENT '生长阶段数',
  `season` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '适合季节(spring/summer/autumn/winter/all)',
  `unlock_level` int(11) DEFAULT '1' COMMENT '解锁等级',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否上架',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `rarity` int(11) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='种子表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seeds`
--

LOCK TABLES `seeds` WRITE;
/*!40000 ALTER TABLE `seeds` DISABLE KEYS */;
INSERT INTO `seeds` VALUES (1,'土豆种子','容易种植的基础作物','/crops/potato',10.00,5.00,20.00,300,5,'spring',1,1,'2025-12-30 15:38:31','2025-12-30 15:38:31',1),(2,'胡萝卜种子','营养丰富的根茎作物','/crops/carrot',15.00,8.00,30.00,360,5,'spring',1,1,'2025-12-30 15:38:31','2025-12-30 15:38:31',1),(3,'萝卜种子','生长迅速的蔬菜','/crops/radish',12.00,6.00,24.00,240,5,'spring',1,1,'2025-12-30 15:38:31','2025-12-30 15:38:31',1),(4,'洋葱种子','调味必备的蔬菜','/crops/onion',18.00,9.00,36.00,420,5,'spring',2,1,'2025-12-30 15:38:31','2025-12-30 15:38:31',1),(5,'菠菜种子','绿叶蔬菜之王','/crops/spinach',20.00,10.00,40.00,300,5,'spring',2,1,'2025-12-30 15:38:31','2025-12-30 15:38:31',1),(6,'芜菁种子','耐寒的根茎作物','/crops/turnip',14.00,7.00,28.00,360,5,'spring',3,1,'2025-12-30 15:38:31','2025-12-30 15:38:31',1),(7,'番茄种子','多汁美味的果实','/crops/tomato',25.00,12.00,50.00,480,5,'summer',5,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(8,'玉米种子','高产的粮食作物','/crops/corn',30.00,15.00,60.00,600,5,'summer',5,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(9,'小麦种子','基础粮食作物','/crops/wheat',20.00,10.00,40.00,360,5,'summer',6,1,'2025-12-30 15:38:31','2025-12-30 15:38:31',1),(10,'辣椒种子','火辣的调味作物','/crops/hot-pepper',35.00,18.00,70.00,540,5,'summer',8,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(11,'甜瓜种子','香甜的夏日水果','/crops/melon',50.00,25.00,100.00,720,5,'summer',10,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(12,'蓝莓种子','富含花青素的浆果','/crops/blueberry',45.00,22.00,90.00,660,5,'summer',10,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(13,'向日葵种子','阳光般的花朵','/crops/sunflower',40.00,20.00,80.00,480,5,'summer',12,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(14,'茄子种子','紫色的美味蔬菜','/crops/eggplant',40.00,20.00,80.00,540,5,'autumn',15,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(15,'南瓜种子','秋季代表作物','/crops/pumpkin',60.00,30.00,120.00,780,5,'autumn',15,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',3),(16,'甜菜种子','制糖原料作物','/crops/beet',35.00,18.00,70.00,480,5,'autumn',16,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(17,'蔓越莓种子','酸甜的浆果','/crops/cranberries',55.00,28.00,110.00,600,5,'autumn',18,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',3),(18,'山药种子','滋补的根茎作物','/crops/yam',50.00,25.00,100.00,660,5,'autumn',20,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',2),(19,'葡萄种子','酿酒的优质原料','/crops/grape',70.00,35.00,140.00,720,5,'autumn',22,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',3),(20,'朝�的种子','药用价值高的作物','/crops/artichoke',65.00,32.00,130.00,600,5,'autumn',24,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',3),(21,'草莓种子','鲜甜的人气水果','/crops/strawberry',80.00,40.00,160.00,480,5,'spring',25,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',3),(22,'咖啡豆种子','提神醒脑的作物','/crops/coffee-bean',100.00,50.00,200.00,900,5,'all',28,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',3),(23,'菠萝种子','热带风情水果','/crops/pineapple',120.00,60.00,240.00,1080,5,'summer',30,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',4),(24,'杨星果种子','神秘的星形水果','/crops/starfruit',150.00,75.00,300.00,1200,5,'summer',35,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',4),(25,'远古果实种子','传说中的古老作物','/crops/ancient-fruit',200.00,100.00,400.00,1440,5,'all',40,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',4),(26,'甜宝石浆果种子','极其稀有的作物','/crops/sweet-gem-berry',500.00,250.00,1000.00,1800,5,'autumn',50,1,'2025-12-30 15:38:31','2025-12-30 17:31:29',5);
/*!40000 ALTER TABLE `seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_orders`
--

DROP TABLE IF EXISTS `stock_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `stock_id` bigint(20) unsigned NOT NULL,
  `order_type` enum('buy','sell','long_open','long_close','short_open','short_close') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单类型',
  `leverage` int(11) DEFAULT '1' COMMENT '杠杆倍数(现货为1)',
  `shares` bigint(20) NOT NULL COMMENT '股数',
  `price` decimal(10,2) NOT NULL COMMENT '成交价',
  `total_amount` decimal(20,2) NOT NULL COMMENT '总金额',
  `margin` decimal(20,2) DEFAULT '0.00' COMMENT '保证金',
  `profit` decimal(20,2) DEFAULT '0.00' COMMENT '盈亏(平仓时)',
  `position_id` bigint(20) unsigned DEFAULT NULL COMMENT '关联仓位ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_stock` (`stock_id`),
  CONSTRAINT `stock_orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `stock_orders_ibfk_2` FOREIGN KEY (`stock_id`) REFERENCES `stocks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='股票交易记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_orders`
--

LOCK TABLES `stock_orders` WRITE;
/*!40000 ALTER TABLE `stock_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_prices`
--

DROP TABLE IF EXISTS `stock_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_prices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stock_id` bigint(20) unsigned NOT NULL,
  `price` decimal(10,2) NOT NULL COMMENT '收盘价',
  `open_price` decimal(10,2) DEFAULT NULL COMMENT '开盘价',
  `high_price` decimal(10,2) DEFAULT NULL COMMENT '最高价',
  `low_price` decimal(10,2) DEFAULT NULL COMMENT '最低价',
  `volume` bigint(20) DEFAULT '0' COMMENT '成交量',
  `amount` decimal(20,2) DEFAULT '0.00' COMMENT '成交额',
  `period_type` enum('1m','5m','15m','1h','1d') COLLATE utf8mb4_unicode_ci DEFAULT '1m' COMMENT '周期类型',
  `recorded_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_stock_time` (`stock_id`,`period_type`,`recorded_at`),
  CONSTRAINT `stock_prices_ibfk_1` FOREIGN KEY (`stock_id`) REFERENCES `stocks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='股票价格历史';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_prices`
--

LOCK TABLES `stock_prices` WRITE;
/*!40000 ALTER TABLE `stock_prices` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_rankings`
--

DROP TABLE IF EXISTS `stock_rankings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_rankings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `rank_type` enum('assets','profit','profit_rate','win_rate','shares') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '排行类型',
  `stock_id` bigint(20) unsigned DEFAULT NULL COMMENT '股票ID(持股排行用)',
  `user_id` bigint(20) unsigned NOT NULL,
  `rank_position` int(11) NOT NULL COMMENT '排名',
  `score` decimal(20,4) NOT NULL COMMENT '分数',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type_stock_user` (`rank_type`,`stock_id`,`user_id`),
  KEY `idx_type_rank` (`rank_type`,`stock_id`,`rank_position`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `stock_rankings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='股票排行榜';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_rankings`
--

LOCK TABLES `stock_rankings` WRITE;
/*!40000 ALTER TABLE `stock_rankings` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_rankings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stocks`
--

DROP TABLE IF EXISTS `stocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stocks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '股票代码',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '股票名称',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '描述',
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图标',
  `base_price` decimal(10,2) NOT NULL COMMENT '基准价格',
  `current_price` decimal(10,2) NOT NULL COMMENT '当前价格',
  `open_price` decimal(10,2) DEFAULT NULL COMMENT '开盘价',
  `high_price` decimal(10,2) DEFAULT NULL COMMENT '最高价',
  `low_price` decimal(10,2) DEFAULT NULL COMMENT '最低价',
  `close_price` decimal(10,2) DEFAULT NULL COMMENT '收盘价',
  `price_min` decimal(10,2) NOT NULL COMMENT '历史最低',
  `price_max` decimal(10,2) NOT NULL COMMENT '历史最高',
  `total_shares` bigint(20) NOT NULL COMMENT '总股本',
  `available_shares` bigint(20) NOT NULL COMMENT '流通股本',
  `today_volume` bigint(20) DEFAULT '0' COMMENT '今日成交量',
  `today_amount` decimal(20,2) DEFAULT '0.00' COMMENT '今日成交额',
  `volatility` decimal(5,2) DEFAULT '0.10' COMMENT '波动系数',
  `max_leverage` int(11) DEFAULT '10' COMMENT '最大杠杆倍数',
  `trend` enum('up','down','stable') COLLATE utf8mb4_unicode_ci DEFAULT 'stable' COMMENT '趋势',
  `change_percent` decimal(10,4) DEFAULT '0.0000' COMMENT '涨跌幅',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否上市',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='股票定义表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stocks`
--

LOCK TABLES `stocks` WRITE;
/*!40000 ALTER TABLE `stocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `stocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trade_logs`
--

DROP TABLE IF EXISTS `trade_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trade_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `trade_type` enum('buy','sell','auction','transfer','gift') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '交易类型',
  `item_type` enum('seed','crop','tool','material') COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL COMMENT '单价',
  `total_price` decimal(20,2) NOT NULL COMMENT '总价',
  `target_user_id` bigint(20) unsigned DEFAULT NULL COMMENT '交易对象',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_time` (`created_at`),
  CONSTRAINT `trade_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交易记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trade_logs`
--

LOCK TABLES `trade_logs` WRITE;
/*!40000 ALTER TABLE `trade_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `trade_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_achievements`
--

DROP TABLE IF EXISTS `user_achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_achievements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `achievement_id` bigint(20) unsigned NOT NULL,
  `progress` int(11) DEFAULT '0' COMMENT '当前进度',
  `is_completed` tinyint(1) DEFAULT '0',
  `is_claimed` tinyint(1) DEFAULT '0' COMMENT '是否领取奖励',
  `completed_at` datetime DEFAULT NULL,
  `claimed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_achievement` (`user_id`,`achievement_id`),
  KEY `achievement_id` (`achievement_id`),
  CONSTRAINT `user_achievements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_achievements_ibfk_2` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户成就表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_achievements`
--

LOCK TABLES `user_achievements` WRITE;
/*!40000 ALTER TABLE `user_achievements` DISABLE KEYS */;
INSERT INTO `user_achievements` VALUES (1,2,18,1,0,0,NULL,NULL),(2,2,16,0,0,0,NULL,NULL),(3,2,17,0,0,0,NULL,NULL),(4,2,19,100,1,0,'2025-12-30 18:59:58',NULL),(5,2,20,100,1,0,'2025-12-30 18:59:58',NULL),(6,2,5,100,1,0,'2025-12-30 19:16:54',NULL),(7,2,6,100,1,0,'2025-12-30 19:16:54',NULL),(8,2,1,100,1,0,'2025-12-30 19:17:05',NULL),(9,2,2,100,1,0,'2025-12-30 19:17:08',NULL);
/*!40000 ALTER TABLE `user_achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_farms`
--

DROP TABLE IF EXISTS `user_farms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_farms` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `slot_index` int(11) NOT NULL COMMENT '农田格子索引',
  `seed_id` bigint(20) unsigned DEFAULT NULL COMMENT '种植的种子ID',
  `planted_at` datetime DEFAULT NULL COMMENT '种植时间',
  `stage` int(11) DEFAULT '0' COMMENT '当前生长阶段',
  `status` enum('empty','growing','mature','withered') COLLATE utf8mb4_unicode_ci DEFAULT 'empty' COMMENT '状态',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_slot` (`user_id`,`slot_index`),
  KEY `seed_id` (`seed_id`),
  CONSTRAINT `user_farms_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_farms_ibfk_2` FOREIGN KEY (`seed_id`) REFERENCES `seeds` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户农田表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_farms`
--

LOCK TABLES `user_farms` WRITE;
/*!40000 ALTER TABLE `user_farms` DISABLE KEYS */;
INSERT INTO `user_farms` VALUES (1,2,3,1,'2025-12-30 19:34:30',2,'growing','2025-12-30 16:50:49','2025-12-30 19:37:10'),(2,2,2,1,'2025-12-30 19:34:31',2,'growing','2025-12-30 16:51:04','2025-12-30 19:37:10'),(3,2,1,1,'2025-12-30 19:34:32',2,'growing','2025-12-30 17:10:10','2025-12-30 19:37:10'),(4,2,7,1,'2025-12-30 19:34:29',2,'growing','2025-12-30 17:33:25','2025-12-30 19:37:10'),(5,2,6,1,'2025-12-30 19:34:28',2,'growing','2025-12-30 17:33:27','2025-12-30 19:37:10'),(6,2,5,1,'2025-12-30 19:34:27',2,'growing','2025-12-30 17:33:28','2025-12-30 19:37:10'),(7,2,4,1,'2025-12-30 19:34:24',2,'growing','2025-12-30 17:33:33','2025-12-30 19:37:10'),(8,2,9,1,'2025-12-30 19:34:26',2,'growing','2025-12-30 17:33:37','2025-12-30 19:37:10'),(9,2,8,1,'2025-12-30 19:34:25',2,'growing','2025-12-30 17:33:38','2025-12-30 19:37:10'),(10,2,0,1,'2025-12-30 19:34:23',2,'growing','2025-12-30 17:35:18','2025-12-30 19:37:10');
/*!40000 ALTER TABLE `user_farms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_inventory`
--

DROP TABLE IF EXISTS `user_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_inventory` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `item_type` enum('seed','crop','tool','material') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品类型',
  `item_id` bigint(20) unsigned NOT NULL COMMENT '物品ID',
  `quantity` int(11) DEFAULT '0' COMMENT '数量',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_item` (`user_id`,`item_type`,`item_id`),
  CONSTRAINT `user_inventory_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户仓库表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_inventory`
--

LOCK TABLES `user_inventory` WRITE;
/*!40000 ALTER TABLE `user_inventory` DISABLE KEYS */;
INSERT INTO `user_inventory` VALUES (1,1,'seed',1,1,'2025-12-30 16:01:50','2025-12-30 16:01:50'),(2,2,'seed',1,4,'2025-12-30 16:22:09','2025-12-30 19:34:32'),(3,2,'crop',1,20,'2025-12-30 16:58:37','2025-12-30 19:34:22'),(4,2,'seed',2,0,'2025-12-30 17:12:21','2025-12-30 18:14:40'),(5,2,'seed',8,0,'2025-12-30 19:17:01','2025-12-30 19:23:37');
/*!40000 ALTER TABLE `user_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_leverage_positions`
--

DROP TABLE IF EXISTS `user_leverage_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_leverage_positions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `stock_id` bigint(20) unsigned NOT NULL,
  `position_type` enum('long','short') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '做多/做空',
  `leverage` int(11) NOT NULL COMMENT '杠杆倍数',
  `shares` bigint(20) NOT NULL COMMENT '持仓数量',
  `entry_price` decimal(10,2) NOT NULL COMMENT '开仓价格',
  `margin` decimal(20,2) NOT NULL COMMENT '保证金',
  `liquidation_price` decimal(10,2) NOT NULL COMMENT '强平价格',
  `unrealized_profit` decimal(20,2) DEFAULT '0.00' COMMENT '未实现盈亏',
  `status` enum('open','closed','liquidated') COLLATE utf8mb4_unicode_ci DEFAULT 'open' COMMENT '状态',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `closed_at` datetime DEFAULT NULL COMMENT '平仓时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `stock_id` (`stock_id`),
  CONSTRAINT `user_leverage_positions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_leverage_positions_ibfk_2` FOREIGN KEY (`stock_id`) REFERENCES `stocks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户杠杆仓位表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_leverage_positions`
--

LOCK TABLES `user_leverage_positions` WRITE;
/*!40000 ALTER TABLE `user_leverage_positions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_leverage_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_stats`
--

DROP TABLE IF EXISTS `user_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_stats` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `total_planted` int(11) DEFAULT '0' COMMENT '总种植次数',
  `total_harvested` int(11) DEFAULT '0' COMMENT '总收获次数',
  `total_sold` int(11) DEFAULT '0' COMMENT '总售出数量',
  `total_bought` int(11) DEFAULT '0' COMMENT '总购买数量',
  `total_gold_earned` decimal(20,2) DEFAULT '0.00' COMMENT '总赚取金币',
  `total_gold_spent` decimal(20,2) DEFAULT '0.00' COMMENT '总花费金币',
  `total_friends` int(11) DEFAULT '0' COMMENT '好友数量',
  `total_stolen` int(11) DEFAULT '0' COMMENT '偷菜次数',
  `login_days` int(11) DEFAULT '0' COMMENT '登录天数',
  `consecutive_days` int(11) DEFAULT '0' COMMENT '连续登录天数',
  `last_login_date` date DEFAULT NULL COMMENT '最后登录日期',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `contribution_points` int(11) DEFAULT '0' COMMENT '贡献点数',
  `achievement_points` int(11) DEFAULT '0' COMMENT '成就点数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `user_stats_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户统计表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_stats`
--

LOCK TABLES `user_stats` WRITE;
/*!40000 ALTER TABLE `user_stats` DISABLE KEYS */;
INSERT INTO `user_stats` VALUES (1,2,76,61,59,11,1362.44,299.75,0,0,1,1,'2025-12-30','2025-12-30 17:53:57','2025-12-30 19:34:32',610,45);
/*!40000 ALTER TABLE `user_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_stock_stats`
--

DROP TABLE IF EXISTS `user_stock_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_stock_stats` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `total_assets` decimal(20,2) DEFAULT '0.00' COMMENT '股票总资产',
  `total_profit` decimal(20,2) DEFAULT '0.00' COMMENT '累计盈亏',
  `total_profit_rate` decimal(10,4) DEFAULT '0.0000' COMMENT '累计收益率',
  `today_profit` decimal(20,2) DEFAULT '0.00' COMMENT '今日盈亏',
  `today_profit_rate` decimal(10,4) DEFAULT '0.0000' COMMENT '今日收益率',
  `win_count` int(11) DEFAULT '0' COMMENT '盈利次数',
  `lose_count` int(11) DEFAULT '0' COMMENT '亏损次数',
  `win_rate` decimal(5,2) DEFAULT '0.00' COMMENT '胜率',
  `max_profit` decimal(20,2) DEFAULT '0.00' COMMENT '单笔最大盈利',
  `max_loss` decimal(20,2) DEFAULT '0.00' COMMENT '单笔最大亏损',
  `trade_count` int(11) DEFAULT '0' COMMENT '交易次数',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `user_stock_stats_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户股票统计表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_stock_stats`
--

LOCK TABLES `user_stock_stats` WRITE;
/*!40000 ALTER TABLE `user_stock_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_stock_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_stocks`
--

DROP TABLE IF EXISTS `user_stocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_stocks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `stock_id` bigint(20) unsigned NOT NULL,
  `shares` bigint(20) NOT NULL DEFAULT '0' COMMENT '持有股数',
  `avg_cost` decimal(10,2) NOT NULL COMMENT '平均成本',
  `total_cost` decimal(20,2) NOT NULL COMMENT '总成本',
  `realized_profit` decimal(20,2) DEFAULT '0.00' COMMENT '已实现盈亏',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_stock` (`user_id`,`stock_id`),
  KEY `stock_id` (`stock_id`),
  CONSTRAINT `user_stocks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_stocks_ibfk_2` FOREIGN KEY (`stock_id`) REFERENCES `stocks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户现货持仓表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_stocks`
--

LOCK TABLES `user_stocks` WRITE;
/*!40000 ALTER TABLE `user_stocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_stocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `linuxdo_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'LinuxDo用户ID',
  `charity_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '公益站ID',
  `nickname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL',
  `level` int(11) DEFAULT '1' COMMENT '等级',
  `gold` decimal(20,2) DEFAULT '1000.00' COMMENT '金币',
  `farm_slots` int(11) DEFAULT '4' COMMENT '农田格子数量',
  `contribution` int(11) DEFAULT '0' COMMENT '贡献值',
  `achievement_points` int(11) DEFAULT '0' COMMENT '成就点数',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `linuxdo_id` (`linuxdo_id`),
  KEY `idx_linuxdo_id` (`linuxdo_id`),
  KEY `idx_charity_id` (`charity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'1995','','1995','',1,990.00,4,0,0,'2025-12-30 16:00:26','2025-12-30 16:01:50'),(2,'1996','','1996','',6,2977.70,10,883,47,'2025-12-30 16:07:29','2025-12-30 19:34:22');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-30 19:40:17
