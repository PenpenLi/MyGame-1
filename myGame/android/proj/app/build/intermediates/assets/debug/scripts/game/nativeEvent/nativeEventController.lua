-- nativeEventController.lua
-- Last modification : 2016-05-19
-- Description: a controller in nativeEvent moudle

-- 本地事件方法

local NativeEventController = class();

function NativeEventController.getInstance()
    if not NativeEventController.s_instance then 
        NativeEventController.s_instance = new(NativeEventController);
    end
    return NativeEventController.s_instance;
end

function NativeEventController.releaseInstance()
    if NativeEventController.s_instance then 
        delete(NativeEventController.s_instance)
        NativeEventController.s_instance = nil
    end
end

function NativeEventController:ctor()
    EventDispatcher.getInstance():register(Event.Call, self, self.getNativeCallResult);
end

function NativeEventController:dtor()
    EventDispatcher.getInstance():unregister(Event.Call, self, self.getNativeCallResult);
end

---
-- lua 调用 java  并根据类型处理 data 
-- 
-- @param string key 键值，在nativeEventConfig中定义的key
-- @param number dataType 数据类型，在nativeEventConfig中定义
-- @param data dataType对应类型的数据
-- @param keyBack 供win32回调
-- @param backData 供win32回调数据 

function NativeEventController:callNativeEvent(key, dataType, data, keyBack, backData)
    if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
        if data then
            if dataType == kCallParamInt and type(data) == "number" then
                dict_set_int(key, key..kParmPostfix, data);
            elseif dataType == kCallParamDouble and type(data) == "number" then
                dict_set_double(key, key..kParmPostfix, data);
            elseif dataType == kCallParamString and type(data) == "string" then
                dict_set_string(key, key..kParmPostfix, data);
            elseif dataType == kCallParamJsonString and type(data) == "table" then
                dict_set_string(key, key..kParmPostfix, json.encode(data));
            end
        end
        dict_set_string(kLuaCallFuc, kLuaCallFuc, key);
        call_native(kLuaCallNavite);
    elseif System.getPlatform() == kPlatformWin32 then
        if keyBack then
            -- win32 直接 return backData
            Log.printInfo("native", "NativeEventController.getNativeCallResult keyBack " .. keyBack)
            Log.printInfo("native", "NativeEventController.getNativeCallResult data " .. tostring(backData))
            self:onEventCall(keyBack, false, backData)
        end
    end
end

---
-- java 调用 lua  并根据类型处理返回值 data
-- 
-- @param string key
-- @param data
-- 
function NativeEventController:getNativeCallResult()
    Log.printInfo("native", "NativeEventController.getNativeCallResult");
    local key = dict_get_string(kLuaEventCall, kLuaEventCall);
    local callResult = dict_get_int(key, kCallResult, -1);

    Log.printInfo("native", "NativeEventController.callResult " .. callResult);

    local resultParamType = dict_get_int(key, kCallParamType, -1);
    Log.printInfo("native", "NativeEventController.getNativeCallResult key = "..key.." =========");

    local result = nil
    if resultParamType == kCallParamInt then
        result = dict_get_int(key , key .. kResultPostfix);
    elseif resultParamType == kCallParamDouble then
        result = dict_get_double(key , key .. kResultPostfix);
    elseif resultParamType == kCallParamString then
        result = dict_get_string(key , key .. kResultPostfix);
    elseif resultParamType == kCallParamJsonString then
        result = dict_get_string(key , key .. kResultPostfix);
        Log.printInfo("native", "NativeEventController.getNativeCallResult result = "..result.." =========")
        result = json.decode(result);
    elseif resultParamType == kCallParamBoolean then
        result = dict_get_boolean(key , key .. kResultPostfix);
    end
    
    dict_delete(key);

    Log.printInfo("native", "NativeEventController.getNativeCallResult result = ".. tostring(result).." =========")

    if callResult == kResultSucess then -- 成功,参照kCallResult类型
        Log.printInfo("native", "NativeEventController kResultSucess")
        self:onEventCall(key, true, result)
        return
    elseif callResult == kResultFail then -- 失败
        self:onEventCall(key, false, "fail", result)
        return
    elseif callResult == kResultCancle then -- 取消
        self:onEventCall(key, false, "cancle", result)
        return
    elseif callResult == -1 then
        self:onEventCall(key, false, "error")
        return
    end
end

function NativeEventController:onEventCall(key, status, data)
    Log.printInfo("native", "NativeEventController:onEventCall and key " .. key)
    EventDispatcher.getInstance():dispatch(EventConstants.onEventCallBack, key, status, data);
end

return NativeEventController

