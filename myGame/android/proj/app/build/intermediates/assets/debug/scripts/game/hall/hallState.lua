-- hallState.lua
-- Last modification : 2016-05-11
-- Description: a state in Hall moudle

local HallController = require("game.hall.hallController")
local HallScene = require("game.hall.hallScene")
local HallData = require("game.hall.hallData")
local HallSceneView = require(VIEW_PATH .. "hall.hall_scene")
local HallSceneLayoutVar = VIEW_PATH .. "hall.hall_scene_layout_var"

local HallState = class(GameBaseState);

function HallState:ctor()
	-- Log.printInfo("HallState.ctor");
	self.m_controller = nil
	self.m_style = "AsyncStyle"
end

function HallState:load()
	-- Log.printInfo("HallState.load");
	GameBaseState.load(self);
	self.m_controller = new(HallController, self, HallScene, HallSceneView, HallData, HallSceneLayoutVar);
	return true
end

function HallState:__after_delete()
	Clock.instance():schedule_once(function()
		collectgarbage()
	    TextureCache.instance():clean_unused()
	    -- TextureCache.instance():dump()
	end, 0.1)
end

return HallState