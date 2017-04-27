local UmengNativeEvent = class(GameBaseNativeEvent)
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function UmengNativeEvent:ctor()
    
end

function UmengNativeEvent:dtor()
    
end

function UmengNativeEvent:report(id,type)
    self:onEventCount(id)
end

function UmengNativeEvent:reportValue(id,args,value)
    self:onEventCountValue(id, args, value)
end

--计数事件，就是只统计事件触发次数
function UmengNativeEvent:onEventCount(eventId)
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_UMENG_EVENT_COUNT, kCallParamString, eventId)
end

--计算事件，该事件有数值纪录
function UmengNativeEvent:onEventCountValue(eventId,args,value)
	local params = {}
	params.eventId = eventId
	params.args = args
	params.value = value
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_UMENG_EVENT_COUNT_VALUE, kCallParamJsonString, params)
end

--上报Lua错误
function UmengNativeEvent:reportError(errorStr)
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_UMENG_ERROR, kCallParamString, errorStr)
end

---------------------------------nativeHandle-----------------------------------


UmengNativeEvent.s_nativeHandle = {
    -- ["***"] = function
}

return UmengNativeEvent