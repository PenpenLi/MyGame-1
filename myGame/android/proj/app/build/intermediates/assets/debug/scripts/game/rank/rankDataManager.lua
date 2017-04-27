-- rankDataManager.lua
-- Last modification : 2016-06-20
-- Description: a manager in rank moudle, to manage all rank data
-- Offer Instance

local RankDataManager = class()

function RankDataManager.getInstance()
    if not RankDataManager.s_instance then
        RankDataManager.s_instance = new(RankDataManager)
    end
    return RankDataManager.s_instance
end

function RankDataManager:ctor()
	Log.printInfo("RankDataManager", "ctor")
    -- 加载各总排行榜列表状态
    self.m_isGetRankList_ing = {}
    self.m_loadCallback = {}
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpPorcesser);
end

function RankDataManager:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpPorcesser);
end

function RankDataManager:autoDispose()
    self.m_loadCallback = nil
    self.m_loadCallback = {}
end

function RankDataManager:loadRankData(type, page, callback)
    self.m_loadCallback[type] = callback
    if self.m_isGetRankList_ing[type] then  
        return
    end
    self.m_isGetRankList_ing[type] = true
    local param = {}
    param.mid = nk.userData.mid
    param.type = type
    param.page = page
    nk.HttpController:execute("getRankData", {game_param = param})
end

function RankDataManager:onGetRankDataBack(errorCode, data)
    Log.printInfo("RankDataManager", "RankDataManager.onGetRankDataBack")
    if errorCode == HttpErrorType.SUCCESSED then
        if data then
            local retData = data.data
            self.m_isGetRankList_ing[retData.type] = false
            if self.m_loadCallback[retData.type] then
                self:invokeCallback(self.m_loadCallback[retData.type], true, retData)
            end
        end
    else
        table.foreach(self.m_isGetRankList_ing, function(i, v)
                v = false
            end)
        table.foreach(self.m_loadCallback, function(i, v)
                self:invokeCallback(v, false)
            end)
        
    end
end

function RankDataManager:invokeCallback(callback, ...)
    if callback then
        callback(...)
    end
end

function RankDataManager:onHttpPorcesser(command, ...)
    Log.printInfo("RankDataManager", "RankDataManager.onHttpPorcesser");
    if not self.s_httpRequestsCallBack[command] then
        Log.printWarn("RankDataManager", "Not such request cmd in current controller command:" .. command);
        return;
    end
    self.s_httpRequestsCallBack[command](self,...); 
end

RankDataManager.s_httpRequestsCallBack = {
    ["getRankData"] = RankDataManager.onGetRankDataBack
}

return RankDataManager