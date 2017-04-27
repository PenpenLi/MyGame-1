-- storeGoodsItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a good item layer in store moudle

local StoreGoodsItemLayer = class(GameBaseLayer, false)
local storeGoodsItemView = require(VIEW_PATH .. "store.store_pop_goodsItem_layer")
local varConfigPath = VIEW_PATH .. "store.store_pop_goodsItem_layer_layout_var"

-- data.title
-- data.rate
-- data.priceDollar
-- data.buyButtonLabel
-- data.priceLabel
-- data.pid
-- data.img
function StoreGoodsItemLayer:ctor(data)
	Log.printInfo("StoreGoodsItemLayer.ctor");
    super(self, storeGoodsItemView, varConfigPath);

    -- 背景
    self.m_bg = self:getUI("bg")
    local w,h = self.m_bg:getSize();
    self:setSize(w,h)

    self.m_data = data

	-- 箭头(展开/缩回)
	self.m_pointImage = self:getUI("pointImage")
	-- hot 标签
	self.m_hotImage = self:getUI("hotImage")
	-- 商品图标
	self.m_goosIcon = self:getUI("goosIcon")
    if data.img then
        self.m_goosIcon:setFile(kImageMap["common_coin_" .. data.img])
    end
	-- 金币数量
	self.m_goodsMoneyLabel = self:getUI("goodsMoneyLabel")
    self.m_goodsMoneyLabel:setText(data.title)
    -- 汇率
    self.m_changeMoneyLabel = self:getUI("changeMoneyLabel")
    if data.rate and data.rate > 1000 then
        local rate = tonumber(string.format("%d", data.rate))
        self.m_changeMoneyLabel:setText(bm.LangUtil.getText("STORE", "RATE_CHIP", nk.updateFunctions.formatNumberWithSplit(rate), data.priceDollar))
    else
        self.m_changeMoneyLabel:setText(bm.LangUtil.getText("STORE", "RATE_CHIP", string.format("%.2f", data.rate or 0), data.priceDollar))
    end
    -- 支付金额
    self.m_payMoneyLabel = self:getUI("payMoneyLabel")
    if data.buyButtonLabel then
        self.m_payMoneyLabel:setText(data.buyButtonLabel)
    else
        self.m_payMoneyLabel:setText(data.priceLabel)
    end
    -- 金币icon
    self.m_goldImage = self:getUI("goldImage")
    self.m_goldImage:setVisible(false)
    -- 购买按钮
    self.m_buyButton = self:getUI("buyButton")
    self.m_buyButton:setSrollOnClick()
end

function StoreGoodsItemLayer:onBuyButtonClick()
    EventDispatcher.getInstance():dispatch(EventConstants.storeBuyEvent, "BUY_GOODS", self.m_data.pid, self.m_data)
end

function StoreGoodsItemLayer:dtor()
	Log.printInfo("StoreGoodsItemLayer.dtor");
end

return StoreGoodsItemLayer