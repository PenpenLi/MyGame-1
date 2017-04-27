--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		radioButtonGroup = 2,
		inviteRadiobutton = 3,
		inviteFriendLabel = 4,
		myAwardRadiobutton = 5,
		myAwardLabel = 6,
		inviteRed = 7,
		ruleRadiobutton = 8,
		ruleLabel = 9,
		inviteView = 10,
		myAwardView = 11,
		ruleView = 12,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","View5","Image3","radioButtonGroup"},
		[3] = {"Image_bg","View5","Image3","radioButtonGroup","inviteRadiobutton"},
		[4] = {"Image_bg","View5","Image3","radioButtonGroup","inviteRadiobutton","inviteFriendLabel"},
		[5] = {"Image_bg","View5","Image3","radioButtonGroup","myAwardRadiobutton"},
		[6] = {"Image_bg","View5","Image3","radioButtonGroup","myAwardRadiobutton","myAwardLabel"},
		[7] = {"Image_bg","View5","Image3","radioButtonGroup","myAwardRadiobutton","inviteRed"},
		[8] = {"Image_bg","View5","Image3","radioButtonGroup","ruleRadiobutton"},
		[9] = {"Image_bg","View5","Image3","radioButtonGroup","ruleRadiobutton","ruleLabel"},
		[10] = {"Image_bg","inviteView"},
		[11] = {"Image_bg","myAwardView"},
		[12] = {"Image_bg","ruleView"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[3] = "onInviteRadioChange",
		[5] = "onMyAwardRadioChange",
		[8] = "onRuleRadioChange",
	},
}
return MAP;