-- storeController.lua
-- Last modification : 2016-06-12
-- Description: a controller in Store moudle

local StoreController = class(GameBaseController);
local CacheHelper = require("game.cache.cache")
local PayManager = require("game.store.pay.payManager")
local PropManager = require("game.store.prop.propManager")
local HistoryManager = require("game.store.history.historyManager")

function StoreController:ctor(state, viewClass, viewConfig, dataClass)
	Log.printInfo("StoreController.ctor");
    self.m_state = state;
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

	self:loadPayConfig()
end

function StoreController:resume()
    Log.printInfo("StoreController.resume");
	GameBaseController.resume(self);
--	self:updateView("updatePayTypeList", data)
--	self:updateView("updateGoodsTypeList", data)
--	self:updateView("updateGoodsList", data)
    
end

function StoreController:pause()
    Log.printInfo("StoreController.pause");
	GameBaseController.pause(self);
end

function StoreController:dtor()
    self.m_payManager:autoDispose()
    self.m_propManager:autoDispose()
    self.m_historyManager:autoDispose()
end

-------------------------------- private function --------------------------

-- Provide state to call
function StoreController:onBack()
    StateMachine.getInstance():popState();
end

-- 加载支付类型配置
function StoreController:loadPayConfig()
    Log.printInfo("StoreController:loadPayConfig..")
    self.m_retryTimes = 3
    if self.m_isLoadPayType_ing then
        return
    end
    self.m_isLoadPayType_ing = true
    nk.HttpController:execute("getPayTypeConfig", {game_param = {apkVer = GameConfig.CUR_VERSION}})
end

-- 根据支付类型发起购买
function StoreController:buyGoods(paytypeId, pid, goodData)
    local pay = self.m_payManager:getPay(paytypeId)
    pay:makeBuy(pid, goodData)
end

-- 加载道具类型配置
function StoreController:loadPropConfig()
    self.m_isLoadPropType_ing = true
    self.m_propManager:loadConfig(handler(self, self.onLoadPropConfigCallBack))
end

-- 购买道具
function StoreController:buyProp(pnid, num)
    self.m_view:onShowLoading(true)
    self.m_propManager:buyProp(pnid, num, function()
          self.m_view:onShowLoading(false)
    end)
end

-- 购买礼物
function StoreController:buyGift(pnid, num)
    self.m_view:onShowLoading(true)
    self.m_propManager:buyGift(pnid, num, function()
          self.m_view:onShowLoading(false)
    end)
end

function StoreController:gotoTab(index)
    self:updateView("gotoTab", index)
end

function StoreController:checkKoinIsEnough(cost)
    local isEnough = true
    if cost then
        if nk.functions.getMoney() - tonumber(cost) < 0 then
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
    if not isEnough then
        local args = {
            hasCloseButton = true,
            messageText = bm.LangUtil.getText("STORE", "BUY_FAIL_MSG"),  
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
-------------------------------- handle function --------------------------

 -- 加载支付配置后，初始化Manager
function StoreController:onLoadPayConfigCallBack(status, data)
    Log.printInfo("StoreController:onLoadPayConfigCallBack")
    self.m_isLoadPayType_ing = false
    if status then
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
function StoreController:onLoadChipProductList(paytypeId)
    Log.printInfo("StoreController:onLoadChipProductList")
    if self.m_isLoadPayType_ed then
        local pay = self.m_payManager:getPay(paytypeId)
        Log.dump(self.m_isLoadGoods_ing)
        self.m_isLoadGoods_ing[paytypeId] = true
        pay:loadChipProductList(handler(self, self.loadChipProductListResult))
    else
        self:loadPayConfig()
    end
end

function StoreController:loadChipProductListResult(status, paytype, data)
    Log.printInfo("StoreController:loadChipProductListResult")
    if status then
        self.m_isLoadGoods_ing[paytype.id] = false
        self.m_isLoadGoods_ed[paytype.id] = true
        self.m_baseData:setGoodsData(paytype.id, data)
        self:updateView("updateGoodsList", paytype)
    end
end

-- 加载道具配置回调
function StoreController:onLoadPropConfigCallBack(status, data)
    Log.printInfo("StoreController:onLoadPropConfigCallBack")
    self.m_isLoadPropType_ing = false
    if status then
        self.m_isLoadPropType_ed = true
        self.m_baseData:setPropTypeData(data)
        self:updateView("updatePropTypeList", data)
    else
        self:updateView("showNoDataTip")
    end
end

 -- 加载道具列表
function StoreController:onLoadPropProductList(proptypeId)
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

function StoreController:loadPropProductListResult(status, paytypeId, data)
    self.m_isLoadProp_ing[paytypeId] = false
    if status then
        self.m_isLoadProp_ed[paytypeId] = true
        self.m_baseData:setPropData(paytypeId, data)
        self:updateView("updatePropList", data)
    end
end

 -- 加载购买列表
function StoreController:onLoadHistoryList(proptypeId)
    self.m_historyManager:loadHistory(handler(self, self.loadHistoryListResult))
end

function StoreController:loadHistoryListResult(status, data)
    if status then
        self.m_baseData:setHistoryData(data)
        self:updateView("updateHistoryList", data)
    end
end

-------------------------------- event listen ------------------------

function StoreController:onStoreBuyEvent(tag, pid, goodData, cost)
    Log.printInfo("StoreController onStoreBuyEvent")
    if tag == "BUY_GOODS" then
        local payId = self.m_baseData:getPayViewId()
        if payId then
            nk.AnalyticsManager:report("New_Gaple_store_gold_buy", "store") 
            self:buyGoods(payId, pid, goodData)
        end
    elseif tag == "BUY_PROP" then
        if self:checkKoinIsEnough(cost) then
            self:buyProp(pid, goodData)
        end
    elseif tag == "BUY_GIFT" then
        if self:checkKoinIsEnough(cost) then
            self:buyGift(pid, goodData)
        end
    end
end

-------------------------------- native event -----------------------------


-------------------------------- table config ------------------------
-- Provide cmd handle to call
StoreController.s_cmdHandleEx = 
{
    ["loadPayConfigCallBack"] = StoreController.onLoadPayConfigCallBack,
    ["loadChipProductList"] = StoreController.onLoadChipProductList,
    ["loadPropProductList"] = StoreController.onLoadPropProductList,
    ["loadHistoryList"] = StoreController.onLoadHistoryList,
    ["back"] = StoreController.onBack,
};

-- Java to lua native call handle
StoreController.s_nativeHandle = {
    -- ["***"] = function
};

-- Event to register and unregister
StoreController.s_eventHandle = {
    -- [Event ] = function
    [EventConstants.storeBuyEvent] = StoreController.onStoreBuyEvent,
};

return StoreController