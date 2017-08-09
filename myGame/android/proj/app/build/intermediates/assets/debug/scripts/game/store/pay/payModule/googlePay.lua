-- googlePay.lua
-- Last modification : 2016-06-12
-- Description: a google pay moudle
-- 谷歌支付，该支付需要集成godsdk

local PayBase = require("game.store.pay.payModuleBase")
local PayHelper = require("game.store.pay.payHelper")
local StoreConfig = require("game.store.storeConfig")
local Gzip = require('core.gzip')
local GooglePay = class(PayBase)

local PAMOUNT_TEMP = 0
local CURRENCY_TEMP = "USD"

function GooglePay:ctor()
    self.m_helper = new(PayHelper, "GooglePlay")
end

function GooglePay:init(config)
    self.m_config = config
    self.isBuying = false
end

function GooglePay:autoDispose()
    self.isBuying = false
    self.m_loadChipRequesting = false -- 
    self.m_loadChipRequested = false -- 标记是否请求加载商品列表，即有需要回调
    self.m_loadChipCallback = nil
end

--callback(payType, data)
function GooglePay:loadChipProductList(callback)
    self.m_loadChipCallback = callback
    self.m_loadChipRequested = true
    self:loadProcess()
end

--加载商品信息流程
function GooglePay:loadProcess()
    if not self.m_products then
        self.m_helper:cacheConfig(self.m_config.configURL, handler(self, self.configLoadHandler))
    else
--    if self.m_loadChipRequested or self.loadPropRequested_ then
        if self.m_loadChipRequested then
--            if self.isProductPriceLoaded_ then
                --更新折扣
                if self.m_products then
                    --self.m_helper:updateDiscount(self.m_products, self.m_config)
                    self:invokeCallback(true, self.m_products.chips)
                else
                    self:invokeCallback(false)
                end
--            elseif not self.isProductRequesting_ then
--                self.isProductRequesting_ = true
--                local joinedSkuList = table.concat(self.m_products.skus, ",")
--                self:invokeCallback(false)
--            else
--                self:invokeCallback(false)
--            end
        else
            self:invokeCallback(false)
        end
--    end
    end
end

function GooglePay:configLoadHandler(succ, content)
    if succ then
        self.m_products = self.m_helper:parseConfig(content, function(category, json, product)
        end)
        self:loadProcess()
    else
        self:invokeCallback(false, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end

function GooglePay:invokeCallback(status, data)
    if self.m_loadChipRequested and self.m_loadChipCallback then
        if status then
            self.m_loadChipCallback(true, self.m_config, data)
        else
            self.m_loadChipCallback(false, data)
        end
    end
end

function GooglePay:makeBuy(pid, goodData)
    Log.printInfo("GooglePay", ">>> GooglePay -> makeBuy", pid)
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

function GooglePay:createOrderBack(data)
    self.isBuying = false
    --存一下用来统计上报
    PAMOUNT_TEMP  = data.PAMOUNT
    CURRENCY_TEMP = data.CURRENCY

    -- RET -- 0:success  非0:errorCode
    if 0 == data.RET then

        -- local params = {}
        -- params.orderId = data.ORDER
        -- params.uid = tostring(nk.userData.mid) or ""
        -- params.channel = tostring(GameConfig.ROOT_CGI_SID) or ""
        -- params.sku = data.PAYCONFID
        -- nk.GoogleNativeEvent:pay(params)

        local params = {}
        params.pmode = StoreConfig.IN_APP_BILLING
        params.orderId = data.ORDER
        -- params.uid = tostring(nk.userData.mid) or ""
        -- params.channel = tostring(GameConfig.ROOT_CGI_SID) or ""
        params.productId = data.PAYCONFID
        nk.GodSDKNativeEvent:godsdkPay(params)
    else

    end
end

function GooglePay:onPayCallback(data)
    Log.printInfo("GooglePay", "onPayCallback")
    local params = {}
    params.signedData = Gzip.encodeBase64(data.OriginalBase)
    params.signature = data.Signature
    params.pmode = data.pmode
    nk.HttpController:execute("googlePaySuccess", {game_param = params})
end

function GooglePay:onGooglePaySuccessCallback(errorCode, data)
    Log.printInfo("GooglePay", "onGooglePaySuccessCallback")
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local retData = data.data
            if retData and retData.RET == 0 then
                nk.userData["firstRechargeStatus"] = 0
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
                if nk.AdPlugin then
                    nk.AdPlugin:reportPay(PAMOUNT_TEMP, CURRENCY_TEMP)
                end
                nk.AnalyticsManager:report("New_Gaple_store_gold_buy", "store")
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                -- TO DO 提示发货成功
            else
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                -- TO DO 尝试6次，间隔10秒，php返回错误则提示错误，如果网络错误则保存本地缓存，提示下次启动重试
            end
        end
    else
        
    end
end

function GooglePay:delivery(sku, receipt, signature, showMsg)
    local retryLimit = 6
    local deliveryFunc
    local params = {}
    params.signedData = crypto.encodeBase64(receipt)
    params.signature = signature
    params.pmode = self.m_config.pmode

    deliveryFunc = function()
        self.m_helper:callPayDelivery(params,function(json)
                -- local json = json.decode(data)
                if json and json.RET == 0 then
                    -- self.invokeJavaMethod_("consume", {sku}, "(Ljava/lang/String;)V")
                    if showMsg then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                        if self.purchaseCallback_ then
                            self.purchaseCallback_(true)
                        end
                    end
                else
                    self.logger:debug("delivery failed => " .. (json and json.MSG or "nil"))
                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        Clock.instance():schedule_once(function()
                            deliveryFunc()
                        end, 10)
                    else
                        if showMsg then
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                            if self.purchaseCallback_ then
                                self.purchaseCallback_(false, "error")
                            end
                        end
                    end
                end
            end, function(errData) 
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    Clock.instance():schedule_once(function()
                        deliveryFunc()
                    end, 10)
                else
                    if showMsg then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                        if self.purchaseCallback_ then
                            self.purchaseCallback_(false, "error")
                        end
                    end
                end
            end)
    end
    deliveryFunc()
end

return GooglePay