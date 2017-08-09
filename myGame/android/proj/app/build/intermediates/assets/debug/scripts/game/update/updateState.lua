-- updateState.lua
-- Last modification : 2016-05-27
-- Description: a state in update moudle

local UpdateController = require("game.update.updateController")
local UpdateScene = require("game.update.updateScene")
local UpdateData = require("game.update.updateData")
local UpdateSceneView = require(VIEW_PATH .. "update.update_scene")
-- local UpdateSceneView = require("view.Android_800_480.hall_view")
local varConfigPath = VIEW_PATH .. "update.update_scene_layout_var"

local UpdateState = class(GameBaseState);

function UpdateState:ctor()
	Log.printInfo("UpdateState.ctor");
	self.m_controller = nil;
end

function UpdateState:load()
	Log.printInfo("UpdateState.load");
	GameBaseState.load(self);

	self.m_controller = new(UpdateController, self, UpdateScene, UpdateSceneView, UpdateData, varConfigPath);
	Log.printInfo("UpdateState.return true");
	return true
end

return UpdateState