--
-- Author: melon
-- Date: 2016-10-17 18:11:40
--
local LimitTimeController = class()

function LimitTimeController:ctor(view)
	self.view = view
    EventDispatcher.getInstance():register(EventConstants.close_limit_time_giftbag, self, self.onLimitTimeClose)
    EventDispatcher.getInstance():register(EventConstants.getLimitTimeGift, self, self.onGetLimitTimeGiftbag)
    local PayManager = require("game.store.pay.payManager")
    self.payManager = PayManager.getInstance()
end

function LimitTimeController:dtor()
	Log.printInfo("LimitTimeController:dtor")
	self.view = nil
	EventDispatcher.getInstance():unregister(EventConstants.close_limit_time_giftbag, self, self.onLimitTimeClose)
    EventDispatcher.getInstance():unregister(EventConstants.getLimitTimeGift, self, self.onGetLimitTimeGiftbag);
end

function LimitTimeController:initPayConfig(config)
    self.payManager:init(config)
end

function LimitTimeController:onLimitTimeClose()
	if self.view then
		self.view:onLimitTimeClose()
	end
end

function LimitTimeController:onGetLimitTimeGiftbag(data)
    if data and self.view  then
        self.view:initLimitTimeGiftbag(data)
    end
end


function LimitTimeController:loadLimitTimeGiftbag()
    local ver = nk.DictModule:getString("gameData", "limitTimeVer", "")
    nk.HttpController:execute("getLimitTimeGiftbag", {game_param = {ver= ver}})
end

function LimitTimeController:buyLimitGiftbag(payData)
    local payType = self.payManager:getPay(tonumber(payData.pmode))
    payType:makeBuy(payData.pid, payData)
end

return LimitTimeController