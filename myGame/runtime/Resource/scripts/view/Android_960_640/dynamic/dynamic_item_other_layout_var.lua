--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		text_time = 2,
		text_dynamic = 3,
		btn_like = 4,
		text_like_times = 5,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","text_time"},
		[3] = {"Image_bg","text_dynamic"},
		[4] = {"Image_bg","btn_like"},
		[5] = {"Image_bg","text_like_times"},
	},
	func = {
		[4] = "onBtnLikeClick",
	},
}
return MAP;