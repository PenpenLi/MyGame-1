--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Image_bg = 1,
		Image_bt_bg = 2,
		RadioButtonGroup = 3,
		RadioButton_1 = 4,
		Text_l = 5,
		Image_sysMsg_point = 6,
		RadioButton_2 = 7,
		Text_m = 8,
		Image_sysNotice_point = 9,
		RadioButton_3 = 10,
		Text_r = 11,
		Image_friend_point = 12,
		Image_delete = 13,
		Button_delete = 14,
		Text_delete = 15,
		Button_sure = 16,
		Text_sure = 17,
		Button_cancel = 18,
		Text_cancel = 19,
		Text_tip = 20,
		Text_none = 21,
	},
	ui = {
		[1] = {"Image_bg"},
		[2] = {"Image_bg","Image_bt_bg"},
		[3] = {"Image_bg","Image_bt_bg","RadioButtonGroup"},
		[4] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_1"},
		[5] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_1","Text_l"},
		[6] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_1","Text_l","Image_sysMsg_point"},
		[7] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_2"},
		[8] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_2","Text_m"},
		[9] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_2","Text_m","Image_sysNotice_point"},
		[10] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_3"},
		[11] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_3","Text_r"},
		[12] = {"Image_bg","Image_bt_bg","RadioButtonGroup","RadioButton_3","Text_r","Image_friend_point"},
		[13] = {"Image_bg","Image_delete"},
		[14] = {"Image_bg","Image_delete","Button_delete"},
		[15] = {"Image_bg","Image_delete","Button_delete","Text_delete"},
		[16] = {"Image_bg","Image_delete","Button_sure"},
		[17] = {"Image_bg","Image_delete","Button_sure","Text_sure"},
		[18] = {"Image_bg","Image_delete","Button_cancel"},
		[19] = {"Image_bg","Image_delete","Button_cancel","Text_cancel"},
		[20] = {"Image_bg","Image_delete","Text_tip"},
		[21] = {"Image_bg","Text_none"},
	},
	func = {
		[1] = "onPopupBgTouch",
	},
}
return MAP;