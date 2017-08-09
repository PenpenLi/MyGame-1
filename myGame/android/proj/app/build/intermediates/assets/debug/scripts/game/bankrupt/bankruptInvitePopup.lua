-- BankruptInvitePopup.lua
-- Date : 2016-06-01
-- Description: a scene in login moudle
local BankruptHelpPopup = require("game.bankrupt.bankruptHelpPopup")
local PopupModel = import('game.popup.popupModel')
local bankruptInviteView = require(VIEW_PATH .. "bankrupt/bankrupt_invite_layer")
local bankruptInviteInfo = VIEW_PATH .. "bankrupt/bankrupt_invite_layer_layout_var"
local BankruptInvitePopup= class(PopupModel);

function BankruptInvitePopup.show(data)
	PopupModel.show(BankruptInvitePopup, bankruptInviteView, bankruptInviteInfo, {name="BankruptInvitePopup"}, data)
end

function BankruptInvitePopup.hide()
	PopupModel.hide(BankruptInvitePopup)
end

function BankruptInvitePopup:ctor(viewConfig)
	Log.printInfo("BankruptInvitePopup.ctor");
    self:addShadowLayer()
    self:initLayer()
end 

function BankruptInvitePopup:initLayer()
     self:initWidget()
end

function BankruptInvitePopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)   

    self:getUI("Text_title"):setText(bm.LangUtil.getText("CRASH", "TITLE"))
    self:getUI("TextView_content"):setText(bm.LangUtil.getText("CRASH", "INVITE_LABEL"))
    self:getUI("Text_bt_invite"):setText(bm.LangUtil.getText("CRASH", "INVITE_FRIEND"))

end

function BankruptInvitePopup:bt_invite_click()
    local InviteScene = require("game.invite.inviteScene")
    nk.PopupManager:addPopup(InviteScene,"BankruptInvitePopup")
end

function BankruptInvitePopup:onCloseBtnClick()
    self:hide()
    if nk.userData.bankruptcyGrant and nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
         nk.PopupManager:addPopup(BankruptHelpPopup,"hall")
    end
end

function BankruptInvitePopup:dtor()
    Log.printInfo("BankruptInvitePopup.dtor");
end 


return BankruptInvitePopup