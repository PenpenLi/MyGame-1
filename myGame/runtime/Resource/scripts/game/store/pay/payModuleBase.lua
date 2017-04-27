-- payModuleBase.lua
-- Last modification : 2016-06-12
-- Description: a pay base moudle, specific pay need to extends it

local PayModuleBase = class()

function PayModuleBase:ctor()
end

function PayModuleBase:dtor()
end

function PayModuleBase:init(config)
end

function PayModuleBase:autoDispose()
end

--callback(payType, isComplete, data)
function PayModuleBase:loadChipProductList(callback)
end

--callback(payType, isComplete, data)
function PayModuleBase:loadPropProductList(callback)
end

function PayModuleBase:makePurchase(pid, callback)
end

function PayModuleBase:prepareEditBox(input1, input2, submitBtn)
end

function PayModuleBase:onInputCardInfo(productType, input1, input2, submitBtn, callback)
end

function PayModuleBase:createJavaMethodInvoker(javaClassName)
end

return PayModuleBase
