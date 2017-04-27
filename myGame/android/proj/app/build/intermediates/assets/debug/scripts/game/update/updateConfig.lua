kHttpFileLoadKey = "httpFileDownload"
kHttpFileLoadCancelKey = "httpFileDownloadCancel"

kHttpFileLoadResultSuccess = 1
kHttpFileLoadResultTimeout = 0
kHttpFileLoadResultError   = -1
kHttpFileLoadResultMD5Fail = -2

local UpdateConfig = {}

-- -- 热更新配置文件url路径基础(会在检查版本后赋值)
-- UpdateConfig.hotUpdateConfig_url_base = ""

-- -- 热更新配置文件url路径部分
-- UpdateConfig.hotUpdateConfig_url_param = "flist" .. string.sub(GameConfig.CUR_VERSION, 1, 5)

-- -- 临时热更新配置文件存储路径
-- UpdateConfig.hotUpdateConfig_savePath_temp = System.getStorageUpdatePath() .. "versionConfig_temp.lua"

-- -- 当前热更新配置文件存储路径
-- UpdateConfig.hotUpdateConfig_savePath = System.getStorageUpdatePath() .. "versionConfig.lua"

-- lua zip 文件存储路径
UpdateConfig.hotUpdateLua_savePath = System.getStorageUpdatePath()  .. GameConfig.CUR_VERSION .. "_"

-- android patch 文件存储路径
UpdateConfig.hotUpdateLua_savePath_patch = System.getStorageUpdatePath() .. GameConfig.CUR_VERSION .. "_"

-- android new apk 文件存储路径
UpdateConfig.hotUpdateLua_savePath_apk = System.getStorageUpdatePath() .. "version.apk"

UpdateConfig.getPatchUpdatePath = function()
    -- if TerminalInfo.getInstance():isSDCardWritable() then
    --     Log.i("UpdatePathManager.getApkUpdatePath isSDCardWritable!");
    --     local path = System.getStorageUserPath() .. "/apkUpdate/";
    --     Log.i("UpdatePathManager.getApkUpdatePath path:"..path);
    --     dict_set_string("patchUpdate" , "dirPath" ,path);--目录全路径
        
    --     dict_set_string("LuaCallEvent","LuaCallEvent","PatchUpdateDir");

    --     if System.getPlatform() == kPlatformAndroid then
    --         call_native("OnLuaCall");
    --     end 
    --     return path;
    -- else
    --     Log.i("UpdatePathManager.getApkUpdatePath is not SDCardWritable!");
    --     return TerminalInfo.getInstance():getInternalUpdatePath();
    -- end
end

-- 增量更新 patch 文件存储路径
UpdateConfig.hotUpdatePatch_savePath = UpdateConfig.getPatchUpdatePath()
-- require("view.view_config")

-- require("EngineCore.config")


-- require("EngineCoreex.coreexInit")
-- --
--     require("EngineCoreex.stateMachineex")
--     require("EngineCoreex.labelEx")
--     require("EngineCoreex.systemex")
--     require("EngineCoreex.socketex")
--     require("EngineCoreex.scrollViewex")

-- require("utils.utilsInit")
-- --
--     require("utils.functionModule")
--     require("utils.debugModule")

-- require("config")

-- require("gameConfig")


-- require("game.gameInit")
-- --
--     require("game.common.eventConstants")
--     require("game.gameBase.httpModule");
--     require("game.net.socket.socketConfig")
--     require("game.gameBase.gameBaseSocket");
--     require("game.gameBase.gameBaseSocketProcesser");
--     require("game.gameBase.gameBaseSocketReader");
--     require("game.gameBase.gameBaseSocketWriter");
--     require("game.gameBase.gameBaseData");
--     require("game.gameBase.gameBaseLayer");
--     require("game.gameBase.gameBaseScene");
--     require("game.gameBase.gameBaseController");
--     require("game.gameBase.gameBaseState");
--     require("game.gameBase.gameBaseNativeEvent");
--     require("game.statesConfig")

-- require("language/languageInit")
-- --
--     require("language.lang")
--     require("language.appconfig")
--     require("language.lang.Gettext")
--     require("language.lang.LangUtil")


-- UpdateConfig.reLoadFiles = {
--     "game.net.http.httpConfig",
--     "game.uiex.urlImage"
-- }

return UpdateConfig
