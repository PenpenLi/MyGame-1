-- friendScene.lua
-- Last modification : 2016-06-03
-- Description: a scene in Friend moudle

local FriendScene = class(GameBaseScene);
local FriendConfig = require("game.friend.friendConfig")
local FriendItemLayer = require("game.friend.layers.friendItemLayer")
local FriendRecommendItemLayer = require("game.friend.layers.friendRecommendItemLayer")
local LoadingAnim = require("game.anim.loadingAnim")

function FriendScene:ctor(viewConfig,controller)
	Log.printInfo("FriendScene.ctor");
    -- 初始化数据
    self:initScene()
end 

function FriendScene:resume()
    Log.printInfo("FriendScene.resume");
    nk.PopupManager:removeAllPopup()
    GameBaseScene.resume(self);
end

function FriendScene:pause()
    Log.printInfo("FriendScene.pause");
	nk.PopupManager:removeAllPopup()
	GameBaseScene.pause(self);
end 

function FriendScene:dtor()
    Log.printInfo("FriendScene.dtor");
end
-------------------------------- private function --------------------------

function FriendScene:initScene(viewType)
	-- 设置TAB标题背景光
	self.m_titleLightImage_1 = self:getControl(self.s_controls["titleLightImage_1"])
	self.m_titleLightImage_2 = self:getControl(self.s_controls["titleLightImage_2"])
	self.m_titleLightImage_2:setVisible(false)
	
	local titleGroup = self:getUI("titleRadioButtonGroup")
	titleGroup:setOnChange(self,self.onTitleGroupChangeClick);

	-- 设置TAB切换监听
	-- 好友列表模块
	self.m_friendRadiobutton = self:getControl(self.s_controls["friendRadiobutton"])
	self.m_friendRadiobutton:setChecked(true)
	-- 查找模块
	self.m_searchRadiobutton = self:getControl(self.s_controls["searchRadiobutton"])

	-----好友-----
	-- friendsView 好友列表View
	self.m_friendsView = self:getControl(self.s_controls["friendsView"])
	-- contentListView 好友列表
	self.m_contentListView = self:getControl(self.s_controls["contentListView"])
    -- 好友数量
    self.m_friendNumLabel = self:getControl(self.s_controls["friendNumLabel"])
    -- TODO 设置最大好友数
    self:setFriendNum(nil,0)
    self.m_noDataTipLabel = self:getUI("noDataTipLabel")
    self.m_noDataTipLabel:setText(bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP"))

    -----查找好友-----
    -- searchFriendView 查找好友View
	self.m_searchFriendView = self:getControl(self.s_controls["searchFriendView"])
	self.m_searchFriendView:setVisible(false)
    -- 输入框
	self.m_searchEditBox = self:getControl(self.s_controls["searchEditBox"])
	self.m_searchEditBox:setHintText(bm.LangUtil.getText("FRIEND", "SEARCH_ID"),165,145,120);
    self.m_searchEditBox:setOnTextChange(self, self.onEditTextChange);
    -- 查找btn
    self.m_searchButton = self:getControl(self.s_controls["searchButton"])
    -- friendItemView 查找到的好友显示节点
    self.m_friendItemView = self:getControl(self.s_controls["friendItemView"])
    -- 查找到的好友
    self.m_searchFriendItems = {}

    -----推荐好友-----
    -- recommendLabel 推荐标题
    self.m_recommendLabel = self:getControl(self.s_controls["recommendLabel"])
    self.m_recommendLabel:setText(bm.LangUtil.getText("FRIEND", "RECOMMEND_TITLE"))
	-- recommendFriendView 推荐好友列表
    self.m_recommendFriendView = self:getControl(self.s_controls["recommendFriendView"])
    self.m_recommendFriendView:setVisible(false)
    -- recommendFriendItems 推荐好友控件Table,只第一次创建，更换推荐好友时作信息替换处理
    self.m_recommendFriendItems = {}
    self.m_changeLotLabel = self:getUI("changeLotLabel")
    self.m_changeLotLabel:addPropRotateSolid(1, 90, kCenterDrawing)
    self.m_changeLotLabel:setPickable(false)
    
    -- 无推荐好友提示
    self.m_noRecommendTipLabel = self:getUI("noRecommendTipLabel")
    self.m_noRecommendTipLabel:setPickable(false)
    self.m_noRecommendTipLabel:setText(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
    -- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self:getUI("bg"))
end

function FriendScene:onTitleGroupChangeClick()
    Log.printInfo("FriendScene", "onTitleGroupChangeClick")
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if self.m_friendRadiobutton:isChecked() then
    	self.m_titleLightImage_1:setVisible(true)
    	self.m_titleLightImage_2:setVisible(false)
    	self:onShowFriendView()
    elseif self.m_searchRadiobutton:isChecked() then
    	self.m_titleLightImage_2:setVisible(true)
    	self.m_titleLightImage_1:setVisible(false)
    	self:onShowSearchView()
    end
end

function FriendScene:onChangeLotButtonClick()
	Log.printInfo("FriendScene","onChangeLotButtonClick")
	self:onShowLoading(true)
	self:requestCtrlCmd("getRecommendFriendList")
end

function FriendScene:onShowLoading(status)	
	if status then
		Log.printInfo("FriendScene","onShowLoading true")
		self.m_loadingAnim:onLoadingStart()
	else
		Log.printInfo("FriendScene","onShowLoading false")
		self.m_loadingAnim:onLoadingRelease()
	end
end

function FriendScene:onShowFriendView()
	Log.printInfo("FriendScene","onShowFriendView")
	self.m_friendsView:setVisible(true)
	self.m_searchFriendView:setVisible(false)
	self.m_recommendFriendView:setVisible(false)
	self:onShowLoading(true)
	self:requestCtrlCmd("getFriendList")
end

function FriendScene:onShowSearchView()
	Log.printInfo("FriendScene","onShowSearchView")
	self.m_searchFriendView:setVisible(true)
	self.m_recommendFriendView:setVisible(true)
	self.m_friendsView:setVisible(false)
	if #self.m_recommendFriendItems < 1 then
		self:onShowLoading(true)
		self:requestCtrlCmd("getRecommendFriendList")
	end
end

-- editText内容改变监听
function FriendScene:onEditTextChange(str)
	if str == "" or str == " " or str == nil then
        self:setSendBtnStatus(false);
    else
        self:setSendBtnStatus(true);
        self:onSearchButtonClick()
    end
end

-- 设置发送按钮呼吸效果和可否点击
function FriendScene:setSendBtnStatus(enable)
    if enable then
        self.m_searchButton:setEnable(true); 
        -- 发送按钮呼吸动画
        self.m_searchButton:addPropTransparency(1,kAnimLoop,600,-1,1,0.7);
    else
        self.m_searchButton:setEnable(false);
        self.m_searchButton:doRemoveProp(1);
    end
end

function FriendScene:setFriendNum(total, current)
	if current == 0 then
		self.m_friendNumLabel:setVisible(false)
	else
        local vip = tonumber(nk.userData.vip or 0)
        if vip > 0 then
           total =  nk.vipController:getFriendNum(vip)
        end 

		self.m_friendNumLabel:setVisible(true)
		self.m_friendNumLabel:setText(T("我的好友") .. ":" .. (current or 0) .. "/" .. (total or 300))
	end
end

-------------------------------- handle function --------------------------

-- 更新好友列表
function FriendScene:onUpdateFriendList(data)
	Log.printInfo("FriendScene","onUpdatePayTypeList")
	self:onShowLoading(false)
    -- TODO 设置最大好友数
    self:setFriendNum(nil,#(data or {}))
	if not data or #data == 0 then
		self.m_noDataTipLabel:setVisible(true)
	else
        self.m_friendNumLabel:setVisible(true)
		self.m_contentListView:setVisible(true)
		if self.m_friendRadiobutton:isChecked() then
			self.m_recommendFriendView:setVisible(false)
		end
		self.m_noDataTipLabel:setVisible(false)
		local adapter = new(CacheAdapter, FriendItemLayer, data);
		self.m_contentListView:setAdapter(adapter)
        return
	end
	self.m_friendNumLabel:setVisible(false)
	self.m_contentListView:setVisible(false)
	self.m_recommendFriendView:setVisible(true)
	if #self.m_recommendFriendItems < 1 then
		self:onShowLoading(true)
		self:requestCtrlCmd("getRecommendFriendList")
	end
end

-- 更新好友推荐列表
function FriendScene:onUpdateRecommendFriend(status, data)
	Log.printInfo("FriendScene","onUpdateGoodsList")
	self:onShowLoading(false)
	if not status then
--		self:onShowBadNetwork()
	end
	if not data then
		self.m_noRecommendTipLabel:setVisible(true)
		return
	end
	self.m_noRecommendTipLabel:setVisible(false)
	update_recommend_view(self.m_recommendFriendView, data, self.m_recommendFriendItems)
end

-- 更新查找好友结果
function FriendScene:onUpdateSearchFriend(status, data)
	Log.printInfo("FriendScene","onUpdateSearchFriend")
	self:onShowLoading(false)
	if not data then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEARCH_ID_FAIL"))
		return
	end
	self.m_friendItemView:removeAllChildren(true)
	local friendItem = new(FriendItemLayer, data)
	self.m_friendItemView:addChild(friendItem)
end

-------------------------------- native event -----------------------------


-------------------------------- UI function ---------------------------

function FriendScene:onBackButtonClick()
	Log.printInfo("FriendScene","onBackButtonClick")
	self:requestCtrlCmd("back")
end

function FriendScene:onSearchButtonClick()
    nk.AnalyticsManager:report("New_Gaple_friend_search", "friend")

	Log.printInfo("FriendScene","onSearchButtonClick")
	local idStr = self.m_searchEditBox:getText() or "";
	Log.printInfo("FriendScene", "search editbox str:" .. idStr)
    if not string.find(idStr, "^[+-]?%d+$") then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEARCH_ID_ERROR"))
        self.m_searchEditBox:setText(nil)
        return
    end
    Log.printInfo("FriendScene", "search editbox str:" .. idStr .. " self mid:" .. nk.userData.mid)
    if tonumber(idStr) == tonumber(nk.userData.mid) then
    	nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEARCH_ID_ERROR"))
        self.m_searchEditBox:setText(nil)
        return
    end
	self:requestCtrlCmd("searchFriendById", idStr)
end

function FriendScene:onInviteButtonClick()
	Log.printInfo("FriendScene","onInviteButtonClick")
    local InviteScene = require("game.invite.inviteScene")
    nk.PopupManager:addPopup(InviteScene,"FriendScene")
end

-------------------------------- table config -----------------------------

FriendScene.s_cmdHandleEx = 
{
	["updateFriendList"] = FriendScene.onUpdateFriendList,
	["updateRecommendFriend"] = FriendScene.onUpdateRecommendFriend,
	["updateSearchFriend"] = FriendScene.onUpdateSearchFriend,
}

local DrawVip = function(node,vipLevel)
    node:removeAllChildren(true)
    local vipIcon = new(Image,"/res/common/vip_small/v.png")
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

update_recommend_view = function(root, data, rootItems)
	if rootItems and not table_is_empty(rootItems) then
		for i, v in ipairs(rootItems) do
			if data[i] then
				v.m_data = data[i]
                -- if not string.find(v.m_data.micon, "http")then
                    -- 默认头像 
                    local index = tonumber(v.m_data.micon) or 1
                    v.m_headImage:setFile(nk.s_headFile[index])
                    if v.m_data.msex and  tonumber(v.m_data.msex) ==1 then
                        v.m_headImage:setFile(kImageMap.common_male_avatar)
                    else
                        v.m_headImage:setFile(kImageMap.common_female_avatar)
                    end
                if string.find(v.m_data.micon, "http")then
                    -- 上传的头像
                    UrlImage.spriteSetUrl(v.m_headImage, v.m_data.micon)
                end 
		        v.m_moneyLabel:setText(nk.updateFunctions.formatBigNumber(v.m_data.money))
		        v.m_nameLabel:setText(nk.updateFunctions.limitNickLength(v.m_data.name,8))
		        if tonumber(v.m_data.msex) ==1 then
                    v.m_sexIcon:setFile(kImageMap.common_sex_man_icon)
                else
                    v.m_sexIcon:setFile(kImageMap.common_sex_woman_icon)
                end

		        if v.m_data.vip  and tonumber(v.m_data.vip)>0 then 
	                DrawVip(v.m_vip, v.m_data.vip)
	                v.m_nameLabel:setColor(0xa0,0xff,0x00)
                end
			end
		end
		return
	end

	-- data.msex
	-- data.status
	-- data.micon
	-- data.name
	-- data.money
	-- data.s_picture
	for i, v in ipairs(data) do
		if i > 4 then
			return
		end
    	local item = new(FriendRecommendItemLayer)
        local w = item:getSize()
        item:setPos(w*(i-1) + 20*i, 5)
    	item.m_data = v
        if not string.find(item.m_data.micon, "http")then
            -- 默认头像 
            local index = tonumber(item.m_data.micon) or 1
            item.m_headImage:setFile(nk.s_headFile[index])
            if item.m_data.msex and tonumber(item.m_data.msex) ==1 then
                item.m_headImage:setFile(kImageMap.common_male_avatar)
            else
                item.m_headImage:setFile(kImageMap.common_female_avatar)
            end
        else
            -- 上传的头像
            UrlImage.spriteSetUrl(item.m_headImage, item.m_data.micon)
        end 
        item.m_moneyLabel:setText(nk.updateFunctions.formatBigNumber(item.m_data.money))
        item.m_nameLabel:setText(nk.updateFunctions.limitNickLength(item.m_data.name,8))
        if tonumber(item.m_data.msex) ==1 then
            item.m_sexIcon:setFile(kImageMap.common_sex_man_icon)
        else
            item.m_sexIcon:setFile(kImageMap.common_sex_woman_icon)
        end
        if item.m_data.vip  and tonumber(item.m_data.vip)>0 then 
            DrawVip(item.m_vip, item.m_data.vip)
            item.m_nameLabel:setColor(0xa0,0xff,0x00)
        end
        table.insert(rootItems, item)
        root:addChild(item)
    end
end

return FriendScene