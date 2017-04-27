-- godsdkNativeEvent.lua
-- Last modification : 2016-05-24
-- Description: a native event controller for godsdk moudle

local GodSDKNativeEvent = class(GameBaseNativeEvent)
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")
local PayManager = require("game.store.pay.payManager")

function GodSDKNativeEvent:ctor()
    
end

function GodSDKNativeEvent:dtor()
    
end

-- @params table data
-- data = {
    
-- }
function GodSDKNativeEvent:godsdkPay(data)
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_GODSDK_PAY, kCallParamJsonString, data, NativeEventConfig.NATIVE_GODSDK_PAY_CALLBACK)
end

---------------------------------nativeHandle-----------------------------------

function GodSDKNativeEvent:onPayCallBack(status, data)
    Log.printInfo("GodSDKNativeEvent","onPayCallBack")
    Log.dump(data)
  --   "<var>" = {
	 --     "OriginalBase" = "{"packageName":"com.boyaa.gaple","productId":"200000","purchaseTime":1466596670250,"purchaseState":0,"developerPayload":"3150084100","purchaseToken":"onghhabcijhbcckddhhacooo.AO-J1OzDdLoqaFdLKV-QIB_7GfjeXIIYPrD3TQFXks-aWqnbNxIKfOxAoIJVI8DbMCB8XMR8A0uGPZmkmuvrf7-84_yw5n7IZbHBdPF_6XHXGeHEhB077gY"}"
	 --     "Signature"    = "dZRHZpQcV2JocU5aKmjh71q6Ed4/t6req9j8H/JfR+tGGYXhAIZwe6c+yXcbOnD15U+Wj2C9N6zjw8JwCGG5vKRApAG2EOfGgxhace+hFZ3gkkRg6PiEaG9u6JIgWe0TF3uxEkZQVh7BmWrg8RAREAF7XnnJlgNhdfBsHWfsMhkBBrW1yVwLuIgmPjeTWkADP1hQs7OPsSHZ7ydbTaNEzh9SR0HYuksc2ldadtP6Ye8D69qMwL32gdbS1DiYYR6h16LIHQGjmKl2aT/yvskMbzhypO6iob51h0HOSFC2uo01QxGABQuwGvcueWAhLe9s3zJhcEYUPQnwUBW4BxrNtw=="
	 --     "pmode"        = "12"
	 -- }
	-- 测试沙盒支付没有orderId
	if status then
		if data and data.pmode then
			local payManager = PayManager.getInstance()
			local pay = payManager:getPay(tonumber(data.pmode))
			if pay and pay.onPayCallback then
				pay:onPayCallback(data)
			end
		end
	end
end

----------------------------------tableConfig-----------------------------------
GodSDKNativeEvent.s_nativeHandle = {
    -- ["***"] = function
    [NativeEventConfig.NATIVE_GODSDK_PAY_CALLBACK] = GodSDKNativeEvent.onPayCallBack,
}

return GodSDKNativeEvent