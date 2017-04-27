
local varConfigPath = VIEW_PATH .. "chat.friend_chat_f_item_view_layout_var"
local itemView = require(VIEW_PATH .. "chat.friend_chat_f_item_view")
local WAndFChatConfig = import('game.chat.wAndFChatConfig')

local FriendsItem = class(GameBaseLayer,false);

function FriendsItem:ctor(data)
	super(self, itemView);
    self:declareLayoutVar(varConfigPath)
    self.data = data
    self:setSize(self.m_root:getSize());
    self:init()
    self:setData()
    self:checkNoReadMsg()
    self:addPropertyObservers_()
    EventDispatcher.getInstance():register(EventConstants.talkingWithWho, self, self.updataBg)
end

function FriendsItem:dtor()
	self:removePropertyObservers()
	EventDispatcher.getInstance():unregister(EventConstants.talkingWithWho, self, self.updataBg)
end

function FriendsItem:init()
	self.m_bg = self:getUI("friend_bg")
	self.m_head = self:getUI("feirnd_head")
    self.m_head = Mask.setMask(self.m_head, kImageMap.common_head_mask_min)
	self.m_name = self:getUI("friend_name")
	self.m_online_status = self:getUI("online_status")
	self.m_new_msg = self:getUI("new_msg")
	self.m_sex_icon = self:getUI("sex_icon")
end

function FriendsItem:setData()
	self.m_sex_icon:setFile(nk.functions.getDefaulSexIcon(tonumber(self.data.msex)))

	self.m_name:setText(nk.updateFunctions.limitNickLength(self.data.name,8))
	if self.data.msex and tonumber(self.data.msex) ==1 then
        self.m_head:setFile(kImageMap.common_male_avatar)
    else
        self.m_head:setFile(kImageMap.common_female_avatar)
    end

    if string.find(self.data.micon, "http")then
        UrlImage.spriteSetUrl(self.m_head, self.data.micon)
    end
	self.m_new_msg:setVisible(false)
	self.m_online_status:setText("Off-Line")

	local file = "res/chat/chat_player_offline_bg.png"
	if self.data.roomid >= 0 then
		file = "res/chat/chat_player_online_bg.png"
		self.m_online_status:setText("On-Line")
		if self.data.roomid > 0 then
			self.m_online_status:setText("Room")
		end
	end

	if self.data.isSelected then
		file = "res/chat/chat_player_chat_bg.png"
	end
	self.m_bg:setFile(file)
end

function FriendsItem:updataBg(mid)
	local file = "res/chat/chat_player_offline_bg.png"
	if self.data.roomid >= 0 then
		file = "res/chat/chat_player_online_bg.png"
		self.m_online_status:setText("On-Line")
		if self.data.roomid > 0 then
			self.m_online_status:setText("Room")
		end
	end

	if tonumber(self.data.mid) == tonumber(mid) then
		file = "res/chat/chat_player_chat_bg.png"
	end
	self.m_bg:setFile(file)
end

function FriendsItem:checkNoReadMsg()
	local flag = false
	if nk.userData.chatRecord then
	    for i=1,#nk.userData.chatRecord do
	        local chatRecord = nk.userData.chatRecord[i]
	        if tonumber(self.data.mid) == tonumber(chatRecord.send_uid)  and tonumber(chatRecord.recv_uid) == tonumber(nk.userData.mid) then
	            flag = true
	            break
	        end
	    end
	else
		nk.userData.chatRecord = nk.userData.chatRecord or {}
	end
    self.m_new_msg:setVisible(flag)
end


function FriendsItem:addPropertyObservers_()
    self.chatRecordHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", handler(self, function (obj, chatRecord)
        if not nk.updateFunctions.checkIsNull(obj) then
            obj:checkNoReadMsg()
        end
    end))
end

function FriendsItem:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", self.chatRecordHandle_)
end

return FriendsItem

--[[
-		data	{mid=105105 win=57 exp=1235 send=1 micon="" mlevel=7 ptotal=0 sdchip=10000 money=13300000 plose=0 isfb=0 name="nubia_NX507J" pwin=0 msex="2" roomid=-1 incMoney=0 rank=-1 }	
		mid	105105	number
		win	57	number
		exp	1235	number
		send	1	number
		micon	""	string
		mlevel	7	number
		ptotal	0	number
		sdchip	10000	number
		money	13300000	number
		plose	0	number
		isfb	0	number
		name	"nubia_NX507J"	string
		pwin	0	number
		msex	"2"	string
		roomid	-1	number
		incMoney	0	number
		rank	-1	number



        mid	"105089"	string
		win	0	number
		exp	"0"	string
		send	1	number
		isSelected	true	boolean
		micon	"https://graph.facebook.com/523225837833558/picture?type=normal"	string
		mlevel	1	number
		ptotal	0	number
		sdchip	10000	number
		money	2510000	number
		plose	0	number
		maxwmoney	0	number
		isfb	0	number
		totalPlay	0	number
		name	"Kume Chang"	string
		pwin	0	number
		msex	"1"	string
		roomid	-1	number
		incMoney	0	number
		rank	-1	number

]]