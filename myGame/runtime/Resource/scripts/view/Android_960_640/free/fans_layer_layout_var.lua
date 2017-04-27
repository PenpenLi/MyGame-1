--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		EditText_code = 3,
		TextView_content = 4,
		TextView_url = 5,
		Button_code = 6,
		Text_bt_code = 7,
		Button_fans = 8,
		Text_bt_link = 9,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image4","Text_title"},
		[3] = {"Image_bg","Image6","EditText_code"},
		[4] = {"Image_bg","Image8","TextView_content"},
		[5] = {"Image_bg","Image8","TextView_url"},
		[6] = {"Image_bg","Button_code"},
		[7] = {"Image_bg","Button_code","Text_bt_code"},
		[8] = {"Image_bg","Button_fans"},
		[9] = {"Image_bg","Button_fans","Text_bt_link"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[6] = "bt_code_click",
		[8] = "bt_fans_click",
	},
}
return MAP;