--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Image_tab = 2,
		RadioButtonGroup = 3,
		RadioButton_l = 4,
		Text_l = 5,
		Image_day_redPoint = 6,
		RadioButton_r = 7,
		Text_r = 8,
		Image_grow_redPoint = 9,
		ListView_day = 10,
		ListView_grow = 11,
		Image_ex_reward = 12,
		Text_tip = 13,
		Image_progress_bg = 14,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image_tab"},
		[3] = {"Image_bg","Image_tab","RadioButtonGroup"},
		[4] = {"Image_bg","Image_tab","RadioButtonGroup","RadioButton_l"},
		[5] = {"Image_bg","Image_tab","RadioButtonGroup","RadioButton_l","Text_l"},
		[6] = {"Image_bg","Image_tab","RadioButtonGroup","RadioButton_l","Text_l","Image_day_redPoint"},
		[7] = {"Image_bg","Image_tab","RadioButtonGroup","RadioButton_r"},
		[8] = {"Image_bg","Image_tab","RadioButtonGroup","RadioButton_r","Text_r"},
		[9] = {"Image_bg","Image_tab","RadioButtonGroup","RadioButton_r","Text_r","Image_grow_redPoint"},
		[10] = {"ListView_day"},
		[11] = {"ListView_grow"},
		[12] = {"Image_ex_reward"},
		[13] = {"Image_ex_reward","Text_tip"},
		[14] = {"Image_ex_reward","Image_progress_bg"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;