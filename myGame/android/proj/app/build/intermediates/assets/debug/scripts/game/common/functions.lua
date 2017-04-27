--
-- Author: tony
-- Date: 2014-08-01 10:35:58
--
local functions = {}

function functions.getCardDesc(handCard)
    if handCard then
        local value = bit.band(handCard, 0x0F)
        local variety = bit.band(handCard, 0xF0)       

        local p = ""
        if variety == 0x0 then
            p = "梅花"
        elseif variety == 0x10 then
            p = "方块"
        elseif variety == 0x20 then
            p = "红桃"
        elseif variety == 0x30 then
            p = "黑桃"
        end

        if value >= 2 and value <= 10 then
            p = p .. value
        elseif value == 11 then
            p = p .. "J"
        elseif value == 12 then
            p = p .. "Q"
        elseif value == 13 then
            p = p .. "K"
        elseif value == 1 then
            p = p .. "A"
        end

        if p == "" then
            return "无"
        else
            return p
        end
    else
        return "无"
    end
end

function functions.cacheKeyWordFile()
    local CacheHelper = require("game.cache.cache")
    local cacheHelper = new(CacheHelper)
    cacheHelper:cacheFile(nk.userData['urls.keyword'], handler(self, function(obj, result, content)
        if result then
            functions.keywords = content
        end
    end), "keywordfilter", "keywordfilter_key")
end

function functions.keyWordFilter(message, replaceWord)
    local replaceWith = replaceWord or "**"
    if not functions.keywords then
        functions.cacheKeyWordFile()
    else
        local searchMsg = string.lower(message)
        for i,v in pairs(functions.keywords) do
            local keywords = string.lower(v)
            local limit = 50
            while true do
                limit = limit - 1
                if limit <= 0 then
                    break
                end
                local s, e = string.find(searchMsg, keywords)
                if s and s > 0 then
                    searchMsg = string.sub(searchMsg, 1, s - 1) .. replaceWith ..string.sub(searchMsg, e + 1)
                    message = string.sub(message, 1, s - 1) .. replaceWith .. string.sub(message, e + 1)
                else
                    break
                end
            end
        end
    end
    return message
end

function functions.symbolFilter(message)
    local replaceWith = ""
    
    --匹配模式特殊字符，会被当成匹配符，所以往前加转义符%
    local temp = {"%.", "%%", "%+", "%-", "%*", "%?" ,"%[", "%^" ,"%$","%]","%(","%)"}   

    local searchMsg = (message)

    for i,v in ipairs(temp) do
        local keywords = tostring(v)
        local limit = 50
        while true do
            limit = limit - 1
            if limit <= 0 then
                break
            end
            local s, e = string.find(searchMsg, keywords)
            if s and s > 0 then
                searchMsg = string.sub(searchMsg, 1, s - 1) .. replaceWith ..string.sub(searchMsg, e + 1)
                message = string.sub(message, 1, s - 1) .. replaceWith .. string.sub(message, e + 1)
            else
                break
            end
        end
    end
    return message
end

function functions.badNetworkToptip()
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end

function functions.randomUUID()
    local uuid = nk.DictModule:getString("gameData", "UUID", "")
    if uuid == "" then
        math.randomseed(os.time());
        local words = "0123456789abcdefghijklmnopqrstuvwxyzqwQWERTYUIOPASDFGHJKLZXCVBNM"
        local wl = string.len(words)
        for i=1,32 do  
            local index = math.random(1,wl);
            uuid = uuid .. string.sub(words,index,index)
        end 
        nk.DictModule:setString("gameData", "UUID", uuid)
        nk.DictModule:saveDict("gameData")
    end
    return uuid
end

function functions.getUserInfo(default)
    local userInfo = nil
    if default ~= true then
        userInfo = {
            mavatar = nk.UserDataController.getMicon(), 
            name = nk.UserDataController.getUserName(),
            mlevel = nk.UserDataController.getMlevel(),
            mlose = nk.UserDataController.getLoseNum(),
            mwin = nk.UserDataController.getWinNum(),
            money = nk.functions.getMoney(), 
            msex = nk.UserDataController.getUserSex(),
            mexp = nk.UserDataController.getExp(),
            sitemid = nk.UserDataController.getSitemid(),
            giftId = nk.UserDataController.getGift(),
            sid = tonumber(nk.UserDataController.getSid()),
            lid = tonumber(nk.UserDataController.getLid()),
            vip = tonumber(nk.userData.vip),

            --[[
            终端类型、版本类型、渠道信息
            --]]
        }
        
    else
        userInfo = {
            mavatar = "", 
            name = T("游戏玩家"),
            mlevel = 3,
            mlose = 0,
            mwin = 0,
            money = 10000, 
            msex = 1,
            mexp = 100,
            sitemid = 0,
            giftId = 0,
            sid = 1,
            lid = 1,
            vip = 0,
        }
    end
    return userInfo 
end

-- 根据房间level获取配置
-- 房间ID,底注,最小下限,最大上限,快速进入数值,房间虚拟在线人数,台费,过费
function functions.getRoomDataByLevel(level,isSingle)
    local tb = nk.DataProxy:getData(nk.dataKeys.TABLE_NEW_CONF)
    FwLog("functions.getRoomDataByLevel = " .. json.encode(tb))
    local temp = {}

    if not isSingle then
        if nk.updateFunctions.checkIsNull(tb) then
            return temp
        end
        
        for _,group in pairs(tb) do
            for __,vv in pairs(group) do
                if (checkint(vv.serverid)) == (checkint(level)) then
                    temp.level = checkint(vv.serverid)  --server id
                    temp.baseAnte = checkint(vv.bets)  --底柱
                    temp.minBuyIn = checkint(vv.minmoney)  --最小买入
                    temp.maxBuyIn = checkint(vv.maxmoney)  --最大买入
                    temp.quickBuyIn = checkint(vv.roommoney) --快速进入设置
                    temp.online = checkint(0)   --在线人数
                    temp.fee = checkint(vv.tip) --台费
                    temp.pass = checkint(vv.passfree) --过费
                    temp.escapeMoney = checkint(vv.escapefree) --逃跑扣费
                    temp.prop = checkint(vv.prop) --道具费用
                    temp.expression = checkint(vv.expression) --表情费用
                    temp.name = vv.name --  100k
                    temp.typename = vv.typename --  Bonus
                    temp.backdrop = checkint(vv.backdrop) --  Bonus
                    return temp
                end
            end 
        end

        -- 上面没有，则从私人房列表中查找
        local privateRoomConf = nk.DataProxy:getData(nk.dataKeys.PRIVATE_ROOM_CONF)

        if nk.updateFunctions.checkIsNull(privateRoomConf) then
            return temp
        end

    --私人房
    -- "acttime"     = "12"
    -- "bankupmoney" = 破产值
    -- "bets"        = 底注
    -- "escapefree"  = "800000"
    -- "exp_lose"    = "5"
    -- "exp_win"     = "10"
    -- "expression"  = 表情费用
    -- "maxmoney"    = "3"
    -- "minmoney"    = 进入金币门槛
    -- "mlevel"      = 进入等级门槛
    -- "name"        = "200K"
    -- "passfree"    = 过费
    -- "prop"        = 道具费用
    -- "serverid"    = "1"
    -- "tip"         = "50000"

        for _,v in pairs(privateRoomConf) do
            if (checkint(v.serverid)) == (checkint(level)) then
                temp.level = checkint(v.serverid)
                temp.baseAnte = checkint(v.bets)  
                temp.minBuyIn = checkint(v.minmoney)
                temp.maxBuyIn = checkint(v.maxmoney)
                temp.quickBuyIn = checkint(v.bets)
                temp.online = checkint(v.online or 4)
                temp.fee = checkint(v.tip) 
                temp.pass = checkint(v.passfree) 
                temp.escapeMoney = checkint(v.escapefree)
                temp.expression = checkint(v.expression)
                temp.prop = checkint(v.prop)
                return temp
            end
        end
    else
        return functions.getSingleRoomData()
    end

    return temp
end

function functions.getRoomQiuQiuDataByLevel(level)
    assert(level, "level should not be nil or false")
    local tbQiuQiu = nk.DataProxy:getData(nk.dataKeys.TABLE_99_NEW_CONF)
    if not tbQiuQiu then
        return nil
    end
    -- FwLog("tbQiuQiu = " .. json.encode(tbQiuQiu))
    for _,group in pairs(tbQiuQiu) do
        for ___,vv in pairs(group) do
            if (checkint(vv.serverid)) == (checkint(level)) then
                local temp = {}
                temp.bets = checkint(vv.bets)         --底注
                temp.buyin = checkint(vv.buyin)          --默认买入
                temp.fee = checkint(vv.dealertip)          --打赏小费
                temp.expression = checkint(vv.expression)  --互动表情费用
                temp.levellimit = checkint(vv.levellimit)  --等级下限
                temp.maxbuyin = checkint(vv.maxbuyin)  --最大买入
                temp.maxEnter = checkint(vv.maxmoney)     --房间进入上限
                temp.minbuyin = checkint(vv.minbuyin)  --最小买入
                temp.minEnter = checkint(vv.minmoney)     --房间进入下限
                temp.pertime = checkint(vv.pertime)  --结算牌展示时间
                temp.prop = checkint(vv.prop)  --互动道具费用
                temp.roommoney = checkint(vv.roommoney)        --快速进入设置
                temp.level = checkint(vv.serverid)        --场次等级
                temp.waittime = checkint(vv.waittime)  --等待时间            
                temp.limit = checkint(0)        --快速开始筹码线
                temp.online = checkint(0)       --默认在线人数
                temp.slotBet = {}               --老虎机底注,是数组
                temp.backdrop = checkint(vv.backdrop)   --桌布颜色
                return temp
            end
        end
    end
    return nil
end

function functions.getSingleRoomData()
    return nk.LocalData.TableConfig
end

function functions.getRoomLevelByMoney(money)
    local tb = nk.DataProxy:getData(nk.dataKeys.TABLE_NEW_CONF)

    local level = nil

    if nk.updateFunctions.checkIsNull(tb) then
        return 0
    end

    for _,group in ipairs(tb) do
        for __,vv in ipairs(group) do
            if money <= tonumber(vv.roommoney) or tonumber(vv.roommoney) == 0 then
                return tonumber(vv.serverid)
            else 
                level = tonumber(vv.serverid)
            end
        end 
    end
    return level
end

function functions.getRoomQiuQiuLevelByMoney(money)
    local tb = nk.DataProxy:getData(nk.dataKeys.TABLE_99_NEW_CONF)

    local level = nil

    if nk.updateFunctions.checkIsNull(tb) then
        return 0
    end

    for _,group in ipairs(tb) do
        for __,vv in ipairs(group) do
            if money <= tonumber(vv.roommoney) or tonumber(vv.roommoney) == 0 then
                return tonumber(vv.serverid)
            else 
                level = tonumber(vv.serverid)
            end
        end 
    end
    return level
end

-- function functions.serverTableIDToClientTableID(table_id)
--     local server_id = table_id
--     -- 右移16位为server_id
--     bit.brshift(server_id, 16)
--     local real_table_id = table_id
--     bit.band(0x0000ffff, real_table_id)
    
--     return tostring(server_id) .. tostring(real_table_id)
-- end

-- -- 规定前3位为server_id (table_id_str为玩家输入ID)
-- function functions.clientTableIDToServerTableID(table_id_str)
--     local len = string.len(table_id_str)    
--     -- 异常 输入的只能为数字什么的判断
--     if len <= 3 then
--         --return error!!
--         return
--     end
--     local server_str = string.sub(table_id_str, 1, 4)
--     local real_table_id_str = string.sub(table_id_str, 4, len)
    
--     local server_id = tonumber(server_str)
--     local real_table_id = tonumber(real_table_id_str)
--     bit.blshift(server_id, 16)
--     return  server_id + real_table_id
-- end

function functions.exportMethods(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

function functions.getGeneralNumber()
    local uid = nk.UserDataController.getUid()
    return nk.DictModule:getInt("gameData", nk.cookieKeys.USER_GENERAL_NUMBER .. uid, 1)
end

function functions.setHasTips(flag)
    local uid = nk.UserDataController.getUid()
    nk.DictModule:setBoolean("gameData", nk.cookieKeys.USER_CARD_TIPS .. uid, flag)
end

function functions.getHasTips()
    local uid = nk.UserDataController.getUid()
    return nk.DictModule:getBoolean("gameData", nk.cookieKeys.USER_CARD_TIPS .. uid, false)
end

function functions.setSpaceShouldTips(flag)
    functions.spaceShouldTips = flag
end

function functions.getSpaceShouldTips()
    return functions.spaceShouldTips
end

function functions.setPassShouldTips(flag)
    functions.passShouldTips = flag
end

function functions.getPassShouldTips()
    return functions.passShouldTips
end

function functions.setShakeShouldTips(flag)
    functions.shakeShouldTips = flag
end

function functions.getShakeShouldTips()
    return functions.shakeShouldTips
end

function functions.shouldCardTips()
    local flag = false
    local generalNumber = functions.getGeneralNumber()
    local hasTips = functions.getHasTips()
    if generalNumber == 0 and not hasTips then
        flag = true
    end

    if flag then
        functions.setSpaceShouldTips(true)
        functions.setPassShouldTips(true)
        functions.setShakeShouldTips(true)
    end

    return flag
end

function functions.getInSeatNum(playerList,seatCount)
    local inSeat = 0
    for i=0,seatCount - 1 do
        local player = playerList[i]
        if player then
            inSeat = inSeat + 1
        end
    end
    return inSeat
end

function functions.checkMoneyisEnough(count,isRoom,roomLevel,price)
    local flag = false

    if isRoom and roomLevel then
        if roomLevel >= consts.QIUQIU_ROOM_LEVEL.LEVEL_MIN and roomLevel <= consts.QIUQIU_ROOM_LEVEL.LEVEL_MAX then
            local buyIn = nk.userData.roomBuyIn or 0
            if functions.getMoney() >= (price * count + buyIn) then
                flag = true
            end
        elseif roomLevel > 0 and roomLevel < consts.QIUQIU_ROOM_LEVEL.LEVEL_MIN then
            local roomData = nk.functions.getRoomDataByLevel(roomLevel) 
            if roomData then
                if functions.getMoney() - (price * count) >= roomData.minBuyIn then
                    flag = true
                end
            end
        end
    else
        if functions.getMoney() - (price * count) >= 0 then
            flag = true
        end
    end

    return flag
end

function functions.checkVersion()
    local upd = require("update.init")
    local params = 
    {
        device = (device.platform == "windows" and "android" or device.platform), 
        pay = (device.platform == "windows" and "android" or device.platform), 
        noticeVersion = "noticeVersion",
        osVersion = upd.conf.CLIENT_VERSION,
        version = upd.conf.CLIENT_VERSION,
        sid = GameConfig.ROOT_CGI_SID,
    }
    
    if IS_DEMO then
        params.demo = 1
    end

    nk.http.post_url(appconfig.VERSION_CHECK_URL,params,
        handler(functions, function (obj, data)
            if data then
                local retData = json.decode(data)
                functions.checkUpdate(retData.curVersion, retData.verTitle, retData.verMessage, retData.updateUrl)
            end
        end), 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))  
        end)
end

function functions.checkUpdate(curVersion, verTitle, verMessage, updateUrl)
    local latestVersionNum = bm.getVersionNum(curVersion)
    local installVersionNum = bm.getVersionNum(BM_UPDATE.VERSION)
    print("latestVersionNum:"..latestVersionNum)
    print("installVersionNum:"..installVersionNum)

    if latestVersionNum <= installVersionNum then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("UPDATE", "HAD_UPDATED"))
    else
        local UpdatePopup = import("app.module.settingAndhelp.setting.UpdatePopup")
        UpdatePopup.new(verTitle, verMessage, updateUrl):show()
    end
end

-- 获得低位值(牌下面的点数)
function functions.getLowPoint(card)
    return bit.band(card, 0x0F)
end

-- 获得高位值(牌上面的点数)
function functions.getHighPoint(card)
    return bit.band(card, 0xF0) / 16
end

function functions.getPointSum(card)
    local low = functions.getLowPoint(card)
    local height = functions.getHighPoint(card)
    return low + height
end

function functions.getMoney(moneyOnLine)
    -- dump(nk.isInSingleRoom, "nkisInSingleRoom = ")
    local money = nk.UserDataController.getUserMoney()
    -- dump(money, "getMoneygetMoney = ")
    if moneyOnLine then
        -- dump("moneyOnLinemoneyOnLinemoneyOnLinemoneyOnLine getMoney")
    end
    if not moneyOnLine then
        if nk.isInSingleRoom then
            money = nk.UserDataController.getSingleMoney()
            -- dump(money, "   getMoney singleMoneysingleMoney" )
        end
    end
    return money
end

function functions.setMoney(money,moneyOnLine)
    -- dump(nk.isInSingleRoom, "nkisInSingleRoom = ")
    if moneyOnLine then
        -- dump("moneyOnLinemoneyOnLinemoneyOnLinemoneyOnLine setMoney")
    end
    if moneyOnLine then
        nk.UserDataController.setUserMoney(money)
    elseif nk.isInSingleRoom then
        nk.UserDataController.setSingleMoney(money)
    else
        nk.UserDataController.setUserMoney(money)
    end 
end

function functions.shJoins(data,isSig)
    local str = "[";
    local key = {};
    local sig = 0;

    if data == nil then
        str = str .. "]";
        return str;
    end

    for i,v in pairs(data) do
        table.insert(key,i);
    end
    table.sort(key);
    for k=1,table.maxn(key) do
        sig = isSig;
        local b = key[k];
        if sig ~= 1 and string.sub(b,1,4) == "sig_" then
            sig = 1;
        end
        local obj = data[b];
        local oType = type(obj);
        local s = "";
        if sig == 1 and oType ~= "table" then
            str = string.format("%s&%s=%s",str.."",b,obj);
        end
        if oType == "table" then
            str = string.format("%s%s=%s",str.."",b,functions.shJoins(obj,sig));
        end
    end
    str = str .. "]";
    return str;
end

function functions.Joins(t, mtkey)
    local str = "M";
    if t == nil or type(t) == "boolean"  or type(t) == "byte" then
        return str;
    elseif type(t) == "number" or type(t) == "string" then
        str = string.format("%sT%s%s", str.."", mtkey, string.gsub(t, "[^a-zA-Z0-9]",""));
    elseif type(t) == "table" then
        for k,v in orderedPairs(t) do
            str = string.format("%s%s=%s", str, tostring(k), functions.Joins(v, mtkey));
        end
    end
    return str;
end

-- 多维数组转一维数组
function functions.toOneDimensionalTable(table, prefix, root)
    if prefix == nil then
        prefix = ""
        root = table
    end
    for k,v in pairs(clone(table)) do               
        local rootkey = k
        if prefix ~= "" then
            rootkey = prefix.."."..k
        end

        if type(v) == "table" then
            if #v == 0 then --是kv数组  (这一步有问题，如果字典v里面有数组的类型，会丢失 --by ziway)
                functions.toOneDimensionalTable(v, rootkey, root)
                if prefix == "" then
                    root[k] = nil
                end
            end
        else
            if prefix ~= "" then
                root[rootkey] = v
            end
        end
    end  

end

-- 类型批量转换
function functions.typeFilter(table, types)
    for func,keys in pairs(types) do
        for _,key in ipairs(keys) do
            if table[key] ~= nil then
                table[key] = func(table[key])
            end
        end
    end
end

function functions.removeFromParent(ctr, clean)
    local parent = ctr:getParent();
    if parent then
        parent:removeChild(ctr, clean);
    end
end

function functions.formatMemberInfo(data)
    functions.typeFilter(data.aUser,{
                [tostring] = {'name','sitemid','mcity','micon'},
                [tonumber] = {
                    'lid', 'mid', 'mlevel', 
                    'win', 'lose','money', 
                    'exp','msex'
                }
            })

   functions.typeFilter(data.aBest,{
                [tostring] = {'maxwcard','maxwcardvalue'},
                [tonumber] = {'maxmoney', 'maxwmoney'}
            })
end


function functions.updataChatRecord()
    if nk.userData and nk.userData.chatRecord then
        nk.userData.chatRecord = nk.userData.chatRecord
    end
end

function functions.formatAbsolutePos(ctr)
    local x, y = ctr:getAbsolutePos()
    x = x * System.getLayoutScale()
    y = y * System.getLayoutScale()
    return x, y
end

-- 1.5.0 版本开始 图像不和性别挂钩
-- function functions.getDefaulHeadIcon(msex)
--     local icon 
--     if tonumber(msex) == 2 then
--         icon = kImageMap.common_female_avatar
--     else
--         icon = kImageMap.common_male_avatar
--     end
--     return icon
-- end

function functions.getDefaulSexIcon(msex)
    local icon 
    if tonumber(msex) == 2 then
        icon = kImageMap.common_sex_woman_icon
    else
        icon = kImageMap.common_sex_man_icon
    end
    return icon
end

-- 暂用于统计 system error 
function functions.report_lua_error_Temp()
    local params = 
    {
       sid         = GameConfig.ROOT_CGI_SID,
       lid         = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST"), 
       apkVer      = GameConfig.CUR_VERSION, 
    }
    local info = json.encode(params)   
    errStr = "System Error" .. "\n uid = " .. tostring(nk.userData.uid) .. "\n userInfo = " .. info
    nk.UmengNativeEvent:reportError(errStr)
end

-- -- 上传照片
-- function functions.uploadPhoto(status,path,posIndex,imgIndex)
--     if status then
--         local http2 = require('network.http2')
--         local iconKey = '~#kevin&^$xie$&boyaa'
--         local time = os.time()
--         local sig = md5_string(nk.userData.uid .. "|" .. 1 .. "|" .. time .. iconKey)
--         http2.request_async({
--         url = nk.userData.UPLOAD_PIC,
--         post = {
--                 {
--                     type = 'file',
--                     filepath = path,
--                     name = "upload",
--                     file_type = "image/png",
--                 },
--                 {
--                     type = "content",
--                     name = "sid",
--                     contents = "1",
--                 },
--                 {
--                     type = "content",
--                     name = "mid",
--                     contents = tostring(nk.userData.uid),
--                 },
--                 {
--                     type = "content",
--                     name = "time",
--                     contents = tostring(time),
--                 },
--                 {
--                     type = "content",
--                     name = "sig",
--                     contents = tostring(sig),
--                 },
--                 {
--                     type = "content",
--                     name = "index",
--                     contents = tostring(imgIndex),
--                 },
--                 {
--                     type = "content",
--                     name = "posIndex",
--                     contents = tostring(posIndex),
--                 },

--          }
--        },
--          function(rsp)
--             if rsp.errmsg then              
--                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PHOTO_FAIL"))
--             else
--                 if System.getPlatform() == kPlatformAndroid then
--                     System.removeFile(path)
--                 end
--                 -- Log.dump(rsp, "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
--                 if not (rsp.code >= 200 and rsp.code <= 209) then
--                     -- network error
--                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PHOTO_FAIL"))
--                     return
--                 end
--                 local content = json.decode(rsp.content)
--                 assert(content, "UPLOAD_PIC fail with rep = " .. rsp.content)
--                 nk.HttpController:execute("Member.updateUserIcon", {game_param = {iconname = nk.userData.uid,
--                     index = content.index,
--                     iconIndex=nk.userData.headIconIndex,posIndex = content.posIndex}}, nil, handler(self, function (obj, errorCode, data)
--                 if errorCode == 1 and data then
--                     if data.code ~= 1  then
--                         nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PHOTO_FAIL"))
--                         return
--                     end
--                     if data.data.posIndex==nk.userData.headIconIndex then
--                         if data.data.micon and data.data.micon ~="" then
--                             if string.find(data.data.micon,"http") then
--                                 nk.userData["micon"] = data.data.micon
--                             else
--                                 nk.userData["micon"] = nk.userData.iconurl..data.data.micon
--                             end
--                             nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "CHANGE_HEAD_ICON_SUCCESS"))
--                         end
--                     else
--                         nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PHOTO_SUCCESS"))
--                     end
--                     assert(nk.userData.photos[data.data.posIndex], "data.data.posIndex error with php callback =" .. json.encode(data))
--                     nk.userData.photos[data.data.posIndex].url = data.data.micon
--                     EventDispatcher.getInstance():dispatch(EventConstants.update_photo, data.data.posIndex, data.data.micon)
--                     end
--                 end ))
--             end
--          end
--         )
--    else
--        Log.printInfo("ChangeHeadPopup","get headpic faild !")
--    end
-- end


function functions.getAngle(p1,p2)
    local angle = 0
    if p2.x > p1.x then
        if p2.y>p1.y then
            angle = math.deg(math.atan((p2.y-p1.y)/(p2.x-p1.x)))
        elseif p2.y<p1.y then
            angle = math.deg(math.atan((p2.y-p1.y)/(p2.x-p1.x))) + 360 
        else
            angle = 0        
        end
    elseif p2.x< p1.x then
        if p2.y>p1.y then
            angle = math.deg(math.atan((p2.y-p1.y)/(p2.x-p1.x))) + 180
        elseif p2.y<p1.y then
            angle = math.deg(math.atan((p2.y-p1.y)/(p2.x-p1.x))) + 180
        else
            angle = 180        
        end
    else
        if p2.y>p1.y then
            angle = 90
        elseif p2.y<p1.y then
            angle = 270   
        end
    end
    return angle
end

function functions.getExpImagesList(id,frameNum,isNewExp)
    local name =  "res/roomChat/expNormal/expNormal_%d_%04d.png"
    if isNewExp == 1 then
        if id >= 100 and id <= 110 then
            name =  "res/roomChat/punakawan/%d/expPunakawan_%d_%04d.png"
        elseif id >= 111 and id <= 118 then
            name =  "res/roomChat/punakawan/%d/expPunakawan2_%d_%04d.png"
        end
    elseif isNewExp == 2 then
        name =  "res/roomChat/expVip/%d/expVip_%d_%04d.png"
    end

    local imageName = nil
    local list = {}
    for i=1,frameNum do
        if isNewExp == 0 then
            imageName = string.format(name,id,i)
        elseif isNewExp == 1 or isNewExp == 2 then
            imageName = string.format(name,id%100,id,i)
        end
        table.insert(list,imageName)
    end

    return list, imageName
end

function functions.updatePosAlignCenter(node)
    if node then
        local parent = node:getParent()
        if not parent then
            return
        end
        local pW,pH = parent:getSize()
        local w,h = node:getSize()
        local x,y = node:getPos()
        local oldAlign = node:getAlign()
        node:setAlign(kAlignCenter)
        if kAlignTop == oldAlign then
            node:setPos(x,y+h*0.5-pH*0.5)
        elseif kAlignTopRight == oldAlign then 
            node:setPos(-x-w*0.5+pW*0.5,y+h*0.5-pH*0.5)    
        elseif kAlignRight == oldAlign then     
            node:setPos(pW*0.5-x-w*0.5,y)
        elseif kAlignBottomRight == oldAlign then 
            node:setPos(-x-w*0.5+pW*0.5,-y-h*0.5+pH*0.5)    
        elseif kAlignBottomLeft == oldAlign then   
            node:setPos(x+w*0.5-pW*0.5,-y-h*0.5+pH*0.5)  
        elseif kAlignBottom == oldAlign then     
            node:setPos(x,pH*0.5-y-h*0.5)
        elseif kAlignLeft == oldAlign then  
            node:setPos(x+w*0.5-pW*0.5,y)   
        elseif kAlignTopLeft == oldAlign then 
            node:setPos(x+w*0.5-pW*0.5,y+h*0.5-pH*0.5)    
        end
    end
end


function functions.createSmartText(str,font,fontSize,r,g,b,clipW)
    if not clipW then
        local content = new(Text,str,0,0,kAlignCenter,font,fontSize,r or 255,g or 255,b or 255)
        return content
    else
        local content = new(Text,str,0,0,kAlignCenter,font,fontSize,r or 255,g or 255,b or 255)
        content:setAlign(kAlignCenter)
        local w,h = content:getSize()
        if clipW >= w then
            return content
        else
            local clip = new(Image,kImageMap.common_transparent)
            clip:setAlign(kAlignCenter)
            clip:setSize(clipW, h)
            clip:setClip2(true, 0, 0,clipW, h)
            local oX = clipW*0.5+10+w*0.5
            content:setPos(oX,0)
            clip:addChild(content)
            local tX = -clipW*0.5-10-w*0.5
            local move = nil
            move = function( ... )
                content:moveTo({x = tX, time = (oX-tX)/40,onComplete = handler(self, function()
                    content:setPos(oX,0) 
                    move()
                    end)
                })
            end
            move()
            return clip
        end    
    end
end

function functions.addPropIconTo(parent, data, gridSize, itemObj)
    if not data then return end
    local icon = new(Image, kImageMap.common_transparent)
    icon:addTo(parent)
    -- icon:setSize(40, 40)
    icon:setAlign(kAlignCenter)
    icon:setSize(90, 90)
    local PropManager = require("game.store.prop.propManager")
    PropManager.getInstance():getPropListById(PropManager.TYPE_PROP, function(status, propType, configArr)
        if status and not tolua.isnull(icon) then
            if configArr then
                for i = 1, #configArr do
                    if(tonumber(configArr[i]["pnid"]) == tonumber(data.pnid)) then
                        functions.loadPropIconToImage(icon, configArr[i]["image"], gridSize)
                        if itemObj then
                            itemObj.config = configArr[i]
                        end
                        break
                    end
                end
            end
        end
    end)
    return icon
end

function functions.loadPropIconToImage(imageIcon, url, maxGridSize)
    if maxGridSize then
        local originSetFileFunc = imageIcon.setFile
        imageIcon.setFile = function(...)
            originSetFileFunc(...)
            local w, h = imageIcon:getSize()
            if w >= maxGridSize or h >= maxGridSize then
                local scale = math.min(maxGridSize/w, maxGridSize/h)
                imageIcon:setSize(w * scale, h * scale)
            end
            imageIcon.setFile = originSetFileFunc
        end
    end
    UrlImage.spriteSetUrl(imageIcon, url, false)
end

function functions.loadIconToNode(nodeImage, micon, msex, isAvatar)
    if string.find(micon, "http") then
        -- local index = tonumber(micon) or 1
        -- nodeImage:setFile(nk.s_headFile[index])-- 默认头像 
        nodeImage:setFile(kImageMap.userInfo_nophoto)
        UrlImage.spriteSetUrl(nodeImage, micon)-- 上传的头像
    else
        if tonumber(msex) == 1 then
            nodeImage:setFile("res/photoManager/avatar_big_male.png")
        else
            nodeImage:setFile("res/photoManager/avatar_big_female.png")
        end
    end 
end

function functions.getStrOfLeftTime(leftTime)
    local space = " "
    local strLeftTime = nil
    local day = checkint(leftTime / (24 * 3600))
    if day <= 0 then
        local leftTime = math.max(leftTime, 0)
        local dictStr = {
            hour = bm.LangUtil.getText("COMMON", "HOUR"),
            min = bm.LangUtil.getText("COMMON", "MINUTE"),
            -- sec = bm.LangUtil.getText("COMMON", "SECOND")
            }
        local hour = math.floor(leftTime/3600)
        if hour >= 1 then 
            strLeftTime = hour .. space .. dictStr.hour end
        if hour == 0 then 
            strLeftTime = string.format("%02d", math.floor(leftTime/60)) .. space .. dictStr.min --.. string.format("%02d", timeInt%60) .. dictStr.sec
        end
    else
        strLeftTime = day .. space .. bm.LangUtil.getText("COMMON", "DAY")
    end
    return strLeftTime
end

function functions.registerImageTouchFunc(image, instance, touchFunc)
    local clickPos
    local isMove
    image:setEventTouch(instance, function(_, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
        if finger_action == kFingerDown then
            clickPos = {x = x, y = y}
        elseif finger_action == kFingerMove then
            if math.abs(x - clickPos.x) > 5 or math.abs(y - clickPos.y) > 5 then
                isMove = true
            end
        elseif finger_action == kFingerUp then
            if isMove then 
                isMove = false
                return 
            end
            touchFunc(instance)
        end
    end)
end

function functions.uploadPhoto(path)
    local http2 = require('network.http2')
    Log.dump(path, "<<<<<<<<   path1111111")

    local table = {
        mid = MID,
        gid = 2,
        param = {method = "User.uploadIcon"}
    }

    http2.request_async({
         url = HttpConfig.BASE_URL,
         post = {
                  {
                    type = 'file',
                    filepath = path,
                    name = "icon",
                    file_type = "image/png",
                  },
                  {
                    type = "content",
                    name = "api",
                    contents = json.encode(table),
                  },
         }
       },
         function(rsp)
            Log.dump(rsp,">>>  uploadHead.rsp")
            if rsp.code == 200 and rsp.content ~= nil then

                local content = json.decode(rsp.content)
                -- Log.dump(content, "<<content")
                local iconUrl = content.data.middle .. "?" ..os.time() 
                nk.DictModule:setString("playerAvatar", "iconUrl", iconUrl)
                nk.DictModule:saveDict("playerAvatar")

                EventDispatcher.getInstance():dispatch(EventConstants.changeHeadSuccess)
            end
         end
    )

end



return functions
