--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_touch18 = 1,
		countTxt = 2,
		image_track = 3,
		fg = 4,
		image_bar = 5,
		allInBtn = 6,
		btnPot4 = 7,
		btnPot4Txt = 8,
		btnPot2 = 9,
		btnPot2Txt = 10,
		btnPot1 = 11,
		btnPot1Txt = 12,
		btnBet3 = 13,
		btnBet3Txt = 14,
	},
	ui = {
		[1] = {"Image_touch18"},
		[2] = {"bgNode","Image3","countTxt"},
		[3] = {"bgNode","Image3","image_track"},
		[4] = {"bgNode","Image3","image_track","fg"},
		[5] = {"bgNode","Image3","image_track","image_bar"},
		[6] = {"bgNode","Image3","allInBtn"},
		[7] = {"bgNode","Image3","btnPot4"},
		[8] = {"bgNode","Image3","btnPot4","btnPot4Txt"},
		[9] = {"bgNode","Image3","btnPot2"},
		[10] = {"bgNode","Image3","btnPot2","btnPot2Txt"},
		[11] = {"bgNode","Image3","btnPot1"},
		[12] = {"bgNode","Image3","btnPot1","btnPot1Txt"},
		[13] = {"bgNode","Image3","btnBet3"},
		[14] = {"bgNode","Image3","btnBet3","btnBet3Txt"},
	},
	func = {
		[1] = "onBgTouch",
	},
}
return MAP;