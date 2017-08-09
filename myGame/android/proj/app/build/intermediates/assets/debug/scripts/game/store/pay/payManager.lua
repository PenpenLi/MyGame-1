-- payManager.lua
-- Last modification : 2016-06-12
-- Description: a manager in pay moudle, to manage all pay type
-- Offer Instance

local GooglePay = require("game.store.pay.payModule.googlePay")
local StoreConfig = require("game.store.storeConfig")

local PayManager = class()

function PayManager.getInstance()
    if not PayManager.s_instance then
        PayManager.s_instance = new(PayManager)
    end
    return PayManager.s_instance
end

function PayManager:ctor()
    local InAppPurchasePay = require("game.store.pay.payModule.inAppStorePay")
    local MimoPayPay = require("game.store.pay.payModule.mimoPayPay")
    local ZingMobilePay = require("game.store.pay.payModule.zingMobilePay")
    local CodaIndosatPay = require("game.store.pay.payModule.codaIndosatPay")
    local IndomogPay = require("game.store.pay.payModule.indomogPay")
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpPorcesser);
    self.availablePay_ = {}
    self.m_pays = {}
    if System.getPlatform() == kPlatformAndroid then
        self.availablePay_[StoreConfig.IN_APP_BILLING] = GooglePay
        self.availablePay_[StoreConfig.MIMO_PAY] = MimoPayPay
        self.availablePay_[StoreConfig.ZING_MOBILE_XL] = ZingMobilePay
        self.availablePay_[StoreConfig.CODA_INDOSAT] = CodaIndosatPay
        self.availablePay_[StoreConfig.INDOMOG] = IndomogPay
    elseif System.getPlatform() == kPlatformIOS then
        self.availablePay_[StoreConfig.IN_APP_PURCHASE] = InAppPurchasePay
    elseif System.getPlatform() == kPlatformWin32 then
        self.availablePay_[StoreConfig.IN_APP_BILLING] = GooglePay
        self.availablePay_[StoreConfig.IN_APP_PURCHASE] = InAppPurchasePay
        self.availablePay_[StoreConfig.MIMO_PAY] = MimoPayPay
        self.availablePay_[StoreConfig.ZING_MOBILE_XL] = ZingMobilePay
        self.availablePay_[StoreConfig.CODA_INDOSAT] = CodaIndosatPay
        self.availablePay_[StoreConfig.INDOMOG] = IndomogPay
    end
end

function PayManager:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpPorcesser);
end

function PayManager:isPayAvailable(payId)
    return self.availablePay_[payId]
end

function PayManager:init(payConfig)
    for i, config in ipairs(payConfig) do
        local PayClass = self.availablePay_[config.id]
        local PayInstance = self.m_pays[config.id]
        if PayClass then
            if not PayInstance then
                PayInstance = new(PayClass)
                self.m_pays[config.id] = PayInstance
            end
            PayInstance:init(config)
        end
    end
end

function PayManager:getPay(payId)
    return self.m_pays[payId]
end


function PayManager:getQickPay(payId)
    local PayClass = self.availablePay_[payId]
    local PayInstance = self.m_pays[payId]
    if PayClass then
        if not PayInstance then
            PayInstance = new(PayClass)
            self.m_pays[payId] = PayInstance
        end
    end
    return PayInstance
end

function PayManager:autoDispose()
    for id, service in pairs(self.m_pays) do
        service:autoDispose()
    end
end

function PayManager:onCreateOrderBack(errorCode, data)
    Log.printInfo("PayManager", "PayManager.onCreateOrderBack")
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local retData = data.data
            if retData and retData.PMODE then
                local pay = self:getPay(tonumber(retData.PMODE))
                pay:createOrderBack(retData)
            end
        end
    else
        
    end
end

function PayManager:onGooglePaySuccessCallback(errorCode, data)
    local pay = self:getPay(StoreConfig.IN_APP_BILLING)
    if pay and pay.onGooglePaySuccessCallback then
        pay:onGooglePaySuccessCallback(errorCode, data)
    end
end

function PayManager:onHttpPorcesser(command, ...)
    Log.printInfo("PayManager", "PayManager.onHttpPorcesser");
    if not self.s_httpRequestsCallBack[command] then
        Log.printWarn("PayManager", "Not such request cmd in current controller command:" .. command);
        return;
    end
    self.s_httpRequestsCallBack[command](self,...); 
end

PayManager.s_httpRequestsCallBack = {
    ["createOrder"] = PayManager.onCreateOrderBack,
    ["googlePaySuccess"] = PayManager.onGooglePaySuccessCallback,
}

return PayManager
