local GameData = {};

GameData.registerRewardAward  = nil  -- 注册奖励  
-- { 是个table 
--   GameData.registerRewardAward.config
--   GameData.registerRewardAward.reward  }

GameData.switchData   = nil;  -- 加载友盟开关配置
GameData.GIFT_JSON =    nil;  --礼物配置Json
GameData.PROPS_JSON =    nil;  --生商城道具列表配置Json
GameData.MSGTPL_ROOT =    nil;  --消息模板配置Json
GameData.LEVEL_JSON =    nil;  --等级配置Json
GameData.EXP_JSON   =   nil; --不同场次对应经验配置json
GameData.UPLOAD_PIC =    nil;  -- 头像上传地址
GameData.WHEEL_CONF =    nil;  --幸运转盘配置Json
GameData.fbInviteNumCfg=   nil; --fb显示好友数
GameData.TASK_JSON =    nil;  --任务模板配置Json
GameData.STATSWITCH_JSON =    nil;  --友盟上报开关配置Json
GameData.LOGOUT_JSON =    nil;  --退出弹窗的配置
GameData.SAMPINGAN_JSON =    nil;  --边注玩法配置
GameData.ROOMFUNCTION_JSON =    nil;  --房间功能配置
GameData.NOTICE_JSON =    nil;  --公告配置
GameData.LOGINREWARD_JSON =    nil;  --登陆奖励配置
GameData.RANKREWARD_JSON =    nil;  --登陆奖励配置
GameData.SINGLEREWARD_JSON =    nil;  --单机奖励配置
GameData.SELF_SERVICE_JSON = nil;  --自助服务的问题配置Json

GameData.hallip 			= nil;     -- ip,port
GameData.isCreate   = nil;     -- 如果是第一次创建，拉取FB邀请数据，判断是谁拉的
GameData.isOnline  = nil;     -- 是否在线
GameData.activityNum = nil;     -- 大厅活动按钮红点相关


GameData.friendUidList = nil;     -- 好友uid列表
GameData.chatRecord		= nil;     -- 好友聊天记录
GameData.GIFT_SHOP		= 1;


GameData.isSendChips		= nil;     -- 是否赠送过好友金币
GameData.inviteSendChips		= nil;     -- 邀请发送奖励
GameData.inviteBackChips		= nil;     -- 邀请回来奖励
GameData.recallSendChips		= nil;     -- 召回发送奖励
GameData.recallBackChips		= nil;     -- 召回奖励
GameData.roomBuyIn		= nil;     -- 
GameData.nextRwdLevel		= nil;     -- 
GameData.userOnline  		= nil;     -- 当前在线人数
GameData.itemDiscount 		= nil;     -- 商品折扣配置
GameData.invitableLevel = nil;    --  升级奖励
GameData.broadcastPrice = nil;    --  喇叭广播费用
GameData.smsInviteAward = nil;    --  短信邀请送多少
GameData.emailInviteAward = nil;    -- email邀请送多少
GameData.fbInviteNumCfg = nil;    --  fb显示好友数
GameData.inviteForRegist = nil;    --  邀请注册送多少

GameData.loginReward = nil;    -- 登录奖励
GameData.loginWithFBOtherAward = nil;    -- 用fb登录额外送多少
GameData.privateRoom = nil;    -- 私人房【刷新间隔、列表数量】
GameData.MessageShowTap = nil;    -- 消息中心显示页码
GameData.gpqrCode = nil;    --  二维码图片地址
GameData.firstRechargeConfig = nil;    -- 首充配置信息
GameData.firstRechargeStatus = nil;    -- 是否首充的标识
GameData.canEditAvatar = nil;    --  fb能否更改个人信息

GameData.newerStatis = nil;    --  
GameData.dropMessageFlag = nil;    --
GameData.commentUrl = nil;    --
GameData.FreeMoneyModTips = nil;    --


-- GameData.b_picture   -- 貌似没用
-- GameData.m_picture   -- 貌似没用

-- GameData[self.plugin.CONFIG_KEY]  = nil; --加载支付配置 url

-- [tostring] = {'aUser.mavatar', 'aUser.memail', 'aUser.sitemid'},
--                     [tonumber] = {
--                         'aUser.lid', 'aUser.mid', 'aUser.mlevel', 
--                         'aUser.mltime', 'aUser.win',  'aUser.lose','aUser.money', 'aUser.sitmoney', 
--                         'isCreate', 'loginInterval' , 'isFirst', 'mid', 'aUser.exp',
--                         'ADCLoginOn','ADCLeaveOn','DropActivity','hallShowNewSign','newerStatis','regAges'


return GameData