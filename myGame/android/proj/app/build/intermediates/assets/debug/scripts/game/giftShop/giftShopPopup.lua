-- 礼物购买弹框

local PopupModel = import('game.popup.popupModel')

local GiftShopPopupLayer = require(VIEW_PATH .. "giftShop.gift_shop_pop_layer")
local varConfigPath = VIEW_PATH .. "giftShop.gift_shop_pop_layer_layout_var"

local ShopGiftLayer = require("game.giftShop.layers.shopGiftLayer")

local MyGiftLayer = require("game.giftShop.layers.myGiftLayer")

local giftShopController = require("game.giftShop.giftShopController")


local GiftShopPopup = class(PopupModel)

GiftShopPopup.DEF_VIEW_TYPE = 1

function GiftShopPopup.show(...)
	PopupModel.show(GiftShopPopup, GiftShopPopupLayer, varConfigPath, {name="GiftShopPopup"}, ...)
end

function GiftShopPopup.hide()
    PopupModel.hide(GiftShopPopup)
end


-- isRoom,   是否在房间内
-- uid,  点击的玩家Id
-- allTableId, 赠送的玩家uid 表
-- tableNum,  玩家个数
-- toUidArr, 赠送的玩家uid 表
-- level,  房间等级
-- notRoom, 房间外赠送好友礼物

function GiftShopPopup:ctor(viewConfig, varConfigPath, viewIndex, isRoom, uid, allTableId, tableNum, toUidArr, level, notRoom)
	self.isRoom = isRoom
    self.useId_ = uid
    self.useIdArray_ = allTableId
    self.tableNum_ = tableNum
    self.toUidArr_ = toUidArr
    self.level_ = level
    self.notRoom = notRoom --房间外赠送好友礼物 true

    self.popData = {
    	["isRoom"] = self.isRoom,
    	["useId_"] = self.useId_,
    	["useIdArray_"] = self.useIdArray_,
    	["tableNum_"] = self.tableNum_,
    	["toUidArr_"] = self.toUidArr_,
    	["level_"] = self.level_,
    	["notRoom"] = self.notRoom,
    }

	self:initScene()
	self:addShadowLayer()

	self.m_goToIndex = viewIndex or 1

	self.m_giftShopController = new(giftShopController)

	self:goToViewIndex()

	EventDispatcher.getInstance():register(EventConstants.getMemberInfoCallback, self, self.onPersonalInfoCallback)

	nk.UserDataController.getMemberInfo({uid = self.useId_})

	EventDispatcher.getInstance():register(EventConstants.onGiftChange, self, self.onGiftChange)
end

function GiftShopPopup:onGiftChange(data)
	UrlImage.spriteSetUrl(self.Image_gift_icon, data.image)
	-- 这里添加 礼物描述代码
	if data.desc then
		self.text_gift_desc:setText(data.desc)
	else
		self.text_gift_desc:setText("")
	end
end

function GiftShopPopup:onPersonalInfoCallback(data)
	local mid = data.aUser.mid or 0
	if tonumber(mid) ~= tonumber(self.useId_) then return end -- may be other response

	local name = nk.updateFunctions.limitNickLength(data.aUser.name, 15) or ""
	local mlevel = data.aUser.mlevel or 1
	local money = data.aUser.money or 0
	local charm = data.aUser.charm or 0
	local micon = data.aUser.micon or "1" 
	local msex = tonumber(data.aUser.msex) or 0
	local vipLv = tonumber(data.aUser.vip) or 0

	self.LoadIconToNode(self.user_icon, micon, msex)
end

function GiftShopPopup:initScene()
	self.m_popupBg = self:getUI("popup_bg")
	self:addCloseBtn(self.m_popupBg)

	self.m_shopBtn = self:getUI("shopGift")
	self.m_shopBtn_bg = self:getUI("shopGift_btn_bg")
	self.m_shop_text = self:getUI("shopGift_text")

	self.m_myBtn = self:getUI("myGift")
	self.m_myBtn_bg = self:getUI("myGift_btn_bg")
	self.m_my_text = self:getUI("myGift_text")

	self.m_shop_text:setText(bm.LangUtil.getText("GIFT", "MAIN_TAB_TEXT")[1])
	self.m_my_text:setText(bm.LangUtil.getText("GIFT", "MAIN_TAB_TEXT")[2])

	self.m_shopGiftView = self:getUI("shop_gift_view")
	self.m_myGiftView = self:getUI("my_gift_view")

	self.user_icon = Mask.setMask(self:getUI("Image_user_icon"), kImageMap.common_head_mask_big, {scale = 1, align = 0, x = 0, y = 0})

	self.Image_gift_icon = self:getUI("Image_gift_icon")
	self.text_gift_desc = self:getUI("text_gift_desc")
	self.text_gift_desc:setText("")

	if not self.isRoom then -- 不是房间内，右侧礼物描述更高些
		local x, y = self.text_gift_desc:getSize()
		self.text_gift_desc:setSize(x, y + 50)
	end
end

function GiftShopPopup.LoadIconToNode(nodeImage, micon, msex)
	if string.find(micon, "http") then
        nodeImage:setFile(kImageMap.userInfo_nophoto)
    	UrlImage.spriteSetUrl(nodeImage, micon)-- 上传的头像
    else
    	if tonumber(msex) == 1 then
	    	nodeImage:setFile("res/photoManager/avatar_big_male.png")
	    else
	    	nodeImage:setFile("res/photoManager/avatar_big_female.png")
	    end
    end 
end

function GiftShopPopup:goToViewIndex()
	if self.m_goToIndex == 1 then
		self:onShopGiftBtnClick()
	elseif self.m_goToIndex == 2 then
		self:onMyGiftBtnClick()
	end
end

function GiftShopPopup:updataBtnStatus()
	self.m_shopBtn_bg:setVisible(false)
	self.m_myBtn_bg:setVisible(false)
	self.m_shop_text:setColor(199,127,241)
	self.m_my_text:setColor(199,127,241)
	if self.m_curViewType == 1 then
		self.m_shopBtn_bg:setVisible(true)
		self.m_shop_text:setColor(255,255,255)
	else
		self.m_myBtn_bg:setVisible(true)
		self.m_my_text:setColor(255,255,255)
	end
end

function GiftShopPopup:onShopGiftBtnClick()
	if self.m_curViewType ~= 1 then
		self.m_curViewType = 1
		self.m_giftShopController:setMainViewIndex(self.m_curViewType)
		if not self.m_shopGiftLayer then
			self.m_shopGiftLayer = new(ShopGiftLayer,self.m_giftShopController,self.popData)
			self.m_shopGiftView:addChild(self.m_shopGiftLayer)
		end
	end
	self.m_shopGiftView:setVisible(true)
	if self.m_shopGiftLayer.m_selectGiftId_ and self.m_shopGiftLayer.m_selectGiftId_ ~= 0 then
    	EventDispatcher.getInstance():dispatch(EventConstants.giftSelected, {pnid = self.m_shopGiftLayer.m_selectGiftId_, viewIndex = 1})
    end

	self.m_myGiftView:setVisible(false)
	self:updataBtnStatus()
end

function GiftShopPopup:onMyGiftBtnClick()
	if self.m_curViewType ~= 2 then
		self.m_curViewType = 2
		self.m_giftShopController:setMainViewIndex(self.m_curViewType)
		if not self.m_myGiftLayer then
			self.m_myGiftLayer = new(MyGiftLayer,self.m_giftShopController,self.popData)
			self.m_myGiftView:addChild(self.m_myGiftLayer)

			self.m_myGiftLayer.m_selectGiftId_ = nk.userData["gift"] or 0
		end
	end
	self.m_myGiftView:setVisible(true)
	if self.m_myGiftLayer.m_selectGiftId_ and self.m_myGiftLayer.m_selectGiftId_ ~= 0 then
    	EventDispatcher.getInstance():dispatch(EventConstants.giftSelected, {pnid = self.m_myGiftLayer.m_selectGiftId_, viewIndex = 2})
    end

	self.m_shopGiftView:setVisible(false)
	self:updataBtnStatus()
end

function GiftShopPopup:onCloseGiftPopup()
	GiftShopPopup.hide()
end

function GiftShopPopup:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.getMemberInfoCallback, self, self.onPersonalInfoCallback)
	EventDispatcher.getInstance():unregister(EventConstants.onGiftChange, self, self.onGiftChange)
end

GiftShopPopup.s_eventHandle = 
{
    [EventConstants.closeGiftPopup] = GiftShopPopup.onCloseGiftPopup,
};

return GiftShopPopup