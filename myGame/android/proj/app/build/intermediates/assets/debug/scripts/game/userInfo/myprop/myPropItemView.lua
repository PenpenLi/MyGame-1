local PropManager = require("game.store.prop.propManager")
--private functions


local MyPropItemView = class(Node)

function MyPropItemView:ctor(data)
	local image = new(Image, kImageMap.userInfo_propItem_bg)
	image:addTo(self)
	self.imageBg = image
	self:setSize(image:getSize())
	nk.functions.registerImageTouchFunc(image, self, self.onTouchHandler)
	self:setData(data)
end

function MyPropItemView:dtor()
	
end

function MyPropItemView:setData(data)
	self.data = data
	local image = self.imageBg
	if checkint(data.pcid) > 0 then
		local deco = new(Image, kImageMap.userInfo_propItem_deco)
		deco:addTo(image)
		deco:setAlign(kAlignCenter)
		deco:addPropScaleSolid(0, 0.7, 0.7, kCenterDrawing)
		local icon = nk.functions.addPropIconTo(image, data, 90, self) -- self会获得config属性
		local scale = 0.9
		icon:addPropScaleSolid(0, scale, scale, kCenterDrawing)
		local count = data.pcnter
		if count then
			local label = new(Text, "x" .. count, nil, nil, kAlignLeft, "", 20, 255, 255, 255)
			label:addTo(image)
			label:setAlign(kAlignBottomRight)
			label:setPos(7, 3)
		end
	else
		local iconPath
		local scale = 1
		if data.pcid == -1 then
			iconPath = kImageMap.userInfo_propItem_exchange
		else
			iconPath = kImageMap.userInfo_coming_add_big
			scale = 0.8
		end
		local icon = new(Image, iconPath)
		icon:addTo(image)
		icon:setAlign(kAlignCenter)
		if scale ~= 1 then
			icon:addPropScaleSolid(0, scale, scale, kCenterDrawing)
		end
		if data.title then
			local label = new(Text, data.title, nil, nil, kAlignCenter, "", 22, 255, 255, 255)
			label:addTo(image)
			label:setAlign(kAlignBottom)
			label:setPos(0, 10)
			icon:setPos(0, -10)
		end
	end
end

function MyPropItemView:setTouchDelegate(delegate, delegateFunc)
	self.delegate = delegate
	self.delegateFunc = delegateFunc
end

function MyPropItemView:onTouchHandler()
	if self.delegateFunc then
		self.delegateFunc(self.delegate, self)
	end
end

return MyPropItemView