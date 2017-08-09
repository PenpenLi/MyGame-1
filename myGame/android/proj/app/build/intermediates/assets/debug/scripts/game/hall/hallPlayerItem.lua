
local varConfigPath = VIEW_PATH .. "hall.hall_player_item_layout_var"
local itemView = require(VIEW_PATH .. "hall.hall_player_item")
local FriendDataManager = require("game.friend.friendDataManager") 

local HallPlayerItem = class(GameBaseLayer,false)

function HallPlayerItem:ctor(data,index)
	super(self, itemView);
    self:declareLayoutVar(varConfigPath)
    self.data = data
    self.index = index
    self:setSize(self.m_root:getSize());
    self:init()
    if self.data then
	    self:setData()
	    self.m_friendDataManager = FriendDataManager.getInstance()
	end
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
    EventDispatcher.getInstance():register(EventConstants.playerIconChange, self, self.onPlayerIconChange)
    EventDispatcher.getInstance():register(EventConstants.playerMoneyChange, self, self.onPlayerMoneyChange)
end

function HallPlayerItem:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
    EventDispatcher.getInstance():unregister(EventConstants.playerIconChange, self, self.onPlayerIconChange)
    EventDispatcher.getInstance():unregister(EventConstants.playerMoneyChange, self, self.onPlayerMoneyChange)
end

function HallPlayerItem:init()
	self.m_playerBg = self:getUI("player_bg")
	self.m_playerBg:setSrollOnClick()
	self.m_head = self:getUI("head")
    self.m_head = Mask.setMask(self.m_head, kImageMap.common_head_mask_min)
	self.m_name = self:getUI("name")
	self.m_money = self:getUI("money")
	self.m_operatorBtn = self:getUI("trace_btn")
	self.m_vip = self:getUI("View_vip")
	self.m_operatorBtn:setSrollOnClick()
end

function HallPlayerItem:setData()
	self.m_name:setText(nk.updateFunctions.limitNickLength(self.data.name,8))
	if self.data.mid and self.data.mid == nk.userData.uid then
		self.m_playerBg:setFile("res/hall/hall_ownItem_bg.png")
	else
		self.m_playerBg:setFile("res/hall/hall_playerItem_bg.png")
	end
	if nk.rankNodeIndex == 1 then
		self.m_money:setText(nk.updateFunctions.formatBigNumber(self.data.incMoney))

        self.m_operatorBtn:setEnable(false)
        if self.data.roomid and self.data.roomid > 0 then
            --好友在线玩牌
            self.m_operatorBtn:setFile("res/rank/rank_btn_track.png")
            if self.data.mid and self.data.mid ~= nk.userData.uid then
                self.m_operatorBtn:setEnable(true)
            end
        else
            self.m_operatorBtn:setFile("res/friend/friend_send_prop.png")
            self.m_operatorBtn:setEnable(true)
        end

        if self.index<4 then
            local rank = new(Image,kImageMap["rank_rank_"..self.index])
            rank:setAlign(kAlignCenter)
            rank:addPropScaleSolid(0, 0.4, 0.4, kCenterDrawing)
            rank:addPropRotateSolid(1, -45, kCenterDrawing)
            rank:setPos(-105,-25)
            rank:setLevel(10)
            self:addChild(rank)
        end

        if self.data.mid and self.data.mid == nk.userData.uid then
            self.m_operatorBtn:setVisible(false)
        end
	else
		self.m_money:setText(nk.updateFunctions.formatBigNumber(self.data.money))
		self.m_operatorBtn:setFile("res/friend/friend_send_money.png")
        self.m_operatorBtn:setVisible(true)
		self.m_operatorBtn:setEnable(false)
	    if self.data.send and self.data.send > 0 then
	        self.m_operatorBtn:setEnable(true)
	    end
	end 

    self:updataPlayerIcon()

    self.m_sex = self:getUI("SexIcon")
    if tonumber(self.data.msex) ==1 then
        self.m_sex:setFile(kImageMap.common_sex_man_icon)
    else
        self.m_sex:setFile(kImageMap.common_sex_woman_icon)
    end
    if self.data.vip  and tonumber(self.data.vip)>0 then 
        local vipk = new(Image,"res/common/vip_head_kuang.png")
        vipk:setAlign(kAlignCenter)
        vipk:addPropScaleSolid(0, 0.5, 0.5, kCenterDrawing);
        vipk:setPos(-80,0)
        self:addChild(vipk)
        self:DrawVip(self.m_vip, self.data.vip)
        self.m_name:setColor(0xa0,0xff,0x00)
    end
end

function HallPlayerItem:DrawVip(node,vipLevel)
    node:removeAllChildren(true)
    local vipIcon = new(Image,"res/common/vip_small/v.png")
    node:addChild(vipIcon)
    vipLevel = tonumber(vipLevel)

    if vipLevel >=10 then
        local num1 = math.modf(vipLevel/10)
        local num2 = vipLevel%10

        local vipNum1 = new(Image,"res/common/vip_small/" .. num1 .. ".png")
        vipNum1:setPos(40,4)
        node:addChild(vipNum1)
        local vipNum2 = new(Image,"res/common/vip_small/" .. num2 .. ".png")
        vipNum2:setPos(47,4)
        node:addChild(vipNum2)
    else
        local vipNum = new(Image,"res/common/vip_small/" .. vipLevel .. ".png")
        vipNum:setPos(40,4)
        node:addChild(vipNum)
    end   
end

function HallPlayerItem:onPlayerBgClick()
    if self.data.mid and self.data.mid == nk.UserDataController.getUid() then
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Hall")
    else
    	nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Friend", self.data)
        nk.DataCenterManager:report("btn_profit_playerPic")
    end	
end

function HallPlayerItem:onOperatorBtnClick()
	if nk.rankNodeIndex == 1 then
        if self.data.roomid and self.data.roomid > 0 then
		    -- 追踪
    		if self.data.roomid and self.data.roomid > 0 and self.data.mid then
                nk.AnalyticsManager:report("New_Gaple_profit_track", "profit")
                nk.DataCenterManager:report("btn_profit_track")
    			local ret = nk.SocketController:trackFriend(self.data.mid)
                if ret then
                    EnterRoomManager.getInstance():enterRoomLoading()
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL_2"))
                end
    		end
        else
            -- 赠送道具
            local userinfo = {}
            userinfo.aUser = {}
            userinfo.aUser.micon = self.data.micon
            userinfo.aUser.msex = self.data.msex
            userinfo.aUser.name = self.data.name
            userinfo.aUser.mid = self.data.mid

            local SendPropPopup = require("game.userInfo.myprop.sendPropPopup")
            nk.PopupManager:addPopup(SendPropPopup, nil, userinfo)
            nk.AnalyticsManager:report("New_Gaple_click_sendprop_personinfo")
            nk.DataCenterManager:report("btn_profit_send_prop")
        end
	else
		-- 赠送金币
	    local params = {}
	    params.mid = nk.userData.uid
	    params.fid = self.data.mid
	    nk.HttpController:execute("sendMoneyToFriend", {game_param = params})
	end
end

function HallPlayerItem:onHttpProcesser(command, errorCode, data)
    if command == "sendMoneyToFriend" then
    	self.m_friendDataManager:onSendMoneyToFriendBack(errorCode,data)
        if errorCode == HttpErrorType.SUCCESSED then
            if data and data.code == 1 and data.data and tonumber(data.data.fid or 0) == tonumber(self.data.mid) then
                nk.AnalyticsManager:report("New_Gaple_profit_sendGold", "profit")

                local retData = data.data
                if retData and retData.ret then
                    if retData.ret == 2 then
                        self.data.send = 0
                    	self.m_friendDataManager:changeFriendData(self.data)
                        self.m_operatorBtn:setEnable(false)
                    end
                end
            end
        end
    end
end

function HallPlayerItem:onPlayerIconChange(data)
    if data and self.data and tonumber(data.uid) == tonumber(self.data.mid) then
        self.data.micon = data.micon
        self:updataPlayerIcon()
    end
end

function HallPlayerItem:onPlayerMoneyChange(data)
    if nk.rankNodeIndex == 2 and data and self.data and tonumber(data.uid) == tonumber(self.data.mid) and self.data.money then
        self.data.money = data.money
        self.m_money:setText(nk.updateFunctions.formatBigNumber(self.data.money))
    end
end

function HallPlayerItem:updataPlayerIcon()
    if not string.find(self.data.micon, "http")then
        -- 默认头像 
        local index = tonumber(self.data.micon) or 1
        self.m_head:setFile(nk.s_headFile[index])
        if self.data.msex and tonumber(self.data.msex) ==1 then
            self.m_head:setFile(kImageMap.common_male_avatar)
        else
            self.m_head:setFile(kImageMap.common_female_avatar)
        end
    else
        -- 上传的头像
        UrlImage.spriteSetUrl(self.m_head, self.data.micon)
    end  
end

return HallPlayerItem

--[[
		好友数据
-		data	{mid=105116 win=57 exp=4305 send=1 micon="" mlevel=9 ptotal=4 sdchip=10000 money=8947050786 plose=3 isfb=0 name="sdfsdf" pwin=1 msex="1" roomid=-1 incMoney=-200000 rank=1 }	
		mid	105116	number
		win	57	number
		exp	4305	number
		send	1	number
		micon	""	string
		mlevel	9	number
		ptotal	4	number
		sdchip	10000	number
		money	8947050786	number
		plose	3	number
		isfb	0	number
		name	"sdfsdf"	string
		pwin	1	number
		msex	"1"	string
		roomid	-1	number
		incMoney	-200000	number
		rank	1	number
]]

--[[
		赢利榜数据
-		self.data	{mid=105232 msex="2" money=819360000 micon="" name="TTVM_TiantianVM" incMoney=200000 roomid=-1 rank=1 mlevel=9 }	
		mid	105232	number
		msex	"2"	string
		money	819360000	number
		micon	""	string
		name	"TTVM_TiantianVM"	string
		incMoney	200000	number
		roomid	-1	number
		rank	1	number
		mlevel	9	number
]]