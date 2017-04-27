--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		title = 2,
		binding_btn = 3,
		binding_name = 4,
		bind_tips = 5,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","title"},
		[3] = {"Image_bg","binding_btn"},
		[4] = {"Image_bg","binding_btn","binding_name"},
		[5] = {"Image_bg","bind_tips"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;