--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		titleLabel = 2,
		buyinMoneyLabel = 3,
		minBuyinMoney = 4,
		minBuyinLabel = 5,
		addButton = 6,
		deleteButton = 7,
		sliderBg = 8,
		sliderProgress = 9,
		thumbImage = 10,
		maxBuyinMoney = 11,
		maxBuyinLabel = 12,
		buyinButton = 13,
		buyinLabel = 14,
		outoBuyinLabel = 15,
		checkButton = 16,
		checkImage = 17,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","titleBg","titleLabel"},
		[3] = {"bg","buyinMoneyBg","buyinMoneyLabel"},
		[4] = {"bg","minBuyinMoney"},
		[5] = {"bg","minBuyinLabel"},
		[6] = {"bg","addButton"},
		[7] = {"bg","deleteButton"},
		[8] = {"bg","sliderBg"},
		[9] = {"bg","sliderBg","sliderProgress"},
		[10] = {"bg","sliderBg","thumbImage"},
		[11] = {"bg","maxBuyinMoney"},
		[12] = {"bg","maxBuyinLabel"},
		[13] = {"bg","buyinButton"},
		[14] = {"bg","buyinButton","buyinLabel"},
		[15] = {"bg","outoBuyinLabel"},
		[16] = {"bg","checkButton"},
		[17] = {"bg","checkButton","checkImage"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[6] = "onAddButtonClick",
		[7] = "onDeleteButtonClick",
		[10] = "onThumbTouch_",
		[13] = "onBuyinButtonClick",
		[16] = "onCheckButtonClick",
	},
}
return MAP;