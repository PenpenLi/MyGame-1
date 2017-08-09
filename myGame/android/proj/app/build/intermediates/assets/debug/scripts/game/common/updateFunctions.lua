--
-- Author: tony
-- Date: 2014-07-11 13:47:18
--
-- require("lfs")
-- local socket = require("socket")
local utf8 = import(".utf8")

local functions = {}

function functions.getTime()
    return socket.gettime()
end

-- function functions.isFileExist(path)
--     -- return path and CCFileUtils:sharedFileUtils():isFileExist(path)
--     if path then
--         local file = io.open(path, "rb")
--         if file then
--             file:close()
--             return true
--         end
--     end
--     return false
-- end

function functions.isDirExist(path)
    local success, msg = lfs.chdir(path)
    return success
end
 
function functions.mkdir(path)
    if not functions.isDirExist(path) then
        local prefix = ""
        if string.sub(path, 1, 1) == device.directorySeparator then
            prefix = device.directorySeparator
        end
        local pathInfo = string.split(path, device.directorySeparator)
        local i = 1
        while(true) do
            if i > #pathInfo then
                break
            end
            local p = string.trim(pathInfo[i] or "")        --string.trim删除字符串两端的空白字符
            if p == "" or p == "." then
                table.remove(pathInfo, i)
            elseif p == ".." then
                if i > 1 then
                    table.remove(pathInfo, i)
                    table.remove(pathInfo, i - 1)
                    i = i - 1
                else
                    return false
                end
            else
                i = i + 1
            end
        end
        for i = 1, #pathInfo do
            local curPath = prefix .. table.concat(pathInfo, device.directorySeparator, 1, i) .. device.directorySeparator
            if not functions.isDirExist(curPath) then
                --print("mkdir " .. curPath)
                local succ, err = lfs.mkdir(curPath)
                if not succ then 
                    cc.LuaLog("mkdir " .. path .. " failed, " .. err)
                    return false
                end
            else
                --print(curPath, "exists")
            end
        end
    end
    cc.LuaLog("done mkdir " .. tostring(path))
    return true
end
 
function functions.rmdir(path)
    cc.LuaLog("rmdir " .. path)
    if functions.isDirExist(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        --print("remove file ", curDir)
                        os.remove(curDir)
                    end
                end
            end
            --print("rmdir ", path)
            local succ, des = lfs.rmdir(path)
            if not succ then cc.LuaLog("remove dir " .. path .. " failed, " .. des) end
            return succ
        end
        _rmdir(path)
    end
    cc.LuaLog("done rmdir " .. path)
    return true
end

function functions.readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

function functions.removeFile(path)
    io.writefile(path, "")
    if device.platform == "windows" then
        os.execute("del " .. string.gsub(path, '/', '\\'))
    else
        os.execute("rm " .. path)
    end
end

function functions.checkFile(fileName, cryptoCode)
    if not io.exists(fileName) then
        return false
    end

    local data=functions.readFile(fileName)
    if data==nil then
        return false
    end

    if cryptoCode=="nil" or cryptoCode == "" or cryptoCode == nil then
        return true
    end
    local ms = crypto.md5file(fileName)
    if ms==cryptoCode then
        return true
    end

    return false
end

function functions.checkDirOK( path )
    local oldpath = lfs.currentdir()
    CCLuaLog("old path------> "..oldpath)
    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        CCLuaLog("path check OK------> "..path)
        return true
    end

    if lfs.mkdir(path) then
        CCLuaLog("path create OK------> "..path)
        return true
    end
end

--获取APP版本号
function  functions.getAppVersion()
    local ok, version
    if device.platform == "android" then
        ok, version = luaj.callStaticMethod("com/boyaa/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
        if ok then
            return version
        end
    elseif device.platform == "ios" then
        ok, version = luaoc.callStaticMethod("LuaOCBridge", "getAppVersion", nil)
        if ok then
            return version
        end
    end
end

function functions.exportMethods(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end



function functions.cacheFile(url, callback, dirName)
    local dirPath = device.writablePath .. "cache" .. device.directorySeparator ..  (dirName or "tmpfile") .. device.directorySeparator
    local hash = crypto.md5(url)
    local filePath = dirPath .. hash
    print("cacheFile filePath", filePath)
    if functions.mkdir(dirPath) then
        if io.exists(filePath) then
            print("cacheFile io exists", filePath)
            callback("success", io.readfile(filePath), "exists")
        else
            print("cacheFile url", url)
            bm.HttpService.GET_URL(url, {}, function(data)
                io.writefile(filePath, data, "w+")
                callback("success", data, "downLoad")
            end,
            function()
                callback("fail")
            end)
        end
    end
end

function functions.cacheTable(name, table)
    local dirPath = System.getStorageDictPath()
    local filePath = dirPath .. name

    if type(table) ~= "table" then
        local ret = nil
        if io.exists(filePath) then                
            local tmp = io.readfile(filePath) 
            ret = json.decode(tmp)             
        end
        return ret
    else    
        local data = json.encode(table)
        if data then
            io.writefile(filePath, data, "w+")
        end
        return table
    end
    
end

-- 遍历table，释放CCObject
local releaseHelper
releaseHelper = function (obj)
    if type(obj) == "table" then
        for k, v in pairs(obj) do
            releaseHelper(v)
        end
    elseif type(obj) == "userdata" then
        obj:release()
    end
end
functions.objectReleaseHelper = releaseHelper


function functions.formatBigStrToNum(numStr)
    numStr=tostring(numStr)
    local len = string.len(numStr)
    if len<1 then
        return tonumber(numStr)
    end
    local ret = string.sub(numStr,len,len)
    local retNum=string.sub(numStr,1,len-1)
    print("---->formatBigStrToNum ret="..ret.." retNum="..retNum)
    if ret=="T" then
        return tonumber(retNum)*1000000000000
    elseif ret=="B" then
        return tonumber(retNum)*1000000000
    elseif ret=="M" then
        return tonumber(retNum)*1000000
    elseif ret=="K" then
        return tonumber(retNum)*1000
    else
        return tonumber(numStr)
    end
    return tonumber(numStr)
end



-- function functions.formatBigNumber(num)
--     local len  = string.len(tostring(num))
--     local temp = tonumber(num)
--     local ret
--     if len >= 13 then
--         temp = temp / 1000000000000;
--         ret = string.format("%.3f", temp)
--         ret = string.sub(ret, 1, string.len(ret) - 1)
--         ret = ret .. "T"
--     elseif len >= 10 then
--         temp = temp / 1000000000;
--         ret = string.format("%.3f", temp)
--         ret = string.sub(ret, 1, string.len(ret) - 1)
--         ret = ret .. "B"
--     elseif len >= 7 then
--         temp = temp / 1000000;
--        ret = string.format("%.3f", temp)
--         ret = string.sub(ret, 1, string.len(ret) - 1)
--         ret = ret .. "M"
--     elseif len >= 5 then
--         temp = temp / 1000;
--         ret = string.format("%.3f", temp)
--         ret = string.sub(ret, 1, string.len(ret) - 1)
--         ret = ret .. "K"
--     else
--         return tostring(temp)
--     end

--     if string.find(ret, "%.") then
--         while true do
--             local len = string.len(ret)
--             local c = string.sub(ret, len - 1, string.len(ret) - 1)
--             if c == "." then
--                 ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
--                 break
--             else
--                 c = tonumber(c)
--                 if c == 0 then
--                     ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
--                 else
--                     break
--                 end
--             end
--         end
--     end

--     return ret
-- end

function functions.formatBigNumber(num)
    local temp = tonumber(num)
    if not temp then return "0" end
    local sys = ""
    if temp < 0 then
        sys = "-"
    end
    temp = math.abs(num)
    local ret
    local digit = 3
    if math.log10(temp) >= 12  then
        temp = temp / 1000000000000;
        ret = string.format("%."..digit.."f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "T"
    elseif math.log10(temp) >= 9 then
        temp = temp / 1000000000;
        ret = string.format("%."..digit.."f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "B"
    elseif math.log10(temp) >= 6  then
        temp = temp / 1000000;
        ret = string.format("%."..digit.."f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "M"
    elseif math.log10(temp) >= 3  then
        temp = temp / 1000;
        ret = string.format("%."..digit.."f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "K"   
    else
        ret = string.format("%."..(digit-1).."f", temp)
    end
    local p = string.find(ret, "%.")
    local l = digit - 1
    if p then
        while true do
            local c = tonumber(string.sub(ret, p+l,p+l))
            if c and c==0 then
                if l>=1 then
                    l = l - 1
                else
                    ret = string.sub(ret,1,p+l)..string.sub(ret,p+digit)  
                    break    
                end
            else
                if c then
                    ret = string.sub(ret,1,p+l)..string.sub(ret,p+digit)
                else
                    ret = string.sub(ret,1,p-1)..string.sub(ret,p+digit)
                end
                break
            end
           
        end
    end
    return sys..ret
end

-- 返回数值的000,000,000格式字符,s为分割符号
function getFormatNumber(num, s, max)
    local divideTimes = 0
    if type(num) == "number" then
        while (num >= 100000000000000) do
            num = math.floor(num/1000)
            divideTimes = divideTimes + 1
        end
    end
    local len = string.len(num)
    if len <= 3 then return num end
    while max and len > max do
        num = math.floor(num/1000)
        divideTimes = divideTimes + 1
        len = string.len(num)
    end 
    local strformat = ""
    for i = len, 1, -3 do
        if i - 2 > 0 then
            strformat = strformat == "" and string.sub(num, i - 2, i) or
                string.sub(num, i - 2, i) .. s .. strformat
        else
            strformat = string.sub(num, 1, i) .. s .. strformat
        end
    end
    strformat = string.gsub(strformat, ",$", "")
    local postfix = {"", "K", "M", "B", "T", "KT", "MT", "BT", "TT"}
    return strformat .. (postfix[divideTimes + 1] or "?")
end

functions.getFormatNumber = getFormatNumber

function functions.formatNumberWithSplit(num)
    local len  = string.len(tostring(num))
    if len>=15 then
        return functions.formatBigNumber(num)
    end
    return string.formatnumberthousands(num)
end

function functions.getVersionNum(version, num)
    local versionNum = 0
    if version then
        local list = string.split(version, ".")
        for i = 1, 4 do
            if num and num > 0 and i > num then
                break
            end
            if list[i] then
                versionNum = versionNum  + tonumber(list[i]) * (100 ^ (4 - i))
            end
        end
    end
    return versionNum
end

function functions.limitNickLength(str,l)
    -- if str and str ~= "" and num then
    --     local len,cLen = string.utf8len(str)
    --     if len > num then
    --         return string.utf8sub(str,1,num) .. ".."
    --     else
    --         return string.utf8sub(str,1,num) 
    --     end
    -- else
    --     return str
    -- end
    if str == nil or type(str)~="string" then
        return nil
    end
    local result = ""
    local len = string.len(str)
    local i = 1
    local index = 0
    while i <= len and index < l do
        local byteValue = string.byte(str, i)
        if byteValue <= 127 then    --asccii字符
            index = index + 1
            result = result..string.sub(str, i, i)
            i = i + 1
        elseif byteValue >= 128 and byteValue <= 191 then --非ascii字符不为第一个字节的字节
            i = i + 1
        elseif byteValue >= 192 and byteValue <= 223 then   --非ascii字符二字节中第一个字节
            index = index + 1
            result = result..string.sub(str, i, i+1)
            i = i + 2
        elseif byteValue >= 224 and byteValue <= 239 then --非ascii字符三字节中第一个字节
            index = index + 2
            result = result..string.sub(str, i, i+2)
            i = i + 3
        elseif byteValue >= 240 and byteValue <= 247 then --非ascii字符四字节中第一个字节
            index = index + 1
            result = result..string.sub(str, i, i+3)
            i = i + 4
        end
    end
    if i<=len then
        result = result..".."
    end
    return result       
end

function functions.replaceEmojiTest(str)
    if str == nil or type(str)~="string" then
        return nil
    end
    local result = ""
    local len = string.len(str)
    local i = 1
    local index = 0
    while i <= len do
        local byteValue = string.byte(str, i)
        if byteValue <= 127 then    --asccii字符
            index = index + 1
            result = result..string.sub(str, i, i)
            i = i + 1
        elseif byteValue >= 128 and byteValue <= 191 then --非ascii字符不为第一个字节的字节
            i = i + 1
        elseif byteValue >= 192 and byteValue <= 223 then   --非ascii字符二字节中第一个字节
            index = index + 1
            result = result..string.sub(str, i, i+1)
            i = i + 2
        elseif byteValue >= 224 and byteValue <= 239 then --非ascii字符三字节中第一个字节
            index = index + 2
            result = result..string.sub(str, i, i+2)
            i = i + 3
        elseif byteValue >= 240 and byteValue <= 247 then --非ascii字符四字节中第一个字节
            index = index + 1
            i = i + 4
        end
    end
    if i<=len then
        result = result
    end
    return result       
end



--存的是一个table，含有pmode,id   pmode就是支付类型，id就是商品id，time支付时间戳
function functions.getUserLastPayData()
    local cacheData = nk.userData.fastPay
    
    Log.dump(cacheData,">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> functions.getUserLastPayData")
    --如果没有数据
    if not cacheData then
        --先返回一个默认的支付类型
        local lastLoginType = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
        
        if lastLoginType == "GUEST" then
            cacheData = {pmode = 12, id = 200000,getname = ""}
        elseif lastLoginType == "FACEBOOK" then
            cacheData = {pmode = 12, id = 130504,getname = ""}
        end
    end

    return cacheData
end

function functions.makeQuickPay()
    local data = functions.getUserLastPayData()
    --发起支付的字段是pid
    data.pid = data.id
    local pmode = checkint(data.pmode)
    Log.dump(data, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> makeQuickPay")

    local PayManager = require("game.store.pay.payManager")
    local payManager_ = PayManager:getInstance()
    local payServer_ = payManager_:getQickPay(pmode)
    payServer_:makeBuy(data.id,data)
end

functions.exportMethods = function(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

function functions.checkIsNull(target)
    -- -- if type(target) == "userdata" then
    -- --     -- return nk.updateFunctions.checkIsNull(target)
    -- --     return false
    -- -- else
    --     if target then
    --         return false
    --     else
    --         return true
    --     end
    -- -- end
    if type(target) == "userdata" or type(target) == "table" then
        return tolua.isnull(target)
    else
        if target then
            return false
        else
            return true
        end
    end
end

-- 图片一般不用进行缩放适配分辨率，引擎会自动按照【宽】的缩放比例，去等比缩放图片，若在【高】上有要求的图片，就要调用此方法
function functions.fixScale(obj, scale)
    if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
        if not scale then
            obj:scale(nk.displayScale)
        else
            obj:scale(scale)
        end
    end
end

function functions.checkPrintScreen()
    local dirPath = device.writablePath .. "cache" .. device.directorySeparator .. "printScreen" ..device.directorySeparator
    functions.mkdir(dirPath)
    
    local uid = ""
    if nk.userData and nk.userData.mid then
        uid = nk.userData.mid
    end

    local filePath = dirPath.."print" .. uid .. ".png"

    if not io.exists(filePath) then
        nk.userDefault:setStringForKey(nk.cookieKeys.MAIN_HALL_BG_PRINTSCREEN, os.time())
        functions.printScreen(filePath)
    else
        local lastTimeStr = nk.userDefault:getStringForKey(nk.cookieKeys.MAIN_HALL_BG_PRINTSCREEN, "")
        local nowTime = os.time()
        if nowTime - checkint(lastTimeStr) > 604800 then
            nk.userDefault:setStringForKey(nk.cookieKeys.MAIN_HALL_BG_PRINTSCREEN, nowTime)
            functions.printScreen(filePath)
        end
    end
end

function functions.removePrintScreen()
    local uid = ""
    if nk.userData and nk.userData.mid then
        uid = nk.userData.mid
    end
    local dirPath = device.writablePath .. "cache" .. device.directorySeparator .. "printScreen" ..device.directorySeparator
    functions.mkdir(dirPath)
    local filePath = dirPath.."print" .. uid .. ".png"
    functions.removeFile(filePath)
end

function functions.printScreen(savePath)
    local size = display.size
    local screen = CCRenderTexture:create(size.width, size.height)  
    local scene = CCDirector:sharedDirector():getRunningScene()
    screen:begin()
    scene:visit()
    screen:endToLua()
    print("filterfilterfilter", "saveStart")
    screen:saveToFile(savePath)
    print("filterfilterfilter", "saveEnd")
end

function functions.getLogoFileBySid()
    local file = "res/common/common_logo.png"
    if GameConfig.ROOT_CGI_SID == "2" then
        file = "res/common/common_logo_1.png"
    end
    return file
end

return functions
