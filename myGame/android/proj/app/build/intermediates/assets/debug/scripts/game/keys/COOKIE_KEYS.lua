--
-- Author: tony
-- Date: 2014-08-24 20:45:24
--
local K = {}
local COOKIE_KEYS = K

K.AUTO_BUY_IN = "AUTO_BUY_IN"
K.AUTO_SIT = "AUTO_SIT"
K.SHOCK = "SHOCK"
K.VOLUME = "VOLUME"
K.MESSAGE = "MESSAGE"
K.PUSH = "PUSH"
K.MUSIC = "MUSIC"

K.CHANGE_SERVER				   = "CHANGE_SERVER"

K.LAST_LOGIN_TYPE              = "LAST_LOGIN_TYPE"
K.LOGIN_MTKEY                  = "LOGIN_MTKEY"
K.LOGINED_DEVICE               = "LOGINED_DEVICE"
K.USER_FIRST_DEALER_SEND_CHIP  = "USER_FIRST_DEALER_SEND_CHIP"  --用户第一次给荷官送筹码
K.FACEBOOK_ACCESS_TOKEN        = "FACEBOOK_ACCESS_TOKEN"
K.FACEBOOK_INVITED_NAMES       = "FACEBOOK_INVITED_NAMES"
K.FACEBOOK_INVITE_MONEY        = "FACEBOOK_INVITE_MONEY"
K.FACEBOOK_INVITED_PAGE        = "FACEBOOK_INVITED_PAGE"
K.RECORD_SEND_DEALER_CHIP_TIME = "RECORD_SEND_DEALER_CHIP_TIME" -- 记录给荷官送筹码的次数
K.DALIY_REPORT_INVITABLE       = "DALIY_REPORT_INVITABLE"       -- 记录每日是否已经上报能邀请的用户数
K.CONFIG_VER				   = "CONFIG_VER"					-- 配置信息版本号前缀

K.LOGIN_UIDS                   = "LOGIN_UIDS"                   -- 登录uid列表

K.DALIY_REPORT_OLDUSER_INVITED = "DALIY_REPORT_OLDUSER_INVITED" -- 记录每日使用邀请老用户的功能时间

K.GTF_GUIDE_TO_FACEBOOK        = 'GTF_GUIDE_TO_FACEBOOK'        -- 是否已经引导过facebook登录
K.GTF_CHECK_TODAY              = 'GTF_CHECK_TODAY'              -- 今天是否已经检查过
K.GTF_LOGIN_COUNT              = 'GTF_LOGIN_COUNT'              -- 使用游客登录的次数

K.TIPS_STATE                   = 'TIPS_STATE'                   -- 提示标识

K.QT_NEXT_DAY_CHIPS_TYPE       = 'QT_NEXT_DAY_CHIPS_TYPE'       -- 明天再来可以领取的奖励类型
K.QT_NEXT_DAY_CHIPS_REWARD     = 'QT_NEXT_DAY_CHIPS_REWARD'     -- 明天再来可以领取的奖励数量

K.DALIY_POPUP_INVITABLE		   = 'DALIY_POPUP_INVITABLE'		--每天第一次进大厅弹出最新活动

K.USER_GENERAL_NUMBER		   = 'USER_GENERAL_NUMBER'			--玩家玩牌总局数
K.USER_CARD_TIPS		   	   = 'USER_CARD_TIPS'				--是否已经提示过

K.SEND_ERROR_INFO_DAY		   = "SEND_ERROR_INFO_DAY"			--发送友盟错误日期
K.SEND_ERROR_INFO_NUM		   = "SEND_ERROR_INFO_NUM"			--发送友盟错误数量

K.HALL_SHOW_NEWSIGN		   	   = 'HALL_SHOW_NEWSIGN'			--大厅显示新消息提示

K.NEWER_SIGN		   	       = 'NEWER_SIGN'					--新手标记

K.PRIVATE_HIDE_FULL 		   = "PRIVATE_HIDE_FULL"			--私人房列表隐藏已满房间标记

K.SYSTEM_NOTICE_READ 		   = "SYSTEM_NOTICE_READ"			--系统消息是否已读标记  0 未读

K.MAIN_HALL_BG_PRINTSCREEN 	   = "MAIN_HALL_BG_PRINTSCREEN"		--大厅截图时间戳

K.SVR_MSG_SEND_RETIRE		   = "SVR_MSG_SEND_RETIRE"			--服务器通知退休

K.GAME_BROADCAST			   = "GAME_BROADCAST" 				--喇叭消息记录

K.FRIEND_CHAT_RECORD 	       = "FRIEND_CHAT_RECORD"		    --好友聊天记录

K.PROP_SENT_MORE_NUM		   = "PROP_SENT_MORE_NUM"			--道具多连发

K.SINGLE_REWARD_JSON		   = "SINGLEREWARD_JSON"		    --私人房奖励JSON配置URL
K.SINGLE_PLAYER_NUM		   	   = "SINGLE_PLAYER_NUM"		    --私人房参与统计(未登陆)
K.SINGLE_PLAYER_NUM_O		   = "SINGLE_PLAYER_NUM_O"		    --私人房参与统计(登陆)

K.ROOM_LEVEL 				   = "ROOM_LEVEL"		    		--房间等级

K.GUEST_BIND_FB_STATUS		   = "GUEST_BIND_FB_STATUS"			--游客帐号绑定FB状态
K.GUEST_BIND_FB_NAME		   = "GUEST_BIND_FB_NAME"			--游客帐号绑定FB账号名

return COOKIE_KEYS