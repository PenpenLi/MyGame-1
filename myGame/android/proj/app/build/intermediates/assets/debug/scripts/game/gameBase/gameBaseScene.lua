-- gameBaseScene.lua
-- Last modification : 2016-07-02
-- Description: extend gameScene class in core 

GameBaseScene = class(GameScene);

function GameBaseScene:ctor(viewConfig, controller, dataClass, varConfig)
    if varConfig then
        self:declareLayoutVar(varConfig)
    end
end

-- @Override
function GameBaseScene:resume()
    GameScene.resume(self)
    for i, v in pairs(self.s_eventHandle) do
        EventDispatcher.getInstance():register(i, self, v);
    end
end

-- @Override
function GameBaseScene:pause()
    GameScene.pause(self)
    for i, v in pairs(self.s_eventHandle) do
        EventDispatcher.getInstance():unregister(i, self, v);
    end
end

-- get ui from page which create by qn editor
-- 获取UI控件，从秦弩编辑器生成的页面中
function GameBaseScene:getUI(str)
    return self:getControl(self.s_controls[str])
end

-- @Override
function GameBaseScene:requestCtrlCmd(cmd, ...)
	if not self.m_controller then
		return
	end

	return self.m_controller:handleCmdEx(cmd, ...)
end

function GameBaseScene:handleCmdEx(cmd, ...)
	if not self.s_cmdHandleEx[cmd] then
		Log.printWarn("gameBase", "Layer, no such cmd");
		return;
	end

	return self.s_cmdHandleEx[cmd](self,...)
end

function GameBaseScene:dtor()
    
end

---------------------------------table config-----------------------------------------

-- Provide cmd handle to call
-- 提供给Controller调用
-- eg:xxxController:updateView("***")
GameBaseScene.s_cmdHandleEx = 
{
	--["***"] = function
};

-- Event to register and unregister
-- 要监听的事件，baseScene将自动监听的释放监听
GameBaseScene.s_eventHandle = {
    -- [Event ] = function
};