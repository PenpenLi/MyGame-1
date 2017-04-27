--
-- Author: Johnny Lee
-- Date: 2014-07-08 10:52:57
--

local lang = {}
local L    = lang
local TT, TT1

L.COMMON   = {}
L.LOGIN    = {}
L.LOGOUT   = {}
L.HALL     = {}
L.ROOM     = {}
L.SINGLE     = {}
L.STORE    = {}
L.USERINFO = {}
L.FRIEND   = {}
L.RANKING  = {}
L.MESSAGE  = {}
L.SETTING  = {}
L.REGISTERREWARD = {}
L.LOGINREWARD = {}
L.HELP     = {}
L.UPDATE   = {}
L.ABOUT    = {}
L.DAILY_TASK = {}
L.COUNTDOWNBOX = {}
L.NEWESTACT = {}
L.FEED = {}
L.ECODE = {}
L.WHEEL = {}
L.BANK = {}
L.SLOT = {}
L.UPGRADE = {}
L.GIFT = {}
L.DYNAMIC = {}
L.CRASH = {}
L.GAMEBOARDCASTNOTICE = {}
L.ROOM_NEWBIE_GUIDE = {}
L.LIMIT_TIME_GIFTBAG = {}
L.LIMIT_TIME_EVENT = {}
L.PHOTO_MANAGER = {}
L.LOTTERY = {}
L.SCORE = {}

-- COMMON MODULE
L.COMMON.COLON=T("：")
L.COMMON.NUM=T("{1}")
L.COMMON.LEVEL = T("Lv.{1}")
L.COMMON.ASSETS = T("${1}")
L.COMMON.CONFIRM = T("确定")
L.COMMON.CANCEL = T("取消")
L.COMMON.AGREE = T("同意")
L.COMMON.REJECT = T("拒绝")
L.COMMON.RETRY = T("重试")
L.COMMON.NOTICE = T("温馨提示")
L.COMMON.BUY = T("购买")
L.COMMON.BUY_PROP = T("购买道具")
L.COMMON.SEND = T("发送")
L.COMMON.BAD_NETWORK = T("网络不给力")
L.COMMON.BAD_NETWORK_FAIL = T("连接失败，请检查您的网络设置({1})")
L.COMMON.REQUEST_DATA_FAIL = T("网络不给力，获取数据失败，请重试！")
L.COMMON.REQUEST_DATA_FAIL_2 = T("网络正在连接中，请稍后重试")
L.COMMON.JSON_DATA_FAIL = T("解析数据失败，请重试！")
L.COMMON.ROOM_FULL = T("现在该房间旁观人数过多，请换一个房间")
L.COMMON.USER_BANNED = T("您的账户被冻结了，请你反馈或联系管理员")
L.COMMON.MAX_MONEY_HISTORY = T("历史最高资产: {1}")
L.COMMON.MAX_POT_HISTORY = T("赢得最大奖池: {1}")
L.COMMON.WIN_RATE_HISTORY = T("历史胜率-: {1}%%")
L.COMMON.BEST_CARD_TYPE_HISTORY = T("历史最佳牌型:")
L.COMMON.MAX_WIN_HISTORY = T("历史最高赢取: {1}")
L.COMMON.INFO_RANKING = T("排名: {1}")
L.COMMON.LEVEL_UP_TIP = T("恭喜你升到{1}级, 获得奖励:{2}")
L.COMMON.MY_PROPS = T("我的道具:")
L.COMMON.SHARE = T("分  享")
L.COMMON.GET_REWARD = T("领取奖励")
L.COMMON.BUY_CHAIP = T("购买")
L.COMMON.LOGOUT = T("登出")
L.COMMON.CONTINUE = T("继续游戏")
L.COMMON.QUIT_DIALOG_TITLE = T("确认退出")
L.COMMON.QUIT_DIALOG_MSG = T("真的确认退出游戏吗？淫家好舍不得滴啦~\\(≧▽≦)/~")
L.COMMON.QUIT_DIALOG_CONFIRM = T("忍痛退出")
L.COMMON.QUIT_DIALOG_CANCEL = T("我点错了")
L.COMMON.LOGOUT_DIALOG_TITLE = T("确认退出登录")
L.COMMON.LOGOUT_DIALOG_MSG = T("真的要退出登录吗？")
L.COMMON.NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG = T("您的金币不足最小买入{1}，请前往免费金币看看。")
L.COMMON.USER_SILENCED_MSG = T("您的帐号已被禁言，您可以在帮助-反馈里联系管理员处理")
L.COMMON.TO_SHOP=T("前往商城")
L.COMMON.FB_CAN_NOT_CHANGE_HEAD=T("您当前是FB登陆，无法在游戏中修改头像")
L.COMMON.FB_CAN_NOT_CHANGE_USERINFO=T("您当前是FB登陆，无法在游戏中修改个人资料")
-- 99
L.COMMON.ALREADY_GET=T("已领取")
L.COMMON.MONTH_DAY_HOUR_MINUTE=T("{1}月{2}日{3}时{4}分")
L.COMMON.FORBID_GAME_NOTICE=T("亲爱的玩家朋友，为了给您提供更好的游戏服务，现正在对游戏服务器进行升级维护，预计{1}后即可重新开放游戏，开放游戏后{2}小时内登陆游戏的玩家朋友将会获得{3}筹码作为停服补偿。给您带来不便深表歉意，谢谢您对我们游戏的支持")
L.COMMON.GET_MONEY = T("恭喜您获得了{1}筹码")
L.COMMON.ENTER = T("进入")
L.COMMON.NO_DATA = T("没有数据")
L.COMMON.NO_RECORD = T("没有记录")
L.COMMON.DELETE = T("删除")
L.COMMON.DELETE_SURE = T("确认删除")
L.COMMON.NOT_LOAD_DATA = T("暂未获取到数据，请稍后重试。")
-- 99

L.COMMON.DAY = T("天")
L.COMMON.HOUR = T("小时")
L.COMMON.MINUTE = T("分钟")
L.COMMON.SECOND = T("秒")

L.COMMON.NAME_KEY = T("昵称")

L.COMMON.COINS = T("金币")

-- LOGIN MODULE
L.LOGIN.FB_LOGIN = T("FB账户登录")
L.LOGIN.GU_LOGIN = T("游客账户登录")
L.LOGIN.FB_LOGIN_TIP = T("邀请朋友一起玩，获取更多金币！")
L.LOGIN.USE_DEVICE_NAME_TIP = T("您是否允许我们使用您的设备名称\n作为游客账户的昵称并上传到游戏服务器？")
L.LOGIN.REWARD_SUCCEED = T("领取奖励成功")
L.LOGIN.REWARD_FAIL = T("领取失败")
L.LOGIN.REIGSTER_REWARD_FIRST_DAY = T("第一天")
L.LOGIN.REGISTER_REWARD_SECOND_DAY = T("第二天")
L.LOGIN.REGISTER_REWARD_THIRD_DAY = T("第三天")
L.LOGIN.REGISTER_REWARD_TODAY = T("今天")
L.LOGIN.REGISTER_REWARD_TOMORROW = T("明天")
L.LOGIN.LOGINING_MSG = T("正在登录游戏...")
L.LOGIN.CANCELLED_MSG = T("登录已经取消")
L.LOGIN.FEED_BACK_HINT     = T("请反馈您遇到的问题，我们将会为你尽快解决无法进入游戏的问题，谢谢！")
L.LOGIN.FEED_BACK_TITLE    = T("Feedback")
L.LOGIN.PHONE_NUMBER       = T("联系方式（必填）")
L.LOGIN.DOUBLE_LOGIN_MSG = T("您的账户在其他地方登录")

--99
L.LOGIN.NO_LOGIN_POPUP_DATA=T("数据加载失败，请重试")
L.LOGIN.NO_LOGIN_POPUP_ITEM_DATA=T("暂无数据")
L.LOGIN.SYSTEM_CONFIG_ERROR=T("系统配置错误,请与管理员联系")
--99
L.LOGIN.SEALED = T("封号通知")
L.LOGIN.SEALED_MODE = T("处罚方式：封号")
L.LOGIN.SEALED_TIME = T("处罚时间：")
L.LOGIN.SEALED_FREE = T("处罚时间结束后，您可以继续登陆账号玩游戏哦")
L.LOGIN.SEALED_FOREVER = T("永久封号后永远无法登陆游戏")

-- LOGOUT 
L.LOGOUT.TIP_TEXT = T("明天回来还可以领取登陆奖励{1}金币哦")
L.LOGOUT.QUIT_TIP_TEXT = T("#cffffff明天回来还可以领取登陆奖励#n#cffc84b{1}#n#cffffff金币哦！#n")
-- HALL MODULE
L.HALL.USER_ONLINE = T("当前在线人数{1}")
L.HALL.INVITE_FRIEND = T("邀请FB好友+50000")
L.HALL.DAILY_BONUS = T("登录奖励")
L.HALL.DAILY_MISSION = T("每日任务")
L.HALL.NEWEST_ACTIVITY = T("最新活动")
L.HALL.ACTIVITY = T("活动")
L.HALL.LOGIN_REWARD = T("登陆奖励")
L.HALL.LUCKY_WHEEL = T("幸运转转转")
L.HALL.UPLEVEL_AWARD=T("升级奖励")
L.HALL.VIDEO_AWARD = T("观看视频")
L.HALL.DOWNLOAD_AWARD = T("安装游戏")
L.HALL.NO_UPLEVEL_AWARD=T("您当前没有升级奖励可领取,还需要获得{1}经验升级")
L.HALL.NOTOPEN=T("暂未开放 敬请期待")
L.HALL.STORE_BTN_TEXT = T("商城")
L.HALL.FRIEND_BTN_TEXT = T("好友")
L.HALL.RANKING_BTN_TEXT = T("排行榜")
L.HALL.FREECHIP_BTN_TEXT = T("免费金币")
L.HALL.MAX_BUY_IN_TEXT = T("最大买入{1}")
L.HALL.MIN_BUY_IN_TEXT = T("最小买入{1}")
L.HALL.MIN_LIMIT_TEXT = T("场次下限{1}")
L.HALL.PRE_CALL_TEXT = T("大厅前注")
L.HALL.MIN_LEVEL_TEXT = T("等级{1}以上")
L.HALL.MIN_LEVEL_TIP = T("您需要达到等级{1}才能玩该场次")
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_ERROR = T("你输入的房间号码有误")
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_EMPTY = T("房间号码不能为空")
L.HALL.SEARCH_ROOM_NUMBER_IS_WRONG= T("你输入的房间位数不对")
L.HALL.SEARCH_ROOM_INPUT_CORRECT_ROOM_NUMBER= T("请输入5或6位的房间号码")
L.HALL.ROOM_LEVEL_TEXT = {
    T("初级场"), 
    T("中级场"), 
    T("高级场")
}
L.HALL.PLAYER_LIMIT_TEXT = {
    T("9\n人"), 
    T("5\n人")
}

L.HALL.GIRL_TOUCHFORROOKIE = {
    T("多米诺接龙很好玩，我很喜欢这款游戏，你呢？"), --lv 1~4
    T("这是一款充满趣味性的游戏。"),
    T("去游戏房间看看吧，大家都在等你呢。"),
    T("竞技的乐趣在于不断的挑战和冒险，我要努力到最高的场次赢得最多的金币！"),
}
L.HALL.GIRL_TOUCH = {
  T("多米诺99很好玩，我很喜欢这款游戏，你呢？"),
  T("去游戏房间看看吧，大家都在等你呢。"),
  T("竞技的乐趣在于不断的挑战和冒险，我要努力到最高的场次赢得最多的金币！"),
  T("你是一个高手了，想要接受我的挑战么！"),
  T("我在房间等你，快来找我吧。"),
  T("游戏中还会有很多好玩儿的地方，慢慢挖掘吧！"),
  T("快去吧！"),
  T("去之前准备好充足的金币，金币可以免费领取，也可以在游戏里购买！"),
  T("对了，游戏的首充礼包非常优惠，每月只有一次机会喔！"),
}
L.HALL.GIRL_PRIVATEAREA = {
  T("哎呀！"),
  T("你在干嘛？"),
  T("???"),
  T("......"),
  T("!!!!!!"),
  T("讨厌快去打牌吧"),
  T("快去打牌吧！"),
  T("不理你了！"),
  "",
  "",
}
L.HALL.GIRL_ROOKIE = T("多米诺99是一款有趣的游戏，你可以在这里认识到很多朋友！")
L.HALL.GIRL_COMMON = {
  T("Hi，{1}，你来了。有很多牌友正在打牌呢，快来一起参与吧！"),
  T("Hi，{1}，今天天气怎么样，有出去走走么？"),
}

L.ROOM.INFO_UID = T("ID:{1}")
L.ROOM.INFO_LEVEL = T("Lv.{1}")
L.ROOM.INFO_RANKING = T("排名:  {1}")
L.ROOM.INFO_WIN_RATE = T("胜率:  {1}%%")
L.ROOM.INFO_GENERAL_NUMBER = T("总局数:  {1}")
L.ROOM.INFO_SEND_CHIPS = T("赠送金币")
L.ROOM.ADD_FRIEND = T("加为好友")
L.ROOM.IS_FRIEND = T("已添加")
L.ROOM.DEL_FRIEND = T("删除好友")
L.ROOM.GIFT_FRIEND = T("赠送礼物")
L.ROOM.ADD_FRIEND_SUCCESS_MSG = T("添加好友成功")
L.ROOM.ADD_FRIEND_FAILED_MSG = T("添加好友失败")
L.ROOM.ADD_FRIEND_FAILED_IS_FRIEND_ALREADY = T("对方已经是好友了")
L.ROOM.NO_ADD_MYSELF = T("不能添加自己")
L.ROOM.DELE_FRIEND_SUCCESS_MSG = T("删除好友成功")
L.ROOM.DELE_FRIEND_FAIL_MSG = T("删除好友失败")
L.ROOM.SEND_CHIP_NOT_NORMAL_ROOM_MSG = T("只有普通场才可以赠送金币")
L.ROOM.SELF_CHIP_NO_ENOUGH_SEND_DELEAR = T("你的金币不够多，不足给荷官小费")
L.ROOM.EXECUTE_GAME_OPERATION_FIRST = T("请先进行游戏操作")
L.ROOM.SEND_CHIP_NOT_IN_SEAT = T("坐下才可以赠送金币")
L.ROOM.SEND_CHIP_NOT_ENOUGH_CHIPS = T("钱不够啊")
L.ROOM.SEND_CHIP_TOO_OFTEN = T("赠送的太频繁了")
L.ROOM.SEND_CHIP_TOO_MANY = T("赠送的太多了")
L.ROOM.SEND_HDDJ_IN_MATCH_ROOM_MSG = T("比赛场不能发送互动道具")
L.ROOM.SEND_HDDJ_NOT_IN_SEAT = T("坐下才能发送互动道具")
L.ROOM.SEND_HDDJ_NOT_ENOUGH = T("您的互动道具数量不足，赶快去商城购买吧")
L.ROOM.SEND_EXPRESSION_MUST_BE_IN_SEAT = T("坐下才可以发送表情")
L.ROOM.SEND_EXPRESSION_NOTVIP_TIPS = T("您不是VIP会员，无法使用该表情")
L.ROOM.CHAT_FORMAT = T("{1}{2}")
L.ROOM.ROOM_INFO = T("前注: {1}")
L.ROOM.ROOM_INFO_QIUQIU = T("{1}/前注{2}")
L.ROOM.NO_BIG_LA_BA = T("暂无喇叭,是否立即购买？")
L.ROOM.SEND_BIG_LABA_MESSAGE_FAIL = T("发送大喇叭消息失败")
L.ROOM.USER_CARSH_REWARD_DESC = T("您获得了{1}金币的破产补助，终身只有三次机会获得，且用且珍惜")
L.ROOM.USER_CARSH_BUY_CHIP_DESC = T("您也可以立即购买，输赢只是转瞬的事")
L.ROOM.USER_CARSH_REWARD_COMPLETE_DESC = T("您已经领完所有破产补助，您可以去商城购买金币，每天登录还有免费金币赠送哦！")
L.ROOM.USER_CARSH_REWARD_COMPLETE_BUY_CHIP_DESC = T("输赢乃兵家常事，不要灰心，立即购买金币，重整旗鼓。")
L.ROOM.WAIT_NEXT_ROUND = T("请等待下一局开始")
L.ROOM.LOGIN_ROOM_FAIL_MSG = T("登录房间失败")
L.ROOM.BUYIN_ALL_POT= T("全部奖池")
L.ROOM.BUYIN_3QUOT_POT = T("3/4奖池")
L.ROOM.BUYIN_HALF_POT = T("1/2奖池")
L.ROOM.BUYIN_TRIPLE = T("3倍反加")
L.ROOM.CHAT_TAB_SHORTCUT = T("快捷聊天")
L.ROOM.CHAT_TAB_HISTORY = T("聊天记录")
L.ROOM.INPUT_HINT_MSG = T("点击输入聊天内容")
L.ROOM.INPUT_HINT_MSG_LABA = T("点击输入喇叭内容")
L.ROOM.CHAT_SHORTCUT = {
  T("大家好!"),
  T("初来乍到，多多关照"),
  T("我等到花儿都谢了"),
  T("你的牌打得太好了!"),
  T("冲动是魔鬼，淡定!"),
  T("送点钱给我吧!"),
  T("哇，你抢钱啊!"),
  T("又断线，网络太差了!")
}

L.ROOM.CHAT_SHORTCUT_99 = {
  T("大家好!"),
  T("初来乍到，多多关照"),
  T("我等到花儿都谢了"),
  T("ALL IN 他!!"),
  T("你的牌打得太好了!"),
  T("冲动是魔鬼，淡定!"),
  T("求跟注，求ALL IN!"),
  T("送点钱给我吧!"),
  T("哇，你抢钱啊!"),
  T("又断线，网络太差了!")
}

--买入弹框
L.ROOM.BUY_IN_TITLE = T("买入金币")
L.ROOM.BUY_IN_BALANCE_TITLE = T("您的账户余额:#cffd01a{1}#n")
L.ROOM.BUY_IN_MIN = T("最低买入")
L.ROOM.BUY_IN_MAX = T("最高买入")
L.ROOM.BUY_IN_AUTO = T("金币不足时自动买入")
L.ROOM.BUY_IN_BTN_LABEL = T("买入坐下")
L.ROOM.BACK_TO_HALL = T("返回大厅")
L.ROOM.CHANGE_ROOM = T("换  桌")
L.ROOM.USER_STAND_UP = T("站  起")
L.ROOM.SETTING = T("设  置")
L.ROOM.SIT_DOWN_NOT_ENOUGH_MONEY = T("您的金币不足当前房间的最小携带，您可以换桌到低场次房间或者邀请好友获得更多金币奖励。")
L.ROOM.SIT_DOWN_OVER_MAX_MONEY = T("你筹码超过了{1}，就不要去欺负别人了，请前往更高场次玩牌。")
L.ROOM.AUTO_CHANGE_ROOM = T("自动换桌")
L.ROOM.USER_INFO_ROOM = T("个人信息")
L.ROOM.CHARGE_CHIPS = T("补充金币")
L.ROOM.I_KNOW_ED = T("我知道了")
L.ROOM.ENTERING_MSG = T("正在进入，请稍候...\n有识尚需有胆方可成赢家")
L.ROOM.OUT_MSG = T("正在退出，请稍候...")
L.ROOM.CHANGING_ROOM_MSG = T("正在更换房间..")
L.ROOM.CHANGE_ROOM_FAIL = T("更换房间失败，是否重试？")
L.ROOM.CHANGE_ROOM_FAIL2 = T("更换房间失败")
L.ROOM.STAND_UP_IN_GAME_MSG = T("请在本局结束后站起，强制站起将收取{1}金币作为罚款，您确定要站起吗?")
L.ROOM.STAND_UP_IN_GAME_MSG_QIUQIU = T("请在本局结束后站起, 强制站起按“输牌”处理, 你确定要站起吗?")
L.ROOM.STAND_UP_FAILED = T("站起失败，请稍后再试。")
L.ROOM.REQUIRE_LATER = T("请稍后再试...")
L.ROOM.EXIT_IN_GAME_MSG = T("请在本局结束后退出，强制退出将收取{1}金币作为罚款，您确定要退出吗?") 
L.ROOM.EXIT_IN_GAME_MSG_QIUQIU = T("请在本局结束后退出, 强制退出按“输牌”处理, 你确定要退出吗?") 
L.ROOM.CHANGE_ROOM_IN_GAME_MSG = T("请在本局结束后换桌，强制换桌将收取{1}金币作为罚款，您确定要换桌吗?") 
L.ROOM.CHANGE_ROOM_IN_GAME_MSG_QIUQIU = T("请在本局结束后换桌, 强制换桌按“输牌”处理, 你确定要换桌吗?") 
L.ROOM.NET_WORK_PROBLEM_DIALOG_MSG = T("与服务器的连接中断，是否尝试重新连接？")
L.ROOM.RECONNECT_MSG = T("正在重新连接..")
L.ROOM.COUNTDOWN = T("{1}秒之后开始下一局")

L.ROOM.NO_CARD_CAN_SHOW = T("没有合适点数的牌可出")
L.ROOM.APPEAR_DEAD_END = T("游戏出现死路，即将进入游戏结算")
L.ROOM.CARD_TIPS1 = T("点击或拖动任意一张亮着的牌（可出的牌）")
L.ROOM.CARD_TIPS2 = T("点击该位置或把牌直接拖动到该位置则出牌成功")
L.ROOM.CARD_TIPS3 = T("没有合适的牌可出时需向上一次最后出牌的玩家付过费")
L.ROOM.CARD_TIPS4 = T("超时后系统将自动帮你出牌")
L.ROOM.CARD_TIPS5 = T("游客用户点击自己的头像弹框或者性别标志可更换头像和性别哦")

L.ROOM.AUTO_CHECK = T("自动看牌")
L.ROOM.AUTO_CHECK_OR_FOLD = T("看或弃")
L.ROOM.AUTO_FOLD = T("自动弃牌")
L.ROOM.AUTO_CALL_ANY = T("跟任何注")
L.ROOM.FOLD = T("弃  牌")
L.ROOM.ALL_IN = T("ALL IN")
L.ROOM.CALL = T("跟  注")
L.ROOM.CALL_NUM = T("跟注 {1}")
L.ROOM.SMALL_BLIND = T("小盲")
L.ROOM.BIG_BLIND = T("大盲")
L.ROOM.RAISE = T("加  注")
L.ROOM.RAISE_NUM = T("加注 {1}")
L.ROOM.CHECK = T("看  牌")
L.ROOM.SHOW_HANDCARD = T("亮出手牌")
L.ROOM.DEALER_SPEEK_ARRAY = {
    T("祝您牌运亨通，{1}"),
    T("祝您好运连连，{1}"),
    T("您人真好，{1}"),
    T("真高兴能为您服务，{1}"),
    T("衷心的感谢您，{1}")
}
L.ROOM.DEALER_SPEEK_BAD_ARRAY = {
    T("老板，我做错什么了吗？"),
    T("老板，不要欺负人家嘛"),
    T("老板，您太坏了！")
}
L.ROOM.SERVER_UPGRADE_MSG = T("服务器正在升级中，请稍候..")
L.ROOM.USER_CRSH_POP_TITLE = T("破产了")
L.ROOM.CHAT_MAIN_TAB_TEXT = {
    T("消息"), 
    T("消息记录")
}
L.ROOM.CHAT_MAIN_TAB_TEXT_QIUQIU = {
    T("快捷聊天"), 
    T("好友"),
    T("聊天记录")
}
L.ROOM.KICKED_BY_ADMIN_MSG = T("您已被管理员踢出该房间")
L.ROOM.KICKED_BY_USER_MSG = T("您被用户{1}踢出了房间")
L.ROOM.TO_BE_KICKED_BY_USER_MSG = T("您被用户{1}踢出房间，本局结束之后将自动返回大厅")
L.ROOM.USER_CRSH_POP_TITLE = T("破产了")

L.ROOM.PRIVATE_TITLE = T("私人房")
L.ROOM.PRIVATE_INPUT_ID_TIP = T("请输入房间ID")
L.ROOM.PRIVATE_INPUT_NAME_TIP = T("请输入房间名")
L.ROOM.PRIVATE_HIDE_FULL = T("隐藏已满房间")
L.ROOM.PRIVATE_CREATE_ROOM = T("创建房间")
L.ROOM.PRIVATE_ROOM_ID = T("房间ID")
L.ROOM.PRIVATE_ROOM_NAME = T("房间名")
L.ROOM.PRIVATE_ROOM_ANTES = T("底注")
L.ROOM.PRIVATE_ROOM_PEOPLE = T("人数")
L.ROOM.PRIVATE_ROOM_PASSWORD = T("密码")
L.ROOM.PRIVATE_CREATE = T("创建")
L.ROOM.PRIVATE_CREATE_TIP = T("提示：您可以不设置密码")
L.ROOM.PRIVATE_PASSWORD_LIMIT = T("请输入10位以内的密码")
L.ROOM.PRIVATE_NO_ROOM = T("暂无房间，马上去创建一个私人房吧！")
L.ROOM.PRIVATE_CRETE_FAIL_LEVEL = T("至少达到{1}等级才能创建私人房！")
L.ROOM.PRIVATE_CRETE_FAIL_MONEY = T("金币不足，金币需要达到{1}才能创建私人房！")
L.ROOM.PRIVATE_JOIN_FAIL_LEVEL = T("至少达到{1}等级才能进入此私人房！")
L.ROOM.PRIVATE_JOIN_FAIL_MONEY = T("金币不足，金币需要达到{1}才能进入此私人房！")
L.ROOM.PRIVATE_INPUT_NAME_FAIL_TIP = T("私人房名称不可超过12个字符哦")
L.ROOM.PRIVATE_INPUT_NAME_NULL_TIP = T("请为您创建的私人房起个名字吧")
L.ROOM.PRIVATE_INPUT_PASSWORD_FAIL_TIP = T("密码不得超过10位数（可以不设置密码）")
L.ROOM.PRIVATE_INPUT_SEARCH_FAIL_TIP = T("请输入正确的房间ID")
L.ROOM.PRIVATE_ROOMNAME_INFO = T("房间名: {1}")
L.ROOM.PRIVATE_ROOMID_INFO = T("房间ID: {1}")
L.ROOM.PRIVATE_CREATE_AND_ENTERING_MSG = T("创建房间成功!\n正在进入，请稍候...")
L.ROOM.PRIVATE_INPUT_SEARCH_FAIL_TIP = T("请输入正确的房间ID")
L.ROOM.PRIVATE_SEARCH_NO_EXIST = T("房间不存在，请输入其他房间ID试试！")

L.ROOM.SIDECHIPS_EARN = T("赢取说明")
L.ROOM.SIDECHIPS_WIN = T("中奖纪录")
L.ROOM.SIDECHIPS_DETAIL = T("详情")
L.ROOM.SIDECHIPS_ISSEAT = T("站起状态不可参与边注玩法")
L.ROOM.SIDECHIPS_BUY_FAIL = T("买入失败")
L.ROOM.SIDECHIPS_BUY_FAIL1 = T("金币不足，无法购买")
L.ROOM.SIDECHIPS_BUY_FAIL2 = T("金币不足，建议选择小额度买入")
L.ROOM.SIDECHIPS_BUY_SUCC = T("买入成功")
L.ROOM.SIDECHIPS_REWARD_GET = T("恭喜您获得边注玩法奖励{1}金币")
L.ROOM.SIDECHIPS_REWARD_MISS = T("很遗憾，您的运气不佳，没有赢得边注奖励")
L.ROOM.SIDECHIPS_DETAIL_STR = T("1.选择一个买入值和一个下注牌型，从当前房间外的资产中扣除，买入后若下一局拿到的手牌与下注的牌型相同，则可以获得对应金币奖励，房间外总资产=总资产-房间下限\n2.买入值越大，则奖励越高\n3.购买后在下一局中生效\n4.若购买后的下一局，旁观或者离开该房间，则默认玩家取消该次购买，系统将归还玩家购买所消耗的金币")
L.ROOM.SIDECHIPS_INVITED = T("我在边注玩法中奖{1}金币，快来一起玩吧！")
L.ROOM.SIDECHIPS_CANCLE = T("已取消边注玩法下注，金币已退还")

L.ROOM.KICKED_REASON1 = T("网络错误，请您重新进入房间")
L.ROOM.KICKED_REASON2 = T("服务器维护更新，请您重新进入房间")
L.ROOM.KICKED_REASON3 = T("与服务器断开连接，请您重新进入房间")

L.ROOM.ENTER_TIPS_GAPLE = {
    T("接龙玩法简单而有趣"), 
    T("可以通过点击或者拖动牌两种方式进行出牌哦"),
    T("可以向你喜欢或者讨厌的玩法扔互动道具哦"),
    T("邀请FB好友对战，游戏交友两不误，还可获得很多金币哦"),
    T("游客和FB玩家可以自定义自己的头像"),
    T("游戏中途退出要慎重，中途退出是要收取罚费的哦"),
    T("没有牌出的玩家需要向上家付过费哦"),
    T("输牌并不可怕，输掉信心才是最可怕的"),
    T("风水不好时，尝试换个位置"),
}

L.ROOM.ENTER_TIPS_QIUQIU = {
    T("有了好牌要加注，要掌握优势，主动进攻"), 
    T("留意观察对手，不要被对手的某些伎俩所欺骗"),
    T("要打出气势，让别人怕你"),
    T("控制情绪，赢下该赢的牌"),
    T("游客和FB玩家可以自定义自己的头像"),
    T("小提示：设置页可以设置进入房间是否自动买入坐下"),
    T("小提示：设置页可以设置是否震动提醒"),
    T("忍是为了下一次All In！"),
    T("冲动是魔鬼，心态好，好运自然来"),
    T("风水不好时，尝试换个位置"),
    T("你不能控制输赢，但可以控制输赢的多少"),
    T("可以向你喜欢或者讨厌的玩法扔互动道具哦"),
    T("运气有时好有时坏，知识将伴随你一生"),
    T("诈唬是胜利的一大手段，要有选择性的诈唬"),
    T("下注要结合池底，不要看绝对数字"),
    T("All In是一种战术，用好并不容易"),
}


L.SINGLE.BANKRUPT_FINISHED = T("您今天的{1}次单机破产补助已经领取完了，明天再来吧。")
L.SINGLE.BANKRUPT_FINISHED2 = T("您今天的{1}次单机破产补助已领取完了，无法进入单机房间")


TT = {}
L.COMMON.CARD_TYPE = TT
TT1 = {}

TT[1] = TT1
TT[2] = T("顺子")
TT[3] = T("同花顺")
TT[4] = T("三黄")
TT[5] = T("三张")
TT[6] = T("博定")
TT1[0] = T("0点")
TT1[1] = T("1点")
TT1[2] = T("2点")
TT1[3] = T("3点")
TT1[4] = T("4点")
TT1[5] = T("5点")
TT1[6] = T("6点")
TT1[7] = T("7点")
TT1[8] = T("8点")
TT1[9] = T("9点")
TT = {}
L.ROOM.SIT_DOWN_FAIL_MSG = TT
TT["IP_LIMIT"] = T("坐下失败，同一IP不能坐下")
TT["SEAT_NOT_EMPTY"] = T("坐下失败，该桌位已经有玩家坐下。")
TT["CHIPS_ERROR"] = T("坐下失败, 携带的金币不正确。")
TT["OTHER"] = T("坐下失败.")

L.ROOM.SERVER_STOPPED_MSG = T("系统正在停服维护, 请耐心等候")
L.STORE.NOT_SUPPORT_MSG = T("您的账户暂不支持支付")
L.STORE.BUY_MESSAGE = T("您确定花费{1},购买{2}吗?")
L.STORE.PURCHASE_SUCC_AND_DELIVERING = T("已支付成功，正在进行发货，请稍候..")
L.STORE.PURCHASE_CANCELED_MSG = T("支付已经取消")
L.STORE.PURCHASE_FAILED_MSG = T("支付失败")
L.STORE.DELIVERY_FAILED_MSG = T("网络故障，系统将在您下次打开商城时重试。")
L.STORE.DELIVERY_SUCC_MSG = T("发货成功，感谢您的购买。")
L.STORE.TITLE_STORE = T("商城")
L.STORE.TITLE_CHIP = T("金币")
L.STORE.TITLE_PROP = T("互动道具")
L.STORE.TITLE_PROPS = T("道具")
L.STORE.TITLE_MY_PROP = T("我的道具")
L.STORE.TITLE_HISTORY = T("购买记录")
L.STORE.RATE_CHIP = T("1{2}={1}金币")
L.STORE.FORMAT_CHIP = T("chip{1}")
L.STORE.REMAIN = T("剩余：{1}{2}")
L.STORE.INTERACTIVE_PROP = T("互动道具")
L.STORE.LAST = T("剩余：")
L.STORE.GE = T("个")
L.STORE.BUY = T("购买")
L.STORE.USE = T("使用")
L.STORE.BUY_CHIPS = T("购买{1}金币")
L.STORE.RECORD_STATUS = {
    T("已下单"),
    T("已发货"),
    T("已退款")
}
L.STORE.USE_SUCC_MSG = T("道具使用成功")
L.STORE.USE_FAIL_MSG = T("道具使用失败")
L.STORE.NO_PRODUCT_HINT = T("暂无商品")
L.STORE.NO_BUY_HISTORY_HINT = T("暂无支付记录")
L.STORE.MY_CHIPS = T("我的金币 {1}")
L.STORE.BUSY_PURCHASING_MSG = T("正在购买，请稍候..")
L.STORE.CARD_INPUT_SUBMIT = "TOP UP"
L.STORE.MYINFO = T("我的信息")
L.STORE.BUY_SUCC_MSG = T("道具购买成功")
L.STORE.BUY_FAIL_MSG = T("您的金币不足，无法购买该道具，要先充值吗？")
L.STORE.BUY_FAIL_MSG_1 = T("您的金币不足，无法购买该礼物，要先充值吗？")
L.STORE.PROP_LABA_DESC = T("您发送的消息会被所有玩家看到")

L.STORE.FIRST_RECHARGE_TIP = T("每月首充{1}即可获赠超值豪华大礼包!")
L.STORE.FIRST_RECHARGE_TIP_2 = T("每月首次充值#cfff600任意金额#n即可获得价值#cfff600{1}#n豪华大礼包")
L.STORE.FIRST_RECHARGE_TYPE_SELECT = T("支付方式")
L.STORE.FIRST_RECHARGE_AMOUNT_SELECT = T("支付额度")
L.STORE.FIRST_RECHARGE_PAYTYPE = T("选择支付方式进行购买")
L.STORE.FIRST_RECHARGE_TITLE=T("首充礼包")
L.STORE.CARD_TITLE=T("Indomog实体卡支付")
L.STORE.CARD_ACCOUNT=T("卡号:")
L.STORE.CARD_PASSWORD=T("密码:")
L.STORE.CARD_TIP=T("请输入正确的Indomog实体卡号和密码!")
L.STORE.VIP_NEXT_TIP = T("充值达到 {1}IDR,即可享受 VIP{2} 特权")
L.STORE.VIP_PRIVILEGE = T("{1} 享有以下特权(有效期: {2} 天)")
L.STORE.VIP_EXPIRY_TIME = T("您的VIP到期时间：{1}")
L.STORE.VIP_BE_VIP = T("成为VIP")
L.STORE.VIP_TOP = T("您是最高VIP")
L.STORE.VIP_PRIVILEGE_INFO = T("查看VIP特权")

-- register reward
L.REGISTERREWARD.TITLE = T("注册奖励")
L.REGISTERREWARD.INFO = T("连续登陆奖励更多哦")
-- login reward
L.LOGINREWARD.TITLE = T("连续登录奖励")
L.LOGINREWARD.INVITE_FRIEND=T("邀请好友")
L.LOGINREWARD.IMMEDIATELY_PLAY=T("马上玩牌")
L.LOGINREWARD.REWARD = T("今日奖励{1}金币")
L.LOGINREWARD.REWARD_ADD = T("(FB登录多加50000金币)")
L.LOGINREWARD.PROMPT = T("连续登录可获得更多奖励，最高每天{1}游戏币奖励")
L.LOGINREWARD.DAYS = T("{1}天")
L.LOGINREWARD.NO_REWARD = T("三次注册礼包领取完成后即可领取")
L.LOGINREWARD.CONTINUOUS_DAY = T("已累积登录#cfff000{1}#n天，累积登录#cfff000{2}#n天可获得#cfff000{3}#n.")
-- USERINFO MODULE
L.USERINFO.UPLOAD_SELF_PIC = T("上传照片")
L.USERINFO.WRITE_SELF_DYNA = T("请输入你的动态信息哦")
L.USERINFO.WRITE_SELF_DYNA_TITLE = T("发表动态")
L.USERINFO.SIGN_HINT_TEXT = T("请输入你的个性签名哦")
L.USERINFO.COMFIRM_INFO = T("提交信息")
L.USERINFO.SIGN_TXT = T("签名")
L.USERINFO.QUICK_CHANGE = T("(头像修改后立即生效)")
L.USERINFO.GOTO_CHANGE = T("去修改")
L.USERINFO.AVATAR = T("头像")
L.USERINFO.SEX = T("性别")
L.USERINFO.MODIFY_SELF_INFO = T("修改资料")
L.USERINFO.MAX_MONEY_HISTORY = T("历史最高资产:")
L.USERINFO.MAX_POT_HISTORY = T("赢得最大奖池:")
L.USERINFO.MAX_WIN_HISTORY = T("历史最高赢取:")
L.USERINFO.WIN_RATE_HISTORY = T("历史胜率:")
L.USERINFO.INFO_RANKING = T("排名:")
L.USERINFO.BEST_CARD_TYPE_HISTORY = T("历史最佳牌型:")
L.USERINFO.MY_PROPS = T("我的道具:")
L.USERINFO.SEX_MAN = T("男")
L.USERINFO.SEX_WOMAN = T("女")
L.USERINFO.CHANGE_AVATAR = T("修改头像")
L.USERINFO.MY_PROPS_TIMES = "X{1}"
L.USERINFO.EXPERIENCE_VALUE = "{1}/{2}" --经验值
L.USERINFO.GENERAL_NUMBER = T("总局数:")
L.USERINFO.UPLOAD_PIC_NO_SDCARD = T("没有安装SD卡，无法使用头像上传功能")
L.USERINFO.UPLOAD_PIC_PICK_IMG_FAIL = T("获取图像失败")
L.USERINFO.UPLOAD_PIC_UPLOAD_FAIL = T("上传头像失败，请稍后重试")
L.USERINFO.UPLOAD_PIC_IS_UPLOADING = T("正在上传头像，请稍候...")
L.USERINFO.UPLOAD_PIC_UPLOAD_SUCCESS = T("上传头像成功")
L.USERINFO.BROADCAST_TOO_FAST = T("发送频率过快")
L.USERINFO.GAG_TIPS = T("已屏蔽对方聊天")
L.USERINFO.GAG_CANCEL_TIPS = T("已开启对方聊天")
L.USERINFO.GAG_TIPS1 = T("取消屏蔽")
L.USERINFO.GAG_CANCEL_TIPS1 = T("屏蔽")
L.USERINFO.DEL_FRIEND_TIPS = T("已删除对方")
L.USERINFO.PROP_COUNT = T("剩余:{1}个")
L.USERINFO.PROP_BUY_AND_USE = T(",继续使用将每次扣除{1}金币")
L.USERINFO.SEND_BROADCAST = T("点击切换，可以发送喇叭消息")
L.USERINFO.LABA = T("喇叭")
L.USERINFO.USE_TIME = T("使用期限")
L.USERINFO.FOREVER = T("永久")
L.USERINFO.NO_PROP = T("暂无道具哦")
L.USERINFO.INFO = T("提示：禁止上传色情图片，一旦发现，改头像将被立刻删除，同时账号得到一定处罚")
L.USERINFO.PHOTO = T("立即拍照")
L.USERINFO.PICTURE = T("本地上传")
L.USERINFO.USE = T("使用")
L.USERINFO.MOD_SUCCESS = T("修改成功")
L.USERINFO.MOD_FAILD = T("修改失败")
L.USERINFO.WRITE_DYNAMIC_FAILD = T("发表动态失败")
L.USERINFO.WRITE_DYNAMIC_SUCC = T("发表动态成功")
L.USERINFO.COMMON_USE = T("最近使用表情")
L.USERINFO.GAME_DETEIL = T("牌局详情")
L.USERINFO.NO_EXP_TIPS = T("您最近未发送表情，赶快发送表情和其他玩家互动吧！")

L.USERINFO.UPLOAD_PHOTO_SUCCESS = T("上传照片成功")
L.USERINFO.UPLOAD_PHOTO_FAIL = T("上传照片失败")
L.USERINFO.CHANGE_HEAD_ICON_SUCCESS  = T("头像更换成功")

L.USERINFO.TAB_SPACE = T("个人空间")
L.USERINFO.TAB_DETAIL = T("详细资料")
L.USERINFO.TAB_HDPROP = T("互动道具")
L.USERINFO.TAB_MYPROP = T("我的道具")
L.USERINFO.TAB_RECENTEXP = T("最近表情")

L.USERINFO.KEY_SIGNATURE = T("个性签名")
L.USERINFO.KEY_NEW_ACTIVITY = T("最新动态")
L.USERINFO.KEY_EDIT_PROFILE = T("编辑信息")
L.USERINFO.BTN_SEE_ALL = T("查看全部：{1}条")
L.USERINFO.ACTIVITY_EMPTY = T("空")

L.USERINFO.KEY_MONEY = T("资产")
L.USERINFO.KEY_MONEY_RANK = T("资产排行")
L.USERINFO.KEY_MATCH_COUNT = T("牌局数")
L.USERINFO.KEY_WIN_RATE = T("胜率")
L.USERINFO.KEY_FRIEND_CNT = T("好友数量")
L.USERINFO.KEY_FANS_CNT = T("粉丝数量")
L.USERINFO.KEY_HISTORY_CHARM = T("历史魅力值")
L.USERINFO.KEY_MONTH_CHARM = T("月度魅力值")
L.USERINFO.KEY_EXP = T("经验值")
L.USERINFO.KEY_VIP_LV = T("VIP等级")

L.USERINFO.THUMBUP_SUCC = T("点赞成功")
L.USERINFO.THUMBUP_FAIL = T("点赞失败")
L.USERINFO.DELDYNAMIC_SUCC = T("已删除动态")
L.USERINFO.DELDYNAMIC_FAIL = T("删除动态失败")
L.USERINFO.NOT_VIP_TIP = T("您还不是VIP，无法使用VIP互动道具！")

L.USERINFO.SYNTHESIS_PROP = T("合 成")
L.USERINFO.SYNTHESIS_PROP_TIPS_TITLE = T("合成说明")
L.USERINFO.SYNTHESIS_PROP_TITLE = T("合成道具")
L.USERINFO.EXCHANGE_PROP = T("兑 换")
L.USERINFO.PIECE_PROP = T("道具碎片")
L.USERINFO.CAN_SYNTHESIS = T("可合成道具")
L.USERINFO.SEND_PROP_TITLE = T("赠送道具")

L.USERINFO.PROP_EXPIRE_KEY = T("剩余有效期：")
L.USERINFO.PROP_SENDABLE = T("可赠送")

L.USERINFO.PROP_SENDPROP_TIPS = T("每次只能赠送一个道具，该道具赠送手续费为：")
L.USERINFO.PROP_SENDPROP_MONEY_NOT_ENOUGH = T("手续费不足")
L.USERINFO.PROP_SENDPROP_TO_MUCH_TIME = T("赠送失败，您今日赠送的道具过多")

L.USERINFO.PROP_EXCHANGE_INFO_TIPS = T("输入信息不能为空")

L.USERINFO.PROP_EXCHANGE_SUCCESS = T("信息提交成功")
L.USERINFO.PROP_EXCHANGE_FAIL = T("提交信息失败")

L.USERINFO.PROP_SENDPROP_SUCCESS = T("赠送道具成功")
L.USERINFO.PROP_SENDPROP_FAIL = T("赠送道具失败")

L.USERINFO.PROP_SYNTPROP_SUCCESS = T("合成道具成功")
L.USERINFO.PROP_SYNTPROP_FAIL = T("合成道具失败")
L.USERINFO.PROP_SYNTPROP_NOT_QUALIFIED = T("碎片不足，无法合成")

L.USERINFO.PROP_PLEASE_CHOOSE_SENDPROP_TIPS = T("请从列表中选择要赠送的礼物")

L.USERINFO.PROP_SENDPROP_CONFIRM_TITLE = T("信息确认")
L.USERINFO.PROP_SENDPROP_CONFIRM_TIPS = T("请确认赠送对象信息，物品赠送成功后无法取回")

L.USERINFO.REPORT_TIPS = T("您每日有{1}次举报机会，请珍惜")
L.USERINFO.REPORT_TEXT1 = T("色情图像")
L.USERINFO.REPORT_TIPS1 = T("举报成功")
L.USERINFO.REPORT_TIPS2 = T("举报失败") 
L.USERINFO.REPORT_TIPS3 = T("您今天的举报机会已经用完")

L.USERINFO.FBBINDING_TITLE = T("FB账号绑定")
L.USERINFO.FBBINDING_TIPS = T("游客账号绑定未登陆过游戏的FB账号后，绑定的FB账号游戏ID与此游客账号相同，您可以通过两种登陆方式中的任意一种采用该游戏ID进行游戏，账号更安全，绑定后还可获得绑定奖励哦（奖励在任务系统中领取）")
L.USERINFO.FBBINDING_BTHNAME = T("开始绑定")
L.USERINFO.FBBINDING_BTHNAME_SUCCESS = T("已绑定FB账号：{1}，账号更安全")
L.USERINFO.FBBINDING_BTHNAME_SUCCESS1 = T("已绑定FB账号，账号更安全")
L.USERINFO.FBBINDING_BTHNAME_FAIL1 = T("禁止FB用户绑定")
L.USERINFO.FBBINDING_BTHNAME_FAIL2 = T("当前游客已经绑定过FB账号")
L.USERINFO.FBBINDING_BTHNAME_FAIL3 = T("绑定失败，请稍后再试")
L.USERINFO.FBBINDING_BTHNAME_FAIL4 = T("当前游客已经绑定过FB账号：{1}")
L.USERINFO.FBBINDING_BTHNAME_FAIL5 = T("FB账号：{1}，已经被其他游客帐号绑定或已登陆过游戏，建议您重新选择一个FB账号进行绑定")
L.USERINFO.FBBINDING_BTHNAME_FAIL6 = T("绑定失败，已经被其他游客帐号绑定或已登陆过游戏，建议您重新选择一个FB账号进行绑定")
L.USERINFO.FBBINDING_BTHNAME_FAIL7 = T("已绑定FB账号：{1}")
L.USERINFO.FBBINDING_BTHNAME_FAIL8 = T("已绑定FB账号")

-- FRIEND MODULE
L.FRIEND.NO_FRIEND_TIP = T("暂无好友\n立即邀请好友可获得丰厚金币赠送！")
L.FRIEND.NO_FRIEND_TIP1 = T("您目前还没有好友，赶快来添加好友一起游戏吧")
L.FRIEND.NO_FRIEND_TIP2 = T("暂无好友")
L.FRIEND.HAD_INVITED    =T("您已经给全部好友发送过好友请求，每天只能给每个好友发送一次好友邀请哦")
L.FRIEND.SEND_CHIP = T("赠送金币")
L.FRIEND.SEND_CHIP_WITH_NUM = T("赠送{1}金币")
L.FRIEND.SEND_CHIP_SUCCESS = T("您成功给好友赠送了{1}金币。")
L.FRIEND.SEND_CHIP_TOO_POOR = T("您的金币太少了，请去商城购买金币后重试。")
L.FRIEND.SEND_CHIP_COUNT_OUT = T("您今天已经给该好友赠送过金币了，请明天再试。")
L.FRIEND.INVITE_DESCRIPTION = T("每邀请一位Facebook好友，可立即获赠{1}金币。FaceBook好友接受邀请并成功登录游戏，您还可以额外获得{2}金币奖励，多劳多送。\n")
L.FRIEND.INVITE_REWARD_TIP = T("您已累计获得了{1}金币的邀请奖励，多劳多得，天天都有哦！")
L.FRIEND.INVITE_WITH_FB = T("Facebook\n邀请")
L.FRIEND.INVITE_WITH_SMS = T("短信邀请")
L.FRIEND.INVITE_WITH_MAIL = T("邮件邀请")
L.FRIEND.SELECT_ALL = T("全选")
L.FRIEND.DESELECT_ALL = T("取消全选")
L.FRIEND.SEND_INVITE = T("邀请")
L.FRIEND.CHANGE_A_LOT = T("换一批")
L.FRIEND.INVITE_SUBJECT = T("您绝对会喜欢")
L.FRIEND.INVITE_CONTENT_OLDUSER=T("你快回来，我依然不能等待，你快回来，玩牌因你而精彩")
L.FRIEND.INVITE_CONTENT = T("为您推荐一个既刺激又有趣的扑克游戏，我给你赠送了40万的金币礼包，注册即可领取，快来和我一起玩吧！https://goo.gl/gWZlXp")
L.FRIEND.INVITE_SELECT_TIP = T("您已选择了#cfff600{1}#n位好友 发送邀请即可获得#cfff600{2}#n金币的奖励")
L.FRIEND.INVITE_FRIENDS_NUM_LIMIT_TIP = T("一次邀请最多选取50位好友")
L.FRIEND.INVITE_SUCC_TIP = T("成功发送了邀请！")
L.FRIEND.INVITE_FAIL_TIP = T("发送邀请失败，请稍后再试！")
L.FRIEND.INVITE_TOTAL_NUM = T("累计成功邀请人数：#cfff600{1}人#n")
L.FRIEND.INVITE_TOTAL_MONEY = T("累计获得奖励：#cfff600{1}金币#n")
L.FRIEND.CANNOT_SEND_MAIL = T("您还没有设置邮箱账户，现在去设置吗？")
L.FRIEND.CANNOT_SEND_SMS = T("对不起，无法调用发送短信功能！")
L.FRIEND.INVITE_GETREWARD_SUCC = T("成功领取奖励！")
L.FRIEND.INVITE_GETREWARD_FAIL = T("领取奖励失败，请稍后再试！")
L.FRIEND.MAIN_TAB_TEXT = {
    T("邀请好友"), 
    T("我的奖励"),
    T("规则"),
}

L.FRIEND.TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG = T("您的好友已达到300上限，请删除部分后重新添加")
L.FRIEND.INVITE_OLD_USER_TIP = T("您需要使用FB账号登陆才能发送邀请")
L.FRIEND.RESTORE_TEXT = T("注：恢复界面可恢复之前删除的好友")
L.FRIEND.RESTORE_BTN_TIP = T("恢复好友")
L.FRIEND.RETURN_BTN_TIP = T("返回")
L.FRIEND.RESTORE_NO_DATA = T("您没有可恢复的好友")
L.FRIEND.SEARCH_FRIEND = T("请输入FB好友名称")
L.FRIEND.TALK_FRIEND = T("聊天")
L.FRIEND.SEARCH_ID = T("请输入要添加的好友游戏ID")
L.FRIEND.SEARCH_ID_ERROR = T("您的输入不符合要求")
L.FRIEND.SEARCH_ID_FAIL = T("没有找到您要搜索的好友")
L.FRIEND.CHATMSG_NUM_MAX = T("最多保留最近100条聊天记录")
L.FRIEND.RECOMMEND_TITLE = T("好友推荐")
L.FRIEND.DETAIL_REWARD = T("奖励明细（最多只能查看七日内的记录）")
L.FRIEND.NOT_REWARD = T("暂无奖励信息哦！")
L.FRIEND.GET_ALL_REWARD = T("全部领取")
L.FRIEND.WORLD_TALK = T("世界聊天")
L.FRIEND.FRIEND_TALK = T("好友聊天")
L.FRIEND.CHOOSE_TALK = T("从左侧好友列表中选择好友开始聊天")
L.FRIEND.FAST_ADD = T("立即添加")


-- RANKING MODULE
L.RANKING.TRACE_PLAYER = T("追踪玩家")
L.RANKING.MAIN_TAB_TEXT = {
    T("每日牌局榜"), 
    T("每日盈利榜"),
    T("总金币榜"),
}
L.RANKING.SUB_TAB_TEXT = {
    T("好友排行"), 
    T("总排行"),
}
L.RANKING.RULE_TAB_TEXT = {
    T("每日牌局榜奖励"),
    T("规则"), 
}
L.RANKING.REWARD_RULE = T("奖励规则")
L.RANKING.RECORDS = T("{1} (赢:{2}/输:{3})")
L.RANKING.NO_RANK = T("未入榜")
L.RANKING.DETAIL = T("详情")
L.RANKING.IM_PLAY_RANK = T("马上玩牌冲榜")
L.RANKING.IM_PLAY = T("马上玩牌")
L.RANKING.RANK_TEXT = T("排名")
L.RANKING.REWARD_TEXT = T("奖励")
L.RANKING.DETAIL_CONTENT = T("亲，只要在玩#c49ff01 {1}#n 局，您就可以冲进排行榜啦！\n#cfae6ff每日牌局榜前{2}名玩家均可获得丰富的金币奖励、各种精品礼物！天天有奖，让您乐不停！具体奖励请查看【奖励规则】>【每日牌局榜奖励】#n")

-- SETTING MODULE
L.SETTING.TITLE = T("设置")
L.SETTING.LOGIN_TYPE_FACEBOOK = T("当前FACEBOOK账号登陆")
L.SETTING.LOGIN_TYPE_GUEST = T("当前游客登陆。若使用FB登陆游戏，每天可多获得{1}的免费筹码")
L.SETTING.NICK = T("昵称")
L.SETTING.LOGOUT = T("登出")
L.SETTING.SOUND_VIBRATE = T("声音和震动")
L.SETTING.SOUND = T("音效")
L.SETTING.VIBRATE = T("震动")
L.SETTING.OTHER = T("其他")
L.SETTING.AUTO_SIT = T("自动坐下")
L.SETTING.AUTO_BUYIN = T("自动购买")
L.SETTING.AUTO_BUYIN_TIPS =T("系统已自动帮你买入{1}金币")
L.SETTING.AUTO_BUYIN_TIPS2 =T("退出房间后您的剩余筹码会兑换成等额金币")
L.SETTING.APP_STORE_GRADE = T("喜欢我们，打分鼓励")
L.SETTING.CHECK_VERSION = T("检测更新")
L.SETTING.CURRENT_VERSION = T("当前版本号：V{1}")
L.SETTING.HAD_UPDATED = T("当前为最新版本")
L.SETTING.ABOUT = T("关于")
L.SETTING.FANS = T("粉丝页")
L.SETTING.DAFEN = T("打分")
L.HELP.TITLE = T("帮助")
L.SETTING.PUSH = T("推送")
L.SETTING.MESSAGE = T("喇叭消息")
L.SETTING.PLAY_RULES = T("玩法规则")
L.SETTING.FEEDBACK = T("反馈")

L.SETTING.SHARE = T("分享")
L.SETTING.SHARE_APK_TIP = T("分享(可通过蓝牙免流量转发)")
L.SETTING.SHARE_APK = T("转发游戏安装包")
L.SETTING.QRCODE_TIP = T("扫我下载游戏")
L.SETTING.THANK_FOR_YOU = T("感谢{1},因为有您,我们的游戏生活更精彩！")
L.SETTING.CURRENT_VERSION = T("当前版本号：{1}")
L.SETTING.SELF_SERVICE = T("自助服务")
L.SETTING.MSG_BOARD = T("留言回复")
L.SETTING.TYPE = T("请选择反馈类型")
L.SETTING.PAY = T("支付问题")
L.SETTING.LOGIN = T("登陆问题")
L.SETTING.ACCOUNT = T("账号问题")
L.SETTING.BUG = T("BUG反馈")
L.SETTING.SUGGEST = T("功能建议")
L.SETTING.COMPLAIN = T("投诉和意见")
L.SETTING.COMMIT = T("提交")
L.SETTING.HISTORY = T("历史反馈")
L.SETTING.FB_TITLE = T("您的反馈：")
L.SETTING.RE_TITLE = T("客服小雅回复：")
L.SETTING.SWITCH = T("切换账号")
L.SETTING.CHECK = T("查看>>")
L.SETTING.GAOJI = T("高级设置")
L.SETTING.PUTONG = T("普通设置")
L.SETTING.UPLOAD_PIC = T("上传图片")
L.SETTING.MUSIC = T("背景音乐")


L.HELP.SUB_TAB_TEXT = {
    T("问题反馈"),
    T("常见问题"),
    T("接龙规则"),
    T("QiuQiu规则"),
    T("等级说明")
}
L.HELP.FEED_BACK_HINT = T("您在游戏中碰到的问题或者对游戏有任何意见或者建议，我们都欢迎您给我们反馈")
L.HELP.NO_FEED_BACK = T("您现在还没有反馈记录")
L.HELP.FEED_BACK_SUCCESS = T("反馈成功!")
L.HELP.UPLOADING_PIC_MSG = T("正在上传图片，请稍候..")
L.HELP.MUST_INPUT_FEEDBACK_TEXT_MSG = T("请输入反馈内容")
L.HELP.MUST_INPUT_FEEDBACK_PHONE_NUM=T("请输入正确的手机号码")
L.HELP.FEEDBACK_TYPE = T("请选择反馈类型")
L.HELP.FAQ = {
    {
        T("如何获得免费金币"),
        T("如何获得免费金币回答")
    },
    {
        T("如何购买金币"),
        T("如何购买金币回答")
    },
    {
        T("如何退出游戏"),
        T("如何退出游戏回答")
    },
    {
        T("断线、不能登陆游戏或者不能登陆房间，怎么办"),
        T("断线、不能登陆游戏或者不能登陆房间，怎么办回答")
    },
    {
        T("充值之后，为什么还没得到金币"),
        T("充值之后，为什么还没得到金币回答")
    },
}

L.HELP.RULE = {
    {
        T("出牌"),
        T("要出的这张牌至少有一头的点数要跟当时头或尾点数相同才可出牌进行对接")
    },
    {
        T("游戏结束"),
        T("●当其中一个玩家出完牌或没有玩家能继续对接布局时，游戏结束\n") .. 
        T("●当出现死路时（玩家都不能出牌对接布局时）")
    },
    {
        T("赢家"),
        T("当有玩家出完牌时，则该出完牌的玩家为赢家；当出现死路时，赢家为牌最少的玩家，当牌张数一样时，牌最小的玩家赢")
    },
    {
        T("结算"),
        T("●结算时按照先出完牌的玩家最后一张牌类型，选择对应的结算方式\n") .. 
        T("  SINGLE:制胜牌只能放在其中一个头或尾。赢家拿注池, 输家不需要再付额外金币。\n") .. 
        T("  DOUBLE:制胜牌只能放在其中一个头或尾，制胜牌是双牌。赢家拿注池，然后其余每个玩家需要另付1倍低注。\n") .. 
        T("  TRIPLE:制胜牌能放在两边，头和尾。赢家拿注池，然后其余每个玩家需要另付2倍低注。\n") .. 
        T("  QUARTET:制胜牌能放在两边，头和尾，制胜牌是双牌。赢家拿注池，然后其余每个玩家需要另付3倍低注。\n") .. 
        T("●当出现死路时，此时赢家没有出完牌，牌最小的玩家为赢家，结算方式按照死路方式计算\n") .. 
        T("  DEAD END（死路）:玩家都不能出牌对接布局. 赢家是牌最少的玩家。如果有平分的，拥有最小的牌赢, 输家不需要再付额外金币")
    },
    {
        T("过"),
        T("当玩家没有能拿出的牌（没有能对接布局的牌），则该玩家必须过，过的玩家需要立即给上一个最后出牌的玩家付过费，如果下一个玩家也没有能出的牌则他也要付过费，直到有玩家可以对接牌")
    },
    {
        T("超时"),
        T("超时后系统将自动帮你出牌")
    },
}

L.HELP.RULE_QIUQIU = {
    {
        T("牌型介绍"),
        ""
    },
    {
        T("比牌"),
        T("●比牌原则\n") .. 
        T("●出牌原则\n") .. 
        T("●比牌最后分数相同的情况")
    },
    {
        T("下注"),
        T("●两轮下注\n") .. 
        T("●下注步骤") 
    },
}

L.HELP.LEVEL = {
--    {
--        T("经验获取方式"),
--        T("经验获取方式回答")
--    }    
}
L.HELP.UPLOAD_PHOTO = T("发现新版本")

L.ABOUT.TITLE = T("关于")
L.ABOUT.UID = T("当前玩家ID: {1}")
L.ABOUT.VERSION = T("版本号：V{1}")
L.ABOUT.FANS = T("官方粉丝页：")
L.ABOUT.FANS_URL = GameConfig.FANS_URL 
L.ABOUT.FANS_OPEN = GameConfig.FANS_URL
L.ABOUT.SERVICE = T("服务条款与隐私策略")
L.ABOUT.SERVICE_URL="http://www.boyaa.com/information.html"
L.ABOUT.NEED_URL="http://www.boyaa.com/termofservice.html"
L.ABOUT.COPY_RIGHT = "Copyright © 2015 Boyaa Interactive International Limited."
L.DAILY_TASK.GET_REWARD = T("领取")
L.DAILY_TASK.HAD_FINISH = T("已领取")
L.DAILY_TASK.AUTO_GET_REWARD = T("已自动领取")
L.DAILY_TASK.TO_DO = T("去做任务")
L.DAILY_TASK.NOT_FINISH = T("未完成")
L.DAILY_TASK.COMPLETE_REWARD = T("恭喜你完成了任务：{1}")
L.DAILY_TASK.CHIP_REWARD = T("奖励{1}金币")
L.DAILY_TASK.DAILY_TASK = T("日常任务")
L.DAILY_TASK.GROW_TASK = T("成长任务")
L.DAILY_TASK.REWARD = T("奖励")
L.DAILY_TASK.REWARD_TIP = T("所有任务完成以下对应个数即可获得额外奖励")

-- count down box
L.COUNTDOWNBOX.TITLE = T("倒计时宝箱")
L.COUNTDOWNBOX.SITDOWN = T("坐下才可以继续计时。")
L.COUNTDOWNBOX.FINISHED = T("您今天的宝箱已经全部领取，明天还有哦。")
L.COUNTDOWNBOX.NEEDTIME = T("再玩{1}分{2}秒，您将获得{3}金币。")
L.COUNTDOWNBOX.NEEDNUM = T("再玩{1}局才可开启宝箱。")
L.COUNTDOWNBOX.NEEDLOGIN = T("请登录后领取")
L.COUNTDOWNBOX.REWARD = T("恭喜您获得宝箱奖励{1}金币。")
L.COUNTDOWNBOX.REWARD_SOME = T("恭喜您获得{1}局宝箱奖励:{2}")
L.COUNTDOWNBOX.REWARD_EEOR_3 = T("您已领取过此宝箱")
L.COUNTDOWNBOX.REWARD_EEOR_0 = T("您未达成领取条件")

L.COUNTDOWNBOX.EXP_LACK = T("下一等级奖励{1}")
L.COUNTDOWNBOX.CLICK_GET = T("点击领取")
L.COUNTDOWNBOX.CLICK_SEE = T("点击查看")
L.COUNTDOWNBOX.DAILYTASK = T("每日任务")
L.COUNTDOWNBOX.COUNTDOWNBOX = T("在线宝箱")
L.COUNTDOWNBOX.UPGRADE = T("升级奖励")
L.COUNTDOWNBOX.TODAYFINISH = T("已经全部领取")

L.COUNTDOWNBOX.RULE_TAB_TEXT = {
    T("单机奖励"),
    T("规则"), 
}
L.COUNTDOWNBOX.GAME_NUM_LABEL = T("局数")
L.COUNTDOWNBOX.AWARD_LABEL = T("奖励")

L.NEWESTACT.NO_ACT = T("暂无活动")
L.NEWESTACT.TITLE = T("最新活动")
L.NEWESTACT.LOADING = T("加载中...")
L.FEED.SHARE_SUCCESS = T("分享成功")
L.FEED.SHARE_FAILED = T("分享失败")
L.FEED.LOGIN_REWARD = {
    name = T("太棒了!我在接龙领取了{1}金币的奖励，快来和我一起玩吧！"),
    caption = T("天天登录金币送不停"),
    link = "http://goo.gl/JNA1B2",
    picture = "https://bycdn6-i.akamaihd.net/dominogaple/androidid/images/feed/login.png",
    message = "",
}
L.FEED.EXCHANGE_CODE = {
    name = T("我用接龙粉丝页的兑换码换到了{1}的奖励，快来和我一起玩吧！"),
    caption = T("粉丝奖励兑换有礼"),
    link = "http://goo.gl/JNA1B2",
    picture = "https://bycdn6-i.akamaihd.net/dominogaple/androidid/images/feed/fans_reward.jpg",
    message = "",
}
L.FEED.WHEEL_ACT = {
    name = T("快来和我一起玩开心转转转吧，每天登录就有三次机会！"),
    caption = T("开心转转转100%%中奖"), 
    link = "http://goo.gl/JNA1B2",
    picture = "http://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/WHEEL_ACT1.jpg",
    message = "",
}
L.FEED.WHEEL_REWARD = {
    name = T("我在接龙的幸运转转转获得了{1}的奖励，快来和我一起玩吧！"),
    caption = T("开心转转转100%%中奖"),
    link = "http://goo.gl/JNA1B2",
    picture = "http://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/WHEEL_REWARD1.jpg",
    message = "",
}
L.FEED.UPGRADE_REWARD = {
    name = T("太棒了，我刚刚在接龙成功升到了{1}级，领取了{2}的奖励，快来膜拜吧！"),
    caption = T("升级领取大礼"),
    link = "http://goo.gl/JNA1B2",
    picture = "https://bycdn6-i.akamaihd.net/dominogaple/androidid/images/feed/level{1}.png",
    message = "",
}

-- message
L.MESSAGE.TAB_TEXT = {
    T("系统消息"),
    T("系统公告"),
    T("好友消息")
}
L.MESSAGE.EMPTY_PROMPT = T("您现在没有消息记录")
L.MESSAGE.NONE_FRIEND = T("您还没有任何好友消息呢，不如去玩玩牌，交个朋友吧！")
L.MESSAGE.NONE_SYS_MSG = T("暂无系统消息")
L.MESSAGE.NONE_NOTICE = T("暂无公告")
L.MESSAGE.NUM = T("消息最多显示50条,保存3天")
--奖励兑换码
L.ECODE.TITLE = T("奖励兑换")
L.ECODE.EDITDEFAULT = T("请输入6位数字奖励兑换码")
L.ECODE.DESC = T("关注粉丝页可免费领取奖励兑换码,我们还会不定期在官方粉丝页推出各种精彩活动,谢谢关注。")
L.ECODE.EXCHANGE = T("兑  奖")
L.ECODE.SUCCESS = T("恭喜您，兑奖成功！\n您获得了{1}")
L.ECODE.ERROR_FAILED = T("兑奖失败，请确认您的兑换码是否输入正确！")
L.ECODE.ERROR_INVALID = T("兑奖失败，您的兑换码已经失效。")
L.ECODE.ERROR_USED = T("兑奖失败，每个兑换码只能兑换一次。\n您已经兑换到了{1}")
L.ECODE.ERROR_END = T("领取失败，本次奖励已经全部领光了，关注我们下次早点来哦")
L.ECODE.FANS = T("关注粉丝页")
--大转盘
L.WHEEL.SHARE = T("分享")
L.WHEEL.REMAIN_COUNT = T("剩余抽奖数")
L.WHEEL.TIME = T("次")
L.WHEEL.DESC1 = T("每天登录即可免费获得3次抽奖机会")
L.WHEEL.DESC2_PRE = T("每次")
L.WHEEL.DESC2_POST = T("中奖")
L.WHEEL.DESC3 = T("绝不落空，最高可赢取一千万金币。")
L.WHEEL.DESC4 = T("立即开始吧，点击开始抽奖按钮！")
L.WHEEL.PLAY = T("开始\n抽奖")
L.WHEEL.REWARD = {
    T("中大奖了!"),
    T("恭喜您,抽中{1}的奖励。")
}


--银行
L.BANK.BANK_BUTTON_LABEL = T("银行")
L.BANK.BANK_GIFT_LABEL = T("我的礼物")
L.BANK.BANK_DROP_LABEL = T("我的道具")
L.BANK.BANK_LABA_LABEL = T("喇叭")
L.BANK.BANK_TOTAL_CHIP_LABEL = T("银行内资产")
L.BANK.SAVE_BUTTON_LABEL = T("存钱")
L.BANK.DRAW_BUTTON_LABEL = T("取钱")
L.BANK.CANCEL_PASSWORD_SUCCESS_TOP_TIP = T("取消密码成功")
L.BANK.CANCEL_PASSWORD_FAIL_TOP_TIP = T("取消密码失败")
L.BANK.EMPYT_CHIP_NUMBER_TOP_TIP = T("请输入金额")
L.BANK.USE_BANK_NO_VIP_TOP_TIP = T("你不是VIP用户不能使用保险箱功能")
L.BANK.USE_BANK_SAVE_CHIP_SUCCESS_TOP_TIP = T("存钱成功")
L.BANK.USE_BANK_SAVE_CHIP_FAIL_TOP_TIP = T("存钱失败")
L.BANK.USE_BANK_DRAW_CHIP_SUCCESS_TOP_TIP = T("取钱成功")
L.BANK.USE_BANK_DRAW_CHIP_FAIL_TOP_TIP = T("取钱失败")
L.BANK.BANK_POPUP_TOP_TITIE = T("个人银行")
L.BANK.BANK_INPUT_TEXT_DEFAULT_LABEL = T("请输入密码")
L.BANK.BANK_CONFIRM_INPUT_TEXT_DEFAULT_LABEL = T("请再次输入密码")
L.BANK.BANK_INPUT_PASSWORD_ERROR = T("你输入的密码有误，请从新输入")
L.BANK.BANK_SET_PASSWORD_TOP_TITLE = T("设置密码")
L.BANK.BANK_SET_PASSWORD_SUCCESS_TOP_TIP = T("设置密码成功")
L.BANK.BANK_SET_PASSWORD_FAIL_TOP_TIP = T("设置密码失败")
L.BANK.BANK_LEVELS_DID_NOT_REACH = T("你的等级没有达到七级，不能使用保险箱")
L.BANK.BANK_CANCEL_OR_SETING_PASSWORD = T("取消或者设置密码")
L.BANK.BANK_FORGET_PASSWORD_FEEDBACK = T("忘记密码请向管理员反馈")
L.BANK.BANK_FORGET_PASSWORD_BUTTON_LABEL = T("忘记密码")
L.BANK.BANK_SETTING_PASSWORD_BUTTON_LABEL = T("设置密码")
L.BANK.BANK_CACEL_PASSWORD_BUTTON_LABEL = T("取消密码")
--老虎机
L.SLOT.NOT_ENOUGH_MONEY = T("老虎机购买失败,你的金币不足")
L.SLOT.SYSTEM_ERROR = T("老虎机购买失败，系统出现错误")
L.SLOT.PLAY_WIN = T("你赢得了{1}金币")
L.SLOT.TOP_PRIZE = T("玩家 {1} 玩老虎机抽中大奖，获得金币{2}")
L.SLOT.FLASHBAR_TIP = T("头奖：{1}")
L.SLOT.FLASHBAR_WIN = T("你赢了：{1}")
L.SLOT.AUTO = T("自动")
-- 99
--房间新手引导
L.ROOM_NEWBIE_GUIDE.SIT_HERE = T("你坐在这里")
L.ROOM_NEWBIE_GUIDE.MAKE_OPERATION = T("必须在规定的时间内作出选择，否则系统将自动看牌或弃牌")
L.ROOM_NEWBIE_GUIDE.AUTO_CALL_ANY = T("轮到你说话时系统将自动帮你跟任何数值的注，无需你手动操作")
L.ROOM_NEWBIE_GUIDE.AUTO_CHECK_OR_FOLD = T("轮到你说话时系统将自动帮你看牌或弃牌，无需你手动操作")
L.ROOM_NEWBIE_GUIDE.AUTO_CALL = T("系统将自动跟注xx筹码，无需你手动操作")
L.ROOM_NEWBIE_GUIDE.SEND_BROADCAST = T("点击切换，可以发送喇叭消息")
-- 99

--升级弹框
L.UPGRADE.OPEN = T("打开")
L.UPGRADE.SHARE = T("分享")
L.UPGRADE.GET_REWARD = T("获得{1}")
L.UPGRADE.HAS_GET_REWARD = T("你已经领取过该等级的奖励")
L.UPGRADE.EXP_NOT_ENOUGH = T("经验值不足")
L.UPGRADE.UPGRADE_FAIL = T("更新等级失败")
L.UPGRADE.LEVEL_UP_MSG = T("您升级为Lv.{1}啦！")

L.GIFT.SET_SELF_BUTTON_LABEL = T("设为我的礼物")
L.GIFT.BUY_TO_TABLE_GIFT_BUTTON_LABEL = T("买给牌桌x{1}")
L.GIFT.CURRENT_SELECT_GIFT_BUTTON_LABEL = T("你当前选择的礼物")
L.GIFT.PRESENT_GIFT_BUTTON_LABEL = T("赠送")
L.GIFT.DATA_LABEL = T("天")
L.GIFT.SELECT_EMPTY_GIFT_TOP_TIP = T("请选择礼物")
L.GIFT.BUY_GIFT_SUCCESS_TOP_TIP = T("购买礼物成功")
L.GIFT.BUY_GIFT_FAIL_TOP_TIP = T("购买礼物失败")
L.GIFT.BUY_GIFT_FAIL_NOT_ENOUGH = T("购买礼物失败，金币不足")
L.GIFT.SET_GIFT_SUCCESS_TOP_TIP = T("设置礼物成功")
L.GIFT.SET_GIFT_FAIL_TOP_TIP = T("设置礼物失败")
L.GIFT.PRESENT_GIFT_SUCCESS_TOP_TIP = T("赠送礼物成功")
L.GIFT.PRESENT_GIFT_FAIL_TOP_TIP = T("赠送礼物失败")
L.GIFT.PRESENT_GIFT_FAIL_NOT_ENOUGH = T("赠送礼物失败，金币不足")
L.GIFT.PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP = T("赠送牌桌礼物成功")
L.GIFT.PRESENT_TABLE_GIFT_FAIL_TOP_TIP = T("赠送牌桌礼物失败")
L.GIFT.PRESENT_TABLE_GIFT_FAIL_NOT_ENOUGH = T("赠送牌桌礼物失败，金币不足")
L.GIFT.NOT_ENOUGH_CHIPS = T("金币不足")
L.GIFT.NO_GIFT_TIP = T("暂时没有礼物")
L.GIFT.MY_GIFT_MESSAGE_PROMPT_LABEL = T("点击选中既可在牌桌上展示才礼物")
L.GIFT.SUB_TAB_TEXT_SHOP_GIFT = {
    T("热销"), 
    T("精品"),
    T("奢华"),
    T("节日"),
    T("豪华"),
}
L.GIFT.SUB_TAB_TEXT_MY_GIFT = {
    T("自己购买"), 
    T("牌友赠送")
}

L.GIFT.MAIN_TAB_TEXT = {
    T("商城礼物"), 
    T("我的礼物")
}

-- 个人动态
L.DYNAMIC.MY_DYNAMIC_TITLE = T("我的动态")
L.DYNAMIC.MY_DYNAMIC_TIPS = T("普通用户最多保存10条动态") --，VIP用户最多保存30条动态
L.DYNAMIC.OTHER_DYNAMIC_TITLE = T("个人动态")
L.DYNAMIC.OTHER_DYNAMIC_TIPS = T("即将开放图片动态，敬请期待！")
L.DYNAMIC.TOTAL_DYNAMIC = T("全部动态：{1}条")
L.DYNAMIC.LIKE_ALREADY_TIPS = T("您已经点过赞了！")
L.DYNAMIC.LIKE_TO_MUCH_TIPS = T("抱歉，您今天不能再对该用户点赞了")
L.DYNAMIC.LIKE_LONGTIME_TIPS = T("该动态过去太久不能点赞")
L.DYNAMIC.NO_DYNAMIC = T("还没有动态哦！")
L.DYNAMIC.LIKE_SUCCESS = T("点赞成功")
L.DYNAMIC.LIKE_FAIL = T("点赞失败")
L.DYNAMIC.DEL_SUCCESS = T("成功删除动态")
L.DYNAMIC.DEL_FAIL = T("删除动态失败")

-- 破产
L.CRASH.PROMPT_LABEL = T("您获得{1}金币的破产救济金，同时还获得当日充值优惠一次，立即充值，重振雄风！")
L.CRASH.THIRD_TIME_LABEL = T("您获得最后一次{1}金币的破产救济金，同时还获得当日充值优惠一次，立即满血复活，再战江湖！")
L.CRASH.OTHER_TIME_LABEL = T("您已经领完所有破产救济金了，您可以去商城购买金币，每天登录还有免费金币赠送哦！")
L.CRASH.INVITE_LABEL = T("哎呀，您破产了，不要着急，马上邀请好友即可获得大量免费金币，邀请越多，奖励越多！")
L.CRASH.TITLE = T("你破产了！") 
L.CRASH.CHIPS_TIPS = T("破产救济")

-- 邀请奖励
L.CRASH.INVITE_FRIEND_TIPS = T("邀请奖励")
L.CRASH.INVITE_FRIEND_INFO = T("邀请好友可以获得免费金币")
L.CRASH.BTN_GET_TEXT2 = T("立即邀请")
-- 购买金币
L.CRASH.BUY_CHIPS_TIPS = T("购买金币")
L.CRASH.BUY_CHIPS_INFO = T("现在购买更优惠哦")
L.CRASH.BTN_GET_TEXT3 = T("立即购买")

--99
L.CRASH.FIRST_PAY_TIPS_CONTENT=T("首次充值可额外获得大量的筹码奖励")
L.CRASH.FIRST_PAY_TIPS_TITLE=T("首充有礼")
L.CRASH.IMM_CHARGE=T("立即充值")
--99
L.CRASH.INVITE_FRIEND=T("邀请好友")
L.CRASH.INVITE_FRIEND2 = T("您可以返回大厅邀请好友")

L.CRASH.CHIPS = T("{1}游戏币")
L.CRASH.CHIPS_INFO = T("({1}天内仅限{2}次)")
L.CRASH.INVITE = T("FB邀请")
L.CRASH.INVITE_INFO = T("(邀请1个新朋友并成功进游戏)")
L.CRASH.RECALL = T("FB招回")
L.CRASH.RECALL_INFO = T("(成功召回1个老用户回归游戏)")
L.CRASH.GET = T("立即领取")
L.CRASH.PRODUCT = T("{1}游戏币\n{2}THB")
L.CRASH.GET_REWARD = T("获得{1}游戏币")
L.CRASH.GET_REWARD_FAILE=T("获取游戏币补助失败")
L.CRASH.E2P_TIP = T("仅限E2P")

L.GAMEBOARDCASTNOTICE.SYSTEM = T("[系统]")
L.GAMEBOARDCASTNOTICE.PLAYER = T("[玩家]")

L.LIMIT_TIME_GIFTBAG.TIP = T("活动期间花费#cfff600{1} {2}#n购买#cfff600{3}#n金币, 将同时获得商城额外赠送以下豪华大礼包")
L.LIMIT_TIME_GIFTBAG.TEXT1 = T("结束倒计时:")
L.LIMIT_TIME_GIFTBAG.TEXT2 = T("支付方式")
L.LIMIT_TIME_GIFTBAG.TITLE = T("限时礼包")
L.LIMIT_TIME_GIFTBAG.TEXT3 = T("超值购买机会，仅此一次哦")
L.LIMIT_TIME_GIFTBAG.PERCENT = T("+{1}%%")
L.LIMIT_TIME_GIFTBAG.END = T("限时礼包活动已结束，下次一定记得要把握住机会哦")

L.LIMIT_TIME_EVENT.PERSON_EVENT = T("个人活动")
L.LIMIT_TIME_EVENT.FULLSERVER_EVENT = T("全服活动")
L.LIMIT_TIME_EVENT.TIME_COUNTDOWN = T("活动倒计时:#cffd700{1}#n")
L.LIMIT_TIME_EVENT.GAME_COUNT = T("当前个人进度:#cffd700{1}#n")
L.LIMIT_TIME_EVENT.END_TIME = T("截止日期:#cffd700{1}#n")
L.LIMIT_TIME_EVENT.RANK_TILE = T("参与玩家 (前{1}名)")
L.LIMIT_TIME_EVENT.RANK_TILE1 = T("参与玩家")
L.LIMIT_TIME_EVENT.FULLSERVER_EVENT_NAME = T("当前全服玩家进度")
L.LIMIT_TIME_EVENT.TIPS_1 = T("已经领取过了")
L.LIMIT_TIME_EVENT.TIPS_2 = T("任务未完成")
L.LIMIT_TIME_EVENT.TIPS_3 = T("领取失败，请稍后再试")
L.LIMIT_TIME_EVENT.TIPS_4 = T("活动不存在或已结束，请稍后再试")
L.LIMIT_TIME_EVENT.TIPS_5 = T("您未参与该活动")


L.PHOTO_MANAGER.TITLE = T("相册管理")
L.PHOTO_MANAGER.UPLOAD = T("上传")
L.PHOTO_MANAGER.SET_HEAD_ICON = T("设为头像")
L.PHOTO_MANAGER.NOT_HAVE_PHOTO = T("请上传照片")
L.PHOTO_MANAGER.TIPS = T("禁止上传色情头像，一旦发现，该头像将被立即删除，同时账号可能会受到封号处罚")

L.LOTTERY.NUM = T("抽奖次数:{1}")
L.LOTTERY.TIP = T("规则:每赢牌#cffd700{1}#n局即可获得一次抽奖机会哦,每日最多可抽奖#cffd700{2}#n次")
L.LOTTERY.TIP1 = T("您暂无抽奖机会噢，赶快去赢牌获取抽奖机会吧")
L.LOTTERY.TIP2 = T("您今日抽奖次数已达到上限，无法再次抽奖了哦")
L.LOTTERY.TIP3 = T("稍等，正在为您抽奖哦")
L.LOTTERY.TIP4 = T("抽奖失败")

L.SCORE.TITLE = T("评分")
L.SCORE.TITLE1 = T("免费奖励")
L.SCORE.TITLE2 = T("谢谢您的评价，我们会不断的优化和改进我们的游戏")
L.SCORE.TIP = T("感谢您对游戏的参与和支持，这里邀请您对我们的游戏进行评分。")
L.SCORE.TIP1 = T("恭喜您获得免费领奖的机会，前往谷歌商店为游戏进行五星好评，可获得#cfff600{1}金币#n奖励")
L.SCORE.TIP2 = T("您可以写下优化意见给我们")
L.SCORE.TIP3 = T("请为游戏评分。。。")
L.SCORE.LEVEL = {T("很差"),T("有待改进"),T("一般"),T("良好"),T("优秀")}
L.SCORE.STAR = T("【提交{1}星评分】")


L.UNITY_ADS = {}
L.UNITY_ADS.TITLE = T("看视频，赚奖励")
L.UNITY_ADS.VIDEO_NOT_READY = T("视频准备中，请先去玩牌，稍后再来观看")
L.UNITY_ADS.VIDEO_MAX_COUNT = T("今日已经达到播放次数上限")
L.UNITY_ADS.VIDEO_ERROR = T("视频未成功播放完")
L.UNITY_ADS.VIDEO_GET_REWARD = T("视频观看完毕，恭喜您获得: ")

L.DOWNLOAD_GAMES = {}
L.DOWNLOAD_GAMES.TITLE = T("安装游戏，送奖励")
L.DOWNLOAD_GAMES.BTN_EXCHANGE = T("兑换")
L.DOWNLOAD_GAMES.BTN_EXCHANGE_FINISH = T("已兑换")
L.DOWNLOAD_GAMES.BTN_DOWNLOAD = T("去下载")
L.DOWNLOAD_GAMES.EXCHANGE_TIILE = T("输入新游戏内的数字账号ID")
L.DOWNLOAD_GAMES.EXCHANGE_HINT = T("请输入数字ID")
L.DOWNLOAD_GAMES.NO_TEXT_HINT = T("数字ID不能为空")
L.DOWNLOAD_GAMES.BTN_GET_REWARD = T("领取奖励")
L.DOWNLOAD_GAMES.GET_REWARD = T("恭喜你，获得: ")


L.UPDATE = {}
L.UPDATE.COPY_RIGHT = "Copyright © 2015 Boyaa Interactive International Limited."
L.UPDATE.CHECKING_VERSION = "Cek versi"
L.UPDATE.CHECKING_RES_UPDATE = "Cek Update…"
L.UPDATE.DOWNLOADING_MSG = "Download paket ({1}/{2})"
L.UPDATE.UPDATE_NOW = "Update sekarang"
L.UPDATE.UPDATE_LATER = "Update nanti"
L.UPDATE.DOWNLOAD_ERROR = "Download gagal"
L.UPDATE.DOWNLOAD_NOT_IN_WIFI_PROMPT_TITLE = "Peringatan"
L.UPDATE.SPEED = "Kecepatan Download:{1}"
L.UPDATE.DOWNLOAD_NOT_IN_WIFI_PROMPT_MSG = "Kamu sedang tidak menggunakan wifi, paket data akan terpakai. Yakin update?"
L.UPDATE.UPDATE_COMPLETE = "Update selesai"
L.UPDATE.IS_ALREADY_THE_LATEST_VERSION = "Sudah versi terbaru"
L.UPDATE.BAD_NETWORK_MSG = "Koneksi tidak bagus, update gagal"
L.UPDATE.UPDATE_CANCELED = "Update dibatalkan"
L.UPDATE.DOWNLOAD_SIZE = "Ukuran paket{1}"
L.UPDATE.DOWNLOAD_PROGRESS = "Download paket{1}%"
L.UPDATE.QUIT_DIALOG_TITLE = "Keluar"
L.UPDATE.QUIT_DIALOG_MSG = "Yakin keluar game? Aku tidak rela ~\\(≧▽≦)/~ "
L.UPDATE.QUIT_DIALOG_CONFIRM = "Keluar"
L.UPDATE.QUIT_DIALOG_CANCEL = "Batal"
L.UPDATE.TITLE = T("发现新版本")
L.UPDATE.DO_LATER = T("以后再说")
L.UPDATE.HAD_UPDATED = T("您已经安装了最新版本")
L.UPDATE.TOOLOW_NEED_UPDATE = T("当前版本不支持此功能，请更新最新版本!")
L.UPDATE.AWARD_TIP = T("更新到最新版本就可以获得奖励!")
L.UPDATE.TIPS = {
    T("印尼玩家最喜爱的多米诺游戏，汇聚了上百万玩家在此相互卡牌竞技"),
    T("游戏内多种玩法任你玩，独特而有趣，让您的休闲时光更加愉快"),
    T("您还可以在这里认识很多朋友"),
    T("游戏内每天有很多免费金币可以领取哦"),
    T("时尚又有趣的UI设计使得游戏氛围更为舒适"),
    T("邀请FB好友对战，游戏交友两不误，还可获得很多金币哦"),
    T("游客和FB用户点击自己的头像弹框或者性别标志可更换头像和性别哦"),
    T("游戏内可以向你喜欢或者讨厌的玩法扔互动道具哦，有趣又好玩"),
    T("游客号和Fb号都可快捷登陆"),
    T("登陆不进入游戏时，可以检查下您的网络是否良好"),
    T("有问题欢迎及时向我们反馈哦")
}

L.LUAERROR = {}
L.LUAERROR.ERROR_TIP = T("不好意思，出了点意外!")
return lang