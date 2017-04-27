--
-- Author: tony
-- Date: 2014-07-08 12:45:14
--
local SeatManager = class()

local SeatView = import("game.roomQiuQiu.layers.seatView")
local CardModeConfirm = require("game.roomQiuQiu.layers.cardModeConfirm")
local RoomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")
local BankruptHelpPopup = require("game.bankrupt.bankruptHelpPopup")
-- local UserInfoOtherDialog = import("app.module.room.UserInfoOtherDialog")
-- local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
-- local roomUserinfoSelfPopup = import("game.userInfo.roomUserinfo.roomUserinfoSelfPopup")
-- local roomUserinfoOtherPopup = import("game.userInfo.roomUserinfo.roomUserinfoOtherPopup")
local CountDownAnim = require("game.anim.countDownAnim")
local SeatPosition = RoomViewPosition.SeatPosition
local seatCount = 7
local SeatMaxId = 6
local middleSeatId = 4

local SEATS_7 = {0, 1, 2, 3, 4, 5, 6}
local SEATS_5 = {0, 1, 2 ,3, 4}

local USE_COUNTER_POOL = false

function SeatManager:ctor(ctx)
    
end

function SeatManager:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.seatViewClicked, self, self.onSeatClicked_);
    EventDispatcher.getInstance():unregister(Event.Pause, self, self.onAppEnterBackground_)
    EventDispatcher.getInstance():unregister(Event.Resume, self, self.onAppEnterForeground_)
    if self.seats_ then
        for i = 0, SeatMaxId do
            local seat = self.seats_[i]
            if seat then
                seat:stopAllActions()
                delete(self.seats_[i])
                self.seats_[i] = nil
            end
        end
    end
    nk.GCD.Cancel(self)
    if self.m_countDownAnim then
        -- self.m_countDownAnim.removeAnim()
        self.m_countDownAnim = nil
    end
end

function SeatManager:createNodes()
    --创建座位
    self.seats_ = {}
    for i = 0, SeatMaxId do
        local seat = new(SeatView, self.ctx, i) -- seatId 0 ~ 6
        self.seats_[i] = seat
    end

    -- 提示可切换牌型的tips
    self.tipsIcon_ = new(Image, kImageMap.change_card_mode)
    self.tipsIcon_:setAlign(kAlignCenter)
    self.tipsIcon_:setPos(10, 220)
    self.tipsIcon_:addTo(self.scene.nodes.popupNode)
    self.tipsLabel_ = new(Text, T("点击安排顺序"), 180, nil, kAlignLeft, nil, 20, 150, 180, 205)
    local ax, ay = self.tipsIcon_:getAbsolutePos()
    self.tipsLabel_:setPos(15, 0)
    self.tipsLabel_:setAlign(kAlignLeft)
    self.tipsLabel_:addTo(self.tipsIcon_)
    self:setTipsVisible_(false)
    
    -- 牌型确认倒计时
    local confirmNode = self.scene.nodes.popupNode:getChildByName("confirmNode")
    self._cardModeConfirm = new(CardModeConfirm, confirmNode)
    self._cardModeConfirm:hide()
    --倒计时对象
    self.m_countDownAnim = CountDownAnim --new(CountDownAnim)
    EventDispatcher.getInstance():register(Event.Pause, self, self.onAppEnterBackground_)
    EventDispatcher.getInstance():register(Event.Resume, self, self.onAppEnterForeground_)
    EventDispatcher.getInstance():register(EventConstants.seatViewClicked, self, self.onSeatClicked_);
end

function SeatManager:setTipsVisible_(visible)
    if visible then
        self.tipsIcon_:setVisible(true)
        self.tipsLabel_:setVisible(true)
    else
        self.tipsIcon_:setVisible(false)
        self.tipsLabel_:setVisible(false)
    end
end

function SeatManager:cardPointBoardTipSet(evt)
    self:setTipsVisible_(evt.data)
end

function SeatManager:onAppEnterBackground_()
    nk.SocketController:userEnterBackground()
    self.roomController.isSuspend = true
    
    local counterSeatId = self.counterSeatId_
    self:stopCounter()
    self.counterSeatId_ = counterSeatId
end

function SeatManager:onAppEnterForeground_()
    nk.SocketController:tableSYNCQIUQIU()
end

function SeatManager:getCardModeConfirm(time,confirmCallback)
    time = time <= 9 and time or 9    --资源图只到9秒
    self._cardModeConfirm:startTime(time,function()
        confirmCallback()
    end , function()
        local seatView = self:getSelfSeatView()
        if seatView then 
            seatView:disableCardsTouch()
            seatView:showConfirmCardsIcon(true)
        end
    end
    )
    self._cardModeConfirm:show()
end

function SeatManager:HideSomething()
    self._cardModeConfirm:reset()
end

function SeatManager:forceShowComfirmIconInPlay()
    --收到结算包，就把所有在玩的玩家强制确认牌型完成
    local gameStatus = self.model.gameInfo.gameStatus
    if gameStatus == consts.SVR_GAME_STATUS.TABLE_CHECK then
        for i = 0, SeatMaxId do
            local player = self.model.playerList[i]
            if player and player.isPlay == 1 then
                self:ShowConfirmIconBySeatId(player.seatId)
            end
        end
    end
end

--finish
function SeatManager:ShowConfirmIconBySeatId(seatId)
    self.seats_[seatId]:showConfirmCardsIcon(self.model:selfSeatId() == seatId)
end

--waitting
function SeatManager:ShowConfirmWaitingIcon(seatId)
    self.seats_[seatId]:showConfirmCardsIcon2(self.model:selfSeatId() == seatId)
end

function SeatManager:HideAllConfirmIcon()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        if seat then
            seat:hideConfirmCardsIcon()
        end
    end
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

function SeatManager:getSeatPositionId(seatId)
    local seat = self.seats_[seatId]
    if not tolua.isnull(seat) then
        return seat:getPositionId()
    end
    return nil
end

function SeatManager:getEmptySeatId()
    if self.seatIds_ then
        local playerList = self.model.playerList or {}
        for i, seatId in ipairs(self.seatIds_) do
            if not playerList[seatId] then
                return seatId
            end
        end
    end
    return nil
end

function SeatManager:initSeats(seatsInfo, playerList)
    local model = self.model
    local scene = self.scene
    local seats = self.seats_
    assert(seatsInfo and seatsInfo.seatNum, "seatNum is nil")
    local P = SeatPosition
    local seatIds = nil
    if seatsInfo.seatNum == 7 then
        seatIds = SEATS_7
    elseif seatsInfo.seatNum == 5 then
        seatIds = SEATS_5
    end
    self.seatIds_ = seatIds

    self.dealCardManager:reset()
    for seatId = 0, SeatMaxId do
        local shouldShow = false
        if seatIds then
            for i, v in ipairs(seatIds) do
                if v == seatId then
                    shouldShow = true
                    break
                end
            end
        end
        local seat = self.seats_[seatId]
        if shouldShow then
            local pos = P[seatId + 1]
            seat:setPos(pos.x, pos.y)
            seat:setPositionId(seatId + 1)
            local player = playerList[seatId]
            seat:resetToEmpty()
            seat:setSeatData(player)
            if not seat:getParent() then
                seat:addTo(scene.nodes.seatNode, seatId + 1, seatId + 1)
            end

            if player then
                local gameStatus = self.model.gameInfo.gameStatus
                if player.isSelf then                   
                    if player.cardsCount > 0 then
                        seat:setHandCardValue(player.cards)
                        seat:setHandCardNum(player.cardsCount)
                        seat:showHandCardFrontAll()
                        seat:showAllHandCardsElement()
                        seat:showHandCards()
                        seat:showCardTypeIf(player.specialCardsType)
                        if gameStatus==consts.SVR_GAME_STATUS_QIUQIU.TABLE_BET_ROUND or gameStatus==consts.SVR_GAME_STATUS_QIUQIU.TABLE_BET_ROUND_4card or gameStatus==consts.SVR_GAME_STATUS_QIUQIU.TABLE_CHECK then
                            self:setTipsVisible_(true)
                        else
                            self:setTipsVisible_(false)
                        end
                        
                    else
                        seat:hideHandCards()
                    end
                else
                    if player.cardsCount and player.cardsCount > 0 then
                        self.dealCardManager:showDealedCard(player, player.cardsCount)
                    end
                end
            end
            seat:updateState()
        else
            seat:removeFromParent()
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
        self:rotateSeatByStep_(step, true)
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
    if self.dealCardRotateShowDelayId_ then
        nk.GCD.CancelById(self,self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local selfSeat = self.seats_[selfSeatId]
    local selfPositionId = selfSeat:getPositionId()
    if selfPositionId ~= middleSeatId then
        local step = selfPositionId - middleSeatId
        self:rotateSeatByStep_(step, animation)
    end
    if not self.arrow_table then
        self.arrow_table = {}
    end
    for i,arrow in ipairs(self.arrow_table) do
        arrow:removeFromParent(true)
    end
    if animation then
        self.selfArrowDelayId_ = nk.GCD.PostDelay(self, function() 
            self.selfArrowDelayId_ = nil
            local p = ccp(0, -30)
            local pt = ccp(p.x, p.y - 25)
            local arrow = new(Image, kImageMap.qiuqiu_self_seat_arrow)
            arrow:setPos(p.x, p.y)
            arrow:addTo(selfSeat)
            arrow:setAlign(kAlignTop)
            arrow:movesTo({time=4, pos_t={p, pt, p, pt, p}, delay=0.8, onComplete=function() 
                    arrow:removeFromParent(true)
                    EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_HIDE_SIT_HERE)
                end})
            table.insert(self.arrow_table,arrow)
            local namePosx, namePosy = selfSeat:getPos()
            local startPos = {namePosx + 150 ,namePosy + 50}
            local endPos = {namePosx + 90 ,namePosy + 50}
            EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_SHOW_SIT_HERE, {startPos = startPos,endPos = endPos})
        end, nil, 800)
    end
end

function SeatManager:rotateSeatByStep_(step, animation)
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
            local seatPa = {}
            -- local seatx, seaty = seat:getPos()
            -- table.insert(seatPa, {x=seatx,y=seaty})
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
                table.insert(seatPa, SeatPosition[idx])
                if i == capacity then
                    seat:setPositionId(idx)
                    if not seat:getParent() or not animation then
                        seat:setPos(SeatPosition[idx].x, SeatPosition[idx].y)
                    end
                end
            end
            if animation then
                if seat:getParent() then
                    seat:stopAllActions()
                    seat:movesTo({time=0.5, pos_t=seatPa})
                end
            end
        end
    end

    if animation then
        --隐藏手牌
        self.dealCardRotateShowDelayId_ = nk.GCD.PostDelay(self, function() 
            self.dealCardRotateShowDelayId_ = nil
            setDealedCardDisplay()
        end, nil, 600, false)
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
    self.lampManager:turnTo(lampPositionId, true)

end

function SeatManager:updateAllSeatState()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        seat:setSeatData(self.model.playerList[i])
        seat:updateState()
    end
end

function SeatManager:updateSeatState(seatId)
    local seat = self.seats_[seatId]
    local seatData = self.model.playerList[seatId]
    if seat and not nk.updateFunctions.checkIsNull(seat) then
        seat:setSeatData(seatData)
        seat:updateState()
    end
end

function SeatManager:initFBInviteSeat()
    local seat = self.seats_[self.model:getRoomInvite()]
    if seat then
        seat:initFBInvite()
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
    if self.dealerTapTableTimeoutId_ then
        nk.GCD.CancelById(self,self.dealerTapTableTimeoutId_)
        self.dealerTapTableTimeoutId_ = nil
    end
    self.counterSeatId_ = nil
end

function SeatManager:stopCounterOnSeat(seatId)
    self.m_countDownAnim.stop()
    if self.counterTimeoutId_ then
        nk.GCD.CancelById(self,self.counterTimeoutId_)
        self.counterTimeoutId_ = nil
    end
    if self.dealerTapTableTimeoutId_ then
        nk.GCD.CancelById(self,self.dealerTapTableTimeoutId_)
        self.dealerTapTableTimeoutId_ = nil
    end
    self.counterSeatId_ = nil
end

function SeatManager:startCounter(seatId) 
    local gameInfo = self.model.gameInfo
    self:stopCounter()
    local seat = self.seats_[seatId]
    local seatData = seat:getSeatData()
    if seat and seatData then
        self.counterSeatId_ = seatId
        -- FwLog(">>>>>>>>>>>>>>>>>>>> gameInfo.userAnteTime = " .. gameInfo.userAnteTime)
        self.seatTimerBetExpire_ = math.max(gameInfo.userAnteTime, 0)
        self.m_countDownAnim.play(seat.m_imageNode, self.seatTimerBetExpire_*1000, {img=kImageMap.qiuqiu_count_time, align=kAlignCenter}, seatData.isSelf, seat:getPos())
        if seatData.isSelf then
            self.counterTimeoutId_ = nk.GCD.PostDelay(self, function() 
                seat:shakeAllHandCards()
            end, 
            nil, self.seatTimerBetExpire_ * 0.75 * 1000, false)
        end

        -- 荷官敲桌子
        self.dealerTapTableTimeoutId_ = nk.GCD.PostDelay(self, function() 
            self.dealerTapTableTimeoutId_ = nil
            if self.dealerManager and self.dealerManager.tapTable then
                self.dealerManager:tapTable()
            end
        end, nil, self.seatTimerBetExpire_ * 0.5 * 1000, false)
    end
end

function SeatManager:onSeatClicked_(evt)
    local seat = self.seats_[evt.seatId]
    if seat:isEmpty() then
        local forInvite = evt.forInvite
        if forInvite then
            if seat then
                seat:onClickInviteFriend()
                return
            end
        end
    end

    if seat:isEmpty() then
        local roomData = nk.functions.getRoomQiuQiuDataByLevel(self.model.roomInfo.roomType)
        if not roomData then
            return
        end
        
        if nk.functions.getMoney() > roomData.maxEnter and roomData.maxEnter ~= 0 then
            self:overRoomMaxEnter(roomData.maxEnter)
        elseif nk.functions.getMoney() < self.model.roomInfo.minBuyIn then
            if nk.userData.bankruptcyGrant and (nk.functions.getMoney() < nk.userData.bankruptcyGrant.maxBmoney) then
                --[[
                if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                    nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_SITDOWN_PAY
                    nk.PopupManager:addPopup(BankruptHelpPopup, "roomQiuQiu")
                else
                    local args = {
                        hasCloseButton = false,
                        messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", nk.userData.bankruptcyGrant.maxBmoney), 
                        firstBtnText = bm.LangUtil.getText("COMMON", "TO_SHOP"),
                        secondBtnText = bm.LangUtil.getText("LOGINREWARD","INVITE_FRIEND"), 
                        callback = function (type)
                            if type == nk.Dialog.FIRST_BTN_CLICK then
                                local StorePopup = require("game.store.popup.storePopup")
                                local level = self.model:roomType()
                                nk.PopupManager:addPopup(StorePopup,"roomQiuQiu",true,level)
                            elseif type == nk.Dialog.SECOND_BTN_CLICK then
                                nk.AnalyticsManager:report("EC_H_Gold_Shortage_Invite","invite")
                                local InviteScene = require("game.invite.inviteScene")
                                nk.PopupManager:addPopup(InviteScene,"roomQiuQiu")
                            end
                        end
                    }
                    nk.PopupManager:addPopup(nk.Dialog,"roomQiuQiu",args)
                end
                --]]
                nk.PopupManager:addPopup(BankruptHelpPopup, "roomQiuQiu")
            else
                local args = {
                    hasCloseButton = false,
                    messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
                    firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
                    secondBtnText = bm.LangUtil.getText("CRASH", "INVITE_FRIEND"), 
                    callback = function (type)
                        if type == nk.Dialog.FIRST_BTN_CLICK then
                            self.roomController:onChangeRoom(true)
                        elseif type == nk.Dialog.SECOND_BTN_CLICK then
                            nk.AnalyticsManager:report("EC_H_Gold_Shortage_Invite","invite")
                            local InviteScene = require("game.invite.inviteScene")
                            nk.PopupManager:addPopup(InviteScene,"roomQiuQiu")
                        end
                    end
                }
                nk.PopupManager:addPopup(nk.Dialog,"roomQiuQiu",args)
            end
        else
            local BuyInPopup = require("game.roomQiuQiu.layers.buyInPopup")
            local data = {
                    minBuyIn = self.model.roomInfo.minBuyIn,
                    maxBuyIn = self.model.roomInfo.maxBuyIn,
                    defaultBuyIn = self.model.roomInfo.defaultBuyIn,
                    isAutoBuyin = nk.DictModule:getBoolean("gameData", nk.cookieKeys.AUTO_BUY_IN, true),
                    callback = function(buyinChips, isAutoBuyin1)
                        self:onBuyin_(evt.seatId, buyinChips, isAutoBuyin1)
                    end
                }
            nk.PopupManager:addPopup(BuyInPopup,"roomQiuQiu",data)
        end
    elseif seat:getSeatData().isSelf then
        local tableAllUid, toUidArr = self.model:getTableAllUid()
        local tableNum = self.model:getNumInSeat()
        local tableMessage = {tableAllUid = tableAllUid,toUidArr = toUidArr,tableNum = tableNum}
        -- nk.PopupManager:addPopup(roomUserinfoSelfPopup,"roomQiuQiu",tableMessage,self.ctx.model:roomType(),self.ctx)
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"),
                "roomGaple", nil, self.ctx) -- self.ctx.model:roomType(), 
    else
        -- nk.PopupManager:addPopup(roomUserinfoOtherPopup,"roomQiuQiu",self.ctx,seat:getSeatData())
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"),
            "roomGaple", seat:getSeatData().userInfo, self.ctx, seat:getSeatData())
    end
end
function SeatManager:overRoomMaxEnter(limit)
    local args = {
        hasCloseButton = false,
        messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_OVER_MAX_MONEY",nk.updateFunctions.formatBigNumber(limit)), 
        firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
        secondBtnText = bm.LangUtil.getText("ROOM", "I_KNOW_ED"), 
        callback = function (type)
            if type == nk.Dialog.FIRST_BTN_CLICK then
                self.roomController:onChangeRoom(true)
            end
        end
    }
    nk.PopupManager:addPopup(nk.Dialog,"roomQiuQiu",args)
end
function SeatManager:onBuyin_(seatId, buyinChips, isAutoBuyin)
    nk.SocketController:seatDownQiuQiu(seatId, buyinChips, isAutoBuyin, false)    
end


function SeatManager:showHandCard()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        local seatData = seat:getSeatData()       
        if seatData and seatData.isOutCard == 1 then            
            local handCards = seatData.cards           
            if not seatData.isSelf then
                self.dealCardManager:moveDealedCardToSeat(seatData, function()
                    print("seat " .. seat.seatId_ .. " showHandCard")
                    if seat:getSeatData() == seatData then
                        seat:setHandCardNum(seatData.cardsCount)
                        seat:setHandCardValue(handCards)
                        seat:showHandCardBackAll()
                        seat:showAllHandCardsElement()
                        seat:showHandCards()
                        seat:flipAllHandCards()
                        nk.GCD.PostDelay(self, function() 
                            if seat:getSeatData() == seatData then
                                seat:showCardTypeIf(seatData.specialCardsType)
                            end
                        end, nil, 800, false)
                    elseif seat:getSeatData() == nil then
                        print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to nil")
                    else
                        print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to " .. seat:getSeatData().uid)
                    end
                end)
            else     
                seat:setHandCardNum(seatData.cardsCount)
                seat:setHandCardValue(handCards)
                seat:showAllHandCardsElement()
                seat:showHandCardFrontAll()
                seat:showHandCards()
                seat:showCardTypeIf(seatData.specialCardsType)
            end            
        end
    end
end

function SeatManager:showHandCardByOther(seatId)   
    local seat = self.seats_[seatId]
    assert(seat, "when seatId is " .. (seatId or "nil") .. " seat is nil and self.seats_ len = " .. #self.seats_)
    local seatData = seat:getSeatData()

    if seatData and seatData.isOutCard == 1 and (#seatData.cards > 0) then
        if not seatData.isSelf then
            self.dealCardManager:moveDealedCardToSeat(seatData, function()
                seat:setHandCardNum(#seatData.cards)
                seat:setHandCardValue(seatData.cards)
                seat:showHandCardBackAll()
                seat:showAllHandCardsElement()
                seat:showHandCards()
                seat:flipAllHandCards()
                nk.GCD.PostDelay(self, function() 
                    if seat:getSeatData() == seatData then
                        seat:showCardTypeIf(seatData.specialCardsType)
                    end
                end, nil, 800, false)     
            end)
        end
    end
end

function SeatManager:prepareDealCards()
    local selfSeatId = self.model:selfSeatId()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        local seatData = self.model.playerList[i]
        seat:setSeatData(seatData)

        seat:setHandCardNum(4)
        if i == selfSeatId and seatData and seatData.isPlay == 1 then
            seat:setHandCardValue(seatData.cards)
            seat:showHandCardBackAll()
            seat:hideAllHandCardsElement()
            seat:showHandCards()
        else
            seat:showHandCardBackAll()
            seat:hideHandCards()
        end
    end
end

-- 获取座位中点Node
function SeatManager:getSeatCenterNode(seatId)
    local seat = self.seats_[seatId]
    return seat and  seat.seatCenter_node or nil
end

-- 获取座位gift图标中点Node
function SeatManager:getGiftCenterNode(seatId)
    local seat = self.seats_[seatId]
    return seat and seat.giftCenter_node or nil
end

-- 获取座位中聊天Node
function SeatManager:getSeatChatNode(seatId)
    local seat = self.seats_[seatId]
    return seat and  seat.chatNodeLeft or nil, seat and seat.chatNodeRight or nil
end

-- 获取小牌堆节点
function SeatManager:getSmallPokerNode(seatId)
    local seat = self.seats_[seatId]
    return seat and  seat.small_poker_node or nil
end

function SeatManager:reset()
    for i = 0, SeatMaxId do
        local seat = self.seats_[i]
        if seat then
            seat:reset()
        end
    end
    self:stopCounter()
    self:setTipsVisible_(false)
    nk.GCD.Cancel(self)
end

return SeatManager