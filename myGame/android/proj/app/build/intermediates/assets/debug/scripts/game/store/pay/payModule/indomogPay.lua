-- indomogPay.lua
-- Last modification : 2016-06-12
-- Description: a coda Indomog pay moudle
-- 充值卡支付

local PayBase = require("game.store.pay.payModuleBase")
local PayHelper = require("game.store.pay.payHelper")
-- local IndomogConfirmDlg = import("app.module.newstore.views.IndomogConfirmDlg")
local StoreIindomogPayPopLayer = require("game.store.layers.storeIindomogPayPopLayer")

local IndomogPay = class(PayBase)

local PAMOUNT_TEMP = 0
local CURRENCY_TEMP = "USD"

function IndomogPay:ctor()
    self.m_helper = new(PayHelper, "IndomogPay")
end

function IndomogPay:init(config)
    self.m_config = config
    self.m_isBuying = false
    self.m_helper:cacheConfig(config.configURL, handler(self, self.configLoadHandler))
end

function IndomogPay:autoDispose()
    self.m_loadChipRequested = false
    self.m_loadChipCallback = nil
end

--callback(payType, isComplete, data)
function IndomogPay:loadChipProductList(callback)
    self.m_loadChipCallback = callback
    self.m_loadChipRequested = true
    self:loadProcess()
end

function IndomogPay:loadProcess()
    if not self.m_products then
        -- self.logger:debug("remote config is loading..")
        self.m_helper:cacheConfig(self.m_config.configURL, handler(self, self.configLoadHandler))
        self:invokeCallback(false)
    elseif self.m_loadChipRequested then
        --self.m_helper:updateDiscount(self.m_products, self.m_config)
        self:invokeCallback(true, self.m_products.chips)
    else
        self:invokeCallback(false)
    end
end

function IndomogPay:invokeCallback(status, data)
    if self.m_loadChipRequested and self.m_loadChipCallback then
        if status then
            self.m_loadChipCallback(true, self.m_config, data)
        else
            self.m_loadChipCallback(false)
        end
    end
end

function IndomogPay:configLoadHandler(succ, content)
    if succ then
        -- self.logger:debug("remote config file loaded.")
        self.m_products = self.m_helper:parseConfig(content, function(category, json, product)
            product.priceLabel = string.format("%d" .. product.currency, product.price)
            product.priceNum = product.price
            product.priceDollar = product.currency
        end)
        self:loadProcess()
    else
        -- self.logger:debug("remote config file load failed.")
        self:invokeCallback(true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end

function IndomogPay:makeBuy(pid, goodData)
    Log.printInfo("IndomogPay", ">>> IndomogPay -> makeBuy", pid,goodData.pmode)
    nk.PopupManager:addPopup(StoreIindomogPayPopLayer,"hall",handler(self, function(obj, strNumber, strSecret)
            obj:createOrder(pid, goodData, strNumber, strSecret)
        end))
end

function IndomogPay:createOrder(pid, goodData, strNumber, strSecret)
    Log.printInfo("IndomogPay", ">>> IndomogPay -> makeBuy", pid)
    if self.isBuying then
        -- TO DO 提示正在购买，莫着急
        -- self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end
    self.isBuying = true
    local params = {}
    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode
    params.ptype = goodData.ptype
    params.cardcode = strNumber
    params.cardpwd = strSecret
    if goodData.limid then
        params.limid = goodData.limid
    end
    self.m_helper:callPayOrder(params)
end

function IndomogPay:createOrderBack(data)
    self.isBuying = false
    
    -- RET -- 0:success  非0:errorCode
    if 0 == data.RET then
        --存一下用来统计上报
        PAMOUNT_TEMP  = data.PAMOUNT
        CURRENCY_TEMP = data.CURRENCY

        if nk.AdPlugin then
            nk.AdPlugin:reportPay(PAMOUNT_TEMP, CURRENCY_TEMP)
        end
        nk.AnalyticsManager:report("New_Gaple_store_gold_buy", "store")
    else
        -- TO DO 提示下单失败
    end
end

function IndomogPay:makePurchase(pid, callback, goodData)

    IndomogConfirmDlg.new({
        callback = function (type, strNumber, strSecret)
            if type == nk.Dialog.FIRST_BTN_CLICK then
                -- cancel
            elseif type == nk.Dialog.SECOND_BTN_CLICK then
                -- submit
                self:callPayment_(pid, callback, goodData, strNumber, strSecret)
            end
        end
    }):show()
end

function IndomogPay:callPayment_(pid, callback, goodData, strNumber, strSecret)
    if self.m_isBuying then
        self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end
    self.m_isBuying = true

    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode
    params.ptype = goodData.ptype
    params.cardcode = strNumber
    params.cardpwd = strSecret

    self.m_helper:callPayOrder(params,function(callData)
        dump(callData, ">>>Indomog Order Data")
        -- RET -- 0:success  非0:errorCode
        if callData.RET ~= 0 then
            self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
            self.m_isBuying = false
        else
            PAMOUNT_TEMP  = callData.PAMOUNT
            CURRENCY_TEMP = callData.CURRENCY
            
            if nk.AdPlugin then
                -- dump(PAMOUNT_TEMP, ">>>>>>>>>>>>>>>>>>>>> PAMOUNT_TEMP")
                -- dump(CURRENCY_TEMP, ">>>>>>>>>>>>>>>>>>>>> CURRENCY_TEMP")
                nk.AdPlugin:reportPay(PAMOUNT_TEMP, CURRENCY_TEMP)
            end
        end
        self.m_isBuying = false
    end,function()
        self.m_isBuying = false
    end)
end

function IndomogPay:toptip(msg)
    nk.TopTipManager:showTopTip(msg)
end

return IndomogPay
