local PopupModel = import('game.popup.popupModel')
local rankItemLayer = require("demo.rankItemLayer.rankItemLayer")
local aboutView = require(VIEW_PATH .. "demo/onRankPopup")
local aboutInfo = VIEW_PATH .. "demo/onRankPopup_layout_var"
local onRankPopup = class(PopupModel);

function onRankPopup.show(...)
	PopupModel.show(onRankPopup, aboutView, aboutInfo, {name="onRankPopup"}, ...)
end

function onRankPopup.hide()
	PopupModel.hide(onRankPopup)
end

function onRankPopup:ctor(viewConfig, viewVar, data)
	Log.printInfo("onRankPopup.ctor");
    self.rank = data

    self:addShadowLayer()
    self:initLayer()
end 

function onRankPopup:dtor()
    Log.printInfo("onRankPopup.dtor");  
end 


function onRankPopup:initLayer()
	self.popupBg = self:getUI("bg")
	self.personal = self:getUI("personal")
	self.frame = self:getUI("frame")
	self.ListView = self:getUI("ListView")
	self.myRankTextView = self:getUI("myRankTextView")
	self.imageHead = self:getUI("ImageHead")
	-- self.imageHead = Mask.setMask(self:getUI("ImageHead"), "game/common/headframe1.png", {scale = 1, align = 0, x = -1.5, y = -1})
	UrlImage.spriteSetUrl(self.imageHead, ICON_URL)

	self.RadioButtonGroup = self:getUI("RadioButtonGroup")
	self.RadioButtonGroup:setOnChange(self, self.onTitleGroupChangeClick)

	self.crazyRadioButton = self:getUI("crazyRadioButton")
	self.gentleRadioButton = self:getUI("gentleRadioButton")
	
	self.RadioButtonGroup:setSelected(1)
	self:onMode()
end


function onRankPopup:onTitleGroupChangeClick()
	if self.crazyRadioButton:isChecked() then
		self:onMode("crazy")
	elseif self.gentleRadioButton:isChecked() then
		self:onMode("gentle")
	end
end


function onRankPopup:onMode(mode)

	local listdata = nil
	local rankList = self.rank
	local myCrazyRank = self.rank.personalRankList.crazy.rank
	local myGentleRank = self.rank.personalRankList.gentle.rank

	local mode = mode or "gentle"
	if mode == "gentle" then
		listdata = rankList.gentleRankList
		self.myRankTextView:setText(myGentleRank)
	elseif mode == "crazy" then
		listdata = rankList.crazyRankList
		self.myRankTextView:setText(myCrazyRank)
	end

	if #listdata > 0 then
        local adapter = new(CacheAdapter, rankItemLayer, listdata)
        self.ListView:setAdapter(adapter)
    end
end


return onRankPopup