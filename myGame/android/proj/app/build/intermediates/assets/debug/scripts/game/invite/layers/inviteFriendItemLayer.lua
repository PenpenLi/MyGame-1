-- inviteFriendItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a item layer in invite moudle

local InviteFriendItemLayer = class(GameBaseLayer, false)
local itemView = require(VIEW_PATH .. "invite.invite_friend_item_layer")
local varConfigPath = VIEW_PATH .. "invite.invite_friend_item_layer_layout_var"

InviteFriendItemLayer.checkChanged = EventDispatcher.getInstance():getUserEvent();

function InviteFriendItemLayer:ctor()
	Log.printInfo("InviteFriendItemLayer.ctor");
    super(self, itemView, varConfigPath)
    local w, h = self.m_root:getSize()
    self:setSize(w, h)
    -- 头像
    self.m_headImage = self:getUI("headImage")
    -- 用户头像剪裁
    self.m_headImage = Mask.setMask(self.m_headImage, kImageMap.common_head_mask_min)
	-- 名字
	self.m_nameLabel = self:getUI("nameLabel")
	-- 金币
	self.m_moneyLabel = self:getUI("moneyLabel")
	-- 选中状态勾
	self.m_checkImage = self:getUI("checkImage")
	-- 整个按钮
    self.m_itemButton = self:getUI("itemButton")
    self.m_vipk = self:getUI("Vipk")
	self.m_sexIcon = self:getUI("SexIcon")
	self.m_itemButton:setSrollOnClick()
end 

function InviteFriendItemLayer:setCheck(status)
	self.m_checkImage:setVisible(status)
end

function InviteFriendItemLayer:onItemButtonClick()
	Log.printInfo("InviteFriendItemLayer.onItemButtonClick");
	if self.m_checkImage:getVisible() then
		self.m_checkImage:setVisible(false)
		EventDispatcher.getInstance():dispatch(InviteFriendItemLayer.checkChanged)
	else
		self.m_checkImage:setVisible(true)
		EventDispatcher.getInstance():dispatch(InviteFriendItemLayer.checkChanged)
	end
end

function InviteFriendItemLayer:dtor()
	Log.printInfo("InviteFriendItemLayer.dtor");
end

return InviteFriendItemLayer