-- friendItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a people item layer in friend moudle

local FriendItemLayer = class(GameBaseLayer, false)
local itemView = require(VIEW_PATH .. "friend.friend_item_layer")
local varConfigPath = VIEW_PATH .. "friend.friend_item_layer_layout_var"
local WAndFChatPopup = require("game.chat.wAndFChatPopup")
local FriendDataManager = require("game.friend.friendDataManager") 

local function c1() return 128,128,128 end
local function c2() return 0,209,254 end
local function c3() return 180,114,255 end
local offline_status = {text = "Off-line",color = c1()}
local lobby_status = {text = "Lobby",color = c2()}
local room_status = {text = "Room",color = c3()}

-- data.msex
-- data.status
-- data.micon
-- data.name
-- data.money
-- data.s_picture
function FriendItemLayer:ctor(data)
	Log.printInfo("FriendItemLayer.ctor")
    super(self, itemView, varConfigPath)
    self:setSize(self.m_root:getSize())
    self.m_data = data
    -- 头像
    self.m_headImage = self:getControl(self.s_controls["headImage"])
    -- 用户头像剪裁
    self.m_headImage = Mask.setMask(self.m_headImage, kImageMap.common_head_mask_min)
    self:updataPlayerIcon()
    -- 头像按钮
    self.m_headButton = self:getControl(self.s_controls["headButton"])
    self.m_headButton:setSrollOnClick()
	-- 名字
	self.m_nameLabel = self:getControl(self.s_controls["nameLabel"])
	self.m_nameLabel:setText(nk.updateFunctions.limitNickLength(self.m_data.name,12))
	-- 金币
	self.m_moneyLabel = self:getControl(self.s_controls["moneyLabel"])
	self.m_moneyLabel:setText(nk.updateFunctions.formatBigNumber(self.m_data.money))
	-- 状态
	self.m_statusLabel = self:getControl(self.s_controls["statusLabel"])
	if data.status then
        if data.status == 0 then
            self.m_statusLabel:setText(offline_status.text)
            self.m_statusLabel:setColor(128,128,128)
        elseif data.status == 1 then
            self.m_statusLabel:setText(lobby_status.text)
            self.m_statusLabel:setColor(180,114,255)
        elseif data.status == 2 then
            self.m_statusLabel:setText(room_status.text)
            self.m_statusLabel:setColor(0,209,254)
        end
    end
	-- 送钱btn
	self.m_sendMoneyButton = self:getControl(self.s_controls["sendMoneyButton"])
    self.m_sendMoneyButton:setSrollOnClick()
    local sendMoneyLabel = self:getUI("sendMoneyLabel")
    sendMoneyLabel:setText(bm.LangUtil.getText("FRIEND", "SEND_CHIP"))
    -- 设置赠送按钮
    if self.m_data.send > 0 then
        self.m_sendMoneyButton:setEnable(true)
    else
        self.m_sendMoneyButton:setEnable(false)
    end

    -- 聊天btn
    self.m_chatButton = self:getControl(self.s_controls["chatButton"])
    self.m_chatButton:setSrollOnClick()
    local chatLabel = self:getUI("chatLabel")
    chatLabel:setText(bm.LangUtil.getText("FRIEND", "TALK_FRIEND"))
    self.m_newChatPoint = self:getUI("new_chat_point")
    self.m_newChatPoint:setVisible(false)

    -- 添加btn
    self.m_addButton = self:getControl(self.s_controls["addButton"])
    self.m_addButton:setSrollOnClick()
    if self.m_data.isFriend and self.m_data.isFriend ~= 1 then
        self.m_addButton:setVisible(true)
        self.m_sendMoneyButton:setVisible(false)
        self.m_chatButton:setVisible(false)
    else
        self.m_addButton:setVisible(false)
    end
    -- 添加好友label
    local addLabel = self:getUI("addLabel")
    addLabel:setText(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))

    self.m_friendDataManager = FriendDataManager.getInstance()

    self:checkNoReadMsg()
    self:addPropertyObservers_()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
    EventDispatcher.getInstance():register(EventConstants.playerIconChange, self, self.onPlayerIconChange)
    EventDispatcher.getInstance():register(EventConstants.playerMoneyChange, self, self.onPlayerMoneyChange)

    self.m_sexIcon = self:getUI("SexIcon")
    self.m_vipk = self:getUI("Vipk")
    self.m_vip = self:getUI("View_vip")
    if tonumber(self.m_data.msex) ==1 then
        self.m_sexIcon:setFile(kImageMap.common_sex_man_icon)
    else
        self.m_sexIcon:setFile(kImageMap.common_sex_woman_icon)
    end
    if self.m_data.vip  and tonumber(self.m_data.vip)>0 then 
        self.m_vipk:setFile("res/common/vip_head_kuang.png")
        self.m_vipk:setSize(67,67)
        self:DrawVip(self.m_vip, self.m_data.vip)
        self.m_nameLabel:setColor(0xa0,0xff,0x00)
    end
end 

function FriendItemLayer:DrawVip(node,vipLevel)
    node:removeAllChildren(true)
    local vipIcon = new(Image,"res/common/vip_small/v.png")
    vipIcon:setPos(10,0)
    node:addChild(vipIcon)
    vipLevel = tonumber(vipLevel)

    if vipLevel >=10 then
        local num1 = math.modf(vipLevel/10)
        local num2 = vipLevel%10

        local vipNum1 = new(Image,"res/common/vip_small/" .. num1 .. ".png")
        vipNum1:setPos(50,4)
        node:addChild(vipNum1)
        local vipNum2 = new(Image,"res/common/vip_small/" .. num2 .. ".png")
        vipNum2:setPos(57,4)
        node:addChild(vipNum2)
    else
        local vipNum = new(Image,"res/common/vip_small/" .. vipLevel .. ".png")
        vipNum:setPos(50,4)
        node:addChild(vipNum)
    end   
end

function FriendItemLayer:onHeadButtonClick()
	Log.printInfo("FriendItemLayer.onHeadButtonClick")
    -- nk.PopupManager:addPopup(OtherInfoPopup,"Friend",self.m_data)
    nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Friend", self.m_data)
end

function FriendItemLayer:onSendMoneyButtonClick()
	Log.printInfo("FriendItemLayer.onSendMoneyButtonClick")
    local params = {}
    params.mid = nk.userData.mid
    params.fid = self.m_data.mid
    nk.HttpController:execute("sendMoneyToFriend", {game_param = params})
end

function FriendItemLayer:onHttpProcesser(command, errorCode, data)
    if  command == "sendMoneyToFriend" then
        self.m_friendDataManager:onSendMoneyToFriendBack(errorCode,data)
        if errorCode == HttpErrorType.SUCCESSED then
            if data and data.code == 1 and data.data and tonumber(data.data.fid or 0) == tonumber(self.m_data.mid) then
                local retData = data.data
                if retData and retData.ret then
                    if retData.ret == 2 then
                        self.m_data.send = 0
                        self.m_friendDataManager:changeFriendData(self.m_data)
                        self.m_sendMoneyButton:setEnable(false)
                    end
                end
            end
        end
    end
end

function FriendItemLayer:onPlayerIconChange(data)
    if data and self.m_data and tonumber(data.uid) == tonumber(self.m_data.mid) then
        self.m_data.micon = data.micon
        self:updataPlayerIcon()
    end
end

function FriendItemLayer:onPlayerMoneyChange(data)
    if data and self.m_data and tonumber(data.uid) == tonumber(self.m_data.mid) and self.m_data.money then
        self.m_data.money = data.money
        self.m_moneyLabel:setText(nk.updateFunctions.formatBigNumber(self.m_data.money))
    end
end

function FriendItemLayer:updataPlayerIcon()
    if not string.find(self.m_data.micon, "http")then
        -- 默认头像 
        local index = tonumber(self.m_data.micon) or 1
        self.m_headImage:setFile(nk.s_headFile[index])
        if self.m_data.msex and tonumber(self.m_data.msex) ==1 then
            self.m_headImage:setFile(kImageMap.common_male_avatar)
        else
            self.m_headImage:setFile(kImageMap.common_female_avatar)
        end
    else
        -- 上传的头像
        UrlImage.spriteSetUrl(self.m_headImage, self.m_data.micon)
    end 
end

function FriendItemLayer:onChatButtonClick()
	Log.printInfo("FriendItemLayer.onChatButtonClick")

    nk.AnalyticsManager:report("New_Gaple_friend_chat", "friend")

    nk.PopupManager:addPopup(WAndFChatPopup,"friend",nil,self.m_data.mid)
end

function FriendItemLayer:onAddButtonClick()
    Log.printInfo("FriendItemLayer.onAddButtonClick")
    local params = {}
    params.mid = nk.userData.mid
    params.fid = self.m_data.mid
    nk.HttpController:execute("addFriend", {game_param = params})
end


function FriendItemLayer:checkNoReadMsg()
    local flag = false
    for i=1,#nk.userData.chatRecord do
        local chatRecord = nk.userData.chatRecord[i]
        if tonumber(self.m_data.mid) == tonumber(chatRecord.send_uid)  and tonumber(chatRecord.recv_uid) == tonumber(nk.userData.mid) then
            flag = true
            break
        end
    end
    self.m_newChatPoint:setVisible(flag)
end

function FriendItemLayer:addPropertyObservers_()
    self.chatRecordHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", handler(self, function (obj, chatRecord)
        if not nk.updateFunctions.checkIsNull(obj) then
            obj:checkNoReadMsg()
        end
    end))
end

function FriendItemLayer:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", self.chatRecordHandle_)
end

function FriendItemLayer:dtor()
	Log.printInfo("FriendItemLayer.dtor");
    self:removePropertyObservers()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
    EventDispatcher.getInstance():unregister(EventConstants.playerIconChange, self, self.onPlayerIconChange)
    EventDispatcher.getInstance():unregister(EventConstants.playerMoneyChange, self, self.onPlayerMoneyChange)
end

return FriendItemLayer