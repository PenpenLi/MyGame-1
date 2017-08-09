
local varConfigPath = VIEW_PATH .. "giftShop.gift_item_view_layout_var"
local itemView = require(VIEW_PATH .. "giftShop.gift_item_view")

local GiftItem = class(GameBaseLayer,false);

-- hot new 标记

function GiftItem:ctor(data,popdata,itemIndex,giftShopViewIndex)
	super(self, itemView);
    self:declareLayoutVar(varConfigPath)
    self.data = data
    self.m_popdata = popdata
    self.m_itemIndex = itemIndex
    self.m_giftShopViewIndex = giftShopViewIndex
    self:setSize(self.m_root:getSize());
    self:init()
    -- self:setData()

    EventDispatcher.getInstance():register(EventConstants.giftSelected, self, self.onGiftSelected)
end

function GiftItem:dtor()
   	EventDispatcher.getInstance():unregister(EventConstants.giftSelected, self, self.onGiftSelected)
end

function GiftItem:init()
	self.m_giftBtn = self:getUI("gift_btn")
	self.m_giftView = self:getUI("gift_view")
	self.m_giftDesc = self:getUI("gift_desc")
	self.m_giftIcon = self:getUI("gift_icon") 

	self.m_giftSelected = self:getUI("gift_selected")
	self.m_giftSelected:setVisible(false)

end

function GiftItem:setData()
	local moneyStr = nk.updateFunctions.formatBigNumber(self.data.money)
	local dayStr = self.data.expire .. bm.LangUtil.getText("GIFT","DATA_LABEL")
	local desc = string.format("%s(%s)",moneyStr,dayStr)
	self.m_giftDesc:setText(desc)

	if self.m_giftShopViewIndex == 2 then
		if self.m_popdata.useId_ == nk.userData.uid then 
			self:onGiftSelected({pnid = nk.userData["gift"] or 0, viewIndex = self.m_giftShopViewIndex})
		end
	elseif self.m_giftShopViewIndex == 1 then
		if self.m_itemIndex == 1 then -- 选中第一个条目
			self:onGiftBtnClick()
		end
	end

	self.m_giftIcon:addPropScaleSolid(0, 0.8, 0.8, kCenterDrawing)

	UrlImage.spriteSetUrl(self.m_giftIcon, self.data.image,true)
end

function GiftItem:setDelegate(obj,fun)
	self.m_delegate_obj = obj
	self.m_delegate_fun = fun
end

function GiftItem:onGiftBtnClick()
	self:onGiftSelected({pnid = self.data.pnid, viewIndex = self.m_giftShopViewIndex})

	if self.m_delegate_obj and self.m_delegate_fun then
		local pnid = self.data.pnid and tonumber(self.data.pnid) or 0
		self.m_delegate_fun(self.m_delegate_obj, pnid)

		EventDispatcher.getInstance():dispatch(EventConstants.giftSelected, {pnid = tonumber(pnid), viewIndex = self.m_giftShopViewIndex})
	end
end

function GiftItem:onGiftSelected(data)
	if data.viewIndex ~= self.m_giftShopViewIndex then
		return
	end

	if tonumber(data.pnid) == tonumber(self.data.pnid) then
		-- self.m_giftBtn:setFile("res/gift/gift_icon_selected_bg.png")
		self.m_giftSelected:setVisible(true)
		EventDispatcher.getInstance():dispatch(EventConstants.onGiftChange, self.data)
	else
		-- self.m_giftBtn:setFile("res/gift/gift_bg.png")
		self.m_giftSelected:setVisible(false)
	end
end

return GiftItem

--[[
-       [1] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-1.png?1466064830" name="装饰品" pnid="1" money="100000" expire="2" cnname="装饰品" gift_category="0" }    
        status  "1" string
        image   "https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-1.png?1466064830" string
        name    "装饰品"   string
        pnid    "1" string
        money   "100000"    string
        expire  "2" string
        cnname  "装饰品"   string
        gift_category   "0" string

]]