--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		btn_video = 3,
		img_loading = 4,
		text_loading = 5,
		text_desc = 6,
		text_reward = 7,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image8","Text_title"},
		[3] = {"Image_bg","btn_video"},
		[4] = {"Image_bg","btn_video","img_loading"},
		[5] = {"Image_bg","btn_video","img_loading","text_loading"},
		[6] = {"Image_bg","text_desc"},
		[7] = {"Image_bg","text_reward"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[3] = "onBtnVideoClick",
		[4] = "onImgLoadingClick",
	},
}
return MAP;