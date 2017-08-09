local PopupModel = require('game.popup.popupModel')
local PropManager = require("game.store.prop.propManager")


local PropDetailPopup = class(PopupModel)
PopupModel.RegisterClassFuncs(PropDetailPopup, "PropDetailPopup", nil, nil)

function PropDetailPopup:ctor(_, _, data, config)
	-- FwLog("SynthesisPropItem:ctor start")
	-- FwLog(json.encode(data))
	-- FwLog(json.encode(config))
	-- FwLog("SynthesisPropItem:ctor end")
	self.data = data
	self.config = config

	self:addShadowLayer(kImageMap.common_transparent_blank)
	local popupBg = new(Image, kImageMap.common_popup_bg_small1, nil, nil, 15, 15, 100, 50)
	popupBg:addTo(self)
	popupBg:setAlign(kAlignCenter)
	popupBg:setEventTouch(self, self.onPopupBgTouch)
	self.m_root = popupBg

	local titleBg = new(Image, kImageMap.common_pop_bg_title)
	titleBg:addTo(popupBg)
	titleBg:setAlign(kAlignTop)
	titleBg:setPos(0, 13)
	self.m_root = popupBg
	local titleTxt = new(Text, self.config["name"] or "N/A")
	titleTxt:addTo(titleBg)
	titleTxt:setAlign(kAlignCenter)

	self:addCloseBtn(popupBg, 25, 30)

	if tonumber(self.config.exch) == 1 then
		self:initViewOfExchange()
	else
		self:initViewOfNormal()
	end
end

function PropDetailPopup:dtor()
end

function PropDetailPopup:initViewOfNormal()
	local image = new(Image, kImageMap.userInfo_propItem_bg, nil, nil, 15, 15, 15, 15)
	image:addTo(self.m_root)
	image:setSize(140, 137)
	image:setPos(60, 130)

	local icon = new(Image, kImageMap.common_transparent)
	icon:addTo(image)
	icon:setAlign(kAlignCenter)
	icon:setSize(90, 90)
	nk.functions.loadPropIconToImage(icon, self.config["image"], 90)

	-- t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue
	-- local str = [[如果是中文问如果是中文问如果是中文问如果是中文问如果是中文问如果是中文问如果
	-- 是中文问如果是中文问如果是中文问如果是中文问如
	-- 果是中文问如果是中文问如果是中文问如果是中文问如果是中文问
	-- 如果是中文问]]
	local str = self.config["des"] or "N/A"
	local wOfT, hOfT = 300, 110
	local textDetail = new(TextView, str, wOfT, hOfT,
		kAlignTopLeft, "", 22, 0xe6, 0xd7, 0xfb)
	textDetail:addTo(self.m_root)
	textDetail:setPos(230, 145)

	self:checkAndAddExpireInfo()
	self:checkAndAddSendStatus()

	local btnOk = new(Button, kImageMap.common_btn_yellow)
	btnOk:addTo(self.m_root)
	btnOk:setAlign(kAlignBottom)
	btnOk:setPos(0, 35)
	local textBtn = new(Text, bm.LangUtil.getText("COMMON", "CONFIRM"))
	textBtn:addTo(btnOk)
	textBtn:setAlign(kAlignCenter)
	btnOk:setOnClick(self, self.onClose)
end

function PropDetailPopup:initViewOfExchange()
	-- t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue
	-- local str = [[如果是中文问如果是中文问如果是中文问如果是中文问如果是中文问如果是中文问如果
	-- 是中文问如果是中文问如果是中文问如果是中文问如
	-- 果是中文问如果是中文问如果是中文问如果是中文问如果是中文问
	-- 如果是中文问]]
	local str = self.config["des"] or "N/A"
	local wOfT, hOfT = 480, 50
	local textDetail = new(TextView, str, wOfT, hOfT,
		kAlignTopLeft, "", 20, 0xe6, 0xd7, 0xfb)
	textDetail:addTo(self.m_root)
	textDetail:setPos(50, 110)

	local forms = self.config["exchinfo"]
	local maxKeyWidth = 0
	local hOfText = 0
	-- forms = {forms[1], forms[1]}

	if #forms >= 3 then
		local w, h = self.m_root:getSize()
		self.m_root:setSize(w, h + (#forms - 2) * 50)
	end

	local inputStartY = 110
	for i = 1, #forms do
		local keyStr = forms[i].idname
		local text = new(Text, keyStr .. bm.LangUtil.getText("COMMON", "COLON"),
			nil, nil, kAlignLeft, nil, 22, 0xe6, 0xd7, 0xfb)
		text:addTo(self.m_root)
		text:setPos(50, inputStartY + 60 + (i - 1) * 50)
		local w, hOfText = text:getSize()
		if w > maxKeyWidth then maxKeyWidth = w end
	end

	local infoCollector = {}
	for i = 1, #forms do
		local imageInputBg = new(Image, kImageMap.common_bg_1, nil, nil, 15, 15,  15, 15)
		imageInputBg:addTo(self.m_root)
		imageInputBg:setSize(400, 50)
		imageInputBg:setPos(50 + maxKeyWidth + 5, inputStartY + 60 + (i - 1) * 50 - 11)
		
		local editText = new(EditTextView, "", 380, 40, nil, "", 22, 255, 255, 255)
		editText:addTo(imageInputBg)
		editText:setHintText("请输入信息", 0xab, 0x5f, 0xec)
		editText:setAlign(kAlignCenter)
		
		table.insert(infoCollector, {forms[i].zdname, editText})
	end
	self.infoCollector = infoCollector

	self:checkAndAddExpireInfo()
	self:checkAndAddSendStatus()

	local btnOk = new(Button, kImageMap.common_btn_yellow)
	btnOk:addTo(self.m_root)
	btnOk:setAlign(kAlignBottom)
	btnOk:setPos(0, 35)
	local textBtn = new(Text, bm.LangUtil.getText("COMMON", "CONFIRM"))
	textBtn:addTo(btnOk)
	textBtn:setAlign(kAlignCenter)
	btnOk:setOnClick(self, self.onBtnExchangeClick)
	self.btnExchange = btnOk
end

function PropDetailPopup:checkAndAddExpireInfo()
	if self.data.pexpire then
		local str = nk.functions.getStrOfLeftTime(checkint(self.data.pexpire) - os.time())
		-- t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue
		local textExpireKey = new(Text, bm.LangUtil.getText("USERINFO", "PROP_EXPIRE_KEY"),
			nil, nil, kAlignLeft, nil, 20, 0xe6, 0xd7, 0xfb)
		textExpireKey:addTo(self.m_root)
		textExpireKey:setPos(55, 120) --130 + 137 + 20
		textExpireKey:setAlign(kAlignBottomLeft)
		local textExpireValue = new(Text, str,
			nil, nil, kAlignLeft, nil, 20, 0xff, 0xf0, 0xa0)
		textExpireValue:addTo(self.m_root)
		textExpireValue:setPos(55 + textExpireKey:getSize() + 2, 120) -- 130 + 137 + 20
		textExpireValue:setAlign(kAlignBottomLeft)
	end
end

function PropDetailPopup:checkAndAddSendStatus()
	if tonumber(self.config["sendStatus"]) == 1 then
		local imageBgForSendableFlag = new(Image, kImageMap.userInfo_prop_text_bg_1)
		imageBgForSendableFlag:addTo(self.m_root)
		imageBgForSendableFlag:setAlign(kAlignBottomLeft)
		imageBgForSendableFlag:setPos(230 + 300 * 0.6, 120) --
		local textSendable = new(Text, bm.LangUtil.getText("USERINFO", "PROP_SENDABLE"),
			nil, nil, kAlignLeft, nil, 20, 0xe6, 0xd7, 0xfb)
		textSendable:addTo(imageBgForSendableFlag)
		textSendable:setAlign(kAlignCenter)
		local w, h = imageBgForSendableFlag:getSize()
		imageBgForSendableFlag:setSize(math.max(w, textSendable:getSize() + 10), h)
	end
end


function PropDetailPopup:onBtnExchangeClick()
	if not self.infoCollector then
		return
	end
	local info = {}
	for i = 1, #self.infoCollector do
		local text = self.infoCollector[i][2]:getText()
		if text and not string.match(text, "^%s*$") then
			info[self.infoCollector[i][1]] = text
		else
			-- 提示 ，请输入
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_EXCHANGE_INFO_TIPS"))
			return
		end
	end
	self.btnExchange:setEnable(false)
	PropManager.getInstance():exchProp(self.data.pnid, info, function(status)
		if not tolua.isnull(self) then
			if not status then
				self.btnExchange:setEnable(true)
			else
				self:dismiss()
			end
		end
	end)
end

return PropDetailPopup