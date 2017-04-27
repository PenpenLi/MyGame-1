-- storePayTypeItemLayer.lua
-- Create Date : 2016-07-04
-- Last modification : 2016-07-04
-- Description: a pay type item layer in store moudle

local StorePayTypeItemLayer = class(Node)
local StoreConfig = require("game.store.storeConfig")

StorePayTypeItemLayer.checkChanged = EventDispatcher.getInstance():getUserEvent();

-- @param number data.id
-- @param handler data.callback
function StorePayTypeItemLayer:ctor(data, index)
	Log.printInfo("StorePayTypeItemLayer.ctor");
	self.m_bg = new(Images,{kImageMap.store_payType_unchoose, kImageMap.store_payType_choosed});
    if index == 1 then
        self.m_bg:setImageIndex(1)
    end
    self.m_bg:setAlign(kAlignCenter)
	local w,h = self.m_bg:getSize();
    self:setSize(w,h+10)
    self:addChild(self.m_bg)

    local button = new(Button,kImageMap.common_transparent)
    button:setFillParent(true, true)
    button:setAlign(kAlignCenter)
    button:setOnClick(self,self.onBtnClick)
    self:addChild(button)

    -- 支付图标
    local icon = new(Image, kImageMap[StoreConfig.payTypeIcon[data.id]])
    icon:setAlign(kAlignCenter)
    icon:setPos(-60)
    self:addChild(icon)

    -- 246,215,250
    -- 支付文案
    local s = StoreConfig.payTypeName[data.id] or ""
    self.m_label = new(Text, s, 100, 40, kAlignCenter, nil, 18, 255, 255, 255)
    self.m_label:setPos(80, 0)
    self.m_label:setAlign(kAlignLeft)
    self:addChild(self.m_label)

    if s == "" then
        icon:setPos(0)
    end

    -- 支付ID
    self.m_payId = data.id

    self.m_callback = data.callback

    EventDispatcher.getInstance():register(StorePayTypeItemLayer.checkChanged, self, self.onListenChange)
end 

function StorePayTypeItemLayer:onBtnClick()
    self:setCheck(true)
    EventDispatcher.getInstance():dispatch(StorePayTypeItemLayer.checkChanged, self.m_payId)
end

function StorePayTypeItemLayer:setCheck(status)
    if status then
        self.m_bg:setImageIndex(1)
        self.m_label:setColor(246,215,250)
        if self.m_callback then
            self.m_callback(self.m_payId)
        end
    else
        self.m_bg:setImageIndex(0)
        self.m_label:setColor(255, 255, 255)
    end
end

function StorePayTypeItemLayer:onListenChange(payId)
    if payId == self.m_payId then
        return
    end
    self:setCheck(false)
end

function StorePayTypeItemLayer:dtor()
	Log.printInfo("StorePayTypeItemLayer.dtor");
    EventDispatcher.getInstance():unregister(StorePayTypeItemLayer.checkChanged, self, self.onListenChange)
end

return StorePayTypeItemLayer