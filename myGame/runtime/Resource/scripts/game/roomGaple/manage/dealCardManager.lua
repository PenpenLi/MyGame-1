--
-- Author: tony
-- Date: 2014-07-08 14:27:55
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
-- 发牌
local DealCardManager = class()

local P = RoomViewPosition.DealCardPosition
local tweenDuration = 0.3

local BIG_CARD_SCALE = 116 * 0.8 / 32


-- 扑克堆的位置
local POKER_POS = {}

function DealCardManager:ctor()
end

function DealCardManager:createNodes()
    self.cardBatchNode_ = new(Node)
    self.scene.nodes.dealCardNode:addChild(self.cardBatchNode_)

    self.m_test = new(Node)
    self.scene.nodes.dealCardNode:addChild(self.m_test)

    self.pokerBatch_ = new(Node)
    self.ctx.scene.nodes.dealerNode:addChild(self.pokerBatch_)

    local center_x, center_y = self.ctx.scene.nodes.centerNode:getUnalignPos()
    POKER_POS.x, POKER_POS.y = center_x, center_y - 100
    self.pokerBatch_:setPos(POKER_POS.x, POKER_POS.y)
    self.pokerBatch_:setVisible(false)
    -- 扑克堆
    self.pokerCards_ = {}
    for i = 1, 6 do
        self.pokerCards_[i] = new(Image,"res/room/gaple/roomG_dealed_hand_card.png")
        self.pokerCards_[i]:setPos(0,i)
        self.pokerBatch_:addChild(self.pokerCards_[i])
    end
    self:setPokerVisible(false)

    self.numNeedCards_ = 0
    self.dealCards_ = {}
    for i = 1, 7 do
        self.dealCards_[i] = {}
        for j = 1, 4 do
            self.dealCards_[i][j] = new(Image,"res/room/gaple/roomG_dealed_hand_card.png")
        end
    end 
end

-- 设置扑克堆的可见状态
function DealCardManager:setPokerVisible(visible)
    self.pokerBatch_:setVisible(visible)
end

--[[
    一次发七张    
]]
function DealCardManager:dealCards()
    self:setPokerVisible(true)
    self:dealCardsWithRound(1,7)
    self.isDealingCard = true
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
    if self.currentDealSeatId_ >= 0 and self.currentDealSeatId_ <= 3 then
        self.startDealIndex_ = startDealIndex -- 开始发第几张牌
        if self.scheduleHandle_ then
            nk.GCD.CancelById(self,self.scheduleHandle_)
            self.scheduleHandle_ = nil
        end
        self.scheduleHandle_ =  nk.GCD.PostDelay(self, function()
            self:scheduleHandler()
        end, nil, 100, true)
    end

    return self
end

function DealCardManager:scheduleHandler()
    self:dealCard_(self.seatManager:getSeatPositionId(self.currentDealSeatId_))

    -- 找到下一个需要发牌的座位id
    self.currentDealSeatId_ = self:findNextDealSeatId_()

    -- 已发牌总数加1
    self.numDealedCards_ = self.numDealedCards_ + 1
    if self.numDealedCards_ % self.numInGamePlayers_ == 0 then
        self.startDealIndex_ = self.startDealIndex_ + 1
    end

    -- 需发牌总数减1，发牌总数为0则已发完，结束发牌
    self.numNeedCards_ = self.numNeedCards_ - 1
    if self.numNeedCards_ == 0 then
        nk.GCD.CancelById(self,self.scheduleHandle_)
        self.scheduleHandle_ = nil
        self:setPokerVisible(false)
        self.isDealingCard = false
    end
end

function DealCardManager:dealCard_(positionId)
    local dealingcard = nil
    if self.dealCards_[self.startDealIndex_] and self.dealCards_[self.startDealIndex_][positionId] then
        dealingcard = self.dealCards_[self.startDealIndex_][positionId]
    end

    if not dealingcard then return end

    if dealingcard:getParent() then 
        dealingcard:removeFromParent()
    end 
    dealingcard:addPropScaleSolid(0, 1, 1, kCenterXY)

    Log.dump(self.ctx.model.gameInfo.dealerSeatId,"self.ctx.model.gameInfo.dealerSeatId")
    local dealerSeatId = -1
    if self.ctx.model.gameInfo.dealerSeatId and self.ctx.model.gameInfo.dealerSeatId >= 0 then
        dealerSeatId = self.ctx.model.gameInfo.dealerSeatId
    end
    local startPosId = 5
    if dealerSeatId ~= -1 then
        startPosId = self.seatManager:getSeatPositionId(dealerSeatId)
    end
    dealingcard:setPos(POKER_POS.x, POKER_POS.y)
    self.m_test:addChild(dealingcard)


    local textNode = new(Image,"res/room/gaple/roomG_dealed_hand_card.png")
    if textNode:getParent() then 
        textNode:removeFromParent()
    end 
    textNode:addPropScaleSolid(0, 1, 1, kCenterXY)
    textNode:setPos(POKER_POS.x, POKER_POS.y)
    self.m_test:addChild(textNode)

    local cardIndex = self.startDealIndex_
    local cardNum = self.dealCardsNum_
    local seatView = self.seatManager:getSeatView(self.currentDealSeatId_)
    local seatData = seatView:getSeatData()
    if self.model:isSelfInSeat() and positionId == 3 then        
        transition.moveTo(textNode, {time = tweenDuration, x = P[positionId].x + 80 + 60 * cardIndex, y = P[positionId].y + 125, onComplete=handler(self, function()
            if self.model:isSelfInSeat() then  
                -- if textNode:getParent() then 
                    textNode:removeFromParent(true)
                -- end 
                seatView:setHandCardValue(seatData.cards)
                seatView:showHandCardsElement(cardIndex)
                seatView:flipHandCardsElement(cardIndex)
            elseif not seatView:getSeatData() then
                -- if textNode:getParent() then 
                    textNode:removeFromParent(true)
                -- end
            end
        end)})
        transition.scaleTo(textNode, {scaleX=BIG_CARD_SCALE, scaleY=BIG_CARD_SCALE, time=tweenDuration, needChange = false})
        transition.rotateTo(textNode, {time = tweenDuration, rotate = 360})
    else
        transition.moveTo(textNode, {time=tweenDuration, x=P[positionId].x, y=P[positionId].y, onComplete=handler(self, function()
            -- if textNode:getParent() then 
                textNode:removeFromParent(true)
            -- end
        end)})
        if seatData then
            seatView:setHandCardValue(seatData.cards)
        end
        transition.rotateTo(textNode, {time = tweenDuration, rotate = 360})
    end
    nk.SoundManager:playSound(nk.SoundManager.DEAL_CARD)
end

function DealCardManager:findNextDealSeatId_()
    self.tempIndex_ = (self.tempIndex_ or -1) + 1
    if self.tempIndex_ > #self.dealSeatIdList_ then
        self.tempIndex_ = 1
    end
    return self.dealSeatIdList_[self.tempIndex_]
end

-- 显示指定位置id的发牌sprite
function DealCardManager:showDealedCard(player, cardNum)
    if cardNum == nil or cardNum == 0 then
        return self
    end

    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    for i = 1, cardNum do
        local deadCard = self.dealCards_[i][positionId]
        deadCard:addPropScaleSolid(0, 1, 1, kCenterDrawing)
        deadCard:setVisible(false)
        deadCard:removeFromParent(true)
    end
end

-- 隐藏所有的发牌sprite
function DealCardManager:hideAllDealedCard()
    for i = 1, 7 do
        for j = 1, 4 do
            if self.dealCards_[i] and self.dealCards_[i][j] then
                self.dealCards_[i][j]:setVisible(false)
                self.dealCards_[i][j]:removeFromParent(true)
            end
        end
    end
end

-- 隐藏指定位置id的发牌sprite
function DealCardManager:hideDealedCard(positionId)
    print("hideDealedCard", positionId)
    for i = 1, 7 do
        local deadCard = self.dealCards_[i][positionId]
        deadCard:setVisible(false)
        deadCard:removeFromParent(true)
    end
end

function DealCardManager:ThrowDeadCard(positionId)
    local targetPos = RoomViewPosition.DealerPosition[5]
    for i = 1, 7 do
        local deadCard = self.dealCards_[i][positionId]
        -- if deadCard and deadCard.parent then
        --     -- transition.moveTo(deadCard, {
        --     --     time = tweenDuration + 0.1 * i, 
        --     --     x = targetPos.x,
        --     --     y = targetPos.y,
        --     --     onComplete = function ()
        --     --         deadCard:removeFromParent()
        --     --     end
        --     -- })
        -- end
        deadCard:setVisible(false)
        deadCard:removeFromParent(true)
    end
end

-- 移动至座位中央
function DealCardManager:moveDealedCardToSeat(player, callback)
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    local destPosition = self.seatManager:getSeatPosition(player.seatId)
    if destPosition then
        for i = 1, 7 do
            local deadCard = self.dealCards_[i][positionId]
            -- transition.moveTo(deadCard, {
            --     time = tweenDuration, 
            --     x = destPosition.x + i * 8 - 16, 
            --     y = destPosition.y,
            --     onComplete = function ()
            --         deadCard:removeFromParent()
            --         print("moveDealedCardToSeat", i)
            --         if i == 1 and callback then
            --             print("moveDealedCardToSeat")
            --             callback()
            --         end
            --     end
            -- })
            deadCard:setVisible(false)
            deadCard:removeFromParent(true)
            if i == 1 and callback then
                print("moveDealedCardToSeat")
                callback()
            end
        end
    end
end

-- 重置位置与角度
function DealCardManager:reset()
    print("DealCardManager.reset")
    self:setPokerVisible(false)
    if self.dealCards_ then
        for i = 1, 7 do
            for j = 1, 4 do
                self.dealCards_[i][j]:setVisible(false)
                self.dealCards_[i][j]:removeFromParent()
            end
        end
    end
    nk.GCD.Cancel(self)
    return self
end

-- 清理
function DealCardManager:dtor()
    nk.GCD.Cancel(self)
    if self.dealCards_ then
        for i = 1, 7 do
            for j = 1, 4 do
                if self.dealCards_[i] then
                    delete(self.dealCards_[i][j])
                end
            end
        end 
        self.dealCards_ = nil
    end
end

return DealCardManager