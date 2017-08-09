-- storeState.lua
-- Last modification : 2016-06-03
-- Description: a state in Store moudle

local StoreController = require("game.store.storeController")
local StoreScene = require("game.store.storeScene")
local StoreData = require("game.store.storeData")
local StoreSceneView = require(VIEW_PATH .. "store.store_scene")
local StoreSceneVar = VIEW_PATH .. "store.store_scene_layout_var"

local StoreState = class(GameBaseState);

function StoreState:ctor()
	Log.printInfo("StoreState.ctor");
	self.m_controller = nil;
end

function StoreState:load()
	Log.printInfo("StoreState.load");
	GameBaseState.load(self);

	self.m_controller = new(StoreController, self, StoreScene, StoreSceneView, StoreData, StoreSceneVar)
	return true
end

return StoreState