--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		popup_bg = 1,
		closeButton = 2,
		world_btn = 3,
		world_btn_bg = 4,
		world_text = 5,
		friend_btn = 6,
		friend_btn_bg = 7,
		friend_text = 8,
		red_point = 9,
		world_view = 10,
		friend_view = 11,
	},
	ui = {
		[1] = {"popup_bg"},
		[2] = {"popup_bg","closeButton"},
		[3] = {"popup_bg","btn_bg","world_btn"},
		[4] = {"popup_bg","btn_bg","world_btn","world_btn_bg"},
		[5] = {"popup_bg","btn_bg","world_btn","world_text"},
		[6] = {"popup_bg","btn_bg","friend_btn"},
		[7] = {"popup_bg","btn_bg","friend_btn","friend_btn_bg"},
		[8] = {"popup_bg","btn_bg","friend_btn","friend_text"},
		[9] = {"popup_bg","btn_bg","red_point"},
		[10] = {"popup_bg","world_view"},
		[11] = {"popup_bg","friend_view"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[2] = "onCloseBtnClick",
		[3] = "onWorldBtnClick",
		[6] = "onFriendBtnClick",
	},
}
return MAP;