--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bgView = 1,
		topImage = 2,
		totalNumLabel = 3,
		totalMoneyLabel = 4,
		detailLabel = 5,
		getAllButton = 6,
		getAllLabel = 7,
		beforeButton = 8,
		afterButton = 9,
		dateLabel = 10,
		tipNoLabel = 11,
		awardScrollView = 12,
	},
	ui = {
		[1] = {"bgView"},
		[2] = {"bgView","topImage"},
		[3] = {"bgView","topImage","totalNumLabel"},
		[4] = {"bgView","topImage","totalMoneyLabel"},
		[5] = {"bgView","detailLabel"},
		[6] = {"bgView","getAllButton"},
		[7] = {"bgView","getAllButton","getAllLabel"},
		[8] = {"bgView","Image7","beforeButton"},
		[9] = {"bgView","Image7","afterButton"},
		[10] = {"bgView","Image7","dateLabel"},
		[11] = {"bgView","Image7","tipNoLabel"},
		[12] = {"bgView","Image7","awardScrollView"},
	},
	func = {
		[6] = "onGetAllButtonClick",
		[8] = "onBeforeButtonClick",
		[9] = "onAfterButtonClick",
	},
}
return MAP;