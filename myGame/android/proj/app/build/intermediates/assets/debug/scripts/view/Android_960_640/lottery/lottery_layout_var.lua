--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Bg = 1,
		LotteryButton = 2,
		Num = 3,
		CloseButton = 4,
		Select = 5,
	},
	ui = {
		[1] = {"Bg"},
		[2] = {"Bg","LotteryButton"},
		[3] = {"Bg","LotteryButton","Num"},
		[4] = {"Bg","CloseButton"},
		[5] = {"Bg","Select"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[2] = "OnLotteryClick",
		[4] = "OnCloseClick",
	},
}
return MAP;