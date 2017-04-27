-- adStatsNativeEvent.lua
-- Last modification : 2016-05-24
-- Description: a native event controller for facebook ad statistics moudle

local UnityAdsNativeEvent = class(GameBaseNativeEvent)
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function UnityAdsNativeEvent:ctor()
    
end

function UnityAdsNativeEvent:dtor()
    
end

function UnityAdsNativeEvent:unityAdsIsReady() -- 1表示加载好，0表示没有加载好
	local key = NativeEventConfig.NATIVE_UNITY_ADS_IS_READY

	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_UNITY_ADS_IS_READY, kCallParamNo)

	local result = dict_get_int(key, key .. kResultPostfix, 0)
	return result
end

function UnityAdsNativeEvent:unityAdsShow()
	local isReady = self:unityAdsIsReady()
	if isReady == 1 then
		-- nk.TopTipManager:showTopTip("unityAds isReady:" .. isReady)
		nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_UNITY_ADS_SHOW, kCallParamNo)
	elseif isReady == 0 then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("UNITY_ADS", "VIDEO_NOT_READY"))
	end
	
end
---------------------------------nativeHandle-----------------------------------
function UnityAdsNativeEvent:unityAdsCallBack(status, data)
    -- nk.TopTipManager:showTopTip("unityAds callback status:" .. tostring(status))
    -- Log.printInfo("UnityAdsNativeEvent","unityAdsCallBack")

    if status then
    	local params = {}
	    params.mid = nk.userData.mid -- 
		nk.HttpController:execute("Advert.sendAward", {game_param = params})
    else
    	nk.TopTipManager:showTopTip(bm.LangUtil.getText("UNITY_ADS", "VIDEO_ERROR"))
    end

    
end


UnityAdsNativeEvent.s_nativeHandle = {
    -- ["***"] = function
    [NativeEventConfig.NATIVE_UNITY_ADS_CALLBACK] = UnityAdsNativeEvent.unityAdsCallBack,
}

return UnityAdsNativeEvent