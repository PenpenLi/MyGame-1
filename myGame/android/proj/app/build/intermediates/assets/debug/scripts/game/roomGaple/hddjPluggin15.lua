require("game.uiex.uiexInit")
require("game.anim.transition")

local HddjPluggin15 = class()

local eachImageTime = math.floor(1000/8)

function HddjPluggin15:ctor(container, startPos, endPos)
	self.container = container
	self.startPos = startPos
	self.endPos = endPos
end

function HddjPluggin15:dtor()
	if self.animDelayForGun then
		delete(self.animDelayForGun)
		self.animDelayForGun = nil
	end
end

function HddjPluggin15:play(endFunc)
	local node = new(Node)
	if self.container then
		node:addTo(self.container)
	else
		node:addToRoot()
	end
	self:playGunShoot(node, function()
		self:playBulletFly(node, function ()
			self:playBombBoom(node, endFunc)
		end)
	end)
	if nk.SoundManager then
		nk.SoundManager:playHddjSound(15)
	end
end

function HddjPluggin15:createImagesList(name, frameNum)
    local path =  "res/hddjs/hddj15/hddj15_%s%04d.png"
    local list = {}
    for i= 1, frameNum do
        local imageName = string.format(path, name, i)
        table.insert(list, imageName)
    end
    return list
end

function HddjPluggin15:playGunShoot(node, nextFunc)
	local frameNum = 14
	local imagesList = self:createImagesList("fire", frameNum)
	local drawing = new(Images, imagesList)
	drawing:setAlign(kAlignCenter)
	node:addChild(drawing)

	drawing:addPropTranslateSolid(0, self.startPos.x, self.startPos.y)
	
	-- local arc = math.atan((self.endPos.y - self.startPos.x)/(self.endPos.x - self.startPos.x))
	-- if arc < 0 then arc = arc + math.pi end
	-- local angle = arc / math.pi * 180 + 180
	local angle = nk.functions.getAngle(self.startPos, self.endPos)-- + 180

	local flipY = 1
	-- if angle > 180 then
	-- 	flipY = -1
	-- 	angle = 360 - angle
	-- end
	if angle > 90 and angle < 270 then
       flipY = -1
    else
    	angle = -angle
    end
	FwLog("angle =  " .. angle)
	drawing:addPropRotateSolid(4, angle, kCenterDrawing)
	drawing:setLevel(1)

	local scale = 0.6 
	drawing:addPropScaleSolid(1, -scale, scale * flipY, kCenterDrawing)

	local animIndex = new(AnimInt, kAnimNormal ,0, frameNum - 1, frameNum * eachImageTime)
	animIndex:setDebugName("playHddjAnim.animIndex")
	animIndex:setEvent(nil, function()
		drawing:removeFromParent(true)
	end)
	local propIndex = new(PropImageIndex, animIndex)
	propIndex:setDebugName("playHddjAnim.propIndex")
	drawing:doAddProp(propIndex, 2)

	local anim = new(AnimDouble, kAnimNormal, 0, 1, 1 * eachImageTime, -1)
	self.animDelayForGun = anim
	anim:setEvent(nil, function()
		delete(anim)
		self.animDelayForGun = nil
		if nextFunc then nextFunc() end
	end)
end

function HddjPluggin15:playBulletFly(node, nextFunc)
	local drawing = new(Image, "res/hddjs/hddj15/hddj15_bullet.png")
	node:addChild(drawing)
	drawing:setAlign(kAlignCenter)

	-- local arc = math.atan((self.endPos.y - self.startPos.x)/(self.endPos.x - self.startPos.x))
	-- if arc < 0 then arc = arc + math.pi end
	-- local angle = arc / math.pi * 180 + 180
	local angle = nk.functions.getAngle(self.startPos, self.endPos)-- + 180

	local flipY = 1
	-- if angle > 180 then
	-- 	flipY = -1
	-- 	angle = 360 - angle
	-- end
	if angle > 90 and angle < 270 then
       flipY = -1
    else
    	angle = -angle
    end
	drawing:addPropRotateSolid(4, angle, kCenterDrawing)

	local scale = 0.6 
	drawing:addPropScaleSolid(1, scale * -1, scale * flipY, kCenterDrawing)

	local anim = drawing:addPropTranslate(0, kAnimNormal, 0.5*1000, 0, self.startPos.x, self.endPos.x, self.startPos.y, self.endPos.y)
	anim:setEvent(nil, function()
		drawing:removeFromParent(true)
		if nextFunc then nextFunc() end
	end)
end

function HddjPluggin15:playBombBoom(node, nextFunc)
	local frameNum = 7
	local imagesList = self:createImagesList("explosion", frameNum)
	local drawing = new(Images, imagesList)
	drawing:setAlign(kAlignCenter)
	node:addChild(drawing)

	drawing:addPropTranslateSolid(0, self.endPos.x, self.endPos.y)
	local scale = 0.6
	drawing:addPropScaleSolid(1, scale, scale, kCenterDrawing)

	local animIndex = new(AnimInt, kAnimNormal ,0, frameNum - 1, frameNum * eachImageTime)
	animIndex:setDebugName("playHddjAnim.animIndex")
	local propIndex = new(PropImageIndex, animIndex)
	propIndex:setDebugName("playHddjAnim.propIndex")
	drawing:doAddProp(propIndex, 2)

	animIndex:setEvent(nil, function()
		drawing:removeFromParent(true)
		if endFunc then endFunc() end
	end)
end

return HddjPluggin15