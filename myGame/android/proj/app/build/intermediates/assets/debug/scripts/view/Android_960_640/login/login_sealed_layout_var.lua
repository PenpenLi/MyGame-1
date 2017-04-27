--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		TextView_content = 3,
		Buttton_help = 4,
		Text_mode = 5,
		Text_time = 6,
		Text_info = 7,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image3","Text_title"},
		[3] = {"Image_bg","TextView_content"},
		[4] = {"Image_bg","Buttton_help"},
		[5] = {"Image_bg","Text_mode"},
		[6] = {"Image_bg","Text_time"},
		[7] = {"Image_bg","Text_info"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "sealedBtnClick",
	},
}
return MAP;