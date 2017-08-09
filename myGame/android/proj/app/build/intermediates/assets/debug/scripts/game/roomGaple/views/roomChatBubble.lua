--
-- Author: tony
-- Date: 2014-08-23 19:53:49
--

local RoomChatBubble = class(Node)

RoomChatBubble.DIRECTION_LEFT = 1
RoomChatBubble.DIRECTION_RIGHT = 2

RoomChatBubble.TEXT_MAX_WIDTH = 200

RoomChatBubble.BG_MIN_HEIGHT = 44
RoomChatBubble.BG_MIN_WIDTH = 34

function RoomChatBubble:ctor(label, direction)
    self.m_chatBg = new(Image,"res/room/gaple/roomG_chat_bg.png",nil,nil,15,15,15,15)
    self.m_chatArrow = new(Image,"res/room/gaple/roomG_chat_arrow.png")

    local tempText = new(Text,label, 0, 0, kAlignLeft, nil, 22, 255, 255, 255)
    local tempText_w, _ = tempText:getSize()
    delete(tempText)

    local chatMsg_w, chatMsg_h = 0, 0 
    local chatBg_w, chatBg_h = 0, 0

    if tempText_w >= RoomChatBubble.TEXT_MAX_WIDTH then
        self.m_chatMsg = new(TextView,label,RoomChatBubble.TEXT_MAX_WIDTH,0,kAlignLeft,nil,22,255,255,255)
        self.m_chatMsg:setAlign(kAlignLeft)
        chatMsg_w, chatMsg_h = self.m_chatMsg:getSize()
        chatBg_w, chatBg_h = RoomChatBubble.TEXT_MAX_WIDTH + 30, chatMsg_h < 30 and RoomChatBubble.BG_MIN_HEIGHT or chatMsg_h + 20
    else
        self.m_chatMsg = new(Text,label, 0, 0, kAlignLeft, nil, 22, 255, 255, 255)
        self.m_chatMsg:setAlign(kAlignLeft)
        chatMsg_w, chatMsg_h = self.m_chatMsg:getSize()
        chatBg_w, chatBg_h = chatMsg_w + 30, RoomChatBubble.BG_MIN_HEIGHT
    end

    self.m_chatMsg:setPos(15,0)
    self.m_chatBg:addChild(self.m_chatMsg)

    self.m_chatBg:setSize(chatBg_w, chatBg_h)

    self.m_offsetX = 0
    self.m_offsety = 0

    if direction == RoomChatBubble.DIRECTION_LEFT then
        self.m_offsetX = 100
        self.m_offsety = -5
        if nk.roomSceneType == "qiuqiu" then
            self.m_offsetX = 115
            self.m_offsety = 65
        end
        self.m_chatBg:setAlign(kAlignBottomLeft)
        self.m_chatArrow:setAlign(kAlignBottomLeft)
    else
        self.m_offsetX = 60
        self.m_offsety = -5
        if nk.roomSceneType == "qiuqiu" then
            self.m_offsetX = 75
            self.m_offsety = 65
        end
        self.m_chatBg:setAlign(kAlignBottomRight)
        self.m_chatArrow:setAlign(kAlignBottomRight)
    end

    self.m_chatBg:setPos(0,0)
    self.m_chatArrow:setPos(15,-14)
    self:addChild(self.m_chatBg)
    self:addChild(self.m_chatArrow)
end

function RoomChatBubble:show(parent, x, y, chatNode)
    if self:getParent() then
        self:removeFromParent()
    end

    -- JasonLi 会引起奇怪的现象，暂不清楚什么用处
   -- if parent.roomChatBubble and parent.roomChatBubble[x] then
   --     parent:removeChild(parent.roomChatBubble[x],true)
   --     parent.roomChatBubble[x] = nil
   -- end
   -- if not parent.roomChatBubble then
   --     parent.roomChatBubble = {}
   -- end

   -- parent.roomChatBubble[x] = self

   x, y = chatNode:getAbsolutePos()

   -- self:setPos(x + self.m_offsetX, y + self.m_offsety)
   self:setPos(x, y)
   parent:addChild(self)
end

return RoomChatBubble