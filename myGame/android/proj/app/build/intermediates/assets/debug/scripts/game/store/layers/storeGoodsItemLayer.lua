-- storeGoodsItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a good item layer in store moudle

local StoreGoodsItemLayer = class(GameBaseLayer, false)
local storeGoodsItemView = require(VIEW_PATH .. "store.store_goodsItem_layer")
local varConfigPath = VIEW_PATH .. "store.store_goodsItem_layer_layout_var"

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

	-- hot 标签
	self.m_hotImage = self:getUI("hotImage")
    if data.hot then
        self.m_hotImage:setVisible(true)
    end
	-- 商品图标
	self.m_goosIcon = self:getUI("goosIcon")
    if data.img then
        self.m_goosIcon:setFile(kImageMap["common_coin_" .. data.img])
    end
	-- 折扣后的金币
	self.m_gold_add = self:getUI("goodsMoneyLabel")
    self.m_gold_add:setText(data.getname)
    -- vip
    self.m_vip = self:getUI("changeMoneyLabel")
    self.m_vip:setVisible(false)
    --折扣前的金币
    self.m_gold = self:getUI("Text_gold")
    --折扣率
    self.m_rate_add = self:getUI("Text_rate_add")

    local vipLevel = nk.userData.vip or 0

    if data.discount then
        --有折扣
        self.m_gold:setVisible(true)
        self.m_gold:setText(data.getname)
        self.m_gold_add:setText(data.fgetname)

        local size_w,size_h = self.m_gold:getSize()
        local xian = new(Image,kImageMap["store_line"],nil,nil,1,1,0,2)
        xian:setAlign(kAlignCenter)
        xian:setSize(size_w,4)
        self.m_gold:addChild(xian) 

        self.m_rate_add:setVisible(true)
        self.m_rate_add:setText("+" .. data.discount .. "% FREE")

        self.m_gold_add:setPos(nil,52)

        if tonumber(vipLevel) > 0 then
            local name,payment = nk.vipController:getAddition(vipLevel)
            if tonumber(payment) > 0 then
                self.m_vip:setVisible(true)
                self.m_vip:setPos(nil,67)
                self.m_vip:setText(string.upper(name))
                local text = new(Text,"+" .. payment .. "%",nil,nil,kAlignLeft,nil,20,10,255,0)
                text:setPos((self.m_vip:getSize()))
                self.m_vip:addChild(text)
            end           
        end
    else
        if tonumber(vipLevel) > 0 then          
            local name,payment = nk.vipController:getAddition(vipLevel)
            if tonumber(payment) > 0  then
                self.m_vip:setVisible(true)
                self.m_vip:setText(string.upper(name))
                local text = new(Text,"+" .. payment .. "%",nil,nil,kAlignLeft,nil,20,10,255,0)
                text:setPos((self.m_vip:getSize()))
                self.m_vip:addChild(text)
            end        
        end
    end

    -- 支付金额
    self.m_payMoneyLabel = self:getUI("payMoneyLabel")
    if data.priceLabel then
        self.m_payMoneyLabel:setText(data.priceLabel)
    end
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