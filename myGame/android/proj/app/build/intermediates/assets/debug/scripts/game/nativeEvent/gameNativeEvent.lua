-- gameNativeEvent.lua
-- Last modification : 2016-05-24
-- Description: a native event controller for gaple game normal function moudle

local GameNativeEvent = class(GameBaseNativeEvent)
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function GameNativeEvent:ctor()
    EventDispatcher.getInstance():register(Event.KeyDown, self, self.onKeyDown)
end

function GameNativeEvent:dtor()
    EventDispatcher.getInstance():unregister(Event.KeyDown, self, self.onKeyDown)
end

-- 更换头像  data.mode =1 or 2 , 相册 or 拍照
function GameNativeEvent:pickImage(data,posIndex,imgIndex)
    self.posIndex = posIndex
    self.imgIndex = imgIndex
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GAME_PICKIMAGE, kCallParamJsonString, data, NativeEventConfig.NATIVE_GAME_PICKIMAGE_CALLBACK)
end

-- 反馈图片
function GameNativeEvent:pickPic(data)
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GAME_PICKPICTURE, kCallParamString, data, NativeEventConfig.NATIVE_GAME_PICKPICTURE_CALLBACK)
end

--分享apk
function GameNativeEvent:shareApk()
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_SHARE_APK)
end

-- 启动浏览器
function GameNativeEvent:openBrowser(url)
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GAME_OPEN_BROWSER, kCallParamString, url)
end

-- 安装APK
function GameNativeEvent:installApk(path)
	Log.printInfo("GameNativeEvent:installApk path " .. path)
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GAME_APK_INSTALL, kCallParamString, path)
end

-- 删除文件夹 /data/data/com.boyaa.xxx/files/update 
function GameNativeEvent:deleteUpdate(data)
    Log.printInfo("GameNativeEvent:deleteUpdate","delete: /data/data/com.boyaa.xxx/files/update")
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_DELETE_UPDATE,kCallParamJsonString, data)
end

-- unzip解压缩
function GameNativeEvent:unzip(zipPath, outPath)
	Log.printInfo("GameNativeEvent:unzip")
	local params = {
		zipPath = zipPath,
		outPath = outPath,
	}
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GAME_UNZIP, kCallParamJsonString, params)
end

-- 获取系统信息
function GameNativeEvent:read_getSystemInfo()
    if not self.m_systemInfo then
        if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
            local key = NativeEventConfig.NATIVE_GAME_SYSTEMINFO_READ_
            nk.NativeEventController:callNativeEvent(key, kCallParamNo)
            self.m_systemInfo = json.decode(dict_get_string(key , key .. kResultPostfix))
        elseif System.getPlatform() == kPlatformWin32 then
            self.m_systemInfo = {mac = "mac", imei = "imei", deviceName = "deviceName", deviceModel = "deviceModel", 
                sdkVer = "sdkVer", simNum = "simNum", networkType = "networkType", widthPixels = 960, heightPixels = 640, appVersion = "1.5.0"}
        end
    end
    Log.dump(self.m_systemInfo, "GameNativeEvent:read_getSystemInfo")
    return self.m_systemInfo
end

-- 获取渠道名
function GameNativeEvent:read_getChannel()
    if not self.m_channel then
        if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
            local key = NativeEventConfig.NATIVE_GAME_CHANNEL_READ_
            nk.NativeEventController:callNativeEvent(key, kCallParamNo)
            self.m_channel = dict_get_string(key , key .. kResultPostfix);
        elseif System.getPlatform() == kPlatformWin32 then
            self.m_channel = "Google"
        end
    end
    return self.m_channel
end

-- 获取UUID
function GameNativeEvent:read_getUUID()
    local uuid = nk.DictModule:getString("gameData", "UUID", "")
    if not uuid or uuid == "" then
        if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
            local key = NativeEventConfig.NATIVE_GAME_UUID_READ_
            nk.NativeEventController:callNativeEvent(key, kCallParamNo)
            uuid = dict_get_string(key , key .. kResultPostfix)
            nk.DictModule:setString("gameData", "UUID", uuid)
            nk.DictModule:saveDict("gameData")
        elseif System.getPlatform() == kPlatformWin32 then
            uuid = nk.functions.randomUUID()
        end
    end
    return uuid
end

-- 震动
function GameNativeEvent:vibrate(time)
    if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
        local key = NativeEventConfig.NATIVE_GAME_VIBRATE
        nk.NativeEventController:callNativeEvent(key, kCallParamInt, time or 500)
    end
end

function GameNativeEvent:getFixedWidthText(font, size,text, width)
    return string.sub(text,1,8)
end

function GameNativeEvent:onBack()
    Log.printInfo("GameNativeEvent:onBack")
end

function GameNativeEvent:onKeyDown(key)
    -- Log.printInfo("GameNativeEvent:onKeyDown","onWinKeyDown:" .. key)
    if key == 81 then -- q 返回键
        EventDispatcher.getInstance():dispatch(Event.Back)
    end
    if onDebugKeyDown then onDebugKeyDown(key) end
end

function GameNativeEvent:getCampaignReferrer()
    if System.getPlatform() == kPlatformWin32 then return "" end
    nk.NativeEventController:callNativeEvent("getCampaignReferrer", kCallParamNo)
    local referrer = dict_get_string("getCampaignReferrer", "getCampaignReferrer" .. kResultPostfix);
    return referrer
end

---------------------------------nativeHandle-----------------------------------

function GameNativeEvent:pickImageCallBack(status, data)
    -- EventDispatcher.getInstance():dispatch(EventConstants.pickImageCallBack, status, data)
    -- nk.functions.uploadPhoto(status,data,self.posIndex,self.imgIndex)
    
    Log.printInfo("GameNativeEvent","pickImageCallBack")
end

function GameNativeEvent:pickPictureCallBack(status, data)
    EventDispatcher.getInstance():dispatch(EventConstants.PickPictureCallBack, status, data)
    Log.printInfo("GameNativeEvent","pickPictureCallBack")
end



GameNativeEvent.s_nativeHandle = {
    -- ["***"] = function
    [NativeEventConfig.NATIVE_GAME_PICKIMAGE_CALLBACK] = GameNativeEvent.pickImageCallBack,
    [NativeEventConfig.NATIVE_GAME_PICKPICTURE_CALLBACK] = GameNativeEvent.pickPictureCallBack,
    
}

return GameNativeEvent