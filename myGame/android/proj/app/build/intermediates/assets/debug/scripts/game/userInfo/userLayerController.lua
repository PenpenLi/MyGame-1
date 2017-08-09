--
-- userLayerController.lua
-- Date: 2016-06-06 10:00:54
--
local userLayerController =  class()
local instance

function userLayerController.getInstance()
    instance = instance or userLayerController.new()
    return instance
end

function userLayerController:ctor()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self:registerProcesser()
end

function userLayerController:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, userLayerController.onHttpPorcesser)
end

function userLayerController:registerProcesser()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, userLayerController.onHttpPorcesser)
end

function userLayerController:onHttpPorcesser(command, errorCode, data)
    if command == "propConfig" then
        self.isConfigLoading_ = false
        if errorCode ~= 1 then
            return
        end 
        self:setLogoutConfig(data)
    end
end

function userLayerController:loadLogoutConfig(callback)
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self.loadLogoutConfigCallback_ = callback
    self:loadLogoutConfig_()
end

function userLayerController:loadLogoutConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        self:requireLogoutConfig()
    elseif self.isConfigLoaded_ then
         if self.loadLogoutConfigCallback_ then
            self.loadLogoutConfigCallback_(true, self.logoutData_)
        end
    end
end

function userLayerController:requiredataConfig()
    nk.HttpController:execute("propConfig", {}, nk.userData.PROPS_JSON)
end

function userLayerController:setLogoutConfig(data)
    self.isConfigLoaded_ = true
    self.logoutData_ = data
    if self.loadLogoutConfigCallback_ then
        self.loadLogoutConfigCallback_(true, self.logoutData_)
    end
end

return userLayerController
