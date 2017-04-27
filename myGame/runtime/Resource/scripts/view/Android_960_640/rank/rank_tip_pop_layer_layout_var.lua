--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		titleLabel = 2,
		closeButton = 3,
		tipContentLabel = 4,
		playButton = 5,
		playBtnLabel = 6,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","titleBg","titleLabel"},
		[3] = {"bg","closeButton"},
		[4] = {"bg","tipContentLabel"},
		[5] = {"bg","playButton"},
		[6] = {"bg","playButton","playBtnLabel"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[3] = "onCloseButtonClick",
		[5] = "onPlayButtonClick",
	},
}
return MAP;