-- adapter.lua
-- Author: XXX
-- Date:   XXXX-XX-XX
local PopupModel = import('game.popup.popupModel')
local popupView = require(VIEW_PATH .. "downloadGames/get_reward")
local varConfigPath = VIEW_PATH .. "downloadGames/get_reward_layout_var"

local GetRewardPopup = class(PopupModel);

function GetRewardPopup.show(data)
	PopupModel.show(GetRewardPopup, popupView, varConfigPath, {name="GetRewardPopup"}, data)
end

function GetRewardPopup.hide()
	PopupModel.hide(GetRewardPopup)
end

function GetRewardPopup:ctor(viewConfig, varConfigPath, data)
    self.data_ = data; -- 从downloadItem 的对象
	self:addShadowLayer()
	self:initLayer()
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function GetRewardPopup:initLayer()
	self.image_bg_ = self:getUI("Image_bg")
	self:addCloseBtn(self.image_bg_)

	self.text_info = self:getUI("text_info")
	self.text_info:setText(bm.LangUtil.getText("DOWNLOAD_GAMES", "EXCHANGE_TIILE"))

	self.EditText_id = self:getUI("EditText_id")
	self.EditText_id:setText("")
	self.EditText_id:setHintText(bm.LangUtil.getText("DOWNLOAD_GAMES", "EXCHANGE_HINT"), 0xab, 0x5f, 0xec)
    self.EditText_id:setMaxLength(12)

    self.btn_get_reward_text = self:getUI("btn_get_reward_text")
    self.btn_get_reward_text:setText(bm.LangUtil.getText("DOWNLOAD_GAMES", "BTN_GET_REWARD"))
end

function GetRewardPopup:onBtnGetRewardClick()
	local str = string.trim(self.EditText_id:getText())

	if str ~= "" then
		self:getReward()
	else
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOWNLOAD_GAMES", "NO_TEXT_HINT"))
	end
end

function GetRewardPopup:getReward()
	self:setLoading(true)

	local params = {}   --{"mid", "cekuid", "game"}
    params.mid = nk.userData.mid --
    params.cekuid = string.trim(self.EditText_id:getText())
    params.game = self.data_.data.game_name
	nk.HttpController:execute("Advert.getAward", {game_param = params})
end

function GetRewardPopup:onHttpProcesser(command, code, content)
	if command == "Advert.getAward" then
		self:setLoading(false)

		if code ~= 1 then
			return
		end

		self.m_retData = content.data

		if self.m_retData["ret"] and self.m_retData["ret"] == 1 and self.m_retData["str"] then

			-- item 显示为已兑换
			self.data_.btn_exchange:setEnable(false)
			self.data_.btn_exchange_text:setText(bm.LangUtil.getText("DOWNLOAD_GAMES", "BTN_EXCHANGE_FINISH"))

			nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOWNLOAD_GAMES", "GET_REWARD") .. self.m_retData["str"])
			self:hide()
			
		elseif self.m_retData["ret"] and self.m_retData["msg"] then
			nk.TopTipManager:showTopTip(self.m_retData["msg"])
		end
		
    -- elseif command == "" then

	end
end

function GetRewardPopup:setLoading(isLoading)
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

function GetRewardPopup:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

return GetRewardPopup

