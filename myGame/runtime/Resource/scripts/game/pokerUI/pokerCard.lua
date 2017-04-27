--
-- Author: Johnny Lee
-- Date: 2014-07-11 11:50:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local PokerCard = class(Node)


PokerCard.config = {
    ["v"] = {
        back_bg = "res/common/common_poker_back_bg_v.png",
        font_bg = "res/common/common_poker_font_bg_v.png",
        topPoint_rule = {
            align = kAlignCenter,
            x = 0,
            y = -30,
        },
        downPoint_rule = {
            align = kAlignCenter,
            x = 0,
            y = 30,
        },
    },
    ["h"] = {
        back_bg = "res/common/common_poker_back_bg_h.png",
        font_bg = "res/common/common_poker_font_bg_h.png",
        topPoint_rule = {
            align = kAlignCenter,
            x = -30,
            y = 0,
        },
        downPoint_rule = {
            align = kAlignCenter,
            x = 30,
            y = 0,
        },
    },
}



function PokerCard:ctor(cradDir)
    -- 初始数值
    self.cardUint_   = 0x00
    self.downPoint_  = nil
    self.upPoint_ = 0
    self.isBack_ = true

    self.cardDir = "v"

    --- 当前牌是否已经使用
    self.isUsed = false 

    local config = PokerCard.config[self.cardDir]

    -- 牌背
    self.backBg_ = new(Image, config.back_bg)
    self.backBg_:setAlign(kAlignCenter)
    self:addChild(self.backBg_)
    
    -- self:setSize(self.backBg_:getSize())

    -- 初始化batch node
    self.frontBatch_ = new(Node)
    self.frontBatch_:setAlign(kAlignCenter)
    self.frontBatch_:setSize(self.backBg_:getSize())

    -- 前背景
    self.frontBg_ = new(Image, config.font_bg)
    self.frontBg_:setAlign(kAlignCenter)
    self.frontBatch_:addChild(self.frontBg_)
    
    -- 牌的上半部分点数
    self.topPointSpr_ = new(Image, "res/common/common_poker_0.png")
    self.frontBatch_:addChild(self.topPointSpr_)
    self.topPointSpr_:setAlign(config.topPoint_rule.align)
    self.topPointSpr_:setPos(config.topPoint_rule.x,config.topPoint_rule.y)
    
    -- 牌的下半部分点数
    self.downPointSpr_ = new(Image, "res/common/common_poker_0.png")
    self.frontBatch_:addChild(self.downPointSpr_)
    self.downPointSpr_:setAlign(config.downPoint_rule.align)
    self.downPointSpr_:setPos(config.downPoint_rule.x,config.downPoint_rule.y)

    -- 点击事件
    self.enabled = true

    self:addChild(self.frontBatch_)

    self.touch_node = new(Node)
    self.touch_node:setAlign(kAlignCenter)
    self.touch_node:setSize(self.backBg_:getSize())
    self:addChild(self.touch_node)

    -- local node2 = new(Image,"res/common/common_red_point.png")
    -- node2:setAlign(kAlignCenter)
    -- self:addChild(node2)
    -- test
    -- self:addTips()
end

function PokerCard:addTips()
    self.tipsNode = new(Node)
    self:addChild(self.tipsNode)
    self.tipsNode:setAlign(kAlignTop)
    self.tipsNode:setPos(0,-60)

    local tips_node = new(Image,"res/room/gaple/roomG_hand_tips_node.png")
    tips_node:setPos(0,-20)
    tips_node:setAlign(kAlignTop)
    self.tipsNode:addChild(tips_node)

    local tips_bg = new(Image,"res/room/gaple/roomG_hand_tips_bg.png", nil, nil, 25, 25, 25, 25)
    tips_bg:setSize(320,60)
    tips_bg:setPos(0, -80)
    tips_bg:setAlign(kAlignTop)
    self.tipsNode:addChild(tips_bg)

    local text = bm.LangUtil.getText("ROOM", "CARD_TIPS1")
    local tipsText_ = new(TextView, text, 300, 60, kAlignCenter, nil, 16, 255, 255, 255)
    tipsText_:setAlign(kAlignCenter)
    tips_bg:addChild(tipsText_)
end

function PokerCard:removeTips()
    if self.tipsNode then
        nk.functions.removeFromParent(self.tipsNode, true)
    end
end

function PokerCard:getPointValue()
    return self.cardUint_
end

function PokerCard:getUpPoint()
    return self.upPoint_
end

function PokerCard:getDownPoint()
    return self.downPoint_
end

-- 获取当前牌的点数
function PokerCard:getCardPoint()
    if self.upPoint_ and self.downPoint_ then
        return self.upPoint_ + self.downPoint_
    else
        return nil
    end
end

function PokerCard:isDouble()
    return self.upPoint_ == self.downPoint_
end

-- 设置扑克牌面
function PokerCard:setCard(cardUint)
    self.cardUint_  = cardUint
    self.downPoint_ = nk.functions.getLowPoint(cardUint)
    self.upPoint_   = nk.functions.getHighPoint(cardUint)

    local rotation = 0
    if self.cardDir == "h" then
        rotation = 90
    end

    local point = string.format("res/common/common_poker_%d.png",self.upPoint_)
    self.topPointSpr_:setFile(point)
    self.topPointSpr_:addPropRotateSolid(0, rotation, kCenterDrawing)

    point = string.format("res/common/common_poker_%d.png",self.downPoint_)
    self.downPointSpr_:setFile(point)
    self.downPointSpr_:addPropRotateSolid(0, rotation, kCenterDrawing)
    return self
end

-- 翻牌动画
function PokerCard:flip(noSound)
    self.isBack_ = false
    self:removeCardProp()
    -- 首先显示牌背，0.5s后开始翻牌动画
    self:showBack()

    if not noSound then
        nk.GCD.PostDelay(self, function()
                nk.SoundManager:playSound(nk.SoundManager.FLIP_CARD)
            end, nil, 500)
    end

    --sequence, animType, duration, delay, startX, endX, startY, endY, center, x, y)
    -- self.backBg_:addPropScale(1, kAnimNormal, 250, 200, 1, 0, nil, nil, kCenterDrawing)
    local params = {sequence = 1,time = 0.25,delay = 0.2,scaleX = 0,needChange = false,onComplete = function()
        self:showFront()
        end}
    self.backBg_:scaleTo(params)

    self.frontBatch_:addPropScale(1, kAnimNormal, 250, 450, 0, 1, nil, nil, kCenterDrawing)

    return self
end

function PokerCard:removeCardProp()
    self.backBg_:doRemoveProp(1)
    self.frontBatch_:doRemoveProp(1)
end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    self.backBg_:setVisible(false)
    self.frontBatch_:setVisible(true)
    return self
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    self.backBg_:setVisible(true)
    self.frontBatch_:setVisible(false)
    return self
end

function PokerCard:isBack()
    return self.isBack_
end

-- 震动扑克牌
function PokerCard:shake()
    if self.m_shakeAnim then
        delete(self.m_shakeAnim)
        self.m_shakeAnim = nil
    end
    self.m_shakeAnim = new(AnimInt, kAnimRepeat, 0, 1, 25, -1)
    self.m_shakeAnim:setDebugName("PokerCard", "m_shakeAnim")
    self.m_shakeAnim:setEvent(self, self.onEnterFrame)
    return self
end

function PokerCard:onEnterFrame()
    local posX, posY = self.frontBatch_:getPos()
    if posX <= -1 or posX >= 1 then
        posX = 0
        self.frontBatch_:setPos(posX, posY)
    end
    if posY <= -1 or posY >= 1 then
        posY = 0
        self.frontBatch_:setPos(posX, posY)
    end
    posX = posX + math.random(-1, 1)
    posY = posY + math.random(-1, 1)
    self.frontBatch_:setPos(posX, posY)

    return self
end

-- 停止震动扑克牌
function PokerCard:stopShake()
    if self.m_shakeAnim then
        delete(self.m_shakeAnim)
        self.m_shakeAnim = nil
    end
    self.frontBatch_:setPos(0, 0)
    return self
end

--暗化牌
function PokerCard:addDark()
    if not self.darkOverlay_ then
        self.darkOverlay_ = new(Image, "res/common/common_poker_dark_overlay.png")
        self:addChild(self.darkOverlay_)
        self.darkOverlay_:setAlign(kAlignCenter)
        local fontSize_x, fontSize_y = self.frontBg_:getSize()
        local darkSize_x, darkSize_y = self.darkOverlay_:getSize()
        self.darkOverlay_:addPropScaleSolid(0, fontSize_x / darkSize_x, fontSize_y / darkSize_y, kCenterDrawing);
    end
    self.darkOverlay_:setVisible(true)
    return self
end

-- 移除暗化
function PokerCard:removeDark()
    if self.darkOverlay_ then
        self.darkOverlay_:setVisible(false)
    end
end

-- 重置扑克牌（移除舞台时自动调用）
function PokerCard:dtor()
    -- 恢复扑克
    self:stopShake()
    self:removeDark()
    self:resetCard()
end

function PokerCard:resetCard()
    -- print("PokerCard:reset")
    -- 初始数值
    self.cardUint_   = 0x00
    self.downPoint_  = nil
    self.upPoint_ = nil
    self.isBack_ = true

    -- 点击事件
    self.enabled = true

    self.topPointSpr_:doRemoveProp(0)
    self.downPointSpr_:doRemoveProp(0)
    self.backBg_:doRemoveProp(1)
    self.frontBatch_:doRemoveProp(1)

    nk.GCD.Cancel(self)

end

return PokerCard