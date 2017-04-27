--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		buyButton = 2,
		pointImage = 3,
		hotImage = 4,
		goosIcon = 5,
		goodsMoneyLabel = 6,
		changeMoneyLabel = 7,
		payMoneyLabel = 8,
		goldImage = 9,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","buyButton"},
		[3] = {"bg","pointImage"},
		[4] = {"bg","hotImage"},
		[5] = {"bg","goosIcon"},
		[6] = {"bg","goodsMoneyLabel"},
		[7] = {"bg","changeMoneyLabel"},
		[8] = {"bg","payMoneyLabel"},
		[9] = {"bg","goldImage"},
	},
	func = {
		[2] = "onBuyButtonClick",
	},
}
return MAP;