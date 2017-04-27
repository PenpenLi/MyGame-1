--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PromoteController =  class()

local CacheHelper = require("game.cache.cache")
local  PromotePopup = require("game.promote.promotePopup")

function PromoteController.getInstance()
    PromoteController.instance = PromoteController.instance or new(PromoteController)
    return PromoteController.instance
end

function PromoteController.releaseInstance()
	delete(PromoteController.instance);
	PromoteController.instance = nil;
end

function PromoteController:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self.cache = new(CacheHelper)
end


function PromoteController:loadConfig(url, callback)
   if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false   
   end
    self.loadPromoteConfigCallback_ = callback
    self:loadConfig_()
end

function PromoteController:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        self.cache:cacheFile(self.url_ or nk.userData.SKIP_JSON, function(result, content,stype)
            self.isConfigLoading_ = false
            if result then
                self.isConfigLoaded_ = true
                if not self.PromoteConfigData_ then
                    self.PromoteConfigData_ = content
                    if self.PromoteConfigData_ == nil then
                        print("skip  无配置!") -- 不显示弹窗
                    end
                end
                if self.loadPromoteConfigCallback_ then
                    self.loadPromoteConfigCallback_(true, self.PromoteConfigData_)
                end
            else
                if self.loadPromoteConfigCallback_ then
                    self.loadPromoteConfigCallback_(false)
                end
            end
        end, "promoteInfo", "data")
    elseif self.isConfigLoaded_ then
         if self.loadPromoteConfigCallback_ then
            self.loadPromoteConfigCallback_(true, self.PromoteConfigData_)
        end
    end
end

function PromoteController:isShow(owner)
	local num = nk.DictModule:getInt("gameData", "PromoteShowTimes", 0)

	local tempData = self.PromoteConfigData_
    -- tempData 可能为空，tempData["1"]也可能为空，都要判断下
	if num < 2 and tempData and nk.isFromLoginPromoteTag and tempData["1"] and tonumber(tempData["1"]["stime"] or 0) < os.time() and os.time() < tonumber(tempData["1"]["etime"] or 0) then --最后判断时间
		

		nk.DictModule:setInt("gameData", "PromoteShowTimes", num + 1)
        nk.DictModule:saveDict("gameData")

        nk.isFromLoginPromoteTag = false -- 从其他界面进入就不在弹了
        nk.PopupManager:addPopup(PromotePopup, owner)
	else

	end
end

-- function PromoteController:getAddition(vipLevel)
--     if self.PromoteConfigData_ then
--         local data = self.PromoteConfigData_[tostring(vipLevel)]
--         if data then
--             return data.data.vipName or "vip0",data.data.payment or 0
--         end
--     end

--     return "vip0",0
-- end

-- function PromoteController:getLoginReward(vipLevel)
--     if self.PromoteConfigData_ then
--         local data = self.PromoteConfigData_[tostring(vipLevel)]
--         if data then
--             return data.data.loginPrize or 0
--         end
--     end

--     return 
-- end

function PromoteController:dispose()
    self.loadPromoteConfigCallback_ = nil
end


return PromoteController


--endregion
