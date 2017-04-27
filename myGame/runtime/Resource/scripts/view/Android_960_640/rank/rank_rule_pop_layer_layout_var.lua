--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		radioButtonGroup = 2,
		awardRadiobutton = 3,
		titleAwardLabel = 4,
		ruleRadiobutton = 5,
		titleRuleLabel = 6,
		closeButton = 7,
		comtentBg = 8,
		contentRankLabel = 9,
		contentAwardLabel = 10,
		awardListView = 11,
		ruleScrollView = 12,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","tabBg","radioButtonGroup"},
		[3] = {"bg","tabBg","radioButtonGroup","awardRadiobutton"},
		[4] = {"bg","tabBg","radioButtonGroup","awardRadiobutton","titleAwardLabel"},
		[5] = {"bg","tabBg","radioButtonGroup","ruleRadiobutton"},
		[6] = {"bg","tabBg","radioButtonGroup","ruleRadiobutton","titleRuleLabel"},
		[7] = {"bg","closeButton"},
		[8] = {"comtentBg"},
		[9] = {"comtentBg","contentRankLabel"},
		[10] = {"comtentBg","contentAwardLabel"},
		[11] = {"comtentBg","awardListView"},
		[12] = {"comtentBg","ruleScrollView"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[7] = "onCloseButtonClick",
	},
}
return MAP;