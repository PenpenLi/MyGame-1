-- socketController.lua
-- Last modification : 2016-05-13
-- Description: a controller to finish all socket request. 

local SocketController = class();
local SocketConfig = require("game.net.socket.socketConfig")
local SocketProcesserModule = require("game.net.socket.socketProcesserModule")

SocketController.s_status = {
	NO_CONNECT = -1, -- 未连接
	CONNECTING = 0, -- 正在连接
	CONNECTED = 1, -- 已连接
}

function SocketController.getInstance()
	if not SocketController.s_instance then 
		SocketController.s_instance = new(SocketController);
	end
	return SocketController.s_instance;
end

function SocketController.releaseInstance()
	delete(SocketController.s_instance);
	SocketController.s_instance = nil;
end


function SocketController:ctor()
    self.m_socket = new(GameBaseSocket, kSocketGaple, kSocketHeader, KnetEndian, kGameId, 0, kProtocalVersion, kProtocalVsubVer, SocketConfig.CONFIG.SERVER)
    self.m_processer = new(SocketProcesserModule, SocketConfig.CONFIG.SERVER);
    self.m_writer = new(GameBaseSocketWriter, SocketConfig.CONFIG.CLIENT);
    self.m_reader = new(GameBaseSocketReader, SocketConfig.CONFIG.SERVER);

    self.m_socket:addSocketReader(self.m_reader);
    self.m_socket:addSocketWriter(self.m_writer);
    self.m_socket:addSocketProcesser(self.m_processer);

    self.m_socket:setHeartBeatCmd(SocketConfig.CLISVR_HEART_BEAT);
end

function SocketController:dtor()
	self.m_socket:removeSocketReader(self.m_reader);
	self.m_socket:removeSocketWriter(self.m_writer);
	self.m_socket:removeSocketProcesser(self.m_processer);

	delete(self.m_processer);
	self.m_processer = nil;
    delete(self.m_writer);
    self.m_writer = nil;
    delete(self.m_reader);
    self.m_reader = nil;

	if self.m_socket then
		delete(self.m_socket)
    	self.m_socket = nil
	end
end

function SocketController:getSocketStatus()
	if self.m_socket:isSocketOpen() then
		return SocketController.s_status.CONNECTED
	elseif self.m_socket:isSocketOpening() then
		return SocketController.s_status.CONNECTING
	else
		return SocketController.s_status.NO_CONNECT
	end
end

function SocketController:sendMsg(cmd, info, callback)
    local status = self:getSocketStatus()
    if status == SocketController.s_status.NO_CONNECT then 
        self:connect(nil, nil, 3, callback);
        return false
    elseif status == SocketController.s_status.CONNECTING then
    	return false
    end
	return self.m_socket:sendMsg(cmd, info);
end

function SocketController:connect(ip, port, retryTimes, callback)
    if self.m_isForce then
        return
    end
	local status = self:getSocketStatus()
	if status ~= SocketController.s_status.NO_CONNECT then
        if callback then callback() end
		return
	end
    local hallIp, hallPort = string.match(HttpConfig.inHallIp, "([%d%.]+):(%d+)")
    ip = ip or hallIp
    port = port or hallPort
    if not ip or not port then
    	Log.printError("socket", "No ip or No port to connect");
        return ;
    end
    Log.printInfo("socket", "ip:" .. ip .. " port:" .. port .. " retryTimes:" .. (retryTimes or -1))
    if retryTimes then
    	self.m_socket:setSocketRetryTimes(retryTimes)
    else
    	self.m_socket:setSocketRetryTimes(-1)
    end
    if not self.m_socket:isSocketOpen() then
	    self.m_socket:openSocket(ip, port, callback)
    else
        if callback then callback() end
    end
end

function SocketController:close(tryTime, callback, isForce)
    -- 是否强制关闭，不再打开socket
    self.m_isForce = isForce
    if tryTime and tryTime > 0 then
        self.m_socket:setSocketRetryTimes(tryTime)
    else
        self.m_socket:setSocketRetryTimes(-1)
    end
    self.m_socket:closeSocketAsync(callback)
end


function SocketController:setForce(flag)
    self.m_isForce = isForce
end

---------------------------------------------------以下是socket请求---------------------------------------------------

-- 发送http请求
function SocketController:httpRequest(params)
    -- {name = "id", type = T.INT}, -- http请求id
    -- {name = "httpType", type = T.BYTE}, -- http请求类型(=1:Get请求, =2:Post请求)
    -- {name = "url", type = T.STRING}, -- http请求url
    -- {name = "params", type = T.STRING}, -- http请求params
    
    -- local params = {
    --     game_param = {
    --         apkVer = "1.1.1.0"
    --     },
    --     lid        = 2,
    --     method     = "Payment.getAllPayList",
    --     sesskey    = "105154-1234567890",
    --     sid        = "1",
    --     sig        = "39d5800f7ac5d8e2d42f71fbff29a1fdcccccccccccccccc",}
    -- local param = {}
    -- param.id = 1
    -- param.httpType = kHttpPost + 1
    -- param.url = "http://192.168.204.153/gaple/api/gateway.php"
    -- param.params = json.encode(params)
    return self:sendMsg(SocketConfig.CLI_PHP, params); 
end

-- 发送http请求
function SocketController:httpRequestGet(url, params)
    -- {name = "id", type = T.INT}, -- http请求id
    -- {name = "httpType", type = T.BYTE}, -- http请求类型(=1:Get请求, =2:Post请求)
    -- {name = "url", type = T.STRING}, -- http请求url
    -- {name = "params", type = T.STRING}, -- http请求params
    -- local params = {
    --     game_param = {
    --         apkVer = "1.1.1.0"
    --     },
    --     lid        = 2,
    --     method     = "Payment.getAllPayList",
    --     sesskey    = "105154-1234567890",
    --     sid        = "1",
    --     sig        = "39d5800f7ac5d8e2d42f71fbff29a1fdcccccccccccccccc",}
    local param = {}
    param.id = 1
    param.httpType = kHttpGet + 1
    
    -- local url = "http://192.168.204.153/gaple/api/gateway.php?"
    if params then
        for i, v in pairs(params) do
            if type(v) == "table" then
                url = url .. i .. "=" .. string.urlencode(v) .. "&"
            else
                url = url .. i .. "=" .. v .. "&"
            end
        end
    end

    param.url = url

    return self:sendMsg(SocketConfig.CLI_PHP, param); 
end

function SocketController:isPlayNow()
    return self.isPlayNow_
end

-- 登录大厅
function SocketController:login()
	local info = {}
	info["uid"] = nk.UserDataController.getUid()
    info["userType"] = 0
    info["channel"] = GameConfig.ROOT_CGI_SID
    info["clientVersion"] = 10 -- nk.Native:getAppVersion()
	info["serverVersion"] = 33 -- nk.serverVersion
	info["userLevel"] = nk.UserDataController.getMlevel() 
	info["userMoney"] = nk.functions.getMoney()
	info["vipLevel"] = 0
	return self:sendMsg(SocketConfig.CLI_LOGIN, info);
end

-- 请求分配房间
function SocketController:getRoomAndLogin(level, tid)
    self.isPlayNow_ = false
    local targetid,type
    if tid > 0 then  -- 指定登录哪一桌
        targetid = tid
        type = 1
    else             -- 随机登陆
        targetid = 0
        type = 0
    end
	local param = {}
	param["roomLevel"] = level
    param["userLevel"] = nk.UserDataController.getMlevel()
    param["userChips"] = nk.functions.getMoney()
	return self:sendMsg(SocketConfig.CLI_GET_ROOM, param); 
end

function SocketController:getRoomPlayTypeByTid(tid)
    local param = {}
    param["tid"] = tid
    return self:sendMsg(SocketConfig.CLI_ROOM_STATUS_GET, param);
end

-- 快速开始 gaple
function SocketController:quickPlayGaple()
    local level = nk.functions.getRoomLevelByMoney(nk.functions.getMoney())
    local ret = self:getRoomAndLogin(level, 0)
    if ret then
        self.isPlayNow_ = true
    end
    return ret
end

-- 追踪玩家进入房间, 检查玩家状态，如果在房间内返回房间id
function SocketController:trackFriend(mid)
    local param = {}
    param["uid"] = mid
    return self:sendMsg(SocketConfig.CLI_PLAYER_STATUS_GET, param);
end

-- 登录房间
function SocketController:loginRoom(tid, channel, ver, vip)
	print("------loginRoom-----", self.lastTid_ or "")
    if self.lastTid_ and self.lastTid_ == tid then
        self.lastTid_ = nil
        return
    else
        self.lastTid_ = tid
        nk.GCD.PostDelay(self, function()
            self.lastTid_ = nil
        end, nil, 2000)
    end
    channel = channel or 0
    ver = ver or 0
    vip = vip or 0

	local param = {}
	param["uid"] = nk.UserDataController.getUid()
    param["tid"] = tid
    param["channel"] = channel
    param["ver"] = ver
    param["vip"] = vip
    param["mtkey"] = "woowowoowoooo"
    param["name"] = nk.UserDataController.getUserName()
    param["userInfo"] = json.encode(nk.functions.getUserInfo())
	return self:sendMsg(SocketConfig.CLI_LOGIN_ROOM, param); 
end

function SocketController:logoutRoom()
    return self:sendMsg(SocketConfig.CLI_LOGOUT_ROOM, {}); 
end

-- 请求坐下
function SocketController:seatDown(seatId, autoSit)
    if autoSit then
        autoSit = 1
    else
        autoSit = 0
    end
    
    local param = {}
    param["seatId"] = seatId
    param["autoSit"] = autoSit
    return self:sendMsg(SocketConfig.CLI_SEAT_DOWN, param); 
end

-- 用户请求站立
function SocketController:standUp(seatId)
    local param = {}
    param["seatId"] = seatId
    return self:sendMsg(SocketConfig.CLI_STAND_UP, param); 
end

-- 玩家出牌
function SocketController:sendCard(uid, opType, card, cardPos)
    local param = {}
    param["uid"] = uid
    param["opType"] = opType
    param["card"] = card
    param["cardPos"] = cardPos
    return self:sendMsg(SocketConfig.CLI_SET_BET, param); 
end

-- 用户请求换桌
function SocketController:changeRoomAndLogin(roomLevel,userLevel,userMoney,tid,serverVersion)
    local param = {}
    param["roomLevel"] = roomLevel
    param["userLevel"] = userLevel
    param["userMoney"] = userMoney
    param["tid"] = tid
    param["serverVersion"] = serverVersion
    return self:sendMsg(SocketConfig.CLI_CHANGE_ROOM, param); 
end

-- 用户请求桌面同步包
function SocketController:tableSYNC()
    Log.printInfo("SocketController:tableSYNC")
    return self:sendMsg(SocketConfig.CLI_TABLE_SYNC,{}); 
end

-- 客户端请求更新UserInfo
function SocketController:synchroUserInfo()
    Log.printInfo("------SocketController:synchroUserInfo-----")
    Log.dump(json.encode(nk.functions.getUserInfo()), "json.encode(nk.functions.getUserInfo())")
    local param = {}
    param["uid"] = nk.userData.uid
    param["userInfo"] = json.encode(nk.functions.getUserInfo())
    return self:sendMsg(SocketConfig.CLI_SYNC_USERINFO, param); 
end

----------------------------- 99 start -----------------------------------

-- 快速开始 qiuqiu
function SocketController:quickPlayQiuQiu()
    local level = nk.functions.getRoomQiuQiuLevelByMoney(nk.functions.getMoney())
    self:getRoomAndLogin(level, 0)
    self.isPlayNow_ = true
end

function SocketController:loginRoomQiuQiu(tid,channel,ver,vip)
    -- 这个接口和接龙的内容一样，统一在一起,由server判断登录的是什么房间,返回不同的结果
    -- print("------loginRoomQiuQiu-----")
    -- channel = channel or 0
    -- ver = ver or 0
    -- vip = vip or 0
    -- local param = {}
    -- param["uid"] = nk.userData.uid
    -- param["tid"] = tid
    -- param["channel"] = channel
    -- param["ver"] = ver
    -- param["vip"] = vip
    -- param["mtkey"] = "woowowoowoooo"
    -- param["name"] = nk.userData["aUser.name"]
    -- param["userInfo"] = json.encode(nk.functions.getUserInfo())
    -- return self:sendMsg(SocketConfig.CLI_LOGIN_ROOM_QIUQIU, param); 
end

function SocketController:logoutRoomQiuQiu()
    return self:sendMsg(SocketConfig.CLI_LOGOUT_ROOM_QIUQIU, {})
end

function SocketController:seatDownQiuQiu(seatId, bet, autoBuyin, autoSit)
    if autoBuyin then
        autoBuyin = 1
    else
        autoBuyin = 0
    end

    if autoSit then
        autoSit = 1
    else
        autoSit = 0
    end
    print("seatId, bet, autoBuyin, autoSit ",  seatId, bet, autoBuyin, autoSit)
    local param = {}
    param["seatId"] = seatId
    param["ante"] = bet
    param["autoBuyin"] = autoBuyin
    param["autoSit"] = autoSit
    return self:sendMsg(SocketConfig.CLI_SEAT_DOWN_QIUQIU, param)
end

function SocketController:standUpQiuQiu(seatId)
    local param = {} 
    param["seatId"] = seatId
    return self:sendMsg(SocketConfig.CLI_STAND_UP_QIUQIU, param)
end

--请求给荷官小费
function SocketController:sendChipToGirl(count)
    local param = {}
    param["money"] =count
    return self:sendMsg(SocketConfig.CLI_SEND_TIP_TO_GIRL, param)
end

function SocketController:setBet(type,bet)
    local param = {}
    param["userOperatingType"] = type 
    param["ante"] = bet      
    return self:sendMsg(SocketConfig.CLI_SET_BET_QIUQIU, param) 
end


function SocketController:playerChangeCard(card1,card2,card3,card4)
    local param = {}
    param["card1"] = card1      
    param["card2"] = card2      
    param["card3"] = card3      
    param["card4"] = card4   
    return self:sendMsg(SocketConfig.CLI_SEND_CHANGE_CARDS, param)  
end

function SocketController:tableSYNCQIUQIU()
    return self:sendMsg(SocketConfig.CLI_TABLE_SYNC_QIUQIU, {}) 
end

function SocketController:confirmCardMode()
    return self:sendMsg(SocketConfig.CLI_CONFIRM_CARD_MODE, {}) 
end

------------------------ 99 end --------------------------


function SocketController:sendFriendChatMsg(self_uid,target_uid,msg,send_id,msg_type)
    local param = {}
    param["self_uid"] = self_uid
    param["target_uid"] = target_uid
    param["msg"] = msg
    param["send_id"] = send_id
    param["msg_type"] = msg_type
    return self:sendMsg(SocketConfig.CLI_SEND_FRIEND_CHAT_MSG, param); 
end

function SocketController:getNoReadFriendChatMsg()
    local param = {}
    param["uid"] = nk.userData.uid
    return self:sendMsg(SocketConfig.CLI_GET_NO_READ_MSG, param); 
end

--[[
    发送房间广播消息
]]
function SocketController:sendRoomBroadCast_(info)
    local param = {}
    param["uid"] = nk.userData.uid
    param["info"] = info
    return self:sendMsg(SocketConfig.CLI_SEND_ROOM_BROADCAST, param); 
end


--发送房间聊天信息
function SocketController:sendRoomChat(msg)
    local param = {}
    param["mtype"] = 1
    param["msg"] = msg
    param["name"] = nk.userData.name
    return self:sendRoomBroadCast_(json.encode(param)) 
end

function SocketController:sendRoomGift(giftId,tuids)
    local param =  {}
    param["mtype"] = 3
    param["giftId"] = giftId
    param["tuids"] = tuids
    return self:sendRoomBroadCast_(json.encode(param))
end

function SocketController:sendExpression(fType,faceId,count)
    local param = {}
    param["mtype"] = 5
    param["fType"] = fType
    param["faceId"] = faceId
    param["count"] = count
    return self:sendRoomBroadCast_(json.encode(param))
end

--发送互动表情
function SocketController:sendProp(pid,toSeatIds,pnid,num)
    local param = {}
    param["mtype"] = 6
    param["pid"] = pid  --客户端道具标示
    param["pnid"] = pnid  --PHP的道具ID
    param["toSeatIds"] = toSeatIds
    param["num"] = num or 1 --数量
    return self:sendRoomBroadCast_(json.encode(param)) 
end

--广播打赏荷官小费
function SocketController:sendDealerChip(fee,num)
    local param = {}
    param["mtype"] = 7
    param["fee"] = fee  
    param["num"] = num 
    return self:sendRoomBroadCast_(json.encode(param)) 
end

-- 玩家发送付费表情、道具
--type 1是表情，2是互動道具
function SocketController:sendRoomCostProp(count,type,id,targetSeatId,num)
    local param = {}
    param["money"] = count
    param["type"] = type
    param["id"] = id
    param["targetSeatId"] = targetSeatId
    param["num"] = num or 1
    return self:sendMsg(SocketConfig.CLI_SEND_ROOM_COST_PROP, param); 
end

-- 查询好友状态
function SocketController:checkFriendStatus(uid,num,uidList)
    local param = {}
    param["uid"] = uid
    param["uidList"] = uidList
    return self:sendMsg(SocketConfig.CLI_CHECK_FRIEND_STATUS, param);
end

function SocketController:userEnterBackground()
    return self:sendMsg(SocketConfig.CLI_USER_IN_BACKGROUND, {}); 
end

return SocketController