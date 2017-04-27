-- updateHttpFile.lua
-- Last modification : 2016-05-31
-- Description: a utils in update moudle to download file.(include *.image , *.zip , *.patch, or others)
-- Tips: how to use? see this function UpdateHttpFile:downloadFile(params)

local UpdateHttpFile = class();

-- Lua To Android 的Key值
UpdateHttpFile.s_keys = {
    Id = "id";
    Url = "url";
    SaveAs = "saveas";
    Timeout = "timeout";
    Event = "event";
    Result = "result";
    IdDictName = "http_file_download";
    TimerPeriod = "timerPeriod";
    Md5 = "md5";
    Size = "size";
    HasRead = "hasRead";
};

function UpdateHttpFile.getInstance()
    if not UpdateHttpFile.s_instance then
        UpdateHttpFile.s_instance = new(UpdateHttpFile);
    end
    return UpdateHttpFile.s_instance;
end

function UpdateHttpFile.releaseInstance()
    delete(UpdateHttpFile.s_instance);
    UpdateHttpFile.s_instance = nil;
end

function UpdateHttpFile:ctor()
    self.m_curid = 0; 
    self.m_callbacks = {};
end

function UpdateHttpFile:dtor()
    self.m_curid = 0; 
    self.m_callbacks = {};
end

--[[@param table params = {
        url:              下载URL
        savePath:         保存文件完整路径
        timeout:          超时
        obj:              回调对象
        func:             回调函数 (status, params)返回状态boolean和原始params
        periodFunc:       进度回调函数
        needPause:        WIFI切换是否需要暂停
        tryNumber:        下载失败尝试次数
        md5:              md5校验码
    }
]]
function UpdateHttpFile:downloadFile(params)
    Log.printInfo("UpdateHttpFile savePath :" .. params.savePath .. "  data.url :" .. params.url);
    local id = self:getId();
    params.id = id
    self:saveInfo(params);

    dict_set_int(UpdateHttpFile.s_keys.IdDictName, UpdateHttpFile.s_keys.Id, id);
    
    local dictName = self:getDictName(id);

    dict_set_string(dictName, UpdateHttpFile.s_keys.Url, params.url);
    dict_set_string(dictName, UpdateHttpFile.s_keys.SaveAs, params.savePath);
    dict_set_int(dictName, UpdateHttpFile.s_keys.Timeout, params.timeout);
    dict_set_string(dictName, UpdateHttpFile.s_keys.Md5, params.md5);
    --用于拼接event_http_file_download_response_downloadFile，下载回调函数
    --可以不传，event_http_file_download_response即为回调函数
    dict_set_string(dictName, UpdateHttpFile.s_keys.Event, "downloadFile");
    dict_set_int(dictName,UpdateHttpFile.s_keys.TimerPeriod, 1000);

    if System.getPlatform() == kPlatformAndroid then
        dict_set_string(kLuaCallFuc, kLuaCallFuc, kHttpFileLoadKey);
        call_native(kLuaCallNavite);
    elseif System.getPlatform() == kPlatformWin32 then
        if params.func and params.obj then
            params.func(params.obj, true, params)
        end
    end
end

function UpdateHttpFile:downloadFile_http2(params)
    Log.printInfo("UpdateHttpFile savePath :" .. params.savePath .. "  data.url :" .. params.url)
    local args = {
        url = params.url,
        savePath = params.savePath,
        callback = handler(params.obj, params.func),
        periodFunc = handler(params.obj, params.periodFunc),
        needPause = params.needPause,
        tryTimes = params.tryNumber,
        md5 = params.md5,
    }
    nk.HttpDownloadManager:addTask(args)
end

-- 取消下载
function UpdateHttpFile:cancleGrapFile(id)
    if id then
        if System.getPlatform() == kPlatformAndroid and id ~= -1 then
            -- 取消下载更新包
            dict_set_int(UpdateHttpFile.s_keys.IdDictName, UpdateHttpFile.s_keys.Id, id);
            dict_set_string(kLuaCallFuc, kLuaCallFuc, kHttpFileLoadCancelKey);
            call_native(kLuaCallNavite);
        end
        self.m_callbacks[id] = nil;
    end
end

-- 检查文件是否存在
function UpdateHttpFile:exitApkFile(filePath)
    dict_set_string("ExistApkFile","filePath",filePath);
    if System.getPlatform() == kPlatformAndroid then
        call_native("ExistApkFile");
    end
    local existFlag = dict_get_int("ExistApkFile", "fileExist",0);
    if existFlag == 1 then
        Log.printInfo("UpdateHttpFile.exitApkFile " .. filePath .. " is exist!");
        return true;
    else
        Log.printInfo("UpdateHttpFile.exitApkFile " .. filePath .. " is no exist.");
        return false;
    end
end

-- 获取下载任务Id对应的Lua To Android Key 值
function UpdateHttpFile:getDictName(id)
    return string.format(UpdateHttpFile.s_keys.IdDictName .. id);
end

-- 获取下载任务Id
function UpdateHttpFile:getId()
    self.m_curid = self.m_curid + 1;
    return self.m_curid;
end

-- 保存下载任务
function UpdateHttpFile:saveInfo(params)
    self.m_callbacks[params.id] = params
end

-- 下载回调
function UpdateHttpFile:onResponse()
    Log.printInfo("UpdateHttpFile.onResponse");

    local id = dict_get_int(UpdateHttpFile.s_keys.IdDictName, UpdateHttpFile.s_keys.Id, -1);
    local dictName = self:getDictName(id);
    local resultCode = dict_get_int(dictName, UpdateHttpFile.s_keys.Result, -1);
    local resultReason = "";
    local callback = self.m_callbacks[id];
    self.m_callbacks[id] = nil;

    Log.printInfo("UpdateHttpFile.onResponse resultCode " .. resultCode);

    Log.dump(callback, "UpdateHttpFile.onResponse")

    if callback and resultCode == kHttpFileLoadResultMD5Fail then    
        --MD5校验失败
        System.removeFile(callback["savePath"]);
        resultReason = dict_get_string(dictName, "resultReason") or "md5 fail";
        callback["func"](callback["obj"], resultCode == kHttpFileLoadResultSuccess, resultReason);
        return;
    end
    if callback and callback["func"] then
        if callback["tryNumber"] and callback["tryNumber"] > 1 and resultCode ~= kHttpFileLoadResultSuccess then
            Log.printInfo("UpdateHttpFile.onResponse download fail and try");
            if callback["tryNumber"] == 999 then
                callback["tryNumber"] = 1000;
            else
                callback["tryNumber"] = callback["tryNumber"] - 1
            end
            self:downloadFile(callback);
        else
            if resultCode ~= kHttpFileLoadResultSuccess then
                Log.printInfo("UpdateHttpFile.onResponse download fail");
                resultReason = dict_get_string(dictName,"resultReason") or "no know";
                Log.printInfo("UpdateHttpFile.onResponse false and resultReason ：" ..resultReason);
            end
            Log.printInfo("UpdateHttpFile.onResponse success and callback");
            if callback["obj"] then
                callback["func"](callback["obj"], resultCode == kHttpFileLoadResultSuccess, callback)
            else
                callback["func"](resultCode == kHttpFileLoadResultSuccess, callback)
            end
        end
    end
end

-- 下载进度回传
function UpdateHttpFile:onResponsePeriod()
    local id = dict_get_int(UpdateHttpFile.s_keys.IdDictName, UpdateHttpFile.s_keys.Id,-1);
    local dictName = self:getDictName(id);
    local period = dict_get_double(dictName, UpdateHttpFile.s_keys.Result, 0);
    -- 已经下载的字节
    local hasRead = dict_get_double(dictName, UpdateHttpFile.s_keys.HasRead, 0);
    -- 总的字节
    local size = dict_get_double(dictName, UpdateHttpFile.s_keys.Size, 0);
    Log.printInfo("UpdateHttpFile.onResponsePeriod 总共" .. size .. "已下载".. period .. " :" .. hasRead);
    local callback = self.m_callbacks[id];
    if callback and callback["periodFunc"] then
        callback["periodFunc"](callback["obj"],period, size, hasRead);
    end
end

-- Android Call Lua 下载回调
function event_http_file_download_response_downloadFile()
    Log.printInfo("UpdateHttpFile.event_http_file_download_response_downloadFile");
    UpdateHttpFile.getInstance():onResponse();
end

-- Android Call Lua 下载进度回调
function event_http_file_download_timer_period()
    Log.printInfo("UpdateHttpFile.event_http_file_download_timer_period");
    UpdateHttpFile.getInstance():onResponsePeriod();
end

-- Android Call Lua wifi状态改变
-- function UpdateHttpFile:onResponseWifiChange(networkTypeFlag)
--     Log.printInfo("UpdateHttpFile.event_wifiStateChange type = "..tostring(networkTypeFlag));
--     local flag = false;
--     if networkTypeFlag ~= 1 and self.m_callbacks then
--         for k, v in pairs(self.m_callbacks) do 
--             if v.needPause then
--                 self:cancleGrapFile(k);
--                 flag = true;
--             end
--         end
--         if flag then
-- --            kGameData:setUpdating(false);
--         end
--     end
-- end

return UpdateHttpFile
