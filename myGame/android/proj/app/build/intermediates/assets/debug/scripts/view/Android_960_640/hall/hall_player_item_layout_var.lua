--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		player_bg = 1,
		head = 2,
		name = 3,
		money = 4,
		trace_btn = 5,
		SexIcon = 6,
		View_vip = 7,
	},
	ui = {
		[1] = {"player_bg"},
		[2] = {"player_bg","head"},
		[3] = {"player_bg","name"},
		[4] = {"player_bg","money"},
		[5] = {"player_bg","trace_btn"},
		[6] = {"player_bg","SexIcon"},
		[7] = {"player_bg","View_vip"},
	},
	func = {
		[1] = "onPlayerBgClick",
		[5] = "onOperatorBtnClick",
	},
}
return MAP;