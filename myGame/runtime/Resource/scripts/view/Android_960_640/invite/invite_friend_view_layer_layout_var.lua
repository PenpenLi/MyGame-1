--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bgView = 1,
		checkButton = 2,
		checkBgImage = 3,
		checkImage = 4,
		inviteButton = 5,
		inviteLabel = 6,
		searchEditBox = 7,
		searchButton = 8,
		checkAllLabel = 9,
		itemScrollView = 10,
		bottomImage = 11,
		chooseTipLabel = 12,
	},
	ui = {
		[1] = {"bgView"},
		[2] = {"bgView","topImage","checkButton"},
		[3] = {"bgView","topImage","checkBgImage"},
		[4] = {"bgView","topImage","checkBgImage","checkImage"},
		[5] = {"bgView","topImage","inviteButton"},
		[6] = {"bgView","topImage","inviteButton","inviteLabel"},
		[7] = {"bgView","topImage","Image7","searchEditBox"},
		[8] = {"bgView","topImage","Image7","searchButton"},
		[9] = {"bgView","topImage","checkAllLabel"},
		[10] = {"bgView","itemScrollView"},
		[11] = {"bgView","bottomImage"},
		[12] = {"bgView","bottomImage","chooseTipLabel"},
	},
	func = {
		[2] = "onCheckButtonClick",
		[5] = "onInviteButtonClick",
		[8] = "onSearchButtonClick",
	},
}
return MAP;