--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		popupBg = 1,
		TextTitle = 2,
		Image_sex_frame = 3,
		Image_user_icon = 4,
		TextName = 5,
		TextUID = 6,
		TextTips = 7,
		ButtonCancel = 8,
		TextCancel = 9,
		ButtonSure = 10,
		TextSure = 11,
	},
	ui = {
		[1] = {"Image2"},
		[2] = {"Image2","Image4","Text4"},
		[3] = {"Image2","Image6","Image11","Image_sex_frame"},
		[4] = {"Image2","Image6","Image11","View61","Image_user_icon"},
		[5] = {"Image2","Image6","Text13"},
		[6] = {"Image2","Image6","Text14"},
		[7] = {"Image2","Image6","TextView16"},
		[8] = {"Image2","Button18"},
		[9] = {"Image2","Button18","Text21"},
		[10] = {"Image2","Button19"},
		[11] = {"Image2","Button19","Text22"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[8] = "onClose",
		[10] = "onBtnSureClick",
	},
}
return MAP;