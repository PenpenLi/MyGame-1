-- payHelper.lua
-- Last modification : 2016-06-12
-- Description: a helper to mamage each pay config moudle

local PayHelper = class()
local CacheHelper = require("game.cache.cache")
local DefaultCacheDict = "storeGoods"

function PayHelper:ctor(name)
    self.m_name = name or ""
end

-- process config from cache or url
function PayHelper:cacheConfig(url, callback)
    if self.isCachingConfig_ or not url then return end
    self.isCachingConfig_ = true
    self.m_cacheHelper = new(CacheHelper)
    self.m_cacheHelper:cacheFile(url, handler(self, function(obj, result, content)
            self.isCachingConfig_ = false
            callback(result, content)
        end), DefaultCacheDict, self.m_name)
end

function PayHelper:parsePrice(p)
    local s, e = string.find(p, "%d")
    local partDollar
    local partNumber
    local partNumberLen
    if s <= 1 then
        local lastNumIdx = 1
        while true do
            local st, ed = string.find(p, "%d", lastNumIdx + 1)
            if ed then
                lastNumIdx = ed
            else
                partDollar = string.sub(p, lastNumIdx + 1)
                partNumber = string.sub(p, 1, lastNumIdx)
                partNumberLen = string.len(partNumber)
                break
            end
        end
    else
        partDollar = string.sub(p, 1, s - 1)
        partNumber = string.sub(p, s)
        partNumberLen = string.len(partNumber)
    end

    local priceNum = 0
    local split, dot = "", ""
    local s1, e1 = string.find(partNumber, "%p")
    if s1 then
        --找到第一个标点
        local firstP = string.sub(partNumber, s1, e1)
        local s2, e2 = string.find(partNumber, "%p", s1 + 1)
        if s2 then
            --至少2个标点
            local secondP = string.sub(partNumber, s2, e2)
            if firstP == secondP then
                --2个一样的标点肯定分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                local sdb, sde = string.find(str, "%p")
                if sdb then
                    --去掉分隔符之后的肯定是小数点
                    dot = string.sub(str, sdb, sde)
                    str = string.gsub(str, "%" .. dot, ".")
                end
                priceNum = tonumber(str)
            else
                --2个标点不一样，前面的是分隔符，后面的是小数点
                split = firstP
                dot = secondP
                local str = string.gsub(partNumber, "%" .. split, "")
                str = string.gsub(str, "%" .. dot, ".")
                priceNum = tonumber(str)
            end
        else
            --只有一个标点
            if string.sub(partNumber, 1, s1 - 1) == "0" then
                --标点前面为0，这个标点肯定是小数点
                dot = firstP
                --把这个标点替换为 "."
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            elseif partNumberLen == e1 + 3 then
                --标点之后有3位，假定这个标点为分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            elseif partNumberLen <= e1 + 2 then
                --标点之后有2或1位，假定这个标点为小数点
                dot = firstP
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            elseif firstP == "," then
                --默认","为分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            elseif firstP == "." then
                --默认"."为小数点
                dot = firstP
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            else
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            end
        end
    else
        --找不到标点
        priceNum = tonumber(partNumber)
    end

    return partDollar, priceNum, split, dot
end


function PayHelper:callPayOrder(params,resultCallback,errorCallback)
    assert(params and params.id, "callPayOrder must has 'id'") --商品ID
    assert(params and params.pmode, "callPayOrder must has 'pmode'") -- 支付渠道标识

    local mid = nk.userData.mid
    local sitemid = nk.userData.sitemid
    params.mid = mid
    params.sitemid = sitemid
    params.scene  = nk.payScene or consts.PAY_SCENE.UNKNOW
    nk.HttpController:execute("createOrder", {game_param = params})
    -- nk.http.callPayOrder(params,function(callData)
    --     if resultCallback then
    --         resultCallback(callData)
    --     end
    -- end,function(errData)
    --     if errorCallback then
    --         errorCallback(errData)
    --     end
    -- end)
end

function PayHelper:getChipIcon(i,pchips)
    local iconArr = {100,101,102,103,104,105};
    if i then
        return iconArr[i];
    end
    return iconArr[(math.random(1,5))]
end

-- function PayHelper:parseConfig(data, itemCallback)
--     -- self.logger:debug(jsonString)
--     local json = data
--     local result = {}
--     result.skus = {}
--     result.chips = {}
--     result.props = {}
--     result.coins = {}
--     if json and json.chips then
--         -- table.sort(json.chips,function(t1,t2)
--         --     return tonumber(t1.pamount < t1.pamount)
--         -- end)
--         local chips = {}
--         result.chips = chips
--         for i = 1, #json.chips do

--             local chip = json.chips[i]
--             local prd = {}
--             prd.pid = chip.pid or chip.id or ""
--             prd.id = chip.id
--             prd.sid = chip.sid
--             prd.appid = chip.appid
--             prd.pmode = chip.pmode
--             prd.pamount = chip.pamount
--             prd.discount = chip.discount
--             prd.pcoins = chip.pcoins
--             prd.pchips = chip.pchips
--             prd.pcard = chip.pcard
--             prd.ptype = chip.ptype
--             prd.pnum = chip.pnum
--             prd.getname = chip.getname
--             prd.desc = chip.desc
--             prd.stag = chip.stag
--             prd.currency= chip.currency
--             prd.prid= chip.prid
--             prd.expire= chip.expire
--             prd.state= chip.state
--             prd.device= chip.device
--             prd.sortid= chip.sortid
--             prd.etime= chip.etime
--             prd.status= chip.status
--             prd.use_status= chip.use_status

--             --三公原有字段兼容处理
--             prd.price = chip.pamount or 0
--             prd.chipNum = chip.pchips or 0
--             prd.title = chip.getname or ""
--             prd.tag = chip["tag"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
--             prd.label = chip.label or 0
--             -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
--             local imgIdx = i;
--             if imgIdx > 5 then
--                 imgIdx = 5
--             end
--             prd.img = self:getChipIcon(imgIdx,chip.pchips)

--             -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
--             -- prd.title = chip.n or ""
--             -- prd.chipNum = chip.ch or ""
--             -- prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
--             if itemCallback then
--                 itemCallback("chips", chip, prd)
--             end
--             table.insert(chips, prd)
--             table.insert(result.skus, prd.pid)


--             --[[
--             local chip = json.chips[i]
--             local prd = {}
--             prd.pid = chip.pid
--             prd.id = chip.id
--             prd.price = chip.p
--             prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
--             prd.title = chip.n
--             prd.chipNum = chip.ch
--             prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
--             if itemCallback then
--                 itemCallback("chips", chip, prd)
--             end
--             table.insert(chips, prd)
--             table.insert(result.skus, prd.pid)
--             --]]
--         end
--     end
--     if json and json.props then
--         local props = {}
--         result.props = props
--         for i = 1, #json.props do
--             local prop = json.props[i]
--             local prd = {}
--             prd.pid = prop.pid
--             prd.id = prop.id
--             prd.detail = prop.d
--             prd.price = prop.p
--             prd.img = prop.u and prop.u ~= "" and prop.u or prd.id
--             prd.title = prop.n
--             prd.propId = prop.pr
--             prd.tag = prop["if"] == 1 and "hot" or (prop["if"] == 2 and "new" or "")
--             prd.propType = prop.pt
--             if itemCallback then
--                 itemCallback("props", prop, prd)
--             end
--             table.insert(props, prd)
--             table.insert(result.skus, prd.pid)
--         end
--     end
--     if json and json.coins then
--         local coins = {}
--         result.coins = coins
--         for i = 1, #json.coins do
--             local coin = json.coins[i]
--             local prd = {}
--             prd.pid = coin.pid
--             prd.id = coin.id
--             prd.price = coin.p
--             prd.img = coin.u and coin.u ~= "" and coin.u or prd.id
--             prd.title = coin.n
--             prd.coinNum = coin.co
--             prd.tag = coin["if"] == 1 and "hot" or (coin["if"] == 2 and "new" or "")
--             if itemCallback then
--                 itemCallback("coins", coin, prd)
--             end
--             table.insert(coins, prd)
--             table.insert(result.skus, prd.pid)
--         end
--     end
--     return result
-- end

-- function PayHelper:updateDiscount(products, paytypeConfig)
--     if not products or not paytypeConfig then return end
--     local itemDiscount = paytypeConfig.discount or {}
--     local chipDiscount = paytypeConfig.chipDiscount or 1
--     local coinDiscount = paytypeConfig.coinDiscount or 1
--     if products.chips then
--         for i, chip in ipairs(products.chips) do
--             local byIdDiscount = itemDiscount[chip.pid] and itemDiscount[chip.pid].dis
--             local byIdDiscountExpire = itemDiscount[chip.pid] and itemDiscount[chip.pid].expire
--             chip.discount = byIdDiscount or chipDiscount
--             chip.discountExpire = byIdDiscountExpire
--             if not chip.priceLabel then
--                 chip.priceLabel = "$" .. chip.price
--             end
--             local partDollar, priceNum
--             if chip.priceNum and chip.priceDollar then
--                 partDollar = chip.priceDollar
--                 priceNum = chip.priceNum
--             elseif not chip.priceNum then
--                 partDollar, priceNum = self:parsePrice(chip.priceLabel)
--                 chip.priceNum = priceNum
--                 chip.priceDollar = partDollar
--             else
--                 priceNum = chip.priceNum
--                 chip.priceDollar = self:parsePrice(chip.priceLabel)
--             end
--             if chip.discount ~= 1 then
--                 chip.rate = chip.chipNum * chip.discount / priceNum
--                 chip.chipNumOff = chip.chipNum * chip.discount
--             else
--                 chip.rate = chip.chipNum / priceNum
--             end
--             chip.rate = tonumber(string.format("%.2f", chip.rate))
--         end
--     end
--     if products.coins then
--         for i, coin in ipairs(products.coins) do
--             local byIdDiscount = itemDiscount[coin.pid] and itemDiscount[coin.pid].dis
--             local byIdDiscountExpire = itemDiscount[coin.pid] and itemDiscount[coin.pid].expire
--             coin.discount = byIdDiscount or coinDiscount
--             coin.discountExpire = byIdDiscountExpire
--             if not coin.priceLabel then
--                 coin.priceLabel = "$" .. coin.price / 100
--             end
--             local partDollar, priceNum
--             if coin.priceNum and coin.priceDollar then
--                 partDollar = coin.priceDollar
--                 priceNum = coin.priceNum
--             elseif not coin.priceNum then
--                 partDollar, priceNum = self:parsePrice(coin.priceLabel)
--                 coin.priceNum = priceNum
--                 coin.priceDollar = partDollar
--             else
--                 priceNum = coin.priceNum
--                 coin.priceDollar = self:parsePrice(coin.priceLabel)
--             end
--             if coin.discount ~= 1 then
--                 coin.rate = coin.coinNum * coin.discount / priceNum
--                 coin.coinNumOff = coin.coinNum * coin.discount
--             else
--                 coin.rate = coin.coinNum / priceNum
--             end
--             coin.rate = tonumber(string.format("%.2f", coin.rate))
--         end
--     end
--     if products.props then
--         for i, prop in ipairs(products.props) do
--             if not prop.priceLabel then
--                 prop.priceLabel = "$" .. prop.price / 100
--             end
--         end
--     end
-- end

function PayHelper:parseConfig(data, itemCallback)
    local json = data
    local result = {}
    result.skus = {}
    result.chips = {}
    if json and json.chips then
        local chips = {}
        result.chips = chips
        for i = 1, #json.chips do
            local chip = json.chips[i]
            local prd = {}
            prd.pid = chip.pid or chip.id or ""
            prd.id = chip.id
            prd.pmode = chip.pmode
            prd.pamount = chip.pamount
            prd.discount = chip.discount
            prd.getname = chip.getname
            prd.currency= chip.currency
            prd.pchips = chip.pchips
            prd.price = chip.pamount or 0
            prd.hot = chip.hot
            local imgIdx = i;
            if imgIdx > 5 then
                imgIdx = 5
            end
            prd.img = self:getChipIcon(imgIdx,chip.pchips)
            if itemCallback then
                itemCallback("chips", chip, prd)
            end

            if not prd.priceLabel then
                prd.priceLabel = "$" .. prd.price
            end

            if prd.discount then
                prd.fgetname = nk.updateFunctions.formatBigNumber(tonumber(prd.discount)*tonumber(prd.pchips) / 100 + tonumber(prd.pchips)) .. " koin"
            end

            table.insert(chips, prd)
            table.insert(result.skus, prd.pid)
        end
    end

    return result
end


return PayHelper
