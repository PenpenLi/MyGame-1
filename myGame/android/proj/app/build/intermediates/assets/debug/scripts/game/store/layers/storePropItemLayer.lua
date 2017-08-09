-- storePropItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a good item layer in store moudle

local StorePropItemLayer = class(GameBaseLayer, false)
local storeGoodsItemView = require(VIEW_PATH .. "store.store_goodsItem_layer")
local varConfigPath = VIEW_PATH .. "store.store_goodsItem_layer_layout_var"

-- 喇叭
-- -       self.m_data {cnname="喇叭广播" cost="800000" price="800K Koin" nav="1" pcid="1" sort="2" useType="2" sendStatus="1" pnid="1001" ctime="0" sid="0" mtime="0" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/props/prop-1001.png?1466129893" ctype="1" name="Megafon" label="0" status="1" autoUse="0" useValue="1" des="Pesan kamu bisa dibaca semua pemain" } 
--         cnname  "喇叭广播"  string
--         cost    "800000"    string
--         price   "800K Koin" string
--         nav "1" string
--         pcid    "1" string
--         sort    "2" string
--         useType "2" string
--         sendStatus  "1" string
--         pnid    "1001"  string
--         ctime   "0" string
--         sid "0" string
--         mtime   "0" string
--         image   "https://mvgliddn01-static.akamaized.net/dominogaple/androidid/props/prop-1001.png?1466129893"  string
--         ctype   "1" string
--         name    "Megafon"   string
--         label   "0" string
--         status  "1" string
--         autoUse "0" string
--         useValue    "1" string
--         des "Pesan kamu bisa dibaca semua pemain"   string


-- 礼物
-- -       self.m_data {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-1.png?1466064830" name="Ornamen" pnid="1" money="100000" expire="2" cnname="装饰品" gift_category="0" }    
--         status  "1" string
--         image   "https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-1.png?1466064830" string
--         name    "Ornamen"   string
--         pnid    "1" string
--         money   "100000"    string
--         expire  "2" string
--         cnname  "装饰品"   string
--         gift_category   "0" string

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
        UrlImage.spriteSetUrl(self.m_goosIcon, data.image,true)
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

    -- 详情展开按钮（道具）
    self.m_detailButton = self:getUI("detailButton")
    -- 详情描述（道具）
    self.m_detailLabel = self:getUI("detailLabel")
    if data.des then
        -- self.m_pointImage:setVisible(true)
        -- self.m_detailLabel:setText(data.des)
    end
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