--
-- Author: tony
-- Date: 2014-07-08 12:45:14
--
local SeatManager = class()

local BankruptInvitePopup = require("game.bankrupt.bankruptInvitePopup")
local BankruptHelpPopup = require("game.bankrupt.bankruptHelpPopup")
local seatView = require("game.roomGaple.views.seatView")
local seatViewScene = require(VIEW_PATH .. "roomGaple.roomGaple_seat")
local seatViewVar = VIEW_PATH .. "roomGaple.roomGaple_seat_layout_var"
local CountDownAnim = require("game.anim.countDownAnim")
-- local SeatProgressTimer = import(".views.SeatProgressTimer")
-- local UserInfoOtherDialog = import(".views.UserInfoOtherDialog")
-- local UserCrash = import("app.module.room.userCrash.UserCrash")
-- local roomUserinfoSelfPopup = import("game.userInfo.roomUserinfo.roomUserinfoSelfPopup")
-- local roomUserinfoOtherPopup = import("game.userInfo.roomUserinfo.roomUserinfoOtherPopup")



local SeatPosition = RoomViewPosition.SeatPosition
local seatCount = 4
local SeatMaxId = 3
local middleSeatId = 3
--座位旋转时间
local AtmullRomToTime = 0.5

local SEAT_PROGRESS_TIMER_TAG = 8390

local SEATS_4 = {0, 1, 2, 3}

local USE_COUNTER_POOL = false

function SeatManager:ctor()
    Log.printInfo("SeatManagerSeatManagerSeatManagerSeatManagerSeatManagerSeatManager ")
    EventDispatcher.getInstance():register(Event.Pause, self, self.onAppEnterBackground_)
    EventDispatcher.getInstance():register(Event.Resume, self, self.onAppEnterForeground_)
end

function SeatManager:dtor()
    EventDispatcher.getInstance():unregister(Event.Pause, self, self.onAppEnterBackground_)
    EventDispatcher.getInstance():unregister(Event.Resume, self, self.onAppEnterForeground_)
    if self.seats_ then
        for i = 0, SeatMaxId do
            local seat = self.seats_[i]
            if seat then
                seat:stopAllActions()
                delete(seat)
                self.seats_[i] = nil
            end
        end
    end
    if self.m_countDownAnim then
        -- self.m_countDownAnim.removeAnim()
        self.m_countDownAnim = nil
    end
    nk.GCD.Cancel(self)
end

function SeatManager:createNodes()
    --创建座位
    self.seats_ = {}
    for i = 0, SeatMaxId do
        local seat = new(seatView,seatViewScene,seatViewVar,self.ctx,i)
        seat:setDelegate(self, self.onSeatClicked_);
        self.seats_[i] = seat
    end
    --倒计时对象
    self.m_countDownAnim = CountDownAnim --new(CountDownAnim)
end

function SeatManager:onAppEnterBackground_()
    nk.SocketController:userEnterBackground()
    self.roomController.isSuspend = true

    local counterSeatId = self.counterSeatId_
    self:stopCounter()
    self.counterSeatId_ = counterSeatId
end

function SeatManager:onAppEnterForeground_()
    nk.SocketController:tableSYNC()
end

function SeatManager:setHandCardStatus(seatId, status)
    self:getSeatView(seatId):setHandCardTouchStatus(status)
end

function SeatManager:getSeatView(seatId)
    return self.seats_[seatId]
end

function SeatManager:getSelfSeatView()
    return self:getSeatView(self.model:selfSeatId())
end

function SeatManager:getSeatPosition(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return SeatPosition[seat:getPositionId()]
    end
    return nil
end

function SeatManager:getSeatPositionId(seatId, isSelf)
    local seat = self.seats_[seatId]
    if seat then
        local positionId = seat:getPositionId()
        if positionId == 3 and isSelf then
            positionId = 5
        end
        return positionId
    end
    return nil
end

function SeatManager:getEmptySeatId()
    if self.seatIds_ then
        local playerList = self.model.playerList
        for i, seatId in ipairs(self.seatIds_) do
            if not playerList[seatId] then
                return seatId
            end
        end
    end
    return nil
end

function SeatManager:clearHandCardStatus(seatId)
    local seatView = self:getSeatView(seatId)
    if seatView then
        seatView:setPassStatus(false)
        seatView:setHandCardTouchStatus(true)
        seatView:showAllHandCardsElement()
        seatView:stopShakeAllHandCards()
    end
end

function SeatManager:checkMyHandCard(headValue,tailValue)
    local selfSeatView = self:getSelfSeatView()
    if selfSeatView then
        return selfSeatView:checkHandCard(headValue,tailValue)
    else
        return true
    end
end

function SeatManager:showPass(seatId)
    local seatView = self:getSeatView(seatId)
    if seatView then
        seatView:setPassStatus(true)
    end
end

function SeatManager:initSeats(seatsInfo, playerList)
    Log.printInfo("iniaatsiniaatsiniaatsiniaatsiniaatsiniaatsiniaats")
    print("SeatManager:initSeats")
    local model = self.model
    local scene = self.scene
    local seats = self.seats_
    assert(seatsInfo and seatsInfo.seatNum, "seatNum is nil")
    local P = SeatPosition
    local seatIds = SEATS_4
    self.seatIds_ = seatIds

    self.dealCardManager:reset()

    --为了和server同步从0开始
    --初始化有问题，但玩牌的时候没问题
    --客户端【 4     1 】
    --      【 3     2 】

    --服务端【 0     1 】
    --      【 3     2 】

    --修复前客户端初始化为  【 3     0 】
                    -- 【 2     1 】
    for seatId = 0, SeatMaxId do
        local fixSeatId = seatId
        local shouldShow = false
        if seatIds then
            for i, v in ipairs(seatIds) do
                if v == fixSeatId then
                    shouldShow = true
                    break
                end
            end
        end
        local seat = self.seats_[fixSeatId]
        if shouldShow then
            if fixSeatId == 0 then
                fixSeatId = 4
            end
            local posRules = P[fixSeatId]
            seat:setPos(posRules.x, posRules.y) 
            seat:setPositionId(fixSeatId)
            local player
            if fixSeatId == 4 then
                player = playerList[0]
            else
                player = playerList[fixSeatId]
            end
            seat:resetToEmpty()
            seat:setSeatData(player)
            if not seat:getParent() then
                scene.nodes.seatNode:addChild(seat)
            end

            if player and player.userStatus == consts.SVR_USER_STATE.USER_STATE_GAMEING then
                local gameStatus = self.model.gameInfo.gameStatus
                if player.isSelf then                   
                    if player.cardsCount > 0 then
                        seat:setHandCardValue(player.cards)
                        seat:setHandCardNum(player.cardsCount)
                        seat:showHandCardFrontAll()
                        seat:showAllHandCardsElement()
                        seat:showHandCards()
                    else
                        seat:hideHandCards()
                    end
                else
                    if player.cardsCount > 0 then
                        seat:setHandCardValue(player.cards)
                        seat:setHandCardNum(player.cardsCount)
                    else
                        seat:hideHandCards()
                    end

                end
            end
            seat:setVisible(true)
            seat:updateState()
        else
            nk.functions.removeFromParent(seat)
            seat:setVisible(false)
        end
    end
end

function SeatManager:rotateSeatToOrdinal()
    if self.dealCardRotateShowDelayId_ then
        nk.GCD.CancelById(self,self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local seat = self.seats_[2]
    local positionId = seat:getPositionId()
    if positionId ~= (middleSeatId-1) then
        local step = positionId - (middleSeatId-1)
        self:rotateSeatByStep_(step, true, true)
    else
        self:rotateSeatSelf(true, true)
    end
    if self.selfArrowDelayId_ then
        nk.GCD.CancelById(self,self.selfArrowDelayId_)
        self.selfArrowDelayId_ = nil
    end
    if self.arrow_table then
        for i,arrow in ipairs(self.arrow_table) do
            arrow:removeFromParent(true)
        end
    end
end

function SeatManager:rotateSelfSeatToCenter(selfSeatId, animation)
    print("SeatManager:rotateSeatSelf selfSeatId=" .. selfSeatId)
    if self.dealCardRotateShowDelayId_ then
        nk.GCD.CancelById(self,self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local selfSeat = self.seats_[selfSeatId]
    local selfPositionId = selfSeat:getPositionId()
    if selfPositionId ~= middleSeatId then
        local step = selfPositionId - middleSeatId
        self:rotateSeatByStep_(step, animation)
    else
        --自己坐下的位置在左下角，也要转动到自己专属位置，第五个位置
        self:rotateSeatSelf(false, animation)
    end

    --箭头动画
    if animation then
        if not self.arrow_table then
            self.arrow_table = {}
        end
        for i,arrow in ipairs(self.arrow_table) do
            arrow:removeFromParent(true)
        end
        self.selfArrowDelayId_ = nk.GCD.PostDelay(self, function() 
            self.selfArrowDelayId_ = nil
            local p = ccp(0, -50)
            local pt = ccp(p.x, p.y - 25)
            local arrow = new(Image, kImageMap.qiuqiu_self_seat_arrow)
            arrow:setPos(p.x, p.y)
            arrow:addTo(selfSeat)
            arrow:setAlign(kAlignTop)
            arrow:movesTo({time=4, pos_t={p, pt, p, pt, p}, delay=0.8, onComplete=function() 
                    arrow:removeFromParent(true)
                end})
            table.insert(self.arrow_table,arrow)
        end, nil, 800)
    end
end

--从其他位置转动到专属位置
--isOrdinal 是否还原座位
function SeatManager:rotateSeatByStep_(step, animation, isOrdinal)
    if step > middleSeatId - 1 then
        step = step - seatCount
    elseif step < -(middleSeatId -1) then
        step = step + seatCount
    end
    self.dealCardManager:reset()
    local setDealedCardDisplay = function()
        --显示手牌
        for i = 0, SeatMaxId do
            local player = self.model.playerList[i]
            if player and not player.isSelf and player.isPlay == 1 then               
                self.dealCardManager:showDealedCard(player, player.cardsCount)                
            end
        end
    end

    --转动座位
    local capacity = math.abs(step)
    for seatId = 0, SeatMaxId do
        local seat = self.seats_[seatId]
        local seatCurPos = seat:getPositionId()
        if seat then
            local seatPos_ 
            local seatPa = {}
            for i = 1, capacity do
                local idx
                if step > 0 then
                    --逆时针转
                    if seatCurPos - i >= 1 then
                        idx = seatCurPos - i
                    else
                        idx = seatCurPos - i + seatCount
                    end
                else
                    --顺时针转
                    if seatCurPos + i <= seatCount then
                        idx = seatCurPos + i
                    else
                        idx = seatCurPos + i - seatCount
                    end
                end
                if not isOrdinal and idx == middleSeatId then
                    seatPos_ = SeatPosition[#SeatPosition]
                else
                    seatPos_ = SeatPosition[idx]
                end
                table.insert(seatPa, seatPos_)
                if i == capacity then
                    seat:setPositionId(idx)
                    if not seat:getParent() or not animation then
                        seat:setPos(seatPos_.x,seatPos_.y) 
                    end
                end
            end
            if animation then
                if seat:getParent() then
                    seat:stopAllActions()
                    seat:movesTo({time=0.5, pos_t=seatPa, needChange=true})
                    -- Log.dump(seat.seatData_, "satsatsatsatsatsatsatsatsatsatsatds")

                    -- Log.dump(seatCurPos, "seatCurPosseatCurPosseatCurPosseatCurPosseatCurPos")

                    -- Log.dump(seat.seatId_, "seatId_seatId_seatId_seatId_seatId_seatId_")

                    -- Log.dump(seat.positionId_, "positionId_positionId_positionId_positionId_positionId_positionId_")

                    -- Log.dump(seatPa, "seatPatseatPatseatPatseatPatseats")
                end
            end
        end
    end

    if animation then
        --隐藏手牌
        self.dealCardRotateShowDelayId_ = nk.GCD.PostDelay(self, function()
            self.dealCardRotateShowDelayId_ = nil
            setDealedCardDisplay()
        end, nil, 600)
    else
        setDealedCardDisplay()
    end

    --移动dealer位置
    self.animManager:rotateDealer(step)

    --转动灯光
    local lampPositionId = self.lampManager:getPositionId()
    lampPositionId = lampPositionId - step
    if lampPositionId > seatCount then
        lampPositionId = lampPositionId - seatCount
    elseif lampPositionId < 1 then
        lampPositionId = lampPositionId + seatCount
    end
    self.lampManager:turnTo(lampPositionId, true, isOrdinal ~= true)

end

----从左下位置转动到专属位置
--isOrdinal 是否还原
function SeatManager:rotateSeatSelf(isOrdinal, animation)
    --转动座位到自己的专属位置
    if self.dealCardRotateShowDelayId_ then
        nk.GCD.CancelById(self,self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local seat = self.seats_[middleSeatId]
    local seatPa = {}
    local seatPos_
    if isOrdinal then
        seatPos_ = SeatPosition[middleSeatId]
    else
        seatPos_ = SeatPosition[#SeatPosition]
    end
    table.insert(seatPa, seatPos_)
    if seat:getParent() then
        seat:stopAllActions()
        seat:movesTo({time=0.5, pos_t=seatPa, needChange=true})
    end
    
    local setDealedCardDisplay = function()
        --显示手牌
        for i = 0, SeatMaxId do
            local player = self.model.playerList[i]
            if player and not player.isSelf and player.isPlay == 1 then               
                self.dealCardManager:showDealedCard(player, player.cardsCount)                
            end
        end
    end

    --隐藏手牌
    if animation then
        self.dealCardRotateShowDelayId_ = nk.GCD.PostDelay(self, function()
            self.dealCardRotateShowDelayId_ = nil
            setDealedCardDisplay()
        end, nil, 600)
    end

end

function SeatManager:updateAllSeatState()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        print("reset ==> SeatManager:updateAllSeatState")
        seat:setSeatData(self.model.playerList[i])
        seat:updateState()
    end
end

function SeatManager:updateSeatState(seatId,notSetTouch)
    local seat = self.seats_[seatId]
    local seatData = self.model.playerList[seatId]
    print("reset ==> SeatManager:updateSeatState")
    if seat and not nk.updateFunctions.checkIsNull(seat) then
        seat:setSeatData(seatData,notSetTouch)
        seat:updateState()
    end
end

function SeatManager:updateLastCardNum(seatId)
    local seatView = self:getSeatView(seatId)
    if seatView then
        local cardNum = seatView:getHandCardNum()
        seatView:setHandCardNum(cardNum -1)
    end
end

function SeatManager:playSitDownAnimation(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:playSitDownAnimation()
    end
end

function SeatManager:fadeSeat(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:fade()
    end
end

function SeatManager:unFadeSeat(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:unfade()
    end
end

function SeatManager:playStandUpAnimation(seatId, onCompleteCallback)
    local seat = self.seats_[seatId]
    if seat then
        seat:playStandUpAnimation(onCompleteCallback)
    end
end

function SeatManager:updateHeadImage(seatId, imageUrl)
    local seat = self.seats_[seatId]
    if seat then
        if imageUrl then
            seat:updateHeadImage(imageUrl)
        end
    end
end

function SeatManager:updateGiftUrl(seatId, giftId)
    local seat = self.seats_[seatId]
    if seat and giftId then
        seat:updateGiftUrl(giftId)
    end
end

function SeatManager:playSeatWinAnimation(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:playWinAnimation()
    end
end

function SeatManager:stopCounter()
    self.m_countDownAnim.stop()
    if self.counterTimeoutId_ then
        nk.GCD.CancelById(self,self.counterTimeoutId_)
        self.counterTimeoutId_ = nil
    end
    nk.GCD.Cancel(self)
    self.counterSeatId_ = nil
end

function SeatManager:stopCounterOnSeat(seatId)
    self.m_countDownAnim.stop()
    if self.counterTimeoutId_ then
        nk.GCD.CancelById(self,self.counterTimeoutId_)
        self.counterTimeoutId_ = nil
    end
    nk.GCD.Cancel(self)
    self.counterSeatId_ = nil
end

function SeatManager:startCounter(seatId) 
    local gameInfo = self.model.gameInfo
    self:stopCounter()
    local seat = self.seats_[seatId]
    local seatData = seat:getSeatData()
    if seat and seatData then
        self.counterSeatId_ = seatId
        self.seatTimerBetExpire_ = math.max(gameInfo.userAnteTime, 0)
        self.m_countDownAnim.play(seat.image_, self.seatTimerBetExpire_*1000, {img="res/room/gaple/roomG_count_time.png",pos={x=0,y=0},align=kAlignCenter})
        if seatData.isSelf then
            self.counterTimeoutId_ = nk.GCD.PostDelay(self, function() 
                seat:shakeAllHandCards()
            end, nil, self.seatTimerBetExpire_ * 0.75 * 1000, false)
        end
    end
end

function SeatManager:onSeatClicked_(seatId)
    local seat = self.seats_[seatId]
    if seat:isEmpty() then
        if nk.functions.getMoney() < (self.model.roomInfo.minBuyIn or 0) then
            if  nk.userData.bankruptcyGrant and nk.functions.getMoney() < nk.userData.bankruptcyGrant.maxBmoney then
                --[[
                if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                  --  nk.PopupManager:addPopup(BankruptInvitePopup, "roomGaple") 
                    nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_SITDOWN_PAY
                    nk.PopupManager:addPopup(BankruptHelpPopup, "roomGaple")
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
                nk.PopupManager:addPopup(BankruptHelpPopup, "roomGaple")
            else
                if self.model.roomInfo.roomName ~= "" then
                    local args = {
                        hasCloseButton = false,
                        messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
                        firstBtnText = bm.LangUtil.getText("CRASH", "INVITE_FRIEND"), 
                        callback = function (type)
                            if type == nk.Dialog.FIRST_BTN_CLICK then
                                local InviteScene = require("game.invite.inviteScene")
                                nk.PopupManager:addPopup(InviteScene,"roomGaple")
                            end
                        end
                    }
                    nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)
                else
                    local args = {
                        hasCloseButton = false,
                        messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
                        firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
                        secondBtnText = bm.LangUtil.getText("CRASH", "INVITE_FRIEND"), 
                        callback = function (type)
                            if type == nk.Dialog.FIRST_BTN_CLICK then
                                self.scene:playNowChangeRoom()
                            elseif type == nk.Dialog.SECOND_BTN_CLICK then
                                local InviteScene = require("game.invite.inviteScene")
                                nk.PopupManager:addPopup(InviteScene,"roomGaple")
                            end
                        end
                    }
                    nk.PopupManager:addPopup(nk.Dialog,"roomGaple",args)
                end
            end
        else
            self:onBuyin_(seatId)
        end
    elseif seat:getSeatData().isSelf then
        local tableAllUid, toUidArr = self.model:getTableAllUid()
        local tableNum = self.model:getNumInSeat()
        local tableMessage = {tableAllUid = tableAllUid,toUidArr = toUidArr,tableNum = tableNum}
        if not nk.isInSingleRoom then
            nk.AnalyticsManager:report("New_Gaple_selfInfo", "selfInfo")
            -- nk.PopupManager:addPopup(roomUserinfoSelfPopup,"roomGaple",tableMessage,self.ctx.model:roomType(),self.ctx)
            nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"),
                "roomGaple", nil, self.ctx)
        end
    else
        -- nk.PopupManager:addPopup(roomUserinfoOtherPopup,"roomGaple",self.ctx,seat:getSeatData())
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"),
            "roomGaple", seat:getSeatData().userInfo, self.ctx, seat:getSeatData())
    end
end

function SeatManager:onBuyin_(seatId)
    nk.SocketController:seatDown(seatId, 0)    
end


function SeatManager:showHandCard()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        local seatData = seat:getSeatData()       
        if seatData and seatData.isOutCard == 1 then            
            local handCards = seatData.cards           
            if not seatData.isSelf then
                    seat:setHandCardNum(seatData.cardsCount)
                    seat:showHandCardBackAll()
                    seat:showAllHandCardsElement()
                    seat:showHandCards()
                    seat:flipAllHandCards()
                    seat:hidHandCardNum()
            else     
                seat:setHandCardNum(seatData.cardsCount)
                seat:showAllHandCardsElement()
                seat:showHandCardFrontAll()
                seat:showHandCards()
            end            
        end
    end
end

function SeatManager:showHandCardByOther(seatId)   
    local seat = self.seats_[seatId]
    local seatData = seat:getSeatData()
    if seatData and seatData.isOutCard == 1 then
        if not seatData.isSelf then
            self.dealCardManager:moveDealedCardToSeat(seatData, function()
                seat:setHandCardValue(seatData.cards)
                seat:showHandCardBackAll()
                seat:showAllHandCardsElement()
                seat:showHandCards()
                seat:flipAllHandCards()      
            end)
        end
    end
end

function SeatManager:prepareDealCards()
    local selfSeatId = self.model:selfSeatId()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        seat:setSeatData(self.model.playerList[i])
        seat:setHandCardNum(7)
        if i == selfSeatId then
            seat:setHandCardValue(seat:getSeatData().cards)
            seat:showHandCardBackAll()
            seat:hideAllHandCardsElement()
            seat:showHandCards()
        else
            seat:showHandCardBackAll()
            seat:hideHandCards()
        end
    end
end

--播放座位加经验的动画，只播放自己的
function SeatManager:playExpChangeAnimation()
    if self.model:isSelfInSeat() then
        local selfSeatId = self.model:selfSeatId()
        local playerSelf = self.model:selfSeatData()
        if playerSelf and playerSelf.isPlayBeforeGameOver == 1 then
            if playerSelf.getExp > 0 then
                local seat = self.seats_[selfSeatId]
                if seat then
                    seat:playExpChangeAnimation(playerSelf.getExp)
                end
            end
        end
    end
end

-- 获取座位中点Node
function SeatManager:getSeatCenterNode(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return seat.seatCenter_node
    else
        return nil
    end
end

-- 获取座位gift图标中点Node
function SeatManager:getGiftCenterNode(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return seat.giftCenter_node
    else
        return nil
    end
end

-- 获取座位中聊天Node
function SeatManager:getSeatChatNode(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return seat.chatNodeLeft, seat.chatNodeRight
    else
        return nil
    end
end

function SeatManager:reset()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        seat:reset()
    end
    self:stopCounter()
    nk.GCD.Cancel(self)
end


return SeatManager