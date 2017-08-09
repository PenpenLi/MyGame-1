
local ExpressionsItem = class(Node)

function ExpressionsItem:ctor(startId,index,scale)
	self.m_id = startId + index

	local item_w, item_h = 100, 100

	self:setSize(item_w, item_h)

	self.m_expBtn = new(Button,"res/common/common_blank.png")
	self.m_expBtn:setSize(item_w, item_h)
	self:addChild(self.m_expBtn)
	self.m_expBtn:setSrollOnClick()
	self.m_expBtn:setOnClick(self, self.onExpClicked)

	local file = string.format("res/roomChat/exp/expression_%d.png",self.m_id)
	self.m_exp = new(Image,file)
	self.m_exp:setAlign(kAlignCenter)
	self.m_exp:addPropScaleSolid(0, scale, scale, kCenterDrawing)
	self:addChild(self.m_exp)
end

function ExpressionsItem:setDelege(obj,fun)
	self.m_delegeObj = obj
	self.m_delegeFun = fun
end

function ExpressionsItem:onExpClicked()
	if self.m_delegeObj and self.m_delegeFun then
		self.m_delegeFun(self.m_delegeObj,self.m_id)
	end
end

function ExpressionsItem:dtor()
	if self.m_exp then
		self.m_exp:doRemoveProp(0)
	end
end


return ExpressionsItem