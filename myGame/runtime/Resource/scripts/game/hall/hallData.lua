-- hallData.lua
-- Last modification : 2016-05-11
-- Description: a data in Hall moudle

local HallData = class(GameBaseData);

function HallData:ctor(controller)
	Log.printInfo("HallData.ctor");
end

function HallData:dtor()

end

function HallData:getLoginRewardConfigCallBack(errorCode,data)
	Log.printInfo("HallData.getLoginRewardConfigCallBack");
    -- Log.dump(data, "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",10)
end

-- Event to register and unregister
HallData.s_eventHandle = {
    -- [Event ] = function
    [EventConstants.httpProcesser] = HallData.onHttpPorcesser,
};

HallData.s_httpRequestsCallBack = {
	["Http.load"] = HallData.loadCallBack,
	["loginReward"] = HallData.getLoginRewardConfigCallBack,
}

-- Provide handle to call
HallData.s_cmdConfig = 
{
	--["***"] = function
};

return HallData