--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		text_info = 2,
		EditText_id = 3,
		btn_get_reward = 4,
		btn_get_reward_text = 5,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","text_info"},
		[3] = {"Image_bg","EditText_id"},
		[4] = {"Image_bg","btn_get_reward"},
		[5] = {"Image_bg","btn_get_reward","btn_get_reward_text"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "onBtnGetRewardClick",
	},
}
return MAP;