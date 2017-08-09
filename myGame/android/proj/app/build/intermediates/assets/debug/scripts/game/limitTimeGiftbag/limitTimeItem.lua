--
-- Author: melon
-- Date: 2016-10-18 14:45:46
--
local LimitTimeItem = class(Node)

function LimitTimeItem:ctor(data,index)
    self.data = data
    self.index = index
    local itemClass = require(VIEW_PATH .. "limitTimeGiftbag/payItem")
    self.m_root = SceneLoader.load(itemClass)
    self:setSize(self.m_root:getSize());
    self:addChild(self.m_root)
    self.payBg = self.m_root:getChildByName("PayBg")
    self.payIcon = self.m_root:getChildByName("PayIcon")
    self.payIcon:setFile("res/payType/first_recharge_"..data.pmode.."_icon.png")
    self.payBg:setFile(kImageMap.common_transparent)
end

function LimitTimeItem:dtor()

end

function LimitTimeItem:updataBg(index)
    local file = kImageMap.common_transparent
    if tonumber(self.index) == tonumber(index) then
        file = "res/common/pay_select.png"
    end
    self.payBg:setFile(file)
end

return LimitTimeItem