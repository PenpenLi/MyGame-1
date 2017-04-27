-- updateController.lua
-- Last modification : 2016-05-27
-- Description: a controller in update moudle

local UpdateController = class(GameBaseController);
local UpdatePopup = require("game.update.updatePopup")
local UpdatePopupLayer = require(VIEW_PATH .. "update.update_pop_layer")
local varConfigPath = VIEW_PATH .. "update.update_pop_layer_layout_var"
local UrlImage = require("game.uiex.urlImage")

UpdateController.fileType = {
    Lua = 0;
    Apk = 1;
};

function UpdateController:ctor()
    Log.printInfo("UpdateController.ctor");
    if nk.HttpController then
        nk.HttpController.m_httpModule:setDefaultTimeout(3)
    end
end

function UpdateController:resume()
    Log.printInfo("UpdateController.resume");
    GameBaseController.resume(self);
    self.m_checkTime = 3
    self:checkVersion()
    if self.m_schedule then
        self.m_schedule.paused = false    -- 恢复
    end
end

function UpdateController:pause()
    Log.printInfo("UpdateController.pause");
    GameBaseController.pause(self);
    if self.m_schedule then
        self.m_schedule.paused = true    -- 暂停
    end
end 

function UpdateController:dtor()
    Log.printInfo("UpdateController.dtor");
    GameBaseController.dtor(self);
    if self.m_schedule then
        self.m_schedule:cancel()
        self.m_schedule = nil
    end
end

-------------------------------- private function --------------------------

-- 检查更新
function UpdateController:checkVersion()
    local systemInfo = nk.GameNativeEvent:read_getSystemInfo()
    local params = 
    {
        device = (System.getPlatform() == kPlatformWin32 and kPlatformAndroid or System.getPlatform()), 
        pay = device, 
        osVersion = systemInfo.appVersion,
        version = GameConfig.CUR_VERSION,
        sid = GameConfig.ROOT_CGI_SID,
        uuid = nk.GameNativeEvent:read_getUUID(),
    }

    if not IS_RELEASE then
        local PHPServerUrl = require("game.net.http.phpServerUrl")
        local phpServerUrl_index = nk.DictModule:getInt("changeServerData", nk.cookieKeys.CHANGE_SERVER, 1)
        HttpConfig.s_request["Http_checkVersion"].url = PHPServerUrl[phpServerUrl_index][1]
        nk.HttpController.m_httpModule:appendConfigs(HttpConfig.s_request)
    end
    self.m_checkTime = self.m_checkTime - 1 
    nk.HttpController:execute("Http_checkVersion", params)
    self:startSchedule()
end

-- 检查更新的时候更新进度条提示
function UpdateController:startSchedule()
    if self.m_schedule then
        self.m_schedule:cancel()
        self.m_schedule = nil
    end
    self.m_schedule = Clock.instance():schedule(function(dt)
        local msg = bm.LangUtil.getText("UPDATE", "CHECKING_VERSION")
        if self.m_msgTime then
            if self.m_msgTime == 1 then
                msg = msg .. "."
            end
            if self.m_msgTime == 2 then
                msg = msg .. ".."
            end
            if self.m_msgTime == 3 then
                msg = msg .. "..."
                self.m_msgTime = 0
            end
            self.m_msgTime = self.m_msgTime + 1
        else
            self.m_msgTime = 1
            msg = msg .. "."
        end
        self:onUpdatePeriod(nil, nil, nil, msg)
    end, 1)
end

-- 开始热更新(下载LUA更新包)
function UpdateController:startLuaUpdate(data)
    local params = {
        url = data.url,
        savePath = nk.UpdateConfig.hotUpdateLua_savePath .. data.version .. "_update.zip",
        timeout = 3000,
        obj = self,
        func = self.onDownLualoadBack,
        periodFunc = self.onDownloadPeriod,
        needPause = false,
        tryNumber = tryNumber or 3,
        md5 = data.code,
    }
    -- nk.UpdateHttpFile:downloadFile(params)
    nk.UpdateHttpFile:downloadFile_http2(params)
end

-- Lua zip 包下载回调
function UpdateController:onDownLualoadBack(status, data, msg)
    Log.printInfo("UpdateController:onDownLualoadBack")
    if status then
        -- 解压lua zip 包
        self:unzip(data.savePath)
    else
        -- 下载失败，直接进入游戏
        Log.printInfo("UpdateController:onDownLualoadBack false " .. (msg or ""))
        self:luaUpdateFail()
    end
end

-- 更新弹窗
function UpdateController:openUpdatePop(data)
    local params = {}
    params.config = data
    params.callFunc = handler(self, self.onUpdatePopupCallBack)

    local node = new(UpdatePopup, UpdatePopupLayer, varConfigPath, params)
    node:setAlign(kAlignCenter)
    self.m_view:addChild(node)
end

-- 开始增量更新(下载JAVA更新包)
function UpdateController:startJavaUpdate(data)
    local params = {
        url = data.url,
        savePath = nk.UpdateConfig.hotUpdateLua_savePath_patch .. data.version .. ".patch",
        timeout = 3000,
        obj = self,
        func = self.onDownJavaloadBack,
        periodFunc = self.onDownloadPeriod,
        needPause = false,
        tryNumber = tryNumber or 3,
        md5 = data.patch_code,
        apkMD5 = data.apk_code,
    }
    -- nk.UpdateHttpFile:downloadFile(params);
    nk.UpdateHttpFile:downloadFile_http2(params)
end

-- 下载进度回调
function UpdateController:onDownloadPeriod(period, size, hasRead)
    Log.printInfo("UpdateController:onDownloadPeriod")
    local sizeFormat = flowUnitConversionsK_KB_MB(size)
    local hasReadFormat = flowUnitConversionsK_KB_MB(hasRead)
    self:onUpdatePeriod(period, sizeFormat, hasReadFormat)
end

function UpdateController:onUpdatePeriod(period, size, hasRead, msg)
    if not period then
        period = 0.07
    end
    if period < 0.07 then
        period = 0.07
    end
    if period > 1 then
        period = 1
    end
--    period = period/100
    if not msg and hasRead and size then
        msg = bm.LangUtil.getText("UPDATE", "DOWNLOADING_MSG", hasRead, size)
    end
    self:updateView("updatePeriod", period, msg)
end

-- Java patch下载回调
function UpdateController:onDownJavaloadBack(status, data)
    Log.printInfo("UpdateController:onDownJavaloadBack")
    if status then
        self:onUpdatePeriod(1, nil, nil, "100%")
        -- 合并 java patch 包
        self:mergeNewApk(data.savePath, data.md5, data.apkMD5)
    else
        -- 下载失败，直接进入游戏
        Log.printInfo("UpdateController:onDownJavaloadBack false")
        -- 设置从google商店下载
        nk.UpdateConfig.javaUpdate.isApk = 1
        local msg = T("更新包下载失败，请重试")
        self:javaUpdateFail(msg)
    end
end

-- 合并patch包
function UpdateController:mergeNewApk(savePath, patchMD5, apkMD5)
    Log.printInfo("UpdateController.mergeNewApk patchPath = " .. savePath .. "  newApkPath = " .. nk.UpdateConfig.hotUpdateLua_savePath_apk);
    -- 调用merge apk 模块，merge成功和校验后直接调起安装
    local mergeNewApk = require("utils.mergeapkModule")
    mergeNewApk:mergeCall(savePath, nk.UpdateConfig.hotUpdateLua_savePath_apk, patchMD5, apkMD5)
end

-- 合并patch包回调
function UpdateController:onMergeCallback(status, patchPath, newApkPath)
    Log.printInfo("UpdateController.onMergeCallback");
    -- 不除patch包
    -- System.removeFile(patchPath)
    if status then
        Log.printInfo("UpdateController.onMergeCallback success!");
        nk.GameNativeEvent:installApk(newApkPath)
        if nk.UpdateConfig.javaUpdate.isForce == 1 then
            self:openUpdatePop(nk.UpdateConfig.javaUpdate)
        else
            self:endUpdate()
        end
    else
        Log.printInfo("UpdateController.onMergeCallback fail~");
        nk.UpdateConfig.javaUpdate.isApk = 1
        local msg = T("更新包合并失败，请重试")
        self:javaUpdateFail(msg)
    end
end

-- 安装apk回调
function UpdateController:onInstallCallback(status)
    Log.printInfo("UpdateController.onInstallCallback");
    if status then
        Log.printInfo("UpdateController.onInstallCallback success!");
    else
        Log.printInfo("UpdateController.onInstallCallback fail~");
    end
end

-- 解压缩lua zip 包
function UpdateController:unzip(path)
    Log.printInfo("UpdateController:unzip")
    local Zip= require('core.zip')
    local targetPath = System.getStorageAppRoot() .. "/update"
    local result = Zip.unzipWholeFile(path, targetPath)
    Log.printInfo("UpdateController:unzip after")
    -- 删除zip包
    System.removeFile(path)
    if result then
        Log.printInfo("UpdateController:unzip zip success!")
        self:endUpdate(true)
    else
        Log.printInfo("UpdateController:unzip zip fail~")
        self:luaUpdateFail()
    end
end

-- 更新结束
function UpdateController:endUpdate(isLuaUpdated)
    if isLuaUpdated then
        local msg = bm.LangUtil.getText("UPDATE", "CHECKING_VERSION")
        self:onUpdatePeriod(100, nil, nil, "100%")
        StateMachine:releaseInstance()
        -- self:reloaderFile()
        to_lua("main.lua")
        self:saveConfig(self.m_retData)
        Log.printInfo("UpdateController to_lua again!")
    else
        Log.printInfo("UpdateController didnt update lua")
        require("game.gameInit")
        StateMachine.getInstance():changeState(States.Login);
    end
end

-- 重新加载文件
function UpdateController:reloaderFile()
    require = old_require
    -- Log.dump(FILE_RE_LIST, "iccccccccccccccccccccccc")
    local file_re_list = Copy(FILE_RE_LIST)
    if not table_is_empty(file_re_list) then
        for i, v in ipairs(FILE_RE_LIST) do
            package.loaded[v]  = nil
        end
        -- while not table_is_empty(FILE_RE_LIST) do
        --     local filename = table.remove(FILE_RE_LIST, 1)
        --     require(filename)
        -- end
    end
    self:saveConfig(self.m_retData)
    -- event_init()
end

-- 更新弹窗回调
function UpdateController:onUpdatePopupCallBack(index)
    Log.printInfo("UpdateController.onUpdatePopupCallBack " .. index);
    local luaUpdate = nk.UpdateConfig.luaUpdate
    local javaUpdate = nk.UpdateConfig.javaUpdate
    if index == 1 then
        -- UpdatePopup 点击确认
        if javaUpdate.isApk == 1 then
            -- 跳转google应用商店下载
            self:browserDownload(nk.UpdateConfig.googleStoreUrl)
        else
            -- 跳转增量更新下载
            self:clearDir(GameConfig.CUR_VERSION .. "_" .. javaUpdate.version)
            self:startJavaUpdate(javaUpdate)
        end
    elseif index == 2 then
        -- UpdatePopup 点击取消
        if luaUpdate and not table_is_empty(luaUpdate) then
            self:startLuaUpdate(nk.UpdateConfig.luaUpdate)
        else
            self:endUpdate()
        end
    elseif index == 3 then
        -- UpdatePopup 点击关闭
        self:endUpdate()
    end
end

-- 打开浏览器下载
function UpdateController:browserDownload(url)
    nk.GameNativeEvent:openBrowser(url)
end

-- JAVA增量更新失败
function UpdateController:javaUpdateFail(msg)
    -- 弹窗提示msg
    nk.TopTipManager:showTopTip(msg)
    self:openUpdatePop(nk.UpdateConfig.javaUpdate)
end

-- LUA增量更新失败
function UpdateController:luaUpdateFail()
    -- TODO 暂时直接进入游戏
    self:endUpdate()
end

-- 保存配置
function UpdateController:saveConfig(retData)
    -- java大版本更新配置
    nk.UpdateConfig.javaUpdate = retData.java
    -- lua热版本更新配置
    nk.UpdateConfig.luaUpdate = retData.lua
    -- 公告配置
    nk.UpdateConfig.noticeConfig = retData.noticeConfig

    -- google url
    nk.UpdateConfig.googleStoreUrl = retData.commentUrl
    -- feedback url 
    nk.UpdateConfig.feedBackUrl = retData.FEEDBACK_CGI
    -- facebook url
    nk.UpdateConfig.facebookFansUrl = retData.facebookFansUrl
    -- login url
    nk.UpdateConfig.loginUrl = retData.loginUrl
    -- login url
    HttpConfig.BASE_URL = retData.loginUrl
    -- 是否通过socket请求http
    HttpConfig.SOCKET_REQUEST = retData.isSocket

    --HttpConfig.inHallIp = retData.inHallIp[1]

    -- facebook 登陆奖励
    nk.UpdateConfig.FACEBOOK_BONUS = retData.fbBonus
    nk.UpdateConfig.fbLoginReward = "+" .. (retData.fbBonus or 0)
end

function UpdateController:clearDir(filename)
    local dir = System.getStorageUpdatePath()
    local files = os.lsfiles(dir)
    Log.dump(files, "UpdateController:clearDir")
    for i, v in ipairs(files) do
        if not string.find(v, filename) then
            System.removeFile(v)
        end
    end
end

-------------------------------- handle function --------------------------

function UpdateController:checkVersionCallBack(status, retData)
    Log.printInfo("UpdateController.checkVersionCallBack")
    if self.m_schedule then
        self.m_schedule:cancel()
        self.m_schedule = nil
    end
    -- status = false
    if status then
        self.m_retData = retData
        if retData then
            self:saveConfig(retData)
            -- 此次更新，是否热更新
            local luaUpdate = retData.lua
            -- 是否是大版本更新
            local javaUpdate = retData.java
            if javaUpdate and not table_is_empty(javaUpdate) then
                self:openUpdatePop(javaUpdate)
            elseif luaUpdate and not table_is_empty(luaUpdate) then
                self:startLuaUpdate(luaUpdate)
            else
                self:endUpdate()
            end
        else
            self:endUpdate()
        end
    else
        local errorCode = retData
        -- Log.printInfo("UpdateController.checkVersionCallBack checkVersion again new errorCode = ", errorCode);
        -- Log.printInfo("checkVersionCallBack time = ", os.time());
        -- Log.printInfo("checkVersionCallBack self.m_checkTime = ", self.m_checkTime);
        if errorCode == HttpErrorType.TIMEOUT then
            self:endUpdate()
        elseif errorCode == HttpErrorType.NETWORKERROR  then
            if self.m_checkTime > 0 then
                self:checkVersion()
            else
                self:endUpdate()
            end
        end
    end
end

-------------------------------- table config ------------------------

-- Provide cmd handle to call
UpdateController.s_cmdHandleEx = 
{
    --["***"] = function
    ["checkVersionCallBack"] = UpdateController.checkVersionCallBack
};

-- Java to lua native call handle
UpdateController.s_nativeHandle = {
    -- ["***"] = function
};

-- Event to register and unregister
UpdateController.s_eventHandle = {
    -- [Event ] = function
    [EventConstants.mergeModule] = UpdateController.onMergeCallback,
    [EventConstants.installModule] = UpdateController.onInstallCallback,
};

return UpdateController
