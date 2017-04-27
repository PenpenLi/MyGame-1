--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		TextView_content = 3,
		Button_share = 4,
		Text_bt_share = 5,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image4","Text_title"},
		[3] = {"Image_bg","TextView_content"},
		[4] = {"Image_bg","Button_share"},
		[5] = {"Image_bg","Button_share","Text_bt_share"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "bt_share_click",
	},
}
return MAP;