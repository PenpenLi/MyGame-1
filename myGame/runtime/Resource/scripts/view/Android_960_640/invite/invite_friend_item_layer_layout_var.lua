--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		itemButton = 1,
		nameLabel = 2,
		moneyLabel = 3,
		SexIcon = 4,
		headImage = 5,
		Vipk = 6,
		checkImage = 7,
	},
	ui = {
		[1] = {"View2","itemButton"},
		[2] = {"View2","itemButton","nameLabel"},
		[3] = {"View2","itemButton","moneyLabel"},
		[4] = {"View2","itemButton","SexIcon"},
		[5] = {"View2","itemButton","headImage"},
		[6] = {"View2","itemButton","Vipk"},
		[7] = {"checkImage"},
	},
	func = {
		[1] = "onItemButtonClick",
	},
}
return MAP;