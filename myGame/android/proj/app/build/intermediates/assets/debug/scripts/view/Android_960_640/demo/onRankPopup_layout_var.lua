--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		RadioButtonGroup = 2,
		gentleRadioButton = 3,
		crazyRadioButton = 4,
		ListView = 5,
		ImageHead = 6,
		myRankTextView = 7,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","RadioButtonGroup"},
		[3] = {"bg","RadioButtonGroup","gentleRadioButton"},
		[4] = {"bg","RadioButtonGroup","crazyRadioButton"},
		[5] = {"bg","ListView"},
		[6] = {"bg","ImageHead"},
		[7] = {"bg","ImageHead","myRankTextView"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;