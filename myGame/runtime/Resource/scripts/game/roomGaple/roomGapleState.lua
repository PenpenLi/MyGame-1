-- hallState.lua
-- Last modification : 2016-05-11
-- Description: a state in Hall moudle

local RoomGapleController = require("game.roomGaple.roomGapleController")
local RoomGapleScene = require("game.roomGaple.roomGapleScene")
local RoomGapleData = require("game.roomGaple.roomGapleData")
local RoomGapleSceneView = require(VIEW_PATH .. "roomGaple.roomGaple_scene")
local RoomGapleSceneLayoutVar = VIEW_PATH .. "roomGaple.roomGaple_scene_layout_var"

local RoomGapleState = class(GameBaseState);

function RoomGapleState:ctor()
	self.m_controller = nil
	self.m_style = "AsyncStyle"
end

function RoomGapleState:load()
	GameBaseState.load(self)
	self.m_controller = new(RoomGapleController, self, RoomGapleScene, RoomGapleSceneView, RoomGapleData, RoomGapleSceneLayoutVar)
	return self
end

function RoomGapleState:__after_delete()
	Clock.instance():schedule_once(function()
		collectgarbage()
	    TextureCache.instance():clean_unused()
	    -- TextureCache.instance():dump()
	end, 0.1)
end

return RoomGapleState