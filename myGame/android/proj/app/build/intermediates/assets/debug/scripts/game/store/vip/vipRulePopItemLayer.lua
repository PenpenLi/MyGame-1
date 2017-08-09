-- VipRulePopItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a people item layer in rank moudle

local VipRulePopItemLayer = class(Node)

-- data.vip
-- data.vip describe
function VipRulePopItemLayer:ctor(data)
	Log.printInfo("VipRulePopItemLayer.ctor");
    self:setSize(670, 52)
    -- 背景
    self.m_bg = new(Image, kImageMap.rank_pop_item_bg)
    self.m_bg:setFillParent(true, true)
    local remain = math.mod(data.index_, 2)
    if remain == 0 then
        self.m_bg:setVisible(false)
    end
    self:addChild(self.m_bg)
    -- 名次范围标签
    self.m_rank = new(Text, data.vip, 50, 52, kAlignCenter, nil, 22, 221, 208, 248)
    self.m_rank:setPos(72)
    self:addChild(self.m_rank)

    -- 奖励标签
    self.m_reward =  new(Text, data.describe, 384, 52, kAlignCenter, nil, 22, 221, 208, 248)
    self.m_reward:setPos(265)
    self:addChild(self.m_reward)
end 

function VipRulePopItemLayer:dtor()
	Log.printInfo("VipRulePopItemLayer.dtor");
end

return VipRulePopItemLayer