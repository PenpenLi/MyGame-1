-- roomConfigController.lua
-- Last modification : 2016-05-24
-- 

-- 此模块负责房间配置加载
-- 普通房配置TABLE_NEW_CONF、表情、道具费用配置ROOM_COST
-- 私人房配置PRIVATE_ROOM_CONF
-- 99玩法房配置TABLE_99_NEW_CONF
local RoomConfigController = class()

function RoomConfigController:ctor()
	self.isLoading_ = false
	self:registerProcesser()
end

function RoomConfigController:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, RoomConfigController.onHttpPorcesser)
end

function RoomConfigController:registerProcesser()
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, RoomConfigController.onHttpPorcesser)
end

function RoomConfigController:requireRoomConfig()
	nk.HttpController:execute("roomConfig", {game_param = {mid = nk.userData.mid}})
end

function RoomConfigController:onHttpPorcesser(command, errorCode, data)
	if command == "roomConfig" then
		if errorCode ~= 1 then
			return
		end
		self.isLoading_ = nil
		self:setRoomConfig(data)
	end
end

function RoomConfigController:setRoomConfig(roomConfig)
	-- Log.dump(roomConfig, "setRnetRnfigsetRnfigsfigsetRnfigsetRnfigsetRnfigsetRnfigseetRnfigsetRnfigstRnfigsetRnfig")

	self.isLoading_ = nil
    nk.OnOff:saveNewVersionInLocal("roomlist")
    -- 场次配置
    nk.DataProxy:setData(nk.dataKeys.TABLE_NEW_CONF, roomConfig.data.newRoomlist)
    nk.DataProxy:cacheData(nk.dataKeys.TABLE_NEW_CONF)
    -- 99场次配置
    nk.DataProxy:setData(nk.dataKeys.TABLE_99_NEW_CONF, roomConfig.data.room99List)
    nk.DataProxy:cacheData(nk.dataKeys.TABLE_99_NEW_CONF)
    -- 私人房配置
    nk.DataProxy:setData(nk.dataKeys.PRIVATE_ROOM_CONF, roomConfig.data.privateRoom)
    nk.DataProxy:cacheData(nk.dataKeys.PRIVATE_ROOM_CONF)

    nk.DataProxy:setData(nk.dataKeys.ROOM_COST,roomConfig.data.roomCost)
    nk.DataProxy:cacheData(nk.dataKeys.ROOM_COST)

    -- 
end

function RoomConfigController:getRoomConfig()
	if self.isLoading_ then
		return
	end

	if self:checkRoomConfig() then
		self.isLoading_ = nil
		-- 
		return
	end
	print("requireRorequireRoomConfigomConfigrequireRorequireRoomConfigomConfig")

	self.isLoading_ = true
	self:requireRoomConfig()
end

function RoomConfigController:checkRoomConfig()
	if not nk.OnOff:checkLocalVersion("roomlist") then
		print(not nk.OnOff:checkLocalVersion("roomlist"),"RoomConfigController:checkRoomConfig checkLocalVersion")
		return false
	end
	if nk.DataProxy:getData(nk.dataKeys.TABLE_NEW_CONF) == nil then
		print("RoomConfigController:checkRoomConfig TABLE_NEW_CONF nil")
		return false
	end
	if nk.DataProxy:getData(nk.dataKeys.PRIVATE_ROOM_CONF) == nil then	
		print("RoomConfigController:checkRoomConfig PRIVATE_ROOM_CONF nil")
		return false
	end
	if nk.DataProxy:getData(nk.dataKeys.ROOM_COST) == nil then
		print("RoomConfigController:checkRoomConfig ROOM_COST nil")
		return false
	end
	if nk.DataProxy:getData(nk.dataKeys.TABLE_99_NEW_CONF) == nil then
		print("RoomConfigController:checkRoomConfig TABLE_99_NEW_CONF nil")
		return false
	end
	print("RoomConfigController:checkRoomConfig is good")
	return true
end

function RoomConfigController:cleanCallback()
	self.successCallback_ = nil
	self.failCallback_ = nil
end

return RoomConfigController