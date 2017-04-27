-- require("view.view_config");
require("game.uiex.uiexInit");
require("game.anim.transition");
require("game.enterRoom.enterRoomManager")

RoomViewPosition = require("game.roomGaple.config.roomViewPosition")

nk = nk or {}

nk.reLoginRoom_ = false
nk.reLoginRoom = false

nk.ignoreBack = false

nk.maxDiscount = 0

nk.loginRoomSuccess = false --是否成功进入房间

nk.enterRoomFromChoosePopup = false --是否从选场界面进入房间

nk.CommonExpManage = require("game.userInfo.roomUserinfo.commonExpManage")

nk.updateFunctions = require("game.common.updateFunctions")

-- 公共UI
nk.pokerUI = import("game.pokerUI.init")

nk.GameObject = import("game.common.component.gameObject")

nk.LoadingAnim = require("game.anim.loadingAnim")

nk.tid = 0
--服务器版本
nk.serverVersion = 33

nk.isInRoomScene = false
nk.isInSingleRoom = false
nk.roomSceneType = ""
nk.onlineUserData = {}

nk.SWF = {}


local DataProxy = import("boyaa.proxy.DataProxy")
nk.DataProxy  = new(DataProxy)

local TimeUtil = import("game.common.timeUtil")
nk.TimeUtil = new(TimeUtil)

-- 设置元表
local mt = {}
mt.__index = function (t, k)
    if k == "userData" then
        return nk.DataProxy:getData(nk.dataKeys.USER_DATA)
    end
end
setmetatable(nk, mt)

-- nk.GCD = import("game.common.gcd")
nk.Gzip = require('core/gzip')

-- 开关控制
local OnOff = import("game.login.OnOff") 
nk.OnOff = new(OnOff)

nk.gameData = require("game.data.gameData")
-- nk.userData_ = require("game.data.userData")
nk.UserDataController = require("game.data.userDataController")

local ErrorManager = require("game.common.errorManager")
nk.ErrorManager = new(ErrorManager,nk.TopTipManager)

local GameBroadCastHistoryManager = require("game.chat.gameBroadCastHistoryManager")
nk.GameBroadCastHistoryManager = new(GameBroadCastHistoryManager)
nk.HornTextRotateAnim = require("game.anim.hornTextRotateAnim")
nk.HornTextRotateAnim.setup()
local WChatPlay = require("game.chat.wChatPlay")
nk.WChatPlay = new(WChatPlay)


-- lua call 相关

local FacebookNativeEvent = require("game.nativeEvent.facebookNativeEvent")
nk.FacebookNativeEvent = new(FacebookNativeEvent)

local ActivityNativeEvent = require("game.nativeEvent.activityNativeEvent")
nk.ActivityNativeEvent = new(ActivityNativeEvent)

local GodSDKNativeEvent = require("game.nativeEvent.godsdkNativeEvent")
nk.GodSDKNativeEvent = new(GodSDKNativeEvent)

local GoogleNativeEvent = require("game.nativeEvent.googleNativeEvent")
nk.GoogleNativeEvent = new(GoogleNativeEvent)

-- lua call 相关 end
local RoomConfigController = require("game.hall.roomConfigController")
nk.RoomConfigController = new(RoomConfigController)

local LoginRewardConfig = require("game.loginReward.loginRewardConfig")
nk.LoginRewardConfig = new(LoginRewardConfig)

--暂时用来获取我的道具
local userLayerconfig = require("game.userInfo.userLayerController")
nk.userLayerConfig = new(userLayerconfig)

nk.LotteryController = new(require("game.lottery.lotteryController"))

local loadLevelControl = require("game.config.loadLevelControl")
-- nk.LevelConfigController = new(loadLevelControl) -- 和之前的保持统一命名
nk.Level = new(loadLevelControl)

local loginRewardController = require("game.loginReward.loginRewardController")
nk.LoginRewardController = new(loginRewardController)

local feedbackController = require("game.setting.feedbackController")
nk.FeedbackController = new(feedbackController)

local messageController = require("game.message.messageController")
nk.messageController = new(messageController)

local taskController = require("game.task.taskController")
nk.taskController = new(taskController)

local limitTimer = require("game.limitTimeGiftbag.limitTimer")
nk.limitTimer = limitTimer.getInstance()

local vipController = require("game.store.vip.vipController")
nk.vipController = vipController.getInstance()

local promoteController = require("game.promote.promoteController")
nk.promoteController = promoteController.getInstance()

local limitTimeEventDataController = require("game.limitTimeEvent.limitTimeEventDataController")
nk.limitTimeEventDataController = new(limitTimeEventDataController)

local reportConfig = require("game.userInfo.reportConfig")
nk.reportConfig = new(reportConfig)

nk.s_headFile =
{
  "res/head/female_avatar_1.png",
  "res/head/female_avatar_2.png",
  "res/head/female_avatar_3.png",
  "res/head/female_avatar_4.png",
  "res/head/female_avatar_5.png",
  "res/head/male_avatar_1.png",
  "res/head/male_avatar_2.png",
  "res/head/male_avatar_3.png",
  "res/head/male_avatar_4.png",
  "res/head/male_avatar_5.png",
}


function event_error_param()
 	-- 没有返回参数
end 

