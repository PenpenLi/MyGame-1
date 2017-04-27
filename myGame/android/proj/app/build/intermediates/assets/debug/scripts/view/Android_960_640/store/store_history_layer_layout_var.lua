--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_touch = 1,
		Image_bg = 2,
		Text_title = 3,
		ListView_history = 4,
		Text_noData = 5,
	},
	ui = {
		[1] = {"Image_touch"},
		[2] = {"Image_bg"},
		[3] = {"Image_bg","Text_title"},
		[4] = {"Image_bg","ListView_history"},
		[5] = {"Image_bg","Text_noData"},
	},
	func = {
		[1] = "onBgTouch",
		[2] = "onPopupBgTouch",
	},
}
return MAP;