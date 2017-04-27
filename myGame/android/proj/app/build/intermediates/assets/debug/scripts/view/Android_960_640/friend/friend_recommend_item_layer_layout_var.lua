--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		nameLabel = 2,
		headImage = 3,
		moneyLabel = 4,
		addButton = 5,
		addLabel = 6,
		SexIcon = 7,
		View_vip = 8,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","nameLabel"},
		[3] = {"bg","headImage"},
		[4] = {"bg","moneyLabel"},
		[5] = {"bg","addButton"},
		[6] = {"bg","addButton","addLabel"},
		[7] = {"bg","SexIcon"},
		[8] = {"View_vip"},
	},
	func = {
		[3] = "onDetailButtonClick",
		[5] = "onAddButtonClick",
	},
}
return MAP;