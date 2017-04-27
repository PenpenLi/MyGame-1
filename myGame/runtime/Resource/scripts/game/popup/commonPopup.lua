-- commonPopup.lua
-- Last modification : 2016-07-28
-- Description: a common popup to tip something 

local PopupModel = import('game.popup.popupModel')
local CommonPopup = class(PopupModel)
local CommonPopupLayer = require(VIEW_PATH .. "popup.common_pop_layer")
local varConfigPath = VIEW_PATH .. "popup.common_pop_layer_layout_var"

CommonPopup.ONE_BUTTON = 1
CommonPopup.TWO_BUTTON = 1

-------------------------------- single function --------------------------

-- data = {
--     type = CommonPopup.ONE_BUTTON or CommonPopup.TWO_BUTTON, default = CommonPopup.ONE_BUTTON @按钮个数类型
--     titleStr = "" @标题字符串
--     contentStr = "" @内容字符串

--     closeBtn = boolean @是否需要关闭按钮， default = false
--     shadeCloase = boolean @点击阴影层是否可关闭弹窗， default = true
--     sureStr = "" @确定按钮文案
--     cancelStr = "" @取消按钮文案
-- }
-- sureCallback = handler() 点击sure按钮回调
-- cancelCallback = handler() 点击cancel按钮回调

function CommonPopup.show(data, sureCallback, cancelCallback)
    PopupModel.show(CommonPopup, CommonPopupLayer, varConfigPath, {name="CommonPopup"}, data, true, sureCallback, cancelCallback) 
end

function CommonPopup.hide()
    PopupModel.hide(CommonPopup)
end

-------------------------------- base function --------------------------

function CommonPopup:ctor(viewConfig, varConfigPath, data, sureCallback, cancelCallback)
	Log.printInfo("CommonPopup.ctor")
    self.m_data = data
    self.m_sureCallback = sureCallback
    self.m_cancelCallback = cancelCallback
    self:getUI("CloseBtn"):setClickSound(nk.SoundManager.CLOSE_BUTTON)
	self:init(data)
end 


function CommonPopup:onCloseBtnClick()
    CommonPopup.hide()
end

function CommonPopup:onUpdate()
    -- body
end

function CommonPopup:dtor()
	Log.printInfo("CommonPopup.dtor")
end

-- overwrite
-- 透明或半透明背景触摸响应
function PopupModel:onBgTouch()
    if self.m_canClose then
        self:hide()
    end
end

-------------------------------- private function --------------------------

function CommonPopup:init(data)
	Log.printInfo("CommonPopup.init")
    local titleLabel = self:getUI("titleLabel")

    local titleLabel = self:getUI("twoCancleLabel")

    local titleLabel = self:getUI("twoSureLabel")

    local titleLabel = self:getUI("oneSureLabel")
end 

-------------------------------- UI function --------------------------

function CommonPopup:onSureButtonClick()
	Log.printInfo("CommonPopup.onSureButtonClick")
end 

function CommonPopup:onCancleButtonClick()
	Log.printInfo("CommonPopup.onCancleButtonClick")
end 
-------------------------------- table config ------------------------

CommonPopup.s_cmdHandleEx = 
{

}

return CommonPopup