local DemoController = require("demo.demoController")
local DemoScene = require("demo.demoScene")

local DemoData = require("demo.demoData")

local DemoLayer = require(VIEW_PATH .. "demo/demoLayer")
local DemoLayerVar = VIEW_PATH .. "demo/demoLayer_layout_var"

local DemoState = class(GameBaseState);

function DemoState:ctor()
	-- Log.printInfo("DemoState.ctor");
	self.m_controller = nil
end

function DemoState:load()
	-- Log.printInfo("DemoState.load");
	GameBaseState.load(self);
	self.m_controller = new(DemoController, self, DemoScene, DemoLayer, DemoData, DemoLayerVar);

	return true
end

function DemoState:onBack()


end

return DemoState