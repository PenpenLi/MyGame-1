local PopupModel = require('game.popup.popupModel')
local PropManager = require("game.store.prop.propManager")
--private 
local addDecoToFont

local SynthesisPropItem = require('game.userInfo.myprop.synthesisPropItem')

local SynthesisPropPopup = class(PopupModel)
PopupModel.RegisterClassFuncs(SynthesisPropPopup, "SynthesisPropPopup", nil, nil)

function SynthesisPropPopup:ctor(viewConfig, varConfigPath)
	self:addShadowLayer(kImageMap.common_transparent_blank)
	local popupBg = new(Image, kImageMap.common_pop_bg)
	popupBg:addTo(self)
	popupBg:setAlign(kAlignCenter)
	popupBg:setEventTouch(self, self.onPopupBgTouch)
	self.widthOfView, self.heightOfView = popupBg:getSize()
	local titleBg = new(Image, kImageMap.common_pop_bg_title)
	titleBg:addTo(popupBg)
	titleBg:setAlign(kAlignTop)
	self.m_root = popupBg
	local titleTxt = new(Text, bm.LangUtil.getText("USERINFO", "SYNTHESIS_PROP_TITLE"))
	titleTxt:addTo(titleBg)
	titleTxt:setAlign(kAlignCenter)
	self:addCloseBtn(popupBg, 25, 20)

	local btnQuestion = new(Button, kImageMap.common_question_mark) 
	btnQuestion:addTo(popupBg)
	-- btnQuestion:setAlign(kAlignTopLeft)
	btnQuestion:setPos(28, 23)
	btnQuestion:setOnClick(self,self.onBtnQuestionClick)

	local image = new(Image, kImageMap.userInfo_tile_bg, nil, nil, 2, 2, 1, 1)
	image:addTo(popupBg)
	image:setSize(230, 399)
	image:setPos(self.widthOfView - 230, 90)
	
end

function SynthesisPropPopup:dtor()
	
end

function SynthesisPropPopup:onShow()
	self:requestConfig()
end

function SynthesisPropPopup:requestConfig()
	PropManager.getInstance():loadSyntConf(function(status, data)
		-- FwLog("PropManager:requestConfig >>")
		if status and not tolua.isnull(self) then
			self.config = data or {} -- 配置，数组
			self:initView()
		end
	end)
end

function SynthesisPropPopup:initView()
	local scrollContainer = new(ScrollView, 14, 90, self.widthOfView - 26, self.heightOfView - 90 - 24, false)
	scrollContainer:addTo(self.m_root)
	scrollContainer:setDirection(kVertical)
    self.scrollContainer = scrollContainer

    local text = new(Text, bm.LangUtil.getText("USERINFO", "PIECE_PROP"), 0, 20, kAlignCenter,"", 20, 255, 255, 255)
    text:addTo(scrollContainer)
    text:setPos(190, 15)
    addDecoToFont(text, 10)

    local text = new(Text, bm.LangUtil.getText("USERINFO", "CAN_SYNTHESIS"), 0, 20, kAlignCenter,"", 20, 255, 255, 255)
    text:addTo(scrollContainer)
    text:setPos(583 - text:getSize()/2, 15)
    addDecoToFont(text)

    local currentHeight = 50
    local list = self.config.info or {}
    local cnt = #list
    for i = 1, cnt do
    	local node = new(SynthesisPropItem, list[i])
    	node:addTo(scrollContainer)
    	node:setPos(0, currentHeight)
    	currentHeight = currentHeight + 130
    end
    scrollContainer.m_nodeH = currentHeight
    scrollContainer:update()
end

function SynthesisPropPopup:onBtnQuestionClick()
	local SynthesisPropTipsPopup = require("game.userInfo.myprop.synthesisPropTipsPopup")
	nk.PopupManager:addPopup(SynthesisPropTipsPopup, "synthesisProp")
end

addDecoToFont = function(text, gap)
	local gap = gap or 0
	local parent = text:getParent()
	local x,y = text:getPos()
	local w,h = text:getSize()
	local left = new(Image, kImageMap.userInfo_exchange_deco)
	left:addTo(parent)
	local wOfDeco = left:getSize()
	local right = new(Image, kImageMap.userInfo_exchange_deco)
	right:addPropScaleSolid(0, -1, 1, kCenterDrawing)
	right:addTo(parent)
	left:setPos(x - wOfDeco - 5 - gap, y)
	right:setPos(x + w + 4 + gap, y)
end

return SynthesisPropPopup