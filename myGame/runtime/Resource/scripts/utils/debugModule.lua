-- debugModule.lua
-- Last modification : 2016-05-07
-- Description: order to print log better

Log = {}

local logFile = getPreDir(System.getStorageDictPath(),3).."scripts/debug.log"

if io.exists(logFile) then
	os.remove(logFile)
end

local function getArg(...)
    local arg = {...}
    for k,v in pairs(arg) do
        arg[k] = tostring(v)
    end
    return table.concat(arg, "\t")
end

local currentCollectStr = ""
local schedule_once = false

local function writefile(file, str, mode)
    if mode == "a+" and file == logFile then
        currentCollectStr = currentCollectStr .. str
        if not schedule_once and mode == "a+" then
            Clock.instance():schedule_once(function()
                io.writefile(logFile, currentCollectStr, "a+")
                schedule_once = false
                currentCollectStr = ""
            end, 0.5)
            schedule_once = true
        end
    else
        io.writefile(file, str, mode)
    end
end

--[[--

打印调试信息

### 用法示例

~~~ lua

printTag("WARN", "Network connection lost at %d", os.time())

~~~

@param string type 调试信息的类型
@param string tag 调试信息的 tag
@param string fmt 调试信息格式
@param [mixed ...] 更多参数

]]
function Log.printTag(info, type, tag, ...)
    if DEBUG < 1 then return end
    local t = {
    	"["..os.time() - (START_TIME or os.time()) .. "]",
    	"["..type.."]",
    	"["..(string.match(info.source, ".+\/([^\/]*%.%w+)$") or info.source).." "..(info.name or "")..":"..info.currentline.."]",
        "[",
        tostring(tag),
        "] ",
        getArg(...),
    }
    local str = table.concat(t)
    print_string(str)
    if DEBUG_LOG then
    	writefile(logFile, str .. "\n", "a+") -- 瓶颈。有点卡顿
    end
end

function Log.doPrint(info, type, ...)
	if select("#", ...) < 2 then
		Log.printTag(info, type, nil, ...)
	else
		Log.printTag(info, type, ...)
	end
end

function Log.printInfo(...)
    if DEBUG < 2 then return end
    local info = debug.getinfo(2)
	Log.doPrint(info, "Lua_Info", ...)
end

function Log.printDebug(...)
    local info = debug.getinfo(2)
	Log.doPrint(info, "Lua_Debug", ...)
end

function Log.printWarn(...)
    local info = debug.getinfo(2)
	Log.doPrint(info, "Lua_Warn", ...)
end

function Log.printError(...)
    local info = debug.getinfo(2)
	Log.doPrint(info, "Lua_Error", ...)
end

function Log.printFatal(...)
    local info = debug.getinfo(2)
	Log.doPrint(info, "Lua_Fatal", ...)
end

function Log.dump(...)
    local info = debug.getinfo(2)
    dump2(info, ...)
end

--[[--

输出值的内容

### 用法示例

~~~ lua

local t = {comp = "chukong", engine = "quick"}

dump(t)

~~~

@param mixed value 要输出的值

@param [string desciption] 输出内容前的文字描述

@parma [integer nesting] 输出时的嵌套层级，默认为 3

]]

function dump(info, value, desciption, nesting)
    if DEBUG < 1 then
        return
    end
    if type(nesting) ~= "number" then nesting = 10 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local traceback = string.split(debug.traceback("", 2), "\n")
    local printStr = "dump from:" .. string.trim(traceback[3])
    print_string(printStr)
    if DEBUG_LOG then
        writefile(logFile, printStr .. "\n", "a+")
    end
    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)
    
    for i, line in ipairs(result) do
        print_string(line)
        if DEBUG_LOG then
            writefile(logFile, line .. "\n", "a+")
        end
    end

end

function dump2(info, value, desciption, nesting)
    if DEBUG < 1 then
        return
    end
    if type(nesting) ~= "number" then nesting = 10 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    -- local traceback = string.split(debug.traceback("", 2), "\n")
    local traceback = (string.match(info.source, ".+\/([^\/]*%.%w+)$") or "").." "..(info.name or "")..":"..info.currentline
    local printStr = "Lua_dump from:" .. traceback
    print_string(printStr)
    if DEBUG_LOG then
        writefile(logFile, printStr .. "\n", "a+")
    end
    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)
    for i, line in ipairs(result) do
        print_string(line)
        if DEBUG_LOG then
            writefile(logFile, line .. "\n", "a+")
        end
    end
end

--[[--

用指定字符或字符串分割输入字符串，返回包含分割结果的数组

~~~ lua

local input = "Hello,World"
local res = string.split(input, ",")
-- res = {"Hello", "World"}

local input = "Hello-+-World-+-Quick"
local res = string.split(input, "-+-")
-- res = {"Hello", "World", "Quick"}

~~~

@param string input 输入字符串
@param string delimiter 分割标记字符或字符串

@return array 包含分割结果的数组

]]
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end