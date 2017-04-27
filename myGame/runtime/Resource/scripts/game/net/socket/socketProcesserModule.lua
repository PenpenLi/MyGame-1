-- socketProcesserModule.lua
-- Last modification : 2016-05-10
-- Description: a processer to finish all socket after read.

local SocketProcesserModule = class(GameBaseSocketProcesser);

function SocketProcesserModule:ctor(config)

end

function SocketProcesserModule:dtor()

end

function SocketProcesserModule:SVR_PHP_BACK(pack)
    Log.printInfo("SocketProcesserModule", "SVR_PHP_BACK")
    EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_PHP_BACK", pack);
end

function SocketProcesserModule:SVR_LOGIN_OK(pack)
    Log.printInfo("SocketProcesserModule", "SVR_LOGIN_OK")
    -- if self.loginTimeoutHandle_ then
    --     scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
    --     self.loginTimeoutHandle_ = nil
    -- end
    -- self:setHeartBeatParams(PROTOCOL.CLISVR_HEART_BEAT, 3)

    -- local scene = display.getRunningScene()
    -- -- dump(scene.name,">>>>>>>>>>>>>>>>>>>>>>>> sceneName")
    -- local scheduleTime = 10
    -- if scene.name == "HallScene" then
    --     scheduleTime = self.HallHeartBeatInterval
    -- elseif scene.name == "RoomScene" then
    --     scheduleTime = self.RoomHeartBeatInterval
    -- elseif scene.name == "RoomQiuqiuScene" then
    --     scheduleTime = self.RoomHeartBeatInterval
    -- end
    -- self:scheduleHeartBeat(scheduleTime)
    

    self.isLogin_ = true
    nk.SocketController:getNoReadFriendChatMsg()
    EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_LOGIN_OK", pack);

    self:onLoginServerSucc(pack)
end

function SocketProcesserModule:onLoginServerSucc(data)
    Log.printInfo("SocketProcesserModule:onLoginServerSucc")
    if data and data.tid > 0 and (not self.notReConnect_) then
        -- 重连房间
        -- nk.TopTipManager:showTopTip("tid = " .. data.tid)
        self.tid__ = data.tid
        self.isEnterRoomIng = true
        nk.GCD.PostDelay(self,function()
            self:reLoginRoom_()
        end, nil, 1000)
    else
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

function SocketProcesserModule:reLoginRoom_()
    if self.tid__ and self.tid__ > 0 then
        nk.tid = self.tid__
        -- local pack = {}
        -- pack.tid = nk.tid
        -- self:SVR_GET_ROOM_OK(pack)
        nk.SocketController:getRoomPlayTypeByTid(nk.tid)
    end
    self.loginRoomSucc_ = false
end

function SocketProcesserModule:SVR_HALL_LOGIN_FAIL(pack)
	Log.printInfo("SocketProcesserModule", "SVR_HALL_LOGIN_FAIL")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_HALL_LOGIN_FAIL", pack);
	nk.TopTipManager:showTopTip(T("大厅登录失败,错误码%d", string.format("%#x",evt.data.errorCode))) 
end

function SocketProcesserModule:getMemberInfoCallBack(pack)
    Log.printInfo("SocketProcesserModule", "getMemberInfoCallBack")
end

function SocketProcesserModule:CLISVR_HEART_BEAT(pack)
	Log.printInfo("SocketProcesserModule", "CLISVR_HEART_BEAT")
end

function SocketProcesserModule:SVR_GET_ROOM_OK(pack)
	-- Log.printInfo("SocketProcesserModule", "SVR_GET_ROOM_OK")
    -- EnterRoomManager.getInstance():enterRoomLoading()
    if pack and pack.tid > 0 then
        nk.tid = pack.tid
        local states = StateMachine.getInstance():getRunningState()
        if states.state == States.RoomGaple or states.state == States.RoomQiuQiu then
            -- 一下这个事件可能会没有处理，若没有处理，state的controller在resume的时候，会处理
            EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_GET_ROOM_OK", pack)
        end
    end
end

function SocketProcesserModule:SVR_GET_ROOM_FAIL(pack)
    nk.ErrorManager:ShowErrorTips(pack.errorCode)
end

function SocketProcesserModule:SVR_LOGIN_ROOM_OK(pack)
	Log.printInfo("SocketProcesserModule", "SVR_LOGIN_ROOM_OK")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_LOGIN_ROOM_OK", pack);
end

function SocketProcesserModule:SVR_LOGIN_ROOM_FAIL(pack)
    nk.ErrorManager:ShowErrorTips(pack.errorCode)
end

function SocketProcesserModule:SVR_RE_LOGIN_ROOM_OK(pack)
	Log.printInfo("SocketProcesserModule", "SVR_RE_LOGIN_ROOM_OK")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_RE_LOGIN_ROOM_OK", pack);
end

function SocketProcesserModule:SVR_SELF_SEAT_DOWN_OK(pack)
	Log.printInfo("SocketProcesserModule", "SVR_SELF_SEAT_DOWN_OK")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_SELF_SEAT_DOWN_OK", pack);
end

function SocketProcesserModule:SVR_SEAT_DOWN(pack)
	Log.printInfo("SocketProcesserModule", "SVR_SEAT_DOWN")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_SEAT_DOWN", pack);
end

function SocketProcesserModule:SVR_STAND_UP(pack)
	Log.printInfo("SocketProcesserModule", "SVR_STAND_UP")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_STAND_UP", pack);
end

function SocketProcesserModule:SVR_OTHER_STAND_UP(pack)
	Log.printInfo("SocketProcesserModule", "SVR_OTHER_STAND_UP")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_OTHER_STAND_UP", pack);
end

function SocketProcesserModule:SVR_GAME_START(pack)
	Log.printInfo("SocketProcesserModule", "SVR_GAME_START")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_GAME_START", pack);
end

function SocketProcesserModule:SVR_NEXT_BET(pack)
	Log.printInfo("SocketProcesserModule", "SVR_NEXT_BET")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_NEXT_BET", pack);
end

function SocketProcesserModule:SVR_GAME_OVER(pack)
	Log.printInfo("SocketProcesserModule", "SVR_GAME_OVER")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_GAME_OVER", pack);
end

function SocketProcesserModule:SVR_LOGIN_ROOM_QIUQIU_OK(pack)
	Log.printInfo("SocketProcesserModule", "SVR_LOGIN_ROOM_QIUQIU_OK")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_LOGIN_ROOM_QIUQIU_OK", pack);
end

function SocketProcesserModule:SVR_LOGIN_ROOM_QIUQIU_FAIL(pack)
    nk.ErrorManager:ShowErrorTips(pack.errorCode)
end

function SocketProcesserModule:SVR_OTHER_OFFLINE_QIUQIU(pack)    
end

function SocketProcesserModule:SVR_OTHER_OFFLINE(pack)
end

function SocketProcesserModule:SVR_LOGOUT_ROOM_OK(pack)
	Log.printInfo("SocketProcesserModule", "SVR_LOGOUT_ROOM_OK")
	--退出房间同步钱数
    nk.functions.setMoney(pack.money)
end

function SocketProcesserModule:SVR_LOGOUT_ROOM_OK_QIUQIU(pack)
    Log.printInfo("SocketProcesserModule", "SVR_LOGOUT_ROOM_OK_QIUQIU")
    --退出房间同步钱数
    nk.functions.setMoney(pack.money)
end

function SocketProcesserModule:SVR_KICK_OUT(pack)
	Log.printInfo("SocketProcesserModule", "SVR_KICK_OUT")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_KICK_OUT", pack);
end

function SocketProcesserModule:SVR_SYNC_USERINFO(pack)
	Log.printInfo("SocketProcesserModule", "SVR_SYNC_USERINFO")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_SYNC_USERINFO", pack);
end

function SocketProcesserModule:SVR_MSG_SEND_RETIRE(pack)
	Log.printInfo("SocketProcesserModule", "SVR_MSG_SEND_RETIRE")
	EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, "SVR_MSG_SEND_RETIRE", pack);
end

function SocketProcesserModule:SVR_HALL_BROADCAST_MGS(pack)
	Log.dump(pack, "SocketProcesserModule:SVR_HALL_BROADCAST_MGS")
	if pack and pack.info then
        local pack = json.decode(pack.info)
        local mtype = pack and pack.msg_id or 0
        if mtype == consts.GAME_BROADCAST_ID.SYSTEM_MSG_ID then
            if pack.isLimGift and pack.isLimGift ==1  then
                local time = pack.time
                local num = pack.num
                local limId = pack.limId 
                if time == 0 then  -- 限时礼包结束后延长展示
                    time = nk.limitTimer.delayTime  
                    nk.limitTimer.duringDelay = true
                end
                if nk.DictModule:getString("gameData", "limitid","0") ==limId then
                    time = 0
                end
                nk.limitInfo = pack
                if time and  time>0 then 
                    if num and num ==0 then
                        time = 0
                    end
                    if time>0 then
                        nk.limitTimer:setTime(time)
                        nk.limitTimer:startSchedule()
                        EventDispatcher.getInstance():dispatch(EventConstants.open_limit_time_giftbag,pack)
                    end
                    nk.WChatPlay:setBroadcast(pack)  
                else
                    nk.limitTimer:close()
                end
            else
                nk.WChatPlay:setBroadcast(pack)
            end
        elseif mtype == consts.GAME_BROADCAST_ID.SYSTEM_USER_ID then
            nk.WChatPlay:setBroadcast(pack)
        elseif mtype == consts.GAME_BROADCAST_ID.SYSTEM_MSG_ID_NEW then
            if pack.type then
                if pack.type == 1 and pack.content then
                    -- 全服活动
                    if type(pack.content) == 'table' then
                        local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
                        local time = checkint(pack.content[2])
                        time = time or 0
                        datas["eventIsOpen"] = (time > 0)
                        if time > 0 and nk.limitTimeEventDataController then
                            nk.limitTimeEventDataController:reSetExpireTime(time)
                        end
                    end
                end
            end
        end
    end
end

function SocketProcesserModule:SVR_COMMON_BROADCAST(pack)
    Log.dump(pack, "SocketProcesserModule:SVR_COMMON_BROADCAST")
    if pack then
        local mtype = pack.mtype
        if mtype == 1 then
            --支付成功广播加钱
            if pack.info then
                local pInfo = json.decode(pack.info)
                local money = pInfo.money
                local addMoney = pInfo.addMoney
                if nk and nk.userData then
                    nk.functions.setMoney(money,true)
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))

                    EventDispatcher.getInstance():dispatch(EventConstants.message_buy_gold, true)
                end
            end
            nk.userData["firstRechargeStatus"] = 0
            nk.SocketController:synchroUserInfo()
        elseif mtype == 10 then
            --PHP通知更新金币
            Log.printInfo("SVR_COMMON_BROASVR_COMMON_BROAD_BROADCAST")
            if pack.info then
                local pInfo = json.decode(pack.info)
                local money = pInfo.money
                local msg = pInfo.msg
                if nk and nk.userData then
                    nk.functions.setMoney(money,true)
                    if msg and msg ~= "" then
                        nk.TopTipManager:showTopTip(msg)
                    end
                end
            end
            nk.SocketController:synchroUserInfo()
        elseif mtype == 20 then
            -- php 任务完成或消息通知
            if pack.info then
                 local pInfo = json.decode(pack.info)
                 local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
                 if pInfo.type == "task" and pInfo.status == 1 then
                     Log.printInfo(" NEW_TASK_OR_MESSAGE ^^^^^^^^^^^^^ task")
                     if not nk.PopupManager:hasPopup(nil,"MessagePopup") then
                         datas["TaskMainPoint"] = true
                     end                
                 elseif pInfo.type == "message" and pInfo.status == 1 and pInfo.tab then
                     Log.printInfo(" NEW_TASK_OR_MESSAGE ^^^^^^^^^^^^^ message")
                     pInfo.tab = checkint(pInfo.tab)
                     if pInfo.tab == 1 then
                         datas["sysNoticePoint"] = true
                     elseif pInfo.tab == 2 then
                         datas["sysMsgPoint"] = true
                     elseif pInfo.tab == 3 then
                         datas["friendMsgPoint"] = true
                     end
                     if not nk.PopupManager:hasPopup(nil,"MessagePopup") then
                         datas["MsgMainPoint"] = true
                     end
                 elseif pInfo.type == "feedback" and pInfo.status == 1 then
                     Log.printInfo(" NEW_TASK_OR_MESSAGE ^^^^^^^^^^^^^ feedback")
                     nk.FeedbackController.feedbackData_ = nil  --重新获取反馈历史
                     datas["fbTabPoint"] = true
                     if not nk.PopupManager:hasPopup(nil,"FeedbackPopup") then
                         datas["settingPoint"] = true
                         datas["feedbackPoint"] = true
                     end
                elseif pInfo.type == "single" and pInfo.status == 1 and pInfo.tab then 
                    -- 限时活动，个人
                    pInfo.tab = checkint(pInfo.tab)
                    if pInfo.tab == 5 then 
                        datas["singleEventPoint"] = true   
                    end
                elseif pInfo.type == "all" and pInfo.status == 1 and pInfo.tab then 
                    -- 限时活动，全服
                    pInfo.tab = checkint(pInfo.tab)
                    if pInfo.tab == 5 then 
                        datas["fullEventPoint"] = true   
                    end
                 end
            end
        elseif mtype == 11 then
            -- php 其他人加"我"为好友
            local userData = json.decode(pack.info)
            if userData then
                local FriendDataManager = require("game.friend.friendDataManager")
                if FriendDataManager.getInstance():addFriendData(userData) then
                    EventDispatcher.getInstance():dispatch(EventConstants.addFriendData, true, userData)
                end
            end
        elseif mtype == 12 then
            -- php 其他人在好友中删除"我"
            if pack and pack.info then
                local FriendDataManager = require("game.friend.friendDataManager") 
                if FriendDataManager.getInstance():deleteFriendData(pack.info) then
                    EventDispatcher.getInstance():dispatch(EventConstants.deleteFriendData, true, pack.info)
                end
            end
            --vip updata
        elseif mtype == 30 then
            if pack and pack.info then
                local sInfo = json.decode(pack.info)
                nk.userData.score = sInfo.score or 0
                nk.userData.expiry_time = sInfo.expiry_time or 0
                local vip = tonumber(nk.userData.vip or 0)
                local bevip = tonumber(sInfo.vip or 0)
                --if math.abs(bevip - vip) >0 then
                    nk.userData.vip = bevip
                --end
                if bevip - vip > 0 then
                    local beVipTime = os.date("%Y%m%d",os.time())
                    nk.DictModule:setString("gameData","BE_VIP_TIME",beVipTime or "")
                    nk.DictModule:saveDict("gameData")
                end
            end     
        elseif mtype == 22 then
            local pInfo = json.decode(pack.info)
            if pInfo then
                nk.TopTipManager:showTopTip(pInfo.msg)
                nk.functions.setMoney(pInfo.money,true)
                nk.DictModule:setString("gameData", "limitid",pInfo.limId or "0")
                nk.DictModule:saveDict("gameData")
                nk.limitTimer:close(true)
            end
        elseif mtype == 35 then
            local pInfo = json.decode(pack.info)
            if pInfo then
                nk.lotteryTimes = tonumber(pInfo.times)
                EventDispatcher.getInstance():dispatch(EventConstants.updateLotteryTimes,pInfo.times)
            end
        end
    end
end

function SocketProcesserModule:SVR_REC_FRIEND_CHAT_MSG(pack)
    Log.printInfo(">>> boardcast")
    Log.dump(pack, "SocketProcesserModule:SVR_REC_FRIEND_CHAT_MSG")
    
    if pack.msg_json  then
        local data = json.decode(pack.msg_json)
        table.insert(nk.userData.chatRecord,data)
        nk.functions.updataChatRecord()
        EventDispatcher.getInstance():dispatch(EventConstants.recFriendMsgInChatpopup, data)
    end 
end

function SocketProcesserModule:SVR_GET_NO_READ_MSG_RETURN(pack)
    Log.dump(pack, "SVR_GET_NO_READ_MSG_RETURN")
    if pack.msgs and #pack.msgs>0 then
        for i=1,#pack.msgs do
            local data = json.decode(pack.msgs[i])
            table.insert(nk.userData.chatRecord,data)
        end    
        nk.functions.updataChatRecord()
        EventDispatcher.getInstance():dispatch(EventConstants.recFriendMsgInChatpopup, data)
    end
end

function SocketProcesserModule:SVR_SEND_FRIEND_CHAT_MSG_RETUEN(pack)
    Log.dump(pack, "SVR_SEND_FRIEND_CHAT_MSG_RETUEN")
end

function SocketProcesserModule:SVR_CHECK_FRIEND_STATUS(pack)
    Log.dump(pack, "SVR_CHECK_FRIEND_STATUS")
    if pack.statusList and #pack.statusList > 0 then
        local FriendDataManager = require("game.friend.friendDataManager")
        FriendDataManager.getInstance():refreshFriendStatus(pack.statusList)
    else
        
    end
end

function SocketProcesserModule:SVR_ROOM_STATUS_GET(pack)
    if pack and pack.roomPlayType then
        -- self.roomPlayType = pack.roomPlayType 
        if pack.roomPlayType == consts.ROOM_PLAY_TYPE.GAPLE_PLAYE then
            StateMachine.getInstance():changeState(States.RoomGaple)
        elseif pack.roomPlayType == consts.ROOM_PLAY_TYPE.QIUQIU_PLAYE then
            StateMachine.getInstance():changeState(States.RoomQiuQiu)
        end
    end
end

function SocketProcesserModule:SVR_PLAYER_STATUS_RESPONSE(pack)
    if pack then
        if pack.tid > 0 then
            if pack.tableType == 2 then
                nk.tid = pack.tid
                StateMachine.getInstance():changeState(States.RoomGaple)
            elseif pack.tableType == 4 then
                nk.tid = pack.tid
                StateMachine.getInstance():changeState(States.RoomQiuQiu)
            elseif pack.tableType == 0 or pack.tableType == 1 then
                nk.TopTipManager:showTopTip(T("无法追踪好友，请确认好友是否在线并正在进行游戏"))
                self:refreshFriendStattus()
            else
                nk.TopTipManager:showTopTip(T("追踪失败"))
                EnterRoomManager.getInstance():releaseLoading()
                self:refreshFriendStattus()
            end
        else
            nk.TopTipManager:showTopTip(T("无法追踪好友，请确认好友是否在线并正在进行游戏"))
            EnterRoomManager.getInstance():releaseLoading()
            self:refreshFriendStattus()
        end
    end
end

function SocketProcesserModule:refreshFriendStattus()
    local FriendDataManager = require("game.friend.friendDataManager")
    local uidList_ = FriendDataManager.getInstance():getFriendsUidList()
    nk.SocketController:checkFriendStatus(nk.userData.mid,#uidList_,uidList_)
end


function SocketProcesserModule:SVR_FORCE_USER_OFFLINE(pack)
    Log.printInfo("SocketProcesserModule", "SVR_FORCE_USER_OFFLINE")
    if pack.errorCode then
        if pack.errorCode == nk.ErrorManager.Error_Code_Maps.DOUBLE_LOGIN then
            local args = {
                hasCloseButton = false,
                hasFirstButton = false,
                closeWhenTouchModel = false,
                messageText = T("您的账户在别处登录"), 
                secondBtnText = T("确定"), 
                callback = function (type)
                    if type == nk.Dialog.SECOND_BTN_CLICK then
                        --清理个人信息
                        nk.SocketController:logoutRoom()
                        nk.SocketController:logoutRoomQiuQiu()
                        StateMachine.getInstance():changeState(States.Login)
                    end
                end
            }
            nk.PopupManager:addPopup(nk.Dialog,"",args)
        end
        nk.SocketController:close()
    end
end

return SocketProcesserModule

