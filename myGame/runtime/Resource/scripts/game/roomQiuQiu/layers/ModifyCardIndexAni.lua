--
-- Author: ziway
-- Date: 2016-05-25 18:50:06
--
local ModifyCardIndexAni = class(Node)

function ModifyCardIndexAni:ctor()
	--切牌提示底图
	-- self.pressNode = display.newNode():addTo(self):setVisible(false)

	-- self.bg = display.newSprite("#modifyCardIndexBg.png"):addTo(self.pressNode)

	--切牌提示光条
    -- self.light = display.newSprite("#modifyCardIndexLight.png")

    -- self.size1 = self.bg:getContentSize()
    -- self.size2 = self.light:getContentSize()

    -- --光条遮罩
    -- local clipper = cc.ClippingNode:create()
    -- clipper:addTo(self.pressNode)
    -- clipper:setContentSize(self.size1)
    -- clipper:setAlphaThreshold(0)
    -- clipper:setStencil(self.bg)
    -- self.light:setPosition(-self.size1.width*0.5-self.size2.width*0.5,0)
    -- clipper:addChild(self.light)

    --确认牌型准备
    self.prepareNode = new(Node)
    self.prepareNode:setAlign(kAlignCenter)
    self.prepareNode:addTo(self)
    self.prepareNode:setVisible(false)

    self.confirmCardsIconPrepare_ = new(Image,kImageMap.qiuqiu_card_mode_confirmed_icon2)
    self.confirmCardsIconPrepare_:setAlign(kAlignCenter)
    self.confirmCardsIconPrepare_:addTo(self.prepareNode)

    --准备光圈
    self.confirmCardsIconSpin_ = new(Image,kImageMap.qiuqiuModifyCardSpin)
    self.confirmCardsIconSpin_:addTo(self.prepareNode)
    self.confirmCardsIconSpin_:setAlign(kAlignCenter)
    self.confirmCardsIconSpin_:setVisible(false)

    --确认牌型提示打钩
    self.confirmCardsIcon_ = new(Image,kImageMap.qiuqiu_card_mode_confirmed_icon)
    self.confirmCardsIcon_:addTo(self)
    self.confirmCardsIcon_:setAlign(kAlignCenter)
    self.confirmCardsIcon_:setVisible(false)

    --打钩光圈
    self.confirmCardsIconCircle_ = new(Image,kImageMap.qiuqiuModifyCardCircle)
    self.confirmCardsIconCircle_:addTo(self)
    self.confirmCardsIconCircle_:setAlign(kAlignCenter)
    self.confirmCardsIconCircle_:setVisible(false)
end

function ModifyCardIndexAni:onModifyWaitting(isSelf,posX,posY)
	self.isFinishAni = nil
	
	-- self.pressNode:setVisible(false)
	self.prepareNode:setVisible(false)
	self.confirmCardsIcon_:setVisible(false)
	self.confirmCardsIconCircle_:setVisible(false)

	self.prepareNode:setPos(posX,posY)
	self.confirmCardsIcon_:setPos(posX,posY)
	self.confirmCardsIconCircle_:setPos(posX,posY)

	--切牌白条动画
	-- if isSelf then
	-- 	self.pressNode:setVisible(true)

	-- 	self.light:removeAllProp()
	-- 	self.light:runAction(cc.RepeatForever:create(transition.sequence({
	--     	cc.CallFunc:create(function()
	--     		self.light:opacity(255)
	--     		self.light:setPos(-self.size1.width*0.5-self.size2.width*0.5,0)
	--     	end),
	--         cc.MoveTo:create(0.5, cc.p(0, 0)), 
	--         cc.DelayTime:create(0.3),
	--         cc.FadeTo:create(0.2,0)
	--     })))
	-- end

	--等待圈圈动画
	self:showBack()
	self.confirmCardsIconSpin_:setVisible(true)
	self.confirmCardsIconSpin_:removeAllProp()
    self.confirmCardsIconSpin_:addPropRotate(1, kAnimRepeat, 500, -1, 0, 360, kCenterDrawing)

end

function ModifyCardIndexAni:onModifyFinish(posX,posY)
	if self.isFinishAni then
		return
	end
	self.isFinishAni = true

	self.prepareNode:setPos(posX,posY)
	self.confirmCardsIcon_:setPos(posX,posY)
	self.confirmCardsIconCircle_:setPos(posX,posY)

	-- self.pressNode:setVisible(false)
	-- self.light:removeAllProp()

	self.confirmCardsIconSpin_:removeAllProp()

	self.prepareNode:removeAllProp()

	local params = {sequence = 1,time = 0.25,delay = 0.2,scaleX = 0,needChange = false,onComplete = function()
        self:onBackActionComplete_()
        end}
    self.prepareNode:scaleTo(params)

	-- self.prepareNode:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
	-- self.prepareNode:runAction(transition.sequence({
	-- 	cc.DelayTime:create(0.2),
	-- 	cc.OrbitCamera:create(0.25, 1, 0, 0, 90, 0, 0),
	-- 	cc.CallFunc:create(handler(self, self.onBackActionComplete_))
	-- }))
end

function ModifyCardIndexAni:onBackActionComplete_()
	self:showFront()

	self.confirmCardsIcon_:removeAllProp()

	local params = {sequence = 1,time = 0.25,srcX = 0,scaleX = 1,needChange = false,onComplete = function()
        self:onFrontActionComplete_()
        end}
    self.confirmCardsIcon_:scaleTo(params)

	-- self.confirmCardsIcon_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
	-- self.confirmCardsIcon_:runAction(transition.sequence({
	-- 	cc.OrbitCamera:create(0.25, 1, 0, -90, 90, 0, 0),
	-- 	cc.CallFunc:create(handler(self, self.onFrontActionComplete_))
	-- }))

end

function ModifyCardIndexAni:onFrontActionComplete_()
 --    self.prepareNode:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
	-- self.confirmCardsIcon_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
	self.prepareNode:removeAllProp()
	self.confirmCardsIcon_:removeAllProp()

	self.confirmCardsIconCircle_:setVisible(true)
	self.confirmCardsIconCircle_:removeAllProp()
	self.confirmCardsIconCircle_:opacity(255)
	self.confirmCardsIconCircle_:addPropScaleSolid(1, 0.9, 0.9, kCenterDrawing)

	local params = {sequence = 2,time = 0.2,srcX = 0.9,scaleX = 1.3,srcY = 0.9,scaleY = 1.3,needChange = true}
    self.confirmCardsIconCircle_:scaleTo(params)

    local params2 = {sequence = 3,time = 0.2,opacity = 0.1,delay = 0.2}
    self.confirmCardsIconCircle_:fadeOut(params2)

    local params3 = {sequence = 4,time = 0,delay = 0.4,onComplete = function()
        self.confirmCardsIconCircle_:setVisible(false)
        self.confirmCardsIconCircle_:removeAllProp()
    end}
    self.confirmCardsIconCircle_:fadeOut(params3)


	-- self.confirmCardsIconCircle_:runAction(transition.sequence({
	-- 	cc.ScaleTo:create(0.2,1.3),
	-- 	cc.FadeTo:create(0.2,28),
	-- 	cc.DelayTime:create(0.2),
	-- 	cc.CallFunc:create(function()
	-- 		self.confirmCardsIconCircle_:setVisible(false)
	-- 	end)
	-- }))
end

function ModifyCardIndexAni:showBack()
	self.prepareNode:setVisible(true)
	self.confirmCardsIcon_:setVisible(false)
end

function ModifyCardIndexAni:showFront()
	self.prepareNode:setVisible(false)
	self.confirmCardsIcon_:setVisible(true)
end

function ModifyCardIndexAni:reset()
	-- self.pressNode:setVisible(false)
	self.prepareNode:setVisible(false)
	self.confirmCardsIcon_:setVisible(false)
	self.confirmCardsIconCircle_:setVisible(false)

	-- self.light:removeAllProp()
	self.confirmCardsIconSpin_:removeAllProp()
	self.prepareNode:removeAllProp()
	self.confirmCardsIcon_:removeAllProp()
	self.confirmCardsIconCircle_:removeAllProp()

	-- self.prepareNode:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
	-- self.confirmCardsIcon_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))

	self.isFinishAni = nil
end

function ModifyCardIndexAni:dtor()

end

return ModifyCardIndexAni