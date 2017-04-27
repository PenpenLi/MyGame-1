--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		popup_bg = 1,
		title = 2,
		message = 3,
		firstBtn = 4,
		firstBtn_text = 5,
		secondBtn = 6,
		secondBtn_text = 7,
	},
	ui = {
		[1] = {"popup_bg"},
		[2] = {"popup_bg","Image3","title"},
		[3] = {"popup_bg","message"},
		[4] = {"popup_bg","firstBtn"},
		[5] = {"popup_bg","firstBtn","firstBtn_text"},
		[6] = {"popup_bg","secondBtn"},
		[7] = {"popup_bg","secondBtn","secondBtn_text"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "onFirstBtnClick",
		[6] = "onSecondBtnClick",
	},
}
return MAP;