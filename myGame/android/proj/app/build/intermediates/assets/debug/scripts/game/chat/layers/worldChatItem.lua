
local varConfigPath = VIEW_PATH .. "chat.world_chat_item_view_layout_var"
local itemView = require(VIEW_PATH .. "chat.world_chat_item_view")
local WAndFChatConfig = import('game.chat.wAndFChatConfig')

local WorldChatItem = class(GameBaseLayer,false);

function WorldChatItem:ctor(data,index)
	super(self, itemView);
    self:declareLayoutVar(varConfigPath)
    self.data = data
    self:setSize(self.m_root:getSize());
    self:init()
    self:setData()
end

function WorldChatItem:dtor()

end

function WorldChatItem:init()
	self.m_name = self:getUI("name")
	self.m_time = self:getUI("time")
	self.m_msgBg = self:getUI("msg_bg")
	self.m_msg = self:getUI("msg")
end

function WorldChatItem:setData()
	self.m_msg.m_height = 0
	self.m_msg:setText(self.data.msg)
	local w,h  = self.m_msg:getSize() 
	
	self.m_name:setText(" ")
	self.m_name:setText(self.data.title)
	self.m_time:setText(os.date("%m/%d %H:%M",self.data.time))

	local name_w, _ = self.m_name:getSize()
	local name_x, _ = self.m_name:getPos()
	local time_x, time_y = self.m_time:getPos()
	self.m_time:setPos(name_x + name_w + 50, time_y)


	if self.data.mine then
		self.m_name:setColor(WAndFChatConfig.getWChatSelfColor())
	else
		self.m_name:setColor(WAndFChatConfig.getWChatOtherColor())
	end
    
	local root_w,root_h  = self.m_root:getSize()
	local msgBg_w, msgBg_h = self.m_msgBg:getSize()
	self.m_msgBg:setSize(msgBg_w,h + 35)
	self.m_root:setSize(root_w,h + 60)
	self:setSize(self.m_root:getSize())
end

return WorldChatItem