--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Image_kuang = 2,
		rewardView1 = 3,
		Image_reward1 = 4,
		Text_reward1 = 5,
		rewardView2 = 6,
		Image_reward2 = 7,
		Text_reward2 = 8,
		rewardView3 = 9,
		Image_reward3 = 10,
		Text_reward3 = 11,
		addIamge = 12,
		addIamge2 = 13,
		Image_bouns = 14,
		payAmountSelect = 15,
		payAmountTitle = 16,
		amountSelectMc = 17,
		amountTxt = 18,
		amountSelectBtn = 19,
		payTypeSelect = 20,
		payTypeTitle = 21,
		typeSelectMc = 22,
		typeTxt = 23,
		ListView50 = 24,
		typeSelectBtn = 25,
		Button36 = 26,
		buyBtnTxt = 27,
		View_tip = 28,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image_kuang"},
		[3] = {"Image_bg","Image_kuang","rewardView1"},
		[4] = {"Image_bg","Image_kuang","rewardView1","Image_reward1"},
		[5] = {"Image_bg","Image_kuang","rewardView1","Text_reward1"},
		[6] = {"Image_bg","Image_kuang","rewardView2"},
		[7] = {"Image_bg","Image_kuang","rewardView2","Image_reward2"},
		[8] = {"Image_bg","Image_kuang","rewardView2","Text_reward2"},
		[9] = {"Image_bg","Image_kuang","rewardView3"},
		[10] = {"Image_bg","Image_kuang","rewardView3","Image_reward3"},
		[11] = {"Image_bg","Image_kuang","rewardView3","Text_reward3"},
		[12] = {"Image_bg","Image_kuang","addIamge"},
		[13] = {"Image_bg","Image_kuang","addIamge2"},
		[14] = {"Image_bg","Image_kuang","Image_bouns"},
		[15] = {"Image_bg","payAmountSelect"},
		[16] = {"Image_bg","payAmountSelect","payAmountTitle"},
		[17] = {"Image_bg","payAmountSelect","amountSelectMc"},
		[18] = {"Image_bg","payAmountSelect","amountSelectMc","amountTxt"},
		[19] = {"Image_bg","payAmountSelect","amountSelectBtn"},
		[20] = {"Image_bg","payTypeSelect"},
		[21] = {"Image_bg","payTypeSelect","payTypeTitle"},
		[22] = {"Image_bg","payTypeSelect","typeSelectMc"},
		[23] = {"Image_bg","payTypeSelect","typeSelectMc","typeTxt"},
		[24] = {"Image_bg","payTypeSelect","ListView50"},
		[25] = {"Image_bg","payTypeSelect","typeSelectBtn"},
		[26] = {"Image_bg","Button36"},
		[27] = {"Image_bg","Button36","buyBtnTxt"},
		[28] = {"View_tip"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[19] = "onRefreshGoods",
		[25] = "onShowTypeList",
		[26] = "onClickPay",
	},
}
return MAP;