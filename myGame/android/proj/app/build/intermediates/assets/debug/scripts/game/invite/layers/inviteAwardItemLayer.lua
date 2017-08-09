-- inviteAwardItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a item layer in invite moudle

local InviteAwardItemLayer = class(Node)

InviteAwardItemLayer.getAward = EventDispatcher.getInstance():getUserEvent();

function InviteAwardItemLayer:ctor()
	Log.printInfo("InviteAwardItemLayer.ctor");
    self:setSize(635, 55)
    -- 详情
    self.m_detailLabel = new(TextView, "", 450, 55, kAlignLeft, nil, 20, 255, 255, 255)
    self.m_detailLabel:setAlign(kAlignLeft)
    self.m_detailLabel:setPos(15, 0)
    self:addChild(self.m_detailLabel)
	
	-- 时间
    self.m_timeLabel = new(Text, "", 80, 40, kAlignCenter, nil, 18, 237, 216, 252)
    self.m_timeLabel:setAlign(kAlignLeft)
    self.m_timeLabel:setPos(470, 0)
    self:addChild(self.m_timeLabel)

    -- 领取按钮
    self.m_getButton = new(Button, kImageMap.common_btn_yellow_m)
    self.m_getButton:setAlign(kAlignLeft)
    self.m_getButton:setPos(550, 0)
    self.m_getButton:setSize(100, 60)
    self:addChild(self.m_getButton)
    
    local s = bm.LangUtil.getText("DAILY_TASK", "GET_REWARD") or ""
    local buttonLabel = new(Text, s, 100, 40, kAlignCenter, nil, 18, 255, 255, 255)
    buttonLabel:setAlign(kAlignCenter)
    self.m_getButton:addChild(buttonLabel)
    self.m_getButton:setOnClick(self, self.onGetButtonClick)

    -- 状态
    local s = bm.LangUtil.getText("DAILY_TASK", "HAD_FINISH") or ""
    self.m_gettedLabel = new(Text, s, 100, 40, kAlignCenter, nil, 20, 194, 122, 244)
    self.m_gettedLabel:setAlign(kAlignLeft)
    self.m_gettedLabel:setPos(550, 0)
    self:addChild(self.m_gettedLabel)

    local line = new(Image, kImageMap.store_history_line_2)
    line:setAlign(kAlignBottom)
    line:setSize(640, 2)
    self:addChild(line)
end 

function InviteAwardItemLayer:onGetButtonClick()
	Log.printInfo("InviteAwardItemLayer.onGetButtonClick")
    if self.m_data then
	   EventDispatcher.getInstance():dispatch(InviteAwardItemLayer.getAward, tonumber(self.m_data.id))
    end
end

function InviteAwardItemLayer:dtor()
	Log.printInfo("InviteAwardItemLayer.dtor");
end

return InviteAwardItemLayer