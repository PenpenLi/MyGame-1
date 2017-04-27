-- propHelper.lua
-- Last modification : 2016-06-12
-- Description: a helper to mamage each pay config moudle

local PropHelper = class()
local CacheHelper = require("game.cache.cache")
local DefaultCacheDict = "storeProp"

function PropHelper:ctor(name)
    self.m_name = name or ""
end

-- process config from cache or url
function PropHelper:cacheConfig(url, callback)
    if self.isCachingConfig_ then return end
    self.isCachingConfig_ = true

    self.m_cacheHelper = new(CacheHelper)
    self.m_cacheHelper:cacheFile(url, handler(self, function(obj, result, content)
            self.isCachingConfig_ = false
            callback(result, content)
        end), DefaultCacheDict, self.m_name)
end

function PropHelper:callPayOrder(params,resultCallback,errorCallback)
    assert(params and params.id, "callPayDelivery must has 'id'") --商品ID
    assert(params and params.pmode, "callPayDelivery must has 'pmode'") -- 支付渠道标识
    local mid = nk.userData.mid
    local sitemid = nk.userData.sitemid
    params.mid = mid
    params.sitemid = sitemid
    
    nk.HttpController:execute("createOrder", {game_param = params})
end

return PropHelper
