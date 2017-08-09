json = {}

function json.encode(var)
    local status, result = pcall(cjson.encode, var)
    if status then return result end
    if DEBUG > 1 then
        FwLog("json.encode() - encoding failed:" .. tostring(result))
    end
end

function json.decode(text)
    local status, result = pcall(cjson.decode, text)
    if status then return result end
    if DEBUG > 1 then
        FwLog("json.decode() - decoding failed:" .. tostring(result))
    end
    -- if text and text ~= "" and not string.match(text, "^<.+>%s*$") then -- 空字符串和html都过滤
    --     report_lua_error("json decode error = " .. text) 
    -- end-- if no result then report the text
end