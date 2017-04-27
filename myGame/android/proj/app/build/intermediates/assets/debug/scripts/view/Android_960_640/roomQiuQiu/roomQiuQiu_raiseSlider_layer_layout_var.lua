--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		trackBlueImage = 1,
		trackYellowImage = 2,
		thumbImage = 3,
		label = 4,
		allinButton = 5,
	},
	ui = {
		[1] = {"bgNode","bg","trackBg","trackBlueImage"},
		[2] = {"bgNode","bg","trackBg","trackYellowImage"},
		[3] = {"bgNode","bg","trackBg","thumbImage"},
		[4] = {"bgNode","bg","textBg","label"},
		[5] = {"bgNode","bg","allinButton"},
	},
	func = {
		[3] = "onThumbTouch_",
	},
}
return MAP;