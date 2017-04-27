--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		popup_bg = 1,
		topBtn_bg = 2,
		shopGift = 3,
		shopGift_btn_bg = 4,
		shopGift_text = 5,
		myGift = 6,
		myGift_btn_bg = 7,
		myGift_text = 8,
		shop_gift_view = 9,
		my_gift_view = 10,
		Image_user_icon = 11,
		text_gift_desc = 12,
		Image_gift_icon = 13,
	},
	ui = {
		[1] = {"popup_bg"},
		[2] = {"popup_bg","topBtn_bg"},
		[3] = {"popup_bg","topBtn_bg","shopGift"},
		[4] = {"popup_bg","topBtn_bg","shopGift","shopGift_btn_bg"},
		[5] = {"popup_bg","topBtn_bg","shopGift","shopGift_text"},
		[6] = {"popup_bg","topBtn_bg","myGift"},
		[7] = {"popup_bg","topBtn_bg","myGift","myGift_btn_bg"},
		[8] = {"popup_bg","topBtn_bg","myGift","myGift_text"},
		[9] = {"popup_bg","shop_gift_view"},
		[10] = {"popup_bg","my_gift_view"},
		[11] = {"popup_bg","Image12","Image_user_icon"},
		[12] = {"popup_bg","Image12","text_gift_desc"},
		[13] = {"popup_bg","Image_gift_icon"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[3] = "onShopGiftBtnClick",
		[6] = "onMyGiftBtnClick",
	},
}
return MAP;