-- adStatsNativeEvent.lua
-- Last modification : 2016-05-24
-- Description: a native event controller for facebook ad statistics moudle

local AdStatsNativeEvent = class(GameBaseNativeEvent)
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function AdStatsNativeEvent:ctor()
    
end

function AdStatsNativeEvent:dtor()
    
end

function AdStatsNativeEvent:reportStart()
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_START, kCallParamNo)
end

function AdStatsNativeEvent:reportReg()
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_REG, kCallParamNo)
end

function AdStatsNativeEvent:reportLogin()
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_LOGIN, kCallParamNo)
end

function AdStatsNativeEvent:reportPlay()
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_PLAY, kCallParamNo)
end

--金额，币种
function AdStatsNativeEvent:reportPay(payMoney,currencyCode)
	local params = {}
	params.payMoney = payMoney
	params.currencyCode = currencyCode
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_PAY, kCallParamJsonString, params)
end

--召回上报，FB ID（游客时用游客ID）
function AdStatsNativeEvent:reportRecall(fbid)
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_RECALL, kCallParamString, fbid)
end

function AdStatsNativeEvent:reportLogout()
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_LOGOUT, kCallParamNo)
end

--自定义
function AdStatsNativeEvent:reportCustom(eventName)
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_AD_STATISTICS_CUSTOM, kCallParamString, eventName)
end

---------------------------------nativeHandle-----------------------------------



AdStatsNativeEvent.s_nativeHandle = {
    -- ["***"] = function
}

return AdStatsNativeEvent