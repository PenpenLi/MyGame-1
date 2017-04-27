
-- VipItemLayer.lua
-- Last modification : 2016-11-03
-- Description: a people item layer in VipItemLayer moudle

local VipItemLayer = class(GameBaseLayer, false)
local view = require(VIEW_PATH .. "store.store_vip_item")
local varConfigPath = VIEW_PATH .. "store.store_vip_item_layout_var"

function VipItemLayer:ctor()
	Log.printInfo("VipItemLayer", "ctor")
    super(self, view, varConfigPath)
    self:setSize(self.m_root:getSize())

    self.icon_ = self:getUI("Image_icon")
    self.text_ = self:getUI("ScrollView_text")
end 

function VipItemLayer:callback()
    self:getUI("Image_logo"):setVisible(false)
end

function VipItemLayer:dtor()
	Log.printInfo("VipItemLayer", "dtor")
end

return VipItemLayer