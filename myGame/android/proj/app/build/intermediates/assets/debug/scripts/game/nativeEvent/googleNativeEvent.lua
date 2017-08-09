-- googleNativeEvent.lua
-- Last modification : 2016-05-24
-- Description: a native event controller for google moudle

local GoogleNativeEvent = class(GameBaseNativeEvent)
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function GoogleNativeEvent:ctor()
    
end

function GoogleNativeEvent:dtor()
    
end

-- @params table data
-- data = {
    
-- }
function GoogleNativeEvent:pay(data)
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GOOGLE_PAY, kCallParamJsonString, data, NativeEventConfig.NATIVE_GOOGLE_PAY_CALLBACK)
end

function GoogleNativeEvent:getToken()
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GOOGLE_GET_TOKEN, kCallParamNo)
end

---------------------------------nativeHandle-----------------------------------

function GoogleNativeEvent:onPayCallBack(status, data)
    Log.printInfo("GoogleNativeEvent","onPayCallBack")
end

function GoogleNativeEvent:onTokenBack(status, data)
    Log.printInfo("GoogleNativeEvent","onTokenBack")
    if status then
    	nk.HttpController:execute("googleTokenReport", {game_param={type=2,clientid=data}, lid = 2})
    end
end

GoogleNativeEvent.s_nativeHandle = {
    -- ["***"] = function
    [NativeEventConfig.NATIVE_GOOGLE_PAY_CALLBACK] = GoogleNativeEvent.onPayCallBack,
    [NativeEventConfig.NATIVE_GOOGLE_TOKEN_CALLBACK] = GoogleNativeEvent.onTokenBack,
}

return GoogleNativeEvent