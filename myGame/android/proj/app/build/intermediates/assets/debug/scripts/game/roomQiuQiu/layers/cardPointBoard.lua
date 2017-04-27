--
-- Author: Jackie
-- Date: 2015-08-05 18:20:06
-- 牌上边的分数板
local CardPointBoard = class(Node)

function CardPointBoard:ctor()
	self:setSize(200, 43)
	self:addPropScaleSolid(0, 0.8, 0.8, kCenterDrawing)
	-- 分数板背景
	self.cardPointBack_ = new(Image, kImageMap.qiuqiu_card_point_bg)
	self.cardPointBack_:addTo(self)
	
	self.maxPointBorder1_ = new(Image, kImageMap.qiuqiu_card_maxpoint_bg)
	self.maxPointBorder1_:setPos(9, 7)
	self.maxPointBorder1_:addTo(self.cardPointBack_)
	self.maxPointBorder1_:setVisible(false)
	self.maxPointBorder1_:setLevel(1)

	self.maxPointBorder2_ = new(Image, kImageMap.qiuqiu_card_maxpoint_bg)
	self.maxPointBorder2_:setPos(80, 7)
	self.maxPointBorder2_:addTo(self.cardPointBack_)
	self.maxPointBorder2_:setVisible(false)
	self.maxPointBorder2_:setLevel(1)

    self.cardPoint1_ = new(Text, "0", 52, 24, kAlignCenter, "", 24, 200, 200, 255)
    self.cardPoint1_:setPos(11, 8)
    self.cardPoint1_:addTo(self)
    self.cardPoint1_:setLevel(2)

    self.cardPoint2_ = new(Text, "?", 52, 24, kAlignCenter, "", 24, 200, 200, 255)
    self.cardPoint2_:setPos(82, 8)
    self.cardPoint2_:addTo(self)
    self.cardPoint2_:setLevel(2)

    -- 特殊牌型样式
    self.cardLight_ = new(Image, kImageMap.qiuqiu_yellow_light)
    self.cardLight_:setAlign(kAlignCenter)
    self.cardLight_:addTo(self)
    self.cardLight_:setPos(-30,0)

    self.cardSpecal_ = new(Image, kImageMap.qiuqiu_card_mode_1)
    self.cardSpecal_:setAlign(kAlignCenter)
    self.cardSpecal_:addTo(self)
    self.cardSpecal_:setPos(-30,0)

end

function CardPointBoard:setPoint(point1, point2)
	self.cardPointBack_:setVisible(true)
	self.cardPoint1_:setVisible(true)
	self.cardPoint2_:setVisible(true)
	self.cardPoint1_:setColor(200,200,255)
	self.cardPoint1_:setText(point1)
	self.cardPoint2_:setColor(200,200,255)	
	self.cardPoint2_:setText(point2)
	self.maxPointBorder1_:setVisible(false)
	self.maxPointBorder2_:setVisible(false)
	--Log.dump(point1,">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> point1")
	if checkint(point1) == 9 then
		self.maxPointBorder1_:setVisible(true)
		self.cardPoint1_:setColor(255,255,0)
	end
	if checkint(point2) == 9 then
		self.maxPointBorder2_:setVisible(true)
		self.cardPoint2_:setColor(255,255,0)
	end

	self.cardLight_:setVisible(false)
	self.cardLight_:removeAllProp()

	self.cardSpecal_:setVisible(false)

	-- 动画
	self:removeAnimByS(1)
	local params2 = {sequence = 1,time = 0.1,srcX = 1.2,scaleX = 1,srcY = 1.2,scaleY = 1,needChange = false}
	local params = {sequence = 1,time = 0.1,srcX = 0.8,scaleX = 1.2,srcY = 0.8,scaleY = 1.2,needChange = false,onComplete = function()
        	self:scaleTo(params2)
        end}
    self:scaleTo(params)
end

--特殊处理特殊牌型
function CardPointBoard:setSpecialCard(mode)
	if mode > 0 and mode < 6 then
		self.cardPointBack_:setVisible(false)
		self.maxPointBorder1_:setVisible(false)
		self.maxPointBorder2_:setVisible(false)
		self.cardPoint1_:setVisible(false)
		self.cardPoint2_:setVisible(false)

		self.cardLight_:setVisible(true)
		self.cardLight_:removeAllProp()
		--sequence, animType, duration, delay, startValue, endValue, center, x, y
		self.cardLight_:addPropRotate(0, kAnimRepeat, 4000, 0, 0, 360, kCenterDrawing, 0, 0)
		
		self.cardSpecal_:setVisible(true)
        self.cardSpecal_:setFile(kImageMap["qiuqiu_card_mode_"..mode])
	end
end

function CardPointBoard:setFade(isDark)
	if isDark then 
		self.cardPointBack_:setFile(kImageMap.qiuqiu_card_point_bg2)
		self.cardPoint1_:setColor(155,155,155)
		self.cardPoint2_:setColor(155,155,155)

		self.maxPointBorder1_:setVisible(false)
		self.maxPointBorder2_:setVisible(false)
	else
		self.cardPointBack_:setFile(kImageMap.qiuqiu_card_point_bg)
		self.cardPoint1_:setColor(200,200,255)
		self.cardPoint2_:setColor(200,200,255)
		local point1,point2 = self.cardPoint1_:getText(),self.cardPoint2_:getText()
		if checkint(point1) == 9 then
			self.cardPoint1_:setColor(255,255,0)
		end
		if checkint(point2) == 9 then
			self.cardPoint2_:setColor(255,255,0)
		end
	end
end


function CardPointBoard:reset()
	self:setPoint("?", "?")
	--self:setFade(false)
end

return CardPointBoard