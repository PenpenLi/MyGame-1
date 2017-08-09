-- friendData.lua
-- Last modification : 2016-06-03
-- Description: a data in Friend moudle

local FriendData = class(GameBaseData);
local FriendDataManager = require("game.friend.friendDataManager")

function FriendData:ctor(controller)
	Log.printInfo("FriendData.ctor");
end

function FriendData:dtor()
	Log.printInfo("FriendData.dtor");
end

-- 好友列表数据
function FriendData:setFriendList(data)
	self.m_friendList = data
end

function FriendData:getFriendList(data)
	return self.m_friendList
end

-- 推荐好友列表数据
function FriendData:setRecommendFriendList(data)
	self.m_recommendFriendList = data
end

function FriendData:getRecommendFriendList(data)
	return self.m_recommendFriendList or {}
end

-- 查找好友数据
function FriendData:setSearchFriend(data)
	self.m_searchFriend = data
end

function FriendData:getSearchFriend()
	return self.m_searchFriend
end

----------------------------http-------------------------

function FriendData:onGetRecommendFriendListBack(errorCode,data)
	Log.printInfo("FriendData.onGetRecommendFriendListBack");
    self:requestCtrlCmd("getRecommendFriendListBack", errorCode, data)
end

function FriendData:onSearchFriendByIdBack(errorCode,data)
	Log.printInfo("FriendData.onSearchFriendByIdBack");
    self:requestCtrlCmd("searchFriendByIdBack", errorCode, data)
end

--------------------------event function--------------------------

function FriendData:onAddFriendBack(status, userData)
	Log.printInfo("FriendData.onSearchFriendByIdBack")
    self:requestCtrlCmd("addFriendBack", status, userData)
end

function FriendData:onDeleteFriendBack(status, mid)
	Log.printInfo("FriendData.onSearchFriendByIdBack")
	self:requestCtrlCmd("deleteFriendBack", status, mid)
end

------------------------------table config------------------------------

-- Event to register and unregister
FriendData.s_eventHandle = {
    -- [Event ] = function
    [EventConstants.httpProcesser] = FriendData.onHttpPorcesser,
    [EventConstants.addFriendData] = FriendData.onAddFriendBack,
    [EventConstants.deleteFriendData] = FriendData.onDeleteFriendBack,
};

FriendData.s_httpRequestsCallBack = {
	["getRecommendFriendList"] = FriendData.onGetRecommendFriendListBack,
	["searchFriendById"] = FriendData.onSearchFriendByIdBack,
}

-- Provide handle to call
FriendData.s_cmdConfig = 
{
	--["***"] = function
};

return FriendData