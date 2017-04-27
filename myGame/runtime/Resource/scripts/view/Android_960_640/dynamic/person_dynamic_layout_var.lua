--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Text_title = 2,
		ScrollView_dynamic = 3,
		text_total_dynamics = 4,
		text_tips = 5,
		text_no_dynamic = 6,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image8","Text_title"},
		[3] = {"Image_bg","ScrollView_dynamic"},
		[4] = {"Image_bg","text_total_dynamics"},
		[5] = {"Image_bg","text_tips"},
		[6] = {"Image_bg","text_no_dynamic"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;