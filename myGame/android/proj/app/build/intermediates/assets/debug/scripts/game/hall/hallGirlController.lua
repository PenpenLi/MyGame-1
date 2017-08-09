local HallGirlController = class()

function HallGirlController:ctor(spriteGirl)
	self.spriteGirl = spriteGirl
	self.spriteGirl:setEventTouch(self, self.onEventTouch)
	self.xOfSpGirl, self.yOfSpGirl = spriteGirl:getAbsolutePos()
	self.rectHeadZone = {x = 140, y = 23, width = 123, height = 158}
	self.rectBodyZone = {x = 90, y = 180, width = 232, height = 407}
	self.rectBreastZone = {x = 113, y = 231, width = 156, height = 100}
	self.rectHipZone = {x = 240, y = 430, width = 74, height = 150}
	self:initMsgLib()
	self:startLoop()
end

function HallGirlController:dtor( ... )
	self:stopLoop()
end

function HallGirlController:stopLoop()
	if self.delayId then
		nk.GCD.CancelById(self, self.delayId)
		self.delayId = nil
	end
	if self.delayIdLoop then 
		nk.GCD.CancelById(self, self.delayIdLoop) 
		self.delayIdLoop = nil
	end
end

function HallGirlController:startLoop()
	self.delayIdLoop = nk.GCD.PostDelay(self, self.runLoop, nil, 3000)
end

function HallGirlController:initMsgLib()
	self.msgLib = {
		rookie = bm.LangUtil.getText("HALL", "GIRL_ROOKIE"), --lv = 1
		common = bm.LangUtil.getText("HALL", "GIRL_COMMON"),
		touchForRookie = bm.LangUtil.getText("HALL", "GIRL_TOUCHFORROOKIE"),
		touch = bm.LangUtil.getText("HALL", "GIRL_TOUCH"),
		privateArea = bm.LangUtil.getText("HALL", "GIRL_PRIVATEAREA"),
	}
end

function HallGirlController:onEventTouch(finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
	if finger_action == kFingerDown then
		local touchX = x - self.xOfSpGirl
		local touchY = y - self.yOfSpGirl
		-- FwLog("HallGirlController:onEventTouch >>" .. touchX .. "," .. touchY)
		local p = {x = touchX, y = touchY}
		if self.RectContainsPoint(self.rectHeadZone, p)  then
			self:onNormalTouch()
			-- FwLog("HallGirlController touch head")
			-- self:talk("HallGirlController touch head！！！！！！！！！！！！！！！！！！！！！！！！！！")
		elseif self.RectContainsPoint(self.rectBodyZone, p)  then
			-- FwLog("HallGirlController touch body")
			if self.RectContainsPoint(self.rectBreastZone, p) then 
				self:onPrivateTouch()
				nk.AnalyticsManager:report("New_Gaple_touch_hall_girl_breast")
			elseif self.RectContainsPoint(self.rectHipZone, p) then
				-- self:talk("HallGirlController touch breast！！！！")
				self:onPrivateTouch()
				nk.AnalyticsManager:report("New_Gaple_touch_hall_girl_hip")
			else
				-- self:talk("HallGirlController touch body！！！！")
				self:onNormalTouch()
			end
		end
	end
end

function HallGirlController:onNormalTouch()
	local msgs = self.msgLib.touch
	if nk.userData.mlevel < 5 then
		msgs = self.msgLib.touchForRookie
	end
	self.loopTouchIndex = self.loopTouchIndex or 0
	self.loopTouchIndex = self.loopTouchIndex % #msgs
	msg = bm.LangUtil.formatString(msgs[self.loopTouchIndex + 1], nk.userData.name)
	self.loopTouchIndex = self.loopTouchIndex + 1
	self:talk(msg)
	nk.AnalyticsManager:report("New_Gaple_touch_hall_girl")
    nk.DataCenterManager:report("touch_girl")
end

function HallGirlController:onPrivateTouch()
	local msgs = self.msgLib.touch
	if nk.userData.mlevel < 5 then
		msgs = self.msgLib.privateArea
	end
	self.loopTouchPrivateIndex = self.loopTouchPrivateIndex or 0
	self.loopTouchPrivateIndex = self.loopTouchPrivateIndex % #msgs
	msg = bm.LangUtil.formatString(msgs[self.loopTouchPrivateIndex + 1], nk.userData.name)
	self.loopTouchPrivateIndex = self.loopTouchPrivateIndex + 1
	self:talk(msg)
	nk.AnalyticsManager:report("New_Gaple_touch_hall_girl")
end

-- girl talk 接口
function HallGirlController:talk(msg, notForce)
	if notForce and self.msg then 
		self.waitingList = self.waitingList or {}
		table.insert(self.waitingList, msg)
	else
		self.msg = msg
		self:refreshTalkView()
	end
end

function HallGirlController:refreshTalkView()
	local msg = self.msg
	if self.delayId then nk.GCD.CancelById(self, self.delayId) end
	if self.delayIdLoop then nk.GCD.CancelById(self, self.delayIdLoop) end
	if msg ~= "" then
		local bubbleBg = self.bubbleBg
		if not bubbleBg then
			bubbleBg = new(Node)
			local img = new(Image, kImageMap.msg_bubble, nil, nil, 60, 60, 25, 40)
			img:addTo(bubbleBg)
			img:addPropScaleSolid(1, -1, 1)
			img:setName("bubbleBgImg")
			img:setPos(180, 0)
			bubbleBg:addTo(self.spriteGirl:getParent())
			-- bubbleBg:addToRoot()
			bubbleBg:setAlign(kAlignCenter)
			-- bubbleBg:setAlign(kAlignBottomRight)
			bubbleBg:setPos(150, -200)
			self.bubbleBg = bubbleBg
		end
		local text = self.text
		if not text then
			text = new(TextView, msg, 160, nil, kAlignCenter, nil, 20, 255, 255, 255)
			text:addTo(self.bubbleBg)
			text:setAlign(kAlignCenter)
			text:setPos(0, -4)
			self.text = text
		else
			text:setText(msg, w, 0)
			local h = text:getViewLength()
			text:setText(msg, w, h)
		end
		local w, h = text:getSize()
		w, h = math.max(w + 20, 152), math.max(74, h + 30)
		bubbleBg:getChildByName("bubbleBgImg"):setSize(w, h)
		bubbleBg:setSize(w, h)
		bubbleBg:setVisible(true)
	else
		local bubbleBg = self.bubbleBg
		if bubbleBg then bubbleBg:setVisible(false) end
	end
	self.delayId = nk.GCD.PostDelay(self, self.showOver, nil, 4000)
end

function HallGirlController.RectContainsPoint( rect, point )
    local ret = false
    if (point.x >= rect.x) and (point.x <= rect.x + rect.width) and
       (point.y >= rect.y) and (point.y <= rect.y + rect.height) then
        ret = true
    end
    return ret
end

-- 每隔一段时间说一句话
function HallGirlController:runLoop()
	self.delayIdLoop = nil
	local msg = nil
	if self.waitingList and #self.waitingList > 0 then
		msg = table.remove(self.waitingList, 1)
	end
	if msg == nil then 
		if nk.PopupManager:hasPopup() then
			msg = ""
		else
			if nk.userData.mlevel == 1 then
				msg = self.msgLib.rookie
			else
				self.loopIndex = self.loopIndex or 0
				self.loopIndex = self.loopIndex % #self.msgLib.common
				msg = bm.LangUtil.formatString(self.msgLib.common[self.loopIndex + 1], nk.userData.name)
				self.loopIndex = self.loopIndex + 1
			end
		end
	end
	self:talk(msg)
end

function HallGirlController:showOver()
	if self.bubbleBg then
		self.bubbleBg:setVisible(false)
	end
	self.msg = nil
	self.delayIdLoop = nk.GCD.PostDelay(self, self.runLoop, nil, 5000)
end

function HallGirlController.TriangleContainsPoint(triangle, P)
	local A = triangle.A
	local B = triangle.B
	local C = triangle.C
    local v0 = {x = C.x - A.x, y = C.y - A.y}--C - A
    local v1 = {x = B.x - A.x, y = B.y - A.y}--B - A
    local v2 = {x = P.x - A.x, y = P.y - A.y}--P - A
    local dot00 = v0.x * v0.x + v0.y + v0.y--v0.Dot(v0) ;
    local dot01 = v0.x * v1.x + v0.y + v1.y--v0.Dot(v1) ;
    local dot02 = v0.x * v2.x + v0.y + v2.y--v0.Dot(v2) ;
    local dot11 = v1.x * v1.x + v1.y + v1.y--v1.Dot(v1) ;
    local dot12 = v1.x * v2.x + v1.y + v2.y--v1.Dot(v2) ;
    local inverDeno = 1 / (dot00 * dot11 - dot01 * dot01)
    local u = (dot11 * dot02 - dot01 * dot12) * inverDeno
    if (u < 0 or u > 1) then--// if u out of range, return directly
        return false
    end
    local v = (dot00 * dot12 - dot01 * dot02) * inverDeno
    if (v < 0 or v > 1) then --// if v out of range, return directly
        return false
    end
    return u + v <= 1
end

return HallGirlController


-- local text = self.text
-- if not text then
-- 	text = new(Text, msg, 200, 0, kAlignCenter,"", 20, 255, 255, 255)
-- 	text:addTo(self.bubbleBg)
-- 	self.text = text
-- 	text:setAlign(kAlignCenter)
-- 	text:setPos(0, -4)
-- else
-- 	text:setText(msg)
-- end
-- local w, h = text:getSize()

-- local label = self.label
-- if not self.label then
-- 	label = Label()
-- 	bubbleBg:getWidget():add(label)
-- 	self.label = label
-- end
-- label:set_simple_text(msg)
-- local w, h = 10,10
