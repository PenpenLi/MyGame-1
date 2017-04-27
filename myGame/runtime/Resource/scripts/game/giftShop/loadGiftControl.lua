--
-- Author: Tom
-- Date: 2014-12-04 14:29:12
--
local CacheHelper = require("game.cache.cache")

local LoadGiftControl =  class()
local instance

function LoadGiftControl:getInstance()
    instance = instance or new(LoadGiftControl)
    return instance
end

function LoadGiftControl:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoadGiftControl:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadGiftConfigCallback_ = callback
    self:loadConfig_()
end

function LoadGiftControl:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        local cacheHelper_ = new(CacheHelper)
        cacheHelper_:cacheFile(self.url_ or nk.userData.GIFT_JSON, handler(self, function(obj, result, content, stype)
            self.isConfigLoading_ = false
            if result then
                self.isConfigLoaded_ = true
                self.giftData_ = content
                if self.giftData_ then
                    for k, v in pairs(self.requests_) do
                        local called = false
                        for i=1,#self.giftData_ do
                            if tonumber(self.giftData_[i].pnid) == tonumber(v.giftId) then
                                if v.callback then
                                    called = true
                                    v.callback(self.giftData_[i].image)
                                    break
                                end
                            end
                        end
                        if not called and v.callback then
                            v.callback(nil)
                        end
                    end
                end
                if self.loadGiftConfigCallback_ then
                    self.loadGiftConfigCallback_(true, self.giftData_)
                end
            else
                if self.loadGiftConfigCallback_ then
                    self.loadGiftConfigCallback_(false)
                end
            end
        end), "gift", "data")
    elseif self.isConfigLoaded_ then
         if self.loadGiftConfigCallback_ then
            self.loadGiftConfigCallback_(true, self.giftData_)
        end
    end
end

function LoadGiftControl:cancel(requestId)
    self.requests_[requestId] = nil
end

function LoadGiftControl:getGiftUrlById(giftId, callback)
    if self.isConfigLoaded_ then
        if self.giftData_ then
            for i=1,#self.giftData_ do
                if tonumber(self.giftData_[i].pnid) == tonumber(giftId) then
                    if callback then
                        callback(self.giftData_[i].image)
                        return nil
                    end
                end
            end
        end
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {giftId=giftId, callback=callback}
        self:loadConfig_()
        return self.requestId_
    end
end

return LoadGiftControl