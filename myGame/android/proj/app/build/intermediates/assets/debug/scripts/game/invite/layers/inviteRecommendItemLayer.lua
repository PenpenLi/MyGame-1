-- friendRecommendItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a people item layer in friend moudle

local FriendRecommendItemLayer = class(GameBaseLayer, false)
local itemView = require(VIEW_PATH .. "friend.friend_recommend_item_layer")
local varConfigPath = VIEW_PATH .. "friend.friend_recommend_item_layer_layout_var"
local AL = require('byui/autolayout')

function FriendRecommendItemLayer:ctor()
	Log.printInfo("FriendRecommendItemLayer.ctor");
    super(self, itemView);
	self:declareLayoutVar(varConfigPath)
    self.size_hint = self.m_root.size
    self.size = self.m_root.size
    -- 头像
    self.m_headImage = self:getControl(self.s_controls["headImage"])
	-- 名字
	self.m_nameLabel = self:getControl(self.s_controls["nameLabel"])
	-- 金币
	self.m_moneyLabel = self:getControl(self.s_controls["moneyLabel"])
	-- 添加好友btn
	self.m_addButton = self:getControl(self.s_controls["addButton"])
	-- 弹详细信息弹窗btn
	self.m_detailButton = self:getControl(self.s_controls["detailButton"])
end 

function FriendRecommendItemLayer:dtor()
	Log.printInfo("FriendRecommendItemLayer.dtor");
end

return FriendRecommendItemLayer