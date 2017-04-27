-- updateData.lua
-- Last modification : 2016-05-27
-- Description: a data in update moudle

local UpdateData = class(GameBaseData);

function UpdateData:ctor(controller)
	Log.printInfo("UpdateData.ctor");
end

function UpdateData:dtor()
	Log.printInfo("UpdateData.dtor");
end

function UpdateData:checkVersionCallBack(errorCode,retData)
	Log.printInfo("UpdateData.checkVersionCallBack")
	Log.dump(retData, "UpdateData.checkVersionCallBack")
	if errorCode == HttpErrorType.SUCCESSED then
		if retData then
			nk.functions.typeFilter(retData.java, {
	            [tostring] = {},
	            [tonumber] = {"isApk", "isForce"},
	        })
		end
	    self:requestCtrlCmd("checkVersionCallBack", true, retData)
	else
		self:requestCtrlCmd("checkVersionCallBack", false, errorCode)
	end
end

-- Event to register and unregister
UpdateData.s_eventHandle = {
    -- [Event ] = function
    [EventConstants.httpProcesser] = UpdateData.onHttpPorcesser,
}

UpdateData.s_httpRequestsCallBack = {
	["Http_checkVersion"] = UpdateData.checkVersionCallBack,
}

-- Provide handle to call
UpdateData.s_cmdConfig = 
{
	--["***"] = function
};

return UpdateData