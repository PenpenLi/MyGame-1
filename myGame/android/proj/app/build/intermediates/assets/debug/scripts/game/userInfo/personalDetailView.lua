local PersonalDetailView = class(Node)

local TEXT_WIDTH = 170

function PersonalDetailView:ctor(width, height, popup)
	self.widthOfView, self.heightOfView = width, height
	self.popup = popup
	self:initView()
end

function PersonalDetailView:dtor()
end

function PersonalDetailView:initView()
	-- local keys = {
	-- 	"Money",
	-- 	"Money Rank",
	-- 	"Match Count",
	-- 	"Win Rate",
	-- 	"Friends Count",
	-- 	"Fans Count",
	-- 	"Exp",
	-- 	"VIP LV",
	-- }
	local keys = {
		"KEY_MONEY",
		"KEY_MONEY_RANK",
		"KEY_MATCH_COUNT",
		"KEY_WIN_RATE",
		-- "KEY_FRIEND_CNT",
		-- "KEY_FANS_CNT",
		"KEY_MONTH_CHARM",
		"KEY_HISTORY_CHARM",
		"KEY_EXP",
		"KEY_VIP_LV",
	}
	self.dictTextValues = {}
	local colIndex = 1
	local rowIndex = 1
	local eachHeight = 52.5
	local strColon = bm.LangUtil.getText("COMMON", "COLON")
	for i = 1, #keys do
		local textKey = new(Text, bm.LangUtil.getText("USERINFO", keys[i]) .. strColon, nil, 20, nil, nil, 18, 0xfa, 0xe6, 0xff)
		textKey:addTo(self)
		textKey:setPos(25 + (colIndex - 1) * self.widthOfView/2, 25 + (rowIndex - 1) * eachHeight)

		local btnPath
		local btnHandler
		if self.popup.isUser and keys[i] == "KEY_EXP" then
			btnPath = "/res/userInfo/userInfo_btn_question.png"
			btnHandler = self.onBtnQuestionClick
		elseif self.popup.isUser and keys[i] == "KEY_VIP_LV" then
			btnPath = "/res/userInfo/userInfo_btn_add.png"
			btnHandler = self.onBtnBuyVipClick
		end
		local widthOfText = TEXT_WIDTH
		if btnPath then
			local btn = new(Button, btnPath)
			btn:addTo(self)
			btn:setPos(25 + 20 + (colIndex - 1) * self.widthOfView/2 + 140, 25 + (rowIndex - 1) * eachHeight - 10)
			btn:setOnClick(self, btnHandler)
			widthOfText = widthOfText - 35
			self.btnSaveDict = self.btnSaveDict or {}
			self.btnSaveDict[keys[i]] = btn
		end

		local widthOfTextKey = textKey:getSize()
		local textValue = new(Text, "N/A", widthOfText, 20, kAlignRight, nil, 18, 255, 255, 255)
		textValue:addTo(self)
		textValue:setPos(25 + 20 + (colIndex - 1) * self.widthOfView/2, 25 + (rowIndex - 1) * eachHeight)
		self.dictTextValues[keys[i]] = textValue

		rowIndex = rowIndex + 1
		if i == 4 then
			colIndex = colIndex + 1
			rowIndex = 1
			-- eachHeight = 40
		end
	end

	local imgDivider = new(Image, "res/userInfo/userInfo_divider_vertical.png")
	imgDivider:addTo(self)
	imgDivider:setPos(250, 15)
	imgDivider:setSize(3, self.heightOfView - 20)
end

function PersonalDetailView:setData(data)
	-- FwLog("data>>>>" .. json.encode(data))
	local money = data.aUser.money or 0
	local moneyRank = data.aBest.rankMoney
	local win = tonumber(data.aUser.win) or 0
	local lose = tonumber(data.aUser.lose) or 0
	local total = win + lose
	local winRate = math.floor((win / math.max(total, 1)) * 100) .. "%"
	local matchCount = total
	local friendCnt = 1
	local fansCnt = 1
	local ratio, progress, all = nk.Level:getLevelUpProgress(data.aUser.exp)
	local expValue = (progress or 0) .. "/" .. (all or "0")
	local vipLv = tonumber(data.aUser.vip) or 0
	local charm = data.aUser.charm or 0
	local mcharm = data.aUser.mcharm or 0

	if vipLv > 0 and self.popup.isUser then
		self.btnSaveDict["KEY_VIP_LV"]:setVisible(false)
		self.dictTextValues["KEY_VIP_LV"]:setText("", TEXT_WIDTH, 20)
	end

	self.dictTextValues["KEY_MONEY"]:setText(nk.updateFunctions.getFormatNumber(money, ",", 10))
	self.dictTextValues["KEY_MONEY_RANK"]:setText(moneyRank)
	self.dictTextValues["KEY_MATCH_COUNT"]:setText(matchCount)
	self.dictTextValues["KEY_WIN_RATE"]:setText(winRate)
	if self.dictTextValues["KEY_FRIEND_CNT"] then
		self.dictTextValues["KEY_FRIEND_CNT"]:setText(friendCnt)
	end
	if self.dictTextValues["KEY_FANS_CNT"] then
		self.dictTextValues["KEY_FANS_CNT"]:setText(fansCnt)
	end
	self.dictTextValues["KEY_EXP"]:setText(expValue)
	self.dictTextValues["KEY_HISTORY_CHARM"]:setText(charm)
	self.dictTextValues["KEY_MONTH_CHARM"]:setText(mcharm)
	self.dictTextValues["KEY_VIP_LV"]:setText(vipLv)
end

function PersonalDetailView:onBtnQuestionClick()
	local RulesPopup = require("game.setting.rulesPopup")
	nk.PopupManager:addPopup(RulesPopup, self.popup.currentScene, 3)
end

function PersonalDetailView:onBtnBuyVipClick()
	local vipPopup = require("game.store.vip.vipPopup")
	if self.popup.ctx and self.popup.ctx.model then
		local level = self.popup.ctx.model:roomType()
		nk.PopupManager:addPopup(vipPopup, self.popup.currentScene, true, level, "vip")
	else
		nk.PopupManager:addPopup(vipPopup, self.popup.currentScene, nil, nil, "vip")
	end
	self.popup:hide()
	nk.AnalyticsManager:report("New_Gaple_info_click_vip")
end

return PersonalDetailView