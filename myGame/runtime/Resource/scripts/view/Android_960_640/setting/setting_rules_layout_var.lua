--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		RadioButtonGroup = 2,
		Text_l = 3,
		Text_m = 4,
		Text_r = 5,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","RadioButtonGroup"},
		[3] = {"Image_bg","RadioButtonGroup","RadioButton_l","Text_l"},
		[4] = {"Image_bg","RadioButtonGroup","RadioButton_m","Text_m"},
		[5] = {"Image_bg","RadioButtonGroup","RadioButton_r","Text_r"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;