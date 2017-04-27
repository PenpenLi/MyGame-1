--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		titleTxt = 2,
		contentTxt = 3,
		Button6 = 4,
		sendBtnTxt = 5,
		soonImage_1 = 6,
		uploadPicTxt_1 = 7,
		soonImage_2 = 8,
		uploadPicTxt_2 = 9,
		soonImage_3 = 10,
		uploadPicTxt_3 = 11,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","titleTxt"},
		[3] = {"Image_bg","contentTxt"},
		[4] = {"Image_bg","Button6"},
		[5] = {"Image_bg","Button6","sendBtnTxt"},
		[6] = {"Image_bg","soonImage_1"},
		[7] = {"Image_bg","soonImage_1","uploadPicTxt_1"},
		[8] = {"Image_bg","soonImage_2"},
		[9] = {"Image_bg","soonImage_2","uploadPicTxt_2"},
		[10] = {"Image_bg","soonImage_3"},
		[11] = {"Image_bg","soonImage_3","uploadPicTxt_3"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "onSend",
	},
}
return MAP;