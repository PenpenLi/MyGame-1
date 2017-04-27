--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		Text_signature_key = 1,
		Text_news_key = 2,
		Text_news_date = 3,
		Button_publish = 4,
		Button_thump_up = 5,
		Text_thumpUp_num = 6,
		Button_delete = 7,
		Button_see_all = 8,
		Image_edit_sign = 9,
		Text_news_content = 10,
		Edit_signature = 11,
	},
	ui = {
		[1] = {"Text_signature_key"},
		[2] = {"Text_news_key"},
		[3] = {"Text7"},
		[4] = {"Button10"},
		[5] = {"Button11"},
		[6] = {"Text12"},
		[7] = {"Button13"},
		[8] = {"Button15"},
		[9] = {"Image17"},
		[10] = {"TextView17"},
		[11] = {"EditTextView17"},
	},
	func = {
		[4] = "onBtnPublishClick",
		[5] = "onButtonThumpUpClick",
		[7] = "onBtnDeleteClick",
		[8] = "onBtnSeeAllClick",
	},
}
return MAP;