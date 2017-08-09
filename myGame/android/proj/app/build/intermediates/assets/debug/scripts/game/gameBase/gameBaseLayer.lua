-- gameBaseLayer.lua
-- Last modification : 2016-07-02
-- Description: extend gameLayer class in core 

GameBaseLayer = class(GameLayer);

function GameBaseLayer:ctor(viewConfig, varConfig)
	Log.printInfo("GameBaseLayer.ctor");
	if varConfig then
        self:declareLayoutVar(varConfig)
    end
    for i, v in pairs(self.s_eventHandle) do
		EventDispatcher.getInstance():register(i, self, v);
	end
end

function GameBaseLayer:dtor()
	Log.printInfo("GameBaseLayer.dtor");
	for i, v in pairs(self.s_eventHandle) do
		EventDispatcher.getInstance():unregister(i, self, v);
	end
end

-- get ui from page which create by qn editor
-- 获取UI控件，从秦弩编辑器生成的页面中
function GameBaseLayer:getUI(str)
    if self.s_controls[str] then
	   return self:getControl(self.s_controls[str])
    else
        return nil   
    end
end

function GameBaseLayer:handleCmdEx(cmd, ...)
	if not self.s_cmdHandleEx[cmd] then
		Log.printWarn("gameBase", "Layer, no such cmd");
		return;
	end

	return self.s_cmdHandleEx[cmd](self,...)
end

---------------------------------table config-----------------------------------------

-- Event to register and unregister
-- 要监听的事件，baseScene将自动监听的释放监听
GameBaseLayer.s_eventHandle = {
    -- [Event ] = function
};