-- LimitTimeEventDataController.lua
local MAX_NUM = 99999999

local LimitTimeEventDataController = class()
local CacheHelper = require("game.cache.cache")
local limitTimeEventModel = require("game.limitTimeEvent.limitTimeEventModel")

function LimitTimeEventDataController:ctor()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function LimitTimeEventDataController:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function LimitTimeEventDataController:clean()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false  
    self.configData_ = nil

    self.singleEventArr = nil
    self.allEvent = nil
    self.isInit = false

    nk.GCD.CancelById(self,self.m_fefreshTimer_id)

    if self.m_fefreshTimer_id then
        self.m_fefreshTimer_id = nil
    end

    nk.GCD.CancelById(self,self.m_countDownTimer_id)

    if self.m_countDownTimer_id then
        self.m_countDownTimer_id = nil
    end

end

function LimitTimeEventDataController:reStartLoading()
    if not self.isConfigLoaded_ then
        self.isConfigLoading_ = false
    end
end

function LimitTimeEventDataController:getInit()
    return self.isInit
end

function LimitTimeEventDataController:loadConfig(url,callback)
    if self.url_ ~= url then
        self.url_ = url

        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
        self.configData_ = nil
        self.isInit = false
    end
    self.loadConfigCallback_ = callback
    if self.url_ and self.url_ ~= "" then
        self:loadConfig_()
    end
end
function LimitTimeEventDataController:loadConfig_()
   if not self.isConfigLoaded_ and not self.isConfigLoading_ then
       self.isConfigLoading_ = true
       local cache = new(CacheHelper)
       cache:cacheFile(self.url_ or nk.userData.ALL_SERVER_ACTIVITY, function(result,content,stype)
          self.isConfigLoading_ = false
          Log.dump(content,">>>>>>>>>>>>>>>>>>>>>>>>>>>>> LimitTimeEventDataController content")
          if result then
              self.isInit = true
              self.isConfigLoaded_ = true
              if not self.configData_ then
                  self.configData_ = content
                  if self.configData_ == nil then
                      Log.printInfo("limitTimeEventData 配置错误!!")
                  else
                      self:processConfigData(self.configData_)
                  end
                  if self.loadConfigCallback_ then
                     self.loadConfigCallback_(true, self.configData_)
                  end
              end
          end
       end,"limitTimeEventData","data")
    elseif self.isConfigLoaded_ then
        self:processConfigData(self.configData_)
        if self.loadConfigCallback_ then
             self.loadConfigCallback_(true, self.configData_)
        end
    end
end

function LimitTimeEventDataController:processConfigData(data)
    if data then
        --全服活动
        self.allEvent = nil
        self.allEvent = new(limitTimeEventModel)
        if data.all then
            data.all["etime"] = data.etime or 0
            data.all["stime"] = data.stime or 0
            data.all["task_type"] = data.task_type or "friend"
            data.all["unit"] = data.unit or ""
            self.allEvent:setModel(data.all)
            if self.allEvent.num > MAX_NUM then
                self.allEvent.num = MAX_NUM
            end
        end

        --个人活动
        self.singleEventArr = {}
        for k,v in pairs(data.only.prize) do 
            local single = {}
            single["image"] = data.only.image or ""
            single["desc"] = data.only.desc or ""
            single["btn_name"] = data.only.btn_name or ""
            single["btn_url"] = data.only.btn_url or ""
            single["ext"] = data.only.ext or ""

            single["num"] = v.num
            single["prize"] = v.name
            single["prize_icon"] = v.icon

            single["etime"] = data.etime or 0
            single["stime"] = data.stime or 0
            single["task_type"] = data.task_type or "friend"
            single["unit"] = data.unit or ""

            local temp = new(limitTimeEventModel)
            temp:setModel(single)
            table.insert(self.singleEventArr,temp)
        end
        table.sort(self.singleEventArr,function(a,b)
                return a.num < b.num 
        end)
    end
end

-- 获取个人和全服活动的数据
function LimitTimeEventDataController:getEventData()
    if nk.userData.ALL_SERVER_ACTIVITY and nk.userData.ALL_SERVER_ACTIVITY ~= "" then
        self:loadConfig(nk.userData.ALL_SERVER_ACTIVITY,function()
            local params = {}
            params.mid = nk.userData.mid
            nk.HttpController:execute("AllServerActivity.getConfig", {game_param = params})
        end)
    else
        local params = {}
        params.mid = nk.userData.mid
        nk.HttpController:execute("AllServerActivity.getConfig", {game_param = params})
    end
end

-- @optype 1 表示全服活动奖品，2 表示个人活动奖品 
-- @num optype=2 时传递，表示用户领取奖励对应的任务完成所需数量
function LimitTimeEventDataController:getPrize(optype,num)
    local params = {}
    params.mid = nk.userData.mid
    params.type = optype
    if optype == 2 then
        params.num = num
        nk.AnalyticsManager:report("New_Gaple_limitTimeEvent_single_getRwward", "limitTimeEventPopup")
    elseif optype == 1 then
        nk.AnalyticsManager:report("New_Gaple_limitTimeEvent_all_getRwward", "limitTimeEventPopup")
    end
    nk.HttpController:execute("AllServerActivity.getPrize", {game_param = params})
end

-- 获取全服活动当前进度
function LimitTimeEventDataController:getFullEventCounts()
	local params = {}
    params.sid = tonumber(GameConfig.ROOT_CGI_SID or 1)
	nk.HttpController:execute("AllServerActivity.getActivityCounts", {game_param = params})
end

function LimitTimeEventDataController:onHttpProcesser(command, errorCode, content)
	if command == "AllServerActivity.getConfig" then
        if errorCode ~= HttpErrorType.SUCCESSED then
            return 
        end

		if content.code ~= 1 then
			return
		end

		self.m_eventData = content.data

        Log.dump(self.m_eventData,">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> self.m_eventData")
		-- json  这个参数 是防止活动进行当中配置更改，
					-- 如果发现和 （在index.php登陆接口返回字段:urls->allServerActivity） 不一样就要重新拉取活动配置
        if self.m_eventData then
            if self.m_eventData.json and self.m_eventData.json ~= "" and nk.userData.ALL_SERVER_ACTIVITY ~= self.m_eventData.json then
                self.startTime = os.time()
                nk.userData.ALL_SERVER_ACTIVITY = self.m_eventData.json
                self:loadConfig(self.m_eventData.json,function()
                    self:processData()
                end)
            else
                self:processData()
            end
        end
        
	elseif command == "AllServerActivity.getActivityCounts" then
        if errorCode ~= HttpErrorType.SUCCESSED then
            return 
        end

		if content.code ~= 1 then
			return
		end

		self.m_fullSEventCurCounts = checkint(content.data or 0) or 0

        local isNeedAnim = false
        if self.allEvent and self.m_fullSEventCurCounts < checkint(self.allEvent.num) then
            isNeedAnim = true
        else
            nk.GCD.CancelById(self,self.m_fefreshTimer_id)
        end
		-- 发送通知更新界面
        EventDispatcher.getInstance():dispatch(EventConstants.update_limitTimeEvent_view, self.m_fullSEventCurCounts, 2, isNeedAnim)
	
    elseif command == "AllServerActivity.getPrize" then
        if errorCode ~= HttpErrorType.SUCCESSED then
            return 
        end
        local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
        local result_type = 0
        local sData
        local code = content.code or 0
        if code ~= 1 then
            if code == -1 then
                --已经领取过了
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_EVENT","TIPS_1"))
            elseif code == -2 then
                --任务未完成 
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_EVENT","TIPS_2"))
                nk.limitTimeEventDataController:getEventData()
            elseif code == -3 then
                --奖励发送失败 
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_EVENT","TIPS_3"))
            elseif code == -4 then
                --系统错误
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_EVENT","TIPS_3"))
            elseif code == -5 then
                --错误的任务数量 
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_EVENT","TIPS_3"))
            elseif code == -6 then
                --活动（配置或奖励配置）不存在
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_EVENT","TIPS_4"))
            elseif code == -7 then
                -- 玩家未参与活动
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_EVENT","TIPS_5"))
            end
        else
            local result = content.data
            result_type = result.type

            if result then
                -- type 1 表示全服活动奖品，2 表示个人活动奖品
                if result.type == 1 then

                elseif result.type == 2 then
                    sData = self:getSingleDataByNum(result.num)
                    if sData then
                        sData.prizeStatus = 2     --把状态置为已领取
                    end
                    --设置红点提示
                    -- local count = self:checkSingleCanGetCount()
                    -- datas["singleEventPoint"] = (count ~= 0)
                end
            end
        end

        --设置红点提示
        if code == 1 or code == -1 or code == -2 or code == -6 or code == -7 then
            if result_type == 1 then
                datas["fullEventPoint"] = false
            elseif result_type == 2 then
                local count = self:checkSingleCanGetCount()
                datas["singleEventPoint"] = (count ~= 0)
            end
        end
        -- 发送通知更新界面
        EventDispatcher.getInstance():dispatch(EventConstants.limitTimeEvent_prize_result, result_type, code,sData)

    end
end

function LimitTimeEventDataController:getSingleDataByNum(num)
    if self.singleEventArr then
        for k,v in pairs(self.singleEventArr) do 
            if v.num == num then
                return v
            end
        end
    end
    return {}
end
function LimitTimeEventDataController:checkSingleCanGetCount()
    local count = 0
    if self.singleEventArr then
        for k,v in pairs(self.singleEventArr) do 
            if v.prizeStatus == 1 then
                count = count + 1
            end
        end
    end
    return count
end

function LimitTimeEventDataController:getSingleEventArr()
    return self.singleEventArr or {}
end

function LimitTimeEventDataController:getAllEvent()
    return self.allEvent
end

function LimitTimeEventDataController:processData()
    ----[[
        --注入数据
        if self.m_eventData.single and self.m_eventData.single.prizeStatus then
            for k,v in pairs(self.m_eventData.single.prizeStatus) do 
                if self.singleEventArr then
                    local prize = self.singleEventArr[checkint(k)]
                    if prize then
                        local sobj = {}
                        sobj.counts = self.m_eventData.single.counts
                        sobj.prizeStatus = checkint(v)

                        prize:setData(sobj)
                    end
                end
            end
        end

        --设置红点提示
        local count = self:checkSingleCanGetCount()
        local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
        datas["singleEventPoint"] = (count ~= 0)

        self:onStartCountDownTimer()

        local isNeedAnim = false
        if self.m_eventData.all and self.allEvent and checkint(self.m_eventData.all.counts) < checkint(self.allEvent.num) then
            isNeedAnim = true
            self:onStartRefreshTimer()
        else
            nk.GCD.CancelById(self,self.m_fefreshTimer_id)
        end

        if not isNeedAnim then
            local status = nk.limitTimeEventDataController:getAllEventRewardStatus()
            if status == 0 then
                local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
                datas["fullEventPoint"] = true
            end
        end
        
        -- 发送通知更新界面
        EventDispatcher.getInstance():dispatch(EventConstants.update_limitTimeEvent_view, self.m_eventData, 1, isNeedAnim)

end

function LimitTimeEventDataController:getAllEventRewardStatus()
    local status = 0
    if self.m_eventData and self.m_eventData.all then
        status = self.m_eventData.all.prizeStatus or 0
    end
    return status
end

-- 开始倒计时
function LimitTimeEventDataController:onStartCountDownTimer()
    --如果配置重新下载了，这里会有时间差
    if self.startTime then
        local dt = os.time() - self.startTime
        self.m_eventData.expireTime = self.m_eventData.expireTime - dt
        if self.m_eventData.expireTime < 0 then
            self.m_eventData.expireTime = 0
        end
        self.startTime = nil
    end

    -- self.m_eventData.expireTime = 1234
    
    local day = nk.TimeUtil:getRemainDay(self.m_eventData.expireTime) 
    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
    datas["eventIsOpen"] = (self.m_eventData.expireTime > 0)
	if self.m_eventData.expireTime and self.m_eventData.expireTime >= 0 and day <= 1 then
		nk.GCD.CancelById(self,self.m_countDownTimer_id)
		self.m_countDownTimer_id = nk.GCD.PostDelay(self, function()
			if self.m_eventData.expireTime > 0 then
				self.m_eventData.expireTime = self.m_eventData.expireTime - 1
			else
				nk.GCD.CancelById(self,self.m_countDownTimer_id)
			end
            self:formatExpireTime(self.m_eventData.expireTime)
			Log.printInfo("onStartCountDownTimer")
            local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
            datas["eventIsOpen"] = (self.m_eventData.expireTime > 0)
	    end, nil, 1000, true)
	end
end

function LimitTimeEventDataController:reSetExpireTime(time)
    if self.m_eventData and time >= 0 then
        self.m_eventData.expireTime = time
    end
end

function LimitTimeEventDataController:formatExpireTime(time)
    if time < 0 then
        time = 0
    end

    local time_table = {}
    time_table.time = time
    time_table.time_str = nk.TimeUtil:getTimeString1(time) -- 00:00:00
    time_table.day = nk.TimeUtil:getRemainDay(time) 
    if self.allEvent and self.allEvent.etime and tonumber(self.allEvent.etime) >= 0 then
        time_table.time_end =  os.date("%y-%m-%d",self.allEvent.etime) -- 年-月-日
    else
        time_table.time_end =  "xx-xx-xx"
    end
    EventDispatcher.getInstance():dispatch(EventConstants.update_lTEvent_countDownTime, time_table)
end

-- 获取当前活动剩余时间
function LimitTimeEventDataController:getCurReleaseTimer()
	if self.m_eventData then
        local time = self.m_eventData.expireTime or -1
        self:formatExpireTime(time)
		return time
	else
		return -1
	end
end

-- 每隔一段时间请求一次，当前全服活动进度
function LimitTimeEventDataController:onStartRefreshTimer()
	nk.GCD.CancelById(self,self.m_fefreshTimer_id)
    if self:getPopupIsShow() then
    	self.m_fefreshTimer_id = nk.GCD.PostDelay(self, function()
    		self:getFullEventCounts()
    		Log.printInfo("onStartRefreshTimer")
        end, nil, 3500, true)
    end
end

function LimitTimeEventDataController:reset()
	nk.GCD.CancelById(self,self.m_fefreshTimer_id)

	if self.m_fefreshTimer_id then
		self.m_fefreshTimer_id = nil
	end
end

function LimitTimeEventDataController:setPopupIsShow(isShow)
    self.m_isShow = isShow
end

function LimitTimeEventDataController:getPopupIsShow()
    return self.m_isShow
end

return LimitTimeEventDataController



