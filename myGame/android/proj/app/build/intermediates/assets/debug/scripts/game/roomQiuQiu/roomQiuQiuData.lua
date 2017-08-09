-- hallData.lua
-- Last modification : 2016-05-11
-- Description: a data in Hall moudle

local RoomQiuQiuData = class(GameBaseData);

function RoomQiuQiuData:ctor(controller)
	Log.printInfo("RoomQiuQiuData.ctor");
end

function RoomQiuQiuData:dtor()

end

------------------------------------- socket function -----------------------------

function RoomQiuQiuData:SVR_LOGIN_ROOM_QIUQIU_OK(pack)
	Log.printInfo("RoomQiuQiuData", "SVR_LOGIN_ROOM_QIUQIU_OK")
    nk.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 5)
	self:requestCtrlCmd("loginRoomOK", pack)

	self:cancelSuspend()
end

function RoomQiuQiuData:SVN_TABLE_SYNC_QIUQIU(pack)
    Log.printInfo("RoomQiuQiuData", "SVN_TABLE_SYNC_QIUQIU")
    self:requestCtrlCmd("loginRoomOK", pack)

    self:cancelSuspend()
end

function RoomQiuQiuData:cancelSuspend()
	local control = self:getController()
	if control and control.isSuspend then
		control.isSuspend = false
	end
end

RoomQiuQiuData.s_socketCmdFuncMap = {
	["SVR_LOGIN_ROOM_QIUQIU_OK"] = RoomQiuQiuData.SVR_LOGIN_ROOM_QIUQIU_OK,
    ["SVN_TABLE_SYNC_QIUQIU"] = RoomQiuQiuData.SVN_TABLE_SYNC_QIUQIU,
}

RoomQiuQiuData.s_httpRequestsCallBack = {

}

RoomQiuQiuData.s_cmdConfig = 
{

}

-- Event to register and unregister
RoomQiuQiuData.s_eventHandle = {
    
}
return RoomQiuQiuData