-- hddjCakeAnim.lua  蛋糕动画

HddjCakeAnim = class()

local upY = 25

function HddjCakeAnim:ctor(container, startPos, endPos)
	self.container = container
	self.startPos = startPos
	self.endPos = endPos
end

function HddjCakeAnim:play(animCallback)
	self:stopAnim()

	self.animCallback = animCallback
	self.animNode = new(Node)

	self.animNode:setPos(self.startPos.x,self.startPos.y + upY)

	if self.container then
		self.animNode:addTo(self.container)
	else
		self.animNode:addToRoot()
	end

	if nk.SoundManager then
		nk.SoundManager:playHddjSound(17)
	end

	self:playAppear()
end

function HddjCakeAnim:playAppear()
	if self.cakeIcon then
		self.cakeIcon:stopAllActions()
	end

	self.cakeIcon = new(Image,"res/hddjs/hddj17/hddj17_cake_0001.png")
    self.cakeIcon:setAlign(kAlignCenter)
    self.cakeIcon:setTransparency(0)
    self.animNode:addChild(self.cakeIcon)

    self.cakeIcon:fadeIn({time=0.2, delay=0, onComplete = function()
	        self:playLight()
    	end})

end

function HddjCakeAnim:playLight()
	self.lightNode = new(Node)
	self.lightNode:setAlign(kAlignTop)
	self.lightNode:setPos(-6,6)
	self.cakeIcon:addChild(self.lightNode)


	if self.light_circle then
		self.light_circle:doRemoveProp(0)
	end
	if self.fireList then
		self.fireList:doRemoveProp(0)
	end

	self.light_circle = new(Image, "res/hddjs/hddj17/hddj17_light_0001.png")
	self.light_circle:setAlign(kAlignCenter)
	self.light_circle:setPos(6,-6)
	self.lightNode:addChild(self.light_circle)

    self.lightScaleAnim = new(AnimDouble, kAnimLoop, 1, 1.2, 150, -1)
    self.lightScaleProp = new(PropScale, self.lightScaleAnim, self.lightScaleAnim, kCenterDrawing)
	self.light_circle:doAddProp(self.lightScaleProp, 0)

	self.lightScaleHandle_ = nk.GCD.PostDelay(self, function(obj)
		if not nk.updateFunctions.checkIsNull(obj) then
            self.light_circle:doRemoveProp(0)
    		self.light_circle:removeFromParent(true)
    		if self.lightScaleAnim then
    			delete(self.lightScaleAnim)
    			self.lightScaleAnim = nil
    		end
        end 
    end, nil, 800)


	local frameNum = 5
	local imagesList = self:createImagesList("fire", frameNum)
	self.fireList = new(Images, imagesList)
	self.fireList:setAlign(kAlignBottomLeft)
	self.lightNode:addChild(self.fireList)

	local time = 1000
	self.fireAnimIndex = new(AnimInt, kAnimNormal ,0, frameNum - 1, time)
	self.fireAnimIndex:setDebugName("HddjCakeAnim.self.fireAnimIndex")
	self.firePropIndex = new(PropImageIndex, self.fireAnimIndex)
	self.firePropIndex:setDebugName("HddjCakeAnim.self.firePropIndex")
	self.fireList:doAddProp(self.firePropIndex, 0)

	self.schedule1 = Clock.instance():schedule_once(function()
			if self.fireAnimIndex then
				delete(self.fireAnimIndex)
				self.fireAnimIndex = nil
			end
			self.fireList:doRemoveProp(0)
			self.fireList:removeFromParent(true)
			self.cakeIcon:moveTo({time = 0.2, y=-upY, onComplete=function()
	            	self:playMove()
		        end})
	    end, time/1000)
end

function HddjCakeAnim:playMove()
	if self.animNode then
		self.animNode:stopAllActions()
	end
	self.animNode:moveTo({time = 1, x = self.endPos.x, y= self.endPos.y, onComplete=function()
	            self.cakeIcon:removeFromParent(true)
	            self:playOffal()
	        end})
end

function HddjCakeAnim:playOffal()
	self.animNode:setPos(self.endPos.x,self.endPos.y)

	if self.cakeList then
		self.cakeList:doRemoveProp(0)
	end

	if self.cakeDropList then
		self.cakeDropList:doRemoveProp(0)
	end

	local frameNum = 2
	local caketime = 200
	local imagesList = self:createImagesList("cake", frameNum)
	self.cakeList = new(Images, imagesList)
	self.cakeList:setAlign(kAlignCenter)
	self.animNode:addChild(self.cakeList)

	self.cakeAnimIndex = new(AnimInt, kAnimNormal ,0, frameNum - 1, caketime)
	self.cakeAnimIndex:setDebugName("HddjCakeAnim.self.cakeAnimIndex")
	self.cakePropIndex = new(PropImageIndex, self.cakeAnimIndex)
	self.cakePropIndex:setDebugName("HddjCakeAnim.self.cakePropIndex")
	self.cakeList:doAddProp(self.cakePropIndex, 0)

	self.cakeIcon3, self.cakeIcon4 = nil, nil

	self.cakeAnimIndex:setEvent(nil, function()
		self.cakeList:removeFromParent(true)

		self.cakeIcon3 = new(Image,"res/hddjs/hddj17/hddj17_cake_0003.png")
	    self.cakeIcon3:setAlign(kAlignCenter)
	    self.animNode:addChild(self.cakeIcon3)
	    self.cakeIcon3:setLevel(5)

	    self.cakeIconHandle_ = nk.GCD.PostDelay(self, function(obj)
	    	self.cakeIcon3:fadeOut({time=0.5, delay=0, onComplete = function()
				self.cakeIcon3:removeFromParent(true)
	    	end})
	    end, nil, 500)

	    self.cakeIcon4 = new(Image,"res/hddjs/hddj17/hddj17_cake_0004.png")
	    self.cakeIcon4:setAlign(kAlignCenter)
	    self.animNode:addChild(self.cakeIcon4)
	    self.cakeIcon3:setLevel(4)
	end)


	self.cakeDropHandle_ = nk.GCD.PostDelay(self, function(obj)
		local frameNum_drop = 8
		imagesList = self:createImagesList("drop", frameNum_drop)
		self.cakeDropList = new(Images, imagesList)
		self.cakeDropList:setAlign(kAlignCenter)
		self.cakeDropList:setPos(0,40)
		self.animNode:addChild(self.cakeDropList)
		self.cakeDropList:setLevel(-1)

		local time = 2500
		self.cakeDropAnimIndex2 = new(AnimInt, kAnimNormal ,0, frameNum_drop - 1, time)
		self.cakeDropAnimIndex2:setDebugName("HddjCakeAnim.self.cakeDropAnimIndex2")
		self.cakeDropPropIndex = new(PropImageIndex, self.cakeDropAnimIndex2)
		self.cakeDropPropIndex:setDebugName("HddjCakeAnim.self.cakeDropPropIndex")
		self.cakeDropList:doAddProp(self.cakeDropPropIndex, 0)

		self.schedule2 = Clock.instance():schedule_once(function()
			if self.cakeDropAnimIndex2 then
				delete(self.cakeDropAnimIndex2)
				self.cakeDropAnimIndex2 = nil
			end
			self.animNode:fadeOut({time=0.5, delay=0, onComplete = function()
				self.cakeDropList:removeFromParent(true)
				self.animNode:removeFromParent(true)
				if self.animCallback then
					self.animCallback()
				end
				self:release()
	    	end})
	    end, time/1000)
    end, nil, caketime)

end

function HddjCakeAnim:createImagesList(name, frameNum)
    local path =  "res/hddjs/hddj17/hddj17_%s_%04d.png"
    local list = {}
    for i= 1, frameNum do
        local imageName = string.format(path, name, i)
        table.insert(list, imageName)
    end
    return list
end

function HddjCakeAnim:stopAnim()
	if self.schedule1 then
        self.schedule1:cancel()
    end
	if self.schedule2 then
        self.schedule2:cancel()
    end
	if self.cakeIcon then
		self.cakeIcon:stopAllActions()
	end
	if self.light_circle then
		self.light_circle:doRemoveProp(0)
	end
	if self.lightScaleAnim then
		delete(self.lightScaleAnim)
		self.lightScaleAnim = nil
	end
	if self.fireList then
		self.fireList:doRemoveProp(0)
	end
	if self.cakeList then
		self.cakeList:doRemoveProp(0)
	end
	if self.cakeDropList then
		self.cakeDropList:doRemoveProp(0)
	end
	if self.animNode then
		self.animNode:stopAllActions()
	end
	if self.dotsSchedulerHandle_ then
        nk.GCD.CancelById(self, self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
    if self.cakeDropHandle_ then
    	nk.GCD.CancelById(self, self.cakeDropHandle_)
        self.cakeDropHandle_ = nil
    end
    if self.cakeIconHandle_ then
    	nk.GCD.CancelById(self, self.cakeIconHandle_)
        self.cakeIconHandle_ = nil
    end
end

function HddjCakeAnim:release()
	self:stopAnim()
	if self.cakeIcon then
		self.cakeIcon:removeFromParent(true)
	end
	if self.lightNode then
		self.lightNode:removeFromParent(true)
	end
	if self.lightScaleAnim then
		delete(self.lightScaleAnim)
		self.lightScaleAnim = nil
	end
	if self.cakeList then
		self.cakeList:removeFromParent(true)
	end
	if self.cakeDropList then
		self.cakeDropList:removeFromParent(true)
	end
	if self.cakeIcon3 then
		delete(self.cakeIcon3)
		self.cakeIcon3 = nil
	end
	if self.cakeIcon4 then
		delete(self.cakeIcon4)
		self.cakeIcon4 = nil
	end
	if self.animNode then
		self.animNode:removeFromParent(true)
	end
end

return HddjCakeAnim