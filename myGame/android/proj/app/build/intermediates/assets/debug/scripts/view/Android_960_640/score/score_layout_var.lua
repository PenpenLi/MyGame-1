--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Bg = 1,
		Title = 2,
		Tip = 3,
		CommitBtn = 4,
		BtnText = 5,
	},
	ui = {
		[1] = {"Bg"},
		[2] = {"Bg","Title"},
		[3] = {"Bg","Tip"},
		[4] = {"Bg","CommitBtn"},
		[5] = {"Bg","CommitBtn","BtnText"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "onCommitClick",
	},
}
return MAP;