
local PopupModel = import('game.popup.popupModel')
local aboutView = require(VIEW_PATH .. "demo/failPopup")
local aboutInfo = VIEW_PATH .. "demo/failPopup_layout_var"
local failPopup = class(PopupModel);

function failPopup.show(...)
	PopupModel.show(failPopup, aboutView, aboutInfo, {name="failPopup"}, ...)
end

function failPopup.hide()
	PopupModel.hide(failPopup)
end


function failPopup:ctor(viewConfig, viewVar, data1, data2, data3)
	Log.printInfo("failPopup.ctor");
	self.score = data1
	self.curStr = data2 
	self.gameModel = data3
    
    self:addShadowLayer()
    --使点击周围不取消弹框
    self:setIsCanClose(false)
    self:initLayer()

    
end 

function failPopup:initLayer()
	self.popupBg = self:getUI("failPopupBg")
	-- self:addCloseBtn(self.popupBg,x,y)
	self.popupButtonRestart = self:getUI("restart")
	self.popupButtonContinue = self:getUI("continue")
	self.popupTextView = self:getUI("message")
	self.popupButtonTip = self:getUI("tip")
	self.btnHome = self:getUI("btnHome")
	self.popupTextView:setPickable(false)

	self.popupTextView:setText(self.curStr)

	------------------------------------------------
	self.popupButtonRestart.name = "btnRestart"
	self.popupButtonContinue.name = "btnContinue"
	self.popupButtonTip.name = "btnTips"
	--------------------------------------------------

	self.popupButtonRestart:setOnClick(self, self.onRestartClick)
	self.popupButtonContinue:setOnClick(self, self.onContinueClick)
	self.popupButtonTip:setOnClick(self, self.onTipClick)
	self.btnHome:setOnClick(self, self.onbackHome)

end

function failPopup:dtor()
    Log.printInfo("failPopup.dtor");  
end 

function failPopup:onbackHome()
	PopupModel.hide(failPopup)
	EventDispatcher.getInstance():dispatch(EventConstants.backHomeDomoScene)
end

function failPopup:onRestartClick()
	PopupModel.hide(failPopup)
	EventDispatcher.getInstance():dispatch(EventConstants.restartDomoScene)
end

function failPopup:onContinueClick()
	Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>>> failPopup onContinueClick")
	PopupModel.hide(failPopup)
	EventDispatcher.getInstance():dispatch(EventConstants.reviveDomoScene)
end

function failPopup:onTipClick()
	-- PopupModel.hide(failPopup)
	Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>>> failPopup onTipClick")
	EventDispatcher.getInstance():dispatch(EventConstants.tipDemoScene)
end


return failPopup