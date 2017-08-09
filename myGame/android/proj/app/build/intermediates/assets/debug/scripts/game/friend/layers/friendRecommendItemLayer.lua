-- friendRecommendItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a people item layer in friend moudle

local FriendRecommendItemLayer = class(GameBaseLayer, false)
local itemView = require(VIEW_PATH .. "friend.friend_recommend_item_layer")
local varConfigPath = VIEW_PATH .. "friend.friend_recommend_item_layer_layout_var"

function FriendRecommendItemLayer:ctor()
	Log.printInfo("FriendRecommendItemLayer.ctor");
    super(self, itemView, varConfigPath);
    self:setSize(self.m_root:getSize())
    -- 头像
    local headImage = self:getUI("headImage")
    -- 用户头像剪裁
    self.m_headImage = Mask.setMask(headImage, kImageMap.common_head_mask_big)
	-- 名字
	self.m_nameLabel = self:getUI("nameLabel")
	-- 金币
	self.m_moneyLabel = self:getUI("moneyLabel")
	-- 添加好友btn
    self.m_addButton = self:getUI("addButton")
    self.m_sexIcon = self:getUI("SexIcon")
	self.m_bg = self:getUI("bg")
	self.m_vip = self:getUI("View_vip")
	-- 添加好友label
	local addLabel = self:getUI("addLabel")
	addLabel:setText(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
    self.m_headImage:setEventTouch(self,self.onDetailButtonClick) 
end 

function FriendRecommendItemLayer:onDetailButtonClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
    if kFingerUp== finger_action then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
	    nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Friend", self.m_data)
    end
end

function FriendRecommendItemLayer:onAddButtonClick()
    nk.AnalyticsManager:report("New_Gaple_friend_add", "friend")
	Log.printInfo("FriendRecommendItemLayer", "onAddButtonClick")
	local params = {}
    params.mid = nk.userData.mid
    params.fid = self.m_data.mid
    nk.HttpController:execute("addFriend", {game_param = params})
end

function FriendRecommendItemLayer:dtor()
	Log.printInfo("FriendRecommendItemLayer.dtor");
end

return FriendRecommendItemLayer