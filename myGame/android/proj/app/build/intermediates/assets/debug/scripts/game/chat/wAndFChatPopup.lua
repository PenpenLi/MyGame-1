
-- 好友和世界聊天弹框

local PopupModel = import('game.popup.popupModel')
local WAndFChatConfig = import('game.chat.wAndFChatConfig')
local WAndFChatPopupLayer = require(VIEW_PATH .. "chat.chat_pop")
local varConfigPath = VIEW_PATH .. "chat.chat_pop_layout_var"

local WorldChatLayer = require("game.chat.layers.worldChatLayer")
local FriendsChatLayer = require("game.chat.layers.friendsChatLayer")

local WAndFChatPopup = class(PopupModel)

function WAndFChatPopup.show(...)
	PopupModel.show(WAndFChatPopup, WAndFChatPopupLayer, varConfigPath, {name="WAndFChatPopup"}, ...)
end

function WAndFChatPopup.hide()
	PopupModel.hide(WAndFChatPopup)
end

function WAndFChatPopup:ctor(viewConfig, varConfigPath, roomType, mid)
	self.m_backNothing = false
	self.m_roomType = roomType
	self.m_goToMid = mid
	self:initScene()
	self:addPropertyObservers_()
	if self.m_goToMid then
		WAndFChatConfig.CUR_VIEWINDEX = 2
		self:setViewIndex(WAndFChatConfig.CUR_VIEWINDEX)
	else
		WAndFChatConfig.CUR_VIEWINDEX = 1
		self:setViewIndex(WAndFChatConfig.CUR_VIEWINDEX)
	end		
end

function WAndFChatPopup:onShow()
	if self.m_goToMid then
		self:onFriendBtnClick()
	else
		self:onWorldBtnClick()
	end
end

function WAndFChatPopup:dtor()
	if self.m_worldChatView then
		delete(self.m_worldChatView)
	end
	if self.m_worldChatView then
		delete(self.m_friendsChatView)
	end
	self:removePropertyObservers()
end 

function WAndFChatPopup:initScene()
	self.m_popupBg = self:getUI("popup_bg")
	self:addCloseBtn(self.m_popupBg)
	self:addShadowLayer()
	self:initTopBtnNode()
	self:initContentNode()
end

function WAndFChatPopup:setViewIndex(index)
	WAndFChatConfig.CUR_VIEWINDEX = index or WAndFChatConfig.DEFAULT_VIEWINDEX
	self:updateTopBtn()
end

function WAndFChatPopup:initTopBtnNode()
	self.m_worldBtnBg = self:getUI("world_btn_bg")
	self.m_friendBtnBg = self:getUI("friend_btn_bg")
	self.m_worldBtnText = self:getUI("world_text")
	self.m_friendBtnText = self:getUI("friend_text")
	self.m_red_point = self:getUI("red_point")
	self.m_red_point:setVisible(false)

	self.m_worldBtnText:setText(bm.LangUtil.getText("FRIEND", "WORLD_TALK"))
	self.m_friendBtnText:setText(bm.LangUtil.getText("FRIEND", "FRIEND_TALK"))
end

function WAndFChatPopup:initContentNode()
	self.m_worldView = self:getUI("world_view")
	self.m_friendView = self:getUI("friend_view")
end

function WAndFChatPopup:updateTopBtn()
	if WAndFChatConfig.CUR_VIEWINDEX == 1 then
		self.m_worldBtnBg:setVisible(true)
		self.m_friendBtnBg:setVisible(false)
		self.m_worldBtnText:setColor(WAndFChatConfig.getBtnSelectedColor())
		self.m_friendBtnText:setColor(WAndFChatConfig.getBtnUnSelectedColor())
		self.m_worldView:setVisible(true)
		self.m_friendView:setVisible(false)
	else
		self.m_worldBtnBg:setVisible(false)
		self.m_friendBtnBg:setVisible(true)
		self.m_worldBtnText:setColor(WAndFChatConfig.getBtnUnSelectedColor())
		self.m_friendBtnText:setColor(WAndFChatConfig.getBtnSelectedColor())
		self.m_worldView:setVisible(false)
		self.m_friendView:setVisible(true)
	end
end

function WAndFChatPopup:onWorldBtnClick()
	WAndFChatConfig.CUR_VIEWINDEX = 1
	self:setViewIndex(WAndFChatConfig.CUR_VIEWINDEX)
	if not self.m_worldChatView then
		self.m_worldChatView = new(WorldChatLayer,self.m_roomType)
		self.m_worldView:addChild(self.m_worldChatView)
	end
	self.m_worldChatView:updataView()
	if self.m_friendsChatView then
		self.m_friendsChatView:setIsVisible(false)
	end
end

function WAndFChatPopup:onFriendBtnClick()
	WAndFChatConfig.CUR_VIEWINDEX = 2
	self:setViewIndex(WAndFChatConfig.CUR_VIEWINDEX)
	if not self.m_friendsChatView then
		self.m_friendsChatView = new(FriendsChatLayer,self.m_goToMid)
		self.m_friendsChatView:setDelegate(self,self.closeWAndFChatPopup)
		self.m_friendView:addChild(self.m_friendsChatView)
	end
	self.m_friendsChatView:updataView()
	self.m_friendsChatView:setIsVisible(true)
end

function WAndFChatPopup:closeWAndFChatPopup()
	WAndFChatPopup.hide()
end

function WAndFChatPopup:addPropertyObservers_()
    self.chatRecordHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", handler(self, function (obj, chatRecord)
        if not nk.updateFunctions.checkIsNull(obj) then
            if chatRecord and #chatRecord>0 then
                obj.m_red_point:setVisible(true)
            else
                obj.m_red_point:setVisible(false)
            end
        end
    end))
end

function WAndFChatPopup:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", self.chatRecordHandle_)
end

return WAndFChatPopup