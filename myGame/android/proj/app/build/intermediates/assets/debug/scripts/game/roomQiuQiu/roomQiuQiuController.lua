-- RoomQiuQiuController.lua
-- Last modification : 2016-05-11
-- Description: a controller in Room QiuQiu moudle
local BankruptHelpPopup = require("game.bankrupt.bankruptHelpPopup")
local RoomModel = import("game.roomQiuQiu.roomQiuQiuModel")
local SeatManager = require("game.roomQiuQiu.manager.seatManager")
local DealerManager = require("game.roomQiuQiu.manager.dealerManager")
local DealCardManager = require("game.roomQiuQiu.manager.dealCardManager")
local LampManager = import("game.roomQiuQiu.manager.lampManager")
local ChipManager = import("game.roomQiuQiu.manager.chipManager")
local AnimManager = import("game.roomQiuQiu.manager.animManager")
local OperationManager = import("game.roomQiuQiu.manager.operationManager")
-- local UserCrash = import("app.module.room.userCrash.UserCrash")
local UpgradePopup = require("game.upgrade.upgradePopup")
local CountDownBox = require("game.roomGaple.views.countDownBox")
local RoomNewbieGuide = import("game.roomQiuQiu.layers.roomNewbieGuide")
local SeatStateMachine = require("game.roomQiuQiu.roomQiuQiuStateMachine")
local RoomQiuQiuController = class(GameBaseController)

local SeatCount = 7

function RoomQiuQiuController:ctor(state, viewClass, viewConfig, dataClass)
	Log.printInfo("RoomQiuQiuController.ctor")
	self.m_state = state;
    nk.userData.chatRecord = {}
    self:initCtx()
    -- local t = os.clock()
    -- local cnt = 0
    -- debug.sethook(function(event)
    --     local last = (os.clock() - t) * 1000
    --     cnt = cnt + 1
    --     if last > 4 then FwLog("RoomQiuQiuController cost " .. last .. ":cnt:" .. cnt .. ":" .. debug.traceback()) end
    --     t = os.clock()
    -- end, "c")
end

function RoomQiuQiuController:start()
    Log.printInfo("RoomQiuQiuController.start")
    if not self.initCtxed then
        if not self.isPaused then
            self:createNodes()
            self.initCtxed = true
            if self.delayList then
                for i = 1, #self.delayList do
                    local func = self.delayList[i][1]
                    func(unpack(self.delayList[i], 2))
                end
                self.delayList = nil
            end
        else
            self.controllerNeedStart = true            
        end
    end
end

function RoomQiuQiuController:resume()
    Log.printInfo("RoomQiuQiuController.resume")
    -- debug.sethook()
    GameBaseController.resume(self)
    self.isPaused = false
    if self.controllerNeedStart then
        self:start()
    elseif not self.initCtxed then
        return
    end
    nk.roomSceneType = "qiuqiu"
    -- EnterRoomManager.getInstance():enterRoomSuccess()
    -- Clock.instance():schedule_once(function()
        self:requestLoginRoom()
    -- end, 1)
end

function RoomQiuQiuController:pause()
    Log.printInfo("RoomQiuQiuController.pause")
    GameBaseController.pause(self);
    self.isPaused = true
    nk.roomSceneType = ""
    nk.loginRoomSuccess = false
end

function RoomQiuQiuController:dtor()
    nk.GCD.Cancel(self)
    delete(self.model)
    delete(self.seatManager)
    delete(self.dealerManager)
    delete(self.dealCardManager)
    delete(self.lampManager)
    delete(self.chipManager)
    delete(self.animManager)
    delete(self.oprManager)
    delete(self.guideManager)
    EnterRoomManager.getInstance():releaseLoading()
end

-- Provide state to call
function RoomQiuQiuController:onBack()
    self:updateView("menuBtnClick")
end

function RoomQiuQiuController:initCtx()
	local ctx = {}
    ctx.roomController = self
    ctx.scene = self.m_view
    ctx.sceneName = "roomQiuQiu"
    ctx.model = new(RoomModel)
    ctx.seatManager = new(SeatManager)
    ctx.dealerManager = new(DealerManager)
    ctx.dealCardManager = new(DealCardManager)
    ctx.lampManager = new(LampManager)
    ctx.chipManager = new(ChipManager)
    ctx.animManager = new(AnimManager)
    ctx.oprManager = new(OperationManager)
    ctx.guideManager = new(RoomNewbieGuide)
    ctx.export = function(target)
        if target ~= ctx.model then
            target.ctx = ctx
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    target[k] = v
                end
            end
        else
            rawset(target, "ctx", ctx)
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    rawset(target, k, v)
                end
            end
        end
        return target
    end
    ctx.export(self)
    ctx.export(ctx.scene)
    ctx.export(ctx.seatManager)
    ctx.export(ctx.dealerManager)
    ctx.export(ctx.dealCardManager)
    ctx.export(ctx.lampManager)
    ctx.export(ctx.chipManager)
    ctx.export(ctx.animManager)
    ctx.export(ctx.oprManager)
    ctx.export(ctx.guideManager)
end

-- 以下这段代码需要花费较长的时间
function RoomQiuQiuController:createNodes()
    self.countDownBoxNode = new(CountDownBox,self.ctx)
    self.countDownBoxNode:setAlign(kAlignBottomRight)
    self.countDownBoxNode:setPos(45,120)
    self.scene.nodes.animNode:addChild(self.countDownBoxNode)
	self.seatManager:createNodes()
    self.dealerManager:createNodes()
    self.dealCardManager:createNodes()
    self.lampManager:createNodes()
    self.chipManager:createNodes()
    self.animManager:createNodes()
    self.guideManager:createNodes()
    self.oprManager:createNodes()
end

-------------------------------- private function --------------------------

function RoomQiuQiuController:requestLoginRoom()
    if nk.tid then
        nk.SocketController:loginRoom(nk.tid)
    end
end

function RoomQiuQiuController:dealWithLogin(pack)
    Log.dump(pack,"dealWithLogin")
    nk.tid = 0
    local ctx = self.ctx
    local model = self.model
    local oldTid = model.roomInfo ~= nil and model.roomInfo.tid or 0
    
    self:resetExceptChip()

    model:initWithLoginSuccessPack(pack)
    
    self.scene:removeLoading()

    --显示房间信息
    self.scene:setRoomInfoText(model.roomInfo)
    --初始化座位及玩家
    ctx.seatManager:initSeats(model.seatsInfo, model.playerList)

    --设置庄家指示
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), false)
    

    --初始隐藏灯光
    if model.gameInfo.curDealSeatId ~= -1 then
        ctx.lampManager:show()
        ctx.lampManager:turnTo(ctx.seatManager:getSeatPositionId(model.gameInfo.curDealSeatId), false)

        --座位开始计时器动画
        ctx.seatManager:startCounter(model.gameInfo.curDealSeatId)
    else
        ctx.lampManager:hide()
        ctx.seatManager:stopCounter()
    end

    --(要在庄家指示和灯光之后转动，否则可能位置不正确)
    if model:isSelfInSeat() then
        ctx.seatManager:rotateSelfSeatToCenter(model:selfSeatId(), false)
    end

    --重置操作栏自动操作状态
    ctx.oprManager:resetAutoOperationStatus()
    --更新操作栏状态
    ctx.oprManager:updateOperationStatus()

    --一些重连进来的展示
    self:doSomethingReLogin()

    -- 设置登录筹码堆,如果和重连之前一样就不用重新设置
    if self.tableTotalChipTemp and model.gameInfo.totalAnte and self.tableTotalChipTemp == model.gameInfo.totalAnte then
        
    else
        ctx.chipManager:reset()
        ctx.chipManager:setLoginChipStacks()
    end

    self:updateChangeRoomButtonMode()

    --重连进来，如果座位上有自己的数据，就不用再坐下；否则自动坐下,如果是重连前已经坐下的还要坐重连前的同一个位置
    local autoSitDown = false
    if not model:selfSeatData() then
        autoSitDown = true
    end

    if autoSitDown then
        if not self.sitdownPos then
            local userData = nk.userData 
            -- 不做限制会导致破产时多次弹出破产界面
            if userData.bankruptcyGrant and userData.bankruptcyGrant.maxBmoney and nk.functions.getMoney() >= userData.bankruptcyGrant.maxBmoney then
                self:applyAutoSitDown()
            end
        else
           self:reloginAutoSitDown()
        end
    end
    nk.loginRoomSuccess = true
end

--重连坐同一个位置
function RoomQiuQiuController:reloginAutoSitDown()
    if self.sitdownPos and self.model.roomInfo and self.model.roomInfo.minBuyIn then
        local userData = nk.userData
        if nk.functions.getMoney() >= self.model.roomInfo.minBuyIn then
            local isAutoBuyin = nk.DictModule:getBoolean("gameData",nk.cookieKeys.AUTO_BUY_IN, true)
            nk.SocketController:seatDownQiuQiu(self.sitdownPos, math.min(nk.functions.getMoney(), self.model.roomInfo.defaultBuyIn), isAutoBuyin , true)                 
        end
        self.sitdownPos = nil
    end
end

-- reset 用在三个地方，一个是登录房间成功，一个是游戏开始，一个是游戏结束N秒后(跑计时器)
function RoomQiuQiuController:reset()
    self:resetExceptChip()
    self.chipManager:reset()

    self.model.lastAnte = 0
end

-- reset 除了金币
function RoomQiuQiuController:resetExceptChip()
    self.animManager:moveDealerTo(-1, true)
    self.model:reset()
    self.dealCardManager:reset()
    self.seatManager:reset()
    self.lampManager:hide()

    self.model.lastAnte = 0
end

function RoomQiuQiuController:doSomethingReLogin()
    local ctx = self.ctx
    local model = self.model
    --确认牌型倒计时框
    if model.gameInfo.gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_CHECK then
        ctx.lampManager:hide()
        ctx.seatManager:stopCounter()

        if self.model:isSelfInGame() then   --自己在游戏中
            local selfData = model:selfSeatData()
            ctx.seatManager:getSelfSeatView():showCardTypeIf(selfData.specialCardsType)   --显示特殊牌型
            if selfData.hasConfirmCards == 0 then          --还没有确认牌型，可以切牌
                ctx.seatManager:getCardModeConfirm(model.gameInfo.userAnteTime,handler(self, self.confirmCardMode))
            end
        end

        --把确认牌型的都标记出来
        for i = 0,SeatCount - 1 do
            local player = model.playerList[i]
            if player and player.isPlay == 1 then
                if player.hasConfirmCards == 1 then
                	ctx.seatManager:ShowConfirmIconBySeatId(player.seatId)
        		else
        			ctx.seatManager:ShowConfirmWaitingIcon(player.seatId)
        		end
            end
        end
    end
end

-- 更新站起/换房按钮模式
function RoomQiuQiuController:updateChangeRoomButtonMode()
    if self.model:isSelfInSeat() then
        self.scene:setChangeRoomButtonMode(2)
    else
        self.scene:setChangeRoomButtonMode(1)
    end
end

--自动坐下不一定会坐，只有在外面设置了自动坐下、或快速开始进来的、或forceSit为true的时候
function RoomQiuQiuController:applyAutoSitDown(forceSit)
    if not self.model:isSelfInGame() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        if emptySeatId then
            local isAutoSit = nk.DictModule:getBoolean("gameData",nk.cookieKeys.AUTO_SIT, true)
            if isAutoSit or nk.SocketController:isPlayNow() or forceSit then
                local userData = nk.userData
                local roomData = nk.functions.getRoomQiuQiuDataByLevel(self.model.roomInfo.roomType)
                if not roomData then
                    return
                end

                if nk.functions.getMoney() > roomData.maxEnter and roomData.maxEnter ~= 0 then
                    nk.GCD.PostDelay(self, function()
                        self:overRoomMaxEnter(roomData.maxEnter)
                    end, nil, 1000)
                elseif nk.functions.getMoney() >= self.model.roomInfo.minBuyIn then
                    local isAutoBuyin = nk.DictModule:getBoolean("gameData",nk.cookieKeys.AUTO_BUY_IN, true)
                    nk.SocketController:seatDownQiuQiu(emptySeatId, math.min(nk.functions.getMoney(), self.model.roomInfo.defaultBuyIn), isAutoBuyin , true)                 
                else
                    --这里可能scene还未切换完成，等待1S再弹对话框
                    if userData.bankruptcyGrant and userData.bankruptcyGrant.maxBmoney and nk.functions.getMoney() < userData.bankruptcyGrant.maxBmoney then
                        nk.GCD.PostDelay(self, function()
                            --[[
                            if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                                nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_SITDOWN_PAY
                                nk.PopupManager:addPopup(BankruptHelpPopup, "RoomQiuQiu")
                            else
                                local args = {
                                    hasCloseButton = false,
                                    messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", nk.userData.bankruptcyGrant.maxBmoney), 
                                    firstBtnText=bm.LangUtil.getText("COMMON", "TO_SHOP"),
                                    secondBtnText=bm.LangUtil.getText("LOGINREWARD","INVITE_FRIEND"), 
                                    callback = function (type)
                                        if type == nk.Dialog.FIRST_BTN_CLICK then
                                            local StorePopup = require("game.store.popup.storePopup")
                                            local level = self.model:roomType()
                                            nk.PopupManager:addPopup(StorePopup,"RoomQiuQiu",true,level)
                                        elseif type == nk.Dialog.SECOND_BTN_CLICK then
                                            local InviteScene = require("game.invite.inviteScene")
                                            nk.PopupManager:addPopup(InviteScene,"RoomQiuQiu")
                                        end
                                    end
                                }
                                nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
                            end
                            --]]
                            nk.PopupManager:addPopup(BankruptHelpPopup, "RoomQiuQiu")
                        end, nil, 1000)
                    else
                        nk.GCD.PostDelay(self, function()
                            self:seatDownFail(bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"))
                        end, nil, 1000)
                    end
                end
            end
        else
            Log.printDebug("can't auto sit down, no emtpy seat")
        end
    end
end



-- 游戏开始，发牌动画结束后，反转自己的牌
function RoomQiuQiuController:showMyCard()
    Log.dump("showMyCard")
    local ctx = self.ctx
    local model = self.model
    ctx.seatManager:prepareDealCards()   
    ctx.dealCardManager:dealCards()    
end



-- 转向下一个玩家操作处理
function RoomQiuQiuController:turnTo_(seatId)
    local ctx = self.ctx
    local model = self.model
    if model:selfSeatId() == seatId then
        nk.SoundManager:playSound(nk.SoundManager.NOTICE)
        if nk.DictModule:getBoolean("gameData", nk.cookieKeys.SHOCK, true) then
            nk.GameNativeEvent:vibrate(500)
        end
    end

    EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_HIDE_MAKE_OPERATION)

    if seatId ~= -1 then
        --打光切换
        ctx.lampManager:show()
        ctx.lampManager:turnTo(self.seatManager:getSeatPositionId(seatId), true)
        -- --座位开始计时器动画
        ctx.seatManager:startCounter(seatId)
        --把状态名改回名字
        ctx.seatManager:updateSeatState(seatId)
    else
        ctx.lampManager:hide()
        ctx.seatManager:stopCounter()
    end
    --更新操作栏状态
    ctx.oprManager:updateOperationStatus()
end

-- 设置最佳牌型
function RoomQiuQiuController:bestCardMode(player,pack)
    local seatView = self.ctx.seatManager:getSelfSeatView()
    if seatView then
        --按server摆牌
        seatView.handCards_:setCardsByServer(pack.cards)
        --点数和牌型提示
        seatView:showCardTypeIf(player.specialCardsType)
        --如果弃牌了，禁止点击
        if not self.model:isSelfInGame() then
            seatView.handCards_:DisableCardsTouch()
            seatView:setCardPointBoardDard()
        end
    end
end

-- 等级晋升处理
function RoomQiuQiuController:processUpgrade(delay)
    -- TODO
    do return end
    local oldExp = checkint(nk.userData.exp)
    local selfSeatData = self.model:selfSeatData()
    local getExp = selfSeatData.getExp or 0
    local nowExp = oldExp + getExp

    if nowExp ~= oldExp then
        nk.userData.exp = nowExp
    end

    local isLevelConfigLoaded = nk.Level:isConfigLoaded()
    if not isLevelConfigLoaded then
        return
    end
    
    local nowLevel = nk.Level:getLevelByExp(nowExp);
    local oldLevel = nk.Level:getLevelByExp(oldExp);

    --升级相关
    if tonumber(nowLevel) > tonumber(oldLevel) then
        if not nk.userData["invitableLevel"] then
            nk.userData["invitableLevel"] = {}
        end
        table.insert(nk.userData["invitableLevel"], nowLevel)
        nk.GCD.PostDelay(self,function()
            nk.PopupManager:addPopup(UpgradePopup, "RoomQiuQiu")
        end, nil, delay*1000)
    end   
end

-- 坐下失败
function RoomQiuQiuController:seatDownFail(message)
    if self.ctx.model.roomInfo.roomName ~= "" then
        local args = {
            hasCloseButton = false,
            messageText = message, 
            firstBtnText = bm.LangUtil.getText("CRASH", "INVITE_FRIEND"),
            callback = function (type)
                if type == nk.Dialog.FIRST_BTN_CLICK then
                    local InviteScene = require("game.invite.inviteScene")
                    nk.PopupManager:addPopup(InviteScene,"RoomQiuQiu")
                end
            end
        }
        nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
    else
        local args = {
            hasCloseButton = false,
            messageText = message, 
            firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
            secondBtnText = bm.LangUtil.getText("CRASH", "INVITE_FRIEND"), 
            callback = function (type)
                if type == nk.Dialog.FIRST_BTN_CLICK then
                    self:onChangeRoom(true)
                elseif type == nk.Dialog.SECOND_BTN_CLICK then
                    local InviteScene = require("game.invite.inviteScene")
                    nk.PopupManager:addPopup(InviteScene,"roomQiuQiu")
                end
            end
        }
        nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
    end
end

function RoomQiuQiuController:processBestMaxMoney()
    if nk.userData.best and nk.userData.best.maxmoney then
        if nk.functions.getMoney() > nk.userData.best.maxmoney then
            local info = {}
            local params = {}
            params.maxmoney = nk.functions.getMoney()
            info.multiValue = params
            nk.HttpController:execute("updateMemberBest", {game_param = info})
            nk.userData.best["maxmoney"] = nk.functions.getMoney()
        end
    end
end

-- 判断是否破产
function RoomQiuQiuController:processBankrupt(delay,showView)
    local isBankrup = false
    if nk.userData.bankruptcyGrant and nk.functions.getMoney() < nk.userData.bankruptcyGrant.maxBmoney then
       -- if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
            isBankrup = true
            if showView then
                if delay and delay > 0 then
                    nk.GCD.PostDelay(self, function()
                        nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_BANKRUPTCY_PAY
                        nk.PopupManager:addPopup(BankruptHelpPopup, "RoomQiuQiu")
                    end, nil, delay*1000)
                else
                    nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_BANKRUPTCY_PAY
                    nk.PopupManager:addPopup(BankruptHelpPopup, "RoomQiuQiu")
                end
            end
       -- end
    end
    return isBankrup
end

-- 金币大于该场次提示
function RoomQiuQiuController:overRoomMaxEnter(limit)
    local args = {
        hasCloseButton = false,
        messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_OVER_MAX_MONEY",nk.updateFunctions.formatBigNumber(limit)), 
        firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
        secondBtnText = bm.LangUtil.getText("ROOM", "I_KNOW_ED"), 
        callback = function (type)
            if type == nk.Dialog.FIRST_BTN_CLICK then
                self:onChangeRoom(true)
            end
        end
    }
    nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
end

-------------------------------- handle function --------------------------


function RoomQiuQiuController:onLobbyBtnClick()
    if self.ctx.model:isSelfInGame() then
        nk.AnalyticsManager:report("New_Gaple_room_return", "room")
        local args = {
            messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG_QIUQIU"), 
            hasCloseButton = false,
            callback = function (type)
                if type == nk.Dialog.SECOND_BTN_CLICK then
                    self:onBackToHall()
                end
            end
        }
        nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
    else              
        self:onBackToHall()
    end
end

-- 返回到大厅
function RoomQiuQiuController:onBackToHall()
    -- 添加加载loading
    EnterRoomManager.getInstance():exitRoomLoading(2000, bm.LangUtil.getText("ROOM", "OUT_MSG"))
    nk.SocketController:logoutRoomQiuQiu()
    StateMachine.getInstance():changeState(States.Hall)
end

-- 重复登陆返回到登陆界面
function RoomQiuQiuController:doBackToLoginByDoubleLogin()
    EnterRoomManager.getInstance():exitRoomLoading(nil, bm.LangUtil.getText("ROOM", "OUT_MSG"))
    nk.SocketController:logoutRoomQiuQiu()
    StateMachine.getInstance():changeState(States.Login)
end


function RoomQiuQiuController:onChangeRoomBtnClick()
    if self.ctx.model:isSelfInGame() then
        local args = {
            messageText = bm.LangUtil.getText("ROOM", "CHANGE_ROOM_IN_GAME_MSG_QIUQIU"), 
            hasCloseButton = false,
            callback = function (type)
                if type == nk.Dialog.SECOND_BTN_CLICK then
                    self:onChangeRoom()
                end
            end
        }
        nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
    else              
        self:onChangeRoom()
    end
end

-- 切换房间
function RoomQiuQiuController:onChangeRoom(changeLowerRoom)
    changeLowerRoom = changeLowerRoom or false

    -- 添加加载loading
    EnterRoomManager.getInstance():exitRoomLoading(9000, bm.LangUtil.getText("ROOM", "CHANGING_ROOM_MSG"), function()
        nk.SocketController:logoutRoomQiuQiu()
        StateMachine.getInstance():changeState(States.Hall)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "CHANGE_ROOM_FAIL2")) 
    end)

    nk.SocketController:standUpQiuQiu(self.ctx.model:selfSeatId())

    local tid = self.ctx.model.roomInfo.tid
    nk.SocketController:logoutRoomQiuQiu()

    local roomType
    if changeLowerRoom then
        roomType = nk.functions.getRoomQiuQiuLevelByMoney(nk.functions.getMoney())
    else
        roomType = self.ctx.model.roomInfo.roomType
    end
    nk.SocketController:changeRoomAndLogin(roomType,nk.userData.mlevel,nk.functions.getMoney(), tid, nk.serverVersion)
end

function RoomQiuQiuController:onStandUp()
    if self.ctx.model:isSelfInGame() then
        local args = {
            hasCloseButton = false,
            messageText = bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG_QIUQIU"),  
            callback = function (type)
                if type == nk.Dialog.SECOND_BTN_CLICK then
                    nk.SocketController:standUpQiuQiu(self.ctx.model:selfSeatId())
                end
            end
        }
        nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
    else
        nk.SocketController:standUpQiuQiu(self.ctx.model:selfSeatId())
    end
end

-------------------------------- native event -----------------------------


-------------------------------- socket function ----------------------------

function RoomQiuQiuController:onGetRoomOk(data)
    self:requestLoginRoom()
end

function RoomQiuQiuController:onLoginRoomOK(pack)
    Log.printInfo("RoomQiuQiuController", "onLoginRoomOK")
    -- flag
    if self.initCtxed then
        EnterRoomManager.getInstance():enterRoomSuccess()
        self:dealWithLogin(pack)
        -- self.scene:makeSelfInSeat()
    else
        self.delayList = self.delayList or {}
        table.insert(self.delayList, {self.onLoginRoomOK, self, pack})
    end
end

-- 接收坐下广播
function RoomQiuQiuController:SVR_SEAT_DOWN_QIUQIU(pack)
    Log.dump(pack, "SVR_SEAT_DOWN_QIUQIU")
    local ctx = self.ctx
    local model = self.model

    --坐下
    local seatId, isAutoBuyin = model:processSitDown(pack)
    if isAutoBuyin then
        local seatView_ = ctx.seatManager:getSeatView(seatId)
        seatView_:playAutoBuyinAnimation(pack.anteMoney)
        return
    end

    if model:selfSeatId() == seatId then
        --上报坐下玩牌
        if nk.AdPlugin then
            nk.AdPlugin:reportPlay()
        end
        --更新全部座位状态，没人的座位会隐藏
        ctx.seatManager:updateAllSeatState()

        --把自己的座位转到中间去,还有黄色箭头动画(重连没有)
        if self.sitdownNotPlaying then
            ctx.seatManager:rotateSelfSeatToCenter(seatId, false)
        else
            ctx.seatManager:rotateSelfSeatToCenter(seatId, true)
            ctx.seatManager:playSitDownAnimation(seatId)
        end

        if model:isSelfInSeat() and not model:isSelfInGame() and not self.sitdownNotPlaying
        and model.gameInfo.gameStatus ~= consts.SVR_GAME_STATUS_QIUQIU.TABLE_CLOSE  
        and model.gameInfo.gameStatus ~= consts.SVR_GAME_STATUS_QIUQIU.TABLE_OPEN then
            self.waitHandles = nk.GCD.PostDelay(self,function()   
                self.waitHandles = nil
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "WAIT_NEXT_ROUND"))  
            end, nil, 2000, false)
        end
    else        
        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)     
        ctx.seatManager:playSitDownAnimation(seatId)  
    end

    self:updateChangeRoomButtonMode()
end

-- 接收坐下成功，只处理自己坐下错误的情况，成功的情况在广播有用户坐下那里处理
function RoomQiuQiuController:SVR_SELF_SEAT_DOWN_QIUQIU_OK(pack)
    Log.dump(pack, "SVR_SELF_SEAT_DOWN_QIUQIU_OK") 
    if pack.ret == 0 then
        --坐下失败
        self.sitdownNotPlaying = nil
        local errorCode = pack.errorCode
        nk.ErrorManager:ShowErrorTips(errorCode)
    end 
end

-- 接收游戏开始
function RoomQiuQiuController:SVR_GAME_START_QIUQIU(pack)
    Log.dump(pack, "SVR_GAME_START_QIUQIU")
    local ctx = self.ctx
    local model = self.model

    self:reset()
    self.sitdownNotPlaying = nil

    --牌局开始
    model:processGameStart(pack)

    -- 播放发牌动画
    self:showMyCard()

    local ctx = self.ctx
    local model = self.model
    model:processDeal(pack)       

    local valformat = string.format("%013.0f", model.gameInfo.totalAnte)
    ctx.chipManager.totalBoard_:setText((getFormatNumber(valformat, ", ")))

    --移动庄家指示
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), true)

    self.gameStartDelay_ = 2 + model:getNumInRound() * 3 * 0.1

    --重置操作栏自动操作状态
    ctx.oprManager:resetAutoOperationStatus()    
    
    --更新操作栏状态
    ctx.oprManager:hideOperationButtons(false)

    --更新座位状态
    ctx.seatManager:updateAllSeatState()

    self:updateChangeRoomButtonMode()
    
    --下底注
    for i=0,SeatCount - 1 do
        local player = model.playerList[i]
        if player then
            ctx.chipManager:betChip(player)
            nk.SoundManager:playSound(nk.SoundManager.CALL)
        end
    end
    nk.DictModule:setBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
end

-- 接收回复自己站起
function RoomQiuQiuController:SVR_STAND_UP_QIUQIU(pack)
    Log.dump(pack, "SVR_STAND_UP_QIUQIU")
    local ctx = self.ctx
    local model = self.model
    self.sitdownNotPlaying = nil
    pack.seatId = self.model:selfSeatId()
    if pack.seatId ~= -1 then
        local seatId = model:processStandUp(pack)
        self:StandUP_Process(seatId,true)
        ctx.oprManager:hideOperationButtons(false)
        ctx.seatManager:initFBInviteSeat()
        EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_HIDE_ALL)
    end
end

-- 接收到广播站起,服务器强制用户站起也是广播这个
function RoomQiuQiuController:SVR_OTHER_STAND_UP_QIUQIU(pack)
    Log.dump(pack, "SVR_OTHER_STAND_UP_QIUQIU")
    local ctx = self.ctx
    local model = self.model

    --如果tid对不上，就不处理
    --local oldTid = model.roomInfo ~= nil and model.roomInfo.tid or 0
    --if pack.tid ~= oldTid then
     --   return
    --end
    --先存一下自己的seatId, 如果上面的回复站起处理过了这里是-1,如果是服务器强制站起这里是正确值
    local selfSeatId = model:selfSeatId()
    --处理站起
    local seatId = model:processStandUp(pack)
    self:StandUP_Process(seatId,selfSeatId == seatId)
    
    --如果自己站起。selfSeatId == -1的情况是在回复自己站起那里已经执行了processStandUp
    if selfSeatId == seatId or selfSeatId == -1 then
        ctx.seatManager:HideSomething()
        ctx.seatManager:initFBInviteSeat()
        self.sitdownNotPlaying = nil
        EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_HIDE_ALL)
    end
end

-- 站起流程处理
function RoomQiuQiuController:StandUP_Process(seatId, isSelf)
    local ctx = self.ctx
    local positionId = ctx.seatManager:getSeatPositionId(seatId) 
    --更新全部座位状态，没人的座位会显示
    ctx.seatManager:updateAllSeatState()
    --播放站起动画，更新某个座位
    ctx.seatManager:playStandUpAnimation(seatId, function() 
        ctx.seatManager:updateSeatState(seatId)
    end)
    --干掉已经发的手牌
    self.dealCardManager:ThrowDeadCard(positionId)
    --如果当前座位正在计时，强制停止
    ctx.seatManager:stopCounterOnSeat(seatId)
    self:updateChangeRoomButtonMode()   
    if isSelf then 
        --把转动过的座位还原
        ctx.seatManager:rotateSeatToOrdinal()
        self:processBankrupt(1,true) 
        self:processBestMaxMoney()  
    end
end
-- 接收确认牌型阶段
function RoomQiuQiuController:SVR_CONFIRM_CARDS_STAGE(pack)
    Log.dump(pack, "SVR_CONFIRM_CARDS_STAGE")
    local ctx = self.ctx
    self.model.gameInfo.gameStatus = consts.SVR_GAME_STATUS.TABLE_CHECK
    if self.model:isSelfInGame() then 
        ctx.seatManager:getCardModeConfirm(pack.userOperatingTime,handler(self, self.confirmCardMode))
    end

    for i=0,SeatCount - 1 do
        local player = self.model.playerList[i]
        if player and player.isPlay == 1 then

            ctx.seatManager:ShowConfirmWaitingIcon(i)
            player.statemachine:doEvent(SeatStateMachine.Evt_CONFIRM_CARD)
            -- 把状态名改回名字
            player.statemachine:setStateText(player.statemachine:getStateDefaultText())
            ctx.seatManager:updateSeatState(i)
        end
    end
    -- 隐藏操作栏
    ctx.oprManager:hideOperationButtons(false)
    --隐藏灯光
    ctx.lampManager:hide()
    EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_HIDE_MAKE_OPERATION)
end

-- 接收牌型切换返回
function RoomQiuQiuController:SVR_BACK_CHANGE_CARDS(pack)
    Log.dump(pack, "SVR_BACK_CHANGE_CARDS")
    local seatView = self.ctx.seatManager:getSelfSeatView()
    if tolua.isnull(seatView) then
        return
    end
    if pack.ret == 1 then
        seatView:showCardTypeIf(pack.specialCardsType)
        seatView.handCards_:changeCardSucc()
    else
        seatView.handCards_:changeCardFail()
    end
end


-- 确认牌型处理
function RoomQiuQiuController:confirmCardMode()
    nk.SocketController:confirmCardMode()
    local seatView = self.ctx.seatManager:getSelfSeatView()
    if seatView and not tolua.isnull(seatView) then
    	seatView:disableCardsTouch()
    end
end

-- 接收被强制T出房间
function RoomQiuQiuController:SVR_KICK_OUT(pack)
    self:onBackToHall()
end

-- 接收到玩家操作的广播，把该位置的状态改变
function RoomQiuQiuController:SVR_BET_QIUQIU(pack)
    Log.dump(pack, "SVR_BET_QIUQIU")
    local ctx = self.ctx
    local model = self.model
    local seatId = model:processBetSuccess(pack)
    --更新座位信息
    ctx.seatManager:updateSeatState(seatId)
    --总筹码数字
    local valformat = string.format("%013.0f", model.gameInfo.totalAnte)
    ctx.chipManager.totalBoard_:setText((getFormatNumber(valformat, ", ")))

    local player = model.playerList[seatId]
    local isSelf = player and model:isSelf(player.uid) or false
    if player and player.statemachine:getState() ~= SeatStateMachine.STATE_FOLD then
        --如果当前座位正在计时，强制停止
        ctx.seatManager:stopCounterOnSeat(seatId)
        ctx.chipManager:betChip(player)       
        nk.SoundManager:playSound(nk.SoundManager.CALL)
        -- all in
        if player.anteMoney == 0 then
            nk.SoundManager:playSound(nk.SoundManager.RAISE)
        end
        if isSelf then
            ctx.oprManager:hideOperationButtons(false)
        end
    elseif player then 
        --干掉已经发的手牌
        local positionId = ctx.seatManager:getSeatPositionId(seatId) 
        self.dealCardManager:ThrowDeadCard(positionId)    --一个有动画一个直接隐藏
        --手牌变灰
        if isSelf then
            local seatView = self.ctx.seatManager:getSelfSeatView()
            seatView.handCards_:addDarkWithNum(player.cardsCount)
        end
      --如果当前座位正在计时，强制停止
        ctx.seatManager:stopCounterOnSeat(seatId)
    end
end

-- 接收到轮到下个操作的广播，操作者状态改变
function RoomQiuQiuController:SVR_NEXT_BET_QIUQIU(pack)
    Log.dump(pack, "SVR_NEXT_BET_QIUQIU")
    local model = self.model
    local ctx = self.ctx
    local seatId = model:processTurnTo(pack)
    self:turnTo_(seatId)
end

-- 接收服务器发第四张牌
function RoomQiuQiuController:SVR_RECEIVE_FOURTH_CARD(pack)
    Log.dump(pack, "SVR_RECEIVE_FOURTH_CARD")
    local ctx = self.ctx
    local model = self.model
    model:processFourthCardsStage(pack)
    --只会发给还在玩的人
    for i, seatId in ipairs(pack.seatIds) do
        local player = model.playerList[seatId]
        if player then
            if model:selfSeatId() == seatId then
                local selfSeatData = model:selfSeatData()
                if pack.cards then
                    ctx.dealCardManager:dealCardToPlayer(seatId)
                end
                --上面发出第四张牌后，自己要按后端给的最优再排序
                nk.GCD.PostDelay(self, function()
                    self:bestCardMode(selfSeatData,pack)
                end, nil, 1200)
            else
                model.playerList[seatId].cardsCount = 4
                ctx.dealCardManager:dealCardToPlayer(seatId)
                ctx.seatManager:stopCounterOnSeat(seatId)
                ctx.seatManager:updateSeatState(seatId)
            end

            --第四张牌重新谈话，状态名改回自己的名字，除了allin的
            if player and player.statemachine:getState() == SeatStateMachine.STATE_WAITING then
               player.statemachine:setStateText(player.statemachine:getStateDefaultText())
               --把状态名改回名字
               ctx.seatManager:updateSeatState(seatId)
            end
        end
    end

    ctx.lampManager:hide()
    ctx.seatManager:stopCounter()
    ctx.oprManager:updateOperationStatus()
end

-- 接收亮牌
function RoomQiuQiuController:SVR_SHOW_CARD(pack)
    Log.dump(pack, "SVR_SHOW_CARD")
    local model = self.model
    model:processShowHand(pack)
    --这里只标注需要亮牌,亮牌动画在发牌动画结束之后
end

-- 接收房间内广播
function RoomQiuQiuController:SVR_ROOM_BROADCAST(pack)
    Log.dump(pack, "SVR_ROOM_BROADCAST")
    local info = json.decode(pack.info)
    if not info then
        return
    end
    local uid = tonumber(pack.uid)
    local isSelf = (uid == nk.userData.uid)
    local mtype = info.mtype
    local model = self.model

    if mtype == 1 then
        --聊天消息

        --屏蔽用户记录
        local gagData = nk.DataProxy:getData(nk.dataKeys.ROOM_GAG) or {}
        for _, v in ipairs(gagData) do
            if v.uid == uid then
                if v.time - os.time() < 24*3600 then
                    return
                end
            end
        end

        --聊天记录
        local chatHistory = nk.DataProxy:getData(nk.dataKeys.ROOM_CHAT_HISTORY)
        if not chatHistory then
            chatHistory = {}
        end

        local msg = bm.LangUtil.getText("ROOM", "CHAT_FORMAT", "[" .. info.name .. "]", info.msg)
        chatHistory[#chatHistory + 1] = {messageContent = msg, time = os.time(), mtype = 2, sendUid = uid}
        nk.DataProxy:setData(nk.dataKeys.ROOM_CHAT_HISTORY, chatHistory)

        local seatId = model:getSeatIdByUid(uid)
        self.animManager:showChatMsg(seatId,info.msg)
    elseif mtype == 2 then   --废弃
        -- nk.SocketController:synchroUserInfo()
    elseif mtype == 3 then
        -- 赠送礼物
        local giftId = info.giftId
        local fromUid = uid
        local toUidArr = info.tuids
        local toSeatIdArr = {}
        for _,v in pairs(toUidArr)do
            local tsid = model:getSeatIdByUid(v)
            if v == nk.userData.uid then
                nk.userData['gift'] = giftId
            end
            if tsid ~= -1 then
                table.insert(toSeatIdArr,tsid)
            end
        end
        local function callback( ... )
            if isSelf then
                nk.SocketController:synchroUserInfo()
            end
        end
        self.animManager:playSendGiftAnimation(giftId, fromUid, toUidArr,callback)
    elseif mtype == 4 then  --废弃
        -- 设置礼物
        -- local seatId, giftId = param1, param2
        -- if seatId ~= -1 then
        --     self.seatManager:updateGiftUrl(seatId, giftId)
        -- end
        -- nk.SocketController:synchroUserInfo()
    elseif mtype == 5 then
        -- 发送表情
        local seatId = model:getSeatIdByUid(uid)
        local faceId = info.faceId
        local fType = info.fType
        local isSelf = (uid == nk.userData.uid) and true or false
        local minusChips = 0 --是否需要扣费 test
        if seatId then
            self.animManager:playExpression(seatId, faceId)
            nk.CommonExpManage.addCommonExp(faceId)
            if isSelf and minusChips > 0 then
                --是自己并且有扣钱，播放扣钱动画
                self.animManager:playChipsChangeAnimation(seatId, -minusChips)
            end
        end
        if isSelf then
            nk.SocketController:synchroUserInfo()
        end
    elseif mtype == 6 then
        --互动道具
        local fromSeatId = model:getSeatIdByUid(uid)
        local toSeatIds = info.toSeatIds
        local selfUid = nk.userData.uid
        local fromPlayer = model.playerList[fromSeatId]
        local pnid = info.pnid
        local pid = info.pid
        local num = info.num or 1
        for _,v in pairs(toSeatIds) do
            if v == 8 then
                if selfUid ~= uid then
                    -- 荷官
                    self.animManager:playHddjAnimation(fromSeatId, v, pid)
                end
                if fromPlayer then
                    local fromPlayerName = fromPlayer.userInfo.name
                    nk.GCD.PostDelay(self, function()
                        local isBad = false
                        if pid == 2 or pid == 6 or pid == 9 or pid == 7 then
                            isBad = true
                        end
                        self:playDealerBubble(fromPlayerName, isBad)
                    end, nil, 2000)
                end
            else
                local toPlayer = model.playerList[v]
                if selfUid ~= uid and toPlayer and fromPlayer then
                    --自己发送的互动道具动画已经提前播过了
                    self.animManager:playHddjAnimation(fromSeatId, v, pid, num)
                end
            end
        end
        if isSelf then
            nk.SocketController:synchroUserInfo()
        end
    elseif mtype == 7 then
        --给荷官赠送筹码
        local fee = info.fee
        local num = info.num
        local uid = uid
        local fromSeatId = model:getSeatIdByUid(uid)
        local toSeatId = 8
        local player = self.model.playerList[fromSeatId]
        if player then
            self.animManager:playSendChipAnimation(fromSeatId, toSeatId, fee)

            nk.GCD.PostDelay(self, function()
                self.ctx.dealerManager:kissPlayer()
                self:playDealerBubble(player.userInfo.name)
            end, nil, 2000)

            local sendNumber_ = nk.DictModule:getInt("gameData", nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, 5)
                sendNumber_ = sendNumber_  - 1
                nk.DictModule:setInt("gameData", nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, sendNumber_)
            if sendNumber_ <= 0 then
                nk.GCD.PostDelay(self, function()
                    self.animManager:playHddjAnimation(toSeatId, fromSeatId,math.random(3,4))
                end, nil, 4000)
                nk.DictModule:setInt("gameData", nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, 5)
            end
        end
        if isSelf then
            nk.SocketController:synchroUserInfo()
        end
    end
end

-- 接收广播用户确认切牌结果
function RoomQiuQiuController:SVR_BOARDCAST_CONFIRM_CARD(pack)
    Log.dump(pack, "SVR_BOARDCAST_CONFIRM_CARD")
    self.ctx.seatManager:ShowConfirmIconBySeatId(pack.seatId)
end

-- 接收游戏结束
function RoomQiuQiuController:SVR_GAME_OVER_QIUQIU(pack)
    Log.dump(pack, "SVR_GAME_OVER_QIUQIU")
    local ctx = self.ctx
    local model = self.model

    --如果确认牌型的包延迟的话，强制完成。这个放在processGameOver前面
    ctx.seatManager:forceShowComfirmIconInPlay()

    model:processGameOver(pack)
    --隐藏灯光
    ctx.lampManager:hide()
    --禁用操作按钮
    ctx.oprManager:blockOperationButtons()
    --座位停止计时器
    ctx.seatManager:stopCounter()
    --亮牌
    self.seatManager:showHandCard()
    --收到结算包就关掉确认牌型倒计时,如果确认牌型的包延迟的话
    ctx.seatManager:HideSomething()
    --隐藏新手引导
    EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_HIDE_ALL)

    -- 延迟处理
    local resetDelayTime = (4 + #model.gameInfo.bonusList * 3)*1000   --整个结算时间,基础时间4s + 奖池个数*3s
    local chipDelayTime = 2000                  --亮牌时间2秒，之后再分池、显示winner
    -- 分奖池动画
    nk.GCD.PostDelay(self, function()
        ctx.chipManager:GameOverShareBonus(model.gameInfo.bonusList)  
    end, nil, chipDelayTime)

    --隐藏确认牌型提示icon
    nk.GCD.PostDelay(self, function()
        self.seatManager:HideAllConfirmIcon()
    end, nil, chipDelayTime)

    local isBankrup = self:processBankrupt(0,false)
    if not isBankrup and (self.model:isSelfInSeat()) and not UpgradePopup.isShowIng then
        self:processUpgrade(chipDelayTime +  2000)
    end

    -- 刷新游戏状态
    nk.GCD.PostDelay(self, self.reset, nil, resetDelayTime)
    local isServerRetire = nk.DictModule:getBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
    if isServerRetire then
        nk.GCD.PostDelay(self, function()
            local tid = self.model.roomInfo.tid
            local roomType = self.model.roomInfo.roomType
            nk.SocketController:changeRoomAndLogin(roomType,nk.userData.mlevel,nk.functions.getMoney(), tid,nk.serverVersion)
            nk.DictModule:setBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
        end, nil, resetDelayTime)
    end
end

-- 接收SERVER广播更新UserInfo
function RoomQiuQiuController:SVR_SYNC_USERINFO(pack)
    Log.dump(pack, "SVR_SYNC_USERINFO")
    if pack and pack.uid then
        local uid = json.decode(pack.uid)
        local info = json.decode(pack.info)
        local seatId = self.model:getSeatIdByUid(uid)
        local player = self.model.playerList[seatId]
        if player and player.userInfo then
            local userinfo =  player.userInfo 
            if info then
                userinfo.mexp = info.mexp
                userinfo.mlose = info.mlose
                userinfo.mavatar = info.mavatar
                userinfo.mlevel = info.mlevel
                userinfo.money = info.money
                userinfo.msex = info.msex
                userinfo.name = info.name
                userinfo.sitemid = info.sitemid
                userinfo.mwin = info.mwin
                userinfo.giftId = info.giftId
            end
        end
        if seatId > -1 then
            self.seatManager:updateSeatState(seatId)
        end
    end
end

-- 接收服务器通知退休
function RoomQiuQiuController:SVR_MSG_SEND_RETIRE()
    Log.printInfo("SVR_MSG_SEND_RETIRE ")
    nk.DictModule:setBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, true)
end

-- 强制踢出房间
function RoomQiuQiuController:SVR_FORCE_USER_OFFLINE(pack)
    Log.printInfo("RoomQiuQiuController", "SVR_FORCE_USER_OFFLINE ")
    if pack.errorCode then
        if pack.errorCode == nk.ErrorManager.Error_Code_Maps.DOUBLE_LOGIN then
            local args = {
                hasCloseButton = false,
                hasFirstButton = false,
                messageText = T("您的账户在别处登录"), 
                secondBtnText = T("确定"), 
                callback = function (type)
                    if type == nk.Dialog.SECOND_BTN_CLICK then
                        self:doBackToLoginByDoubleLogin()
                    end
                end
            }
            nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
        end
    end
end

function RoomQiuQiuController:SVR_LOGIN_OK(pack)
    --重连成功的时候，重置这些
    nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 5)
    EnterRoomManager.getInstance():releaseLoading()
    local data = pack
    if data.tid > 0 then
        -- 重连房间
        nk.tid = data.tid
        nk.SocketController:loginRoom(nk.tid)
    else
        local model = self.model
        nk.tid = model.roomInfo.tid
        nk.SocketController:loginRoom(nk.tid)
    end
end

function RoomQiuQiuController:SVR_SEND_TIP_TO_GIRL(pack)
    if pack.ret == 1 then
        nk.functions.setMoney(pack.totalMoney)
        local selfData = self.model:selfSeatData()
        if selfData then
            selfData.anteMoney = pack.anteMoney
            self.seatManager:updateSeatState(selfData.seatId)
        end
        --广播打赏荷官
        nk.SocketController:sendDealerChip(pack.count,1)
    else
        nk.ErrorManager:ShowErrorTips(pack.errorCode)
    end
end

function RoomQiuQiuController:SVR_SEND_ROOM_QIUQIU_COST_PROP(pack)
    if pack.ret == 1 then
        nk.functions.setMoney(pack.totalMoney)
        local selfData = self.model:selfSeatData()
        if selfData then
            selfData.anteMoney = pack.anteMoney
            self.seatManager:updateSeatState(selfData.seatId)
        end
        --广播
        if pack.type == 1 then
            nk.SocketController:sendExpression(1,pack.id)
        elseif pack.type == 2 then
            nk.SocketController:sendProp(pack.id, {pack.targetSeatId} , 2001, pack.num or 1)
            self.ctx.animManager:playHddjAnimation(self.ctx.model:selfSeatId(), pack.targetSeatId,pack.id, pack.num or 1)
        end
    else
        nk.ErrorManager:ShowErrorTips(pack.errorCode,pack.type)
    end
end

function RoomQiuQiuController:SVN_AUTO_ADD_MIN_CHIPS(pack)
    if pack and pack.haveChips then
        local autoAddMinChips=pack.haveChips
        if not self.sitdownNotPlaying then
            self.autoAddMinChipsHandles = nk.GCD.PostDelay(self,function()   
                self.autoAddMinChipsHandles = nil
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SETTING", "AUTO_BUYIN_TIPS",nk.updateFunctions.formatBigNumber(autoAddMinChips))) 
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("SETTING", "AUTO_BUYIN_TIPS2"))
            end, nil, 1000)
        end

        local seatView = self.seatManager:getSelfSeatView()
        if seatView then
            seatView:SetSeatChipTxt(autoAddMinChips)
        end
    end
end

-------------------------------- event listen -----------------------------

function RoomQiuQiuController:onSocketError(errorCode)
    self.sitdownNotPlaying = self.model:isSelfInSeat() and (not self.model:isSelfInGame())   --当前在座位上，但是没有玩牌
    self.sitdownPos = self.model:selfSeatId() ~= -1 and self.model:selfSeatId() or nil     --在坐下的情况下要记录位置,用来重连同一个位置
    
    if self.model.gameInfo then
        self.tableTotalChipTemp = self.model.gameInfo.totalAnte         --重连之前的桌面上的总筹码
    end

    --连接server失败,retry三次为一组，三秒后在进行一组连接，不断重复
    if errorCode == consts.SVR_ERROR.ERROR_CONNECT_FAILURE then       
        -- self:showErrorByDialog_(T("服务器连接失败"))
        nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
        nk.SocketController:connect()
    --心跳包超时三次跑这里，断开连接再重连
    elseif errorCode == consts.SVR_ERROR.ERROR_HEART_TIME_OUT then       
        -- self:showErrorByDialog_(T("服务器响应超时"))
        nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
        nk.SocketController:connect()
    --连接server成功，但登录超时(5秒内没有回复成功)，判定失败,断开连接，3秒后再连接
    elseif errorCode == consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT then       
        -- self:showErrorByDialog_(T("服务器登录超时"))   
        nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
        nk.SocketController:connect()
    end
end

function RoomQiuQiuController:playDealerBubble(nick, isBad)
    if not self.prevPlayDealerBubbleTime_ then
        self.prevPlayDealerBubbleTime_ = true
        local DEALER_SPEEK_ARRAY
        if isBad then
            DEALER_SPEEK_ARRAY = bm.LangUtil.getText("ROOM", "DEALER_SPEEK_BAD_ARRAY")
        else
            DEALER_SPEEK_ARRAY = bm.LangUtil.getText("ROOM", "DEALER_SPEEK_ARRAY")
        end
        local array = {}
        for i,v in ipairs(DEALER_SPEEK_ARRAY) do
            local kk = bm.LangUtil.formatString(v, nick or "")
            table.insert(array, kk)
        end
        DEALER_SPEEK_ARRAY = array

        local dealerSpeakLengt = #DEALER_SPEEK_ARRAY
        local textId = math.round(math.random(1, dealerSpeakLengt))
        if textId <= dealerSpeakLengt then
            if textId == 0 then
                textId = 3
            end
            self:showBubble(textId, DEALER_SPEEK_ARRAY)
            nk.GCD.PostDelay(self, function()
                self.prevPlayDealerBubbleTime_ = false
            end, nil, 3000)
        end

    end
end

function RoomQiuQiuController:showBubble(textId, DEALER_SPEEK_ARRAY)
    local RoomChatBubble = import("game.roomGaple.views.roomChatBubble")
    local bubble = new(RoomChatBubble,DEALER_SPEEK_ARRAY[textId], RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self.scene.nodes.animNode, 0, 0, self.scene.nodes.dealerChatNode)
    if bubble then
        nk.GCD.PostDelay(self,function()
            bubble:removeFromParent(true)
            bubble = nil
        end, nil, 5000)  
    end
end

function RoomQiuQiuController:handleDealerProp(hddjId)
    if self.model:isSelfInSeat() then
        local expCost = 0
        local roomId = tostring(self.model.roomInfo.roomType)
        local roomCostConf = self.model.roomCostConf
        if roomCostConf ~= nil and roomCostConf[roomId] and roomCostConf[roomId][2] ~= nil then
            expCost = roomCostConf[roomId][2]
        end
        nk.SocketController:sendRoomCostProp(expCost,2,hddjId,8)
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_IN_SEAT"))
    end
end

function RoomQiuQiuController:onSEAndBackToHall()
    nk.AnalyticsManager:report("New_Test_System_Error2", "Room")
    nk.functions.report_lua_error_Temp()
    self:onBackToHall()
end

function RoomQiuQiuController:onLimitTimeOpen(pack)
    self:updateView("openLimitTimeGiftbag",pack)
end

function RoomQiuQiuController:onLimitTimeClose(isBuySuccess)
    self:updateView("closeLimitTimeGiftbag",isBuySuccess)
end

----------------------------------table config-------------------------------

-- Provide cmd handle to call
RoomQiuQiuController.s_cmdHandleEx = 
{
    ["onLobbyBtnClick"] = RoomQiuQiuController.onLobbyBtnClick,
    ["changeRoom"] = RoomQiuQiuController.onChangeRoomBtnClick,
    ["standUp"] = RoomQiuQiuController.onStandUp,

    ["loginRoomOK"] = RoomQiuQiuController.onLoginRoomOK,
};

-- Java to lua native call handle
RoomQiuQiuController.s_nativeHandle = {
	
};

--除了这里，还有RoomQiuQiuData那里会取消过滤状态
function RoomQiuQiuController:suspendCondition(command)
    if not self.isSuspend then
        return false
    end
    --处于过滤的情况下,遇到以下的包取消过滤
    if command == "SVR_LOGIN_OK" or command == "SVR_KICK_OUT" then
        self.isSuspend = false
    else
        Log.dump(command,">>>>>>>>>>>>>>>>>>>>>>>>>> suspendCondition fliter")
    end
    return self.isSuspend
end

RoomQiuQiuController.s_socketCmdFuncMap = {
    ["SVR_GET_ROOM_OK"] = RoomQiuQiuController.onGetRoomOk,
    ["SVR_SELF_SEAT_DOWN_QIUQIU_OK"] = RoomQiuQiuController.SVR_SELF_SEAT_DOWN_QIUQIU_OK,
    ["SVR_GAME_START_QIUQIU"] = RoomQiuQiuController.SVR_GAME_START_QIUQIU,
    ["SVR_SEAT_DOWN_QIUQIU"] = RoomQiuQiuController.SVR_SEAT_DOWN_QIUQIU,
    ["SVR_STAND_UP_QIUQIU"] = RoomQiuQiuController.SVR_STAND_UP_QIUQIU,
    ["SVR_OTHER_STAND_UP_QIUQIU"] = RoomQiuQiuController.SVR_OTHER_STAND_UP_QIUQIU,
    ["SVR_CONFIRM_CARDS_STAGE"] = RoomQiuQiuController.SVR_CONFIRM_CARDS_STAGE,
    ["SVR_BACK_CHANGE_CARDS"] = RoomQiuQiuController.SVR_BACK_CHANGE_CARDS,
    ["SVR_KICK_OUT"] = RoomQiuQiuController.SVR_KICK_OUT,
    ["SVR_BET_QIUQIU"] = RoomQiuQiuController.SVR_BET_QIUQIU,
    ["SVR_NEXT_BET_QIUQIU"] = RoomQiuQiuController.SVR_NEXT_BET_QIUQIU,
    ["SVR_RECEIVE_FOURTH_CARD"] = RoomQiuQiuController.SVR_RECEIVE_FOURTH_CARD,
    ["SVR_SHOW_CARD"] = RoomQiuQiuController.SVR_SHOW_CARD,
    ["SVR_ROOM_BROADCAST"] = RoomQiuQiuController.SVR_ROOM_BROADCAST,
    ["SVR_BOARDCAST_CONFIRM_CARD"] = RoomQiuQiuController.SVR_BOARDCAST_CONFIRM_CARD,
    ["SVR_GAME_OVER_QIUQIU"] = RoomQiuQiuController.SVR_GAME_OVER_QIUQIU,
    ["SVR_SYNC_USERINFO"] = RoomQiuQiuController.SVR_SYNC_USERINFO,
    ["SVR_MSG_SEND_RETIRE"] = RoomQiuQiuController.SVR_MSG_SEND_RETIRE,
    -- ["SVR_FORCE_USER_OFFLINE"] = RoomQiuQiuController.SVR_FORCE_USER_OFFLINE,

    -- 断线重连
    ["SVR_LOGIN_OK"] = RoomQiuQiuController.SVR_LOGIN_OK,
    ["SVR_SEND_TIP_TO_GIRL"] = RoomQiuQiuController.SVR_SEND_TIP_TO_GIRL,
    ["SVR_SEND_ROOM_QIUQIU_COST_PROP"] = RoomQiuQiuController.SVR_SEND_ROOM_QIUQIU_COST_PROP,
    ["SVN_AUTO_ADD_MIN_CHIPS"] = RoomQiuQiuController.SVN_AUTO_ADD_MIN_CHIPS,
}

RoomQiuQiuController.s_httpRequestsCallBack = {

}

-- Event to register and unregister
RoomQiuQiuController.s_eventHandle = {
    [EventConstants.SVR_ERROR] = RoomQiuQiuController.onSocketError,
    [EventConstants.socketError] = RoomQiuQiuController.onSEAndBackToHall,
    [EventConstants.ROOM_DEALE_RPROP] = RoomQiuQiuController.handleDealerProp,
    [EventConstants.close_limit_time_giftbag] = RoomQiuQiuController.onLimitTimeClose,
    [EventConstants.open_limit_time_giftbag] = RoomQiuQiuController.onLimitTimeOpen,
}

return RoomQiuQiuController