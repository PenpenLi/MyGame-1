

local LoginRewardConfig = class()

function LoginRewardConfig:ctor()
	self:registerProcesser()
end

function LoginRewardConfig:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, LoginRewardConfig.onHttpPorcesser)
end

function LoginRewardConfig:requireRewardConfig()
    nk.HttpController:execute("loginReward", {}, nk.userData.LOGINREWARD_JSON)
end

function LoginRewardConfig:registerProcesser()
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, LoginRewardConfig.onHttpPorcesser)
end

function LoginRewardConfig:onHttpPorcesser(command, errorCode, data)
	if errorCode ~= 1 then
		return
	end
	if command == "loginReward" then
		self:setrewardConfig(data)
	end
end

function LoginRewardConfig:setrewardConfig(rewardconfig)
	local rewardStr = json.encode(rewardconfig)
	nk.DictModule:setString("loginRewardConfig", "rewardConfig", rewardStr)
end

function LoginRewardConfig:getrewardConfig()
	local rewardStr = nk.DictModule:getString("loginRewardConfig", "rewardConfig")
	local rewardconfig = json.decode(rewardStr)
	return rewardconfig
end


return LoginRewardConfig