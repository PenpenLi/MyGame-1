-- hallController.lua
-- Last modification : 2016-05-11
-- Description: a controller in Hall moudle

local RoomChooseController = class(GameBaseController);
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function RoomChooseController:ctor(state, viewClass, viewConfig, dataClass)
	Log.printInfo("RoomChooseController.ctor");
	self.m_state = state;
end

function RoomChooseController:resume()
    Log.printInfo("RoomChooseController.resume");
	GameBaseController.resume(self);
end

function RoomChooseController:pause()
    Log.printInfo("RoomChooseController.pause");
	GameBaseController.pause(self);

end

function RoomChooseController:dtor()

end

-- Provide state to call
function RoomChooseController:onBack()

end



-------------------------------- private function --------------------------



-------------------------------- handle function --------------------------


-------------------------------- native event -----------------------------



-------------------------------- event listen ------------------------



-------------------------------- socket function ----------------------------


--------------------------------- table config ---------------------------

-- Provide cmd handle to call
RoomChooseController.s_cmdHandleEx = 
{
    
};

-- Java to lua native call handle
RoomChooseController.s_nativeHandle = {
	
};

-- Event to register and unregister
RoomChooseController.s_eventHandle = {

};

RoomChooseController.s_socketCmdFuncMap = {

}

return RoomChooseController