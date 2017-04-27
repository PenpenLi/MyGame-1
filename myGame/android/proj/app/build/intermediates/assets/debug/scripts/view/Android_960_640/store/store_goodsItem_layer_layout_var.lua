--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		detailButton = 2,
		buyButton = 3,
		pointImage = 4,
		hotImage = 5,
		goosIcon = 6,
		Text_rate_add = 7,
		Text_gold = 8,
		goodsMoneyLabel = 9,
		changeMoneyLabel = 10,
		payMoneyLabel = 11,
		goldImage = 12,
		detailLabel = 13,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","detailButton"},
		[3] = {"bg","buyButton"},
		[4] = {"bg","pointImage"},
		[5] = {"bg","hotImage"},
		[6] = {"bg","goosIcon"},
		[7] = {"bg","Text_rate_add"},
		[8] = {"bg","Text_gold"},
		[9] = {"bg","goodsMoneyLabel"},
		[10] = {"bg","changeMoneyLabel"},
		[11] = {"bg","payMoneyLabel"},
		[12] = {"bg","goldImage"},
		[13] = {"bg","detailLabel"},
	},
	func = {
		[2] = "onDetailButtonClick",
		[3] = "onBuyButtonClick",
	},
}
return MAP;