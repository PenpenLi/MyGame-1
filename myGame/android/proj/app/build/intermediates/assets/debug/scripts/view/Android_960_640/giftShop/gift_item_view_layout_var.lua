--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		gift_btn = 1,
		gift_view = 2,
		gift_icon = 3,
		gift_desc = 4,
		gift_selected = 5,
	},
	ui = {
		[1] = {"gift_btn"},
		[2] = {"gift_btn","gift_view"},
		[3] = {"gift_btn","gift_icon"},
		[4] = {"gift_btn","gift_desc"},
		[5] = {"gift_btn","gift_selected"},
	},
	func = {
		[1] = "onGiftBtnClick",
	},
}
return MAP;