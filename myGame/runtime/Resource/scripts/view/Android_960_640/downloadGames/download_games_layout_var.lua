--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		ScrollView_games = 3,
		text_no_games = 4,
		text_info = 5,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image8","Text_title"},
		[3] = {"Image_bg","ScrollView_games"},
		[4] = {"Image_bg","text_no_games"},
		[5] = {"Image_bg","text_info"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;