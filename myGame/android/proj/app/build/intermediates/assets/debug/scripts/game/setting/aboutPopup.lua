-- AboutPopup.lua
-- Date : 2016-06-01
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local aboutView = require(VIEW_PATH .. "setting/setting_about")
local aboutInfo = VIEW_PATH .. "setting/setting_about_layout_var"
local AboutPopup= class(PopupModel);

function AboutPopup.show(data)
	PopupModel.show(AboutPopup, aboutView, aboutInfo, {name="AboutPopup"}, data)
end

function AboutPopup.hide()
	PopupModel.hide(AboutPopup)
end

function AboutPopup:ctor(viewConfig)
	Log.printInfo("AboutPopup.ctor");
    self:addShadowLayer()
    self:initLayer()
end 

function AboutPopup:initLayer()
     self:initWidget()
end

function AboutPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)   
    self.bt_share_ = self:getUI("Button_share")
    self.bt_share_:setOnClick(self,self.bt_share_click)

    self.text_title_ = self:getUI("Text_title")
    self.text_title_:setText(bm.LangUtil.getText("SETTING", "ABOUT"))

    self.text_thanks_ = self:getUI("Text_thankyou")
    self.text_thanks_:setText(bm.LangUtil.getText("SETTING", "THANK_FOR_YOU",nk.UserDataController.getUserName()))

    self.text_version_ = self:getUI("Text_version")
    self.text_version_:setText(bm.LangUtil.getText("SETTING", "CURRENT_VERSION", GameConfig.CUR_VERSION))

    self.text_down_ = self:getUI("Text_down")
    self.text_down_:setText(bm.LangUtil.getText("SETTING", "QRCODE_TIP"))

    self.text_share_ = self:getUI("Text_share")
    self.text_share_:setText(bm.LangUtil.getText("SETTING", "SHARE_APK"))

    self.text_share_tip_ = self:getUI("Text_share_tip")
    self.text_share_tip_:setText(bm.LangUtil.getText("SETTING", "SHARE_APK_TIP"))

end

function AboutPopup:bt_share_click()
   nk.GameNativeEvent:shareApk()
end

function AboutPopup:dtor()
    Log.printInfo("AboutPopup.dtor");
end 


return AboutPopup