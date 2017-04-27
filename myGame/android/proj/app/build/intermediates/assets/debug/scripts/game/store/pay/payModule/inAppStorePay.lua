--
-- Author: tony
-- Date: 2014-11-24 19:01:49
-- appstore支付
--
local PayBase = require("game.store.pay.payModuleBase")
local PayHelper = require("game.store.pay.payHelper")
-- local Store = import("app.module.store.plugins.Store")

local InAppStorePay = class(PayBase)

function InAppStorePay:ctor()
    InAppStorePay.super.ctor(self, "InAppStorePay")
    self.helper_ = new(PayHelper)
    self.store_ = Store.new()
    self.store_:addEventListener(Store.LOAD_PRODUCTS_FINISHED, handler(self, self.loadProductFinished_))
    self.store_:addEventListener(Store.TRANSACTION_PURCHASED, handler(self, self.transactionPurchased_))
    self.store_:addEventListener(Store.TRANSACTION_RESTORED, handler(self, self.transactionRestored_))
    self.store_:addEventListener(Store.TRANSACTION_FAILED, handler(self, self.transactionFailed_))
    self.store_:addEventListener(Store.TRANSACTION_UNKNOWN_ERROR, handler(self, self.transactionUnkownError_))
end

function InAppStorePay:init(config)
    self.active_ = true
    self.config_ = config
    self.isSupported_ = self.store_:canMakePurchases()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
    end
    self.store_:restore()
end

function InAppStorePay:autoDispose()
    self.active_ = false
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.purchaseCallback_ = nil
    self.isProductPriceLoaded_ = false
    self.isProductRequesting_ = false
end

--callback(payType, isComplete, data)
function InAppStorePay:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function InAppStorePay:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function InAppStorePay:loadProcess_()
    if not self.isSupported_ then
        self.logger:debug("iap not supported")
        self:invokeCallback_(3, true, bm.LangUtil.getText("STORE", "NOT_SUPPORT_MSG"))
    else
        if not self.products_ then
            self.logger:debug("remote config is loading..")
            self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
        end
        if self.loadChipRequested_ or self.loadPropRequested_ then
            if self.products_ then
                if self.isProductPriceLoaded_ then
                    --更新折扣
                    self.helper_:updateDiscount(self.products_, self.config_)
                    self:invokeCallback_(1, true, self.products_.chips)
                    self:invokeCallback_(2, true, self.products_.props)
                elseif not self.isProductRequesting_ then
                    self.isProductRequesting_ = true
                    self.logger:debug("start loading price...")
                    self:invokeCallback_(3, false)
                    self.store_:loadProducts(self.products_.skus)
                else
                    self:invokeCallback_(3, false)
                end
            else
                self:invokeCallback_(3, false)
            end
        else
            self:invokeCallback_(3, false)
        end
    end
end

function InAppStorePay:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end
    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end
end

function InAppStorePay:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        self.products_ = self.helper_:parseConfig(content, function(category, json, product)
        end)
        self:loadProcess_()
    else
        self.logger:debug("remote config file load failed.")
        self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end

function InAppStorePay:makePurchase(pid, callback)
    self.purchaseCallback_ = callback
    self.store_:purchaseProduct(pid)
end

--OC to lua
function InAppStorePay:loadProductFinished_(evt)
    self.isProductRequesting_ = false
    local function getPriceLabel(prd)
        return luaoc.callStaticMethod(
                            "LuaOCBridge", 
                            "getPriceLabel", 
                            {
                                priceLocale = prd.priceLocale, 
                                price = prd.price, 
                            }
                        )
    end
    if evt.products and #evt.products > 0 then
        --更新价格
        for i, prd in ipairs(evt.products) do
            if self.products_.chips then
                for j, chip in ipairs(self.products_.chips) do
                    if prd.productIdentifier == chip.pid then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            chip.priceLabel = price
                        else
                            chip.priceLabel = prd.price
                        end
                        chip.priceNum = prd.price
                    end
                end
            end
            if self.products_.props then
                for j, prop in ipairs(self.products_.props) do
                    if prd.productIdentifier == prop.pid then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            prop.priceLabel = price
                        else
                            prop.priceLabel = prd.price
                        end
                        prop.priceNum = prd.price
                    end
                end
            end
            if self.products_.coins then
                for j, coin in ipairs(self.products_.coins) do
                    if prd.productIdentifier == coin.pid then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            coin.priceLabel = price
                        else
                            coin.priceLabel = prd.price
                        end
                        coin.priceNum = prd.price
                    end
                end
            end
        end
        self.isProductPriceLoaded_ = true
        self:loadProcess_()
        return
    end
    self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end
--OC to lua
function InAppStorePay:transactionPurchased_(evt)
    nk.userData["firstRechargeStatus"] = 0
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
    self:delivery(evt.transaction, true)
end
--OC to lua
function InAppStorePay:transactionRestored_(evt)
    self:delivery(evt.transaction, false)
end
--OC to lua
function InAppStorePay:transactionFailed_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
    if self.purchaseCallback_ then
        self.purchaseCallback_(false, "ERROR")
    end
end
--OC to lua
function InAppStorePay:transactionUnkownError_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
    if self.purchaseCallback_ then
        self.purchaseCallback_(false, "ERROR")
    end
end

function InAppStorePay:delivery(transaction, showMsg)
    local retryLimit = 6
    local deliveryFunc
    local params = {
        mod = "pay",
        act = "delivery",
        receipt = crypto.encodeBase64(transaction.receipt),
    }
    deliveryFunc = function()
        bm.HttpService.POST(params, function(ret)
                local jsn = json.decode(ret)
                if jsn and tonumber(jsn.ret) == 0 then
                    self.logger:debug("dilivery success, consume it")
                    --v3
                    --store:finishTransaction(transaction.transactionIdentifier)
                    --v2
                    self.store_:finishTransaction(transaction)
                    if showMsg then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                        if self.purchaseCallback_ then
                            self.purchaseCallback_(true)
                        end
                    end
                else
                    self.logger:debug("delivery failed => " .. ret)
                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
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
            end, function()
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
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



return InAppStorePay
