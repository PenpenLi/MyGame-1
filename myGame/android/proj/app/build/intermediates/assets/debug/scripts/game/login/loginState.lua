-- loginState.lua
-- Last modification : 2016-05-16
-- Description: a state in Login moudle
require("view.view_config")
local LoginSceneView = require(VIEW_PATH .. "login.login_scene")

local LoginController = require("game.login.loginController")
local LoginScene = require("game.login.loginScene")
local LoginData = require("game.login.loginData")
local LoginLayoutVar = VIEW_PATH .. "login.login_scene_layout_var"

local LoginState = class(GameBaseState);

function LoginState:ctor()
	Log.printInfo("LoginState.ctor");
	self.m_controller = nil;
end

function LoginState:load()
	GameBaseState.load(self);

	self.m_controller = new(LoginController, self, LoginScene, LoginSceneView, LoginData, LoginLayoutVar)
	return self
end

return LoginState