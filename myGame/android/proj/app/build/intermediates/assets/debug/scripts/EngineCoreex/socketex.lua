-- socketex.lua
-- Last modification : 2016-06-27
-- Description: a ex recover sokcet some function in core

---
-- 开始读取一个数据包,进行无符号处理
--
-- @param self
-- @param #number packetId 数据包的id。
Socket.readBegin = function(self, packetId)
	local cmd = socket_read_begin(packetId)
    return bit.band(cmd, 0xffff)
end

---
-- 开始写一个二进制流
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #string string 数据字符串。
-- @param #number compress 0 不压缩，非0则压缩。
Socket.writeBinary = function(self, packetId, string, compress)
	return socket_write_string_compress(packetId, string, compress)
end

---
-- 开始读取一个二进制流
--
-- @param self
-- @param #number packetId 数据包的id。
Socket.readBinary = function(self, packetId)
	return socket_read_string_compress(packetId)
end