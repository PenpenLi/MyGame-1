--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Bg = 1,
		CommitBtn = 2,
		BtnText = 3,
		Desc = 4,
		Opiniont = 5,
	},
	ui = {
		[1] = {"Bg"},
		[2] = {"Bg","CommitBtn"},
		[3] = {"Bg","CommitBtn","BtnText"},
		[4] = {"Bg","Desc"},
		[5] = {"Bg","Opiniont"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[2] = "onCommitClick",
	},
}
return MAP;