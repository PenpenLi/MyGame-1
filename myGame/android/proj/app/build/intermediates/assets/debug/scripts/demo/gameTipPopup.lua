local PopupModel = import('game.popup.popupModel')
local aboutView = require(VIEW_PATH .. "demo/gameTipPopup")
local aboutInfo = VIEW_PATH .. "demo/gameTipPopup_layout_var"
local gameTipPopup = class(PopupModel);

function gameTipPopup.show(...)
	PopupModel.show(gameTipPopup, aboutView, aboutInfo, {name="gameTipPopup"}, ...)
end

function gameTipPopup.hide()
	PopupModel.hide(gameTipPopup)
end


function gameTipPopup:ctor(viewConfig, viewVar, data1, data2)
	Log.printInfo("failPopup.ctor");
	self.style= data1
	self.curStr = data2 
    Log.printInfo("-----------------style",self.style)
    self:addShadowLayer()
    self:initLayer()

    --使点击周围消失
    self:setIsCanClose(true)
end 

function gameTipPopup:initLayer()
	self.tipimage = self:getUI("tipImageBg")
	self.textviewTip = self:getUI("tip")
	self.imageTip = self:getUI("imageTip")
	
	local name = ""
	local x, y = self.textviewTip:getSize()
	self.textviewTip:setText(self.curStr, x, y, 0, 0, 0)
	
	if self.style == "Little" then
		name = "tipLittle"
	elseif self.style == "Long" then
		name = "tipLong"
	elseif self.style == "Mid" then
		name = "tipMid"
	elseif self.style == "Tall" then
		name = "tipTall"
	elseif self.style == "ZOMBIE" then
		name = "tipZOMBIE"

	end

	self.imageTip:setFile("game/gestures/" .. name .. ".png")

end

return gameTipPopup