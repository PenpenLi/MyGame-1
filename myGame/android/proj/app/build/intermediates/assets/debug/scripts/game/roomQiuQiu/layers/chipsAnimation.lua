--
-- Author: Jackie
-- Date: 2015-09-17 16:14:06
--
local ChipsAnimation = class(Node)

-- 向上move的距离
local offsetY = -30
-- 每个单位的宽度
local sizeX = 21

function ChipsAnimation:ctor()
	self:setSize(200, 200)
end

-- args={
-- 	x: 相对于root的x
-- 	y: 相对于root的y
-- 	root: 要添加的父节点
-- }
function ChipsAnimation:play(chips, args)
	if args then
		self:setPos(args.x - 20, args.y)
		if args.root then
			self:addTo(args.root)
		end
	end
	self:play_(chips)
end

function ChipsAnimation:play_(chips)
	local chipsNode = new(Node)
	chipsNode:setFillParent(true, true)
	chipsNode:addTo(self)
	local count = string.len(chips)
	local startPos = -(count - 1) * sizeX * 0.5
	local sprite
	for i = 1, count do
		sprite = self:getSprite_(string.sub(chips, i, i), startPos + (i - 1) * sizeX, 0)
		sprite:addTo(chipsNode)
	end
    self:fadeIn({time = 0.5})

    self:moveTo({time = 0.8, x=0, y=offsetY, delay = 0.3, offset=true})

    self:fadeOut({time = 1, delay = 0.8, onComplete=handler(self, function()
    		self:setVisible(false)
    	end)})
 	
 	nk.GCD.PostDelay(self, function()
 		if not tolua.isnull(self) then
 			self:removeFromParent(true)
 		end 
 	end, nil, 2000, false)
end

function ChipsAnimation:getSprite_(unit, x, y)
	local sprite = new(Image, kImageMap.n_0)
	if unit == "+" then
		unit = "and"
	elseif unit == "-" then
		unit = "delete"
	elseif unit == "." then
		unit = "dot"
	end
	sprite:setFile(kImageMap[("n_" .. unit .. "")])
	sprite:setPos(x, y)
	return sprite
end

return ChipsAnimation