--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		chat_msg_view = 1,
		send_view = 2,
		horn_input = 3,
		hron_num_bg = 4,
		hron_num = 5,
		horn_send_btn = 6,
	},
	ui = {
		[1] = {"chat_msg_view"},
		[2] = {"send_view"},
		[3] = {"send_view","horn_input_bg","horn_input"},
		[4] = {"send_view","hron_num_bg"},
		[5] = {"send_view","hron_num_bg","hron_num"},
		[6] = {"send_view","horn_send_btn"},
	},
	func = {
		[6] = "onHornSendBtnClick",
	},
}
return MAP;