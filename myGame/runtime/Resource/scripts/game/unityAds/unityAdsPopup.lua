-- unityAdsPopup.lua
-- Author: Allen Yue
-- Date:   2016-12-14

local PopupModel = import('game.popup.popupModel')
local popupView = require(VIEW_PATH .. "unityAds/unity_ads")
local varConfigPath = VIEW_PATH .. "unityAds/unity_ads_layout_var"

local UnityAdsPopup = class(PopupModel);

function UnityAdsPopup.show(data)
	PopupModel.show(UnityAdsPopup, popupView, varConfigPath, {name="UnityAdsPopup"}, data)
end

function UnityAdsPopup.hide()
	PopupModel.hide(UnityAdsPopup)
end

function UnityAdsPopup:ctor(viewConfig, varConfigPath, data)
    self.data_ = data;
    self:addShadowLayer()
	self:initLayer()
	
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function UnityAdsPopup:initLayer()
	self.image_bg_ = self:getUI("Image_bg")
	self:addCloseBtn(self.image_bg_)

	self.Text_title = self:getUI("Text_title")
	self.Text_title:setText(bm.LangUtil.getText("UNITY_ADS", "TITLE"))
	
	self.img_loading_ = self:getUI("img_loading")
	self.text_loading = self:getUI("text_loading")
	self.text_loading:setText(bm.LangUtil.getText("UNITY_ADS", "VIDEO_NOT_READY"))

	self.text_desc = self:getUI("text_desc")
	self.text_reward = self:getUI("text_reward")

	self.text_desc:setVisible(false)
	self.text_reward:setVisible(false)

	self.btn_video = self:getUI("btn_video")
	self.btn_video:setVisible(false)

	local isReady = nk.UnityAdsNativeEvent:unityAdsIsReady()
	if isReady == 1 then
		self.img_loading_:setVisible(false)
	elseif isReady == 0 then
		self.img_loading_:setVisible(true)
	end

	self.schedule = Clock.instance():schedule(function (dt)
                self:scheduleHandler()
            end, 1)

	self:requestInfo()

	-- nk.UnityAdsNativeEvent:unityAdsCallBack(true, "")
end

function UnityAdsPopup:requestInfo()
	self:setLoading(true)

	local params = {}
    params.mid = nk.userData.mid -- 
	nk.HttpController:execute("Advert.getAdList", {game_param = params})

	nk.AnalyticsManager:report("New_Gaple_open_unity_ads")
end

function UnityAdsPopup:onHttpProcesser(command, code, content)
	if command == "Advert.getAdList" then
		self:setLoading(false)

		if code ~= 1 then
			return
		end

		self.m_adsData = content.data

		if self.m_adsData and self.m_adsData["des"] and self.m_adsData["str"] then
			self.text_desc:setVisible(true)
			self.text_reward:setVisible(true)

			self.btn_video:setVisible(true)

			self.text_desc:setText(self.m_adsData["des"])
			self.text_reward:setText(self.m_adsData["str"])

			if self.m_adsData["str"] == "" then -- 达到次数上限
				self:unityAdsMaxCount()
			end
			
		end

    elseif command == "Advert.sendAward" then
    	if code ~= 1 then
			return
		end

		self.m_adsRewardData = content.data

		if self.m_adsRewardData and self.m_adsRewardData["str"] and self.m_adsRewardData["nextStr"] then --str当次成功获得奖励，nextStr下次奖励的

			self.text_reward:setText(self.m_adsRewardData["nextStr"]) --要设置成下次的

			--nk.TopTipManager:showTopTip(bm.LangUtil.getText("UNITY_ADS", "VIDEO_GET_REWARD") .. self.m_adsRewardData["str"])

			nk.unityadsTimes = nk.unityadsTimes - 1

			if self.m_adsRewardData["nextStr"] == ""  then --达到次数上限
				self:unityAdsMaxCount()
			end
		end

		
	end
end

function UnityAdsPopup:unityAdsMaxCount()
	if self.schedule then
        self.schedule:cancel()
        self.schedule = nil
	end

	self.img_loading_:setVisible(true)
	self.text_loading:setText(bm.LangUtil.getText("UNITY_ADS", "VIDEO_MAX_COUNT"))
end

function UnityAdsPopup:scheduleHandler()
	local isReady = nk.UnityAdsNativeEvent:unityAdsIsReady()
	if isReady == 1 then
		self.img_loading_:setVisible(false)
	elseif isReady == 0 then
		self.img_loading_:setVisible(true)
	end
end

function UnityAdsPopup:onBtnVideoClick()
	nk.AnalyticsManager:report("New_Gaple_unityads_btn_video")

	nk.UnityAdsNativeEvent:unityAdsShow()
end

function UnityAdsPopup:onImgLoadingClick()
	--
end


function UnityAdsPopup:setLoading(isLoading)
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

function UnityAdsPopup:dtor()
	if self.schedule then
        self.schedule:cancel()
        self.schedule = nil
    end

    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

return UnityAdsPopup