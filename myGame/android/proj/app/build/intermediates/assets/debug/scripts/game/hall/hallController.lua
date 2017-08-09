-- hallController.lua
-- Last modification : 2016-05-11
-- Description: a controller in Hall moudle
local BankruptInvitePopup = require("game.bankrupt.bankruptInvitePopup")
local HallController = class(GameBaseController);
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")
local LogoutPopup = require("game.logout.logoutPopup")

local BankruptHelpPopup = require("game.bankrupt.bankruptHelpPopup")

function HallController:ctor(state, viewClass, viewConfig, dataClass)
    Log.printInfo("HallController.ctor");
    self.m_state = state;

    --logout johnleo add 
    EventDispatcher.getInstance():register(EventConstants.logout, self, self.handleLogout)
end

function HallController:resume()
    Log.printInfo("HallController.resume");
    GameBaseController.resume(self);
    -- nk.FacebookNativeEvent:login()
    -- EventDispatcher.getInstance():dispatch(EventConstants.onEventCallBack, NativeEventConfig.NATIVE_GAME_PICKIMAGE_CALLBACK, true, data)
    self.clockHandler = Clock.instance():schedule_once(function()    
        self:showRewardPopup()
        nk.limitTimeEventDataController:loadConfig(nk.userData.ALL_SERVER_ACTIVITY, function(success, ltedcData)
            if success then
                nk.limitTimeEventDataController:getEventData()
            end
        end)
        --初始化任务的状态（给房间里边用的）
        nk.taskController:requestTaskData()-- function(result) if result then Log.printInfo("LoginController","updata task status succ") end end
    end, 1.0)
end

function HallController:pause()
    Log.printInfo("HallController.pause");
    GameBaseController.pause(self);
    if self.clockHandler then self.clockHandler:cancel() self.clockHandler = nil end
end

function HallController:dtor()
     EventDispatcher.getInstance():unregister(EventConstants.logout, self, self.handleLogout)
     nk.GCD.Cancel(self)
end

-- Provide state to call
function HallController:onBack()
    Log.printInfo("HallController.onBack")
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

-------------------------------- private function --------------------------

function HallController:showExitAlert()
    -- Log.printInfo("abc","HallControllerdosomething")
    -- local messageString
    -- if self.quitTips_ then
    --     messageString = bm.LangUtil.getText("LOGOUT", "QUIT_TIP_TEXT", " " .. self.quitTips_ .. " ")
    -- else
    --     messageString = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_MSG")
    -- end
    -- local args = {
    --     titleText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_TITLE"),
    --     messageText = messageString, 
    --     hasCloseButton = false,
    --     firstBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CONFIRM"),
    --     secondBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CANCEL"),
    --     callback = function (type)
    --         if type == nk.Dialog.FIRST_BTN_CLICK then
    --             if nk.AdExchangePlugin then
    --                 nk.AdExchangePlugin:clearAll()
    --             end
    --             self:exitApp() 
    --         elseif type == nk.Dialog.SECOND_BTN_CLICK then
    --         end
    --     end
    -- }
    
    
    nk.PopupManager:addPopup(LogoutPopup,"hall")
end

function HallController:exitApp()
    Log.printInfo("HallController","exitApp")
    self:saveNoReadMsg()
    nk.DictModule:setBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
    sys_exit()
end

function HallController:saveNoReadMsg()
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

-- 显示奖励弹窗（注册奖励或登陆奖励）
function HallController:showRewardPopup()
    local enter_view_tag = false
    local time = nk.DictModule:getString("gameData", nk.userData.uid.."localTime", "")
    if os.date("%Y%m%d",os.time())~=time then
        nk.isNewDay = true
        nk.DictModule:setString("gameData", nk.userData.uid.."localTime", os.date("%Y%m%d",os.time()))
        nk.DictModule:saveDict("gameData")
    end
    if nk.userData.registerRewardAward and nk.userData.registerRewardAward.ret==0 and nk.isNewDay then
        nk.isNewDay = false
        nk.DictModule:setInt("gameData", "PromoteShowTimes", 0)
        nk.DictModule:saveDict("gameData")
        nk.PopupManager:addPopup(require("game.popup.registerRewardPopup"),"hall")
        enter_view_tag = true
    elseif nk.userData.loginReward and nk.userData.loginReward.ret == 0 and nk.isNewDay and nk.LoginRewardController and nk.LoginRewardController:getLoginRewardData() then
        nk.isNewDay = false
        nk.DictModule:setInt("gameData", "PromoteShowTimes", 0)
        nk.DictModule:saveDict("gameData")
        nk.PopupManager:addPopup( require("game.loginReward.loginRewardPopup"),"hall")
        enter_view_tag = true
    end
    if not enter_view_tag and nk.isFromLoginPromoteTag then -- 如果有弹出注册奖励或登陆奖励在他们关闭时弹登录弹窗，另外在登录时也会谈
        nk.promoteController:isShow("hall")

    end

--    if checkint(nk.userData.loginAward.ret) == 0 and self.registrationAward == 0 then
--        if nk.userData.bankruptcyGrant and nk.userData.bankruptcyGrant.maxBmoney and checkint(nk.functions.getMoney()) < checkint(nk.userData.bankruptcyGrant.maxBmoney) then
--            if checkint(nk.userData.bankruptcyGrant.bankruptcyTimes) < checkint(nk.userData.bankruptcyGrant.num) then
--                local userCrash = UserCrash.new()
--                userCrash:show() 
--            end
--        elseif nk.userData["DropMessageFlag"] == 1 then
--            MessageView.new():show()
--        end
--    end
end
-------------------------------- handle function --------------------------

function HallController:dosomething()
    Log.printInfo("abc","HallControllerdosomething")
end

-------------------------------- native event -----------------------------

function HallController:pickCallBack()
    Log.printInfo("HallController","pickCallBack")
end

-------------------------------- event listen ------------------------

--[[ -- 移植到SocketProcesserModule

self.isEnterRoomIng 用 EnterRoomManager.getInstance():isEnterRooming() 替代

function HallController:onLoginServerSucc(data)
    Log.printInfo("HallController:onLoginServerSucc")
    -- self:hideLoading()
    if data.tid > 0 and (not self.notReConnect_) then
        -- 重连房间
        self.tid__ = data.tid
        self.isEnterRoomIng = true
        nk.GCD.PostDelay(self,function()
            self:reLoginRoom_()
        end, nil, 1000)
    else
        if nk.userData.loginReward and nk.userData.loginReward.ret == 1 and nk.LoginRewardController then
            local LoginRewardPopup = require("game.loginReward.loginRewardPopup")
            LoginRewardPopup.show()
        end
        -- if checkint(self.loginReward) == 0 and self.registrationReward == 0 then
        --     if nk.userData.bankruptcyGrant and nk.userData.bankruptcyGrant.maxBmoney and checkint(nk.functions.getMoney()) < checkint(nk.userData.bankruptcyGrant.maxBmoney) then
        --         if checkint(nk.userData.bankruptcyGrant.bankruptcyTimes) < checkint(nk.userData.bankruptcyGrant.num) then
        --             local userCrash = UserCrash.new()
        --             userCrash:show() 
        --         end
        --     elseif nk.userData["DropMessageFlag"] == 1 then
        --         MessageView.new():show()
        --     end
        -- end
    end
end


function HallController:reLoginRoom_()
    if self.tid__ and self.tid__ > 0 then
        nk.tid = self.tid__
        nk.SocketController:getRoomPlayTypeByTid(nk.tid)
    end
    self.loginRoomSucc_ = false
end

--]]

-- type 1 gaple, 2 qiuqiu, 具体看roomChoosePopup
function HallController:onTryToEnterRoom(data, type)
    -- Log.dump(data, "onTryToEerRoomonTryToEerRoomonTryToEerRoomonTryToEerRoom")
    if type == 1 then
        EnterRoomManager.getInstance():enterGapleRoom(data)
    else
        EnterRoomManager.getInstance():enter99Room(data)
    end

    -- TODO 切换成EnterRoomManager
    do return end
    local level = tonumber(data.serverid)

    local money = nk.functions.getMoney()
    if money >= tonumber(data.minmoney) then
        self.isEnterRoomIng = true
        nk.SocketController:getRoomAndLogin(level, 0)
    else
        local bankruptcyGrant = nk.UserDataController.getBankruptcyGrant()
        if bankruptcyGrant and money < bankruptcyGrant.maxBmoney then
        -- bankruptcyGrant.bankruptcyTimes < bankruptcyGrant.num then
            -- nk.PopupManager:addPopup(BankruptInvitePopup, "hall")
            nk.payScene = consts.PAY_SCENE.HALL_BANKRUPTCY_PAY
            nk.PopupManager:addPopup(BankruptHelpPopup, "hall")    -- 上面 do return 返回了       
        else
            self.isEnterRoomIng = true
            -- nk.SocketController:getRoomAndLogin(level, 0)
            -- self:loadingRoom()
        end
    end
end

function HallController:onFriendChange()
    self:updateView("refreshFriendList")
end

function HallController:onLimitTimeOpen(pack)
    self:updateView("openLimitTimeGiftbag",pack)
end

function HallController:onLimitTimeClose(isBuySuccess)
    self:updateView("closeLimitTimeGiftbag",isBuySuccess)
end

function HallController:onSocketError(errorCode)
    --连接server失败
    if errorCode == consts.SVR_ERROR.ERROR_CONNECT_FAILURE then       
        self:showErrorByDialog_(T("服务器连接失败"))
    --心跳包超时三次跑这里，断开连接再重连
    elseif errorCode == consts.SVR_ERROR.ERROR_HEART_TIME_OUT then       
        self:showErrorByDialog_(T("服务器响应超时"))
    --连接server成功，但登录超时(5秒内没有回复成功)，判定失败,断开连接，3秒后再连接
    elseif errorCode == consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT then       
        self:showErrorByDialog_(T("服务器登录超时"))   
    end
end

function HallController:showErrorByDialog_(msg)
    local args = {
        messageText = msg, 
        secondBtnText = T("重试"), 
        titleText = T("错误提示"),
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.Dialog.SECOND_BTN_CLICK then
                nk.SocketController:connect()
            end
        end,
    }
    nk.PopupManager:addPopup(nk.Dialog,"hall",args)
end

-------------------------coco2dx 登出的处理方式, dologout 用来clear数据。-----------------------
function HallController:handleLogout()
--    if self.isEnterRoomIng then
--        return
--    end
    self:doLogout()
--    -- 设置视图
--    --Umeng报错onLogoutSucc为nil，原因待查，先做屏蔽处理
--    if self.scene_ and self.scene_.onLogoutSucc then
--        self.scene_:onLogoutSucc()
--    end
    
    --大厅切换到登陆界面
    StateMachine.getInstance():changeState(States.Login)
end

function HallController:doLogout()
    --登出上报
    if nk.AdPlugin then
        nk.AdPlugin:reportLogout()
    end

--    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "")
--    nk.userDefault:flush()
    if nk.FacebookNativeEvent then
        nk.FacebookNativeEvent:logout()
    end

    if nk.userData and nk.userData.loginReward and nk.userData.loginReward.day and nk.userData.loginReward.days and nk.userData.loginReward.days[nk.userData.loginReward.day] then
        local day = checkint(nk.userData.loginReward.day) + 1
        if day > 6 then
            day = 6
        end
--        self.scene_.quitTips_ = nk.userData.loginReward.days[day]
    end

    --清除消息数据
    nk.messageController:clean()
    
    --清除任务数据
    nk.taskController:clean()

    --清除好友数据
    local FriendDataManager = require("game.friend.friendDataManager") 
    FriendDataManager.deleteInstance()


    -- 清除用户数据，
    nk.DataProxy:clearData(nk.dataKeys.USER_DATA, true)

    nk.DataProxy:clearData(nk.dataKeys.NEW_MESSAGE, true)

    -- 清楚限时活动数据
    nk.limitTimeEventDataController:clean()

    nk.SocketController:close()

    -- 上报数据中心
    nk.DataCenterManager:setSwitch(false)

    --保存限时活动时间
    if nk.limitTimer:getTime() > 0 then 
        if nk.limitInfo then
            nk.DictModule:setString("gameData", "limitTag", nk.limitInfo.limId or "0")
        end  
        nk.DictModule:setInt("gameData", "logoutTime", os.time() or 0)
        nk.DictModule:setInt("gameData", "remainingTime", nk.limitTimer:getTime() or 0)
        nk.DictModule:saveDict("gameData")
    end
end
-------------------------coco2dx 登出的处理方式,-----------------------



-------------------------------- table config ------------------------
-- Provide cmd handle to call
HallController.s_cmdHandleEx = 
{
    ["HallController.dosomething"] = HallController.dosomething,
};

-- Java to lua native call handle
HallController.s_nativeHandle = {
    -- ["***"] = function
    [NativeEventConfig.NATIVE_GAME_PICKIMAGE_CALLBACK] = HallController.pickCallBack,
};

HallController.s_socketCmdFuncMap = {
    -- 移植到SocketProcesserModule
    -- ["SVR_LOGIN_OK"] = HallController.onLoginServerSucc,
}

-- Event to register and unregister
HallController.s_eventHandle = {
    [EventConstants.tryToEnterRoom] = HallController.onTryToEnterRoom,
    [EventConstants.addFriendData] = HallController.onFriendChange,
    [EventConstants.deleteFriendData] = HallController.onFriendChange,
    [EventConstants.SVR_ERROR] = HallController.onSocketError,
    [EventConstants.close_limit_time_giftbag] = HallController.onLimitTimeClose,
    [EventConstants.open_limit_time_giftbag] = HallController.onLimitTimeOpen,
}

return HallController


