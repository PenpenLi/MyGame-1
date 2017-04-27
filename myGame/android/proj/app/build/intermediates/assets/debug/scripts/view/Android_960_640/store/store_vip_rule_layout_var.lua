--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_touch = 1,
		Image_bg = 2,
		RadioButtonGroup = 3,
		RadioButton_l = 4,
		Text_l = 5,
		RadioButton_r = 6,
		Text_r = 7,
		View_vip_level = 8,
		ListView_vip = 9,
		View_vip_rule = 10,
		TextView_rule = 11,
	},
	ui = {
		[1] = {"Image_touch"},
		[2] = {"Image_bg"},
		[3] = {"Image_bg","Image_tab12","RadioButtonGroup"},
		[4] = {"Image_bg","Image_tab12","RadioButtonGroup","RadioButton_l"},
		[5] = {"Image_bg","Image_tab12","RadioButtonGroup","RadioButton_l","Text_l"},
		[6] = {"Image_bg","Image_tab12","RadioButtonGroup","RadioButton_r"},
		[7] = {"Image_bg","Image_tab12","RadioButtonGroup","RadioButton_r","Text_r"},
		[8] = {"Image_bg","View_vip_level"},
		[9] = {"Image_bg","View_vip_level","ListView_vip"},
		[10] = {"Image_bg","View_vip_rule"},
		[11] = {"Image_bg","View_vip_rule","TextView_rule"},
	},
	func = {
		[1] = "onBgTouch",
		[2] = "onPopupBgTouch",
	},
}
return MAP;