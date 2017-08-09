-- storePropTypeItemLayer.lua
-- Create Date : 2016-07-04
-- Last modification : 2016-07-04
-- Description: a pay type item layer in store moudle

local StorePropTypeItemLayer = class(Node)
local StoreConfig = require("game.store.storeConfig")

StorePropTypeItemLayer.checkChanged = EventDispatcher.getInstance():getUserEvent();

-- @param number data.id
-- @param handler data.callback
function StorePropTypeItemLayer:ctor(data, index)
	Log.printInfo("StorePropTypeItemLayer.ctor");
	self.m_bg = new(Images,{kImageMap.store_payType_unchoose, kImageMap.store_payType_choosed});
--    if index == 1 then
--        self.m_bg:setImageIndex(1)
--    end
    self.m_bg:setAlign(kAlignCenter)
	local w,h = self.m_bg:getSize();
    self:setSize(w,h+10)
    self:addChild(self.m_bg)

    local button = new(Button,kImageMap.common_transparent)
    button:setFillParent(true, true)
    button:setAlign(kAlignCenter)
    button:setOnClick(self,self.onBtnClick)
    self:addChild(button)

    -- 246,215,250
    -- 道具文案
    local s = data.name or ""
    self.m_label = new(Text, s, 100, 40, kAlignCenter, nil, 18, 255, 255, 255)
    self.m_label:setAlign(kAlignCenter)
    self:addChild(self.m_label)

    -- 道具类型ID
    self.m_propId = data.id

    self.m_callback = data.callback

    EventDispatcher.getInstance():register(StorePropTypeItemLayer.checkChanged, self, self.onListenChange)
end 

function StorePropTypeItemLayer:setSelect(isSelect)
    if isSelect then
        self.m_bg:setImageIndex(1)
    end
end

function StorePropTypeItemLayer:onBtnClick()
    self:setCheck(true)
    EventDispatcher.getInstance():dispatch(StorePropTypeItemLayer.checkChanged, self.m_propId)
end

function StorePropTypeItemLayer:setCheck(status)
    if status then
        self.m_bg:setImageIndex(1)
        self.m_label:setColor(246,215,250)
        if self.m_callback then
            self.m_callback(self.m_propId)
        end
    else
        self.m_bg:setImageIndex(0)
        self.m_label:setColor(255, 255, 255)
    end
end

function StorePropTypeItemLayer:onListenChange(payId)
    if payId == self.m_propId then
        return
    end
    self:setCheck(false)
end

function StorePropTypeItemLayer:dtor()
	Log.printInfo("StorePropTypeItemLayer.dtor");
    EventDispatcher.getInstance():unregister(StorePropTypeItemLayer.checkChanged, self, self.onListenChange)
end

return StorePropTypeItemLayer