
local ChatMsgShortcutListItem = class(Node)

function ChatMsgShortcutListItem:ctor(msg)
	local item_h = 65
	self.m_msg = msg
	self:setSize(400,item_h)

	self.m_msgBtn = new(Button,"res/common/common_blank.png")
	self.m_msgBtn:setSize(400,item_h)
	self:addChild(self.m_msgBtn)
	self.m_msgBtn:setSrollOnClick()
	self.m_msgBtn:setOnClick(self, self.onChatShortcutClicked)

	self.m_msgBg = new(Image,"res/roomChat/roomChat_chat_bg.png",nil,nil,25,25,40,40)
	self.m_msgBg:setSize(400,85)
	self.m_msgBg:setAlign(kAlignCenter)
	self.m_msgBtn:addChild(self.m_msgBg)

	self.m_msgText = new(Text,msg,365,55,kAlignLeft,nil,24,250,230,255) 
	self.m_msgText:setAlign(kAlignLeft)
	self.m_msgText:setPos(15,0)
	self:addChild(self.m_msgText)
end

function ChatMsgShortcutListItem:setDelege(obj,fun)
	self.m_delegeObj = obj
	self.m_delegeFun = fun
end

function ChatMsgShortcutListItem:onChatShortcutClicked()
	if self.m_delegeObj and self.m_delegeFun then
		self.m_delegeFun(self.m_delegeObj,self.m_msg)
	end
end

function ChatMsgShortcutListItem:dtor()
	
end

return ChatMsgShortcutListItem