local PopupModel = require('game.popup.popupModel')
local ViewTable = require(VIEW_PATH .. "userInfo/sendPropConfirm_layer")
local ViewConfigPath = VIEW_PATH .. "userInfo/sendPropConfirm_layer_layout_var" 

local SendPropConfirmPopup = class(PopupModel)
PopupModel.RegisterClassFuncs(SendPropConfirmPopup, "SendPropConfirmPopup", ViewTable, ViewConfigPath)

function SendPropConfirmPopup:ctor(_, _, infoOfPerson, sureCallback)
	self:addShadowLayer(kImageMap.common_transparent_blank)
	self:addCloseBtn(self:getUI("popupBg"), 25, 30)
	self.infoOfPerson = infoOfPerson
	self.sureCallback = sureCallback
	self:initView()
end	

function SendPropConfirmPopup:dtor()
	self.sureCallback = nil
end

function SendPropConfirmPopup:initView()
	self.user_icon = Mask.setMask(self:getUI("Image_user_icon"), kImageMap.common_head_mask_middle, {scale = 1, align = 0, x = -1.5, y = -1})
	local aUser = self.infoOfPerson.aUser
	nk.functions.loadIconToNode(self.user_icon, aUser.micon, aUser.msex, true)
	self:getUI("TextTitle"):setText(bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_CONFIRM_TITLE"))
	self:getUI("TextName"):setText(bm.LangUtil.getText("COMMON", "NAME_KEY") .. bm.LangUtil.getText("COMMON", "COLON") .. (aUser.name or "?"))
	self:getUI("TextUID"):setText("ID: " .. (aUser.mid or "?"))
	self:getUI("TextTips"):setText(bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_CONFIRM_TIPS"))
	self:getUI("TextSure"):setText(bm.LangUtil.getText("COMMON", "CONFIRM"))
	self:getUI("TextCancel"):setText(bm.LangUtil.getText("COMMON", "CANCEL"))
end

function SendPropConfirmPopup:onBtnSureClick()
	if self.sureCallback then
		self.sureCallback()
	end
	self:onClose()
end

return SendPropConfirmPopup