-- gameBaseController.lua
-- Last modification : 2016-07-02
-- Description: extend gameController class in core 

GameBaseController = class(GameController);

-- 创建一个Controller将会附带创建scene和data
-- self.m_view直接访问scene 或 self:updateView("***")
-- self.m_baseData直接访问data 或 self:updateData("***")
-- 不建议直接访问

function GameBaseController:ctor(state, viewClass, viewConfig, dataClass, ...)
	Log.printInfo("GameBaseController.ctor");
	self.s_eventHandle = CombineTables(self.s_base_eventHandle, self.s_eventHandle)
	if dataClass then
		self.m_baseData = new(dataClass, self, ...);
		if self.m_view then
			self.m_view.m_baseData = self.m_baseData
		end
	end
end

function GameBaseController:dtor()
	delete(self.m_baseData)
	self.m_baseData = nil
	delete(self.m_view)
	self.m_view = nil
end

-- @Override
function GameBaseController:resume()
	GameController.resume(self)

	EventDispatcher.getInstance():register(EventConstants.onEventCallBack, self, self.onNativeCall);

	for i, v in pairs(self.s_eventHandle) do
		EventDispatcher.getInstance():register(i, self, v);
	end
end

-- @Override
function GameBaseController:pause()
	GameController.pause(self)

	EventDispatcher.getInstance():unregister(EventConstants.onEventCallBack, self, self.onNativeCall);

	for i, v in pairs(self.s_eventHandle) do
		EventDispatcher.getInstance():unregister(i, self, v);
	end
end

-- @Override
function GameBaseController:stop()
	GameController.stop(self)

	EventDispatcher.getInstance():unregister(EventConstants.onEventCallBack, self, self.onNativeCall);

	for i, v in pairs(self.s_eventHandle) do
		EventDispatcher.getInstance():unregister(i, self, v);
	end
end

function GameBaseController:handleCmdEx(cmd, ...)
	if not self.s_cmdHandleEx[cmd] then
		Log.printWarn("gameBase", "Controller, no such cmd in s_cmdHandleEx");
		return;
	end

	return self.s_cmdHandleEx[cmd](self,...)
end

-- @Override
function GameBaseController:updateView(cmd, ...)
	if not self.m_view then
		return;
	end

	return self.m_view:handleCmdEx(cmd,...);
end

function GameBaseController:updateData(cmd, ...)
	if not self.m_data then
		return;
	end

	return self.m_data:handleCmdEx(cmd,...);
end

function GameBaseController:onNativeCall(key, status, data, ...)
    if not self.s_nativeHandle[key] then
		return;
    end

    self.s_nativeHandle[key](self, status, data, ...)
end

function GameBaseController:onHttpPorcesser(command, ...)
	Log.printInfo("gameBase", "GameBaseController.onHttpPorcesser");
	if not self.s_httpRequestsCallBack[command] then
		Log.printWarn("gameBase", "Not such request cmd in current controller");
		return;
	end
    self.s_httpRequestsCallBack[command](self,...); 
end

function GameBaseController:onSocketPorcesser(command, ...)
	Log.printInfo("gameBase", "GameBaseController.onSocketPorcesser");

	if self.suspendCondition and self:suspendCondition(command) then
		Log.printWarn("GameBaseController", "is suspending until the right command")
		return
	end
	if not self.s_socketCmdFuncMap[command] then
		Log.printWarn("gameBase", "Not such socket cmd in current controller");
		return;
	end
    self.s_socketCmdFuncMap[command](self,...); 
end

-- function GameBaseController:onBack()
-- 	Log.printInfo("gameBase", "GameBaseController.onBack");
	
-- 	for k,popupMap in pairs(nk.PopupManager.m_PopupMap) do
-- 		for j,popup in pairs(popupMap) do
-- 			if popup.s_instance then
-- 				popup:hide()
-- 				break
-- 			end
-- 		end
-- 	end
-- end

-- Provide cmd handle to call
-- 提供给scene和data调用
-- eg:xxxScene:requestCtrlCmd("***")
GameBaseController.s_cmdHandleEx = 
{
	--["***"] = function
};

-- Java to lua native call handle
-- 注册java调用lua的事件
GameBaseController.s_nativeHandle = {
    -- ["***"] = function
};

-- socket回调事件
GameBaseController.s_socketCmdFuncMap = {

}

-- http回调事件
GameBaseController.s_httpRequestsCallBack = {
	
}

-- Event to register and unregister
-- 要监听的事件，baseScene将自动监听的释放监听
-- 默认添加了http和socket事件
GameBaseController.s_base_eventHandle = {
    -- [Event ] = function
    [EventConstants.httpProcesser] = GameBaseController.onHttpPorcesser,
    [EventConstants.socketProcesser] = GameBaseController.onSocketPorcesser,
    -- [Event.Back] = GameBaseController.onBack,
};

