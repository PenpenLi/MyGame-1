
local LoadingAnim = class()

function LoadingAnim:ctor()
	
end

function LoadingAnim:addLoading(view)
	self.loading_node = new(Node)
	self.loading_node:setAlign(kAlignCenter)
	self.loading_node:setPos(0,-30)

	self.loading_icon = new(Image,"res/common/common_loading_icon.png")
	self.loading_icon:setAlign(kAlignCenter)

	self.loading_tips = new(Text,bm.LangUtil.getText("NEWESTACT", "LOADING"), 200, 40, kAlignCenter, nil, 24, 255, 255, 255)
	self.loading_node:addChild(self.loading_tips)
	self.loading_tips:setAlign(kAlignCenter)
	self.loading_tips:setPos(0,60)
	self.loading_node:addChild(self.loading_icon)

	self.view = view
	self.view:addChild(self.loading_node)
	self.loading_node:setVisible(false)
end

function LoadingAnim:onLoadingStart()
	self:onLoadingRelease();

	self.loading_node:setVisible(true)
	self.animLoading = new(AnimDouble,kAnimRepeat,0,360,1000,-1)
	self.propLoading = new(PropRotate,self.animLoading, kCenterDrawing)
	self.loading_icon:doAddProp(self.propLoading, 1)

end

function LoadingAnim:onLoadingRelease()
	
	self.loading_icon:doRemoveProp(1)
	-- delete(self.animLoading)
	-- self.animLoading = nil
	-- delete(self.propLoading)
	-- self.propLoading = nil

	self.loading_node:setVisible(false)
end

return LoadingAnim
