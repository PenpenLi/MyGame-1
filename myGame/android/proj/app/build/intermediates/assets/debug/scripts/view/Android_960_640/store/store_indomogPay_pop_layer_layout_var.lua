--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_touch = 1,
		bg = 2,
		titleLabel = 3,
		closeButton = 4,
		accountLabel = 5,
		passwordLabel = 6,
		accountEditBox = 7,
		passwordEditBox = 8,
		sureButton = 9,
		sureLabel = 10,
		cancelButton = 11,
		cancelLabel = 12,
	},
	ui = {
		[1] = {"Image_touch"},
		[2] = {"bg"},
		[3] = {"bg","Image3","titleLabel"},
		[4] = {"bg","closeButton"},
		[5] = {"bg","accountLabel"},
		[6] = {"bg","passwordLabel"},
		[7] = {"bg","accountEditBoxBg","accountEditBox"},
		[8] = {"bg","passwordEditBoxBg","passwordEditBox"},
		[9] = {"bg","View12","sureButton"},
		[10] = {"bg","View12","sureButton","sureLabel"},
		[11] = {"bg","View12","cancelButton"},
		[12] = {"bg","View12","cancelButton","cancelLabel"},
	},
	func = {
		[1] = "onCloseButtonClick",
		[2] = "itemTouch",
		[4] = "onCloseButtonClick",
		[9] = "onSureButtonClick",
		[11] = "onCancelButtonClick",
	},
}
return MAP;