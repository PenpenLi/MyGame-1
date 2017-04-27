-- mimoPay.lua
-- Last modification : 2016-06-12
-- Description: a coda MimoPay pay moudle
-- MimoPay支付，该支付需要集成godsdk

local PayBase = require("game.store.pay.payModuleBase")
local PayHelper = require("game.store.pay.payHelper")
local MimoPay = class(PayBase)

local PAMOUNT_TEMP = 0
local CURRENCY_TEMP = "USD"

function MimoPay:ctor()
    self.m_helper = new(PayHelper, "MimoPay")
    -- 商品数据，下单的时候赋值
    self.m_goodData = nil
end

function MimoPay:init(config)
    self.m_config = config
    self.m_isBuying = false
    self.m_helper:cacheConfig(config.configURL, handler(self, self.configLoadHandler))
end

function MimoPay:autoDispose()
    self.m_loadChipRequested = false
    self.m_loadChipCallback = nil
end

--callback(payType, isComplete, data)
function MimoPay:loadChipProductList(callback)
    self.m_loadChipCallback = callback
    self.m_loadChipRequested = true
    self:loadProcess()
end

function MimoPay:loadProcess()
    if not self.m_products then
        -- self.logger:debug("remote config is loading..")
        self.m_helper:cacheConfig(self.m_config.configURL, handler(self, self.configLoadHandler))
        self:invokeCallback(false)
    elseif self.m_loadChipRequested then
       -- self.m_helper:updateDiscount(self.m_products, self.m_config)
        self:invokeCallback(true, self.m_products.chips)
    else
        self:invokeCallback(false)
    end
end

function MimoPay:invokeCallback(status, data)
    if self.m_loadChipRequested and self.m_loadChipCallback then
        if status then
            self.m_loadChipCallback(true, self.m_config, data)
        else
            self.m_loadChipCallback(false)
        end
    end
end

function MimoPay:configLoadHandler(succ, content)
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

function MimoPay:makeBuy(pid, goodData)
    Log.printInfo("MimoPay", ">>> MimoPay -> makeBuy", pid)
    if self.m_isBuying then
        -- TO DO 提示正在购买，莫着急
        -- self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end
    self.m_isBuying = true
    self.m_goodData = goodData
    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode
    params.getname = goodData.getname
    if goodData.limid then
        params.limid = goodData.limid
    end
    self.m_helper:callPayOrder(params)
end

function MimoPay:createOrderBack(data)
    self.m_isBuying = false
    
    -- RET -- 0:success  非0:errorCode
    if 0 == data.RET then
        local params = {}
        params.emailOrUserId = data.SITEMID
        params.productName = string.gsub(self.m_goodData.getname or "", " ", "-")
        params.transactionId = data.ORDER
        params.currency = data.CURRENCY
        params.enableLog = true
        params.enableGateway = true --true:正式/false:测试
        params.channel = 8
        params.isQuietMode = false
        params.pamount = data.PAMOUNT
        params.autoSendSms = true
        params.pmode = data.PMODE

         --存一下用来统计上报
        PAMOUNT_TEMP  = data.PAMOUNT
        CURRENCY_TEMP = data.CURRENCY

        nk.GodSDKNativeEvent:godsdkPay(params)
    else
        -- TO DO 提示下单失败
    end
end

--支付成功的回调
function MimoPay:onPayCallback(data)
    nk.userData["firstRechargeStatus"] = 0
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))

    if nk.AdPlugin then
        nk.AdPlugin:reportPay(PAMOUNT_TEMP, CURRENCY_TEMP)
    end

    nk.AnalyticsManager:report("New_Gaple_store_gold_buy", "store")
end

function MimoPay:makePurchase(pid, callback, goodData)
    if self.m_isBuying then
        self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end
    self.m_isBuying = true

    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode
    self.m_helper:callPayOrder(params,function(callData)
        dump(callData, ">>>MimoPay Order Data")
        -- RET -- 0:success  非0:errorCode
        if callData.RET == 0 then
            local params = {}
            params.emailOrUserId = callData.SITEMID
            params.productName = string.gsub(goodData.getname, " ", "-")
            params.transactionId = callData.ORDER
            params.currency = callData.CURRENCY
            params.enableLog = true
            params.enableGateway = true --true:正式/false:测试
            params.channel = 8
            params.isQuietMode = false
            params.pamount = callData.PAMOUNT
            params.autoSendSms = true
            params.pmode = callData.PMODE

            --存一下用来上报
            PAMOUNT_TEMP  = callData.PAMOUNT
            CURRENCY_TEMP = callData.CURRENCY

            local jsonString = json.encode(params)
            print("makePurchase params", jsonString)
        else
            self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
            self.m_isBuying = false
        end
        
    end,function()
        self.m_isBuying = false
    end)
end

function MimoPay:onPaymentResult_(jsonString)
    print(">>>> MimoPay payment callback", jsonString)
    local data = json.decode(jsonString)
    local success = (data.result == 1) and true or false
    if success then
        nk.userData["firstRechargeStatus"] = 0
        self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))

        if nk.AdPlugin then
            dump(PAMOUNT_TEMP, ">>>>>>>>>>>>>>>>>>>>> PAMOUNT_TEMP")
            dump(CURRENCY_TEMP, ">>>>>>>>>>>>>>>>>>>>> CURRENCY_TEMP")
            nk.AdPlugin:reportPay(PAMOUNT_TEMP, CURRENCY_TEMP)
        end
    else
        self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
        if self.purchaseCallback_ then
            self.purchaseCallback_(false, "error")
        end
    end
    self.m_isBuying = false
end

function MimoPay:toptip(msg)
    nk.TopTipManager:showTopTip(msg)
end

return MimoPay
