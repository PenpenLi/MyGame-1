--
-- Author: johnny@boomegg.com
-- Date: 2014-07-16 17:00:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

consts = consts or {}


--hall server错误定义
consts.SVR_ERROR = {}
local codes = consts.SVR_ERROR
codes.ERROR_CONNECT_FAILURE = 100 --连接失败
codes.ERROR_HEART_TIME_OUT  = 101 --心跳包超时
codes.ERROR_LOGIN_TIME_OUT  = 102 --登录超时

-- 登录失败原因代码
consts.SVR_LOGIN_FAIL_CODE = {}
codes = consts.SVR_LOGIN_FAIL_CODE
codes.INVALID_MTKEY        = 0x9001 --错误的mtkey
codes.USER_BANNED          = 0x9002 --用户被禁
codes.ROOM_ERR             = 0x9003 --登录桌子错误
codes.ROOM_FULL            = 0x9004 --房间旁观人数到达上限
codes.RECONN_TO_OTHER_ROOM = 0x9005 --重连进入不同的桌子
codes.SOMEONE_ELSE_RELOGIN = 0x9006 --账号被其他人登陆了
codes.MIN_USER_LEVEL_LIMIT = 0x9007 --等级不够
codes.SERVER_STOPPED       = 0x9008 --停服标志
codes.KICKED               = 0x9009 --被踢出
codes.WRONG_PASSWORD       = 0x810A --密码错误
codes.ROOM_NOT_EXISTS      = 0x810B --房间不存在


-- 下注失败原因代码
consts.SVR_BET_FAIL_CODE = {}
codes = consts.SVR_BET_FAIL_CODE
codes.WRONG_STATE    = 0x9301 --游戏状态错误
codes.NOT_YOUR_TURN  = 0x9302 --还没轮到用户下注
codes.NOT_IN_GAME    = 0x9303 --用户没有参与本轮游戏
codes.CANNOT_CHECK   = 0x9304 --不能看牌，有人加注了
codes.WRONG_BET_TYPE = 0x9305 --错误的下注类型
codes.PRE_BET        = 0x9306 --提前下注（开始server强行每个用户下相同数额的筹码数）

--赠送筹码失败原因代码
consts.SVR_SEND_CHIPS_FAIL_CODE = {}
codes = consts.SVR_SEND_CHIPS_FAIL_CODE
codes.NOT_ENOUGH_CHIPS     = 0x9401 --钱数不够，不能赠送
codes.TOO_OFTEN         = 0x9402 --太频繁
codes.TOO_MANY             = 0x9403 --太多了

-- 操作类型
consts.SVR_BET_STATE = {}
local states = consts.SVR_BET_STATE
states.USER_STATE_READY 			= 0			--准备,等待状态,(坐下，其他人在玩牌)
states.USER_STATE_CEKPOKER          = 1			--已经选择看牌 
states.USER_STATE_CALL          	= 2			--已经选择跟注 
states.USER_STATE_LKUT          	= 3			--已经选择加注 
states.USER_STATE_GIVEUP            = 4			--已经选择弃牌
states.USER_STATE_ALLIN          	= 5			--已经allin 
states.USER_STATE_CHOICE          	= 6			--正在选择 
states.USER_STATE_WAITOTHER         = 7			--等待其它人选择
states.USER_STATE_STAND          	= 8			--站立围观状态(服务器用)


-- 玩家状态类型
consts.SVR_USER_STATE = {}
local states = consts.SVR_USER_STATE
states.USER_STATE_NOTGAME 			= 0			--未参加游戏
states.USER_STATE_GAMEING 			= 1			--游戏中

states.USER_STATE_INSEAT 			= false			--玩家是否坐下  true:坐下 false:站起

-- 房间状态类型
consts.SVR_GAME_STATUS = {}
states = consts.SVR_GAME_STATUS
states.GAME_STOP       		= 0 	--停止
states.GAME_RUNING       	= 1 	--游戏中

consts.SVR_GAME_STATUS_QIUQIU = {}
states = consts.SVR_GAME_STATUS_QIUQIU
states.TABLE_CLOSE       		= 0 	--关闭状态, 桌子上无人
states.TABLE_OPEN    	 		= 1    --桌子上有人，但人数不够开局，比如说一个人
states.TABLE_READY       		= 2	--满开局人数条件后，2s后开始游戏
states.TABLE_BET_ROUND   		= 3	--三张牌加注状态
states.TABLE_BET_ROUND_4card    = 4	--四张牌加注状态
states.TABLE_CHECK    			= 5 	--确认点数组合状态,结算前玩家调整牌组合
states.TABLE_GAME_OVER    			= 6 	--结算状态 , 结算时，更新金币信息，此状态前端用不上
states.TABLE_GAME_OVER_SHARE_BONUS  = 7 	--结算时，亮牌，分奖池

-- 房间打牌操作类型
consts.CLI_BET_TYPE = {}
local types = consts.CLI_BET_TYPE
types.PASS = 0    -- 过
types.SEND  = 1   -- 出牌

consts.CLI_BET_TYPE_QIUQIU = {}
local types = consts.CLI_BET_TYPE_QIUQIU
types.CHECK = 0
types.FOLD  = 1
types.CALL  = 2
types.RAISE = 3


-- 房间类型
consts.ROOM_TYPE = {}
types = consts.ROOM_TYPE
types.NORMAL     = 1 -- 普通场
types.PRO        = 2 -- 专业场
types.TOURNAMENT = 3 -- 锦标赛
types.KNOCKOUT   = 4 -- 淘汰赛
types.PROMOTION  = 5 -- 晋级赛

consts.CARD_TYPE = {}
types = consts.CARD_TYPE
types.SPECIAL_SINGLE       = 0 --单倍
types.SPECIAL_DOUBLE       = 0 --双倍
types.SPECIAL_TRIPLE       = 0 --三倍
types.SPECIAL_QUARTET       = 0 --四倍
types.SPECIAL_DEADEND       = 0 --死路

consts.CARD_TYPE_QIUQIU = {}
types = consts.CARD_TYPE_QIUQIU
types.SPECIAL_NONE       = 0 --无
types.SPECIAL_SIX_DEVILS         = 5 --六神
types.SPECIAL_TWIN_CARDS   = 4 -- 对子
types.SPECIAL_SMALL_CARDS     = 3 -- small
types.SPECIAL_BIG_CARDS       = 2 -- big
types.SPECIAL_DOUBLE_CARDS          = 1 -- 99

consts.STATISTICS={} 						--
types=consts.STATISTICS
types.STA_H_E_INVITE			=1 				--邀请好友   
types.STA_H_E_FREE_CHIPS		=2 				--免费筹码
types.STA_H_E_DAILY_TASK		=3 				--每日任务
types.STA_H_E_EXPIRY			=4 				--兑奖
types.STA_H_E_ACTIVITY			=5 				--活动中心
types.STA_H_E_AWARD_UP_LEVEL	=6 				--升级奖励
types.STA_H_E_HALL				=7				--大厅
types.STA_H_E_PLACE_CHOISE		=100			--场次101-118
types.STA_H_E_MATCH				=9 				--比赛
types.STA_H_E_QUICK_PLAY		=10 			--快速开始
types.STA_H_E_HEAD				=11 			--头像
types.STA_H_E_SHOP				=12				--商场
types.STA_H_E_FRIEND			=13 			--好友
types.STA_H_E_RANK 				=14 			--排行
types.STA_H_E_NEWS				=15 			--消息中心
types.STA_H_E_SETTING			=16 			--设置
types.STA_H_E_SINGLE			=17 			--单机

--道具常量
consts.PROPS_ID={} 		
local props=consts.PROPS_ID
props.LABA_PROP             = 1001       --喇叭

--server广播消息类型
consts.GAME_BROADCAST_ID={} 		
props=consts.GAME_BROADCAST_ID
props.SYSTEM_MSG_ID         = 1001       --系统广播
props.SYSTEM_USER_ID        = 1002       --用户广播
props.SYSTEM_MSG_ID_NEW     = 1003       --新的系统广播

--边注玩法标记
consts.SIDECHIPS_STATUS = {} 	
props=consts.SIDECHIPS_STATUS
props.BUY_STATUS       = 0       	--0,没下注 1,下注
props.BUY_BET       = 0       		--下注金额等级
props.BUY_TYPE       = 0       	--下注牌型
props.BUY_BLIND       = 0       	--参与边注玩法的房间底注
props.CAN_SIDE       = 0       	--房间是否支持边注玩法 1:支持 0:不支持


-- 99玩法房间level
consts.QIUQIU_ROOM_LEVEL = {}
props=consts.QIUQIU_ROOM_LEVEL
props.LEVEL_MIN       = 601 
props.LEVEL_MAX       = 1000


-- 根据房间玩法区分类型
-- 离线：0，大厅：1，接龙普通房间：2，接龙私人房间：3,99普通房：4，99私人房间：5

consts.ROOM_PLAY_TYPE = {}
props=consts.ROOM_PLAY_TYPE
props.GAPLE_PLAYE = 2
props.GAPLE_PRIVATE_PLAYE = 3
props.QIUQIU_PLAYE = 4
props.QIUQIU_PRIVATE_PLAYE = 5

-- 付费场景
--[[
   [0] => 未知
   [101] => 大厅首充礼包充值
   [102] => 大厅商城充值
   [103] => 大厅破产弹框充值
   [104] => 大厅个人头像下方充值
   [105] => 大厅限时礼包充值
   [108] => 世界聊天框成为VIP
   [201] => 选场界面首充充值
   [202] => 选场界面商城充值
   [203] => 选场界面破产弹框充值
   [301] => 房间首充礼包充值
   [302] => 房间商城充值
   [303] => 房间快捷充值
   [304] => 房间个人头像下方充值
   [305] => 房间坐下金币不足充值
   [306] => 房间破产弹框充值
   [307] => 房间限时礼包充值
   [308] => 房间聊天框成为VIP

--]]
consts.PAY_SCENE = {}
consts.PAY_SCENE.UNKNOW = 0
consts.PAY_SCENE.HALL_FISRT_PAY = 101
consts.PAY_SCENE.HALL_SHOP_PAY = 102
consts.PAY_SCENE.HALL_BANKRUPTCY_PAY = 103
consts.PAY_SCENE.HALL_HEADICON_PAY = 104
consts.PAY_SCENE.HALL_LIMIT_PAY = 105
consts.PAY_SCENE.HALL_FAST_PAY = 106
consts.PAY_SCENE.HALL_LOGIN_SHOP_PAY = 107
consts.PAY_SCENE.HALL_CHAT_PAY = 108
consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_FISRT_PAY = 201
consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_SHOP_PAY = 202
consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_BANKRUPTCY_PAY = 203
consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_FAST_PAY = 204
consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_LIMIT_PAY = 205
consts.PAY_SCENE.GAPLE_ROOM_FISRT_PAY = 301
consts.PAY_SCENE.GAPLE_ROOM_SHOP_PAY = 302
consts.PAY_SCENE.GAPLE_ROOM_FAST_PAY = 303
consts.PAY_SCENE.GAPLE_ROOM_HEADICON_PAY = 304
consts.PAY_SCENE.GAPLE_ROOM_SITDOWN_PAY = 305
consts.PAY_SCENE.GAPLE_ROOM_BANKRUPTCY_PAY = 306
consts.PAY_SCENE.GAPLE_ROOM_LIMIT_PAY = 307
consts.PAY_SCENE.GAPLE_ROOM_CHAT_PAY = 308
consts.PAY_SCENE.QIUQIU_ROOM_FISRT_PAY = 401
consts.PAY_SCENE.QIUQIU_ROOM_SHOP_PAY = 402
consts.PAY_SCENE.QIUQIU_ROOM_FAST_PAY = 403
consts.PAY_SCENE.QIUQIU_ROOM_HEADICON_PAY = 404
consts.PAY_SCENE.QIUQIU_ROOM_SITDOWN_PAY = 405
consts.PAY_SCENE.QIUQIU_ROOM_BANKRUPTCY_PAY = 406
consts.PAY_SCENE.QIUQIU_ROOM_LIMIT_PAY = 407
consts.PAY_SCENE.QIUQIU_ROOM_CHAT_PAY = 408
consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_FISRT_PAY =501
consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_SHOP_PAY = 502
consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_BANKRUPTCY_PAY = 503
consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_FAST_PAY = 504
consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_LIMIT_PAY = 505
return consts