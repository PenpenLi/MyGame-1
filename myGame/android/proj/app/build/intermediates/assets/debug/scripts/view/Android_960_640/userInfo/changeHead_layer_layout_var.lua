--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_change_head = 2,
		ScrollView_headList = 3,
		Text_tip = 4,
		Button_use = 5,
		Text_use = 6,
		Button_picture = 7,
		Text_photo = 8,
		Button_photo = 9,
		Text_picture = 10,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Text_change_head"},
		[3] = {"Image_bg","ScrollView_headList"},
		[4] = {"Image_bg","Text_tip"},
		[5] = {"Image_bg","Button_use"},
		[6] = {"Image_bg","Button_use","Text_use"},
		[7] = {"Image_bg","Button_picture"},
		[8] = {"Image_bg","Button_picture","Text_photo"},
		[9] = {"Image_bg","Button_photo"},
		[10] = {"Image_bg","Button_photo","Text_picture"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;