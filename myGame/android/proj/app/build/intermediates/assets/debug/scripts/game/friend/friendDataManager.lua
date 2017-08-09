-- friendDataManager.lua
-- Last modification : 2016-06-20
-- Description: a manager in friend moudle, to manage all friend data
-- Offer Instance

local FriendDataManager = class()

function FriendDataManager.getInstance()
    if not FriendDataManager.s_instance then
        FriendDataManager.s_instance = new(FriendDataManager)
    end
    return FriendDataManager.s_instance
end

function FriendDataManager.deleteInstance()
    if FriendDataManager.s_instance then
        delete(FriendDataManager.s_instance)
        FriendDataManager.s_instance = nil
    end
end


function FriendDataManager:ctor()
	Log.printInfo("FriendDataManager", "ctor");
	self.m_isLoaded = false
 	self.m_isLoading = false
 	self.m_friendData = {}
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpPorcesser);
end

function FriendDataManager:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpPorcesser);
end

-- 加载好友列表
function FriendDataManager:loadFriendData(callback)
    self.m_loadCallback = callback
	if not self.m_isLoaded then
		if self.m_isLoading then
			return
		end
		local params = {}
        params.mid = nk.userData["aUser.mid"]
        nk.HttpController:execute("getFriendList", {game_param = params})
	else
		self:invokeCallback(self.m_loadCallback, true, self.m_friendData)
	end
end

function FriendDataManager:getFriendsData()
    return self.m_friendData
end

-- 新增好友
function FriendDataManager:addFriendData(data)
    if data then
        if not self:checkHasFriend(data) then
            table.insert(self.m_friendData, data)
            return true
        end
    end
end

function FriendDataManager:changeFriendData(data)
    if data then
        for i,friendData in ipairs(self.m_friendData) do
            if tonumber(friendData.mid) == tonumber(data.mid) then
                friendData = data
                break
            end
        end
    end
end

-- 删除好友 by id
function FriendDataManager:deleteFriendData(id)
    if id then
        local index = 0
        for i,data in ipairs(self.m_friendData) do
            if tonumber(data.mid) == tonumber(id) then
                index = i
                break
            end
        end
        if index > 0 then
            table.remove(self.m_friendData,index)
            return true
        end
    end
end

-- 检查是否存在该好友
function FriendDataManager:checkHasFriend(data)
    local flag = false
    if data then
        for i,friendData in ipairs(self.m_friendData) do
            if tonumber(friendData.mid) == tonumber(data.mid) then
                flag = true
                break
            end
        end
    end
    return flag
end

-- 获取好友UID列表
function FriendDataManager:getFriendsUidList()
    local uidList = {}
    local uidList_ = {}
    if #self.m_friendData > 0 then
        for i, v in ipairs(self.m_friendData) do
            uidList[#uidList + 1] = v.mid
            uidList_[#uidList_ + 1] = {fuid = v.mid}
        end
    end
    -- 设置好友uid列表
    nk.UserDataController:setFriendUidList(uidList)
    -- 返回符合server格式的uid列表
    return uidList_
end

function FriendDataManager:checkIsFriend(id)
    local flag = false
    local uidList_ = self:getFriendsUidList()
    if #uidList_ > 0 then
        for i,v in ipairs(uidList_) do
            if v.fuid == id then
                flag = true
                break
            end
        end
    end
    return flag
end

-- server回复更新好友状态
function FriendDataManager:refreshFriendStatus(statusList)
    local friendsStatus = {}
    if statusList and type(statusList) == "table" then
        for i,status in ipairs(statusList) do
            table.insert(friendsStatus,tonumber(status.uid),status)
        end
    end
    for i,friend in ipairs(self.m_friendData) do
        if friendsStatus[tonumber(friend.mid)] then
            friend.status = friendsStatus[tonumber(friend.mid)].status
        else
            friend.status = 1
        end
    end
    EventDispatcher.getInstance():dispatch(EventConstants.friendOnlineStatus)
end

-- 根据在线状态排序
function FriendDataManager:sortFriendsByStatus(friendsData)
    friendsData = friendsData or self.m_friendData
    if friendsData and type(friendsData) == "table" then
        table.sort(friendsData, function(x,y)
                    x.status = x.status and x.status or 0
                    y.status = y.status and y.status or 0
                    x.name = x.name and x.name or ""
                    y.name = y.name and y.name or ""
                    if x.status == y.status then
                        return x.name < y.name
                    end
                    return x.status > y.status;
                end);
        return friendsData
    end
    return {}
end

function FriendDataManager:invokeCallback(callback, ...)
    if callback then
        callback(...)
    end
end

function FriendDataManager:onHttpPorcesser(command, ...)
    Log.printInfo("FriendDataManager", "FriendDataManager.onHttpPorcesser");
    if not self.s_httpRequestsCallBack[command] then
        Log.printWarn("FriendDataManager", "Not such request cmd in current controller command:" .. command);
        return;
    end
    self.s_httpRequestsCallBack[command](self,...); 
end

------------------------------http callback----------------------------

function FriendDataManager:onGetFriendListBack(errorCode, data)
    Log.printInfo("FriendDataManager", "FriendDataManager.onGetFriendListBack")
    self.m_isLoading = false
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            self.m_isLoaded = true
            -- Log.dump(data)
            local retData = data.data
            self.m_friendData = retData.friendsList
            self:invokeCallback(self.m_loadCallback, true, self.m_friendData)
        end
    else
        self:invokeCallback(self.m_loadCallback, false, self.m_friendData)
    end
end

function FriendDataManager:onAddFriendBack(errorCode, data)
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local retData = data.data
            if retData.flag == 1 then
                if self:addFriendData(retData.data[1]) then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_SUCCESS_MSG"))
                    EventDispatcher.getInstance():dispatch(EventConstants.addFriendData, true, retData.data[1], retData.flag)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_IS_FRIEND_ALREADY"))
                    EventDispatcher.getInstance():dispatch(EventConstants.addFriendData, false, nil, -2)
                end
            elseif retData.flag == -1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG"))
                EventDispatcher.getInstance():dispatch(EventConstants.addFriendData, false, nil, retData.flag)
            elseif retData.flag == -2 then
                if retData.data and retData.data[1] then
                    self:addFriendData(retData.data[1])
                end
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_IS_FRIEND_ALREADY"))
                EventDispatcher.getInstance():dispatch(EventConstants.addFriendData, false, nil, retData.flag)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
                EventDispatcher.getInstance():dispatch(EventConstants.addFriendData, false, nil, retData.flag)
            end
        end
    end
end

function FriendDataManager:onDeleteFriendBack(errorCode, data)
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local retData = data.data
            if self:deleteFriendData(retData[1]) then
                EventDispatcher.getInstance():dispatch(EventConstants.deleteFriendData, true, retData[1])
            else
                EventDispatcher.getInstance():dispatch(EventConstants.deleteFriendData, false)
            end
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "DEL_FRIEND_TIPS"))
        else
            EventDispatcher.getInstance():dispatch(EventConstants.deleteFriendData, false)
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_FAIL_MSG"))
        end
    end
end

function FriendDataManager:onSendMoneyToFriendBack(errorCode, data)
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local retData = data.data
            if retData.ret then
                if retData.ret == 0 then
                    -- 没钱了
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_TOO_POOR"))
                elseif retData.ret == 1 then
                    -- 赠送次数用完
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_COUNT_OUT"))
                elseif retData.ret == 2 then
                    -- 赠送成功
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_SUCCESS", nk.updateFunctions.formatNumberWithSplit(retData.sendMoney)))
                    local dataInData = retData
                    nk.functions.setMoney(dataInData.remainMoney)
                    EventDispatcher.getInstance():dispatch(EventConstants.sendFriendMoneySucc, false)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end
        end
    end
end

-------------------------------table config------------------------------

FriendDataManager.s_httpRequestsCallBack = {
    ["getFriendList"] = FriendDataManager.onGetFriendListBack,
    ["addFriend"] = FriendDataManager.onAddFriendBack,
    ["deleteFriend"] = FriendDataManager.onDeleteFriendBack,
}

return FriendDataManager