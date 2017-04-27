-- umengOnOffConfig.lua
-- Last modification : 2016-05-25
-- 

local UmengOnOffConfig = class()

function UmengOnOffConfig:ctor()
	self:registerProcesser()
end

function UmengOnOffConfig:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, UmengOnOffConfig.onHttpPorcesser)
end

function UmengOnOffConfig:registerProcesser()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, UmengOnOffConfig.onHttpPorcesser)
end

function UmengOnOffConfig:onHttpPorcesser(command, errorCode, data)
	if errorCode ~= 1 then
		return
	end
    if command == "umengConfig" then
        self:setUmengConfig(data)
    end
end

function UmengOnOffConfig:requireOnOffConfig()
    nk.HttpController:execute("umengConfig", {}, nk.userData.STATSWITCH_JSON)
end

function UmengOnOffConfig:setUmengConfig(content)
    nk.UserDataController.setSwitchData(content)
end

function UmengOnOffConfig:getUmengConfig()

end

return UmengOnOffConfig

