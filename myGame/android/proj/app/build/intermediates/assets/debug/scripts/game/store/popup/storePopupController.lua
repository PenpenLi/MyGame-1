-- storePopupController.lua
-- Last modification : 2016-06-12
-- Description: a controller in Store moudle

local StorePopupController = class()
local CacheHelper = require("game.cache.cache")
local PayManager = require("game.store.pay.payManager")
local PropManager = require("game.store.prop.propManager")
local HistoryManager = require("game.store.history.historyManager")
local StorePopupData = require("game.store.popup.storePopupData")

function StorePopupController:ctor(view, isRoom, level)
    Log.printInfo("StorePopupController.ctor");
    self.m_view = view
    self.m_isRoom = isRoom
    self.m_roomLevel = level
    self.m_baseData = new(StorePopupData)
    view.m_baseData = self.m_baseData
    -----------
    -- 标记字段
    -----------

    -- 加载paytype支付类型
    self.m_isLoadPayType_ing = false
    self.m_isLoadPayType_ed = false
    -- 加载各paytyep支付类型对应的商品
    self.m_isLoadGoods_ing = {}
    self.m_isLoadGoods_ed = {}
    -- 加载道具类型
    self.m_isLoadPropType_ing = false
    self.m_isLoadPropType_ed = false
    -- 加载各道具类型对应的道具
    self.m_isLoadProp_ing = {}
    self.m_isLoadProp_ed = {}
    -- 加载历史
    self.m_isLoadHistory_ing = false
    self.m_isLoadHistory_ed = false

    -----------
    -- 标记字段 end
    -----------

    self.m_payManager = PayManager.getInstance()

    self.m_propManager = PropManager.getInstance()

    self.m_historyManager = HistoryManager.getInstance()

    for i, v in pairs(self.s_eventHandle) do
        EventDispatcher.getInstance():register(i, self, v);
    end
end

function StorePopupController:dtor()
    for i, v in pairs(self.s_eventHandle) do
        EventDispatcher.getInstance():unregister(i, self, v);
    end
    -- 这里会导致报错，先屏蔽
    -- delete(self.m_baseData)
    -- self.m_baseData = nil
    self.m_payManager:autoDispose()
    self.m_propManager:autoDispose()
    self.m_historyManager:autoDispose()
end

-------------------------------- private function --------------------------

-- 加载支付类型配置
function StorePopupController:loadPayConfig()
    Log.printInfo("StorePopupController:loadPayConfig..")
    self.m_retryTimes = 3
    if self.m_isLoadPayType_ing then
        return
    end
    self.m_isLoadPayType_ing = true
    nk.HttpController:execute("getPayTypeConfig", {game_param = {apkVer = GameConfig.CUR_VERSION}})
end

-- 根据支付类型发起购买
function StorePopupController:buyGoods(paytypeId, pid, goodData)
    local pay = self.m_payManager:getPay(paytypeId)
    pay:makeBuy(pid, goodData)
end

-- 加载道具类型配置
function StorePopupController:loadPropConfig()
    self.m_isLoadPropType_ing = true
    self.m_propManager:loadConfig(handler(self, self.onLoadPropConfigCallBack))
end

-- 购买道具
function StorePopupController:buyProp(pnid, num)
    self.m_propManager:buyProp(pnid, num)
end

-- 购买礼物
function StorePopupController:buyGift(pnid, num)
    self.m_propManager:buyGift(pnid, num)
end

function StorePopupController:gotoTab(index)
    self:updateView("gotoTab", index)
end

function StorePopupController:checkKoinIsEnough(cost, propType)
    local isEnough = true
    if cost then
        -- if nk.functions.getMoney() - tonumber(cost) < 0 then
        --     isEnough = false
        -- end
        if not nk.functions.checkMoneyisEnough(1,self.m_isRoom,self.m_roomLevel,tonumber(cost)) then
            isEnough = false
        end
    else
        isEnough = false
    end
    local function toChangeMainTab()
        if self then
            self:gotoTab(1)
        end
    end

    local tips = ""
    if propType == "prop" then
        tips = bm.LangUtil.getText("STORE", "BUY_FAIL_MSG") 
    elseif propType == "gift" then
        tips = bm.LangUtil.getText("STORE", "BUY_FAIL_MSG_1") 
    end

    if not isEnough then
        local args = {
            hasCloseButton = true,
            messageText = tips,  
            callback = function (type)
                if type == nk.Dialog.SECOND_BTN_CLICK then
                    toChangeMainTab()
                end
            end
        }
        nk.PopupManager:addPopup(nk.Dialog,"enterRoomManager",args)
    end
    return isEnough
end

function StorePopupController:loadStoreNotice()
    local cacheHelper = new(CacheHelper)
    cacheHelper:cacheFile(nk.userData.STORE_NOTICE_JSON, handler(self, function(obj, result, content)
            if not tolua.isnull(self.m_view) and result then
                self:updateView("playNotice", content)
            end
        end), "storeNotice", "data")
end
-------------------------------- handle function --------------------------

 -- 加载支付配置后，初始化Manager
function StorePopupController:onLoadPayConfigCallBack(status, data)
    Log.printInfo("StorePopupController:onLoadPayConfigCallBack")
    self.m_isLoadPayType_ing = false
    if data and data.code == 1 then
        data = data.data
        self.m_isLoadPayType_ed = true
        if data then
            local payTypeAvailable = {}
            local payTypeAvailableId = {}
            for i, p in ipairs(data) do
                if self.m_payManager:isPayAvailable(p.id) then
                    payTypeAvailable[#payTypeAvailable + 1] = p
                    payTypeAvailableId[#payTypeAvailableId + 1] = p.id
                end
            end           
            -- init payManager                                                                                                                                               
            self.m_payManager:init(payTypeAvailable)
            self.m_baseData:setPayTypeAvailableData(payTypeAvailable)
            self:updateView("updatePayTypeList", payTypeAvailable)
        else
            self:updateView("showNoDataTip")
        end
    else
        self.m_retryTimes = self.m_retryTimes - 1
        if self.m_retryTimes > 0 then
            self:loadPayConfig()
        else
            self:updateView("showNoDataTip")
        end
    end
end

 -- 加载paytype对应的金币列表
function StorePopupController:onLoadChipProductList(paytypeId)
    Log.printInfo("StorePopupController:onLoadChipProductList")
    if self.m_isLoadPayType_ed then
        local pay = self.m_payManager:getPay(paytypeId)
        Log.dump(self.m_isLoadGoods_ing)
        self.m_isLoadGoods_ing[paytypeId] = true
        pay:loadChipProductList(handler(self, self.loadChipProductListResult))
    else
        self:loadPayConfig()
    end
end

function StorePopupController:loadChipProductListResult(status, paytype, data)
    Log.printInfo("StorePopupController:loadChipProductListResult")
    if status then
        self.m_isLoadGoods_ing[paytype.id] = false
        self.m_isLoadGoods_ed[paytype.id] = true
        self.m_baseData:setGoodsData(paytype.id, data)
        self:updateView("updateGoodsList", paytype)
    end
end

-- 加载道具配置回调
function StorePopupController:onLoadPropConfigCallBack(status, data)
    Log.printInfo("StorePopupController:onLoadPropConfigCallBack")
    self.m_isLoadPropType_ing = false
    if status then
        self.m_isLoadPropType_ed = true
        self:updateView("updatePropTypeList", data)
    else
        self:updateView("showNoDataTip")
    end
end

 -- 加载道具列表
function StorePopupController:onLoadPropProductList(proptypeId)
    if self.m_isLoadProp_ed[proptypeId] then
        self:updateView("updatePropList", self.m_baseData:getPropData(proptypeId))
        return
    end
    if self.m_isLoadPropType_ed then
        self.m_isLoadProp_ing[proptypeId] = true
        self.m_propManager:getPropListById(proptypeId, handler(self, self.loadPropProductListResult))
    else
        self:loadPropConfig()
    end
end

function StorePopupController:loadPropProductListResult(status, paytypeId, data)
    self.m_isLoadProp_ing[paytypeId] = false
    if status then
        self.m_isLoadProp_ed[paytypeId] = true
        self.m_baseData:setPropData(paytypeId, data)
        self:updateView("updatePropList", self.m_baseData:getPropData(paytypeId))
    end
end

 -- 加载购买列表
function StorePopupController:onLoadHistoryList(proptypeId)
    self.m_historyManager:loadHistory(handler(self, self.loadHistoryListResult))
end

function StorePopupController:loadHistoryListResult(status, data)
    if status then
        self.m_baseData:setHistoryData(data)
        self:updateView("updateHistoryList", data)
    end
end

-------------------------------- event listen ------------------------

function StorePopupController:onStoreBuyEvent(tag, pid, goodData, cost)
    Log.printInfo("StorePopupController onStoreBuyEvent")
    if tag == "BUY_GOODS" then
        local payId = self.m_baseData:getPayViewId()
        if payId then
            self:buyGoods(payId, pid, goodData)
        end
    elseif tag == "BUY_PROP" then
        if self:checkKoinIsEnough(cost,"prop") then
            self:buyProp(pid, goodData)
        end
    elseif tag == "BUY_GIFT" then
        if self:checkKoinIsEnough(cost,"gift") then
            self:buyGift(pid, goodData)
        end
    end
end

-------------------------------- native event -----------------------------

function StorePopupController:pickCallBack()
    Log.printInfo("StorePopupController","pickCallBack")
end

-------------------------------- table config ------------------------
-- Provide cmd handle to call
StorePopupController.s_cmdHandleEx = 
{
    ["loadChipProductList"] = StorePopupController.onLoadChipProductList,
    ["loadPropProductList"] = StorePopupController.onLoadPropProductList,
    ["loadHistoryList"] = StorePopupController.onLoadHistoryList,
};

-- Event to register and unregister
StorePopupController.s_eventHandle = {
    [EventConstants.httpProcesser] = GameBaseController.onHttpPorcesser,
    [EventConstants.storeBuyEvent] = StorePopupController.onStoreBuyEvent,
};

-- http回调事件
StorePopupController.s_httpRequestsCallBack = {
    ["getPayTypeConfig"] = StorePopupController.onLoadPayConfigCallBack
}

-------------------------------- ****private config*** ------------------------

function StorePopupController:onHttpPorcesser(command, ...)
    Log.printInfo("gameBase", "StorePopupController.onHttpPorcesser");
    if not self.s_httpRequestsCallBack[command] then
        Log.printWarn("gameBase", "Not such request cmd in current controller");
        return;
    end
    self.s_httpRequestsCallBack[command](self,...); 
end

function StorePopupController:handleCmdEx(cmd, ...)
    if not self.s_cmdHandleEx[cmd] then
        Log.printWarn("gameBase", "Controller, no such cmd in s_cmdHandleEx");
        return;
    end

    return self.s_cmdHandleEx[cmd](self,...)
end

-- @Override
function StorePopupController:updateView(cmd, ...)
    if not self.m_view then
        return;
    end

    return self.m_view:handleCmdEx(cmd,...);
end

return StorePopupController