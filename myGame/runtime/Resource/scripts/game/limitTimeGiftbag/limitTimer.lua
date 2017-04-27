--
-- Author: melon
-- Date: 2016-10-17 16:48:54
--
local LimitTimer = class()

LimitTimer.delayTime = 60  --限时礼包延长展示时间:单位s

function LimitTimer.getInstance()
	if not LimitTimer.instance then 
		LimitTimer.instance = new(LimitTimer)
	end
	return LimitTimer.instance
end

function LimitTimer.releaseInstance()
	delete(LimitTimer.instance);
	LimitTimer.instance = nil;
end

function LimitTimer:ctor()
	self.time = 0
	self.nowTime = 0
	self.deltaTime = 0
	self.timeTextList = {}
	EventDispatcher.getInstance():register(Event.Resume, self, self.resume)
    EventDispatcher.getInstance():register(Event.Pause, self, self.pause)
    self.duringDelay = false   -- 是否处于延迟期间
end


function LimitTimer:dtor()
	self.time = 0
	self.nowTime = 0
	self.deltaTime = 0
	self.timeTextList = {}
	self:cancelSchedule()
	EventDispatcher.getInstance():unregister(Event.Resume, self, self.resume)
    EventDispatcher.getInstance():unregister(Event.Pause, self, self.pause)
    self.duringDelay = false 
end

function LimitTimer:pause()
	self.nowTime = os.time()

    if nk.limitInfo then
        nk.DictModule:setString("gameData", "limitTag", nk.limitInfo.limId or "0")
    end    
    nk.DictModule:setInt("gameData", "logoutTime", os.time() or 0)
    nk.DictModule:setInt("gameData", "remainingTime", self.time or 0)
    nk.DictModule:saveDict("gameData")
end

function LimitTimer:resume()
	self.deltaTime = os.time() - self.nowTime
end

function LimitTimer:addTimeText(text)
    if self.duringDelay then
        text:setText(formatTime(0))
    else
        local time = (self.time - LimitTimer.delayTime <= 0) and 0 or (self.time - LimitTimer.delayTime)
        text:setText(formatTime(time))
    end
	
    if text and not self:isContain(text) then
		table.insert(self.timeTextList,text)
	end
end

function LimitTimer:isContain(text)
    local isContain = false
    for k,v in pairs(self.timeTextList) do
        if text==v then
            isContain = true
            break
        end
    end
    return isContain
end

function LimitTimer:removeTimeText(text)
	for k,v in pairs(self.timeTextList) do
		if text==v then
			table.remove(self.timeTextList,k)
			break
		end
	end
end

function LimitTimer:getTime()
	return self.time
end

function LimitTimer:setTime(time)
    if self.duringDelay then    
        self.time = time 
    else 
        self.time = time + LimitTimer.delayTime
    end
end

function LimitTimer:cancelSchedule()
	if self.schedule then
        self.schedule:cancel()
        self.schedule = nil
    end
end

function LimitTimer:startSchedule()
	self:cancelSchedule()
    self.schedule = Clock.instance():schedule(function(dt)
    	if self.time > 1+self.deltaTime  then
    		self.time = self.time - 1 - self.deltaTime
            self.deltaTime = 0
            if self.time == LimitTimer.delayTime then 
                self.duringDelay = true
            end
    		for k,v in pairs(self.timeTextList) do
				if not tolua.isnull(v) then
                    if self.duringDelay then
                        v:setText(formatTime(0))
                    else
                        local time = (self.time - LimitTimer.delayTime <= 0) and 0 or (self.time - LimitTimer.delayTime)
                        v:setText(formatTime(time))
                    end
                else
                    self:removeTimeText(v)    
				end
			end
   		else
   			self:close()
    	end
    end, 1)
end

function LimitTimer:close(isBuySuccess)
    EventDispatcher.getInstance():dispatch(EventConstants.close_limit_time_giftbag,isBuySuccess or false)
    self:dtor()
end

return LimitTimer   