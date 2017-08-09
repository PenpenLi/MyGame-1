-- hallData.lua
-- Last modification : 2016-05-11
-- Description: a data in Hall moudle

local RoomGapleData = class(GameBaseData);

function RoomGapleData:ctor(controller)
	Log.printInfo("RoomGapleData.ctor");
end

function RoomGapleData:dtor()

end

------------------------------------- socket function -----------------------------

function RoomGapleData:SVR_LOGIN_ROOM_OK(pack)
	Log.printInfo("RoomGapleData", "SVR_LOGIN_ROOM_OK")
    nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 5)
	self:requestCtrlCmd("RoomGapleController.loginRoomOK", pack)

	self:cancelSuspend()
end

function RoomGapleData:SVN_TABLE_SYNC(pack)
    Log.printInfo("RoomGapleData", "SVN_TABLE_SYNC")
    self:requestCtrlCmd("RoomGapleController.svnTableSync", pack)

    self:cancelSuspend()
end

function RoomGapleData:cancelSuspend()
	local control = self:getController()
	if control and control.isSuspend then
		control.isSuspend = false
	end
end

RoomGapleData.s_socketCmdFuncMap = {
	["SVR_LOGIN_ROOM_OK"] = RoomGapleData.SVR_LOGIN_ROOM_OK,
    ["SVN_TABLE_SYNC"] = RoomGapleData.SVN_TABLE_SYNC,
}

-- Event to register and unregister
RoomGapleData.s_eventHandle = {

};

RoomGapleData.s_httpRequestsCallBack = {

}

-- Provide handle to call
RoomGapleData.s_cmdConfig = 
{
	--["***"] = function
};

return RoomGapleData