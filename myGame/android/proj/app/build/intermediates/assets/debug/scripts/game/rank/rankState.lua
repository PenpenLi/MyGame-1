-- rankState.lua
-- Last modification : 2016-06-03
-- Description: a state in Rank moudle

local RankController = require("game.rank.rankController")
local RankScene = require("game.rank.rankScene")
local RankData = require("game.rank.rankData")
local RankSceneView = require(VIEW_PATH .. "rank.rank_scene")
local RankSceneVar = VIEW_PATH .. "rank.rank_scene_layout_var"

local RankState = class(GameBaseState);

function RankState:ctor()
	Log.printInfo("RankState.ctor");
	self.m_controller = nil;
end

function RankState:load()
	Log.printInfo("RankState.load");
	GameBaseState.load(self);

	self.m_controller = new(RankController, self, RankScene, RankSceneView, RankData, RankSceneVar);
	return true
end

return RankState