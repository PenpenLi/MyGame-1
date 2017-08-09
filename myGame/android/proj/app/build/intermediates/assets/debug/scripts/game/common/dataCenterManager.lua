-- Date : 2017-02-10
-- Last modification : 
-- Description:  php 上报到数据中心
-- doc: http://jd.oa.com/wiki/index.php?title=Gaple--%E6%8E%A5%E5%8F%A3--%E6%8C%89%E9%92%AE%E4%BA%8B%E4%BB%B6%E7%BB%9F%E8%AE%A1

local DataCenterManager = class()

function DataCenterManager:ctor()
	--Log.printInfo("DataCenterManager.ctor")
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function DataCenterManager:dtor()
	Log.printInfo("DataCenterManager.ctor")
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function DataCenterManager:report(id)
	-- 每次登陆进来只统计一次
	if not self.justOnce then
		self.justOnce = true
        
		local param = {}
		param.mid = nk.userData.mid
		param.sid = GameConfig.ROOT_CGI_SID
		param.et = "login_btn"
		param.btn = id
		param.num = 1
		nk.HttpController:execute("Login.sendData",{game_param = param})
	end
end

function DataCenterManager:setSwitch(switch)
	self.justOnce = switch
end

function DataCenterManager:onHttpProcesser(command, errorCode, content)
	if command == "Login.sendData" then
		if errorCode == HttpErrorType.SUCCESSED then
			--do nothing
			Log.printInfo("report to data center successed !")
		else
			Log.printInfo("report to data center faild !")
		end

	end
end

return DataCenterManager
