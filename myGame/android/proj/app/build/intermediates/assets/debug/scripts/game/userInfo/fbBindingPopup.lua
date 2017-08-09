-- fbBindingPopup.lua

local PopupModel = import('game.popup.popupModel')
local FbBindingView = require(VIEW_PATH .. "userInfo/fbBinding_layer")
local FbBindingInfo = VIEW_PATH .. "userInfo/fbBinding_layer_layout_var"
local FbBindingPopup = class(PopupModel);

function FbBindingPopup.show(data)
	PopupModel.show(FbBindingPopup, FbBindingView, FbBindingInfo, {name="FbBindingPopup"}, data)
end

function FbBindingPopup.hide()
	PopupModel.hide(FbBindingPopup)
end

function FbBindingPopup:ctor(viewConfig)
	Log.printInfo("FbBindingPopup.ctor");
    self:addShadowLayer()
    self:initLayer()
end 

function FbBindingPopup:initLayer()
	local title = self:getUI("title")
	title:setText(bm.LangUtil.getText("USERINFO","FBBINDING_TITLE"))

	local tips = self:getUI("bind_tips")
	tips:setText(bm.LangUtil.getText("USERINFO","FBBINDING_TIPS"))

	local btn = self:getUI("binding_btn")
	btn:setOnClick(self,self.onBindingBtnClick)

	local btnName = self:getUI("binding_name")
	btnName:setText(bm.LangUtil.getText("USERINFO","FBBINDING_BTHNAME"))
end

function FbBindingPopup:onBindingBtnClick()
	nk.AnalyticsManager:report("New_Gaple_info_click_fbBind")
	nk.FacebookNativeEvent:logout()
	nk.FacebookNativeEvent:facebookBinding()
	-- nk.FacebookNativeEvent:onFacebookBindingResult()
	FbBindingPopup.hide()
end

return FbBindingPopup