-- loginSealed.lua
-- Date: 2017-01-19

local LoginFeedbackPopup = require("game.login.loginFeedbackPopup")
local PopupModel = import('game.popup.popupModel')
local loginSealedView = require(VIEW_PATH .. "login/login_sealed")
local loginSealedInfo =     VIEW_PATH .."login/login_sealed_layout_var"
local LoginSealedPopup = class(PopupModel)

function LoginSealedPopup.show(...)
    PopupModel.show(LoginSealedPopup, loginSealedView, loginSealedInfo, {name="LoginSealedPopup"},...)
end

function LoginSealedPopup.hide()
    PopupModel.hide(LoginSealedPopup)
end

function LoginSealedPopup:ctor(viewConfig)
    self:addShadowLayer(kImageMap.common_transparent_blank)
    self:addCloseBtn(self:getUI("Image_bg"))
    self:initLayer()
end

function LoginSealedPopup:initLayer()
    self.sealedTime_ = self:getUI("Text_time")
    self.sealedInfo_ = self:getUI("Text_info")
    self:getUI("Text_title"):setText(bm.LangUtil.getText("LOGIN","SEALED"))
    self:getUI("TextView_content"):setText(self.args[1])
    self:getUI("Text_mode"):setText(bm.LangUtil.getText("LOGIN","SEALED_MODE"))
    
    if tonumber(self.args[2]) == -1 then
        self.sealedTime_:setText(bm.LangUtil.getText("LOGIN","SEALED_TIME") .. bm.LangUtil.getText("USERINFO","FOREVER"))
        self.sealedInfo_:setText(bm.LangUtil.getText("LOGIN","SEALED_FOREVER"))
    else
        self.sealedTime_:setText(bm.LangUtil.getText("LOGIN","SEALED_TIME") .. os.date("%Y-%m-%d %H:%M",self.args[2]))
        self.sealedInfo_:setText(bm.LangUtil.getText("LOGIN","SEALED_FREE"))
    end
end

function LoginSealedPopup:sealedBtnClick()
    nk.PopupManager:addPopup(LoginFeedbackPopup,"login") 
end

function LoginSealedPopup:dtor()
    
end

return LoginSealedPopup
