-- hddjShieldAnim.lua  盾牌动画

HddjShieldAnim = class()

local upY = 25

function HddjShieldAnim:ctor(container, startPos, endPos)
	self.container = container
	self.startPos = startPos
	self.endPos = endPos
end

function HddjShieldAnim:play(animCallback)
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
		nk.SoundManager:playHddjSound(19)
	end

	self:playAppear()
end

function HddjShieldAnim:playAppear()
	local rotateTime = 500
	self.shieldIcon = new(Image, "res/hddjs/hddj19/hddj19_shield.png")
	self.shieldIcon:setAlign(kAlignCenter)
	self.animNode:addChild(self.shieldIcon)
	self.shieldIcon:addPropRotate(0, kAnimNormal, rotateTime, 0, 0, 360, kCenterDrawing, 0, 0)
	self.schedule1 = Clock.instance():schedule_once(function()
		self.shieldIcon:removeFromParent(true)
        self:playMove()
    end, rotateTime/1000)
end

function HddjShieldAnim:playMove()
	if self.animNode then
		self.animNode:stopAllActions()
	end

	-- "explosion"
	-- "fire"
	local num = 6
	local imagesList = self:createImagesList("fire",num)  
	self.fireList = new(Images, imagesList)
	self.fireList:setAlign(kAlignCenter)
	self.fireList:setPos(-50,0)
	self.animNode:addChild(self.fireList)

	local angle = nk.functions.getAngle(self.startPos,self.endPos)
	if (angle > 90 and angle < 270) then
		self.fireList:setMirror(false,true);
    end
	self.fireList:addPropRotateSolid(1, angle, kCenterXY, 175, 35)

	self.fireAnim = new(AnimDouble, kAnimRepeat, 0, num - 1, 400, -1)
	self.fireAnim:setDebugName("HddjCakeAnim.self.fireAnim")
    self.fireIndex = new(PropImageIndex, self.fireAnim)
	self.fireList:doAddProp(self.fireIndex, 0)


	self.animNode:moveTo({time = 1.3, x = self.endPos.x, y = self.endPos.y, onComplete=function()
				if self.fireAnim then
					delete(self.fireAnim)
					self.fireAnim = nil
				end
				self.fireList:doRemoveProp(0)
				self.fireList:doRemoveProp(1)
				self.fireList:removeFromParent(true)
				self:playExplosion()
	        end})
end

function HddjShieldAnim:playExplosion()
	self.animNode:setPos(self.endPos.x,self.endPos.y)
	local num = 8
	local time = 550
	local imagesList = self:createImagesList("explosion",num)  
	self.explosionList = new(Images, imagesList)
	self.explosionList:setAlign(kAlignCenter)
	self.animNode:addChild(self.explosionList)

	local angle = nk.functions.getAngle(self.startPos,self.endPos)

	if (angle > 90 and angle < 270) then
		self.explosionList:setMirror(true,false);
		self.explosionList:setPos(20,25)
	else
		self.explosionList:setPos(-20,25)
    end

	self.explosionAnim = new(AnimDouble, kAnimNormal, 0, num - 1, time, -1)
	self.explosionAnim:setDebugName("HddjCakeAnim.self.explosionAnim")
    self.explosionIndex = new(PropImageIndex, self.explosionAnim)
	self.explosionList:doAddProp(self.explosionIndex, 0)

	self.schedule2 = Clock.instance():schedule_once(function()
		self.explosionList:doRemoveProp(0)
		self.explosionList:removeFromParent(true)
        self:release()
        if self.animCallback then
			self.animCallback()
		end
    end, time/1000)
end

function HddjShieldAnim:createImagesList(name,frameNum)
    local path =  "res/hddjs/hddj19/hddj19_shield_%s_%04d.png"
    local list = {}
    for i= 1, frameNum do
        local imageName = string.format(path, name, i)
        table.insert(list, imageName)
    end
    return list
end

function HddjShieldAnim:stopAnim()
	if self.schedule1 then
        self.schedule1:cancel()
    end
    if self.schedule2 then
        self.schedule2:cancel()
    end
    if self.fireList then
		self.fireList:doRemoveProp(0)
		self.fireList:doRemoveProp(1)
		self.fireList:stopAllActions()
	end
	if self.explosionList then
		self.explosionList:doRemoveProp(0)
		self.explosionList:stopAllActions()
	end
    if self.shieldIcon then
    	self.shieldIcon:doRemoveProp(0)
    end
    if self.animNode then
		self.animNode:stopAllActions()
	end
end

function HddjShieldAnim:release()
	self:stopAnim()
	if self.animNode then
		self.animNode:removeFromParent(true)
	end
end

return HddjShieldAnim