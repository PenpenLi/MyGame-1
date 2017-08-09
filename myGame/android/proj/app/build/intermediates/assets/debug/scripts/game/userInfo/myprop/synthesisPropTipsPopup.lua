local PopupModel = require('game.popup.popupModel')
local PropManager = require("game.store.prop.propManager")

local SynthesisPropTipsPopup = class(PopupModel)
PopupModel.RegisterClassFuncs(SynthesisPropTipsPopup, "SynthesisPropTipsPopup", nil, nil)

function SynthesisPropTipsPopup:ctor()
	self:addShadowLayer(kImageMap.common_transparent_blank)
	local popupBg = new(Image, kImageMap.common_popup_bg_small1, nil, nil, 15, 15, 100, 50)
	popupBg:addTo(self)
	popupBg:setAlign(kAlignCenter)
	popupBg:setEventTouch(self, self.onPopupBgTouch)
	self.m_root = popupBg
	self:addCloseBtn(popupBg, 25, 30)

	local titleBg = new(Image, kImageMap.common_pop_bg_title)
	titleBg:addTo(popupBg)
	titleBg:setAlign(kAlignTop)
	titleBg:setPos(0, 13)
	self.m_root = popupBg
	local titleTxt = new(Text, bm.LangUtil.getText("USERINFO", "SYNTHESIS_PROP_TIPS_TITLE"))
	titleTxt:addTo(titleBg)
	titleTxt:setAlign(kAlignCenter)

	-- local msg = [[asdasd
	-- asdasd
	-- asdasdasd asdasdasd
	-- asdasdasdasd asdasdasd asdasdasd asdasdasd asdasdasd asdasdasd asdasdasd asdasdasd asdasdasd 
	-- asdasdasdasda

	-- asdasdasd

	-- asdasdasd

	-- asdasdasd
	-- asdasdasd

	-- asdasdasd
	-- ]]
	PropManager.getInstance():loadSyntConf(function(status, conf)
		if status and not tolua.isnull(self) then
			local msg = conf.des
			local textView = new(TextView, msg, 500, 275, kAlignTopLeft, nil, 20, 255, 255, 255)
			textView:addTo(popupBg)
			-- textView:setAlign(kAlignCenter)
			textView:setPos(40, 115)
		end
	end)
	
end

function SynthesisPropTipsPopup:dtor()
	
end

return SynthesisPropTipsPopup