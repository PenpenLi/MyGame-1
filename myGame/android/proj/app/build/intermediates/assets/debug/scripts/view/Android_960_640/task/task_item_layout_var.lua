--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Image_icon = 2,
		Word = 3,
		Text_content = 4,
		Text_reward = 5,
		Text_num = 6,
		Button_get = 7,
		Text_bt_get = 8,
		Button_reward = 9,
		Text_bt_reward = 10,
		Button_goto = 11,
		Text_bt_goto = 12,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image_icon"},
		[3] = {"Image_bg","Image_icon","Word"},
		[4] = {"Image_bg","Text_content"},
		[5] = {"Image_bg","Text_reward"},
		[6] = {"Image_bg","Text_num"},
		[7] = {"Image_bg","Button_get"},
		[8] = {"Image_bg","Button_get","Text_bt_get"},
		[9] = {"Image_bg","Button_reward"},
		[10] = {"Image_bg","Button_reward","Text_bt_reward"},
		[11] = {"Image_bg","Button_goto"},
		[12] = {"Image_bg","Button_goto","Text_bt_goto"},
	},
	func = {
	},
}
return MAP;