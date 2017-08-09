-- friendState.lua
-- Last modification : 2016-06-03
-- Description: a state in Friend moudle

local FriendController = require("game.friend.friendController")
local FriendScene = require("game.friend.friendScene")
local FriendData = require("game.friend.friendData")
local FriendSceneView = require(VIEW_PATH .. "friend.friend_scene")
local FriendSceneVar = VIEW_PATH .. "friend.friend_scene_layout_var"

local FriendState = class(GameBaseState);

function FriendState:ctor()
	Log.printInfo("FriendState.ctor");
	self.m_controller = nil;
end

function FriendState:load()
	Log.printInfo("FriendState.load");
	GameBaseState.load(self);

	self.m_controller = new(FriendController, self, FriendScene, FriendSceneView, FriendData, FriendSceneVar);
	return true
end

return FriendState