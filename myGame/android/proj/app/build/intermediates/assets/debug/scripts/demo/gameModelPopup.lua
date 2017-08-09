local PopupModel = import('game.popup.popupModel')
local aboutView = require(VIEW_PATH .. "demo/exitPopup")
local aboutInfo = VIEW_PATH .. "demo/exitPopup_layout_var"
local exitPopup = require('demo.exitPopup')

local gameModelPopup = class(exitPopup);


function gameModelPopup.show(...)
	PopupModel.show(gameModelPopup, aboutView, aboutInfo, {name="gameModelPopup"}, ...)
end

function gameModelPopup.hide()
	PopupModel.hide(gameModelPopup)
end


function gameModelPopup:initLayer()

	gameModelPopup.super.initLayer(self)
	self.popupBg = self:getUI("exitPopupBg")
	self.btnCrazy = self:getUI("btnCrazy")
	self.btnGentle = self:getUI("btnGentle")
	
	self.popupButtonCancel:setVisible(false)
	self.popupImagePig:setVisible(false)
	self.popupButtonLeave:setVisible(false)
	self.popupButtonCancel:setPickable(false)
	self.popupButtonLeave:setPickable(false)
	self.popupImagePig:setPickable(false)

	self.btnCrazy:setVisible(true)
	self.btnGentle:setVisible(true)

	self.popupBg:setFile("game/backgroud/bg0.png")
	self.btnCrazy:setOnClick(self, self.onCrazyClick)
	self.btnGentle:setOnClick(self, self.onGentleClick)

end


function gameModelPopup:onCrazyClick()
	gameModelPopup.hide()
	nk.DictModule:setString("gameModelPopup", "gameModel", "Crazy")
	EventDispatcher.getInstance():dispatch(EventConstants.restartDomoScene, mode)

end


function gameModelPopup:onGentleClick()
	gameModelPopup.hide()
	nk.DictModule:setString("gameModelPopup", "gameModel", "Gentle")
	EventDispatcher.getInstance():dispatch(EventConstants.restartDomoScene, mode)
end

return gameModelPopup