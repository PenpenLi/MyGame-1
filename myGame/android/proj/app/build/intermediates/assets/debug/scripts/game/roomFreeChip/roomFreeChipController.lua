

local RoomFreeChipController = class()

function RoomFreeChipController:ctor(boxData)
    self.isFinished = false
    self.remainTime = 0
    self.reward = 0
    self.boxStatus_ = -1

    self.boxData = {}
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function RoomFreeChipController:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function RoomFreeChipController:setBoxData(boxData)
    if boxData then
        self.isFinished = boxData.isFinished or false
        self.remainTime = tonumber(boxData.remainTime or 0) 
        self.reward = tonumber(boxData.reward or 0)
    end
    self:setBoxStatus()
end

function RoomFreeChipController:getBoxData() 
    self.boxData.isFinished = self.isFinished or false
    self.boxData.remainTime = self.remainTime or 0
    self.boxData.reward = self.reward or 0
    self.boxData.boxStatus_ = self.boxStatus_ or -1
    return self.boxData
end

function RoomFreeChipController:setBoxStatus() 
    if self.isFinished then
        self.boxStatus_ = 1
    elseif not self.isFinished and self.remainTime and self.remainTime <= 0  then
        self.boxStatus_ = 2
    else
        self.boxStatus_ = 3
    end

    EventDispatcher.getInstance():dispatch(EventConstants.refreshBoxView)
end

function RoomFreeChipController:requestGetChest()
    local params = {}
    nk.HttpController:execute("getCountDownBoxReward", {game_param = params})
end

function RoomFreeChipController:onHttpProcesser(command, errorCode, data)
    if command == "getCountDownBoxReward" then
        if errorCode == 1 and data and data.code == 1 then
            local callData = data.data
            nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_REWARD)
            if callData then
                self.isFinished = callData.nextTime <= 0 and callData.nextMoney == 0
                self.remainTime = callData.nextTime
                self.reward = callData.nextMoney
                if self.setBoxStatus then
                    self:setBoxStatus()
                end

                EventDispatcher.getInstance():dispatch(EventConstants.getRFCBoxRewardSucc, callData)
            end
        elseif data then
            local errData = data.data
            if errData and type(errData) == "table" and errData.errorCode then
                if errData.errorCode == -1 then
                    --已经全部领取完
                    self.isFinished = true
                    self.remainTime = 0
                elseif errData.errorCode == -3 then
                    --时间未到，校正时间
                    local retData = errData.retData
                    self.remainTime = retData.data.nextTime
                    if self.setBoxStatus then
                        self:setBoxStatus()
                    end

                    EventDispatcher.getInstance():dispatch(EventConstants.getRFCBoxRewardFail, errData)
                end
            end
        end
    end
end

return RoomFreeChipController