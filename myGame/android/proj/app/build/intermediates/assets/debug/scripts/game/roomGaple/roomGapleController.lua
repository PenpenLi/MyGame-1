-- roomGapleController.lua
-- Last modification : 2016-05-11
-- Description: a controller in Hall moudle

local RoomModel = import("game.roomGaple.model.roomGapleModel")

local BankruptHelpPopup = require("game.bankrupt.bankruptHelpPopup")
local BankruptInvitePopup = require("game.bankrupt.bankruptInvitePopup")
local SeatManager = require("game.roomGaple.manage.seatManager")
local TableManager = require("game.roomGaple.manage.tableManager")
local UpgradePopup = require("game.upgrade.upgradePopup")
local DealCardManager = require("game.roomGaple.manage.dealCardManager")
local CountDownBox = require("game.roomGaple.views.countDownBox")
local LampManager = import("game.roomGaple.manage.lampManager")
local AnimManager = import("game.roomGaple.manage.animManager")
local OperationManager = import("game.roomGaple.manage.operationManager")

local RoomGapleController = class(GameBaseController);

local PACKET_PROC_FRAME_INTERVAL = 2

local SeatCount = 4

function RoomGapleController:ctor(state, viewClass, viewConfig, dataClass)
    Log.printInfo("RoomGapleController.ctor");
    self.m_state = state;
end

function RoomGapleController:resume()
    Log.printInfo("RoomGapleController.resume");
    GameBaseController.resume(self);
    -- EnterRoomManager.getInstance():enterRoomSuccess()
    self:requestLoginRoom()
end

function RoomGapleController:pause()
    Log.printInfo("RoomGapleController.pause");
    GameBaseController.pause(self);
    nk.loginRoomSuccess = false
end

function RoomGapleController:dtor()
    nk.GCD.Cancel(self)
    self:unbindDataObservers_()
    delete(self.model)
    delete(self.seatManager)
    delete(self.dealCardManager)
    delete(self.lampManager)
    delete(self.TableManager)
    delete(self.animManager)
    delete(self.oprManager)
    EnterRoomManager.getInstance():releaseLoading()
end

-- Provide state to call
function RoomGapleController:onBack()
    self:updateView("RoomGapleScene.onMenuBtnClick")
end

function RoomGapleController:initCtx(scene)
    local ctx = {}
    ctx.roomController = self
    ctx.scene = scene
    ctx.model = new(RoomModel)
    ctx.sceneName = "roomGaple"

    ctx.TableManager = new(TableManager)
    ctx.seatManager = new(SeatManager)
    ctx.dealCardManager = new(DealCardManager)
    ctx.lampManager = new(LampManager)
    ctx.animManager = new(AnimManager)
    ctx.oprManager = new(OperationManager)

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
    ctx.export(ctx.TableManager)
    ctx.export(ctx.seatManager)
    ctx.export(ctx.dealCardManager)
    ctx.export(ctx.lampManager)
    ctx.export(ctx.animManager)
    ctx.export(ctx.oprManager)

    self.packetCache_ = {}
    self.frameNo_ = 1 

    self.countDownBoxNode = new(CountDownBox,self.ctx)
    self.countDownBoxNode:setAlign(kAlignBottomRight)
    self.countDownBoxNode:setPos(140,10)
    self.scene.nodes.dealerNode:addChild(self.countDownBoxNode)
end

function RoomGapleController:createNodes()
    self.TableManager:createNodes()
    self.seatManager:createNodes()
    self.dealCardManager:createNodes()
    self.lampManager:createNodes()
    self.animManager:createNodes()
    self.oprManager:createNodes()

    self:bindDataObservers_()
end


-------------------------------- private function --------------------------

function RoomGapleController:requestLoginRoom()
    nk.SocketController:loginRoom(nk.tid)
end

function RoomGapleController:initLoginData(pack)
    dump(pack,"initLoginData")
    nk.tid = 0

    local ctx = self.ctx
    local model = self.model

    self:reset()

    --登录成功
    model:initWithLoginSuccessPack(pack)

    self.scene:removeLoading()

    --显示房间信息
    self.scene:setRoomInfoText(model.roomInfo)

    --初始化座位及玩家
    ctx.seatManager:initSeats(model.seatsInfo, model.playerList)

    --设置庄家指示
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), false, model:isSelfDealer())

    --初始隐藏灯光
    if model.gameInfo.curDealSeatId and model.gameInfo.curDealSeatId ~= -1 then
        ctx.lampManager:show()
        ctx.lampManager:turnTo(ctx.seatManager:getSeatPositionId(model.gameInfo.curDealSeatId), false, model.gameInfo.curDealSeatId == model:selfSeatId())
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

    --一些重连进来的展示
    self:doSomethingReLogin()

    -- 设置登录筹码堆
    ctx.TableManager:setLoginChipStacks()


    --绘制桌面的牌
    if model.tableCardList and #model.tableCardList > 0 then
        nk.reLoginRoom_ = true
        ctx.TableManager:updateTable(model.tableCardList, model.gameInfo.firstOutCardValue) 
        nk.reLoginRoom_ = false
    end
    nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, model:isSelfInSeat())

    nk.loginRoomSuccess = true
end


function RoomGapleController:doSomethingReLogin()
    local ctx = self.ctx
    local model = self.model
    --确认牌型倒计时框
    if model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_STOP then
        ctx.lampManager:hide()
        ctx.seatManager:stopCounter()
    end

    -- --重连期间说话时间过了自动弃牌，进来后要加黑禁止点击
    -- local selfData = model:selfSeatData()
    -- if selfData and selfData.userStatus == consts.SVR_BET_STATE.USER_STATE_GIVEUP then
    --     local seatView = ctx.seatManager:getSelfSeatView()
    --     seatView.handCards_:addDarkWithNum(selfData.cardsCount)
    -- end
end


function RoomGapleController:reset()
    print("RoomGapleController:reset", "RoomGapleController iccccccccccccc ")
    self.hasReset_ = true

    if not nk.updateFunctions.checkIsNull(self.animManager) then
        self.animManager:moveDealerTo(-1, true, false)
    end
    
    self.model:reset()
    self.dealCardManager:reset()
    self.TableManager:reset()
    self.seatManager:reset()

    self.lampManager:hide()
    nk.GCD.Cancel(self)
end

-------------------------------- handle function --------------------------

function RoomGapleController:setRoomSceneNode(scene)
    self:initCtx(scene)
end

function RoomGapleController:onReturnBtnClick()
    if self.model then
        if self.model:isSelfInGame() then
            nk.AnalyticsManager:report("New_Gaple_room_return", "room")
         
            local args = {
                messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG",self:getEscapeMoney()), 
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.Dialog.SECOND_BTN_CLICK then
                        self:onBackToHall()              
                    end
                end
            }
            nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)
        else
            self:onBackToHall()
        end
    end
end

-- 返回到大厅
function RoomGapleController:onBackToHall()
    nk.isInSingleRoom = false
    EnterRoomManager.getInstance():exitRoomLoading(2000, bm.LangUtil.getText("ROOM", "OUT_MSG"))
    nk.SocketController:logoutRoom()
    StateMachine.getInstance():changeState(States.Hall)
end

-- 重复登陆返回到登陆界面
function RoomGapleController:doBackToLoginByDoubleLogin()
    EnterRoomManager.getInstance():exitRoomLoading(1000, bm.LangUtil.getText("ROOM", "OUT_MSG"))
    nk.SocketController:logoutRoom()
    StateMachine.getInstance():changeState(States.Login)
end

function RoomGapleController:onStandUpBtnClick()
    if self.model then
        if self.model:isSelfInGame() then
            local args = {
                messageText = bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG",self:getEscapeMoney()), 
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.Dialog.SECOND_BTN_CLICK then
                        nk.SocketController:standUp(self.model:selfSeatId())
                    end
                end
            }
            nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)
        else
            nk.SocketController:standUp(self.model:selfSeatId())
        end
    end
end

function RoomGapleController:onChangeRoomBtnClick()
    if self.model then
        if self.model:isSelfInGame() then
            local args = {
                messageText = bm.LangUtil.getText("ROOM", "CHANGE_ROOM_IN_GAME_MSG",self:getEscapeMoney()), 
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.Dialog.SECOND_BTN_CLICK then
                        self:onChangeRoom()
                    end
                end
            }
            nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)
        else              
            self:onChangeRoom()
        end
    end
end

function RoomGapleController:onChangeRoom(changeLowerRoom)
    local changeLowerRoom = changeLowerRoom or false
    EnterRoomManager.getInstance():exitRoomLoading(9000, bm.LangUtil.getText("ROOM", "CHANGING_ROOM_MSG"), function()
        self:onBackToHall()
    end)
    local tid = self.model.roomInfo.tid
    nk.SocketController:logoutRoom()
    local roomType
    if changeLowerRoom then
        roomType = nk.functions.getRoomLevelByMoney(nk.functions.getMoney())
    else
        roomType = self.model.roomInfo.roomType
    end
    nk.SocketController:changeRoomAndLogin(roomType,nk.userData.mlevel,nk.functions.getMoney(), tid,nk.serverVersion)
end
-------------------------------- native event -----------------------------

-------------------------------- eventHandle ------------------------

function RoomGapleController:onGetCountDownBoxReward(reward)
    local selfSeatView = self.seatManager:getSelfSeatView()
    if selfSeatView and not nk.updateFunctions.checkIsNull(selfSeatView) then
        selfSeatView:SetSeatChipTxt(reward, false) 
    end
end

--打开个人信息弹窗，PHP返回后更新UserInfo
function RoomGapleController:onUpdateSeatidUserinfo(evt)
    local data = evt.data
    local seatId = evt.seatId
    if evt.isSelf then
        seatId = self.model:selfSeatId()
    end
    local player = self.model.playerList[seatId]
    if player and player.userInfo then
        local userinfo =  player.userInfo 
        userinfo.mexp = data.aUser.exp
        userinfo.mlose = data.aUser.lose
        userinfo.mavatar = data.aUser.micon
        userinfo.mlevel = data.aUser.mlevel
        userinfo.money = data.aUser.money
        userinfo.msex = data.aUser.msex
        userinfo.name = data.aUser.name
        userinfo.sitemid = data.aUser.sitemid
        userinfo.mwin = data.aUser.win
    end
    if seatId > -1 then
        self.seatManager:updateSeatState(seatId,true)
    end
end


function RoomGapleController:onSocketError(errorCode)
    --连接server失败
    if errorCode == consts.SVR_ERROR.ERROR_CONNECT_FAILURE then       
        self:showErrorByDialog_(T("服务器连接失败"))
        nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
        nk.SocketController:connect()
    --心跳包超时三次跑这里，断开连接再重连
    elseif errorCode == consts.SVR_ERROR.ERROR_HEART_TIME_OUT then       
        -- self:showErrorByDialog_(T("服务器响应超时"))
        nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
        nk.SocketController:connect()
    --连接server成功，但登录超时(5秒内没有回复成功)，判定失败,断开连接，3秒后再连接
    elseif errorCode == consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT then       
        self:showErrorByDialog_(T("服务器登录超时"))   
        nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
        nk.SocketController:connect()
    end
end

function RoomGapleController:showErrorByDialog_(msg)
    if not nk.isInSingleRoom then
        EnterRoomManager.getInstance():connectRoomLoading(9000, T("正在重连中，请稍候"))
    end
end

function RoomGapleController:onHideWaitTips()
    self.ctx.scene.waitbg:setVisible(false)
end

function RoomGapleController:onShowWaitTips()
    self.ctx.scene.waitbg:setVisible(true)
end

function RoomGapleController:onSEAndBackToHall()
    nk.AnalyticsManager:report("New_Test_System_Error1", "Room")
    nk.functions.report_lua_error_Temp()
    self:onBackToHall()
end

-------------------------------- event listen ------------------------

function RoomGapleController:onGetRoomOk(data)
    self:requestLoginRoom()
end

function RoomGapleController:onLoginServerSucc(data)
    --重连成功的时候，重置这些
    nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 5)
    --重连loading
    -- EnterRoomManager.getInstance():releaseLoading()
    if data.tid > 0 then
        -- 重连房间
        nk.tid = data.tid
        self:requestLoginRoom()
    else
        local model = self.model
        if model.roomInfo then
            nk.tid = model.roomInfo.tid
            self:requestLoginRoom()
        end
    end
end

--登录房间成功
function RoomGapleController:onLoginRoomSuccess(data)
    Log.printInfo("onLoginRoomSuccess onLoginRoomSuccess onLoginRoomSuccess ")
    EnterRoomManager.getInstance():enterRoomSuccess()
    -- self:cancelSuspend()
    self:initLoginData(data)
    -- 走自动坐下流程
    if not nk.isInSingleRoom then 
        self:applyAutoSitDown()
        if self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_RUNING then
            if not self.model:isSelfInSeat() and not self.model:isSelfInGame() then
                self.ctx.TableManager:runRuleTips()
            else
                self.ctx.TableManager:stopRuleTips()
            end
        end
    else
    end
end

-- 重连登录房间成功
function RoomGapleController:onReLoginRoomSuccess(pack)
    Log.dump(pack, "SVR_RE_LOGIN_ROOM_OK")
    -- self:cancelSuspend()
    nk.reLoginRoom = true
    self:initLoginData(pack)
    nk.reLoginRoom = false
    EnterRoomManager.getInstance():releaseLoading()

    if self.model:isSelfInGame() and self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_RUNING then
        if self.model.gameInfo.curDealSeatId and self.model.gameInfo.curDealSeatId ~= self.model:selfSeatId() then
            -- 别人庄家时自己手牌不能点击
            local selfSeatView = self.ctx.seatManager:getSeatView(self.model:selfSeatId())
            if selfSeatView then
                selfSeatView:setHandCardTouchStatus(false)
            end
            self:setLayerTouchEnabled(false)
        else
            self:setLayerTouchEnabled(true)
            self.ctx.seatManager:checkMyHandCard(pack.headCardValue, pack.tailCardValue)
        end
    end
    nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self.model:isSelfInSeat())
end

--只处理自己坐下错误的情况，成功的情况在广播有用户坐下那里处理
function RoomGapleController:onSelfSeatDownOk(pack)  
    Log.dump(pack,"RoomGapleController:SVR_SELF_SEAT_DOWN_OK") 
    if pack.ret == 0 then
        --坐下失败
        local errorCode = pack.errorCode
        local message
        if errorCode == nk.ErrorManager.Error_Code_Maps.CHIPS_LOW_ERROR then
            message = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY")
        else
            message = nk.ErrorManager:getErrorTips(errorCode)
        end
        self:seatDownFail(message)
    end  
end

function RoomGapleController:onBroadcastSeatDown(pack)
    Log.dump(pack, "RoomGapleController:SVR_SEAT_DOWN")
    local ctx = self.ctx
    local model = self.model

    --坐下
    local seatId, isAutoBuyin = model:processSitDown(pack)
    model.playerList[seatId].userInfo.money = pack.money
    if model:selfSeatId() == seatId then
        nk.functions.setMoney(pack.money)
    end
    if isAutoBuyin then
        local seatView_ = ctx.seatManager:getSeatView(seatId)
        local money = model.playerList[seatId].userInfo.money 
        if money then
            seatView_:playAutoBuyinAnimation(money)
        end
        return
    end

    if model:selfSeatId() == seatId then
        --上报坐下玩牌
         if nk.AdPlugin then
             nk.AdPlugin:reportPlay()
         end
        --更新全部座位状态，没人的座位会隐藏
        ctx.seatManager:updateAllSeatState()

        --把自己的座位转到中间去
        ctx.seatManager:rotateSelfSeatToCenter(seatId, true)
    else        
        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)       
    end

    ctx.seatManager:playSitDownAnimation(seatId)

    if model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_RUNING then
        local seatView = ctx.seatManager:getSeatView(seatId)
        if model:selfSeatId() == seatId then
            seatView:showWaitText()
            self:onShowWaitTips()
        end
        ctx.seatManager:fadeSeat(seatId)
    end
    if model:selfSeatId() == seatId then
        ctx.TableManager:stopRuleTips()
    end
end

-- 回复自己站起
function RoomGapleController:onSelfStandUpOk(pack)
    local ctx = self.ctx
    local model = self.model
    pack.seatId = self.model:selfSeatId()
    if pack.seatId ~= -1 then
        local seatId = model:processStandUp(pack)
        -- 广播站起的时候也会操作
        -- self:standUpProcess(seatId,true)
    end
end

-- 收到广播站起,服务器强制用户站起也是广播这个
function RoomGapleController:onBroadcastStandUp(pack)
    Log.dump(pack, "RoomGapleController:SVR_OTHER_STAND_UP  ")
    local ctx = self.ctx
    local model = self.model

    --先播放扣费动画，因为下面的代码会导致玩家信息获取失败
    if pack.escapeMoney and pack.escapeMoney > 0 and pack.moneyPool and pack.moneyPool > 0 then
        model:processPot(pack.moneyPool)
        local seatView = ctx.seatManager:getSeatView(pack.seatId)
        if seatView then
            self.animManager:playChipFlayAnim(1, seatView.chip_node, ctx.scene.m_prizePoolChipNode)
            seatView:SetSeatChipTxt(pack.escapeMoney * -1, true)
        end
        nk.GCD.PostDelay(self,function()
            ctx.TableManager:setLoginChipStacks()
        end, nil, 1000)
    end

    --先存一下自己的seatId, 如果上面的回复站起处理过了这里是-1,如果是服务器强制站起这里是正确值
    local selfSeatId = model:selfSeatId()
    local seatView = ctx.seatManager:getSeatView(pack.seatId)
    if selfSeatId == pack.seatId then
        seatView:hideWaitText()
        self:onHideWaitTips()
        if model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_RUNING then
            ctx.TableManager:runRuleTips()
        else
            ctx.TableManager:stopRuleTips()
        end
    end
    ctx.seatManager:unFadeSeat(pack.seatId)

    --处理站起
    local seatId = model:processStandUp(pack)
    self:standUpProcess(seatId,selfSeatId == seatId)

    -- 停止倒计时
    if pack.uid == nk.userData.uid or (not model:isSelfInSeat() or nk.functions.getInSeatNum(model.playerList,SeatCount) < 2) then
        ctx.TableManager:stopCountDownTips()
    end
end

function RoomGapleController:onBroadcastGameStart(pack)
    Log.dump(pack, "RoomGapleController:SVR_GAME_START")
    local ctx = self.ctx
    local model = self.model

    ctx.TableManager:stopCountDownTips()
    self:reset()

    --牌局开始
    model:processGameStart(pack)

    ctx.seatManager:prepareDealCards()   
    ctx.dealCardManager:dealCards()    

    nk.GCD.PostDelay(self,function()
        ctx.TableManager:setLoginChipStacks()
    end, nil, 1000)

    self.gameStartDelay_ = 2 + model:getNumInRound() * 3 * 0.1  

    --更新座位状态
    ctx.seatManager:updateAllSeatState()

    nk.GCD.PostDelay(self,function()
        --移动庄家指示
        ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), true, model:isSelfDealer())
        --灯光倒计时转向庄家
        self:turnTo_(model.gameInfo.dealerSeatId, false, model.gameInfo.dealerSeatId == model:selfSeatId())
    end, nil, (0.1*(#pack.playerCradList)*7 + 2)*1000)

    local selfSeatView = ctx.seatManager:getSeatView(model:selfSeatId())

    if model:isSelfInGame() and not model:isSelfDealer() then
        -- 别人庄家时自己手牌不能点击
        if selfSeatView then
            selfSeatView:setHandCardTouchStatus(false)
        end
        self:setLayerTouchEnabled(false)
    elseif model:isSelfInGame() then
        -- 自己是庄家，判断是否进行出牌提示
        nk.GCD.PostDelay(self,function()
            if selfSeatView then
                ctx.seatManager:checkMyHandCard(-1, -1)
            end
        end, nil, (0.1*(#pack.playerCradList)*7 + 2)*1000)
        self:setLayerTouchEnabled(true)
    end

    -- 下底注
    for i=0,SeatCount - 1 do
        local player = model.playerList[i]
        if player then
            local seatView = ctx.seatManager:getSeatView(player.seatId)
            self.animManager:playChipFlayAnim(1, seatView.chip_node, ctx.scene.m_prizePoolChipNode)
            nk.GCD.PostDelay(self,function()
                seatView:SetSeatChipTxt(self.model.roomInfo.blind * -1)
            end, nil, 1000)
        end
    end

    if model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_RUNING then
        if not model:isSelfInSeat() and not model:isSelfInGame() then
            ctx.TableManager:runRuleTips()
        else
            ctx.TableManager:stopRuleTips()
        end
    end
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
end

function RoomGapleController:onBroadcastNextBet(pack)
    Log.dump(pack, "RoomGapleController:SVR_NEXT_BET")
    local model = self.model
    local ctx = self.ctx
    local uid = nk.UserDataController.getUid()
    local seatId = model:processTurnTo(pack)
    if seatId >= 0 then
        self:turnTo_(seatId)
    end

    -- if pack.uid ~= uid then -- 不是玩家自己出牌
    --     dump(pack, "RoomGapleController:SVR_NEXT_BET ---000  others")
    -- else
    --     dump(pack, "RoomGapleController:SVR_NEXT_BET ---000  self")
    -- end

    Log.printInfo("onBroadcastNextBetshowCard", os.time())
    Log.printInfo("onBroadcastNextBetshowCard os.clock()", os.clock())

    local time = os.clock()
    local needAnim = true
    if not self.m_time or self.m_time == 0 then
        needAnim = true
        self.m_time  = time
    elseif time - self.m_time <= 0.5 then
        needAnim = false
        self.m_time  = time
    else
        needAnim = true
        self.m_time  = time
    end
    Log.printInfo("onBroadcastNextBetshowCard needAnim = ", needAnim)


    ctx.TableManager:showCard(pack,needAnim)
    local opSeatId = model:getSeatIdByUid(pack.uid)
    local selfSeatId = model:getSeatIdByUid(uid)
    local selfSeatView = ctx.seatManager:getSeatView(selfSeatId)
    if pack.uid ~= uid then
        -- 是别人出的牌
        if 0 == pack.opType then
            ctx.seatManager:showPass(opSeatId)
        end
    else
        -- 我的手牌状态还原
        if model:isSelfInGame() then
            ctx.seatManager:clearHandCardStatus(selfSeatId)
        end
    end
    if pack.nextUid == uid and selfSeatView then
        -- 轮到自己出牌
        local findCard = ctx.seatManager:checkMyHandCard(pack.headCardValue,pack.tailCardValue)
        if not findCard then
            self:playPassSound(pack.nextUid)
            ctx.seatManager:stopCounter()
            nk.GCD.PostDelay(self,function()
                nk.SocketController:sendCard(pack.nextUid, 0, 0, 1)
            end, nil, 2000)
        end
    else
        -- 别人出牌时自己手牌不能点击
        if model:isSelfInGame() and selfSeatView then
            selfSeatView:setHandCardTouchStatus(false)
        end
    end
    -- 更新玩家手牌数
    if 0 ~= pack.opType then
        ctx.seatManager:updateLastCardNum(opSeatId)
    else
        if pack.uid ~= uid then
            self:playPassSound(pack.uid)
        end
    end
    -- 更新“过”操作玩家的金币数
    if 0 == pack.opType and pack.passMoney > 0 then 
        -- 付费方
        local positionId = ctx.seatManager:getSeatPositionId(opSeatId)
        if ctx.seatManager:getSeatView(opSeatId) then
            ctx.seatManager:getSeatView(opSeatId):SetSeatChipTxt(pack.passMoney * -1, true)
            local paySeatId = model:getSeatIdByUid(pack.payMoneyUid)
            local paySeatView = ctx.seatManager:getSeatView(paySeatId)
            local getSeatId = model:getSeatIdByUid(pack.getMoneyUid)
            local getSeatView = ctx.seatManager:getSeatView(getSeatId)
            if paySeatView and getSeatView then
                self.animManager:playChipFlayAnim(2, paySeatView.chip_node, getSeatView.chip_node)
                nk.GCD.PostDelay(self,function()
                    if not nk.updateFunctions.checkIsNull(getSeatView) then
                        getSeatView:SetSeatChipTxt(pack.passMoney, true)
                    end
                end, nil, 1000)
            end
        end
    end

    if selfSeatView and 0 == pack.nextUid and 0 == pack.opType then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "APPEAR_DEAD_END"))
    end
end

function RoomGapleController:onBroadcastGameOver(pack)
    Log.dump(pack, "RoomGapleController:SVR_GAME_OVER")
    local ctx = self.ctx
    local model = self.model
    model:processGameOver(pack)
    
    --隐藏灯光
    ctx.lampManager:hide()
    --座位停止计时器
    ctx.seatManager:stopCounter()
    --亮牌
    self.seatManager:showHandCard()
    --更新座位状态
    ctx.seatManager:updateAllSeatState()
    --隐藏桌面出牌位置提示
    ctx.TableManager:hideCradSpaceTips()

    -- 延迟处理
    local resetDelayTime = 4   --整个结算时间,基础时间4s + 奖池个数*3s
    local chipDelayTime = 2                  --亮牌时间2秒，之后再分池、显示winner
    local payAnother = false

    -- 下局开始倒计时
    ctx.TableManager:runCountDownTips(pack.countDown or 10)
    nk.GCD.PostDelay(self,function( ... )
        if model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_STOP
            and model:isSelfInSeat() 
            and nk.functions.getInSeatNum(model.playerList,SeatCount) >= 2 then
            ctx.TableManager:showCountDownTips()
        end
    end, nil, resetDelayTime*1000)

    -- 牌型动画
    if pack.cardType and pack.cardType >= 1 and pack.cardType <= 4 and pack.endType and pack.endType == 1  then
        self.animManager:playCardTypeAnim(pack.cardType)
    end

    local delayEx = 0
    if pack.cardType and pack.cardType > 1 and pack.cardType <= 4 then
        delayEx = 2
        payAnother = true
    end

    local moneyPoolChange = 0

    --显示winner
    nk.GCD.PostDelay(self,function( ... )
        for i=0,SeatCount - 1 do
            local player = model.playerList[i]
            if player then 
                if player.turnMoney and player.turnMoney > 0 then
                    self.seatManager:playSeatWinAnimation(i)
                elseif player.turnMoney and player.turnMoney < 0 and payAnother then
                    local seatView = ctx.seatManager:getSeatView(player.seatId)
                    if seatView then
                        seatView:SetSeatChipTxt(player.turnMoney,true)
                        self.animManager:playChipFlayAnim(1, seatView.chip_node, ctx.scene.m_prizePoolChipNode)
                    end
                    moneyPoolChange = moneyPoolChange + model.roomInfo.blind * (pack.cardType - 1)
                end
                ctx.seatManager:updateSeatState(i)
            end
        end
        if moneyPoolChange > 0 then
            model:processPot(model.gameInfo.totalAnte + moneyPoolChange)
            nk.GCD.PostDelay(self,function( ... )
                ctx.TableManager:setLoginChipStacks()
            end, nil, 1000)
        end  
    end, nil, 0)

    -- 金币飞向赢家
    local winnerSeatId = model:getSeatIdByUid(pack.winnerUid)
    local winnerSeatView = ctx.seatManager:getSeatView(winnerSeatId)
    if winnerSeatView then
        player = model.playerList[winnerSeatId]
        nk.GCD.PostDelay(self,function( ... )
            self.animManager:playChipFlayAnim(4, ctx.scene.m_prizePoolChipNode, winnerSeatView.chip_node)
            ctx.TableManager.totalBoard_:playAddAnim(0)
        end, nil, (delayEx + 0.5)*1000)
        nk.GCD.PostDelay(self,function( ... )
            winnerSeatView:playChangeChipAnim(player.turnMoney,true) --只播放动画
        end, nil, (delayEx + 0.5 + 1)*1000)
    end

    if not nk.isInSingleRoom then
        local isBankrup = self:processBankrupt(0,false)
        if not isBankrup and (self.model:isSelfInSeat()) and not UpgradePopup.isShowIng then
            --非破产才弹升级动画
            self:processUpgrade(resetDelayTime)
        end
    end

    -- 刷新游戏状态
    nk.GCD.PostDelay(self,function( ... )
        self:reset()
    end, nil, resetDelayTime*1000)

    if self.model:isSelfInSeat() then
        local selfSeatView = ctx.seatManager:getSeatView(model:selfSeatId())
        if selfSeatView then
            selfSeatView:hideWaitText()
            self:onHideWaitTips()
            selfSeatView:setHandCardTouchStatus(false)
        end
        ctx.seatManager:unFadeSeat(model:selfSeatId())
    end
    ctx.TableManager:stopRuleTips()
    if not nk.isInSingleRoom then
        -- bm.EventCenter:dispatchEvent(nk.DailyTasksEventHandler.GET_TASK_LIST)
    end

    local isServerRetire = nk.DictModule:getBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
    if isServerRetire then
        nk.GCD.PostDelay(self,function( ... )
            local tid = self.model.roomInfo.tid
            local roomType = self.model.roomInfo.roomType
            nk.SocketController:changeRoomAndLogin(roomType,nk.userData.mlevel,nk.functions.getMoney(), tid, nk.serverVersion)
            nk.DictModule:setBoolean("gameData", nk.cookieKeys.SVR_MSG_SEND_RETIRE, false)
        end, nil, resetDelayTime*1000)
    end
end

function RoomGapleController:onKickOut()
    nk.isInSingleRoom = false
    self:onBackToHall()
end

-- SERVER广播更新UserInfo
function RoomGapleController:onSyncUserinfo(pack)
    Log.dump(pack, "RoomGapleController:SVR_SYNC_USERINFO")
    if pack and pack.uid then
        local uid = json.decode(pack.uid)
        local info = json.decode(pack.info)
        local seatId = self.model:getSeatIdByUid(uid)
        local player = self.model.playerList[seatId]
        if player and player.userInfo then
            local userinfo =  player.userInfo 
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
        if seatId > -1 then
            self.seatManager:updateSeatState(seatId,true)
        end
    end
end

function RoomGapleController:onServerSendRetire()
    Log.printinfo("SVR_MSG_SEND_RETIRE ", self.model:isSelfInSeat())
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.SVR_MSG_SEND_RETIRE, true)
end

function RoomGapleController:onServerSendRoomCostProp(pack)
    if pack.ret == 1 then
        nk.functions.setMoney(pack.totalMoney)
        local selfData = self.model:selfSeatData()
        if selfData then
            selfData.userInfo.money = pack.totalMoney
            selfData.anteMoney = pack.anteMoney
            self.seatManager:updateSeatState(selfData.seatId,true)
        end
        --广播
        if pack.type == 1 then
            nk.SocketController:sendExpression(1,pack.id,pack.num or 1)
        elseif pack.type == 2 then
            nk.SocketController:sendProp(pack.id, {pack.targetSeatId} , 2001, pack.num or 1)
            self.ctx.animManager:playHddjAnimation(self.ctx.model:selfSeatId(), pack.targetSeatId,pack.id,true,pack.num or 1)
        end
    else
        nk.ErrorManager:ShowErrorTips(pack.errorCode,pack.type)
    end
end

function RoomGapleController:onServerRoomBroadcast(pack)
    Log.dump(pack, "SVR_ROOM_BROADCAST")
    local info = json.decode(pack.info)
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
        -- local isSelf = (uid == nk.userData.uid) and true or false
        if isSelf then
            self.animManager:showChatMsg(seatId,info.msg,true)
        else
            self.animManager:showChatMsg(seatId,info.msg)
        end
    elseif mtype == 2 then
        if isSelf then
            nk.SocketController:synchroUserInfo()
        end
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
    elseif mtype == 4 then
        -- 设置礼物
        if isSelf then
            nk.SocketController:synchroUserInfo()
        end
    elseif mtype == 5 then
        --发送表情
        local seatId = model:getSeatIdByUid(uid)
        local faceId = info.faceId
        local fType = info.fType
        -- local isSelf = (uid == nk.userData.uid) and true or false
        local minusChips = 0 --是否需要扣费 test
        local count = info.count
        if seatId then
            self.animManager:playExpression(seatId, faceId, isSelf)
            nk.CommonExpManage.addCommonExp(faceId)
            if isSelf and minusChips > 0 then
                --是自己并且有扣钱，播放扣钱动画
                self.animManager:playChipsChangeAnimation(seatId, -minusChips, isSelf)
            end
            local seatView = self.seatManager:getSeatView(seatId)
            if not isSelf and seatView and count and count > 0 then
                seatView:SetSeatChipTxt(count * -1, false)
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
            local toPlayer = model.playerList[v]
            if selfUid ~= uid and toPlayer and fromPlayer then
                --自己发送的互动道具动画已经提前播过了
                if toPlayer.uid == selfUid then
                    self.animManager:playHddjAnimation(fromSeatId, v, pid, true, num)
                else
                    self.animManager:playHddjAnimation(fromSeatId, v, pid, false, num)
                end
            end
        end
        if fromSeatId and selfUid ~= uid then
            local seatView = self.seatManager:getSeatView(fromSeatId)
            if seatView and num and num > 0 then
                seatView:SetSeatChipTxt(num * -1, false)
            end
        end
        if isSelf then
            nk.SocketController:synchroUserInfo()
        end
    end
end

-- 强制踢出房间
function RoomGapleController:onServerForceUserOffline(pack)
    Log.printInfo("RoomGapleController", "SVR_FORCE_USER_OFFLINE ")
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
            nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)
        end
    end
end


function RoomGapleController:applyAutoSitDown()
    if not self.model:isSelfInGame() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        if emptySeatId then
            local isAutoSit = nk.DictModule:getBoolean("gameData",nk.cookieKeys.AUTO_SIT, true)
            if isAutoSit or nk.SocketController:isPlayNow() then
                local userData = nk.userData
                print(nk.functions.getMoney(), self.model.roomInfo.minBuyIn, "applyAutoSitDown")
                if nk.functions.getMoney() >= (self.model.roomInfo.minBuyIn or 0) then
                    Log.printInfo("auto sit down", emptySeatId)
                    local isAutoBuyin = nk.DictModule:getBoolean("gameData",nk.cookieKeys.AUTO_BUY_IN, true)
                    nk.SocketController:seatDown(emptySeatId, true)                  
                else
                    --这里可能scene还未切换完成，等待1S再弹对话框
                    if userData.bankruptcyGrant and userData.bankruptcyGrant.maxBmoney and nk.functions.getMoney() < userData.bankruptcyGrant.maxBmoney then
                        nk.GCD.PostDelay(self, function()
                            --[[
                            if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                                --  nk.PopupManager:addPopup(BankruptInvitePopup, "hall") 
                                nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_SITDOWN_PAY
                                nk.PopupManager:addPopup(BankruptHelpPopup, "hall")
                            else
                                local args = {
                                    messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", nk.userData.bankruptcyGrant.maxBmoney), 
                                    hasCloseButton = false,
                                    firstBtnText=bm.LangUtil.getText("COMMON", "TO_SHOP"),
                                    secondBtnText=bm.LangUtil.getText("LOGINREWARD","INVITE_FRIEND"),
                                    callback = function (type)
                                        if type == nk.Dialog.FIRST_BTN_CLICK then
                                            local StorePopup = require("game.store.popup.storePopup")
                                            local level = self.model:roomType()
                                            nk.PopupManager:addPopup(StorePopup,"roomGaple",true,level)
                                        elseif type == nk.Dialog.SECOND_BTN_CLICK then
                                            -- nk.AnalyticsManager:report("EC_H_Gold_Shortage_Invite","invite")
                                            local InviteScene = require("game.invite.inviteScene")
                                            nk.PopupManager:addPopup(InviteScene,"roomGaple")
                                        end
                                    end
                                }
                                nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)

                            end
                            --]]
                            nk.PopupManager:addPopup(BankruptHelpPopup, "hall")
                        end, nil, 1000)
                    else
                        nk.GCD.PostDelay(self, function()
                            if self then
                                self:seatDownFail(bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"))
                            end
                        end, nil, 1000)
                    end
                end
            end
        else
            Log.printInfo("can't auto sit down, no emtpy seat")
        end
    end
end

function RoomGapleController:seatDownFail(message)
    if self.ctx.model.roomInfo.roomName ~= "" then
        local args = {
            hasCloseButton = false,
            messageText = message,
            firstBtnText = bm.LangUtil.getText("CRASH", "INVITE_FRIEND"), 
            callback = function (type)
                if type == nk.Dialog.FIRST_BTN_CLICK then
                    local InviteScene = require("game.invite.inviteScene")
                    nk.PopupManager:addPopup(InviteScene,"roomGaple")
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
            callback = handler(self, function (obj, type)
                if type == nk.Dialog.FIRST_BTN_CLICK then
                    self:onChangeRoom(true)
                elseif type == nk.Dialog.SECOND_BTN_CLICK then
                    local InviteScene = require("game.invite.inviteScene")
                    nk.PopupManager:addPopup(InviteScene,"roomGaple")
                end
            end)
        }
        nk.PopupManager:addPopup(nk.Dialog,"RoomQiuQiu",args)
    end
end

function RoomGapleController:standUpProcess(seatId, isSelf)
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

    if isSelf then 

         --把转动过的座位还原
        ctx.seatManager:rotateSeatToOrdinal()

        self:processBankrupt(1,true) 
        self:processBestMaxMoney()  

    end
end

function RoomGapleController:setLayerTouchEnabled(enable)
    local ctx = self.ctx
    local model = self.model
    if ctx.TableManager.touchlayer_ then
        ctx.TableManager.touchlayer_:setLayerTouchEnabled(enable)
    end
end

function RoomGapleController:turnTo_(seatId)
    local ctx = self.ctx
    local model = self.model
    if model:selfSeatId() == seatId then
        nk.SoundManager:playSound(nk.SoundManager.NOTICE)
        if nk.DictModule:getBoolean("gameData", nk.cookieKeys.SHOCK, true) then
            nk.GameNativeEvent:vibrate(500)
        end
    end

    if seatId ~= -1 then
        --打光切换
        ctx.lampManager:show()
        ctx.lampManager:turnTo(self.seatManager:getSeatPositionId(seatId), true, model:selfSeatId() == seatId)

        --座位开始计时器动画
        ctx.seatManager:startCounter(seatId)
        --把状态名改回名字
        ctx.seatManager:updateSeatState(seatId)
    else
        ctx.lampManager:hide()
        ctx.seatManager:stopCounter()
    end

end

function RoomGapleController:processBestMaxMoney()
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

function RoomGapleController:processBankrupt(delay,showView)
    local isBankrup = false
    if nk.userData.bankruptcyGrant and nk.functions.getMoney() < nk.userData.bankruptcyGrant.maxBmoney then
       -- if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
            isBankrup = true
            if showView then
                if delay and delay > 0 then
                    nk.GCD.PostDelay(self,function( ... )
                        nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_BANKRUPTCY_PAY
                        nk.PopupManager:addPopup(BankruptHelpPopup, "hall")
                    end, nil, delay*1000)

                else
                    nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_BANKRUPTCY_PAY
                    nk.PopupManager:addPopup(BankruptHelpPopup, "hall")
                end
            end
  
       -- end
    end
    return isBankrup
end

function RoomGapleController:playPassSound(uid)
    local model = self.model
    local ctx = self.ctx
    local seatId = model:getSeatIdByUid(uid)
    local opSex = 0
    if model.playerList and model.playerList[seatId] and model.playerList[seatId].userInfo then
        opSex = model.playerList[seatId].userInfo.msex
    end
    if opSex and (2 == tonumber(opSex) or 0 == tonumber(opSex)) then
        nk.SoundManager:playSound(nk.SoundManager.PASS_WOMAN)
    else
        nk.SoundManager:playSound(nk.SoundManager.PASS_MAN)
    end
end

function RoomGapleController:getEscapeMoney()
    local escapeMoney = 0
    if not nk.isInSingleRoom then
        local roomData = nk.functions.getRoomDataByLevel(self.model.roomInfo.roomType)
        if roomData then
            escapeMoney = roomData.escapeMoney or 0
        end
        if escapeMoney < 100000 then
            escapeMoney = nk.updateFunctions.formatNumberWithSplit(escapeMoney)
        else
            escapeMoney = nk.updateFunctions.formatBigNumber(escapeMoney)
        end
    end
    return escapeMoney
end

function RoomGapleController:processUpgrade(delay)
    local oldExp = checkint(nk.userData["exp"])
    local selfSeatData = self.model:selfSeatData()
    local getExp = selfSeatData.getExp or 0
    local nowExp = oldExp + getExp

    if nowExp ~= oldExp then
        nk.userData["exp"] = nowExp
    end

    local isLevelConfigLoaded = nk.Level:isConfigLoaded()
    if not isLevelConfigLoaded then
        return
    end
    
    local nowLevel = nk.Level:getLevelByExp(nowExp);
    local oldLevel = nk.Level:getLevelByExp(oldExp);

    --升级相关
    if nowLevel and oldLevel and tonumber(nowLevel) > tonumber(oldLevel) then
        if not nk.userData["invitableLevel"] then
            nk.userData["invitableLevel"] = {}
        end
        table.insert(nk.userData["invitableLevel"], nowLevel)
        nk.GCD.PostDelay(self,function()
            nk.PopupManager:addPopup(UpgradePopup, "roomGaple")
        end, nil, delay*1000)

    end   
end

function RoomGapleController:bindDataObservers_()
    self.maxDiscountObserver_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", handler(self, function (obj, discount)
        if not nk.updateFunctions.checkIsNull(self.scene) then
            -- self.scene:setStoreDiscount(discount)
        end
    end))
end

function RoomGapleController:unbindDataObservers_()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", self.maxDiscountObserver_)
end

function RoomGapleController:onLimitTimeOpen(pack)
    self:updateView("openLimitTimeGiftbag",pack)
end

function RoomGapleController:onLimitTimeClose(isBuySuccess)
    self:updateView("closeLimitTimeGiftbag",isBuySuccess)
end

function RoomGapleController:suspendCondition(command)
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

-- function RoomGapleController:cancelSuspend()
--     if self.isSuspend then
--         self.isSuspend = false
--     end
-- end

-- Provide cmd handle to call
RoomGapleController.s_cmdHandleEx = 
{
    ["RoomGapleController.setRoomSceneNode"] = RoomGapleController.setRoomSceneNode,
    ["RoomGapleController.createNodes"] = RoomGapleController.createNodes,
    ["RoomGapleController.onReturnBtnClick"] = RoomGapleController.onReturnBtnClick,
    ["RoomGapleController.onStandUpBtnClick"] = RoomGapleController.onStandUpBtnClick,
    ["RoomGapleController.onChangeRoomBtnClick"] = RoomGapleController.onChangeRoomBtnClick,
    ["RoomGapleController.loginRoomOK"] = RoomGapleController.onLoginRoomSuccess,
    ["RoomGapleController.svnTableSync"] = RoomGapleController.onReLoginRoomSuccess,
}

-- Java to lua native call handle
RoomGapleController.s_nativeHandle = {
    
}

-- Event to register and unregister
RoomGapleController.s_eventHandle = {
    [EventConstants.GET_COUNTDOWNBOX_REWARD] = RoomGapleController.onGetCountDownBoxReward,
    [EventConstants.UPDATE_SEATID_USERINFO] = RoomGapleController.onUpdateSeatidUserinfo,
    [EventConstants.SVR_ERROR] = RoomGapleController.onSocketError,
    [EventConstants.socketError] = RoomGapleController.onSEAndBackToHall,
    [EventConstants.hideWaitTips] = RoomGapleController.onHideWaitTips,
    [EventConstants.close_limit_time_giftbag] = RoomGapleController.onLimitTimeClose,
    [EventConstants.open_limit_time_giftbag] = RoomGapleController.onLimitTimeOpen,
}

RoomGapleController.s_socketCmdFuncMap = {
    ["SVR_GET_ROOM_OK"] = RoomGapleController.onGetRoomOk,
    -- ["SVR_LOGIN_ROOM_OK"] = RoomGapleController.onLoginRoomSuccess,
    ["SVR_RE_LOGIN_ROOM_OK"] = RoomGapleController.onReLoginRoomSuccess,
    -- ["SVN_TABLE_SYNC"] = RoomGapleController.onReLoginRoomSuccess,
    ["SVR_LOGIN_OK"] = RoomGapleController.onLoginServerSucc,
    
    ["SVR_SELF_SEAT_DOWN_OK"] = RoomGapleController.onSelfSeatDownOk,
    ["SVR_SEAT_DOWN"] = RoomGapleController.onBroadcastSeatDown,
    ["SVR_STAND_UP"] = RoomGapleController.onSelfStandUpOk,
    ["SVR_OTHER_STAND_UP"] = RoomGapleController.onBroadcastStandUp,
    ["SVR_GAME_START"] = RoomGapleController.onBroadcastGameStart,
    ["SVR_NEXT_BET"] = RoomGapleController.onBroadcastNextBet,
    ["SVR_GAME_OVER"] = RoomGapleController.onBroadcastGameOver,
    ["SVR_KICK_OUT"] = RoomGapleController.onKickOut,
    ["SVR_SYNC_USERINFO"] = RoomGapleController.onSyncUserinfo,
    ["SVR_MSG_SEND_RETIRE"] = RoomGapleController.onServerSendRetire,

    ["SVR_SEND_ROOM_COST_PROP"] = RoomGapleController.onServerSendRoomCostProp,
    ["SVR_ROOM_BROADCAST"] = RoomGapleController.onServerRoomBroadcast,
    -- ["SVR_FORCE_USER_OFFLINE"] = RoomGapleController.onServerForceUserOffline,
}

RoomGapleController.s_httpRequestsCallBack = {

}


return RoomGapleController