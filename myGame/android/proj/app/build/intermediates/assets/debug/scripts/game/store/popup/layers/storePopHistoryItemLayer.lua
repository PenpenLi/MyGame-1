-- storeHistoryItemLayer.lua
-- Create Date : 2016-07-04
-- Last modification : 2016-07-04
-- Description: a pay type item layer in store moudle

local StoreHistoryItemLayer = class(Node)
local StoreConfig = require("game.store.storeConfig")

StoreHistoryItemLayer.checkChanged = EventDispatcher.getInstance():getUserEvent();

-- data.count
-- data.detail
-- data.status
-- data.created
function StoreHistoryItemLayer:ctor(data)
	Log.printInfo("StoreHistoryItemLayer.ctor");

    self:setSize(440, 60)

    -- 商品名称
    local s = bm.LangUtil.getText("STORE", "BUY_CHIPS", nk.updateFunctions.formatBigNumber(checkint(data.count))) or ""
    local nameLabel = new(Text, s, 100, 40, kAlignCenter, nil, 16, 255, 255, 255)
    nameLabel:setAlign(kAlignLeft)
    nameLabel:setPos(15, 10)
    self:addChild(nameLabel)

     -- 购买时间
    local s = os.date("%Y-%m-%d", checkint(data.created)) or ""
    local timeLabel = new(Text, s, 100, 40, kAlignCenter, nil, 16, 255, 255, 255)
    timeLabel:setAlign(kAlignLeft)
    timeLabel:setPos(180, 10)
    self:addChild(timeLabel)

     -- 订单状态
    local s = bm.LangUtil.getText("STORE", "RECORD_STATUS")[checkint(data.status)] or ""
    local statusLabel = new(Text, s, 100, 40, kAlignCenter, nil, 16, 255, 255, 255)
    statusLabel:setAlign(kAlignLeft)
    statusLabel:setPos(290, 10)
    self:addChild(statusLabel)

    -- 分割线
    local icon = new(Image, kImageMap.store_history_line_2)
    icon:setAlign(kAlignBottom)
    icon:setSize(410, 2)
    icon:setPos(-2)
    self:addChild(icon)
end 

function StoreHistoryItemLayer:dtor()
	Log.printInfo("StoreHistoryItemLayer.dtor");
end

return StoreHistoryItemLayer