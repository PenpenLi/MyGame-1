local PopupModel = import('game.popup.popupModel')
local aboutView = require(VIEW_PATH .. "demo/victoryPopup")
local aboutInfo = VIEW_PATH .. "demo/victoryPopup_layout_var"
local victoryPopup = class(PopupModel);

function victoryPopup.show(...)
	PopupModel.show(victoryPopup, aboutView, aboutInfo, {name="victoryPopup"}, ...)
end

function victoryPopup.hide()
	PopupModel.hide(victoryPopup)
end


function victoryPopup:ctor(viewConfig, viewVar, data1, data2)
	Log.printInfo("victoryPopup.ctor");
	self.score = data1
	self.curStr = data2 
    
    self:addShadowLayer()
    self:initLayer()

    --使点击周围消失
    self:setIsCanClose(false)
end 

function victoryPopup:initLayer()
	self.tipimage = self:getUI("bgVictory")
	self.barimage = self:getUI("pigSwf")
	self.winTextview = self:getUI("tvWin")

	-- local swfInfo = require("qnRes/qnSwfRes/swf/pig_swf_info")
	-- local pinMap = require("qnRes/qnSwfRes/swf/pig_swf_pin")
	-- self.barimage = new(SwfPlayer,swfInfo,pinMap)
	-- self.barimage:addTo(self)

	self.barimage:play(1, false, -1, 0, false)


	self.winTextview:setText("哈哈哈，我就是辣妹！")
	


end

return victoryPopup