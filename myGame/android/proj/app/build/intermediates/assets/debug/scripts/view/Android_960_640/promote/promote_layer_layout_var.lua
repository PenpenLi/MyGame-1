--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		Image_info = 3,
		btn_go = 4,
		btn_go_text = 5,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image3","Text_title"},
		[3] = {"Image_bg","Image_info"},
		[4] = {"Image_bg","btn_go"},
		[5] = {"Image_bg","btn_go","btn_go_text"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "btn_go_click",
	},
}
return MAP;