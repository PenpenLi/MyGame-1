-- gameBaseSocket.lua
-- Last modification : 2016-05-09
-- Description: extend gameSocket class in core 

GameBaseSocket = class(GameSocket);

function GameBaseSocket:ctor(socketType, sockHeader, netEndian, gameId, deviceType, ver, subVer, config)
	self.m_isSocketOpening = false;
	self.m_retryTimes = -1;
	self.m_config = config
end

function GameBaseSocket:dtor()
	
end

function GameBaseSocket:isSocketOpening()
	return self.m_isSocketOpening;
end

function GameBaseSocket:setSocketRetryTimes(times)
	self.m_retryTimes = times
end

function GameBaseSocket:getSocketRetryTimes()
	return self.m_retryTimes
end

-- @Override 
function GameBaseSocket:createSocket(socketType, sockHeader, netEndian, gameId, deviceType, ver, subVer)
	return new(Socket, socketType, sockHeader, netEndian, gameId, deviceType, ver, subVer);
end

-- @Override
function GameBaseSocket:openSocket(ip, port, callback)
	Log.printInfo("socket", "GameBaseSocket:openSocket")
	GameSocket.openSocket(self, ip, port)
	self.m_ip = ip
	self.m_port = port
	self.m_isSocketOpening = true;
	self.m_callback = callback
end

-- @Override 
function GameBaseSocket:sendMsg(cmd, info)
	Log.printInfo("socket", "GameBaseSocket:sendMsg cmd", string.format("%#x",cmd))
    if not self:isSocketOpen() then 
	    Log.printInfo("socket", "fail to send but reopenSocket cmd", string.format("%#x",cmd))
	    if not self.m_isSocketOpening then
	    	self:openSocket();
	    end
        return false
    end
	return GameSocket.sendMsg(self, cmd, info);
end

-- @Override
function GameBaseSocket:writeBegin(socket, cmd)
	Log.printInfo("socket", "GameBaseSocket:writeBegin")
    local packetId = nil;
    packetId = socket:writeBegin(cmd);
    return packetId;
end 

-- @Override
function GameBaseSocket:readPacket(socket, packetId, cmd)
	local packetInfo = GameSocket.readPacket(self, socket, packetId, cmd)
	local callback = nil
	if self.m_config[cmd] and self.m_config[cmd].callback then
		callback = self.m_config[cmd].callback
	end
	if not callback then
		Log.printWarn("socket", "SocketProcessersModule no such cmd", string.format("%#x",cmd))
		-- Log.printWarn("socket", "SocketProcessersModule cmd no callback in socketConfig");
	else
		for k,v in pairs(self.m_socketProcessers) do --其实只有1个
			if v[callback] then
				v[callback](v, packetInfo)
			else
				EventDispatcher.getInstance():dispatch(EventConstants.socketProcesser, callback, packetInfo)
			end
		end
	end
end

-- @Override
function GameBaseSocket:onTimeout()
	Log.printInfo("socket", "GameBaseSocket:onTimeout")
	GameSocket.onTimeout(self);
    self:closeSocketAsync();
    self:onSocketConnectError(consts.SVR_ERROR.ERROR_HEART_TIME_OUT)
end

-- @Override
function GameBaseSocket:closeSocketAsync(callback)
	Log.printInfo("socket", "GameBaseSocket:closeSocketAsync")
	self.m_closeCallback = callback
	self.m_isSocketOpening = false;
	GameSocket.closeSocketAsync(self);
end

-- @Override
function GameBaseSocket:onSocketClosed()
	Log.printInfo("socket", "GameBaseSocket:onSocketClosed")
	GameSocket.onSocketClosed(self);
	self.m_isSocketOpening = false;
	self:startReconnectTimer()
	if self.m_closeCallback then
		self.m_closeCallback()
		self.m_closeCallback = nil
	end
end 

-- @Override
function GameBaseSocket:onSocketReconnecting()

end

-- @Override
function GameBaseSocket:onSocketConnected()
	Log.printInfo("socket", "GameBaseSocket:onSocketConnected")
	GameSocket.onSocketConnected(self);
	self.m_isSocketOpening = false;

	if nk.shouldContentHallserver then
 		nk.SocketController:login()
 	end
	
	if self.m_callback then
		self.m_callback()
	end
end 

-- @Override
function GameBaseSocket:onSocketConnectFailed()	  	
	Log.printInfo("socket", "GameBaseSocket:onSocketConnectFailed")
    GameSocket.onSocketConnectFailed(self);
    self.m_isSocketOpening = false;

    if self:getSocketRetryTimes() < 0 then
    	self:onSocketConnectError(consts.SVR_ERROR.ERROR_CONNECT_FAILURE)
    else
    	self:startReconnectTimer()
    end
end

function GameBaseSocket:startReconnectTimer()
	Log.printInfo("socket", "GameBaseSocket:startReconnectTimer")
    self:stopReconnectTimer();

    if self:getSocketRetryTimes() < 0 then
    	Log.printInfo("socket", "GameBaseSocket:startReconnectTimer retryTimes < 0 and return")
    	return
    end
    Log.printInfo("socket", "GameBaseSocket:startReconnectTimer retryTimes :" .. self:getSocketRetryTimes())
    self.m_socketRetryAnim = new(AnimInt, kAnimNormal, 0, 1, 1000, 0);
    self.m_socketRetryAnim:setDebugName("GameBaseSocket.m_socketRetryAnim timer");
	self.m_socketRetryAnim:setEvent(self,GameBaseSocket.onSocketRetry);
end

function GameBaseSocket:onSocketRetry()
	local retryTimes = self:getSocketRetryTimes()
     if retryTimes > 0 then 
        self:setSocketRetryTimes(retryTimes - 1)
        if self.m_ip and self.m_port then
        	self:openSocket(self.m_ip, self.m_port);
        end
     else
        self:stopReconnectTimer();
     end
end

function GameBaseSocket:stopReconnectTimer()
    if self.m_socketRetryAnim then
        delete(self.m_socketRetryAnim);
        self.m_socketRetryAnim = nil;
    end
end

function GameBaseSocket:onSocketConnectError(errorCode)
    EventDispatcher.getInstance():dispatch(EventConstants.SVR_ERROR, errorCode)
end

