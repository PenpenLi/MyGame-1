local PopupModel = import('game.popup.popupModel')
local aboutView = require(VIEW_PATH .. "demo/exitPopup")
local aboutInfo = VIEW_PATH .. "demo/exitPopup_layout_var"
local exitPopup = class(PopupModel);

function exitPopup.show(...)
	PopupModel.show(exitPopup, aboutView, aboutInfo, {name="exitPopup"}, ...)
end

function exitPopup.hide()
	PopupModel.hide(exitPopup)
end


function exitPopup:ctor(viewConfig, viewVar, data1)
	Log.printInfo("exitPopup.ctor");
	self.station = data1
    self:addShadowLayer()
    self:initLayer()

    --使点击周围
    self:setIsCanClose(false)
end 

function exitPopup:initLayer()
	self.popupBg = self:getUI("exitPopupBg")

	self.popupButtonCancel = self:getUI("cancelBut")
	self.popupButtonLeave  = self:getUI("leaveBtn")
	self.popupImagePig     = self:getUI("pigImg")

 	---------------------------------------------------
	self.popupButtonCancel.name = "BtnExitCancelNum"
	---------------------------------------------------


	self.popupButtonLeave:setOnClick(self, self.onLeaveClick)

	if self.station == "Victory" then
		self.popupButtonCancel:setOnClick(self, self.onVictory)
	else
		self.popupButtonCancel:setOnClick(self, self.onCancelClick)	
	end
end

function exitPopup:dtor()
    Log.printInfo("exitPopup.dtor");  
end 

function exitPopup:onVictory()
	nk.PopupManager:removeAllPopup()
end

function exitPopup:onLeaveClick()
	PopupModel.hide(exitPopup)
	sys_exit()
end

function exitPopup:onCancelClick()
	PopupModel.hide(exitPopup)

	if self.station == "Init" or self.station == "Victory" then
		nk.PopupManager:removePopupByName("exitPopup")

	else
		EventDispatcher.getInstance():dispatch(EventConstants.cancelDomoScene)

	end

end

return exitPopup