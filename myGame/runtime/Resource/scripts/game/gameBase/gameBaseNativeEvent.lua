-- gameBaseNativeEvent.lua
-- Last modification : 2016-05-11
-- Description: a gamebase of native event

GameBaseNativeEvent = class();

function GameBaseNativeEvent:ctor()
    EventDispatcher.getInstance():register(EventConstants.onEventCallBack, self, self.onNativeCall);
end

function GameBaseNativeEvent:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.onEventCallBack, self, self.onNativeCall);
end

function GameBaseNativeEvent:onNativeCall(key, status, data, ...)
    if self.s_nativeHandle[key] then
        self.s_nativeHandle[key](self, status, data, ...)
    end
end

GameBaseNativeEvent.s_nativeHandle = {
    -- ["***"] = function
}
