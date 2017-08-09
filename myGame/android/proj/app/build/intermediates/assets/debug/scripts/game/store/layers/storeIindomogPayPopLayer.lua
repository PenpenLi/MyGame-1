-- storeIindomogPayPopLayer.lua
-- Last modification : 2016-06-20
-- Description: a pay popup layer in store moudle

local PopupModel = import('game.popup.popupModel')

local StoreIindomogPayPopLayer = class(PopupModel)
local storeIindomogPayView = require(VIEW_PATH .. "store.store_indomogPay_pop_layer")
local varConfigPath = VIEW_PATH .. "store.store_indomogPay_pop_layer_layout_var"

-------------------------------- single function --------------------------

function StoreIindomogPayPopLayer.show(callback)
    PopupModel.show(StoreIindomogPayPopLayer, storeIindomogPayView, varConfigPath, {name="StoreIindomogPayPopLayer"}, callback) 
end

function StoreIindomogPayPopLayer.update()
    if StoreIindomogPayPopLayer.s_instance then
        StoreIindomogPayPopLayer.s_instance:updateData();
    end
end

function StoreIindomogPayPopLayer.hide()
    PopupModel.hide(StoreIindomogPayPopLayer)
end

-------------------------------- base function --------------------------

function StoreIindomogPayPopLayer:ctor(viewConfig, varConfigPath, callback)
	Log.printInfo("StoreIindomogPayPopLayer.ctor");
    self.m_callback = callback
    -- 标题label
    self.m_titleLabel = self:getControl(self.s_controls["titleLabel"])
    self.m_titleLabel:setText(bm.LangUtil.getText("STORE", "CARD_TITLE"))
    -- 关闭btn
    self.m_closeButton = self:getControl(self.s_controls["closeButton"])
	-- 账号输入框
	self.m_accountEditBox = self:getControl(self.s_controls["accountEditBox"])
	-- 密码输入框
	self.m_passwordEditBox = self:getControl(self.s_controls["passwordEditBox"])
	-- 确定btn
	self.m_sureButton = self:getControl(self.s_controls["sureButton"])
    -- 取消btn
    self.m_cancelButton = self:getControl(self.s_controls["cancelButton"])

    self:getUI("accountLabel"):setText(bm.LangUtil.getText("STORE", "CARD_ACCOUNT"))
    self:getUI("passwordLabel"):setText(bm.LangUtil.getText("STORE", "CARD_PASSWORD"))
    self:getUI("sureLabel"):setText(bm.LangUtil.getText("STORE", "BUY"))
    self:getUI("cancelLabel"):setText(bm.LangUtil.getText("COMMON", "CANCEL"))

    self.m_bg = self:getUI("bg")
    self.m_bg:setEventDrag(self, function() return end)
    
    
end 

function StoreIindomogPayPopLayer:dtor()
	Log.printInfo("StoreIindomogPayPopLayer.dtor");
end

-------------------------------- handle function --------------------------

function StoreIindomogPayPopLayer:onCloseButtonClick()
    StoreIindomogPayPopLayer.hide();
end

function StoreIindomogPayPopLayer:onSureButtonClick()
    if self.m_callback then
        local strNumber = self.m_accountEditBox.text or ""
        local strSecret = self.m_passwordEditBox.text or ""
        self.m_callback(strNumber, strSecret)
    end
end
                                  
function StoreIindomogPayPopLayer:onCancelButtonClick()
    StoreIindomogPayPopLayer.hide();
end

function StoreIindomogPayPopLayer:itemTouch()
    return
end

-------------------------------- table config ------------------------

-- UI control handle
StoreIindomogPayPopLayer.s_controlFuncMapEx = 
{
    ["sureButton"] = StoreIindomogPayPopLayer.onSureButtonClick,
    ["cancleButton"] = StoreIindomogPayPopLayer.onCancleButtonClick,
    ["closeButton"] = StoreIindomogPayPopLayer.onCloseButtonClick,
};

return StoreIindomogPayPopLayer