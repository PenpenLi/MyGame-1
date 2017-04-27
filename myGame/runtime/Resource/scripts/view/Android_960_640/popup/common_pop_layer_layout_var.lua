--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		titleLabel = 1,
		twoBtnView = 2,
		twoCancleButton = 3,
		twoCancleLabel = 4,
		twoSureButton = 5,
		twoSureLabel = 6,
		oneBtnView = 7,
		oneSureButton = 8,
		oneSureLabel = 9,
		contentView = 10,
		CloseBtn = 11,
	},
	ui = {
		[1] = {"bg","titleBg","titleLabel"},
		[2] = {"bg","twoBtnView"},
		[3] = {"bg","twoBtnView","twoCancleButton"},
		[4] = {"bg","twoBtnView","twoCancleButton","twoCancleLabel"},
		[5] = {"bg","twoBtnView","twoSureButton"},
		[6] = {"bg","twoBtnView","twoSureButton","twoSureLabel"},
		[7] = {"bg","oneBtnView"},
		[8] = {"bg","oneBtnView","oneSureButton"},
		[9] = {"bg","oneBtnView","oneSureButton","oneSureLabel"},
		[10] = {"bg","contentView"},
		[11] = {"bg","CloseBtn"},
	},
	func = {
		[3] = "onCancleButtonClick",
		[5] = "onSureButtonClick",
		[8] = "onSureButtonClick",
		[11] = "onCloseBtnClick",
	},
}
return MAP;