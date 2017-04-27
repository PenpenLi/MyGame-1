--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		swf_level_up = 1,
		gold_bg = 2,
		text_reward = 3,
		text_level_up = 4,
	},
	ui = {
		[1] = {"swf_level_up"},
		[2] = {"gold_bg"},
		[3] = {"gold_bg","text_reward"},
		[4] = {"gold_bg","text_level_up"},
	},
	func = {
		[1] = "onSwfLeveUpClick",
	},
}
return MAP;