--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		View_bg = 2,
		ScrollView_goods = 3,
		Button_left = 4,
		Button_right = 5,
		Image_vip_gray = 6,
		Image_vip_light = 7,
		Image_vip_num_1 = 8,
		Image_vip_num_2 = 9,
		Image_progress_bg = 10,
		Image_progress = 11,
		Text_vip_next = 12,
		Text_vip_process = 13,
		Text_privilege = 14,
		Button_question = 15,
		Button_recharge = 16,
		Text_recharge = 17,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","View_bg"},
		[3] = {"Image_bg","View_bg","ScrollView_goods"},
		[4] = {"Image_bg","View_bg","Button_left"},
		[5] = {"Image_bg","View_bg","Button_right"},
		[6] = {"Image_bg","View_bg","Image_vip_gray"},
		[7] = {"Image_bg","View_bg","Image_vip_light"},
		[8] = {"Image_bg","View_bg","Image_vip_num_1"},
		[9] = {"Image_bg","View_bg","Image_vip_num_2"},
		[10] = {"Image_bg","View_bg","Image_progress_bg"},
		[11] = {"Image_bg","View_bg","Image_progress"},
		[12] = {"Image_bg","View_bg","Text_vip_next"},
		[13] = {"Image_bg","View_bg","Text_vip_process"},
		[14] = {"Image_bg","View_bg","Text_privilege"},
		[15] = {"Image_bg","View_bg","Button_question"},
		[16] = {"Image_bg","View_bg","Button_recharge"},
		[17] = {"Image_bg","View_bg","Button_recharge","Text_recharge"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[4] = "onLeftBtClick",
		[5] = "onRightBtClick",
		[15] = "onQuestionClick",
		[17] = "rechargeBtnClick",
	},
}
return MAP;