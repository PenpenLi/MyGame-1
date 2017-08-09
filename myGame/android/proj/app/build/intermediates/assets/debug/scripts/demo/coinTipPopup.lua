local PopupModel = import('game.popup.popupModel')
local aboutInfo = VIEW_PATH .. "demo/failPopup_layout_var"
local aboutView = require(VIEW_PATH .. "demo/failPopup")
local failPopup = require('demo.failPopup')

local coinTipPopup = class(failPopup);



function coinTipPopup.show(...)
	PopupModel.show(coinTipPopup, aboutView, aboutInfo, {name="coinTipPopup"}, ...)
end

function coinTipPopup.hide()
	PopupModel.hide(coinTipPopup)
end

function coinTipPopup:initLayer()

	coinTipPopup.super.initLayer(self)

	self.popupButtonKey = self:getUI("key")
	self.popupButtonCancel = self:getUI("cancel")
	self.popupButtonKey:setVisible(true)
	self.popupButtonCancel:setVisible(true)
	self.popupButtonRestart:setVisible(false)
	self.popupButtonContinue:setVisible(false)
	self.popupButtonTip:setVisible(false)

	local x, y = self.popupTextView:getSize()
	self.popupTextView:setText(self.curStr, x, y, 204, 0, 0)

	self.popupButtonKey:setOnClick(self, self.onContinueClick)
	self.popupButtonCancel:setOnClick(self, self.onCancelClick)



end

function coinTipPopup:onContinueClick()
	Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>>> onContinueClick")
	PopupModel.hide(coinTipPopup)
	EventDispatcher.getInstance():dispatch(EventConstants.continueDomoScene)
end

function coinTipPopup:onCancelClick()
	PopupModel.hide(coinTipPopup)
	EventDispatcher.getInstance():dispatch(EventConstants.failDemoScene)
end

return coinTipPopup