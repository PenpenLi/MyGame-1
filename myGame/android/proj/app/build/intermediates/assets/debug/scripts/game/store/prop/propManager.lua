-- propManager.lua
-- Last modification : 2016-06-12
-- Description: a manager in prop moudle, to manage all prop type in store
-- Offer Instance

local StoreConfig = require("game.store.storeConfig")
local PropManager = class()
local CacheHelper = require("game.cache.cache")

PropManager.TYPE_GIFT = 0
PropManager.TYPE_PROP = 1

PropManager.ID_MONKEY_EXP = 4001

function PropManager.getInstance()
    if not PropManager.s_instance then
        PropManager.s_instance = new(PropManager)
    end
    return PropManager.s_instance
end

function PropManager:ctor()
    self.m_loadCallbacks = {}
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpPorcesser);
end

function PropManager:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpPorcesser);
end

function PropManager:autoDispose()
    self.m_loadCallbacks = {}
    self.m_buyPropCallback = nil
    self.m_buyGiftCallback = nil
end

function PropManager:requestUserPropList(callback, useOldData)
    self:loadConfig(function(status)
        if status then
            if useOldData and self.propList then
                callback(true, self.propList)
                return
            end
            nk.HttpController:execute("getUserProps", {game_param = {}}, nil, function(code, data)
                if code ~= HttpErrorType.SUCCESSED or not data or data.code ~= 1 then
                    callback(false)
                else
                    self.propList = data.data or {}
                    callback(true, self.propList)
                end
            end)
        else
            callback(false)
        end
    end)
end

function PropManager:loadConfig(callback)
    -- Log.printInfo("PropManager", "loadConfig");
    if self.m_propConfig then
        self:getPropListById(1, function(status)
            callback(status, self.m_propConfig)
        end)
    else
        table.insert(self.m_loadCallbacks, function(status)
            if status then
                self:getPropListById(1, function(status)
                    callback(status, self.m_propConfig)
                end)
            else
                callback(status)
            end
        end)
        if not self.isLoading then
            self.isLoading = true
            nk.HttpController:execute("getPropTypeConfig", {game_param = {ver = GameConfig.CUR_VERSION}})
        end
    end
end

function PropManager:setUserPropList(propList)
    self.propList = propList
end

function PropManager:getUserPropList()
    assert(self.propList, "please init self.propList first")
    return self.propList
end

function PropManager:getUserPropInfo(pnid)
    pnid = tonumber(pnid)
    -- assert(self.propList, "please init self.propList first")
    if self.propList then
        for i = 1, #self.propList do
            if tonumber(self.propList[i].pnid) == pnid then
                return self.propList[i]
            end
        end
    end
    return nil
end

function PropManager:onGetPropConfigCallBack(errorCode, data)
    self.isLoading = false
    local status = false
    if errorCode == HttpErrorType.SUCCESSED and data and data.code == 1 then
        self.m_propConfig = data.data
        status = true
    end
    if self.m_loadCallbacks then
        for i = 1, #self.m_loadCallbacks do
            local callback = self.m_loadCallbacks[i]
            if callback then
                callback(status, self.m_propConfig)
            end
        end
        self.m_loadCallbacks = {}
    end
end

-- 根据道具类型获得对应道具类型的配置 : 0 Gift or 1 Megafon喇叭
function PropManager:getPropConfigById(propType)
    if self.m_propConfig then
        for i, v in ipairs(self.m_propConfig) do
            if v.id == propType then
                return v
            end
        end
    end
    return nil
end

function PropManager:getPropConfigByPnid(propType, pnid)
    pnid = tonumber(pnid)
    assert(self["propConfigs" .. propType], "prop list is not loaded!")
    local configList = self["propConfigs" .. propType]
    for j = 1, #configList do
        if tonumber(configList[j].pnid) == pnid then
            return configList[j]
        end
    end
    return nil
end

-- 根据道具类型获得对应道具列表 propId: 道具类型
function PropManager:getPropListById(propType, callback)
    local propfig = self:getPropConfigById(propType)
    if propfig then
        if self["propConfigs" .. propType] then
            callback(true, propType, self["propConfigs" .. propType])
        else
            local cacheHelper = new(CacheHelper)
            cacheHelper:cacheFile(propfig.configUrl, function(status, content)
                    if status then
                        self["propConfigs" .. propType] = content
                    end
                    if callback then
                        callback(status, propType, content)
                    end
                end)
        end
    else
        if callback then
            callback(false)
        end
    end
end

-- 购买道具
function PropManager:buyProp(pnid, num, callback)
    Log.printInfo("PropManager", "buyProp")
    self.m_buyPropCallback = callback 
    if self.m_isBuying then
        return
    end
    self.m_isBuying = true
    nk.HttpController:execute("buyProp", {game_param = {mid = nk.userData.mid, pnid = pnid, num = num}})
end

function PropManager:onBuyPropCallBack(errorCode, data)
    -- Log.printInfo("PropManager", "PropManager.onBuyPropCallBack")
    self.m_isBuying = false
    if self.m_buyPropCallback then
         self.m_buyPropCallback()
    end
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local retData = data.data
            if retData and retData.money then
                local money = checkint(retData.money)
                if money and money>=0 then
                    nk.functions.setMoney(money)
                    nk.SocketController:synchroUserInfo()
                end
            end
            nk.AnalyticsManager:report("New_Gaple_prop_buy", "store")
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "BUY_SUCC_MSG"))
        end
    else
        
    end
end

-- 购买道具
function PropManager:buyGift(pnid, num, callback)
    Log.printInfo("PropManager", "buyProp")
    self.m_buyGiftCallback = callback
    if self.m_isBuying then
        return
    end
    self.m_isBuying = true

    local params = {}
    params.pnid = pnid
    params.fid = nk.userData.uid
    nk.HttpController:execute("buyGift", {game_param = params})
end

function PropManager:onBuyGiftCallBack(errorCode, data)
    Log.printInfo("PropManager", "PropManager.onBuyGiftCallBack")
    self.m_isBuying = false
    if self.m_buyGiftCallback then
        self.m_buyGiftCallback()
    end
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local money = checkint(data.data.money)
            local subMoney = checkint(data.data.subMoney)

            if money and money>=0 then
                nk.functions.setMoney(money)
            end
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_SUCCESS_TOP_TIP"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_FAIL_TOP_TIP"))
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_FAIL_TOP_TIP"))
    end
end

function PropManager:onHttpPorcesser(command, ...)
    Log.printInfo("PropManager", "PropManager.onHttpPorcesser");
    if not self.s_httpRequestsCallBack[command] then
        Log.printWarn("PropManager", "Not such request cmd in current controller command:" .. command);
        return;
    end
    self.s_httpRequestsCallBack[command](self,...); 
end

-- 道具合成
function PropManager:syntProp(pnidOfTarget, callback)
    nk.HttpController:execute("Props.syntProp", {game_param = {mid = nk.userData.uid, pnid = pnidOfTarget}}, nil, function(code, data)
            local status = code == HttpErrorType.SUCCESSED and data.code == 1
            if status then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_SYNTPROP_SUCCESS"))
            else
                if data and data.codemsg and data.codemsg ~= "" then
                    nk.TopTipManager:showTopTip(data.codemsg)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_SYNTPROP_FAIL"))
                end
            end
            if callback then callback(status) end
            -- 通知物品刷新事件
            if status then
                self:requestUserPropListWithEvent()
            end
        end)
end

function PropManager:exchProp(pnid, info, callback)
    nk.HttpController:execute("Props.exchProp", {game_param = {mid = nk.userData.uid, pnid = pnid, info = info}}, nil, function(code, data)
            local status = code == HttpErrorType.SUCCESSED and data.code == 1
            if status then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_EXCHANGE_SUCCESS"))
            else
                if data and data.codemsg and data.codemsg ~= "" then
                    nk.TopTipManager:showTopTip(data.codemsg)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_EXCHANGE_FAIL"))
                end
            end
            if callback then callback(status) end
            -- 通知物品刷新事件
            if status then
                self:requestUserPropListWithEvent()
            end
        end)
end

function PropManager:sendProp(pnid, to, callback)
    local record = self:getSendPropRecordToday()
    local conf = self:getPropConfigById(1)
    -- FwLog("conf >>>>>>>>>>>>>" .. json.encode(conf))
    if checkint(record.cnt) >= checkint(conf.sendNum) and (record.date == os.date("%x")) then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_TO_MUCH_TIME"))
        callback(false)
        return
    end 
    nk.HttpController:execute("Props.sendProp", {game_param = {mid = nk.userData.uid, pnid = pnid, to = to}}, nil, function(code, data)
            local status = code == HttpErrorType.SUCCESSED and data.code == 1
            if status then
                nk.AnalyticsManager:report("New_Gaple_sendprop_succ")
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_SUCCESS"))
                if data.data and type(data.data.nowMoney) == "number" then
                    nk.userData.money = data.data.nowMoney
                end
            else
                if data and data.codemsg and data.codemsg ~= "" then
                    nk.TopTipManager:showTopTip(data.codemsg)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_FAIL"))
                end
            end
            local record = self:getSendPropRecordToday()
            local date = os.date("%x")
            if record.date == date then
                record.cnt = checkint(record.cnt) + 1
            else
                record.date = date
                record.cnt = 1
            end
            self:saveSendPropRecordToday()
            if callback then callback(status) end
            -- 通知物品刷新事件
            if status then
                self:requestUserPropListWithEvent()
            end
        end)
end

function PropManager:loadSyntConf(callback)
    if not self.syntConf then
        if not self.isSyntConfLoading then
            if nk.OnOff:checkLocalVersion("syntver") then
                --获取本地的缓存
                FwLog("syntver is the same!!!!!")
                local data = nk.DataProxy:getData(nk.dataKeys.SYNT_PROP_CONF)
                if data then
                    self.syntConf = data
                    if callback then callback(true, self.syntConf) end
                    return
                end
            end
            self.isSyntConfLoading = true
            nk.HttpController:execute("Props.syntConf", {game_param ={mid = nk.userData.uid}}, nil, function(code, data)
                self.isSyntConfLoading = nil
                local status = code == HttpErrorType.SUCCESSED and data.code == 1 and data.data
                if status then 
                    self.syntConf = data.data
                    nk.DataProxy:setData(nk.dataKeys.SYNT_PROP_CONF, self.syntConf)
                    nk.DataProxy:cacheData(nk.dataKeys.SYNT_PROP_CONF)
                    nk.OnOff:saveNewVersionInLocal("syntver")
                end
                -- FwLog("PropManager:loadSyntConf >>" ..json.encode(self.syntConf))
                if callback then callback(status, self.syntConf) end
                if self.waitingSyntConfCallbackList then
                    for i = 1, #self.waitingSyntConfCallbackList do
                        self.waitingSyntConfCallbackList[i](status, self.syntConf)
                    end
                end
                self.waitingSyntConfCallbackList = nil
            end)
        else
            self.waitingSyntConfCallbackList = self.waitingSyntConfCallbackList or {}
            table.insert(self.waitingSyntConfCallbackList, callback)
        end
    else
        if callback then callback(true, self.syntConf) end
    end
end

function PropManager:isPropSyntable(pnid)
    pnid = tonumber(pnid)
    assert(self.syntConf, "synt config is missing")
    -- local userProp = self:getUserPropInfo(pnid)
    -- local configProp = self:getPropConfigByPnid(1, pnid)
    for i = 1, #self.syntConf.info do
        local eachSyntConf = self.syntConf.info[i]
        if tonumber(eachSyntConf.pnid) == pnid then
            for j = 1, #eachSyntConf.synt do
                local material = eachSyntConf.synt[j]
                local materialProp = self:getUserPropInfo(material.pnid)
                local ownPropCnt = 0
                if materialProp then
                    ownPropCnt = tonumber(materialProp.pcnter) or 1
                end
                local newCnt = tonumber(material.num) or 1
                if newCnt > ownPropCnt then return false end
            end
        end
    end
    return false
end

function PropManager:requestUserPropListWithEvent()
    self:requestUserPropList(function(status, data)
        if status then
            EventDispatcher.getInstance():dispatch(EventConstants.PROP_INFO_CHANGED, data)
        end
    end)
end

-- 判断是否过期
function PropManager:isPropValid(pnid)
    local prop = self:getUserPropInfo(pnid)
    if prop and prop.pexpire then
        return checkint(prop.pexpire) > os.time()
    elseif prop then  
        return true
    else
        return false
    end
end

-- 获取今天赠送道具的次数
function PropManager:getSendPropRecordToday()
    if not self.recordOfSendProp then
        self.recordOfSendProp = nk.DataProxy:getData(nk.dataKeys.SEND_PROP_INFO) or {}
    end
    return self.recordOfSendProp
end

-- 保存一次赠送道具的记录
function PropManager:saveSendPropRecordToday()
    if self.recordOfSendProp then
        nk.DataProxy:setData(nk.dataKeys.SEND_PROP_INFO, self.recordOfSendProp)
        nk.DataProxy:cacheData(nk.dataKeys.SEND_PROP_INFO)
    end
end

PropManager.s_httpRequestsCallBack = {
    ["getPropTypeConfig"] = PropManager.onGetPropConfigCallBack,
    ["buyProp"] = PropManager.onBuyPropCallBack,
    ["buyGift"] = PropManager.onBuyGiftCallBack,
}

return PropManager
