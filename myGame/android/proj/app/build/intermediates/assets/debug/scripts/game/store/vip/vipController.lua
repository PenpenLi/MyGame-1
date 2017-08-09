-- VipController.lua
-- Last modification : 2016-11-2
-- 

local VipController =  class()

local CacheHelper = require("game.cache.cache")

function VipController.getInstance()
    VipController.instance = VipController.instance or new(VipController)
    return VipController.instance
end

function VipController.releaseInstance()
	delete(VipController.instance);
	VipController.instance = nil;
end

function VipController:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self.cache = new(CacheHelper)
end


function VipController:loadConfig(url, callback)
   if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false   
   end
    self.loadVipConfigCallback_ = callback
    self:loadConfig_()
end

function VipController:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        self.cache:cacheFile(self.url_ or nk.userData.VIP_JSON, function(result, content,stype)
            self.isConfigLoading_ = false
            if result then
                self.isConfigLoaded_ = true
                if not self.VipConfigData_ then
                    self.VipConfigData_ = content
                    if self.VipConfigData_ == nil then
                        print("vip  配置错误!!")
                    end
                end
                if self.loadVipConfigCallback_ and self.VipConfigData_ then
                    self.loadVipConfigCallback_(true, self.VipConfigData_)
                end
            else
                if self.loadVipConfigCallback_ then
                    self.loadVipConfigCallback_(false)
                end
            end
        end, "vip","data")
    elseif self.isConfigLoaded_ then
         if self.loadVipConfigCallback_ and self.VipConfigData_ then
            self.loadVipConfigCallback_(true, self.VipConfigData_)
        end
    end
end

function VipController:getAddition(vipLevel)
    if self.VipConfigData_ then
        local data = self.VipConfigData_[tostring(vipLevel)]
        if data then
            return data.data.vipName or "vip0",data.data.payment or 0
        end
    end

    return "vip0",0
end

function VipController:getLoginReward(vipLevel)
    if self.VipConfigData_ then
        local data = self.VipConfigData_[tostring(vipLevel)]
        if data then
            return data.data.loginPrize or 0
        end
    end

    return 
end

function VipController:getFriendNum(vipLevel)
   if self.VipConfigData_ then
       local data = self.VipConfigData_[tostring(vipLevel)]
       if data then
           return  data.data.friendNum or 300
       end
   end
end

function VipController:dispose()
    self.loadVipConfigCallback_ = nil
end


return VipController
