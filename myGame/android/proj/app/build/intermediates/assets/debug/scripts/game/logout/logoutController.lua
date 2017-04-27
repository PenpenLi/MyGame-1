--
-- logoutController.lua
-- Date: 2015-12-15 10:00:54
--

local CacheHelper = require("game.cache.cache")
local LogoutController =  class()
local instance

function LogoutController.getInstance()
    instance = instance or new(LogoutController)
    return instance
end

function LogoutController:ctor()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LogoutController:autoDispose()
    self.loadLogoutConfigCallback_ = nil
end


function LogoutController:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadLogoutConfigCallback_ = callback
    self:loadConfig_()
end

function LogoutController:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        local cacheHelper_ = new(CacheHelper)
        cacheHelper_:cacheFile(self.url_ or nk.userData.GIFT_JSON, function(result, content, stype)
            self.isConfigLoading_ = false
            if result then
                self.isConfigLoaded_ = true
                self.logoutData_ = content
                if self.loadLogoutConfigCallback_ then
                    self.loadLogoutConfigCallback_(true, self.logoutData_)
                end
            else
                if self.loadLogoutConfigCallback_ then
                    self.loadLogoutConfigCallback_(false)
                end
            end
        end, "logout", "data")
    elseif self.isConfigLoaded_ then
         if self.loadLogoutConfigCallback_ then
            self.loadLogoutConfigCallback_(true, self.logoutData_)
        end
    end
end

return LogoutController