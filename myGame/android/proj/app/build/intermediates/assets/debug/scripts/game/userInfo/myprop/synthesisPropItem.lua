local SynthesisPropItem = class(Node)
local PropManager = require("game.store.prop.propManager")

function SynthesisPropItem:ctor(data)
	-- FwLog("SynthesisPropItem:ctor>" .. json.encode(data))
	local startX, startY = 20, 0
	self.data = data
	-- assert(data.synt, "no synt!")
	local isSynthesisable = true
	self.materailTexts = {}
	for i = 1, #data.synt do
		local image = new(Image, kImageMap.userInfo_propItem_bg)
		image:addTo(self)
		image:setSize(100 * 0.9, 97 * 0.9)
		image:setPos(startX + (i - 1) * 110, startY)
		local icon = nk.functions.addPropIconTo(image, data.synt[i], 80)
		-- t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue
		local propInfo = PropManager.getInstance():getUserPropInfo(data.synt[i].pnid)
		local ownPropCnt = 0
    	if propInfo then
			ownPropCnt = tonumber(propInfo.pcnter) or 1
		end
		local text = new(Text, ownPropCnt .. "/" .. data.synt[i].num, nil, nil, nil, nil, 20, 0xe6, 0xd7, 0xfb)
		if isSynthesisable and ownPropCnt < tonumber(data.synt[i].num) then
			isSynthesisable = false
		end
		text:addTo(image)
		text:setAlign(kAlignBottom)
		text:setPos(0, -23)
		table.insert(self.materailTexts, text)
	end

	local image = new(Button, kImageMap.userInfo_propItem_bg)
	image:addTo(self)
	image:setSize(100 * 0.9, 97 * 0.9)
	image:setPos(startX + (4 - 1) * 110 + 220, startY)
	local configGetter = {}
	setmetatable(configGetter, {__newindex = function(table, key, value)
		if key == "config" then
			if not tolua.isnull(image) then
				local textBg = new(Image, kImageMap.lottery_name_bg)
				textBg:addTo(image)
				textBg:setAlign(kAlignBottom)
				textBg:setPos(0, -23)
				
				local text = new(Text, value.name, nil, nil, nil, nil, 18, 0xff, 0xd7, 0x00)
				text:addTo(textBg)
				text:setAlign(kAlignCenter)
				textBg:setSize(math.max(text:getSize() + 20, 80), 22)
			end
		end
	end})
	image:setOnClick(self, self.onSynthesisBtnClick)
	self.syntTarget = image
	local icon = nk.functions.addPropIconTo(image, data, 80, configGetter)
	-- nk.functions.registerImageTouchFunc(image, self, self.onSynthesisBtnClick)

	self:refreshState(isSynthesisable)

	local divisionLine = new(Image, kImageMap.userInfo_divider_horizontal)
	divisionLine:addTo(self)
	divisionLine:setPos(10, 118)
	divisionLine:setSize(664, 2)
	EventDispatcher.getInstance():register(EventConstants.PROP_INFO_CHANGED, self, self.onPropInfoChanged)
end

function SynthesisPropItem:refreshState(isSynthesisable)
	local startX = 20
	local needRemoveNode = {}
	self.isSynthesisable  = isSynthesisable
	if isSynthesisable then
		local synthesisBtn = new(Button, kImageMap.common_transparent)
		synthesisBtn:addTo(self)
		synthesisBtn:setSize(100 * 0.9, 97 * 0.9)
		synthesisBtn:setPos(startX + (5 - 1) * 110 + 13, 0)-- + (97 * 0.9 - 48) * 0.5 - 10
		synthesisBtn:setOnClick(self, self.onSynthesisBtnClick)
		table.insert(needRemoveNode, synthesisBtn)

		local image = new(Image, kImageMap.userInfo_exchange_exchangable)
		image:addTo(synthesisBtn)
		image:setAlign(kAlignCenter)
		image:setPos(0, -10)
		local text = new(Text, bm.LangUtil.getText("USERINFO", "SYNTHESIS_PROP"))
		text:addTo(image)
		text:setAlign(kAlignBottom)
		text:setPos(0, -25)

		local deco = new(Image, kImageMap.userInfo_propItem_deco)
		deco:addTo(self.syntTarget)
		deco:setAlign(kAlignCenter)
		deco:addPropScaleSolid(0, 0.7, 0.7, kCenterDrawing)
		deco:setLevel(-1)
		table.insert(needRemoveNode, deco)

		local deco2 = new(Image, kImageMap.lottery_select)
		deco2:addTo(self.syntTarget)
		deco2:setAlign(kAlignCenter)
		deco2:setLevel(1)
		deco2:addPropScaleSolid(0, 0.74, 0.71, kCenterDrawing)
		table.insert(needRemoveNode, deco2)

		local deco3 = new(Image, kImageMap.lottery_select_star)
		deco3:addTo(self.syntTarget)
		deco3:setAlign(kAlignCenter)
		deco3:setLevel(1)
		deco3:addPropScaleSolid(0, 0.9, 0.9, kCenterDrawing)
		table.insert(needRemoveNode, deco3)
	else
		local image = new(Button, kImageMap.userInfo_exchange_unexchangable)
		image:addTo(self)
		image:setPos(startX + (5 - 1) * 110 + 27, (97 * 0.9 - 48) * 0.5 - 10)
		image:setOnClick(self, self.onSynthesisBtnClick)
		local text = new(Text, bm.LangUtil.getText("USERINFO", "SYNTHESIS_PROP"))
		text:addTo(image)
		text:setAlign(kAlignBottom)
		text:setPos(0, -25)
		table.insert(needRemoveNode, image)
	end
	self.needRemoveNode = needRemoveNode
end

function SynthesisPropItem:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.PROP_INFO_CHANGED, self, self.onPropInfoChanged)
end

function SynthesisPropItem:onSynthesisBtnClick()
	nk.AnalyticsManager:report("New_Gaple_click_synt_synt")
	if not self.isSynthesisable then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_SYNTPROP_NOT_QUALIFIED"))
		return
	end
	PropManager.getInstance():syntProp(self.data.pnid, function(status)

	end)
end

function SynthesisPropItem:onPropInfoChanged()
	local data = self.data
	local isSynthesisable = true
    for i = 1, #data.synt do
    	local propInfo = PropManager.getInstance():getUserPropInfo(data.synt[i].pnid)
    	local ownPropCnt = 0
    	if propInfo then
			ownPropCnt = tonumber(propInfo.pcnter) or 1
		end
		if self.materailTexts[i] then
			self.materailTexts[i]:setText(ownPropCnt .. "/" .. data.synt[i].num, 0, 0)
		end
		if isSynthesisable and ownPropCnt < tonumber(data.synt[i].num) then
			isSynthesisable = false
		end
    end
    if self.needRemoveNode then
    	for i = 1, #self.needRemoveNode do
    		delete(self.needRemoveNode[i])
    		FwLog("delete one!")
    	end
    end
    self:refreshState(isSynthesisable)
end

return SynthesisPropItem