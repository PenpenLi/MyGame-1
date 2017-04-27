-- 开关控制
-- Author: LeoLuo
-- Date: 2015-06-12 16:30:43
--

local OnOff = class()
-- local logger = bm.Logger.new("OnOff")

function OnOff:ctor()
	self.onoff_ = {}
    self.version_ = {}
end

function OnOff:init(retData)
    self.onoff_ = retData.open
    self.version_ = retData.version
end

function OnOff:check(name)
	return isset(self.onoff_, name) and tonumber(self.onoff_[name]) == 1
end

function OnOff:checkVersion(name, version)
    return isset(self.version_, name) and self.version_[name] == version
end

function OnOff:checkLocalVersion(name)
    local version = nk.DictModule:getString("gameData", nk.cookieKeys.CONFIG_VER.."_"..name, 0)
    -- FwLog("name = " .. name .. ", version = " .. version .. ", self.version_ = " .. self.version_[name])
    return self:checkVersion(name, version)
end

function OnOff:saveNewVersionInLocal(name)
	if self.version_ then
        -- FwLog("saveNewVersionInLocal -> name = " .. name .. ", self.version_ = " .. self.version_[name])
    	nk.DictModule:setString("gameData", nk.cookieKeys.CONFIG_VER.."_"..name, self.version_[name] or 0)
        nk.DictModule:saveDict("gameData")
    end
end

return OnOff