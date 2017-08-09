-- storePropItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a good item layer in store moudle

local StorePropItemLayer = class(GameBaseLayer, false)
local storeGoodsItemView = require(VIEW_PATH .. "store.store_pop_goodsItem_layer")
local varConfigPath = VIEW_PATH .. "store.store_pop_goodsItem_layer_layout_var"

-- 喇叭
-- data.des
-- data.name
-- data.price
-- data.pnid
-- data.label

-- 礼物
-- data.name
-- data.image
-- data.money
-- data.expire
function StorePropItemLayer:ctor(data)
	Log.printInfo("StorePropItemLayer.ctor");
    super(self, storeGoodsItemView, varConfigPath);

    self.propType = 0

    -- 背景
    self.m_bg = self:getUI("bg")
    local w,h = self.m_bg:getSize();
    self:setSize(w,h)

    self.m_data = data

	-- 箭头(展开/缩回)
	self.m_pointImage = self:getUI("pointImage")
	-- hot 标签
	self.m_hotImage = self:getUI("hotImage")
    if tonumber(data.label) == 1 then
        self.m_hotImage:setVisible(true)
    end
	-- 商品图标
	self.m_goosIcon = self:getUI("goosIcon")
    if data.image then
        UrlImage.spriteSetUrl(self.m_goosIcon, data.image)
    end
	-- 金币数量
	self.m_goodsMoneyLabel = self:getUI("goodsMoneyLabel")
    self.m_goodsMoneyLabel:setText(data.name)
    -- 天数
    self.m_changeMoneyLabel = self:getUI("changeMoneyLabel")
    if data.expire then
        self.m_changeMoneyLabel:setText(data.expire ..bm.LangUtil.getText("GIFT","DATA_LABEL"))
    else
        self.m_changeMoneyLabel:setVisible(false)
    end
    -- 支付金额
    self.m_payMoneyLabel = self:getUI("payMoneyLabel")
    if data.buyButtonLabel then
        self.m_payMoneyLabel:setText(data.buyButtonLabel)
    else
        if data.money then
            self.propType = 2
            self.m_payMoneyLabel:setText(nk.updateFunctions.formatBigNumber(data.money))
        end
        if data.price then
            self.propType = 1
            self.m_payMoneyLabel:setText(data.price)
        end
    end
    -- 金币icon
    self.m_goldImage = self:getUI("goldImage")
    self.m_goldImage:setVisible(true)
    -- 购买按钮
    self.m_buyButton = self:getUI("buyButton")
    self.m_buyButton:setSrollOnClick()
end

function StorePropItemLayer:onBuyButtonClick()
    if self.propType == 1 then
        -- 喇叭
        EventDispatcher.getInstance():dispatch(EventConstants.storeBuyEvent, "BUY_PROP", self.m_data.pnid, self.m_data.num or 1, self.m_data.cost)
    elseif self.propType == 2 then
        -- 礼物
        EventDispatcher.getInstance():dispatch(EventConstants.storeBuyEvent, "BUY_GIFT", self.m_data.pnid, self.m_data.num or 1, self.m_data.money)
    end
end

function StorePropItemLayer:onDetailButtonClick()
    -- if self.m_isOpen then
    --     self.m_isOpen = false
    --     self.m_bg:setFile(kImageMap.store_item_bg)
    --     self:setSize(nil, 102)
    -- else
    --     self.m_isOpen = true
    --     self.m_bg:setFile(kImageMap.store_item_bg_2)
    --     self:setSize(nil, 193)
    -- end
end

function StorePropItemLayer:dtor()
	Log.printInfo("StorePropItemLayer.dtor");
end

return StorePropItemLayer