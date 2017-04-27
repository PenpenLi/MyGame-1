-- adapter.lua
-- Author: XXX
-- Date:   XXXX-XX-XX

local PopupModel = import('game.popup.popupModel')
local popupView = require(VIEW_PATH .. "downloadGames/download_games")
local varConfigPath = VIEW_PATH .. "downloadGames/download_games_layout_var"

local DownloadGamesItem = require("game.downloadGames.downloadGamesItem") 

local DownloadGamesPopup = class(PopupModel);

function DownloadGamesPopup.show(data)
	PopupModel.show(DownloadGamesPopup, popupView, varConfigPath, {name="DownloadGamesPopup"}, data)
end

function DownloadGamesPopup.hide()
	PopupModel.hide(DownloadGamesPopup)
end

function DownloadGamesPopup:ctor(viewConfig, varConfigPath, data)
    self.data_ = data;
	self:addShadowLayer()
	self:initLayer()
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)

	self:requestGamesInfo()
end

function DownloadGamesPopup:initLayer()
	self.image_bg_ = self:getUI("Image_bg")
	self:addCloseBtn(self.image_bg_)

	self.Text_title = self:getUI("Text_title")
	self.Text_title:setText(bm.LangUtil.getText("DOWNLOAD_GAMES", "TITLE"))

	self.text_info = self:getUI("text_info")
	self.text_info:setVisible(false)

	self.ScrollView_games = self:getUI("ScrollView_games")
	self.text_no_games = self:getUI("text_no_games")
	self.text_no_games:setVisible(false)
end

function DownloadGamesPopup:requestGamesInfo()
	self:setLoading(true)

	local params = {}
    params.mid = nk.userData.mid --
	nk.HttpController:execute("Advert.getList", {game_param = params})

    nk.AnalyticsManager:report("New_Gaple_open_download_games")
end

function DownloadGamesPopup:onHttpProcesser(command, code, content)
	if command == "Advert.getList" then
		self:setLoading(false)

		if code ~= 1 then
			return
		end

		self.m_gameData = content.data
		self:fillList()

    -- elseif command == "" then

	end
end

function DownloadGamesPopup:fillList()
	if self.m_gameData and self.m_gameData["list"] and type(self.m_gameData["list"]) == "table" and #(self.m_gameData["list"])>0 then
		self.ScrollView_games:removeAllChildren()

		local pos_x, pos_y = 0, 0
        for i,v in ipairs(self.m_gameData["list"]) do
            local item = new(DownloadGamesItem, v)
            local width, height = item:getSize()
            item:setPos(pos_x, pos_y)

            self.ScrollView_games:addChild(item)

            pos_y = pos_y + height
        end

		self.text_no_games:setVisible(false)

		self.text_info:setText(self.m_gameData.des)
		self.text_info:setVisible(true)
	else
		self.text_no_games:setVisible(true)
	end
end

function DownloadGamesPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.image_bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function DownloadGamesPopup:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

return DownloadGamesPopup