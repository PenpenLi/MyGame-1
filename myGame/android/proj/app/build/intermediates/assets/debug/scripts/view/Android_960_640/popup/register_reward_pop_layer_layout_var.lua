--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		Text_info = 2,
		CloseBtn = 3,
		itembg_vip = 4,
		light = 5,
		star = 6,
		Image_shader = 7,
		Button_vip = 8,
		Text_vip = 9,
		itembg3 = 10,
		itembg2 = 11,
		itembg1 = 12,
		playButton = 13,
		playLabel = 14,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","Text_info"},
		[3] = {"bg","CloseBtn"},
		[4] = {"bg","itembg_vip"},
		[5] = {"bg","itembg_vip","light"},
		[6] = {"bg","itembg_vip","star"},
		[7] = {"bg","itembg_vip","Image_shader"},
		[8] = {"bg","itembg_vip","Button_vip"},
		[9] = {"bg","itembg_vip","Button_vip","Text_vip"},
		[10] = {"bg","itembg3"},
		[11] = {"bg","itembg2"},
		[12] = {"bg","itembg1"},
		[13] = {"bg","playButton"},
		[14] = {"bg","playButton","playLabel"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[3] = "onCloseBtnClick",
		[8] = "onVipClick",
		[13] = "onPlayButtonClick",
	},
}
return MAP;