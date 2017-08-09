--
-- Author: tony
-- Date: 2014-07-08 14:27:55
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
-- 发牌
local DealCardManager = class()

local RoomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")
local P = RoomViewPosition.DealCardPosition
local SP = RoomViewPosition.DealCardStartPosition
local tweenDuration = 0.5

local BIG_CARD_SCALE = 116 * 0.8 / 32

function DealCardManager:ctor()
end

function DealCardManager:dtor()
    nk.GCD.Cancel(self)
    if self.dealCards_ then
        for i = 1, 4 do
            for j = 1, 7 do
                if self.dealCards_[i] and self.dealCards_[i][j] then
                    delete(self.dealCards_[i][j])
                end
            end
        end
        self.dealCards_ = nil
    end
    self.scheduleHandle_ = nil
end

function DealCardManager:createNodes()
    self.cardBatchNode_ = new(Node)
    self.cardBatchNode_:setFillParent(true, true)
    self.scene.nodes.dealCardNode:addChild(self.cardBatchNode_)

    self.pokerHeap1_ = self.scene.nodes.dealCardNode:getChildByName("dealerCardImage1")
    self.pokerHeap2_ = self.scene.nodes.dealCardNode:getChildByName("dealerCardImage2")

    self:playPokerHeapAnim(false)

    self.numNeedCards_ = 0
    self.dealCards_ = {}
    for i = 1, 4 do
        self.dealCards_[i] = {}
        for j = 1, 7 do
            self.dealCards_[i][j] = new(Image, kImageMap.roomG_dealed_hand_card)
            self.dealCards_[i][j].m_signName = i .. "-" .. j
        end
    end 
end

-- 设置扑克堆的可见状态
function DealCardManager:playPokerHeapAnim(visible)
    self.pokerHeap1_:setVisible(visible)
    self.pokerHeap2_:setVisible(visible)
end

--[[
    /*从庄家位置开始发手牌：
        普通场一次性发3张，专业场第一次发2张，第二次再发1张，即第3张
    currentRound：
        1为游戏开始时的第一次；
        2为游戏中途的第二次，仅限专业场   *双联的规则*/

    domimo一次发三张    
]]
function DealCardManager:dealCards()
    self:playPokerHeapAnim(true)
    self:dealCardsWithRound(1,3)
end

-- 给指定玩家发第四张牌。发第四张的时候如果self.scheduleHandle_存在，证明前三张没发完，立刻发完前面三张
function DealCardManager:dealCardToPlayer(seatId)
    self.currentDealSeatId_ = seatId

    if self.scheduleHandle_ then
        nk.GCD.CancelById(self,self.scheduleHandle_)
        -- self.scheduleHandle_ = nil      --不能设为nil，否则只能跑一次
        self:playPokerHeapAnim(false)

        for i = 1,3 do
            self.startDealIndex_ = i
            self:dealCard_(self.seatManager:getSeatPositionId(seatId),true)
        end
    end

    self.startDealIndex_  = 4
    self.dealCardsNum_ = 1
    self:dealCard_(self.seatManager:getSeatPositionId(seatId))

    -- local playerList = self.model.playerList  
    -- for i = 0, 6 do
    --     local player = playerList[i]
    --     if player and tonumber(player.uid) ~= tonumber(nk.userData.uid) and player.seatId and player.seatId == seatId then
    --         nk.GCD.PostDelay(self, function()
    --             self:showDealedCard(player,4)
    --         end, nil, tweenDuration*1000)
    --     end
    -- end

end

-- roundStartIndex指定开始轮次，roundEndIndex指定结束轮次
function DealCardManager:dealCardsWithRound(startDealIndex, endDealIndex)
    if not self.dealCards_ then
        return self
    end
    self.currentDealSeatId_ = -1  -- 初始发牌座位id
    self.numInGamePlayers_  = 0   -- 在玩玩家数量
    self.numNeedCards_      = 0   -- 需要发牌的数量
    self.numDealedCards_    = 0   -- 已经发牌的数量
    self.dealSeatIdList_    = nil -- 需要发牌的座位id列表
    self.dealCardsNum_ = endDealIndex - startDealIndex + 1

    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList    

    -- domino发牌起始位置是庄家位置
    self.currentDealSeatId_ = gameInfo.dealerSeatId

    -- 计算当前在玩人数
    self.dealSeatIdList_ = {}
    local index = 1
    for i = 0, 6 do
        local player = playerList[i]
        if player and player.isPlay == 1 then
            self.dealSeatIdList_[index] = i
            if i == self.currentDealSeatId_ then
                self.tempIndex_ = index
            end
            index = index + 1
            self.numInGamePlayers_ = self.numInGamePlayers_ + 1
        end
    end
    self.numNeedCards_ = self.numInGamePlayers_ * (endDealIndex - startDealIndex + 1) -- 计算本次需要发多少张牌

    -- 发牌定时器
    if self.currentDealSeatId_ >= 0 and self.currentDealSeatId_ <= 6 then
        self.startDealIndex_ = startDealIndex -- 开始发第几张牌
        if self.scheduleHandle_ then
            nk.GCD.CancelById(self,self.scheduleHandle_)
            self.scheduleHandle_ = nil
        end
        --友盟上面有tempIndex_为空的情况，即找不到庄家位置，做容错
        if not self.tempIndex_ then
            self.tempIndex_ = 1
        end

        self.scheduleHandle_ =  nk.GCD.PostDelay(self, function()
            self:scheduleHandler()
        end, nil, 100, true)
    end

    return self
end

-- 间隔发每一张牌
function DealCardManager:scheduleHandler()
    self:dealCard_(self.seatManager:getSeatPositionId(self.currentDealSeatId_))

    -- 找到下一个需要发牌的座位id
    self.currentDealSeatId_ = self:findNextDealSeatId_()

    -- 已发牌总数加1
    self.numDealedCards_ = self.numDealedCards_ + 1
    if self.numDealedCards_ == self.numInGamePlayers_ or self.numDealedCards_ == self.numInGamePlayers_ * 2 then
        self.startDealIndex_ = self.startDealIndex_ + 1
    end

    -- 需发牌总数减1，发牌总数为0则已发完，结束发牌
    self.numNeedCards_ = self.numNeedCards_ - 1
    if self.numNeedCards_ == 0 then
        nk.GCD.CancelById(self,self.scheduleHandle_)
        self.scheduleHandle_ = nil
        self:playPokerHeapAnim(false)
    end
end

-- 发牌动画流程处理
function DealCardManager:dealCard_(positionId,immediately)
    immediately = immediately or false

    local dealingcard = nil
    if self.dealCards_[self.startDealIndex_] and self.dealCards_[self.startDealIndex_][positionId] then
        dealingcard = self.dealCards_[self.startDealIndex_][positionId]
    end

    if not dealingcard then return end

    if dealingcard:getParent() then
        dealingcard:removeFromParent()
    end

    Log.dump(self.ctx.model.gameInfo.dealerSeatId,"self.ctx.model.gameInfo.dealerSeatId")
    local dealerSeatId = -1
    if self.ctx.model.gameInfo.dealerSeatId and self.ctx.model.gameInfo.dealerSeatId >= 0 then
        dealerSeatId = self.ctx.model.gameInfo.dealerSeatId
    end
    local startPosId = 8
    if dealerSeatId ~= -1 then
        startPosId = self.seatManager:getSeatPositionId(dealerSeatId)
    end
    dealingcard:addTo(self.cardBatchNode_)
    dealingcard:setPos(SP[startPosId].x, SP[startPosId].y)

    local targetX
    local targetR
    if self.startDealIndex_ == 1 then
        targetX = P[positionId].x - 8
        targetR = -12
    elseif self.startDealIndex_ == 2 then
        targetX = P[positionId].x
        targetR = 0
    elseif self.startDealIndex_ == 3 then
        targetX = P[positionId].x + 8
        targetR = 12
    else
        targetX = P[positionId].x + 16
        targetR = 24
    end
    local cardIndex = self.startDealIndex_
    local cardNum = self.dealCardsNum_
    local seatView = self.seatManager:getSeatView(self.currentDealSeatId_)
    local seatData = seatView:getSeatData()

    --发牌给自己
    if self.model:isSelfInSeat() and positionId == 4 then
        if cardNum == 3 then
            if self.startDealIndex_ == 1 then
                targetX = P[positionId].x
            elseif self.startDealIndex_ == 2 then
                targetX = P[positionId].x + 59
            elseif self.startDealIndex_ == 3 then
                targetX = P[positionId].x + 118
            end
        else
            if self.startDealIndex_ == 1 then
                targetX = P[positionId].x
            elseif self.startDealIndex_ == 2 then
                targetX = P[positionId].x + 59
            elseif self.startDealIndex_ == 3 then
                targetX = P[positionId].x + 118
            elseif self.startDealIndex_ == 4 then
                targetX = P[positionId].x + 177
            end
        end


        if not immediately then 
            --四张牌的时候，发完牌才setHandCardValue(三张牌一开始就set了)，tweenDuration时间内要禁止切牌
            nk.SoundManager:playSound(nk.SoundManager.DEAL_CARD)
            seatView:disableCardsTouch()

            transition.moveTo(dealingcard, {time = tweenDuration, x = targetX, y = P[positionId].y, onComplete=handler(self, function()
                if self.model:isSelfInSeat() then
                    --自己的座位发完牌就可以移除，用手牌
                    if dealingcard:getParent() then
                        dealingcard:removeFromParent()
                    end
                    if cardIndex == cardNum and cardNum == 3 then   
                        seatView:setHandCardNum(3)                 
                        seatView:showHandCardsElement(cardIndex)
                        seatView:flipAllHandCards()
                        nk.GCD.PostDelay(self, function()
                            --避免发牌过程中弃牌，结果又恢复可点击切牌
                            if not tolua.isnull(seatView) then
                                if self.model:isSelfInGame() then
                                	seatView:showCardTypeIf(consts.CARD_TYPE_QIUQIU.SPECIAL_NONE)
                                	seatView:enableCardsTouch()
                                else
                                    seatView:disableCardsTouch()
                                    seatView:setCardPointBoardDard()
                                end
                            end
                        end, nil, 800)
                    elseif cardIndex == 4 and cardNum == 1 then                    
                        seatView:setHandCardNum(4)
                        seatView:setHandCardValue(seatData.cards)
                        seatView:showHandCardsElement(cardIndex)
                        seatView:flipHandCardsElement(cardIndex)

                        --四张牌由服务器决定牌型，在RoomController:SVR_RECEIVE_FOURTH_CARD
                        nk.GCD.PostDelay(self, function()
                            --避免发牌过程中弃牌，结束又恢复可点击切牌
                            if self.model:isSelfInGame() and not tolua.isnull(seatView) then
                                seatView:enableCardsTouch()
                            end
                        end, nil, 800)
                    else
                        seatView:showHandCardsElement(cardIndex)
                    end
                elseif not seatView:getSeatData() then
                    if dealingcard:getParent() then
                        dealingcard:removeFromParent()
                    end
                end
            end)})
            transition.scaleTo(dealingcard, {scaleX=BIG_CARD_SCALE, scaleY=BIG_CARD_SCALE, time=tweenDuration, needChange = false})
            transition.rotateTo(dealingcard, {time = tweenDuration, rotate = targetR})
    
        else
            if dealingcard:getParent() then
                dealingcard:removeFromParent()
            end
            seatView:setHandCardNum(3)
            seatView:showHandCardsElement(cardIndex)
            seatView:flipHandCardsElement(cardIndex)
        end
    else
        if not immediately then 
            nk.SoundManager:playSound(nk.SoundManager.DEAL_CARD)
            transition.moveTo(dealingcard, {time=tweenDuration, x=targetX, y=P[positionId].y, onComplete=handler(self, function()
                    if not seatData and dealingcard:getParent() then
                        dealingcard:removeFromParent()
                    else
                        if (cardIndex == cardNum and cardNum == 3) or  (cardIndex == 3 and cardNum == 1) then                    
                            if seatData then
                                self.seatManager:showHandCardByOther(seatData.seatId)
                            end
                        end
                    end
                end)})
            transition.rotateTo(dealingcard, {time = tweenDuration, rotate = targetR})
        else
            dealingcard:setPos(targetX, P[positionId].y)
            dealingcard:rotateTo({time = 0,rotate = targetR})
        end
    end
    
end

function DealCardManager:findNextDealSeatId_()
    self.tempIndex_ = self.tempIndex_ + 1
    if self.tempIndex_ > #self.dealSeatIdList_ then
        self.tempIndex_ = 1
    end
    return self.dealSeatIdList_[self.tempIndex_]
end

-- 玩家弃牌
function DealCardManager:foldCard(player)
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    for i = 1, 4 do
        local foldingCard = self.dealCards_[i][positionId]
        if foldingCard:getParent() then
            foldingCard:moveTo({time=tweenDuration, x=P[10].x, y=P[10].y, onComplete=handler(self, function()
                    foldingCard:removeFromParent()
                end)})
        end
    end
end

-- 显示指定位置id的发牌sprite(其他人的手牌牌背)
function DealCardManager:showDealedCard(player, cardNum)
    if cardNum == nil or cardNum == 0 then
        return self
    end

    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    for i = 1, cardNum do
        local deadCard = self.dealCards_[i][positionId]
        if deadCard:getParent() then
            deadCard:removeFromParent()
            deadCard:removeAllProp()
        end
        if i <= cardNum then
            deadCard:addTo(self.cardBatchNode_)
            deadCard:setPos(P[positionId].x + i * 8 - 16, P[positionId].y)
            deadCard:rotateTo({time = tweenDuration, rotate = (i * 12 - 24)})
        end
    end
end

-- 隐藏所有的发牌sprite
function DealCardManager:hideAllDealedCard()
    for i = 1, 4 do
        for j = 1, 7 do
            if self.dealCards_[i] and self.dealCards_[i][j] then
                self.dealCards_[i][j]:setVisible(false)
                self.dealCards_[i][j]:removeFromParent()
            end
        end
    end
end

-- 隐藏指定位置id的发牌sprite
function DealCardManager:hideDealedCard(positionId)
    for i = 1, 4 do
        local deadCard = self.dealCards_[i][positionId]
        if deadCard and deadCard:getParent() then
            deadCard:removeFromParent()
        end
    end
end

function DealCardManager:ThrowDeadCard(positionId)
    local targetPos = RoomViewPosition.DealerPosition[8]
    
    --如果不是自己，才需要丢牌的动画；是自己(在玩一定是4号位)，加黑牌就行(而且这样发牌动画中弃牌，发牌动画还可以跑)
    if positionId == 4 and self.model:isSelfInSeat() then  
        
    else
        for i = 1, 4 do
            local deadCard = self.dealCards_[i][positionId]
            if deadCard and deadCard:getParent() then
                deadCard:removeAllProp()
                transition.moveTo(deadCard, {
                    time = tweenDuration + 0.1 * i, 
                    x = targetPos.x,
                    y = targetPos.y,
                    onComplete=handler(self, function ()
                        deadCard:removeFromParent()
                    end
                )})
            end
        end
    end
end

-- 手牌牌背移动至座位旁边
function DealCardManager:moveDealedCardToSeat(player, callback)
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    local destPosition = self.seatManager:getSeatPosition(player.seatId)
    if destPosition then
        for i = 1, 4 do
            local deadCard = self.dealCards_[i][positionId]
            if deadCard and deadCard:getParent() then
                local yoffset = - (2-i) * 15
                if positionId > 4 then
                    yoffset = -yoffset
                end
	            transition.moveTo(deadCard, {
	                time = tweenDuration, 
	                x = destPosition.x + i * 8 + 70, 
	                y = destPosition.y + 85 + yoffset,
	                onComplete=handler(self, function ()
	                    deadCard:removeFromParent()
	                    if i == 1 and callback then
	                        callback()
	                    end
	                end
	            )})
            else
                if i == 1 and callback then
                    callback()
                end
            end
        end
    end
end

-- 重置位置与角度
function DealCardManager:reset()
    if self.dealCards_ then
        for i = 1, 4 do
            for j = 1, 7 do
                self.dealCards_[i][j]:removeFromParent()
                self.dealCards_[i][j]:removeAllProp()
            end
        end
    end
    nk.GCD.Cancel(self)
    self.scheduleHandle_ = nil
    return self
end

return DealCardManager