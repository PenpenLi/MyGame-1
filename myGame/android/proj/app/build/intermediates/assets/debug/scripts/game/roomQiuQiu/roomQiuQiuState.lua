-- roomQiuQiuState.lua
-- Last modification : 2016-07-12
-- Description: a state in room qiuqiu moudle

local RoomQiuQiuController = require("game.roomQiuQiu.roomQiuQiuController")
local RoomQiuQiuScene = require("game.roomQiuQiu.roomQiuQiuScene")
local RoomQiuQiuData = require("game.roomQiuQiu.roomQiuQiuData")
local RoomQiuQiuSceneView = require(VIEW_PATH .. "roomQiuQiu.roomQiuQiu_scene")
local RoomQiuQiuSceneVar = VIEW_PATH .. "roomQiuQiu.roomQiuQiu_scene_layout_var"

local RoomQiuQiuState = class(GameBaseState);

function RoomQiuQiuState:ctor()
	self.m_controller = nil
	self.m_style = "AsyncStyle"
end

function RoomQiuQiuState:start()
	if self.m_controller then
		self.m_controller:start()
	end
end

function RoomQiuQiuState:load()
	GameBaseState.load(self);
	self.m_controller = new(RoomQiuQiuController, self, RoomQiuQiuScene, RoomQiuQiuSceneView, RoomQiuQiuData, RoomQiuQiuSceneVar);
	return self
end

function RoomQiuQiuState:__after_delete()
	Clock.instance():schedule_once(function()
		collectgarbage()
	    TextureCache.instance():clean_unused()
	    -- TextureCache.instance():dump()
	end, 0.1)
end

return RoomQiuQiuState