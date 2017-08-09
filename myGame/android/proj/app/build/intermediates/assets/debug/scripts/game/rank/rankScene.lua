-- rankScene.lua
-- Last modification : 2016-06-03
-- Description: a scene in Rank moudle

local RankScene = class(GameBaseScene)
local RankConfig = require("game.rank.rankConfig")
local RankItemLayer = require("game.rank.layers.rankItemLayer")
local RankRulePopup = require("game.rank.layers.rankRulePopLayer")
local LoadingAnim = require("game.anim.loadingAnim")

-- 更新排行榜列表
local update_rank_scroll

function RankScene:ctor(viewConfig,controller)
	Log.printInfo("RankScene.ctor")
    -- 初始化数据
    self:initScene()
end 

function RankScene:resume()
    Log.printInfo("RankScene.resume")
    nk.PopupManager:removeAllPopup()
    GameBaseScene.resume(self)
end

function RankScene:pause()
    Log.printInfo("RankScene.pause")
    nk.PopupManager:removeAllPopup()
	GameBaseScene.pause(self)
end 

function RankScene:dtor()
    Log.printInfo("RankScene.dtor")
end

-------------------------------- private function --------------------------

function RankScene:initScene(viewType)
	-- 将各个榜单的scrollView保存, 用于显示和隐藏
	self.m_listViews = {}
	-- 将各个榜单的item保存，避免重复创建
	self.m_totalRankItems = {}

	local subTitleBg = self:getUI("subTitleBg")
	-- subTitleBg:addPropRotateSolid(1, 90, kCenterDrawing)

	-- 设置TAB标题背景光
	self.m_titleLightImage_1 = self:getControl(self.s_controls["titleLightImage_1"])
	self.m_titleLightImage_2 = self:getControl(self.s_controls["titleLightImage_2"])
	self.m_titleLightImage_2:setVisible(false)
	self.m_titleLightImage_3 = self:getControl(self.s_controls["titleLightImage_3"])
	self.m_titleLightImage_3:setVisible(false)

	local titleGroup = self:getUI("radioButtonGroup")
	titleGroup:setOnChange(self,self.onTitleGroupChangeClick)

	-- 设置TAB切换监听
	-- 局数排行
	self.m_gameRadiobutton = self:getControl(self.s_controls["gameRadiobutton"])
	self.m_gameRadiobutton:setChecked(true)

	-- 盈利排行
	self.m_profitRadiobutton = self:getControl(self.s_controls["profitRadiobutton"])

	-- 金币排行
	self.m_moneyRadiobutton = self:getControl(self.s_controls["moneyRadiobutton"])

	local subTitleGroup = self:getUI("subRadioButtonGroup")
	subTitleGroup:setOnChange(self,self.onSubTitleGroupChangeClick)
	-- 设置sub_TAB切换监听
	-- 好友排行
	self.m_friendRankRadiobutton = self:getControl(self.s_controls["friendRankRadiobutton"])
	self.m_tabFriendLabel = self:getControl(self.s_controls["tabFriendLabel"])
	--self.m_friendRankRadiobutton:setChecked(true)
    self.m_tabFriendLabel:setColor(179,115,231)

	-- totalRankRadiobutton
	-- 总排行
	self.m_totalRankRadiobutton = self:getControl(self.s_controls["totalRankRadiobutton"])
	self.m_tabTotalLabel = self:getControl(self.s_controls["tabTotalLabel"])
	--self.m_tabTotalLabel:setColor(179,115,231)
    self.m_totalRankRadiobutton:setChecked(true)

	-- listView 载体
	self.m_contentView = self:getControl(self.s_controls["contentView"])
	-- 自己的排名 载体
	self.m_myRankView = self:getControl(self.s_controls["myRankView"])
	local selfData = {
		status = "",
		micon = "",
		name = "",
		money = "",
		rank = -1,
	}
	-- 自己的item
	self.m_myRankItem = new(RankItemLayer, selfData)
	self.m_myRankItem:addTo(self.m_myRankView)

	-- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self.m_contentView) 
end

-- Provide state to call
function RankScene:onBack()
	StateMachine.getInstance():popState()
end

function RankScene:onShowLoading(status)
	if status then
		Log.printInfo("RankScene","onShowLoading true")
		self.m_loadingAnim:onLoadingStart()
	else
		Log.printInfo("RankScene","onShowLoading false")
		self.m_loadingAnim:onLoadingRelease()
	end
end

function RankScene:showScrollView(mainType, subType)
	for i, v in pairs(self.m_listViews) do
		for j, k in pairs(v) do
			if i == mainType then
				if j == subType then
					k:setVisible(true)
				else
					k:setVisible(false)
				end
			else
				k:setVisible(false)
			end
		end
	end
end

-- main tab 的改变监听
function RankScene:onTitleGroupChangeClick()
    Log.printInfo("RankScene", "onTitleGroupChangeClick")
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self:onShowLoading(true)
    if self.m_gameRadiobutton:isChecked() then
        nk.AnalyticsManager:report("New_Gaple_rank_round", "rank")

    	self.m_titleLightImage_1:setVisible(true)
    	self.m_titleLightImage_2:setVisible(false)
    	self.m_titleLightImage_3:setVisible(false)
    	self:requestCtrlCmd("setMainTabIndex", 1)
    elseif self.m_profitRadiobutton:isChecked() then
        nk.AnalyticsManager:report("New_Gaple_rank_profit", "rank")

    	self.m_titleLightImage_2:setVisible(true)
    	self.m_titleLightImage_1:setVisible(false)
    	self.m_titleLightImage_3:setVisible(false)
    	self:requestCtrlCmd("setMainTabIndex", 2)
    elseif self.m_moneyRadiobutton:isChecked() then
        nk.AnalyticsManager:report("New_Gaple_rank_money", "rank")

    	self.m_titleLightImage_3:setVisible(true)
    	self.m_titleLightImage_1:setVisible(false)
    	self.m_titleLightImage_2:setVisible(false)
    	self:requestCtrlCmd("setMainTabIndex", 3)
    end
end

-- sub tab 的改变监听
function RankScene:onSubTitleGroupChangeClick()
    Log.printInfo("RankScene", "onSubTitleGroupChangeClick")
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self:onShowLoading(true)
    if self.m_friendRankRadiobutton:isChecked() then
    	self.m_tabFriendLabel:setColor(225,194,251)
    	self.m_tabTotalLabel:setColor(179,115,231)
    	self:requestCtrlCmd("setSubTabIndex", 1)
    elseif self.m_totalRankRadiobutton:isChecked() then
    	self.m_tabTotalLabel:setColor(225,194,251)
    	self.m_tabFriendLabel:setColor(179,115,231)
    	self:requestCtrlCmd("setSubTabIndex", 2)
    end
end

-------------------------------- handle function --------------------------

function RankScene:onUpdateRankList(mainType, subType, data, itemIndex)
	Log.printInfo("RankScene","onUpdateRankList")
	self:onShowLoading(false)
	local llistView
	if self.m_listViews[mainType] and self.m_listViews[mainType][subType] then
		llistView = self.m_listViews[mainType][subType]
	else
	 	llistView = new(ListView, 0, 0, 856, 375)
	 	llistView:setOnScroll(self, self.onLoadMore)
	    self.m_contentView:addChild(llistView)
        if not self.m_listViews[mainType] then
	        self.m_listViews[mainType] = {}
        end
	    self.m_listViews[mainType][subType] = llistView 
	end

	if #data > 0 then
		table.foreach(data, function(i, v)
				v.mainType = mainType
			end)
		local adapter = new(CacheAdapter, RankItemLayer, data)
		llistView:setAdapter(adapter)
		if itemIndex then
			llistView:setShowingIndex(itemIndex)
		end
	else
		-- TODO
	end

	self:showScrollView(mainType, subType)
end

function RankScene:onUpdateMyRank(mainType, data)
	Log.printInfo("RankScene","onUpdateMyRank")
	-- update_rank_scroll(self.m_myRankView, {data}, self.m_myRankItem, mainType, true)
	data.mainType = mainType
 	self.m_myRankItem:updateData(data, true)
end

function RankScene:onLoadMore(scroll_status,itemIndex,viewsNum,diff,totalOffset, isMarginRebounding)
    -- isMarginRebounding 是否回弹的状态
    -- 如果处于回弹状态，并且当前总的位移差totalOffset是负的话，代表到底了
    -- 如果处于回弹状态，并且当前总的位移差totalOffset是正的话，代表到头了
	if scroll_status == kScrollerStatusStop and isMarginRebounding and totalOffset < 0 then
        self:requestCtrlCmd("loadMore", itemIndex)
    end
end

-------------------------------- UI function -----------------------------

function RankScene:onBackButtonClick()
    Log.printInfo("RankScene","onBackButtonClick")
	self:requestCtrlCmd("back")
end

function RankScene:onRuleButtonClick()
    Log.printInfo("RankScene","onRuleButtonClick")
    nk.AnalyticsManager:report("New_Gaple_rank_rule", "rank")

    nk.PopupManager:addPopup(RankRulePopup,"rank")
end

-------------------------------- table config -----------------------------

RankScene.s_cmdHandleEx = 
{
	["updateRankList"] = RankScene.onUpdateRankList,
	["updateMyRank"] = RankScene.onUpdateMyRank,
}

-- 不同榜单不同描述
local function update_rank_type_text_(item, type)
	item.m_kiwi =  (item.m_kiwi or 0) + 1
    if type == RankConfig.mainType[1] then
        item.m_goldImage.visible = false
        item.m_moneyLabel:set_text(bm.LangUtil.getText("RANKING", "RECORDS", item.m_data.ptotal or 0, item.m_data.pwin or 0, item.m_data.plose or 0))
        -- item.m_moneyLabel.x = 236
        -- Clock.instance():schedule_once(function(dt)
        --     item.m_moneyLabel:dump_constraint()
        -- end, 3)
        item.m_moneyLabel:add_rules({
					AL.left:eq(236):priority(kiwi.MEDIUM + item.m_kiwi)
    			})
    elseif type == RankConfig.mainType[2] then
        item.m_goldImage.visible = true
        -- item.detailBtn_:hide()
        item.m_moneyLabel:set_text(nk.updateFunctions.formatNumberWithSplit(item.m_data.incMoney or 0))
        -- item.m_moneyLabel.x = 271
        item.m_moneyLabel:add_rules({
					AL.left:eq(271):priority(kiwi.MEDIUM + item.m_kiwi)
    			})
    elseif type == RankConfig.mainType[3] then
        item.m_goldImage.visible = true
        -- item.detailBtn_:hide()
        item.m_moneyLabel:set_text(nk.updateFunctions.formatNumberWithSplit(item.m_data.money or 0))
        -- item.m_moneyLabel.x = 271
        item.m_moneyLabel:add_rules({
					AL.left:eq(271):priority(kiwi.MEDIUM + item.m_kiwi)
    			})
    end
    -- item:update_constraints()
end

update_rank_scroll = function(content, data, rootItems, type, isMy)
	if rootItems and not table_is_empty(rootItems) then
		for i, v in ipairs(rootItems) do
			if data[i] then
				v.m_data = data[i]
				UrlImage.spriteSetUrl(v.m_headImage, v.m_data.micon)
		        v.m_nameLabel:set_text(v.m_data.name)
		        if data.status then
			        if data.status == 0 then
			            v.m_statusLabel:set_text(offline_status.text)
			            v.m_statusLabel:setColor(offline_status.color)
			        elseif data.status == 1 then
			            v.m_statusLabel:set_text(lobby_status.text)
			            v.m_statusLabel:setColor(lobby_status.color)
			        elseif data.status == 2 then
			            v.m_statusLabel:set_text(room_status.text)
			            v.m_statusLabel:setColor(room_status.color)
			        end
	    		end
	    		update_rank_type_text_(v, type)
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
		local itemContent = Widget()

    	local item = new(RankItemLayer)
    	if isMy then
    		item.m_bg.unit = TextureUnit(TextureCache.instance():get(kImageMap.rank_self_rank_bg))
    		item.m_bg:add_rules({
    				AL.width:eq(882),
					AL.height:eq(112),
    			})
    		item.m_bg:add_rules({
					AL.left:eq(AL.parent('width')*0.5-882*0.5),
    			})
    	end
        itemContent:add_rules({
        		AL.width:eq(AL.parent('width')),
				AL.height:eq(item.size.y),
        	})

        item:add_rules(AL.rules.align(ALIGN.CENTER))

        item.m_data = v
        item.m_headButton.on_click = function()
    		nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Rank", item.m_data)
    	end

        UrlImage.spriteSetUrl(item.m_headImage, item.m_data.micon)

        item.m_nameLabel:set_text(item.m_data.name)

        if data.status then
	        if data.status == 0 then
	            item.m_statusLabel:set_text(offline_status.text)
	            item.m_statusLabel:setColor(offline_status.color)
	        elseif data.status == 1 then
	            item.m_statusLabel:set_text(lobby_status.text)
	            item.m_statusLabel:setColor(lobby_status.color)
	        elseif data.status == 2 then
	            item.m_statusLabel:set_text(room_status.text)
	            item.m_statusLabel:setColor(room_status.color)
	        end
	    end

	    update_rank_type_text_(item, type)

    	item.m_trackButton.on_click = function()
        	-- EventDispatcher.getInstance():dispatch(EventConstants.friendBuyEvent, "BUY_GOODS", item.m_data.pid, item.m_data)
    	end
    	itemContent:add(item)
    	table.insert(rootItems, item)
        content:add(itemContent)
    end
end

return RankScene