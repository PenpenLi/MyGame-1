-- adapter.lua
-- Author: XXX
-- Date:   XXXX-XX-XX

local popupView = require(VIEW_PATH .. "downloadGames/game_item")
local varConfigPath = VIEW_PATH .. "downloadGames/game_item_layout_var"

local DownloadGamesItem = class(GameBaseLayer, false)

function DownloadGamesItem:ctor(data)
    super(self, popupView);
	self:declareLayoutVar(varConfigPath)
	
    self.data = data
    self:setSize(self.m_root:getSize());
    self:init()

    if self.data then
	    self:setData()
	end

end

function DownloadGamesItem:init()
	self.img_icon = self:getUI("img_icon")
	self.text_desc = self:getUI("text_desc")

	self.btn_exchange = self:getUI("btn_exchange")
	self.btn_exchange_text = self:getUI("btn_exchange_text")

	-- 需要加一个字段是否兑换了
	if self.data["isGet"] and self.data["isGet"] == 1 then
		self.btn_exchange:setEnable(false)
		self.btn_exchange_text:setText(bm.LangUtil.getText("DOWNLOAD_GAMES", "BTN_EXCHANGE_FINISH"))
	else
		self.btn_exchange_text:setText(bm.LangUtil.getText("DOWNLOAD_GAMES", "BTN_EXCHANGE"))
	end
	

	self.btn_download = self:getUI("btn_download")
	self.btn_download_text = self:getUI("btn_download_text")
	self.btn_download_text:setText(bm.LangUtil.getText("DOWNLOAD_GAMES", "BTN_DOWNLOAD"))
end

function DownloadGamesItem:setData()
	
	UrlImage.spriteSetUrl(self.img_icon, self.data.image, true)

	self.text_desc:setText(self.data.game_des)
end

function DownloadGamesItem:onBtnExchangeClick()
	nk.AnalyticsManager:report("New_Gaple_download_games_btn_exchange")

	nk.PopupManager:addPopup(require("game.downloadGames.getRewardPopup"), "downloadGames" , self)
end

function DownloadGamesItem:onBtnDownloadClick()
	nk.AnalyticsManager:report("New_Gaple_download_games_btn_download")

	nk.GameNativeEvent:openBrowser(self.data.game_url)
end

return DownloadGamesItem
