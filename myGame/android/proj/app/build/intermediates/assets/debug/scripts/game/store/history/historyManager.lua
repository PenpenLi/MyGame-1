-- historyManager.lua
-- Last modification : 2016-06-12
-- Description: a manager in history moudle, to manage all history in store
-- Offer Instance

local StoreConfig = require("game.store.storeConfig")
local HistroyManager = class()

function HistroyManager.getInstance()
    if not HistroyManager.instance_ then
        HistroyManager.instance_ = new(HistroyManager)
    end
    return HistroyManager.instance_
end

function HistroyManager:ctor()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpPorcesser);
    EventDispatcher.getInstance():register(EventConstants.message_buy_gold, self, self.buySucc)
end

function HistroyManager:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpPorcesser);
    EventDispatcher.getInstance():unregister(EventConstants.message_buy_gold, self, self.buySucc)
end

function HistroyManager:buySucc(succ)
    self:clearData()
end

function HistroyManager:autoDispose()
    self.m_loadCallback = nil
end


function HistroyManager:loadHistory(callback)
    Log.printInfo("HistroyManager", "loadHistory");
    self.m_loadCallback = callback
    if not self.m_historyData then
        nk.HttpController:execute("getStoreHistory", {game_param = {}})
    else
        if self.m_loadCallback then
            self.m_loadCallback(true, self.m_historyData)
        end
    end
end

function HistroyManager:onGetHistoryCallBack(errorCode, data)
    Log.printInfo("HistroyManager", "onGetPropTypeConfigCallBack")
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            self.m_historyData = data.data.list
--            for i=1 , 3 do
--                local itemData = {}
--                itemData.count = 1
--                itemData.detail = "10KION"
--                itemData.status = 1
--                itemData.created = 100000
--                table.insert(self.m_historyData, itemData)
--            end
            if self.m_loadCallback then
                self.m_loadCallback(true, self.m_historyData)
            end
        end
    end
end

-- 当支付成功后，需要重新拉取数据，所以清除数据
function HistroyManager:clearData()
    Log.printInfo("HistroyManager", "clearData")
    self.m_historyData = nil
end

function HistroyManager:onHttpPorcesser(command, ...)
    Log.printInfo("HistroyManager", "HistroyManager.onHttpPorcesser");
    if not self.s_httpRequestsCallBack[command] then
        Log.printWarn("HistroyManager", "Not such request cmd in current controller command:" .. command);
        return;
    end
    self.s_httpRequestsCallBack[command](self,...); 
end

HistroyManager.s_httpRequestsCallBack = {
    ["getStoreHistory"] = HistroyManager.onGetHistoryCallBack
}

return HistroyManager
