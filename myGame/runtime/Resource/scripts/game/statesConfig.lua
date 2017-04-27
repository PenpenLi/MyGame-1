-- statesConfig.lua
-- Last modification : 2016-05-11
-- Description: A config of states 

States = 
{
	Login 						= 1,
	Hall 						= 2,
	Update 						= 5,
	RoomGaple 				    = 6,
	Store 						= 7,
	Friend 						= 8,
	Rank						= 9,
	RoomQiuQiu 					= 11,
	Demo 				    	= 12,
};

StatesMap = 
{
	-- [States.Hall] = require("game.hall.hallState")
	[States.Update] = "game.update.updateState",
	[States.Hall] = "game.hall.hallState",
	[States.Login] = "game.login.loginState",
	[States.Store] = "game.store.storeState",
	[States.RoomGaple] = "game.roomGaple.roomGapleState",
	[States.Friend] = "game.friend.friendState",
	[States.Rank] = "game.rank.rankState",
	[States.RoomQiuQiu] = "game.roomQiuQiu.roomQiuQiuState",
	[States.Demo] = "demo.demoState",
};
 