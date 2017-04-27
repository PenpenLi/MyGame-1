--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_thankyou = 2,
		Text_version = 3,
		Text_down = 4,
		Text_share_tip = 5,
		Button_share = 6,
		Text_share = 7,
		Text_title = 8,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Text_thankyou"},
		[3] = {"Image_bg","Text_version"},
		[4] = {"Image_bg","Text_down"},
		[5] = {"Image_bg","Text_share_tip"},
		[6] = {"Image_bg","Button_share"},
		[7] = {"Image_bg","Text_share"},
		[8] = {"Image_bg","Text_title"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;