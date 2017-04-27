-- loadLevelControl.lua
-- Last modification : 2016-05-25
-- 

local LoadLevelControl =  class()
local instance

local CacheHelper = require("game.cache.cache")

function LoadLevelControl.getInstance()
    instance = instance or new(LoadLevelControl)
    return instance
end

function LoadLevelControl:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self.cache1 = new(CacheHelper)
    self.cache2 = new(CacheHelper)
end


function LoadLevelControl:loadConfig(url, callback)
   if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false   
   end
    self.loadLevelConfigCallback_ = callback
    self:loadConfig_()
end

function LoadLevelControl:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        -- local cacheHelper_ = new(CacheHelper)
        self.cache1:cacheFile(self.url_ or nk.userData.LEVEL_JSON, function(result, content,stype)
            self.isConfigLoading_ = false
            if result then
                self.isConfigLoaded_ = true
                if not self.levelData_ then
                    self.levelConfigData_ = content
                    if self.levelConfigData_ == nil then
                        print("level  配置错误!!")
                    else
                        self.levelData_ = self:processLevelData(self.levelConfigData_)
                    end
                end
                if self.levelData_ then
                    for k, v in pairs(self.requests_) do
                        local called = false
                        if v.getType then
                            v.called = true
                            if v.callback then
                                v.callback(v.dealFun((v.exp or v.level or v.title),self.levelData_),v.obj)
                            end
                            self.requests_[k] = nil
                            -- break;
                        end
                    end
                end
                if self.loadLevelConfigCallback_ then
                    self.loadLevelConfigCallback_(true, self.levelData_)
                end
            else
                if self.loadLevelConfigCallback_ then
                    self.loadLevelConfigCallback_(false)
                end
            end
        end, "level","data")
    elseif self.isConfigLoaded_ then
         if self.loadLevelConfigCallback_ then
            self.loadLevelConfigCallback_(true, self.levelData_)
        end
    end
end

-- {"Lv2","博定新手",29,"20个道具"}  等级，称号，经验，奖励
function LoadLevelControl:processLevelData(jsonData)

    local ret = {}
    local itemData
    local lv
    for k,v in pairs(jsonData) do
        itemData = {}
        lv = string.sub(v[1],3)
        -- itemData.level = tonumber(lv)
        itemData.level = tonumber(v[1])
        itemData.title = v[2] or ""
        itemData.exp = tonumber(v[3])
        itemData.reward = v[4] or ""
        table.insert(ret,itemData)
    end
    local lastExp = 0
    local t
    for i = #ret, 1, -1 do
        t = ret[i]
        t.needExp = lastExp > t.exp and lastExp - t.exp or 0
        lastExp = t.exp
    end
    return ret
end

function LoadLevelControl:cancel(requestId)
    self.requests_[requestId] = nil
end


--根据等级获得称号
function LoadLevelControl:getTitleByLevel(level, callback)
    local dealFun = 
    function(tlevel,levelData)
        local t
        for i=1,#levelData do
            t = levelData[i]
            if tonumber(t.level) == tonumber(tlevel) then
                return t.title
            end
        end
    end


    if self.isConfigLoaded_ then
        if self.levelData_ then
            local title = dealFun(level,self.levelData_);
            return title;
        end
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {level=level, callback=callback,getType = "getTitleByLevel",dealFun = dealFun}
        self:loadConfig_()
        return "",self.requestId_
    end
end


--根据经验获得等级
function LoadLevelControl:getLevelByExp(exp,callback)
    exp = exp or 1
    local dealFun = 
    function(texp,levelData)
        local t
        for i=1,#levelData do
            t = levelData[i]
            if tonumber(t.exp) == tonumber(texp) then
                return i or 1
            elseif tonumber(t.exp) > tonumber(texp) then
                local j
                if i - 1 < 1 then
                    j = 1
                else
                    j =  i - 1
                end

                return j or 1;

            end
        end

        return #levelData or 1
    end


    if self.isConfigLoaded_ then
        if self.levelData_ then
            return dealFun(exp,self.levelData_)
        end
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {exp=exp, callback=callback,getType = "getLevelByExp",dealFun = dealFun}
        self:loadConfig_()
        return 1,self.requestId_
    end

end



--根据经验获得称号
function LoadLevelControl:getTitleByExp(exp,callback)

    local dealFun = function(texp)
        local level = self:getLevelByExp(exp)
        return self:getTitleByLevel(level)
    end

    if self.levelData_ then
        return dealFun(exp)
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {exp=exp, callback=callback,getType = "getTitleByExp",dealFun = dealFun}
        self:loadConfig_()
        return "",self.requestId_
    end
    
end




--根据经验值获得经验值升级进度 
--@return  进度百分比,升级已获得经验，升级总经验
--ratio, progress, all, nothing, nextLevelReward
function LoadLevelControl:getLevelUpProgress(exp,callback, obj)
    local dealFun = 
    function(texp,levelData)
        local tlevel = self:getLevelByExp(texp)
        local nextLevel = (tlevel + 1 <= #levelData and tlevel + 1 or #levelData)
        if tlevel == nextLevel then
            return 0, 0, 0, nil, 0
        else
            local progress = texp - levelData[tlevel].exp
            local all = levelData[tlevel].needExp
            return progress / all, progress, all, nil, levelData[nextLevel].reward
        end
    end

    if self.levelData_ then
        if callback then
            callback(dealFun(exp,self.levelData_))
        end
        return dealFun(exp,self.levelData_)
    else
        if callback then
            callback(0,0,0)
        end
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {exp=exp, callback=callback,getType = "getTitleByExp",dealFun = dealFun, obj = obj}
        self:loadConfig_()

        return 0, 0, 0, 0
    end 
end

function LoadLevelControl:getLevelConfigData()
    return self.levelConfigData_
end

function LoadLevelControl:isConfigLoaded()
    return self.isConfigLoaded_
end




-----------------------------------------------------------for get exp config begin----------------------------------
function LoadLevelControl:loadExpConfig(url, callback)
   if self.url_ ~= rul then
        self.url_ = url
        self.isExpConfigLoaded_ = false
        self.isExpConfigLoading_ = false       
   end
    self.loadExpConfigCallback_ = callback
    self:loadExpConfig_() 
end

function LoadLevelControl:loadExpConfig_()
    if not self.isExpConfigLoaded_ and not self.isExpConfigLoading_ then
        self.isExpConfigLoading_ = true
        -- local cacheHelper_ = new(CacheHelper)
        self.cache2:cacheFile(self.url_ or nk.userData.EXP_JSON ,function(result, content, stype)
            self.isExpConfigLoading_ = false
            if result then
                self.isExpConfigLoaded_ = true
                if not self.expData_ then
                    self.expConfigData_ = content
                    if self.expConfigData_ == nil then
                        print("level 配置错误!!")
                    else 
                        self.expData_ = self:processExpData(self.expConfigData_)
                    end
                end
                if self.loadExpConfigCallback_ then
                     self.loadExpConfigCallback_(true, self.expData_)
                end
            else
                if self.loadExpConfigCallback_ then
                    self.loadExpConfigCallback_(false)
                end
            end
        end,"exp","data")
    elseif self.isExpConfigLoaded_ then
        if self.loadExpConfigCallback_ then
             self.loadExpConfigCallback_(true, self.expData_)
        end
    end
end

-- {"Lv2","博定新手",29,"20个道具"}  等级，称号，经验，奖励
function LoadLevelControl:processExpData(jsonData)

    local ret = {}
    local itemData
    local lv
    for k,v in pairs(jsonData) do
        itemData = {}
        itemData.place=v[1] or ""
        itemData.baseChip=v[2]
        itemData.noWin=tonumber(v[3]) --为啥这个地方用no win而不是lose,因为还有可能是弃牌，那问题来了，弃牌怎么能说人家输了了。
        itemData.win=v[4] or ""
        table.insert(ret,itemData)
    end
    return ret
end


function LoadLevelControl:getExpConfigData()
    return self.expConfigData_
end

-----------------------------------------------------------for get exp config end----------------------------------
return LoadLevelControl