--
-- Author: melon
-- Date: 2016-11-30 15:08:15
--
local LotteryController = class()

function LotteryController:ctor()
   
end

function LotteryController:loadConfig(url,callback)
    if not self.isConfigLoaded then 
        local cacheHelper = new(require("game.cache.cache"))
        cacheHelper:cacheFile(url or nk.userData.LOTTERY_CONFIG, handler(self, function(obj, result, content)
                if result then
                    self.isConfigLoaded = true
                    self.lotteryData = content
                    EventDispatcher.getInstance():dispatch(EventConstants.getLotteryConfig,content)
                    if callback then
                        callback()
                    end
                end
            end), "lotteryConfig", "data")   
    end
end

function LotteryController:loadNewConfig(view)
    nk.HttpController:execute("WinLottery.getConfig", {game_param = {mid = nk.userData.uid}}, nil, handler(self, function (obj, errorCode, data)
        if errorCode==1 and data and data.data then
            if nk.userData.LOTTERY_CONFIG~=data.data.json then
                nk.userData.LOTTERY_CONFIG = data.data.json
                self.isConfigLoaded = false
                if not tolua.isnull(view) then
                    view:setLoading(true)
                end
                self:loadConfig()
            end
            nk.lotteryTimes = data.data.times or 0
            nk.lotteryCounts = data.data.counts or 0
            EventDispatcher.getInstance():dispatch(EventConstants.updateLotteryTimes,nil)
            if not tolua.isnull(view) then
                view:updateGetLotteryTimes()
            end
        end
    end ))
end

function LotteryController:runLottery(view)
    nk.HttpController:execute("WinLottery.runLottery", {game_param = {mid = nk.userData.uid}}, nil, handler(self, function (obj, errorCode, data)  
        if errorCode==1 and data and data.data then
            nk.lotteryTimes = data.data.times or 0
            EventDispatcher.getInstance():dispatch(EventConstants.updateLotteryTimes,nil)
            if data.data.money then
                nk.functions.setMoney(tonumber(data.data.money))
            end
            local function lottery( ... )
                if not tolua.isnull(view) then
                    view:onGetlotteryResult(data.code,data.data.pid)
                end
            end
            if data.data.json and nk.userData.LOTTERY_CONFIG~=data.data.json then
                nk.userData.LOTTERY_CONFIG = data.data.json
                self.isConfigLoaded = false
                self:loadConfig(data.data.json,lottery)
            else
                lottery()
            end
        end
    end ))
end

function LotteryController:dtor()
    self.view = nil
end

function LotteryController:loadLotteryConfig()
    local ver = nk.DictModule:getString("gameData", "lotteryConfigVer", "")
end

return LotteryController