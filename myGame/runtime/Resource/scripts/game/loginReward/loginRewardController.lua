-- LoginRewardController.lua
-- Create Date ：2016-07-08
-- Last modification : 2016-07-08
-- Description: a popup controler to show reward when login succ

local LoginRewardController =  class()
local CacheHelper = require("game.cache.cache")

function LoginRewardController:ctor()
    self.requestId_ = 0
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoginRewardController:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadConfigCallback_ = callback
    self:loadConfig_()
end

function LoginRewardController:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        local cacheHelper = new(CacheHelper)
        cacheHelper:cacheFile(self.url_ or nk.userData.LEVEL_JSON, handler(self, function(obj, result, content)
                self.isConfigLoading_ = false
                if result then
                    self.isConfigLoaded_ = true
                    if not self.loginRewardData_ then
                        self.loginRewardData_ = content
                    end
                    if self.loadConfigCallback_ then
                        self.loadConfigCallback_(true, self.loginRewardData_)
                    end
                else
                    if self.loadConfigCallback_ then
                        self.loadConfigCallback_(false)
                    end
                end
            end), "loginReward", "data")
    elseif self.isConfigLoaded_ then
         if self.loadConfigCallback_ then
            self.loadConfigCallback_(true, self.loginRewardData_)
        end
    end
end

function LoginRewardController:getLoginRewardData()
    return self.loginRewardData_
end

function LoginRewardController:getProgressValue(day)
    if self.loginRewardData_ then
        local len = #self.loginRewardData_
        return day/self.loginRewardData_[len].day
    else
        return 0
    end
end

return LoginRewardController