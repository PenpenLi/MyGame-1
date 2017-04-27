--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Bg = 1,
		Title = 2,
		GoBtn = 3,
		BtnText = 4,
	},
	ui = {
		[1] = {"Bg"},
		[2] = {"Bg","Title"},
		[3] = {"Bg","GoBtn"},
		[4] = {"Bg","GoBtn","BtnText"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[3] = "onGoClick",
	},
}
return MAP;