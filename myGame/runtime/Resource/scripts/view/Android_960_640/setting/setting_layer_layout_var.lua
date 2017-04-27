--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		Image_head_bg = 3,
		Image_head_kuang = 4,
		Image_head = 5,
		Text_name = 6,
		Text_type = 7,
		Text_id = 8,
		Button_switch_account = 9,
		Text_switch_account = 10,
		View_clip = 11,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image3","Text_title"},
		[3] = {"Image_bg","Image_head_bg"},
		[4] = {"Image_bg","Image_head_bg","Image_head_kuang"},
		[5] = {"Image_bg","Image_head_bg","Image_head_kuang","Image_head"},
		[6] = {"Image_bg","Image_head_bg","Text_name"},
		[7] = {"Image_bg","Image_head_bg","Text_type"},
		[8] = {"Image_bg","Image_head_bg","Text_id"},
		[9] = {"Image_bg","Image_head_bg","Button_switch_account"},
		[10] = {"Image_bg","Image_head_bg","Text_switch_account"},
		[11] = {"Image_bg","View_clip"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;