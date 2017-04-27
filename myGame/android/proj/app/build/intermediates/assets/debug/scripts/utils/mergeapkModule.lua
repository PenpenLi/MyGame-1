
local MergeapkModule = class()
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

MergeapkModule.dictNameKey = "patchUpdate"
MergeapkModule.patchPathKey = "patchPath"
MergeapkModule.newApkPathKey = "newApkPath"
MergeapkModule.patchMD5Key = "patchMD5"
MergeapkModule.newApkMD5Key = "newApkMD5"
MergeapkModule.resultKey = "result"

function MergeapkModule:ctor()

end

function MergeapkModule:dtor()

end

function MergeapkModule:mergeCall(patchPath, newApkPath, patchMd5, newApkMd5)
	self.m_newApkPath = newApkPath
	Log.printInfo("MergeapkModule:mergeCall")
	dict_set_string(MergeapkModule.dictNameKey, MergeapkModule.patchPathKey, patchPath); 
	dict_set_string(MergeapkModule.dictNameKey, MergeapkModule.newApkPathKey, newApkPath);

	dict_set_string(MergeapkModule.dictNameKey, MergeapkModule.patchMD5Key, patchMd5); 
    dict_set_string(MergeapkModule.dictNameKey, MergeapkModule.newApkMD5Key, newApkMd5);

    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GAME_MERGE_APK)
end

function event_merge_new_apk()
	Log.printInfo("event_merge_new_apk")
	local resultCode = dict_get_int(MergeapkModule.dictNameKey, MergeapkModule.resultKey, -1);
    local patchPath = dict_get_string(MergeapkModule.dictNameKey, MergeapkModule.patchPathKey);
    local newApkPath = dict_get_string(MergeapkModule.dictNameKey, MergeapkModule.newApkPathKey);
	Log.printInfo("event_merge_new_apk resultCode " .. resultCode)
    EventDispatcher.getInstance():dispatch(EventConstants.mergeModule, resultCode == 1, patchPath, newApkPath);
end

function event_install_apk()
	Log.printInfo("event_install_apk")
	local resultCode = dict_get_int(MergeapkModule.dictNameKey, MergeapkModule.resultKey, -1);
	Log.printInfo("event_install_apk resultCode " .. resultCode)
    EventDispatcher.getInstance():dispatch(EventConstants.installModule, resultCode == 1);
end

return MergeapkModule