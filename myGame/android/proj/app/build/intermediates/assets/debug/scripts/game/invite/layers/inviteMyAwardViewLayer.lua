-- inviteMyAwardViewLayer.lua
-- Last modification : 2016-06-30
-- Description: a people item layer in invite moudle

local InviteMyAwardViewLayer = class(GameBaseLayer, false)
local view = require(VIEW_PATH .. "invite.invite_my_award_view_layer")
local varConfigPath = VIEW_PATH .. "invite.invite_my_award_view_layer_layout_var"
local InviteAwardItemLayer = require("game.invite.layers.inviteAwardItemLayer") 
local LoadingAnim = require("game.anim.loadingAnim")

function InviteMyAwardViewLayer:ctor()
	Log.printInfo("InviteMyAwardViewLayer", "ctor")
    super(self, view, varConfigPath)
    self:setSize(self.m_root:getSize())
    self.m_nowTime = os.time()
    self.m_nowDayStr = os.date("%Y-%m-%d", self.m_nowTime)
    self.m_lastDayStr = self:getNewDayStr(self.m_nowDayStr, -7)
    -----------
    -- 标记字段
    -----------

    -- 正在加载某日的奖励数据
    self.m_isGetAwardDataing_date = ""
    
    -- 领取奖励
    self.m_isGetAwarding_id = -1

    -----------
    -- 标记字段 end
    -----------

    -- 累计成功邀请人数：0人
    self.m_totalNumRichText = new(RichText,"", 305, 44, kAlignLeft, "", 20, 255, 255, 255, false,0)
    self.m_totalNumRichText:setPos(27)
    self.m_totalNumLabel = self:getControl(self.s_controls["totalNumLabel"])
    -- 累计获得奖励：0金币
    self.m_totalMoneyRichText = new(RichText,"", 314, 44, kAlignLeft, "", 20, 255, 255, 255, false,0)
    self.m_totalMoneyRichText:setPos(349)
    self.m_totalMoneyLabel = self:getControl(self.s_controls["totalMoneyLabel"])

    local topImage = self:getUI("topImage")
    topImage:addChild(self.m_totalNumRichText)
    topImage:addChild(self.m_totalMoneyRichText)

    self.m_totalNumRichText:setText(bm.LangUtil.getText("FRIEND", "INVITE_TOTAL_NUM", 0))
    self.m_totalMoneyRichText:setText(bm.LangUtil.getText("FRIEND", "INVITE_TOTAL_MONEY", 0))

    -- 全部领取btn
    self.m_getAllButton = self:getUI("getAllButton")
    self.m_getAllButton:setVisible(false)

    self.m_getAllLabel = self:getUI("getAllLabel")
    self.m_getAllLabel:setText(bm.LangUtil.getText("FRIEND", "GET_ALL_REWARD"))

	-- 奖励明细（最多只能查看一个月内的）
	self.m_detailLabel = self:getControl(self.s_controls["detailLabel"])
	self.m_detailLabel:setText(bm.LangUtil.getText("FRIEND", "DETAIL_REWARD"))
	-- 2016-06-30  os.date("%Y-%m-%d", time)
	self.m_dateLabel = self:getControl(self.s_controls["dateLabel"])
    -- 前一天按钮
    self.m_beforeButton = self:getControl(self.s_controls["beforeButton"])
    -- 后一天按钮
    self.m_afterButton = self:getControl(self.s_controls["afterButton"])
	-- 暂无奖励信息哦！
	self.m_tipNoLabel = self:getControl(self.s_controls["tipNoLabel"])
	self.m_tipNoLabel:setText(bm.LangUtil.getText("FRIEND", "NOT_REWARD"))
	-- 奖励scrollview
	self.m_awardScrollView = self:getUI("awardScrollView")
    -- 存储各日期的奖励数据
	self.m_awardDataList = {}

	-- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self:getUI("bgView"))

	EventDispatcher.getInstance():register(InviteAwardItemLayer.getAward, self, self.onGetAward)
    EventDispatcher.getInstance():register(EventConstants.update_invite_award, self, self.updateAward)

    self.m_updateAward = false
end 

function InviteMyAwardViewLayer:dtor()
	Log.printInfo("InviteMyAwardViewLayer", "dtor")
	EventDispatcher.getInstance():unregister(InviteAwardItemLayer.getAward, self, self.onGetAward)
    EventDispatcher.getInstance():unregister(EventConstants.update_invite_award, self, self.updateAward)
end

function InviteMyAwardViewLayer:updateAward()
    self.m_updateAward = true
end

function InviteMyAwardViewLayer:onShow()
	Log.printInfo("InviteFriendViewLayer", "onShow");
	if table_is_empty(self.m_awardDataList) or self.m_updateAward == true  then
		local dateStr = os.date("%Y-%m-%d", self.m_nowTime)
        self:updateTile(dateStr)
		self:getAwardData(dateStr)
	end
end

-- 获取对应天数的奖励数据
function InviteMyAwardViewLayer:getAwardData(dayStr)
	Log.printInfo("InviteMyAwardViewLayer", "getAwardData " .. dayStr)
	self:updateTile(dayStr)
    if self.m_awardDataList[dayStr] and self.m_updateAward == false then
    	self:updateAwardDataList(self.m_awardDataList[dayStr])
		return
	end
	if self.m_isGetAwardDataing_date == dayStr then
		return
	end
	self.m_isGetAwardDataing_date = dayStr
	self:onShowLoading(true)
	local params = {}
	params.mid = nk.userData.mid
	params.day = dayStr
	nk.HttpController:execute("getInviteAwardData", {game_param = params})
end

-- 领取奖励
function InviteMyAwardViewLayer:onGetAward(id, isAll)
	if self.m_isGetAwarding_id == id then
		return
	end
	self:onShowLoading(true)
	self.m_isGetAwarding_id = id
	local params = {}
	params.mid = nk.userData.mid
	params.id = id
	params.isAll = isAll or 0
	nk.HttpController:execute("getInviteAward", {game_param = params})
end

-- 将日期字符串加或减对应的天数，返回日期字符串
-- @param string srcDateTime 日期字符串 XXXX-XX-XX
-- @param number interval 间隔天数
function InviteMyAwardViewLayer:getNewDayStr(srcDateTime, interval)
	-- 从日期字符串中截取出年月日时分秒
	local Y = string.sub(srcDateTime,1,4)
	local M = string.sub(srcDateTime,6,7)
	local D = string.sub(srcDateTime,9,10)
	-- 把日期时间字符串转换成对应的日期时间
	local dt1 = os.time{year=Y, month=M, day=D}
	-- 根据时间单位和偏移量得到具体的偏移数据
	local ofset = 60 *60 * 24 * interval
	-- 指定的时间+时间偏移量
	local newTime = os.date("%Y-%m-%d", dt1 + tonumber(ofset))
	return newTime
end

-- 更新标题 （日期和箭头的显隐）
function InviteMyAwardViewLayer:updateTile(dayStr)
    self.m_isGetAwardData_date = dayStr
    self.m_dateLabel:setText(dayStr)
    if dayStr == self.m_nowDayStr then
        self.m_afterButton:setVisible(false)
    else
        self.m_afterButton:setVisible(true)
    end
    if dayStr == self.m_lastDayStr then
        self.m_beforeButton:setVisible(false)
    else
        self.m_beforeButton:setVisible(true)
    end
end

-- 更新奖励记录列表
function InviteMyAwardViewLayer:updateAwardDataList(data)
    if data and not table_is_empty(data) then
    	self.m_tipNoLabel:setVisible(false)
    	self.m_awardScrollView:setVisible(true)
    	update_invite_award_scroll(self.m_awardScrollView, data, self.m_getAllButton)
    else
    	self.m_tipNoLabel:setVisible(true)
    	self.m_awardScrollView:setVisible(false)
    end
end

-- 前一天点击事件
function InviteMyAwardViewLayer:onBeforeButtonClick()
	Log.printInfo("InviteMyAwardViewLayer", "onBeforeButtonClick")
	local dayStr = self.m_dateLabel:getText()
	dayStr = self:getNewDayStr(dayStr, -1)
	self:getAwardData(dayStr)
end

-- 后一天点击事件
function InviteMyAwardViewLayer:onAfterButtonClick()
	Log.printInfo("InviteMyAwardViewLayer", "onAfterButtonClick")
    local dayStr = self.m_dateLabel:getText()
	dayStr = self:getNewDayStr(dayStr, 1)
	self:getAwardData(dayStr)
end

-- 领取全部点击事件
function InviteMyAwardViewLayer:onGetAllButtonClick()
	self:onGetAward(nil, 1)
end

-- 注册HTTP监听事件
function InviteMyAwardViewLayer:onHttpPorcesser(command, ...)
	Log.printInfo("gameBase", "InviteMyAwardViewLayer.onHttpPorcesser")
	if not self.s_httpRequestsCallBack[command] then
		Log.printWarn("gameBase", "Not such request cmd in current controller")
		return
	end
    self.s_httpRequestsCallBack[command](self,...) 
end

-- 获取奖励数据回调
function InviteMyAwardViewLayer:onGetAwardDataCallback(errorCode, data)
	Log.printInfo("InviteMyAwardViewLayer", "onGetAwardDataCallback")
	self:onShowLoading(false)
	if errorCode == HttpErrorType.SUCCESSED then
		if data.code and data.code == 1 then
			if data and data.data then
                local retData = data.data
				if retData.num then
					self.m_totalNumRichText:setText(bm.LangUtil.getText("FRIEND", "INVITE_TOTAL_NUM", retData.num))
				end
				if retData.money then
					self.m_totalMoneyRichText:setText(bm.LangUtil.getText("FRIEND", "INVITE_TOTAL_MONEY", retData.money))
				end
				self.m_awardDataList[retData.day] = retData.list or {}
                Log.printInfo("InviteMyAwardViewLayer:onGetAwardDataCallback self.m_isGetAwardDataing_date = ",self.m_isGetAwardDataing_date)
                Log.printInfo("InviteMyAwardViewLayer:onGetAwardDataCallback retData.day = ",retData.day)
                if self.m_isGetAwardDataing_date == retData.day then
                    self.m_isGetAwardDataing_date = ""
                    self.m_updateAward = false
                    self:updateAwardDataList(self.m_awardDataList[retData.day])
                end
			end
		else
			
		end
	else

	end
end

local function setAwardDataStatus(data, isGet, id)
	if isGet > 0 then
		table.foreach(data, function(i, v)
			table.foreach(v, function(j, k)
					if tonumber(id) == tonumber(k.id) then
						k.status = 1
						return
					end
				end)
		end)
	else
		table.foreach(data, function(i, v)
			table.foreach(v, function(j, k)
					k.status = 1
				end)
		end)
	end
end


-- 领取奖励回调
function InviteMyAwardViewLayer:onGetInviteAwardCallback(errorCode, data)
	Log.printInfo("InviteMyAwardViewLayer", "onGetAwardDataCallback")
	self:onShowLoading(false)
	if errorCode == HttpErrorType.SUCCESSED then
		if data.code and data.code == 1 then
			local retData = data.data
			if retData.code == 1 then
                local money1 = nk.userData.money
				nk.functions.setMoney(retData.money)
                local money2 = nk.userData.money  
                local name = nk.updateFunctions.formatBigNumber(money2-money1)..bm.LangUtil.getText("STORE", "TITLE_CHIP")
                nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"TaskPopup",{{name=name,icon = kImageMap.common_coin_107}}) 
				self.m_totalMoneyRichText:setText(bm.LangUtil.getText("FRIEND", "INVITE_TOTAL_MONEY", retData.inviteCountMoney))
				nk.userData.inviteIsGet = retData.isGet
				if retData.isGet > 0 then
					self.m_getAllButton:setVisible(true)
				else
					self.m_getAllButton:setVisible(false)
				end
				setAwardDataStatus(self.m_awardDataList, retData.isGet, retData.id)
				self:getAwardData(self.m_isGetAwardData_date)
				if retData.msg then
					nk.TopTipManager:showTopTip(retData.msg)
				else
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_GETREWARD_SUCC"))
				end
			else
				if retData.msg then
					nk.TopTipManager:showTopTip(retData.msg)
				else
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_GETREWARD_FAIL"))
				end
			end
		else
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_GETREWARD_FAIL"))
		end
	else
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
	end
end

function InviteMyAwardViewLayer:onShowLoading(status)	
	if status then
		Log.printInfo("InviteMyAwardViewLayer","onShowLoading true")
		self.m_loadingAnim:onLoadingStart()
	else
		Log.printInfo("InviteMyAwardViewLayer","onShowLoading false")
		self.m_loadingAnim:onLoadingRelease()
	end
end

InviteMyAwardViewLayer.s_eventHandle = {
    [EventConstants.httpProcesser] = InviteMyAwardViewLayer.onHttpPorcesser,
}

InviteMyAwardViewLayer.s_httpRequestsCallBack = {
	["getInviteAwardData"] = InviteMyAwardViewLayer.onGetAwardDataCallback,
	["getInviteAward"] = InviteMyAwardViewLayer.onGetInviteAwardCallback,
}

update_invite_award_scroll = function(content, data, getAllButton)
	-- data.id
	-- data.content
	-- data.status
	-- data.time
    local setItemData = function(root)
        root.m_detailLabel:setText(root.m_data.content)
        root.m_timeLabel:setText(os.date("%H:%M", root.m_data.time))
        if tonumber(root.m_data.status) == 0 then
        	root.m_getButton:setVisible(true)
        	getAllButton:setVisible(true)
        	root.m_gettedLabel:setVisible(false)
        else
        	root.m_getButton:setVisible(false)
        	root.m_gettedLabel:setVisible(true)
        end
    end
    content:removeAllChildren(true)
	for i, v in ipairs(data) do
    	local item = new(InviteAwardItemLayer, v)
        item.m_data = v
        setItemData(item)
        content:addChild(item)
    end
end

return InviteMyAwardViewLayer