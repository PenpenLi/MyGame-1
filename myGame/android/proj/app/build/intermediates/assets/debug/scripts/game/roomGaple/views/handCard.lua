--
-- Author: johnny@boomegg.com
-- Date: 2014-07-14 15:14:54
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

-- 自己手牌模块


local HandCard = class(Node)

-- 中心的x坐标
local CenterX = 231
-- 牌间距
local CellX = 66
local CellY = 120

function HandCard:ctor()
    -- 手牌数量死路
    self.cardNum_ = 7
    -- 可用手牌数量
    self.usefulNum_ = 7
    -- 当前选中的牌
    self.selectCard_ = nil

    -- 扑克牌容器
    local PokerCard = nk.pokerUI.PokerCard
    local startX = CenterX - self.cardNum_ * CellX * 0.5
    self.cards = {}
    for i = 1, self.cardNum_ do
        local card = new(PokerCard)
        card:setPos(startX + CellX * (i - 1), CellY * 0.5)
        -- card:setVisible(false)
        card.touch_node:setEventTouch(self,function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
            if self.touchEnabled_ then
                if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                    self:onTouchEvent_(card)

                    self.beganx = x
                    self.begany = y

                    self.player_sx, self.player_sy = card:getUnalignPos()
                    -- setPos 会自动加上矫正
                    -- self.player_sx = self.player_sx/System.getLayoutScale()
                    -- self.player_sy = self.player_sy/System.getLayoutScale()

                    self.offset_x = self.player_sx - self.beganx
                    self.offset_y = self.player_sy - self.begany
                elseif finger_action == kFingerMove then
                    x = x + (self.offset_x or 0)
                    y = y + (self.offset_y or 0)
                    if self.selectCard_ then
                        card:setPos(x,y)
                        EventDispatcher.getInstance():dispatch(EventConstants.checkCardShow, false)
                    end
                elseif finger_action == kFingerUp then
                    self.endx = x
                    self.endy = y

                    self.beganx = self.beganx or 300
                    self.begany = self.begany or 300

                    if math.abs(self.beganx - self.endx) >= 20 or math.abs(self.begany - self.endy) >= 20 then
                        EventDispatcher.getInstance():dispatch(EventConstants.checkCardShow, true)
                    end
                end
            end
        end)
        self:addChild(card)
        table.insert(self.cards,card)
    end

    EventDispatcher.getInstance():register(EventConstants.handCardUsed, self, self.cardUsedEvent_)
    EventDispatcher.getInstance():register(EventConstants.cardMoveBack, self, self.cardMoveBackEvent_)

    self.passOrDeadTipsBg = new(Image,"res/room/gaple/roomG_round_pass_bg.png")
    self.passOrDeadTipsBg:setAlign(kAlignCenter)
    self:addChild(self.passOrDeadTipsBg)
    self.passOrDeadTipsBg:setVisible(false)

    local psssbg_x, psssbg_y = self.passOrDeadTipsBg:getSize()

    --没有牌可以接龙
    local text = bm.LangUtil.getText("ROOM", "NO_CARD_CAN_SHOW")
    self.passText_ = new(Text, text, psssbg_x - 10, 30, kAlignCenter,nil,26,230,255,80)
    self.passText_:setAlign(kAlignCenter)
    self.passOrDeadTipsBg:addChild(self.passText_)
    self.passText_:setVisible(false)

    --出现死路
    text = bm.LangUtil.getText("ROOM", "APPEAR_DEAD_END")   
    self.deadText_ = new(Text, text, psssbg_x - 10, 30, kAlignCenter,nil,26,230,255,80)
    self.deadText_:setAlign(kAlignCenter)
    self.passOrDeadTipsBg:addChild(self.deadText_)
    self.deadText_:setVisible(false)

end

function HandCard:onTouchEvent_(target)
    if self.touchEnabled_ then
        local isCurrent, startX, cellX
        if self.selectCard_ ~= target then
            isCurrent = false
            cellX = CellX + 5
        else
            isCurrent = true
            cellX = CellX
            self.selectCard_ = nil
        end
        local startX = CenterX - self.usefulNum_ * CellX * 0.5
        local card, index = nil, 1
        for i = 1, self.cardNum_ do
            card = self.cards[i]
            if not card.isUsed then
                if isCurrent then
                    card:setPos(startX + CellX * (index - 1), CellY * 0.5)
                elseif card ~= target then
                    card:setPos(startX + CellX * (index - 1), CellY * 0.5)
                else
                    card:setPos(startX + CellX * (index - 1), CellY * 0.5 - 20)
                    self.selectCard_ = target
                    card:removeDark()
                end
                index = index + 1
            end
            if card.tipsNode then
                card:removeTips()       
            end
        end
        EventDispatcher.getInstance():dispatch(EventConstants.handCardSelected, self.selectCard_)
        EventDispatcher.getInstance():dispatch(EventConstants.tipsCardSelected, self.selectCard_)
    end
end

function HandCard:cardMoveBackEvent_()
    if self.selectCard_ then
        self:onTouchEvent_(self.selectCard_)
    end
end

function HandCard:cardUsedEvent_(evt)
    if evt.uid and evt.uid == self.cardsUid_ then
        Log.printInfo("HandCard:cardUsedEvent_   evt.uid=" .. evt.uid .. "  self.cardUid_=" .. self.cardsUid_)
        if evt.card then
            evt.card.isUsed = true
            evt.card:setVisible(false)
            self.usefulNum_ = self.usefulNum_ - 1

            local startX = CenterX - (self.usefulNum_ - 0) * CellX * 0.5
            local card, index = nil, 1
            for i = 1, self.cardNum_ do
                card = self.cards[i]
                if not card.isUsed then
                    -- transition.stopTarget(card)
                    -- card:moveTo(0.1, startX + CellX * (index - 1), 0)
                    card:setPos(startX + CellX * (index - 1), CellY * 0.5)
                    card:removeDark()
                    index = index + 1
                end
            end        
        end
    end
end

function HandCard:setTouchStatus(enable)
    self.touchEnabled_ = enable
end

function HandCard:getSelectedCard()
    return self.selectCard_
end

function HandCard:setCardsUid(uid)
    self.cardsUid_ = uid
end

-- 设置牌面
function HandCard:setCards(cardsValue)
    if cardsValue then
        local cardNum = #cardsValue
        for i,card in ipairs(self.cards) do
            if i <= cardNum then
                card:setCard(cardsValue[i])
                card.isUsed = false
            else
                local data = {card = card, uid = self.cardsUid_}
                EventDispatcher.getInstance():dispatch(EventConstants.handCardUsed, data)
            end
        end
    end
    return self
end

-- 根据cardValue查找手牌
function HandCard:findCard(cardValue)
    local findCard = nil
    for i, card in ipairs(self.cards) do
        if card:getPointValue() == cardValue then
            findCard = card
            break
         end
    end
    return findCard
end

-- pass
function HandCard:roundPass()
    for i = 1, self.cardNum_ do
        local card = self.cards[i]
        if not card.isUsed then
            card:addDark()
        end
    end
    self.passOrDeadTipsBg:setVisible(true)
    self.passText_:setVisible(true)
    self.deadText_:setVisible(false)
end

-- dead
function HandCard:roundDead()
    for i = 1, self.cardNum_ do
        local card = self.cards[i]
        if not card.isUsed then
            card:addDark()
        end
    end
    self.passOrDeadTipsBg:setVisible(true)
    self.passText_:setVisible(false)
    self.deadText_:setVisible(true)
end

function HandCard:hideAllCards()
    for i = 1, self.cardNum_ do
        self.cards[i]:setVisible(false)
    end
end

function HandCard:showAllCards()
    local card
    for i = 1, self.cardNum_ do
        card = self.cards[i]
        if not card.isUsed then
            card:setVisible(true)
            card:removeDark()
        end
    end
    self.passOrDeadTipsBg:setVisible(false)
    self.passText_:setVisible(false)
    self.deadText_:setVisible(false)
end

function HandCard:checkCard(headValue,tailValue)
    local findCard = false
    local findCardIndex = {}
    dump(self.cards, "self.cards")
    local PokerCard = nk.pokerUI.PokerCard
    for i = 1, self.cardNum_ do
        if not self.cards[i].isUsed then
            local card = new(PokerCard)
            card:setCard(self.cards[i]:getPointValue())
            local upPoint = card:getUpPoint()
            local downPoint = card:getDownPoint()
            if upPoint == headValue or upPoint == tailValue or downPoint == headValue or downPoint == tailValue then
                findCard = true
                table.insert(findCardIndex,i)
                -- break
            else
                --作为庄家第一个出牌
                if headValue == -1 and tailValue == -1 then
                    findCard = true
                    table.insert(findCardIndex,i)
                end
            end
            delete(card)
        end
    end
    if not findCard then
        self:roundPass()
        self:setTouchStatus(false)
    else
        print("findCardIndex=" .. #findCardIndex)
        self:addDarkAll()
        self:setAllEnable(false)
        for i, v in ipairs(findCardIndex) do
            local card = self.cards[v]
            card:removeTips()
            if not card.isUsed then
                card:setVisible(true)
                card:removeDark()
                card:setPickable(true)
                if nk.functions.shouldCardTips() then
                    card:addTips()
                    self.tipcard = card
                    nk.GCD.PostDelay(self, function()
                        if self and self.tipcard then
                            self.tipcard:removeTips()
                        end
                    end, nil, 4000)
                    nk.functions.setHasTips(true)
                end
            end
        end
    end
    return findCard;
end

-- 指定第几张牌翻牌
function HandCard:flipWithIndex(...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        for i = 1, numArgs do
            local value = select(i, ...)
            if value >= 1 and value <= self.cardNum_ then
                self.cards[value]:flip()
            end
        end
    end
    return self
end

function HandCard:showWithIndex(...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        for i = 1, numArgs do
            local value = select(i, ...)
            if value >= 1 and value <= self.cardNum_ then
                self.cards[value]:setVisible(true)
            end
        end
    end
    return self
end

function HandCard:isCardShow(idx)
    return self.cards[idx].visible
end

function HandCard:isCardBack(idx)
    return self.cards[idx]:isBack()
end

function HandCard:isCardFront(idx)
    return self.cards[idx]:isFront()
end

-- 翻开所有牌（比牌时）
function HandCard:flipAll()
    if self:checkBlankCardNum() <= 1 then
        for i = 1, self.cardNum_ do
            local card = self.cards[i]
            if not card.isUsed then
                card:flip()
            end
        end
    end
    return self
end

-- 查找手中空白牌的个数
function HandCard:checkBlankCardNum()
    local blankCardNum = 0
    for i = 1, self.cardNum_ do
        local card = self.cards[i]
        if not card.isUsed and card:getPointValue() == 0 then
            blankCardNum = blankCardNum + 1
        end
    end
    return blankCardNum
end

function HandCard:showFrontAll()
    for _, card in ipairs(self.cards) do
        if not card.isUsed then 
            card:showFront()
        end
    end

    return self
end

function HandCard:showBackAll()
    for _, card in ipairs(self.cards) do
        if not card.isUsed then 
            card:showBack()
        end
    end

    return self
end

-- 震动牌：numCard = 2，前两张；numCard = 3，所有牌
function HandCard:shakeWithNum(numCard)
    for i = 1, numCard do
        if self.cards[i] then
            self.cards[i]:shake()
        end
    end

    return self
end

function HandCard:stopShakeAll()
    for _, card in ipairs(self.cards) do
        card:stopShake()
    end

    return self
end

-- 暗化牌：numCard = 2，前两张；numCard = 3，所有牌
function HandCard:addDarkWithNum(numCard)
    for i = 1, numCard do
        self.cards[i]:addDark()
    end
    return self
end

function HandCard:setAllEnable(flag)
    for _, card in ipairs(self.cards) do
        card:setPickable(flag)
    end

    return self
end

function HandCard:addDarkAll()
    for _, card in ipairs(self.cards) do
        card:addDark()
    end

    return self
end

function HandCard:removeDarkAll()
    for _, card in ipairs(self.cards) do
        card:removeDark()
    end

    return self
end

function HandCard:resetHandCards()
    for _, card in ipairs(self.cards) do
        card:resetCard()
    end
    self.cardNum_ = 7
    self.usefulNum_ = 7
    return self
end

function HandCard:resetPos()
    print("HandCard:resetPos")
    local startX = CenterX - self.cardNum_ * CellX * 0.5
    for i, card in ipairs(self.cards) do
        card:setPos(startX + CellX * (i - 1), CellY * 0.5)
    end
    return self
end 

function HandCard:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.handCardUsed, self, self.cardUsedEvent_)
    EventDispatcher.getInstance():unregister(EventConstants.cardMoveBack, self, self.cardMoveBackEvent_)

    for _, card in ipairs(self.cards) do
        delete(card)
        card = nil
    end
    nk.GCD.Cancel(self)
end

return HandCard