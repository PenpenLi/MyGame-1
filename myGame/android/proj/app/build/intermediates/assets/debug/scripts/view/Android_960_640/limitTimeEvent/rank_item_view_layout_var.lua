--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		headButton = 1,
		headImage = 2,
		Vipk = 3,
		cur_num = 4,
	},
	ui = {
		[1] = {"headButton"},
		[2] = {"headButton","headImage"},
		[3] = {"headButton","Vipk"},
		[4] = {"cur_num"},
	},
	func = {
		[1] = "onHeadButtonClick",
	},
}
return MAP;