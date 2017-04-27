-- hddjDragonflyAnim.lua  蜻蜓动画

HddjDragonflyAnim = class()

local upY = 25

function HddjDragonflyAnim:ctor(container, startPos, endPos)
	self.container = container
	self.startPos = startPos
	self.endPos = endPos
end

function HddjDragonflyAnim:play(animCallback)
	self:stopAnim()

	self.animCallback = animCallback
	self.animNode = new(Node)

	self.animNode:setPos(self.startPos.x,self.startPos.y)

	if self.container then
		self.animNode:addTo(self.container)
	else
		self.animNode:addToRoot()
	end

	if nk.SoundManager then
		nk.SoundManager:playHddjSound(18)
	end

	self:playAppear()
end

function HddjDragonflyAnim:playAppear()
	local angle = nk.functions.getAngle(self.startPos,self.endPos)
	self.dragonflyList = new(Images, {"res/hddjs/hddj18/hddj18_dragonfly0001.png", "res/hddjs/hddj18/hddj18_dragonfly0002.png"})
	self.dragonflyList:setAlign(kAlignCenter)

	if (angle > 90 and angle < 270) then
		self.dragonflyList:setMirror(false,true);
    end

	self.dragonflyList:addPropRotateSolid(1, angle, kCenterDrawing)
	self.animNode:addChild(self.dragonflyList)

	self.lightAnim = new(AnimDouble, kAnimRepeat, 0, 1, 50, -1)
	self.lightAnim:setDebugName("HddjCakeAnim.self.lightAnim")
    self.lightIndex = new(PropImageIndex, self.lightAnim)
	self.dragonflyList:doAddProp(self.lightIndex, 0)

	self.dragonflyList:fadeIn({time=0.3, delay=0, onComplete = function()
    	end})

	self.schedule1 = Clock.instance():schedule_once(function()
            self:playMove()
    end, 0.3)

end

function HddjDragonflyAnim:playMove()
	if self.animNode then
		self.animNode:stopAllActions()
	end
	self.animNode:moveTo({time = 1, x = self.endPos.x, y= self.endPos.y - upY, onComplete=function()
				self.dragonflyList:doRemoveProp(0)
				self.dragonflyList:doRemoveProp(1)
	            self.dragonflyList:removeFromParent(true)
	            self:playCircle()
	        end})
end

function HddjDragonflyAnim:playCircle()
	self.circle_node = new(Node)
	self.circle_node:setAlign(kAlignCenter)
	self.circle_node:setPos(0,upY)
	self.animNode:addChild(self.circle_node)

	local circle_bg = new(Image, "res/hddjs/hddj18/hddj18_dragonfly_light.png")
	
	circle_bg:setAlign(kAlignCenter)
	if nk.roomSceneType == "gaple" then
		circle_bg:setSize(121,121)
		circle_bg = Mask.setMask(circle_bg, kImageMap.common_head_mask_big)
	else
		circle_bg:setSize(83,83)
		circle_bg = Mask.setMask(circle_bg, kImageMap.qiuqiu_seat_head_mask)
	end
	self.circle_node:addChild(circle_bg)

	local num = 17
	local imagesList = self:createImagesList(num)

	self.dragonflyCircleList = new(Images, imagesList)
	self.dragonflyCircleList:setAlign(kAlignCenter)

	self.animNode:addChild(self.dragonflyCircleList)

	local time = 1700
	self.clrcleAnim = new(AnimDouble, kAnimNormal, 0, num - 1, time, -1)
	self.clrcleAnim:setDebugName("HddjDragonflyAnim.self.clrcleAnim")
    self.circleIndex = new(PropImageIndex, self.clrcleAnim)
	self.dragonflyCircleList:doAddProp(self.circleIndex, 0)

	self.schedule2 = Clock.instance():schedule_once(function()
		Log.printInfo("HddjDragonflyAnim:playCircle done");
		self.dragonflyCircleList:doRemoveProp(0)
		self.dragonflyCircleList:removeFromParent(true)
		self.circle_node:removeFromParent(true)
		if self.clrcleAnim then
			delete(self.clrcleAnim)
			self.clrcleAnim = nil
		end
		if self.animCallback then
			self.animCallback()
		end
		self:release()
    end, time/1000)

end

function HddjDragonflyAnim:createImagesList(frameNum)
    local path =  "res/hddjs/hddj18/hddj18_dragonfly_light_%04d.png"
    local list = {}
    for i= 1, frameNum do
        local imageName = string.format(path, i)
        table.insert(list, imageName)
    end
    return list
end

function HddjDragonflyAnim:stopAnim()
	if self.schedule1 then
        self.schedule1:cancel()
    end
	if self.schedule2 then
        self.schedule2:cancel()
    end
	if self.dragonflyList then
		self.dragonflyList:doRemoveProp(0)
		self.dragonflyList:doRemoveProp(1)
		self.dragonflyList:stopAllActions()
	end
	if self.dragonflyCircleList then
		self.dragonflyCircleList:doRemoveProp(0)
	end
	if self.clrcleAnim then
		Log.printInfo("HddjDragonflyAnim:stopAnim delete self.clrcleAnim");
		delete(self.clrcleAnim)
		self.clrcleAnim = nil
	end
	if self.animNode then
		self.animNode:stopAllActions()
	end
end

function HddjDragonflyAnim:release()
	self:stopAnim()
	if self.dragonflyList then
		self.dragonflyList:removeFromParent(true)
	end
	if self.dragonflyCircleList then
		self.dragonflyCircleList:removeFromParent(true)
	end
	if self.circle_node then
		self.circle_node:removeFromParent(true)
	end
	if self.animNode then
		self.animNode:removeFromParent(true)
	end
end

return HddjDragonflyAnim