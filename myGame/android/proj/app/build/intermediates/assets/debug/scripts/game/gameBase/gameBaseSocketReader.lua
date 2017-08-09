-- gameBaseSocketReader.lua
-- Last modification : 2016-05-16
-- Description: a class to reader all socket packet. 

GameBaseSocketReader = class(SocketReader);

local TYPE = kPacketDataType

function GameBaseSocketReader:ctor(config)
	self.m_config = config
end

function GameBaseSocketReader:dtor()

end

local function readData(info, buf, packetId, dtype, fmt, lengthType, depends, tempTable)
    if depends then
        if not depends(info, tempTable) then
            return nil
        end
    end
	if dtype == TYPE.BYTE then
        local ret = buf:readByte(packetId, 0)
        if ret > 2^7 -1 then
            ret = ret - 2^8
        end
        return ret
    elseif dtype == TYPE.INT then
        return buf:readInt(packetId, 0)
    elseif dtype == TYPE.SHORT then
        return buf:readShort(packetId, 0)
    elseif dtype == TYPE.INT64 then
        return buf:readInt64(packetId, 0)
    elseif dtype == TYPE.STRING then
        return buf:readString(packetId)
    elseif dtype == TYPE.BINARY then
        return buf:readBinary(packetId)
    elseif dtype == TYPE.ARRAY then
        -- 读取一个数组
        local len = 0
        if lengthType then
            if lengthType == TYPE.BYTE then
                len = buf:readByte(packetId, 0)
            elseif lengthType == TYPE.INT then
            	len = buf:readInt(packetId, 0)
            else
                len = buf:readInt(packetId, 0)
            end
        end
        if len > 0 then
            local array_table = {}
            for i1 = 1, len do
                local temp_table = {}
                if #fmt == 1 then
                    -- fmt只有一个参数
                    for i2 = 1, len do
                        local v2 = fmt[1]
                        local name = v2.name
                        local dtype = v2.type
                        local fmts = v2.fmt
                        local lengthType = v2.lengthType
                        local depends = v2.depends
                        temp_table[i2] = readData(info, buf, packetId, dtype, fmts, lengthType, depends)
                    end
                    -- 返回{}
                    return temp_table
                else
                    for i2, v2 in ipairs(fmt) do
                        local name = v2.name
                        local dtype = v2.type
                        local fmts = v2.fmt
                        local lengthType = v2.lengthType
                        local depends = v2.depends
                        temp_table[name] = readData(info, buf, packetId, dtype, fmts, lengthType, depends, temp_table)
                    end
                    table.insert(array_table, temp_table)
                end
            end
            -- 返回{{}, {}...}
            return array_table
        else
            return {}
        end
    end
end

function GameBaseSocketReader:readPacket(socket, packetId, cmd)
    Log.printInfo("socket", "GameBaseSocketReader:readPacket cmd", string.format("%#x",cmd));
	if self.m_config and self.m_config[cmd] and self.m_config[cmd].fmt and #self.m_config[cmd].fmt > 0 then
		local info = {}
        -- 读包体
        for i, v in ipairs(self.m_config[cmd].fmt) do
            local name = v.name
            local dtype = v.type
            local fmt = v.fmt
            local lengthType = v.lengthType
            local depends = v.depends
            info[name] = readData(info, socket, packetId, dtype, fmt, lengthType, depends)
        end
        Log.dump(info);
        return info
    end
end