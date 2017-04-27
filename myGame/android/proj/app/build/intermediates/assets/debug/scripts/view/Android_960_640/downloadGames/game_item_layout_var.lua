--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		img_icon = 1,
		text_desc = 2,
		btn_exchange = 3,
		btn_exchange_text = 4,
		btn_download = 5,
		btn_download_text = 6,
	},
	ui = {
		[1] = {"Image_item2","img_icon"},
		[2] = {"Image_item2","text_desc"},
		[3] = {"Image_item2","btn_exchange"},
		[4] = {"Image_item2","btn_exchange","btn_exchange_text"},
		[5] = {"Image_item2","btn_download"},
		[6] = {"Image_item2","btn_download","btn_download_text"},
	},
	func = {
		[3] = "onBtnExchangeClick",
		[5] = "onBtnDownloadClick",
	},
}
return MAP;