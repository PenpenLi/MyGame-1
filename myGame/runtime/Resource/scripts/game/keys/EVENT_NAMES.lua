--
-- Author: tony
-- Date: 2014-07-15 19:05:10
--
local EVENT_NAMES = {}
local E = EVENT_NAMES

E.APP_ENTER_BACKGROUND = "APP_ENTER_BACKGROUND"--应用进入后台
E.APP_ENTER_FOREGROUND = "APP_ENTER_FOREGROUND"--应用恢复

E.EVENT_CLOSE_POPU = "EVENT_CLOSE_POPU"	--关闭窗口监听

E.EVENT_ADD_EDITBTNLISTENER = "EVENT_ADD_EDITBTNLISTENER"  --按钮点击事件

E.HALL_LOGIN_SUCC = "HALL_LOGIN_SUCC"
E.HALL_LOGOUT_SUCC = "HALL_LOGOUT_SUCC"
E.HALL_SHOW_MAIN_HALL = "HALL_SHOW_MAIN_HALL"
E.HALL_SHOW_CHOOSE_ROOM = "HALL_SHOW_CHOOSE_ROOM"
E.ENTER_ROOM_WITH_DATA = "ENTER_ROOM_WITH_DATA"
E.LOGIN_ROOM_SUCC = "LOGIN_ROOM_SUCC"
E.LOGIN_ROOM_FAIL = "LOGIN_ROOM_FAIL"
E.ROOM_CONN_PROBLEM = "ROOM_CONN_PROBLEM"
E.SERVER_STOPPED = "SERVER_STOPPED"
E.LOGOUT_ROOM_SUCC = "LOGOUT_ROOM_SUCC"
E.GET_COUNTDOWNBOX_REWARD = "GET_COUNTDOWNBOX_REWARD"
E.ENTER_ROOM_BY_TASK = "ENTER_ROOM_BY_TASK" --任务跳转房间
E.ENTER_ROOM_BY_RANK = "ENTER_ROOM_BY_RANK" --排行跳转房间
E.USER_CRASH_BANKRUPT = "USER_CRASH_BANKRUPT"	--破产弹窗先弹邀请弹窗，再弹破产补助
E.HALL_LOGOUT_QUICK_START = "HALL_LOGOUT_QUICK_START"	--大厅退出弹框跳转快速开始
E.HALL_ACVITY_NUM = "HALL_ACVITY_NUM"	--活动个数获取后分发
E.HALL_ACTIVITY_TO_ROOM = "HALL_ACTIVITY_TO_ROOM"	--活动回调调整开始游戏
E.HALL_EVENT_BACK = "HALL_EVENT_BACK"	--大厅回退键监听

E.UI_TAB_CHANGE = "UI_TAB_CHANGE"

E.ROOM_DEALE_RPROP = "ROOM_DEALE_RPROP"	--向荷官发送道具
E.ROOM_99_TOUCHLAYER_TOUCH = "ROOM_99_TOUCHLAYER_TOUCH" --触摸99房间的touchLayer
E.ROOM_LOAD_HDDJ_NUM = "ROOM_LOAD_HDDJ_NUM"
E.ROOM_REFRESH_HDDJ_NUM = "ROOM_REFRESH_HDDJ_NUM"

E.SEND_DEALER_CHIP_BUBBLE_VIEW = "SEND_DEALER_CHIP_BUBBLE_VIEW"
E.SVR_BROADCAST_ACT_STATE = "SVR_BROADCAST_ACT_STATE" --活动完成

E.OPEN_BANK_POPUP_VIEW = "OPEN_BANK_POPUP_VIEW"
E.SHOW_EXIST_PASSWORD_ICON = "SHOW_EXIST_PASSWORD_ICON"

E.NEW_TASK_OR_MESSAGE = "NEW_TASK_OR_MESSAGE"

E.SLOT_BUY_RESULT = "SLOT_BUY_RESULT"
E.SLOT_PLAY_RESULT = "SLOT_PLAY_RESULT"

E.SVR_BROADCAST_BIG_LABA = "SVR_BROADCAST_BIG_LABA" --大喇叭消息

E.HIDE_GIFT_POPUP = "HIDE_GIFT_POPUP" --关闭礼物弹框
E.GET_CUR_SELECT_GIFT_ID = "GET_CUR_SELECT_GIFT_ID" --获取当前礼物ID

E.UPDATE_CUR_SELECT_GIFT_ID = "UPDATE_CUR_SELECT_GIFT_ID" --跟新礼物ID

E.DOUBLE_LOGIN_LOGINOUT = "DOUBLE_LOGIN_LOGINOUT" -- 账号同时登录时退出消息

E.SVR_SEND_FRIEND_CHAT_MSG_RETUEN = "SVR_SEND_FRIEND_CHAT_MSG_RETUEN" -- 发送好友消息返回
E.SVR_REC_FRIEND_CHAT_MSG  = "SVR_REC_FRIEND_CHAT_MSG"       --接受好友消息
E.SVR_REC_FRIEND_MSG_IN_CHATPOPUP  = "SVR_REC_FRIEND_MSG_INCHAT_POPUP"       --接受好友消息
E.SVR_REC_FRIEND_MSG_IN_HALL  = "SVR_REC_FRIEND_MSG_IN_HALL"       --接受好友消息
E.SVR_GET_NO_READ_MSG_RETURN  = "SVR_GET_NO_READ_MSG_RETURN"       --拉取未读消息
E.REFRESH_FRIEND_ONLINE_STATUS  = "REFRESH_FRIEND_ONLINE_STATUS"       --刷新好友在线状态
E.CHAT_OPERTATION_HIDE_UNREAD_POINT = "CHAT_OPERTATION_HIDE_UNREAD_POINT"  --隐藏桌面聊天按钮红点
E.SHOW_RECOMMEND_FRIENDS = "SHOW_RECOMMEND_FRIENDS"  --显示推荐好友
E.REFRESH_FRIENDS_NUM = "REFRESH_FRIENDS_NUM"  --刷新好友数量
E.REFRESH_FRIENDS_LIST = "REFRESH_FRIENDS_LIST"  --刷新好友列表

E.REFRESH_BROADCAST_LIST = "REFRESH_BROADCAST_LIST"  --刷新喇叭消息列表

E.REFRESH_SIDECHIPS_STATUS = "REFRESH_SIDECHIPS_STATUS"  --刷新边注玩法 下注状态
E.REFRESH_SIDECHIPS_RECORD_LIST = "REFRESH_SIDECHIPS_RECORD_LIST"  -- 刷新边注玩法 获奖记录

-- HallServer
E.SVR_DOUBLE_LOGIN = "SVR_DOUBLE_LOGIN"
E.SVR_LOGIN_OK = "SVR_LOGIN_OK"
E.SVR_HALL_LOGIN_FAIL = "SVR_LOGIN_HALL_FAIL"
E.SVR_ONLINE = "SVR_ONLINE"
E.SVR_GET_ROOM_OK = "SVR_GET_ROOM_OK"
E.SVR_GET_ROOM_FAIL = "SVR_GET_ROOM_FAIL"

E.SVR_CREATE_PRIVATE_RES = "SVR_CREATE_PRIVATE_RES"	--创建私人房回复
E.SVR_JOIN_PRIVATE_RES = "SVR_JOIN_PRIVATE_RES"	--加入私人房回复
E.SVR_PRIVATE_LIST_RES = "SVR_PRIVATE_LIST_RES"	--创建私人房回复
E.SVR_PRIVATE_SEARCH_RES = "SVR_PRIVATE_SEARCH_RES"	--查找私人房回复

E.SVN_TABLE_SYNC="SVN_TABLE_SYNC"

E.SVR_TRANCE_FRIEND_OK="SVR_TRANCE_FRIEND_OK"

E.SVR_LOGIN_ROOM_OK = "SVR_LOGIN_ROOM_OK"
E.SVR_RE_LOGIN_ROOM_OK = "SVR_RE_LOGIN_ROOM_OK"
-- E.SVR_GET_ROOM_OK="SVR_GET_ROOM_OK"
E.SVR_LOGIN_ROOM_FAIL = "SVR_LOGIN_ROOM_FAIL"
E.SVR_LOGOUT_ROOM_OK = "SVR_LOGOUT_ROOM_OK"
E.SVR_SEAT_DOWN = "SVR_SEAT_DOWN"
E.SVR_STAND_UP = "SVR_STAND_UP"
E.SVR_MSG = "SVR_MSG"
E.SVR_DEAL = "SVR_DEAL"
E.SVR_LOGIN_ROOM = "SVR_LOGIN_ROOM"
E.SVR_LOGOUT_ROOM = "SVR_LOGOUT_ROOM"
E.SVR_SELF_SEAT_DOWN_OK = "SVR_SELF_SEAT_DOWN_OK"
E.SVR_OTHER_STAND_UP = "SVR_OTHER_STAND_UP"
E.SVR_OTHER_OFFLINE = "SVR_OTHER_OFFLINE"
E.SVR_GAME_START = "SVR_GAME_START"
E.SVR_GAME_OVER = "SVR_GAME_OVER"
E.SVR_NEXT_BET = "SVR_NEXT_BET"
E.SVR_BOARDCAST_CONFIRM_CARD = "SVR_BOARDCAST_CONFIRM_CARD"
E.SVR_BACK_CHANGE_CARDS = "SVR_BACK_CHANGE_CARDS"
E.SVR_KICK_OUT_ROOM = "SVR_KICK_OUT"
E.SVR_CAN_OTHER_CARD = "SVR_CAN_OTHER_CARD"
E.SVR_SHOW_CARD = "SVR_SHOW_CARD"
E.SVR_ERROR = "SVR_ERROR"
E.SVR_SIDECHIPS_SETBET_RETURN = "SVR_SIDECHIPS_SETBET_RETURN"
E.SVR_SIDECHIPS_CANCLE_RETURN = "SVR_SIDECHIPS_CANCLE_RETURN"
E.SVR_SIDECHIPS_RESULT = "SVR_SIDECHIPS_RESULT"
E.SVR_ROOM_BROADCAST = "SVR_ROOM_BROADCAST"
E.SVR_COMMON_BROADCAST = "SVR_COMMON_BROADCAST"
E.SVR_HALL_BROADCAST_MGS = "SVR_HALL_BROADCAST_MGS"

E.FREE_CHIP_GET_LEVEL_UP_REWARD = "FREE_CHIP_GET_LEVEL_UP_REWARD"  -- 成功领取升级奖励
E.FREE_CHIP_CAN_GET_REWARD_NUM = "FREE_CHIP_CAN_GET_REWARD_NUM"  -- 可以领取奖励的任务数

-- _QIUQIU

E.SVR_LOGIN_ROOM_QIUQIU_OK = "SVR_LOGIN_ROOM_QIUQIU_OK"
E.SVR_LOGIN_ROOM_QIUQIU_FAIL = "SVR_LOGIN_ROOM_QIUQIU_FAIL"
E.SVR_SELF_SEAT_DOWN_QIUQIU_OK = "SVR_SELF_SEAT_DOWN_QIUQIU_OK"
E.SVR_SEAT_DOWN_QIUQIU = "SVR_SEAT_DOWN_QIUQIU"
E.SVR_GAME_START_QIUQIU = "SVR_GAME_START_QIUQIU"
E.SVR_STAND_UP_QIUQIU = "SVR_STAND_UP_QIUQIU"
E.SVN_AUTO_ADD_MIN_CHIPS="SVN_AUTO_ADD_MIN_CHIPS"
E.SVR_OTHER_STAND_UP_QIUQIU = "SVR_OTHER_STAND_UP_QIUQIU"
E.SVR_NEXT_BET_QIUQIU = "SVR_NEXT_BET_QIUQIU"
E.SVR_SET_BET_QIUQIU = "SVR_SET_BET_QIUQIU"
E.SVR_BET_QIUQIU = "SVR_BET_QIUQIU"
E.SVR_OTHER_OFFLINE_QIUQIU = "SVR_OTHER_OFFLINE_QIUQIU"
E.SVR_CONFIRM_CARDS_STAGE = "SVR_CONFIRM_CARDS_STAGE"
E.SVN_TABLE_SYNC_QIUQIU="SVN_TABLE_SYNC_QIUQIU"
E.SVR_RECEIVE_FOURTH_CARD = "SVR_RECEIVE_FOURTH_CARD"
E.SVR_GAME_OVER_QIUQIU = "SVR_GAME_OVER_QIUQIU"
E.SVR_KICK_OUT_QIUQIU = "SVR_KICK_OUT_QIUQIU"
E.SVR_LOGOUT_ROOM_OK_QIUQIU = "SVR_LOGOUT_ROOM_OK_QIUQIU"



--新手引导事件
E.ROOM_GUIDE_SHOW_SIT_HERE = "ROOM_GUIDE_SHOW_SIT_HERE"
E.ROOM_GUIDE_HIDE_SIT_HERE = "ROOM_GUIDE_HIDE_SIT_HERE"

E.ROOM_GUIDE_SHOW_MAKE_OPERATION = "ROOM_GUIDE_SHOW_MAKE_OPERATION"
E.ROOM_GUIDE_HIDE_MAKE_OPERATION = "ROOM_GUIDE_HIDE_MAKE_OPERATION"

E.ROOM_GUIDE_SHOW_AUTO_CALL_ANY = "ROOM_GUIDE_SHOW_AUTO_CALL_ANY"
E.ROOM_GUIDE_HIDE_AUTO_CALL_ANY = "ROOM_GUIDE_HIDE_AUTO_CALL_ANY"

E.ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD = "ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD"
E.ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD = "ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD"

E.ROOM_GUIDE_SHOW_AUTO_CALL = "ROOM_GUIDE_SHOW_AUTO_CALL"
E.ROOM_GUIDE_HIDE_AUTO_CALL = "ROOM_GUIDE_HIDE_AUTO_CALL"

E.ROOM_GUIDE_SHOW_SEND_BROADCAST = "ROOM_GUIDE_SHOW_SEND_BROADCAST"
E.ROOM_GUIDE_HIDE_SEND_BROADCAST = "ROOM_GUIDE_HIDE_SEND_BROADCAST"

E.ROOM_GUIDE_HIDE_ALL = "ROOM_GUIDE_HIDE_ALL"
E.ROOM_GUIDE_HIDE_OPERATION_BAR = "ROOM_GUIDE_HIDE_OPERATION_BAR"

----------------------单机

E.SINGLE_ROOM_GAME_NUM = "SINGLE_ROOM_GAME_NUM"
E.SINGLE_ROOM_GET_BANKRUPT = "SINGLE_ROOM_GET_BANKRUPT"
E.SINGLE_ROOM_SAVE_DATA = "SINGLE_ROOM_SAVE_DATA"
E.SINGLE_ROOM_BAD_NETWORK = "SINGLE_ROOM_BAD_NETWORK"
E.SINGLE_ROOM_BANKRUPT_FINISH = "SINGLE_ROOM_BANKRUPT_FINISH"
-----------------------新手引导事件 END

-- _QIUQIU

E.SVR_HALL_ERROR = "SVR_HALL_ERROR" -- 服务器错误，返回错误类型

E.SVR_PLAYER_STATUS_RESPONSE = "SVR_PLAYER_STATUS_RESPONSE"

E.PLAYER_STATUS_ISSUPPORT = "PLAYER_STATUS_ISSUPPORT"
-- HallController里面的的事件TAG
E.HALL_CONTROLLER_EVENT_TAG = 2000

-- PrivateRoomView里面的时间TAG
E.PRIVATE_ROOM_EVENT_TAG = 2001

E.PRIVATE_ENTER_ROOM_POPUP_EVENT_TAG = 2002

E.RANKING_EVENT_TAG = 2003

E.SINGLE_ROOM_EVENT_TAG = 2004

E.ROOM_99_EVENT_TAG = 2005

-- 以下是从99那边拷贝的（接龙没有的），不一定会用到

E.QUICK_PAY_SUCC="QUICK_PAY_SUCC"

E.ROOM_HIDE_SEAT_TIPS="ROOM_HIDE_SEAT_TIPS"

E.ACTIVITY_MESSAGE="ACTIVITY_MESSAGE"			--来自活动中心的跳转消息
E.LOGIN_POPUP_CLICK_DESC_BTN="LOGIN_POPUP_CLICK_DESC_BTN"	--点击登陆弹框的详细信息中的按钮，跳转到某个界面或者做某种操作
E.LOGIN_POPUP_CLICK_ITEM="LOGIN_POPUP_CLICK_ITEM"			--点击登陆弹框的某一个选项，同志control刷新详细信息界面。

E.SVR_SET_BET = "SVR_SET_BET"
E.SVR_BET = "SVR_BET"


E.FOR_TALK_OR_NOT="FOR_TALK_OR_NOT"	--是否禁止发言

E.FORBID_GAME_NOTICE = "FORBID_GAME_NOTICE" --停服公告

E.PROPS_ADD_PROPS  = "PROPS_ADD_PROPS"       --增加道具
E.PROPS_RESET_PROPS  = "PROPS_RESET_PROPS"       --重置道具列表

E.SVR_CHECK_TABLE_RESULT = "SVR_CHECK_TABLE_RESULT"  --回复检查桌子结果

E.GET_FRIEND_LIST  = "GET_FRIEND_LIST"       --获取好友列表
E.GIVE_CHIP  = "GIVE_CHIP"       --赠送筹码
E.FRESH_RECOMMEND_LIST  = "FRESH_RECOMMEND_LIST"       --刷新推荐列表
E.SEARCHFRIEND  = "SEARCHFRIEND"       --刷新推荐列表
E.SVR_RETURN_SEND_FRIEND_MSG  = "SVR_RETURN_SEND_FRIEND_MSG"       --发送好友消息返回
E.SVR_REC_FRIEND_MSG  = "SVR_REC_FRIEND_MSG"       --接受好友消息
-- E.SVR_REC_FRIEND_MSG_IN_CHATPOPUP  = "SVR_REC_FRIEND_MSG_INCHAT_POPUP"       --接受好友消息
-- E.SVR_REC_FRIEND_MSG_IN_HALL  = "SVR_REC_FRIEND_MSG_IN_HALL"       --接受好友消息
E.SVR_REC_NO_READ_MSG  = "SVR_REC_NO_READ_MSG"       --接受未读消息
E.GET_FLASH_GIFTBAG_INFO  = "GET_FLASH_GIFTBAG_INFO"       --获取限时礼包信息
E.IN_FLASH_GIFTBAG_TIME  = "IN_FLASH_GIFTBAG_TIME"       --通知限时礼包开放时间到

E.GET_PAY_TYPE_LIST  = "GET_PAY_TYPE_LIST"       --获取支付方式列表
E.GET_CHIP_LIST  = "GET_CHIP_LIST"       --获取筹码列表
E.GET_SHOP_NOTICE  = "GET_SHOP_NOTICE"       --获取商城通知

E.CHANGE_FRIEND_LIST  = "CHANGE_FRIEND_LIST"       --好友列表改变


return EVENT_NAMES