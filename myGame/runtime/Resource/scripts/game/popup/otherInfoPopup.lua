-- OtherInfoPopup.lua
-- Last modification : 2016-06-22
-- Description: a popup to show other detail info 

local PopupModel = import('game.popup.popupModel')
local OtherInfoPopup = class(PopupModel);
local OtherInfoPopupLayer = require(VIEW_PATH .. "popup.other_info_pop_layer")
local varConfigPath = VIEW_PATH .. "popup.other_info_pop_layer_layout_var"
local FriendDataManager = require("game.friend.friendDataManager") 
local GiftShopPopup = import("game.giftShop.giftShopPopup")

-------------------------------- single function --------------------------
function OtherInfoPopup.show(data)
    PopupModel.show(OtherInfoPopup, OtherInfoPopupLayer, varConfigPath, {name="OtherInfoPopup"}, data) 
end

function OtherInfoPopup.hide()
    PopupModel.hide(OtherInfoPopup)
end

-------------------------------- base function --------------------------

function OtherInfoPopup:ctor(viewConfig, varConfigPath, data)
	Log.printInfo("OtherInfoPopup.ctor");
    self.m_data = data
    self:addShadowLayer()
    self.m_friendDataManager = FriendDataManager.getInstance()
	self:init(data)
    EventDispatcher.getInstance():register(EventConstants.addFriendData, self, self.addFriendBack)
    EventDispatcher.getInstance():register(EventConstants.deleteFriendData, self, self.deleteFriendBack)
end 

function OtherInfoPopup:dtor()
	Log.printInfo("OtherInfoPopup.dtor")
    EventDispatcher.getInstance():unregister(EventConstants.addFriendData, self, self.addFriendBack)
    EventDispatcher.getInstance():unregister(EventConstants.deleteFriendData, self, self.deleteFriendBack)
end

-------------------------------- private function --------------------------

function OtherInfoPopup:init(data)
	Log.printInfo("OtherInfoPopup.init");
    self.m_data = data
	-- data.name
	-- data.mid
	-- data.money
	-- data.exp
	-- data.mlevel
	-- data.win 历史胜率
	-- data.ptotal 排行榜中的总局数
	-- data.pwin 排行榜中的胜利局数
    -- data.plose 排行榜中的失败局数
	-- data.msex
	-- data.micon
	-- data.rank
	-- data.status
    -- data.incMoney 排行榜中的盈利金币
    -- data.isFriend
    -- data.mainType
    -- data.roomid

	-- 设置头像和性别
	self.m_headImage = self:getControl(self.s_controls["headImage"])
    self.m_headImage = Mask.setMask(self.m_headImage, kImageMap.common_head_mask_big)
	self.m_sexImage = self:getControl(self.s_controls["sexImage"])

    self.m_sexImage:setFile(nk.functions.getDefaulSexIcon(tonumber(self.m_data.msex)))

    if not string.find(self.m_data.micon, "http")then
        -- 默认头像 
        if self.m_data.msex and tonumber(self.m_data.msex) ==1 then
            self.m_headImage:setFile(kImageMap.common_male_avatar)
        else
            self.m_headImage:setFile(kImageMap.common_female_avatar)
        end
    else
        -- 上传的头像
        UrlImage.spriteSetUrl(self.m_headImage, self.m_data.micon)
    end


    -- ID
    self.m_IDLabel = self:getControl(self.s_controls["IDLabel"])
    self.m_IDLabel:setText(bm.LangUtil.getText("ROOM", "INFO_UID", self.m_data.mid))

    -- 姓名
    self.m_nameLabel = self:getControl(self.s_controls["nameLabel"])
    self.m_nameLabel:setText(nk.updateFunctions.limitNickLength(self.m_data.name, 20))

    -- 金币
    self.m_moneyLabel = self:getControl(self.s_controls["moneyLabel"])
	self.m_moneyLabel:setText(nk.updateFunctions.formatBigNumber(self.m_data.money))

    -- 等级
	self.m_levelImage = self:getControl(self.s_controls["levelImage"])
    self.m_levelLabel = self:getControl(self.s_controls["levelLabel"])
    -- 兼容不存在exp的情况
    if self.m_data.exp then
    	local level = nk.Level:getLevelByExp(self.m_data.exp)
    	if level < 0 or level > 30 then
    		level = 1
    	end
        self.m_levelLabel:setText(bm.LangUtil.getText("ROOM", "INFO_LEVEL", level))
        self.m_levelImage:setFile(kImageMap["level_" .. level])
    elseif self.m_data.mlevel then
        self.m_levelLabel:setText(bm.LangUtil.getText("ROOM", "INFO_LEVEL", self.m_data.mlevel))
        self.m_levelImage:setFile(kImageMap["level_" .. self.m_data.mlevel])
    end

    -- 总局数
    self.m_generalNumLabel = self:getControl(self.s_controls["generalNumLabel"])
    self.m_generalNumLabel:setText(bm.LangUtil.getText("USERINFO", "GENERAL_NUMBER") .. (self.m_data.totalPlay or "0"))

    -- 胜率
    self.m_winRateLabel = self:getControl(self.s_controls["winRateLabel"])
    self.m_winRateLabel:setText(bm.LangUtil.getText("USERINFO", "WIN_RATE_HISTORY") .. (self.m_data.win or "0") .. "%")

    -- 最大赢取
    self.m_maxWinLabel = self:getControl(self.s_controls["maxWinLabel"])
    self.m_maxWinLabel:setText(bm.LangUtil.getText("USERINFO", "MAX_WIN_HISTORY") .. nk.updateFunctions.formatBigNumber(self.m_data.maxwmoney or 0))

    -- 添加/删除好友btn
    self.m_addDeleteButton = self:getControl(self.s_controls["addDeleteButton"])
    self.m_addDeleteLabel = self:getControl(self.s_controls["addDeleteLabel"])
    if self.m_friendDataManager:checkHasFriend(self.m_data) then
        self.m_addDeleteButton:setFile(kImageMap.common_friend_delete)
        self.m_addDeleteLabel:setText(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
    else
        self.m_addDeleteButton:setFile(kImageMap.common_friend_add)
        self.m_addDeleteLabel:setText(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
    end

    -- 发送礼物btn
    self.m_giftButton = self:getControl(self.s_controls["giftButton"])
    self.m_giftLabel =  self:getControl(self.s_controls["giftLabel"])
    self.m_giftLabel:setText(bm.LangUtil.getText("ROOM", "GIFT_FRIEND"))

    -- 追踪btn
    self.m_trackButton =  self:getControl(self.s_controls["trackButton"])
    self.m_trackLabel =  self:getControl(self.s_controls["trackLabel"])
    self.m_trackLabel:setText(bm.LangUtil.getText("RANKING", "TRACE_PLAYER"))
    self.m_statusLabel =  self:getControl(self.s_controls["statusLabel"])
    if self.m_data.status and self.m_data.status == 2 then
        self.m_trackButton:setEnable(true)
        self.m_statusLabel:setText("")
    elseif self.m_data.roomid and self.m_data.roomid > 0 then
        self.m_trackButton:setEnable(true)
        self.m_statusLabel:setText("")
    else
        self.m_trackButton:setEnable(false)
        self.m_trackLabel:setColor(128,128,128)
        self.m_statusLabel:setText("")
    end
end 

function OtherInfoPopup:onUpdate()
    -- body
end

function OtherInfoPopup:setOtherInfo(typeStr, rankType)
    if typeStr and typeStr == "rank" then
        
    else
        
    end
end

function OtherInfoPopup:onCallBack(...)
	if self.m_callFunc then
		self.m_callFunc((...))
	end
end

function OtherInfoPopup:addFriendBack(status, data)
    if status and tonumber(data.mid) == tonumber(self.m_data.mid) then
        self.m_addDeleteButton:setEnable(true)
        self.m_data.isFriend = 1
        self.m_addDeleteButton:setFile(kImageMap.common_friend_delete)
        self.m_addDeleteLabel:setText(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
    end
end

function OtherInfoPopup:deleteFriendBack(status, mid)
    if status and tonumber(mid) == tonumber(self.m_data.mid) then
        self.m_addDeleteButton:setEnable(true)
        self.m_data.isFriend = 0
        self.m_addDeleteButton:setFile(kImageMap.common_friend_add)
        self.m_addDeleteLabel:setText(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
    end
end

-------------------------------- UI function --------------------------

function OtherInfoPopup:onAddDeleteButtonClick()
	Log.printInfo("OtherInfoPopup.onAddDeleteButtonClick")
    self.m_addDeleteButton:setEnable(false)
    if self.m_friendDataManager:checkHasFriend(self.m_data) then
        local params = {}
        params.mid = nk.userData.mid
        params.fid = self.m_data.mid
        nk.HttpController:execute("deleteFriend", {game_param = params})
    else
        nk.AnalyticsManager:report("New_Gaple_rank_add", "rank")

        local params = {}
        params.mid = nk.userData.mid
        params.fid = self.m_data.mid
        nk.HttpController:execute("addFriend", {game_param = params})
    end
end 

function OtherInfoPopup:onGiftButtonClick()
	Log.printInfo("OtherInfoPopup.onGiftButtonClick");

    nk.AnalyticsManager:report("New_Gaple_friend", "friend")

    nk.PopupManager:addPopup(GiftShopPopup,"hall",1,false,self.m_data.mid,"",0,{self.m_data.mid},0,true)
end 

function OtherInfoPopup:onTrackButtonClick()
	Log.printInfo("OtherInfoPopup.onTrackButtonClick");
    nk.SocketController:trackFriend(self.m_data.mid)
    EnterRoomManager.getInstance():enterRoomLoading()
end 

-------------------------------- table config ------------------------

-- Provide cmd handle to call
OtherInfoPopup.s_cmdHandleEx = 
{
    --["***"] = function
    ["updatePeriod"] = OtherInfoPopup.onUpdatePeriod;
};

return OtherInfoPopup