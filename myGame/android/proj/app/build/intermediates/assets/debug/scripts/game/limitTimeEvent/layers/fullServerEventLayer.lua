
local view = require(VIEW_PATH .. "limitTimeEvent.fullService_event_layer")
local varConfigPath = VIEW_PATH .. "limitTimeEvent.fullService_event_layer_layout_var"

local NumScrollerAnim = require("game.limitTimeEvent.layers.numScrollerAnim")

local RankItem = require("game.limitTimeEvent.layers.rankItem")

local FullServerEventLayer = class(GameBaseLayer, false)


local test_num = {
	originNum = 123011,
	changeNum = math.random(5,8),


	diffSetNum = math.random(20,333),
	resetChangeBigNum = math.random(200,5555),
}

function FullServerEventLayer:ctor()
	Log.printInfo("FullServerEventLayer.ctor");
	super(self, view, varConfigPath)
 
	self.m_nodeTable = {}

    self:initScene()
    self:createNumBar()
    self.m_numScrollerAnim = new(NumScrollerAnim,self.m_nodeTable)
    EventDispatcher.getInstance():register(EventConstants.limitTimeEvent_prize_result, self, self.updateRewardView)
end

function FullServerEventLayer:dtor()
	if self.m_numScrollerAnim then
		self.m_numScrollerAnim:stopScroll()
		delete(self.m_numScrollerAnim)
		self.m_numScrollerAnim = nil
	end
	EventDispatcher.getInstance():unregister(EventConstants.limitTimeEvent_prize_result, self, self.updateRewardView)
end

function FullServerEventLayer:initScene()
	self.m_event_image_node = self:getUI("event_image_node")
	self.m_event_image = self:getUI("event_image") 

	local event_icon = self:getUI("event_icon") 
	event_icon = self:getUI("event_icon") 
	event_icon:addPropScaleSolid(0, 0.8, 0.8, kCenterDrawing)

	self.m_rank_view = self:getUI("rank_view")
	self.m_rank_title = self:getUI("rank_title")
	self.m_rank_title:setText(bm.LangUtil.getText("LIMIT_TIME_EVENT","RANK_TILE1"))
	self.m_rank_scroller_view = self:getUI("rank_scroller_view")

	self.m_event_time_1 = self:getUI("fullService_event_time")
	self.m_event_time_1:setVisible(false)

	self.m_countdown_time_bg = self:getUI("countdown_time_bg")
	self.m_event_time = new(RichText,"", 300, 32, kAlignCenter, "", 18, 255, 255, 255, false,0)
	self.m_event_time:setAlign(kAlignCenter)
	self.m_countdown_time_bg:addChild(self.m_event_time) 

	self.m_num_bar = self:getUI("num_bar")

	self.m_num_clip_view = self:getUI("num_clip_view")
	local w, h = self.m_num_clip_view:getSize()
	self.m_num_clip_view:setClip2(true, 0, 0, w, h)

	self.m_fullService_event_name = self:getUI("fullService_event_name")
	self.m_fullService_event_name:setText(bm.LangUtil.getText("LIMIT_TIME_EVENT","FULLSERVER_EVENT_NAME"))

	self.m_reward_view = self:getUI("reward_view")
	self.m_reward_text = self:getUI("reward_text")
	self.m_rewardCondition = self:getUI("reward_condition")
	self.m_hasGetReward = self:getUI("hasGetReward")
	self.m_reward_icon = self:getUI("reward_icon")

	self.m_getRewardBtn = self:getUI("getRewardBtn")

	self.m_fullService_event_desc = self:getUI("fullService_event_desc")

	self.m_quick_play_btn = self:getUI("quick_play_btn")

	self.m_quick_play_taxt = self:getUI("quick_play_taxt")
	self:setRewardBtnStatus(0)
end

-- 0未达成，1可领取，2 已领取
function FullServerEventLayer:setRewardBtnStatus(status)
	if status == 0 then
		self.m_reward_view:setColor(128,128,128)
		self.m_hasGetReward:setVisible(false)
		self.m_getRewardBtn:setEnable(false)
	elseif status == 1 then
		if nk.limitTimeEventDataController:getAllEventRewardStatus() ~= -1 then
			self.m_reward_view:setColor(255,255,255)
			self.m_hasGetReward:setVisible(false)
			self.m_getRewardBtn:setEnable(true)
		end
		if self.m_numScrollerAnim then
			self.m_numScrollerAnim:onStopCurScrollerAnim()
			local allEvent = nk.limitTimeEventDataController:getAllEvent()
			if allEvent and allEvent.num then
				self.m_numScrollerAnim:setNumBar(allEvent.num)
			end
		end
	elseif status == 2 then
		self.m_reward_view:setColor(128,128,128)
		self.m_hasGetReward:setVisible(true)
		self.m_getRewardBtn:setEnable(false)
	end
end

function FullServerEventLayer:setCountdownTimeStr(text, time)
	self.m_event_time:setText(text)
	if time <= 0 then
		self:setRewardBtnStatus(0)
	end
end

function FullServerEventLayer:createNumBar()
	for i=1,8 do
		local node = self:getUI(string.format("node_%d",i))
		table.insert(self.m_nodeTable, node)
	end
end

function FullServerEventLayer:fullServerEventCurNumCallback(directNum, isNeedAnim)
	if self.m_numScrollerAnim then
		self.m_numScrollerAnim:onStartCurScrollerAnim(directNum, isNeedAnim)
	end 
	if not isNeedAnim then
		local status = nk.limitTimeEventDataController:getAllEventRewardStatus()
		if status == 0 then
			self:setRewardBtnStatus(1)
			local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
		    datas["fullEventPoint"] = true
		elseif status == 1 then
			self:setRewardBtnStatus(2)
		end
	end
end

function FullServerEventLayer:updataView(data, isNeedAnim)
	if data then
		local counts = tonumber(data.counts)
		if counts and counts > 0 then
			self:fullServerEventCurNumCallback(counts, isNeedAnim)
		end
		if data.list and #data.list > 0 then
			self:updataRankView(data.list)
		end
		self:updataConfigView()
		local allEvent = nk.limitTimeEventDataController:getAllEvent()
		local rewardCondition = ""
		if allEvent and allEvent.unit and allEvent.num then
			local numStr = nk.updateFunctions.formatBigNumber(allEvent.num)
			rewardCondition = numStr ..  " " .. allEvent.unit
		end
		self.m_rewardCondition:setText(rewardCondition)
	end
end

function FullServerEventLayer:updataRankView(rankData)
	self.m_rank_scroller_view:removeAllChildren(true)
	self.m_rank_title:setText(bm.LangUtil.getText("LIMIT_TIME_EVENT","RANK_TILE", #rankData))
	local pos_x, pos_y = 0, 0
	for index,data in ipairs(rankData) do
		local item = new(RankItem, data)
        item:setDelegate(self, self.onItemClick)
        local width, height = item:getSize()
        pos_x = (index+2)%3*width
        item:setPos(pos_x, pos_y)
        self.m_rank_scroller_view:addChild(item)
        if index%3 == 0 then
            pos_y = pos_y + height + 5
        end   
	end
end

function FullServerEventLayer:updataConfigView()
	local allEvent = nk.limitTimeEventDataController:getAllEvent()
	if allEvent then 
		if allEvent.image and string.find(allEvent.image, "http") then
			UrlImage.spriteSetUrl(self.m_event_image, allEvent.image)
		end
		self.m_reward_text:setText(allEvent.prize)
		if allEvent.prize_icon and string.find(allEvent.prize_icon, "http") then
			UrlImage.spriteSetUrl(self.m_reward_icon, allEvent.prize_icon)
		end
		local richLabel = new(RichText, allEvent.desc or "", 441, 200, kAlignTopLeft, "", 18, 220, 190, 255, true, 10)
        self.m_fullService_event_desc:addChild(richLabel)
		self.m_quick_play_taxt:setText(allEvent.btn_name)
	end
end

function FullServerEventLayer:onQuickPlayBtnClick()
	local allEvent = nk.limitTimeEventDataController:getAllEvent()
 	if self.m_obj and self.m_fun and allEvent then
 		self.m_fun(self.m_obj, allEvent.btn_url, allEvent.ext)
 	end
end

function FullServerEventLayer:setDelegate(obj, fun)
	self.m_obj = obj
	self.m_fun = fun
end

function FullServerEventLayer:onGetRewardBtnClick()
	nk.limitTimeEventDataController:getPrize(1)
end

function FullServerEventLayer:updateRewardView(opType,code)
	if opType ~= 1 then 
        return 
    end
	if code == 1 then
		self:setRewardBtnStatus(2)
		-- self:setRedPoint(false)
		local allEvent = nk.limitTimeEventDataController:getAllEvent()
		if allEvent then
			nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"LimitTimeEventPopup",{{name=allEvent.prize or "",icon = allEvent.prize_icon or ""}}) 
		end
	elseif code == -1 then
		--已经领取过了
		self:setRewardBtnStatus(2)
		-- self:setRedPoint(false)
	elseif code == -2 or code == -6 or code == -7 then
		self:setRewardBtnStatus(0)
		-- self:setRedPoint(false)
	end
end

function FullServerEventLayer:setRedPoint(vislble)
	local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
    datas["fullEventPoint"] = vislble
end

return FullServerEventLayer