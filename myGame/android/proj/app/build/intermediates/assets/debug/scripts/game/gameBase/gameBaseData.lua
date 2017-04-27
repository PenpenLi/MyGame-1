-- gameBaseData.lua
-- Last modification : 2016-07-02
-- Description: A base class of data in MVC 

GameBaseData = class();

function GameBaseData:ctor(controller)
	Log.printInfo("GameBaseData.ctor");
    self.s_eventHandle = CombineTables(self.s_base_eventHandle, self.s_eventHandle)
	self.m_controller = controller;
	for i, v in pairs(self.s_eventHandle) do
		EventDispatcher.getInstance():register(i, self, v);
	end
end

function GameBaseData:dtor()
	self.m_controller = nil;
	for i, v in pairs(self.s_eventHandle) do
		EventDispatcher.getInstance():unregister(i, self, v);
	end
end

function GameBaseData:getController()
	return self.m_controller;
end

function GameBaseData:requestCtrlCmd(cmd, ...)
	if not self.m_controller then
		return;
	end

	return self.m_controller:handleCmdEx(cmd, ...);
end

function GameBaseData.handleCmdEx(cmd, ...)
	if not self.s_cmdConfig[cmd] then
		Log.printWarn("gameBase", "GameBaseData, no such cmd");
		return;
	end

	return self.s_cmdConfig[cmd](self,...)
end

function GameBaseData:onHttpPorcesser(command, ...)
	Log.printInfo("gameBase", "GameBaseData.onHttpPorcesser");
	if not self.s_httpRequestsCallBack[command] then
		Log.printWarn("gameBase", "Not such request cmd in current bseeData");
		return;
	end
    self.s_httpRequestsCallBack[command](self,...); 
end

function GameBaseData:onSocketPorcesser(command, ...)
	Log.printInfo("gameBase", "GameBaseData.onSocketPorcesser");
	if not self.s_socketCmdFuncMap[command] then
		Log.printWarn("gameBase", "Not such socket cmd in current bseeData");
		return;
	end
    self.s_socketCmdFuncMap[command](self,...); 
end

-- socket回调事件
GameBaseData.s_socketCmdFuncMap = {

}

-- http回调事件
GameBaseData.s_httpRequestsCallBack = {
	
}

-- Provide cmd handle to call
-- 提供给Controller调用
-- eg:xxxController:updateData("***")
GameBaseData.s_cmdConfig = 
{
	--["***"] = function
};

-- Event to register and unregister
-- 要监听的事件，baseScene将自动监听的释放监听
-- 默认添加了http和socket事件
GameBaseData.s_base_eventHandle = {
    -- [Event ] = function
    [EventConstants.httpProcesser] = GameBaseData.onHttpPorcesser,
    [EventConstants.socketProcesser] = GameBaseData.onSocketPorcesser,
};
