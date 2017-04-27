--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		popup_bg = 1,
		progressBg = 2,
		progressBarImage = 3,
		tipLabel = 4,
		shareButton = 5,
		shareLabel = 6,
		closeButton = 7,
		itemsView = 8,
	},
	ui = {
		[1] = {"popup_bg"},
		[2] = {"popup_bg","progressBg"},
		[3] = {"popup_bg","progressBg","progressBarImage"},
		[4] = {"popup_bg","tipLabel"},
		[5] = {"popup_bg","shareButton"},
		[6] = {"popup_bg","shareButton","shareLabel"},
		[7] = {"popup_bg","closeButton"},
		[8] = {"popup_bg","itemsView"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[5] = "onShareButtonClick",
		[7] = "onCloseBtnClick",
	},
}
return MAP;