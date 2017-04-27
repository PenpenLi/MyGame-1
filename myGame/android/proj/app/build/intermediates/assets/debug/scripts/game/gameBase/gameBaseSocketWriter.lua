-- GameBaseSocketWriter.lua
-- Last modification : 2016-05-16
-- Description: a class to build all socket packet. 

GameBaseSocketWriter = class(SocketWriter);

local TYPE = kPacketDataType

function GameBaseSocketWriter:ctor(config)
	self.m_config = config
end

function GameBaseSocketWriter:dtor()
	
end

local function writeData(buf, packetId, dtype, val, fmt)
	if dtype == TYPE.BYTE then
        local n = tonumber(val)
        if n and n < 0 then
            n = n + 2^8
        end
        buf:writeByte(packetId, n or 0)
    elseif dtype == TYPE.INT then
        buf:writeInt(packetId, tonumber(val) or 0)
    elseif dtype == TYPE.SHORT then
        buf:writeShort(packetId, tonumber(val) or 0)
    elseif dtype == TYPE.INT64 then
        buf:writeInt64(packetId, tonumber(val) or 0)
    elseif dtype == TYPE.STRING then
        val = tostring(val) or ""
        buf:writeString(packetId, val)
    elseif dtype == TYPE.ARRAY then
        local len = 0
        if val then
            len = #val
        end
        if fmt.lengthType then
            if fmt.lengthType == TYPE.BYTE then
                buf:writeByte(packetId, len)
            elseif fmt.lengthType == TYPE.INT then
            	buf:writeInt(packetId, len)
            else
                buf:writeInt(packetId, len)
            end
        end
        if len > 0 then
            for i1, v1 in ipairs(val) do
                for i2, v2 in ipairs(fmt) do
                    local name = v2.name
                    local dtype = v2.type
                    local fmt = v2.fmt
                    local value = v1[name]
                    writeData(buf, packetId, dtype, value, fmt)
                end
            end
        end
    end
end

function GameBaseSocketWriter:writePacket(socket, packetId, cmd, info)
    Log.printInfo("socket", "GameBaseSocketWriter:writePacket cmd", string.format("%#x",cmd));
    if self.m_config and self.m_config[cmd] and self.m_config[cmd].fmt and #self.m_config[cmd].fmt > 0 and info then
        -- 写包体
        Log.dump(info)
        Log.dump(self.m_config[cmd].fmt)
        for i, v in ipairs(self.m_config[cmd].fmt) do
            local name = v.name
            local dtype = v.type
            local fmt = v.fmt
            local value = info[name]
            Log.printInfo("socket", name, value)
            writeData(socket, packetId, dtype, value, fmt)
        end
    end
end


