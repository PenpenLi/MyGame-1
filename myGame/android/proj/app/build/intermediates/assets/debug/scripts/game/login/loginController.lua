-- loginController.lua
-- Last modification : 2016-05-16
-- Description: a controller in login moudle

local LoginSealedPopup = require("game.login.loginSealedPopup")
local LoginController = class(GameBaseController);
local Gzip = require('core/gzip')
local LogoutController = import('game.logout.logoutController')

function LoginController:ctor(state, viewClass, viewConfig, dataClass)
    Log.printInfo("LoginController.ctor");
    self.m_state = state;
    if nk.HttpController then
        nk.HttpController.m_httpModule:setDefaultTimeout(10)
    end
end

function LoginController:resume()
    Log.printInfo("LoginController.resume");
    GameBaseController.resume(self);
    --背景音乐
    nk.SoundManager:stopMusic()
    nk.SocketController:setForce(false)
end

function LoginController:pause()
    Log.printInfo("LoginController.pause");
    GameBaseController.pause(self);
end

function LoginController:dtor()

end

-- Provide state to call
function LoginController:onBack()
    Log.printInfo("LoginController.onBack")
    -- TODO 是否存在其他弹窗
    --退出游戏框
    if nk.AdExchangePlugin and nk.AdExchangePlugin.getLeaveOn() == 1 then
        self:saveNoReadMsg()
        nk.AdExchangePlugin:setExitCallback(self.exitApp,-1)
        nk.AdExchangePlugin:setExitDlgFailCallback(self.showExitAlert)
        nk.AdExchangePlugin:showExitDlg()
    else 
        self:showExitAlert()
    end
end

function LoginController:onLoginSocketConnect(callback)
    Log.printInfo("LoginController", "onLoginSocketConnect")
    -- 连接登陆Socket
    nk.shouldContentHallserver = false
    local ip,port = string.match(HttpConfig.inHallIp, "([%d%.]+):(%d+)")
    nk.SocketController:connect(ip, port, 5, callback)
end

function LoginController:onHallSocketConnect()
    Log.printInfo("LoginController", "onHallSocketConnect")
    -- 连接HallServer
    -- local ip,port = string.match(HttpConfig.inHallIp, "([%d%.]+):(%d+)")
    -- nk.SocketController:connect(ip, port, 5, handler(self, self.onHallSocketCallback))
    -- nk.shouldContentHallserver = true

    local ip,port = string.match(HttpConfig.inHallIp, "([%d%.]+):(%d+)")
    self.m_comtentTime_start = os.clock()
    print_string("content_time " .. "seconds start = " .. self.m_comtentTime_start)
    nk.SocketController:connect(ip, port, 5, handler(self,function(args)
         self.m_comtentTime_end = os.clock()
         print_string("content_time " .. "seconds start_to_end = " .. (self.m_comtentTime_end - self.m_comtentTime_start))
    end))
    nk.shouldContentHallserver = true
    
    self:onHallSocketCallback()
end

function LoginController:onHallSocketCallback()
    nk.HttpController:execute("Http.load", {game_param = {mid = nk.userData.mid}})  
    nk.GoogleNativeEvent:getToken()
end

function LoginController:onLoginWithGuest()
    -- Log.printInfo("LoginController", "onLoginWithGuest")
    -- self:onLoginSocketConnect(handler(self, self.startGuestLogin_))
    self:startGuestLogin_()
end

function LoginController:startGuestLogin_()
    nk.isInSingleRoom = false
    -- TODO 保存登陆方式
    nk.DictModule:setString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    local systemInfo = nk.GameNativeEvent:read_getSystemInfo()
    self:login("GUEST", systemInfo, nil)
end

function LoginController:onLoginWithFacebook()
    -- self:onLoginSocketConnect(handler(self, self.startFacebookLogin_))
    self:startFacebookLogin_()
end

function LoginController:startFacebookLogin_()
    nk.isInSingleRoom = false
    -- TODO 保存登陆方式
    nk.DictModule:setString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "FACEBOOK")
    nk.FacebookNativeEvent:login(handler(self, function(obj, status, result)
            Log.printInfo("LoginController","woshiceshide")
            if status then
                local systemInfo = nk.GameNativeEvent:read_getSystemInfo()
                self:login("FACEBOOK", systemInfo, result)
            else
                if result == "cancle" then
                    self:updateView("playLoginFailAnim")
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "CANCELLED_MSG"))
                    -- TODO 上报统计
                    -- self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "5", "authorization cancelled")
                else
                    self:updateView("playLoginFailAnim")
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                    -- TODO 上报统计
                    -- self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "6", "authorization failed")
                end
            end
        end))
end

function LoginController:showExitAlert()
    Log.printInfo("abc","LoginControllerdosomething")
    local messageString
    if self.quitTips_ then
        messageString = bm.LangUtil.getText("LOGOUT", "QUIT_TIP_TEXT", " " .. self.quitTips_ .. " ")
    else
        messageString = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_MSG")
    end
    local args = {
        titleText = bm.LangUtil.getText("COMMON", "NOTICE"),
        messageText = messageString, 
        hasCloseButton = false,
        firstBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CONFIRM"),
        secondBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CANCEL"),
        callback = function (type)
            if type == nk.Dialog.FIRST_BTN_CLICK then
                if nk.AdExchangePlugin then
                    nk.AdExchangePlugin:clearAll()
                end
                self:exitApp() 
            elseif type == nk.Dialog.SECOND_BTN_CLICK then
            end
        end
    }
    nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)
end

function LoginController:exitApp()
    Log.printInfo("LoginController","exitApp")
    self:saveNoReadMsg()
    nk.DictModule:setBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
    sys_exit()
end

function LoginController:saveNoReadMsg()
    if nk.userData and nk.userData.chatRecord and #nk.userData.chatRecord > 0 then
        Log.dump(nk.userData.chatRecord, "saveNoRsaveNdMsgeadMsg")

        local list = {}
        local friendName = ""
        local chatRecord =  {}

        for i,data in ipairs(nk.userData.chatRecord) do
            local uid = tonumber(data.send_uid)

            local record = {}
            record.msg = data.msg
            record.time = data.time
            record.kind = 2  
            record.msg_type = data.type

            friendName = string.format("friendChatRecord_%d", uid)

            if not chatRecord[uid] then
                chatRecord[uid] =  nk.DictModule:getString(friendName,nk.cookieKeys.FRIEND_CHAT_RECORD, "")
                chatRecord[uid] = json.decode(chatRecord[uid]) or {}
            end

            if not list[tostring(uid)] then
                list[tostring(uid)] = {}
                for k,v in ipairs(chatRecord[uid]) do
                    table.insert(list[tostring(uid)],v)
                end
            end

            table.insert(list[tostring(uid)],record)
        end

        for k,v in pairs(list) do
            local mid = tonumber(k)
            if v and mid then
                friendName = string.format("friendChatRecord_%d", mid)
                nk.DictModule:setString(friendName,nk.cookieKeys.FRIEND_CHAT_RECORD, json.encode(v))
                nk.DictModule:saveDict(friendName)
            end
        end

    end
end

-------------------------------- private function --------------------------

function LoginController:login(loginType, systemInfo, access_token)
    local referrer = nk.GameNativeEvent:getCampaignReferrer()
    if referrer ~= "" then referrer = string.urlencode(referrer) end
    local params = {
       sig_sitemid = Gzip.encodeBase64(systemInfo.mac .. "_pokdengboyaa"),
       sid         = GameConfig.ROOT_CGI_SID,
       lid         = nk.HttpController:setLoginType_(loginType), 
       uuid        = nk.GameNativeEvent:read_getUUID(), --移动终端UUID 
       apkVer      = GameConfig.CUR_VERSION, --游戏版本号，如"4.0.1","4.2.1" 
       channel_id  = nk.GameNativeEvent:read_getChannel(), -- 渠道号    
       imei        = systemInfo.imei, -- imei号
       mac         = systemInfo.mac, --移动终端设备号 
       sdkVer      = systemInfo.sdkVer, --移动终端设备操作系统、版本号和SDK版本号， 例如 "android_4.2.1|15"， "ios_4.1"
       net         = systemInfo.networkType, --移动终端联网接入方式，例如 "wifi(1)", "2G(2)", "3G(3)", "4G(4)", "离线(-1)"。
       simOperatorName = systemInfo.simNum, --移动终端设备所使用的网络运营商,如"电信"，"移动"，"联通" 
       machineType = systemInfo.deviceModel, --移动终端设备机型.如："iphone 4s TD", "mi 2S", "IPAD mini 2" 
       pixel = string.format("%d*%d", systemInfo.widthPixels, systemInfo.heightPixels), --移动终端设备屏幕尺寸大小，如“1024*700” 
       referrer = referrer,
    }   
    if loginType == "FACEBOOK" then
        params.access_token = access_token
    end

    nk.HttpController:execute("login",{game_param = params}, nk.UpdateConfig.loginUrl)
end

-------------------------------- handle function --------------------------

function LoginController:onLoginLoaded(errorCode,data)
    self.isLoginLoaed = true
    if self.isLoginSceneAnimPlayed then
        StateMachine.getInstance():changeState(States.Hall)
    else
        self:updateView("updateViewOnLoginSucc")
    end
end

function LoginController:onLoginSceneAnimPlayed()
    self.isLoginSceneAnimPlayed = true
    if self.isLoginLoaed then
        StateMachine.getInstance():changeState(States.Hall)
    end
end

-------------------------------- native event -----------------------------

function LoginController:onLoginSuccess(errorCode,data)
    -- dump(errorCode, "onLoginSuccessonLoginSuccessonLoginSuccess errorCode")
    data = data.data
    Log.dump(data, "onLoginSuccessonLoginSuccessonLoginSuccess  data")

    -- 标记联网登陆
    data.isOnline = true

    self:processUserData(data)

    nk.UserDataController.formatProperty(data)

    -- 保存玩家游戏总局数
    local uid = nk.UserDataController.getUid()
    local generalNumber = nk.UserDataController.getWinNum() + nk.UserDataController.getLoseNum()
    nk.DictModule:setInt("gameData", nk.cookieKeys.USER_GENERAL_NUMBER .. uid, tonumber(generalNumber))
    nk.functions.shouldCardTips()

    
    --上报注册
    if data and data.isCreate == 1  then
        if nk.AdPlugin then
            nk.AdPlugin:reportReg()
        end
    end
    
    --召回上报,登陆间隔7天以上
    if data and data.loginInterval > 7  then
        if nk.AdPlugin then
            nk.AdPlugin:reportRecall(nk.userData.sitemid)
        end
    end

    --上报登陆
    if nk.AdPlugin then
        nk.AdPlugin:reportLogin()
    end

    local lastLoginType = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    if lastLoginType ==  "FACEBOOK" then
        if data.isCreate == 1 then
            nk.FacebookNativeEvent:getRequestId()
        end
        -- 上报能邀请的好友数量
        self:reportInvitableFriends_()
    elseif lastLoginType ==  "GUEST" then
        nk.FacebookNativeEvent:checkFBBind()
    end

    --[[
    if data and data.ADCLoginOn and data.ADCLeaveOn then
        if nk.AdExchangePlugin then
            nk.AdExchangePlugin:initByLua(nk.Native:getChannelId(), tostring(data.mid), data.ADCLoginOn, data.ADCLeaveOn, data.ActCenterSize)
            nk.AdExchangePlugin:setOnoff(data.ADCLoginOn,data.ADCLeaveOn)
        end
    end
    --]]

    -- 初始化活动中心
    local systemInfo = nk.GameNativeEvent:read_getSystemInfo()
    local content = 
        {
            mid = nk.userData.mid,
            version = GameConfig.CUR_VERSION,
            api = GameConfig.ROOT_CGI_SID,
            appid = GameConfig.ACTIVITY_APPID,
            sitemid = nk.userData.sitemid,
            usertype = 0,
            deviceno = Gzip.encodeBase64(systemInfo.mac .. "_pokdengboyaa"),
            url = GameConfig.ACTIVITY_URL,
            channeID = GameConfig.ROOT_CGI_SID,
            secretKey = GameConfig.ACTIVITY_SECRETKEY,
        }
    nk.ActivityNativeEvent:activityInit(content)

    self:onHallSocketConnect()
end

-- 上报可邀请的好友数量
function LoginController:reportInvitableFriends_()
    if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then 
        --一天只上报一次
        local date = nk.DictModule:getString("DALIY_REPORT_INVITABLE")       
        nk.FacebookNativeEvent:getInvitableFriends(function(status, friendData)
            if status then
                if date ~= os.date("%Y%m%d") then
                    local count = #friendData
                    nk.DictModule:setString("DALIY_REPORT_INVITABLE", os.date("%Y%m%d"))                   
                    -- 能够邀请的facebook好友数
                    print("---->reportInvitableFriends_ -------------"..count)

                    nk.AnalyticsManager:reportValue("EC_H_CanInvite_Num", {attributes = "EC_H_CanInvite_Num" }, count)
                end
            end      
        end)
    end
end

function LoginController:processUserData(userData)
    -- userData.inviteSendChips = 500000   --邀请发送奖励
    -- userData.inviteBackChips = 50000000 --邀请回来奖励
    -- userData.recallBackChips = 50000000 --召回奖励
    -- userData.recallSendChips = 500000   --召回发送奖励
    --userData.uid = userData['aUser.mid']
    userData.GIFT_JSON = userData["urls.gift"] --礼物配置Json
    userData.PROPS_JSON = userData["urls.props"] --生商城道具列表配置Json
    userData.MSGTPL_ROOT = userData["urls.msg"] --消息模板配置Json
    userData.LEVEL_JSON = userData["urls.level"] --等级配置Json
    userData.EXP_JSON   =userData["urls.exp"]--不同场次对应经验配置json
    userData.UPLOAD_PIC = userData["urls.updateicon"] -- 头像上传地址
    userData.WHEEL_CONF = userData["urls.luckyWheel"] --幸运转盘配置Json
    userData.fbInviteNumCfg=userData["fbInviteNumCfg"] --fb显示好友数
    userData.TASK_JSON = userData["urls.task"] --任务模板配置Json
    userData.STATSWITCH_JSON = userData["urls.statswitch"] --友盟上报开关配置Json
    userData.LOGOUT_JSON = userData["urls.outmsg"] --退出弹窗的配置
    userData.SAMPINGAN_JSON = userData["urls.sampingan"] --边注玩法配置
    userData.ROOMFUNCTION_JSON = userData["urls.roomfunction"] --房间功能配置
    userData.NOTICE_JSON = userData["urls.notice"] --公告配置
    userData.LOGINREWARD_JSON = userData["urls.loginaward"] --登陆奖励配置
    userData.RANKREWARD_JSON = userData["urls.rank"] --登陆奖励配置
    userData.SINGLEREWARD_JSON = userData["urls.singleaward"] --单机奖励配置
    userData.SELF_SERVICE_JSON = userData["urls.question"] --自助服务的问题配置
    userData.NEW_TASK_JSON = userData["urls.taskNew"] --新的任务配置
    userData.INVITE_RULE_JSON = userData["urls.inviteText"] --邀请规则配置
    userData.MONTH_FIRST_PAY_JSON = userData["urls.monthfirstpay"]  --首充配置
    userData.VIP_JSON = userData["urls.vip"]  --vip配置
    userData.STORE_NOTICE_JSON = userData["urls.storeMsg"]  --商城公告配置
    userData.SKIP_JSON = userData["urls.skip"]  --登录弹框配置
    userData.ALL_SERVER_ACTIVITY = userData["urls.allServerActivity"]   --限时活动
    userData.LOTTERY_CONFIG = userData["urls.winLottery"]  --抽奖配置
    nk.DictModule:setString("gameData", nk.cookieKeys.SINGLE_REWARD_JSON, userData.SINGLEREWARD_JSON)

    userData.GIFT_SHOP = 1;
    userData.chatRecord = {}
    nk.LotteryController.isConfigLoaded = false
    nk.LotteryController:loadConfig(userData.LOTTERY_CONFIG)  --抽奖配置

        --五星好评
    new(require("game.cache.cache")):cacheFile(userData["urls.fiveStarGrade"], handler(self, function(obj, result, content)
        if result then
            nk.fiveStarConf = content
        end
    end), "fiveStarConfig", "data")   

    if userData.LOGINREWARD_JSON then
        nk.LoginRewardController:loadConfig(userData.LOGINREWARD_JSON,function(success,expData)
            if success then
                print("login reward load config succ")
            end
        end)
    end

    --exp
    nk.Level:loadExpConfig(userData.EXP_JSON,function(success,expData)
        if success then
            Log.printInfo("LoginController","load exp_json config succ")
        end
    end)    

    --level
    nk.Level:loadConfig(userData.LEVEL_JSON,function(success,expData)
        if success then
            Log.printInfo("LoginController","load level_json config succ")
        end
    end)   

    --self service question
    nk.FeedbackController:loadQConfig(userData.SELF_SERVICE_JSON,function(success,expData)
        if success then
            Log.printInfo("LoginController","load self_service_json question config succ")
        end
    end)

    --task
    nk.taskController:loadTaskConfig(userData.NEW_TASK_JSON,function(success,expData)
        if success then
            Log.printInfo("LoginController","load task_json config succ")
        end
    end)

    --vip
    nk.vipController:loadConfig(userData.VIP_JSON, function(success, vipData)
        if success then
            Log.printInfo("vipController","load VIP_JSON config succ")
        end
    end)

    -- 放到 HallScene
    -- nk.limitTimeEventDataController:loadConfig(userData.ALL_SERVER_ACTIVITY, function(success, ltedcData)
    --     if success then
    --         Log.printInfo("vipController","load ALL_SERVER_ACTIVITY config succ")
    --         nk.limitTimeEventDataController:getEventData()
    --     end
    -- end)

    --登录弹框配置
    nk.promoteController:loadConfig(userData.SKIP_JSON, function(success,expData)
        if success then
            Log.printInfo("promoteController","load SKIP_JSON config succ")

            nk.isFromLoginPromoteTag = true
        end
    end)

    -- 加载友盟开关配置
    -- if userData.STATSWITCH_JSON then
    --     bm.cacheFile(userData.STATSWITCH_JSON, function(result, content)
    --         if result == "success" then
    --             local switchData_ = json.decode(content)
    --             userData.switchData = switchData_
    --         end
    --     end, "statswitch") 
    -- end

    -- 加载退出配置
     if userData.LOGOUT_JSON then
         LogoutController.getInstance():loadConfig(userData.LOGOUT_JSON)
     end
end

function LoginController:loginFail(errorData)
    self.isLoginSceneAnimPlayed = false
    self:updateView("playLoginFailAnim")
    -- -- 视图处理登录失败
    -- if not nk.updateFunctions.checkIsNull(self.view_) and self.view_.playLoginFailAnim then
    --     self.view_:playLoginFailAnim()
    -- end
    -- if errorData and type(errorData) == "table" and errorData.errorMsg then
    --     nk.TopTipManager:showTopTip(errorData.errorMsg)
    -- else
    --     -- 通知网络错误
    --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    -- end
    -- -- bm.EventCenter:dispatchEvent({name=nk.eventNames.SINGLE_ROOM_BAD_NETWORK})

    local errorCode = errorData.errorCode
    local errorMsg = errorData.errorMsg
    local data = errorData.data

    if errorCode == -5  then
        --账号被封,反馈用到的数据
        local tempData = nk.userData
        if tempData and data then
            tempData["mid"] = data.mid
            tempData["name"] = data.name
            tempData["mlevel"] = data.mlevel
            nk.PopupManager:addPopup(LoginSealedPopup,"login",errorMsg or "",data.expire or 0) 
        end
    end
end
-------------------------------- event listen ------------------------

-- Provide cmd handle to call
LoginController.s_cmdHandleEx = 
{
    ["LoginController.onLoginWithGuest"] = LoginController.onLoginWithGuest,
    ["LoginController.onLoginWithFacebook"] = LoginController.onLoginWithFacebook,
    ["LoginController.onLoginLoaded"] = LoginController.onLoginLoaded,
    ["LoginController.loginSuccess"] = LoginController.onLoginSuccess,
    ["LoginController.loginFail"] = LoginController.loginFail,
    ["LoginController.onLoginSceneAnimPlayed"] = LoginController.onLoginSceneAnimPlayed,
};

-- Java to lua native call handle
LoginController.s_nativeHandle = {
    -- ["***"] = function
};

-- Event to register and unregister
LoginController.s_eventHandle = {
    -- [Event ] = function
};

return LoginController