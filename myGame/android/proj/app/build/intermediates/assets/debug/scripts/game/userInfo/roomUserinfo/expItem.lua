
local ExpItem = class(Node)

function ExpItem:ctor(exp)
    self.count = exp.count
    self.id = exp.expId
    self:initView()
end

function ExpItem:initView()
	local btn = new(Button,"res/userInfo/userInfo_prop_expression_bg.png")

	local item_w, item_h = btn:getSize()
	self:setSize(item_w, item_h)

    btn:setOnClick(self, self.onPropClick)
    btn:setSrollOnClick()

    local propIcon = nil 
    local scale = 1

    -- local textNum = new(Text, self.count or 0, 0, 0, kAlignLeft, nil, 24, 255, 255, 255)
    -- btn:addChild(textNum)

    local file = string.format("res/roomChat/exp/expression_%d.png",self.id)
    propIcon = new(Image,file)

    if propIcon then
        propIcon:setAlign(kAlignCenter)
        btn:addChild(propIcon)
        propIcon:addPropScaleSolid(0, scale, scale, kCenterDrawing);
    end

    self:addChild(btn)
end

function ExpItem:setDelegate(obj, fun)
	self.delegate_obj = obj
	self.delegate_fun = fun
end

function ExpItem:onPropClick()
	if self.delegate_obj and self.delegate_fun then
		self.delegate_fun(self.delegate_obj, self.id)
	end
end

return ExpItem