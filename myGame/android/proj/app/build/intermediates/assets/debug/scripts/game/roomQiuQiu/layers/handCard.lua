-- handCard.lua
-- Date: 2016-07-11
-- Last modification : 2016-07-11
-- Description: a class for handCard in QiuQiu

local HandCard = class(Node)

--a1,a2,a3,a4在cards中的顺序,六种情况,用rankindex和他比对是哪种
local indexMap = {}
--切牌失败要回到上个切牌random值
local oldRandom = 1
--弃牌或者确认牌之后，不让点击，禁止计时器恢复可点
local moveTime = 0.2

-- 除了自己，其他座位上的牌默认scale = 0.8
-- changeOrderCallback 切换卡牌顺序回调
local CardPosX = 62 * 0.5
local selfCardPosX = {0+CardPosX, 59+CardPosX, 118+CardPosX, 177+CardPosX}
local CardPosY = 120 * 0.5
local selfCardPosY = {CardPosY, CardPosY, CardPosY, CardPosY}

function HandCard:ctor(sizeScale, changeOrderCallback)

    self:setSize(256, 120)

    -- 设置缩放
    if sizeScale then
       self:addPropScaleSolid(1, sizeScale, sizeScale, kCenterDrawing)
    end

    self.onCardsOrderChange_ = changeOrderCallback

    -- 扑克牌容器
    local PokerCard = nk.pokerUI.PokerCard
    self.cards = {}
    self.a1 = new(PokerCard)
    self.a1:setPos(selfCardPosX[1], selfCardPosY[1])
    self.a1:addTo(self)
    self.a2 = new(PokerCard)
    self.a2:setPos(selfCardPosX[2], selfCardPosY[2])
    self.a2:addTo(self)
    self.a3 = new(PokerCard)
    self.a3:setPos(selfCardPosX[3], selfCardPosY[3])
    self.a3:addTo(self)
    self.a4 = new(PokerCard)
    self.a4:setPos(selfCardPosX[4], selfCardPosY[4])
    self.a4:addTo(self)
    self.cards[1] = self.a1
    self.cards[2] = self.a2
    self.cards[3] = self.a3
    self.cards[4] = self.a4

    self.cardNum_ = 4
    -- 记录随机次数(当前算一次)
    self.random_ = 1

    indexMap[1] = {1,2,3,4}
    indexMap[2] = {1,3,2,4}
    indexMap[3] = {1,4,2,3}
    indexMap[4] = {2,3,1,4}
    indexMap[5] = {2,4,1,3}
    indexMap[6] = {3,4,1,2}

    self:setEventTouch(self,function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
        if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            self:onClick(card)
        end
    end)
    
    --这个弃牌跟收到包实现弃牌不同，是为了玩家点击了弃牌后，在广播包来之前，禁止切牌；否则会出现恢复可切牌的bug(因为跑切牌动画默认恢复点击)
    EventDispatcher.getInstance():register(EventConstants.SELF_CLICK_FOLD_CARD, self, self.DisableCardsTouch)
end

-- 点击手牌，随机组合点数
-- 3张牌客户端随机，4张牌server端随机
function HandCard:onClick(target)
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)

    if self.cardNum_ == 3 then
        self.random_ = self.random_ % 3 + 1
        if self.random_ == 1 then
            self.cards[1], self.cards[2], self.cards[3] = self.a1, self.a2, self.a3  
        elseif self.random_ == 2 then
            self.cards[1], self.cards[2], self.cards[3] = self.a1, self.a3, self.a2  
        else
            self.cards[1], self.cards[2], self.cards[3] = self.a2, self.a3, self.a1  
        end
	    self:setPickable(false)
        self:setCardNum(3)
        --Clock.instance():schedule_once(function(dt)
          --  self:setPickable(true)
        --end, 1)
    elseif self.cardNum_ == 4 then
        --四张牌，六种情况,按照indexMap赋值
        oldRandom = self.random_
        
        self.random_ = self.random_ % 6 + 1
        while not self:setCardsRank() do
            self.random_ = self.random_ % 6 + 1
        end
    
        --先不用缓动，等server回复再动，而且禁止点击
        self:setPickable(false)
    end

    --重新设置点数或者牌型提示,4张牌就请求server确认先
    if self.onCardsOrderChange_ then
       self.onCardsOrderChange_(self.cardNum_)
    end
    
end

-- 设置牌面,发三张牌和发第四张牌。发四张牌1.2秒后会跑setCardsByServer按server最优排序
function HandCard:setCards(cardsValue)
    Log.dump(cardsValue, ">>>>>>>>> 3 cards")
    for i, cardUint in ipairs(cardsValue) do
        if not tolua.isnull(self.cards[i]) then
            self.cards[i]:setCard(cardUint)
        end
    end
    self.random_ = 1

    return self
end

--禁止点击，而且清理计时器不让其他计时器恢复点击。当确认牌型或者弃牌，都不能再点击，除非开始新一局
function HandCard:DisableCardsTouch()
    self:setPickable(false)
    self:setCardMoveCallback(nil)
end

function HandCard:EnableCardsTouch()
    self:setPickable(true)
    self:setCardMoveCallback(nil)
end

--按server设置牌面,缓动时不让点击
function HandCard:setCardsByServer(cardsValue)
    Log.dump(cardsValue, ">>>>>>>>> last card")

    local rankIndex = {}

    for i = 1,#cardsValue do
        if self.a1:getPointValue() == cardsValue[i] then
            self.cards[i] = self.a1
            rankIndex[i] = 1
        elseif self.a2:getPointValue() == cardsValue[i] then
            self.cards[i] = self.a2
            rankIndex[i] = 2
        elseif self.a3:getPointValue() == cardsValue[i] then
            self.cards[i] = self.a3
            rankIndex[i] = 3
        elseif self.a4:getPointValue() == cardsValue[i] then
            self.cards[i] = self.a4
            rankIndex[i] = 4
        end
    end
    
    self:setCardNum(4)

    self.random_ = self:CardsRankIndex(rankIndex)
    oldRandom = self.random_
end

----------------------切牌方法,两张都在左边就是相同
function HandCard:CardsRankIndex(rankIndex)
    for k,v in ipairs(indexMap) do
        if self:isInLeft(v[1],rankIndex) and self:isInLeft(v[2],rankIndex) then
            return k
        end
    end
    return 1
end

function HandCard:isInLeft(value,targetArr)
    if value == targetArr[1] or value == targetArr[2] then
        return true
    end
    return false
end

function HandCard:setCardsRank()
    if self.random_ == 1 then
        self.cards[1], self.cards[2], self.cards[3], self.cards[4]= self.a1, self.a2, self.a3 ,self.a4
    elseif self.random_ == 2 then
        self.cards[1], self.cards[2], self.cards[3], self.cards[4]= self.a1, self.a3, self.a2 ,self.a4  
    elseif self.random_ == 3 then
        self.cards[1], self.cards[2], self.cards[3], self.cards[4]= self.a1, self.a4, self.a2 ,self.a3
    elseif self.random_ == 4 then
        self.cards[1], self.cards[2], self.cards[3], self.cards[4]= self.a2, self.a3, self.a1 ,self.a4
    elseif self.random_ == 5 then
        self.cards[1], self.cards[2], self.cards[3], self.cards[4]= self.a2, self.a4, self.a1 ,self.a3
    elseif self.random_ == 6 then
        self.cards[1], self.cards[2], self.cards[3], self.cards[4]= self.a3, self.a4, self.a1 ,self.a2
    end

    if checkint(self:getLeftPoint())  < checkint(self:getRightPoint()) then 
        return false
    end
    return true
end

--成功跑缓动动画
function HandCard:changeCardSucc()
    self:setCardNum(4)
    
    --Clock.instance():schedule_once(function(dt)
      --  self:setPickable(true)
    --end, 1)
end

--失败重置数据，这里也有可能会有缓动，但是点数是不变的,就像 12,34和21,43
function HandCard:changeCardFail()
    if type(self:getRightPoint()) ~= "string" then 
        self.random_ = oldRandom
        self:setCardsRank()
        self:setCardNum(4)

       -- Clock.instance():schedule_once(function(dt)
         --   self:setPickable(true)
        --end, 1)
    else
        self:setCardNum(3)
    end
end
-----------------------------------
function HandCard:setCardMoveCallback(callback)
    self.moveCallback = callback
end

-- 设置手牌数目,跑切牌动画，默认缓动完可点击
function HandCard:setCardNum(cardNum , isOther)
    self.cardNum_ = cardNum

    self:setCardMoveCallback(function()
        if not isOther then
            self:setPickable(true)
        end
    end)
    assert(cardNum == 3 or cardNum == 4, "cardNum error " .. cardNum)

    self:cardsMoveReset()
    if cardNum == 4 then
        self.cards[1]:moveTo({time = moveTime, x = selfCardPosX[1], y = selfCardPosY[1],onComplete = function()
                if self.moveCallback ~= nil then
                    self.moveCallback()
                end
            end})
        self.cards[2]:moveTo({time = moveTime, x = selfCardPosX[2], y = selfCardPosY[2]})
        self.cards[3]:moveTo({time = moveTime, x = selfCardPosX[3], y = selfCardPosY[3]})
        self.cards[4]:moveTo({time = moveTime, x = selfCardPosX[4], y = selfCardPosY[4]})
    else
        self.cards[1]:moveTo({time = moveTime, x = selfCardPosX[1], y = selfCardPosY[1],onComplete = function()
                if self.moveCallback ~= nil then
                    self.moveCallback()
                end
            end})
        self.cards[2]:moveTo({time = moveTime, x = selfCardPosX[2], y = selfCardPosY[2]})
        self.cards[3]:moveTo({time = moveTime, x = selfCardPosX[3], y = selfCardPosY[3]})
        self.cards[4]:setVisible(false)
    end
end

function HandCard:cardsMoveReset()
    self.cards[1]:removeAllProp()
    self.cards[2]:removeAllProp()
    self.cards[3]:removeAllProp()
    self.cards[4]:removeAllProp()
end

-- 获取左边两张牌点数(手牌大点数）
function HandCard:getLeftPoint()
    local c1 = self.cards[1]:getCardPoint() 
    local c2 = self.cards[2]:getCardPoint()
    if c1 and c2 then
        return (c1 + c2) % 10
    end
    
    return "?"
end

-- 获取右边两张牌点数(手牌小点数）
function HandCard:getRightPoint()
    local c3 = self.cards[3]:getCardPoint() 
    local c4 = self.cards[4]:getCardPoint()
    if c3 and c4 then
        return (c3 + c4) % 10
    end
    return "?"
end

-- 判断手上是否有cardUnint(server定的原始值)牌
function HandCard:isHasCard(cardUnit)
    for i=1, self.cardNum_ do
        if self.cards[i]:getPointValue() == cardUnit then
            return true
        end
    end
    return false
end

function HandCard:getCardsUint()
    local cardsUint = {}
    for i=1, self.cardNum_ do
        cardsUint[i] = self.cards[i]:getPointValue()
    end
    return cardsUint
end


function HandCard:hideAllCards()
    for i = 1, self.cardNum_ do
        self.cards[i]:setVisible(false)
    end
end

function HandCard:showAllCards()
    for i = 1, self.cardNum_ do
        self.cards[i]:setVisible(true)
    end
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
    return self.cards[idx]:getVisible()
end

function HandCard:isCardBack(idx)
    return self.cards[idx]:isBack()
end

function HandCard:isCardFront(idx)
    return self.cards[idx]:isFront()
end

-- 翻开所有牌（比牌时）               --不需要播放四次声音， by ziway
function HandCard:flipAll()
    for i = 1, self.cardNum_ do
        if i == 1 then
            self.cards[i]:flip()
        else
            self.cards[i]:flip(true)
        end
    end

    return self
end

function HandCard:showFrontAll()
    for _, card in ipairs(self.cards) do
        card:showFront()
    end

    return self
end

function HandCard:showBackAll()
    for _, card in ipairs(self.cards) do
        card:showBack()
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
    if numCard then
        for i = 1, numCard do
            if self.cards[i] then
                self.cards[i]:addDark()
            end
        end
        self:DisableCardsTouch()
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

    self.a1:setPos(selfCardPosX[1], selfCardPosY[1])
    self.a2:setPos(selfCardPosX[2], selfCardPosY[2])
    self.a3:setPos(selfCardPosX[3], selfCardPosY[3])
    self.a4:setPos(selfCardPosX[4], selfCardPosY[4])
    self.cards[1] = self.a1
    self.cards[2] = self.a2
    self.cards[3] = self.a3
    self.cards[4] = self.a4
    self.random_ = 1

    self:EnableCardsTouch()
    
    return self
end

function HandCard:dtor()
    for _, card in ipairs(self.cards) do
        delete(card)
        -- card = nil
    end

    EventDispatcher.getInstance():unregister(EventConstants.SELF_CLICK_FOLD_CARD, self, self.DisableCardsTouch)
end

return HandCard
