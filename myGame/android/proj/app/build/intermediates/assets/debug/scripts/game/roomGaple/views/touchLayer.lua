

local TouchLayer=class(Node)


function TouchLayer:ctor(parent)
	parent:addChild(self)
    self:setFillParent(true,true)

    self.touch_bg =  new(Image,"res/common/common_blank.png")
    self:addChild(self.touch_bg)
    self.touch_bg:setFillParent(true,true)

	self:addListener(parent)
end

function TouchLayer:addListener()
	-- self.touch_bg:setEventTouch(self,self.onEventTouch)
	self:setLayerTouchEnabled(true)
end

function TouchLayer:onEventTouch(finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
	if self.player then
		if finger_action == kFingerDown then
			self.beganx = x
			self.begany = y

			self.player_sx, self.player_sy = self.player:getUnalignPos()
			self.player_sx = self.player_sx/System.getLayoutScale()
			self.player_sy = self.player_sy/System.getLayoutScale()

			self.offset_x = self.player_sx - self.beganx
			self.offset_y = self.player_sy - self.begany
	   	elseif finger_action == kFingerMove then
			if self.player then
				x = x + self.offset_x
				y = y + self.offset_y
				self.player:setPos(x,y)
				local moveEnd = false
				EventDispatcher.getInstance():dispatch(EventConstants.checkCardShow, moveEnd)
			end
		elseif finger_action == kFingerUp then
			self.endx = x
			self.endy = y
			if math.abs(self.beganx - self.endx) >= 20 or math.abs(self.begany - self.endy) >= 20 then
				local moveEnd = true
				EventDispatcher.getInstance():dispatch(EventConstants.checkCardShow, moveEnd)
			else
				-- EventDispatcher.getInstance():dispatch(EventConstants.cardMoveBack)
			end
		end
	end
end

function TouchLayer:playerMove(params,tableNode)
	self.player = params
end

function TouchLayer:setLayerTouchEnabled(touchEnable)
	if self.touch_bg then
		self.touch_bg:setPickable(touchEnable)
	end
	self.m_touchEnable = touchEnable
end

function TouchLayer:getLayerTouchEnabled()
	return self.m_touchEnable
end

return TouchLayer
