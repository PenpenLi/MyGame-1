--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		text_time = 2,
		text_dynamic = 3,
		img_like = 4,
		text_like_times = 5,
		btn_delete = 6,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","text_time"},
		[3] = {"Image_bg","text_dynamic"},
		[4] = {"Image_bg","img_like"},
		[5] = {"Image_bg","img_like","text_like_times"},
		[6] = {"Image_bg","btn_delete"},
	},
	func = {
		[6] = "onBtnDeleteClick",
	},
}
return MAP;