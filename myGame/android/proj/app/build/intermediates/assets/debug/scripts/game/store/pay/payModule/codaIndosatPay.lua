-- codaIndosatPay.lua
-- Last modification : 2016-06-12
-- Description: a coda indosat pay moudle
-- CODA INDOSAT支付，该支付需要集成godsdk

local PayBase = require("game.store.pay.payModuleBase")
local PayHelper = require("game.store.pay.payHelper")
local CodaIndosatPay = class(PayBase)

local PAMOUNT_TEMP = 0
local CURRENCY_TEMP = "USD"

function CodaIndosatPay:ctor()
    self.m_helper = new(PayHelper, "CodaIndosatPay")
end

function CodaIndosatPay:init(config)
    self.m_config = config
    self.isBuying = false
end

function CodaIndosatPay:autoDispose()
    self.m_loadChipRequested = false
    self.m_loadChipCallback = nil
end

--callback(payType, isComplete, data)
function CodaIndosatPay:loadChipProductList(callback)
    self.m_loadChipCallback = callback
    self.m_loadChipRequested = true
    self:loadProcess()
end

function CodaIndosatPay:loadProcess()
    if not self.m_products then
        -- self.logger:debug("remote config is loading..")
        self.m_helper:cacheConfig(self.m_config.configURL, handler(self, self.configLoadHandler))
    elseif self.m_loadChipRequested then
       -- self.m_helper:updateDiscount(self.m_products, self.m_config)
        self:invokeCallback(true, self.m_products.chips)
    else
        self:invokeCallback(false)
    end
end

function CodaIndosatPay:invokeCallback(status, data)
    if self.m_loadChipRequested and self.m_loadChipCallback then
        if status then
            self.m_loadChipCallback(true, self.m_config, data)
        else
            self.m_loadChipCallback(false)
        end
    end
end

function CodaIndosatPay:configLoadHandler(succ, content)
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

function CodaIndosatPay:makeBuy(pid, goodData)
    Log.printInfo("CodaIndosatPay", ">>> CodaIndosatPay -> makeBuy", pid)
    if self.isBuying then
        -- TO DO 提示正在购买，莫着急
        -- self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end
    self.isBuying = true
    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode
    if goodData.limid then
        params.limid = goodData.limid
    end
    self.m_helper:callPayOrder(params)
end

function CodaIndosatPay:createOrderBack(data)
    self.isBuying = false
    
    -- RET -- 0:success  非0:errorCode
    if 0 == data.RET then
        local params = {}
        params.apiKey = data.apiKey
        params.orderId = data.ORDER
        params.currency = data.currency
        params.country = data.country
        params.environment = "Production" --生产环境：Production/测试环境：Sandbox
        params.items = data.items       
        params.pmode = data.PMODE
        params.profile = data.profile

        --存一下用来统计上报
        PAMOUNT_TEMP  = data.PAMOUNT
        CURRENCY_TEMP = data.CURRENCY

        nk.GodSDKNativeEvent:godsdkPay(params)
    else
        -- TO DO 提示下单失败
    end
end

--支付成功的回调
function CodaIndosatPay:onPayCallback(data)
    nk.userData["firstRechargeStatus"] = 0
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))

    if nk.AdPlugin then
        nk.AdPlugin:reportPay(PAMOUNT_TEMP, CURRENCY_TEMP)
    end
    nk.AnalyticsManager:report("New_Gaple_store_gold_buy", "store")    
end

-- TO DO 废弃接口
function CodaIndosatPay:makePurchase(pid, callback, goodData)
    if self.isBuying then
        -- self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end
    self.isBuying = true
    self.purchaseCallback_ = callback

    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode

    self.m_helper:callPayOrder(params,function(callData)
        dump(callData, ">>>CodaIndosat Order Data")
        -- RET -- 0:success  非0:errorCode
        if callData.RET == 0 then
            local params = {}
            params.apiKey = callData.apiKey
            params.orderId = callData.ORDER
            params.currency = callData.currency
            params.country = callData.country
            params.environment = "Production" --生产环境：Production/测试环境：Sandbox
            params.items = callData.items
            params.pmode = callData.PMODE

            --存一下用来上报
            PAMOUNT_TEMP  = callData.PAMOUNT
            CURRENCY_TEMP = callData.CURRENCY

            local jsonString = json.encode(params)
            print("makePurchase params", jsonString)
            self.invokeJavaMethod_("makePurchase", {jsonString}, "(Ljava/lang/String;)V")
        else
            -- self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
            self.isBuying = false
        end
        
    end,function()
        self.isBuying = false
    end)
end

-- TO DO 废弃接口
function CodaIndosatPay:onPaymentResult_(jsonString)
    print(">>>> CodaIndosat payment callback", jsonString)
    local data = json.decode(jsonString)
    local success = (data.result == 1) and true or false
    if success then
        nk.userData["firstRechargeStatus"] = 0
        -- self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))

        if nk.AdPlugin then
            dump(PAMOUNT_TEMP, ">>>>>>>>>>>>>>>>>>>>> PAMOUNT_TEMP")
            dump(CURRENCY_TEMP, ">>>>>>>>>>>>>>>>>>>>> CURRENCY_TEMP")
            nk.AdPlugin:reportPay(PAMOUNT_TEMP, CURRENCY_TEMP)
        end
    else
        -- self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
        if self.purchaseCallback_ then
            self.purchaseCallback_(false, "error")
        end
    end
    self.isBuying = false
end

return CodaIndosatPay
