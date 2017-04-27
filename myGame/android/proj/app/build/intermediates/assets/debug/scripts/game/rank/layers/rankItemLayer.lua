-- rankItemLayer.lua
-- Last modification : 2016-06-13
-- Description: a people item layer in rank moudle

local RankItemLayer = class(GameBaseLayer, false)
local itemView = require(VIEW_PATH .. "rank.rank_item_layer")
local varConfigPath = VIEW_PATH .. "rank.rank_item_layer_layout_var"
local RankConfig = require("game.rank.rankConfig")

local function c1() return 128,128,128 end
local function c2() return 0,209,254 end
local function c3() return 180,114,255 end
local offline_status = {text = "Off-line", color = c1()}
local lobby_status = {text = "Lobby", color = c2()}
local room_status = {text = "Room", color = c3()}

-- data.status
-- data.micon
-- data.msex
-- data.name
-- data.money
-- data.rank
-- *data.roomid
-- *data.plose
-- *data.pwin
-- *data.ptotal
function RankItemLayer:ctor(data)
	Log.printInfo("RankItemLayer.ctor")
    super(self, itemView, varConfigPath)
    self:setSize(self.m_root:getSize())
    self.m_data = data
    -- 背景
    self.m_bg = self:getUI("bg")
    -- 头像btn
    self.m_headButton = self:getUI("headButton")
    self.m_headButton:setSrollOnClick()
    -- 头像
    self.m_headImage = self:getUI("headImage")
    -- 用户头像剪裁
    self.m_headImage = Mask.setMask(self.m_headImage, kImageMap.common_head_mask_min)
	-- 名字
	self.m_nameLabel = self:getUI("nameLabel")
	-- 金币icon
	self.m_goldImage = self:getUI("goldImage")
	-- 金币
	self.m_moneyLabel = self:getUI("moneyLabel")
	-- 状态
	self.m_statusLabel = self:getUI("statusLabel")
    -- 追踪btn
    self.m_trackButton = self:getUI("trackButton")
    self.m_trackButton:setSrollOnClick()
    self.m_trackText = self:getUI("Text_track")
    self.m_trackText:setText(bm.LangUtil.getText("RANKING", "TRACE_PLAYER"))
    -- 前三名图片
    self.m_rankFirstImage = self:getUI("rankFirstImage")
    -- 其余名次背景
    self.m_rankNormalImage = self:getUI("rankNormalImage")
    -- 其余名次label
    self.m_rankNormalLabel = self:getUI("rankNormalLabel")
    -- 未入榜label
    self.m_noRankLabel = self:getUI("noRankLabel")
    self.m_noRankLabel:setText(bm.LangUtil.getText("RANKING", "NO_RANK"))
    -- 立即玩牌btn
    self.m_playButton = self:getUI("playButton")
    self.m_playLabel = self:getUI("playLabel")
    self.m_playLabel:setText(bm.LangUtil.getText("RANKING", "IM_PLAY"))
    -- 详情btn
    self.m_detailButton = self:getUI("detailButton")
    self.m_detailLabel = self:getUI("detailLabel")
    self.m_vipk = self:getUI("Vipk")
    self.m_vipIcon = self:getUI("View_vip")
    self.m_sexIcon = self:getUI("SexIcon")
    self.m_detailLabel:setText(bm.LangUtil.getText("RANKING", "DETAIL"))
    self:updateData()
end 

function RankItemLayer:dtor()
	Log.printInfo("RankItemLayer.dtor");
end

function RankItemLayer:updateData(data, isSelf)
    self.m_data = data or self.m_data

    if isSelf then
        self.m_bg:setFile(kImageMap.rank_self_rank_bg)
        self.m_statusLabel:setVisible(false)
        self.m_trackButton:setVisible(false)
        self.m_playButton:setVisible(true)
    else
        if self.m_data.mid == nk.userData.mid then
            self.m_statusLabel:setVisible(false)
            self.m_trackButton:setVisible(false)
            self.m_playButton:setVisible(true)
        else
            self.m_statusLabel:setVisible(true)
            self.m_trackButton:setVisible(true)
            self.m_playButton:setVisible(false)
        end
    end
    local rank = self.m_data.rank or -1
    if rank < 4 and rank > 0 then
        self.m_rankFirstImage:setVisible(true)
        self.m_rankNormalImage:setVisible(false)
        self.m_noRankLabel:setVisible(false)
        self.m_detailButton:setVisible(false)
        self.m_rankFirstImage:setFile(kImageMap["rank_rank_" .. rank])
    elseif rank == -1 then
        self.m_noRankLabel:setVisible(true)
        self.m_detailButton:setVisible(true)
        self.m_rankFirstImage:setVisible(false)
        self.m_rankNormalImage:setVisible(false)
    else
        self.m_rankNormalImage:setVisible(true)
        self.m_rankFirstImage:setVisible(false)
        self.m_noRankLabel:setVisible(false)
        self.m_detailButton:setVisible(false)
        self.m_rankNormalLabel:setText(rank)
    end
    
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
    
    self.m_nameLabel:setText(nk.updateFunctions.limitNickLength(self.m_data.name,8))

    -- 在线状态
    if self.m_data.status then
        if self.m_data.status == 0 then
            self.m_statusLabel:setText(offline_status.text)
            self.m_statusLabel:setColor(128,128,128)
            self.m_trackButton:setEnable(false)
            self.m_trackText:setColor(128,128,128)
        elseif self.m_data.status == 1 then
            self.m_statusLabel:setText(lobby_status.text)
            self.m_statusLabel:setColor(180,114,255)            
            self.m_trackButton:setEnable(false)
            self.m_trackText:setColor(128,128,128)
        elseif self.m_data.status == 2 then
            self.m_statusLabel:setText(room_status.text)
            self.m_statusLabel:setColor(0,209,254)
            self.m_trackButton:setEnable(true)
        end
    else
        -- 总排行榜，没有status的情况
        if self.m_data.roomid then
            if self.m_data.roomid > 0 then
                self.m_statusLabel:setText(room_status.text)
                self.m_statusLabel:setColor(0,209,254)
                self.m_trackButton:setEnable(true)
            elseif self.m_data.roomid == 0 then
                self.m_statusLabel:setText(lobby_status.text)
                self.m_statusLabel:setColor(180,114,255)
                self.m_trackButton:setEnable(false)
                self.m_trackText:setColor(128,128,128)
            else
                self.m_statusLabel:setText(offline_status.text)
                self.m_statusLabel:setColor(128,128,128)
                self.m_trackButton:setEnable(false)
                self.m_trackText:setColor(128,128,128)
            end
        end
    end
    if tonumber(self.m_data.msex) ==1 then
        self.m_sexIcon:setFile(kImageMap.common_sex_man_icon)
    else
        self.m_sexIcon:setFile(kImageMap.common_sex_woman_icon)
    end
    if self.m_data.vip  and tonumber(self.m_data.vip)>0 then 
        self.m_vipk:setFile("res/common/vip_head_kuang.png")
        self.m_vipk:setSize(67,67)
        self:DrawVip(self.m_vipIcon, self.m_data.vip)
        self.m_nameLabel:setColor(0xa0,0xff,0x00)
    end
    self:updateRankTypeText()
end

function RankItemLayer:DrawVip(node,vipLevel)
    node:removeAllChildren(true)
    local vipIcon = new(Image,"res/common/vip_small/v.png")
    node:addChild(vipIcon)
    vipIcon:setPos(10,0)
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

-- 不同榜单不同描述
function RankItemLayer:updateRankTypeText()
    if self.m_data.mainType == RankConfig.mainType[1] then
        self.m_goldImage:setVisible(false)
        self.m_moneyLabel:setText(bm.LangUtil.getText("RANKING", "RECORDS", self.m_data.ptotal or 0, self.m_data.pwin or 0, self.m_data.plose or 0))
        self.m_moneyLabel:setPos(236)
    elseif self.m_data.mainType == RankConfig.mainType[2] then
        self.m_detailButton:setVisible(false)
        self.m_goldImage:setVisible(true)
        self.m_moneyLabel:setText(nk.updateFunctions.formatNumberWithSplit(self.m_data.incMoney or 0))
        self.m_moneyLabel:setPos(271)
    elseif self.m_data.mainType == RankConfig.mainType[3] then
        self.m_goldImage:setVisible(true)
        self.m_detailButton:setVisible(false)
        self.m_moneyLabel:setText(nk.updateFunctions.formatNumberWithSplit(self.m_data.money or 0))
        self.m_moneyLabel:setPos(271)
    end
end

function RankItemLayer:onHeadButtonClick()
    Log.printInfo("RankItemLayer.onHeadButtonClick")
    if tonumber(self.m_data.mid) ~= (nk.userData.mid) and self.m_data.mid then
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Rank", self.m_data)
    end
end

function RankItemLayer:onTrackButtonClick()
    Log.printInfo("RankItemLayer.onTrackButtonClick")
    nk.AnalyticsManager:report("New_Gaple_rank_track", "rank")


    if self.m_data.mid == nk.userData.mid then
        self:quickEnterRoom()
    else
        nk.SocketController:trackFriend(self.m_data.mid)
    end
end

function RankItemLayer:onPlayButtonClick()
    Log.printInfo("RankItemLayer.onPlayButtonClick")
    self:quickEnterRoom()
end

function RankItemLayer:quickEnterRoom()
    if GameConfig.ROOT_CGI_SID == "2" then
        nk.SocketController:quickPlayQiuQiu()
    else
        nk.SocketController:quickPlayGaple()
    end
end

function RankItemLayer:onDetailButtonClick()
    Log.printInfo("RankItemLayer.onDetailButtonClick")
    local RankDetailPopLayer = require("game.rank.layers.rankDetailPopLayer")
    nk.PopupManager:addPopup(RankDetailPopLayer,"rank",self.m_data.pDiff)
end

return RankItemLayer