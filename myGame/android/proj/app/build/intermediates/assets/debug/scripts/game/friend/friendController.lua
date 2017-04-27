-- friendController.lua
-- Last modification : 2016-06-12
-- Description: a controller in Friend moudle

local FriendController = class(GameBaseController);
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")
local FriendDataManager = require("game.friend.friendDataManager") 

function FriendController:ctor(state, viewClass, viewConfig, dataClass)
	Log.printInfo("FriendController.ctor");
    self.m_state = state;

    -----------
    -- 标记字段
    -----------

    -- 加载好友列表
    self.m_isGetFriendList_ing = false
    -- 加载好友推荐列表
    self.m_isGetRecommendList_ing = false
    self.m_isGetRecommendList_ed = false
    -- 查找好友
    self.m_isSearchFriend_ing = false
    -- 处于添加好友成功后，将新的推荐好友替换的状态
    self.m_isAddFriend_status = false
    self.m_isAddFriend_mid = nil
    -----------
    -- 标记字段 end
    -----------

    self.m_friendDataManager = FriendDataManager.getInstance()
	self:loadFriendData()
end

function FriendController:resume()
    Log.printInfo("FriendController.resume");
	GameBaseController.resume(self);
end

function FriendController:pause()
    Log.printInfo("FriendController.pause");
	GameBaseController.pause(self);
end

function FriendController:dtor()
    
end

-------------------------------- private function --------------------------

-- Provide state to call
function FriendController:onBack()
    StateMachine.getInstance():popState();
end

-- noCheckStatus 不需要检查状态
function FriendController:loadFriendData(noCheckStatus)
    if self.m_isGetFriendList_ing then  
        return
    end
    self.m_isGetFriendList_ing = true
    self.m_friendDataManager:loadFriendData(handler(self, function(obj, status, data)
            self.m_isGetFriendList_ing = false
            if status then
                table.foreach(data, function(i, v)
                        v.isFriend = 1
                    end)
                FriendDataManager.getInstance():sortFriendsByStatus()
                self:updateView("updateFriendList", data)
                if not noCheckStatus then
                    Clock.instance():schedule_once(function(dt)
                        local uidList_ = FriendDataManager.getInstance():getFriendsUidList()
                        nk.SocketController:checkFriendStatus(nk.userData.mid,#uidList_,uidList_)
                    end, 0.5)
                end
            else

            end
        end))
end

-------------------------------- handle function --------------------------

-- isReLoad 是否重新获取
function FriendController:onGetRecommendFriendList(isAddFriend)
    if isAddFriend then
        self.m_isAddFriend_status = true
    else
        self.m_isAddFriend_status = false
    end
    if self.m_isGetRecommendList_ing then
        return
    end
    self.m_isGetRecommendList_ing = true
    local params = {}
    params.mid = nk.userData.mid
    nk.HttpController:execute("getRecommendFriendList", {game_param = params})
end

function FriendController:onGetRecommendFriendListBack(errorCode, data)
    Log.printInfo("FriendController", "onGetRecommendFriendListBack")
    self.m_isGetRecommendList_ing = false
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            self.m_isGetRecommendList_ed = true
            local retData = data.data

            if self.m_isAddFriend_status and self.m_isAddFriend_mid then
                local recommendList = self.m_baseData:getRecommendFriendList()
                -- 获取与前一次推荐不同的好友，最少会有一个
                for _, v in pairs(recommendList) do
                    for i, k in pairs(retData) do
                        if tonumber(k.mid) == tonumber(v.mid) then
                            table.remove(retData, i)
                        end
                    end
                end
                table.foreach(recommendList, function(i, v)
                        if tonumber(v.mid) == tonumber(self.m_isAddFriend_mid) then
                            table.remove(recommendList, i)
                            table.insert(recommendList, i, retData[1])
                        end
                    end)
                self.m_isAddFriend_status = false
                self.m_isAddFriend_mid = nil
                retData = recommendList
            end

            self.m_baseData:setRecommendFriendList(retData)

            self:updateView("updateRecommendFriend", true, retData)
        end
    else
        self:updateView("updateRecommendFriend", false)
    end
end

function FriendController:onSearchFriendById(id)
    Log.printInfo("FriendController", "onSearchFriendById")
    if self.m_isSearchFriend_ing then
        return
    end
    self.m_isSearchFriend_ing = true
    local params = {}
    params.smid = id
    nk.HttpController:execute("searchFriendById", {game_param = params})
end

function FriendController:onSearchFriendByIdBack(errorCode, data)
    Log.printInfo("FriendController", "onSearchFriendByIdBack")
    self.m_isSearchFriend_ing = false
    if errorCode == HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local retData = data.data
            self.m_baseData:setSearchFriend(retData[1])
            self:updateView("updateSearchFriend", true, retData[1])
        end
    else
        self:updateView("updateSearchFriend", false)
    end
end

-- 添加好友返回
-- 1、将推荐好友中添加成功的好友更换为新的推荐好友
-- 2、将搜索结果的好友更换已好友状态
-- 3、更新好友列表
function FriendController:onAddFriendBack(status, userData)
    if status then
        self.m_isAddFriend_status = true
        self.m_isAddFriend_mid = userData.mid
        self:onGetRecommendFriendList(true)

        local searchFriend = self.m_baseData:getSearchFriend()
        if searchFriend and tonumber(searchFriend.mid) == tonumber(userData.mid) then
            searchFriend.isFriend = 1
            self:updateView("updateSearchFriend", true, searchFriend)
        end
        self:loadFriendData()
    end
end

-- 删除好友返回
-- 1、将搜索结果的好友更换已好友状态
-- 2、更新好友列表
function FriendController:onDeleteFriendBack(status, mid)
    if status then
        local searchFriend = self.m_baseData:getSearchFriend()
        if searchFriend and tonumber(searchFriend.mid) == tonumber(mid) then
            searchFriend.isFriend = 0
            self:updateView("updateSearchFriend", true, searchFriend)
        end
        self:loadFriendData()
    end
end

-------------------------------- event listen ------------------------

-- 好友状态更新
function FriendController:onFriendOnlineStatus()
    self:loadFriendData(true)
end

-------------------------------- native event -----------------------------

-------------------------------- table config ------------------------

FriendController.s_cmdHandleEx = 
{
    ["back"] = FriendController.onBack,
    ["getFriendList"] = FriendController.loadFriendData,
    ["getRecommendFriendList"] = FriendController.onGetRecommendFriendList,
    ["getRecommendFriendListBack"] = FriendController.onGetRecommendFriendListBack,
    ["searchFriendById"] = FriendController.onSearchFriendById,
    ["searchFriendByIdBack"] = FriendController.onSearchFriendByIdBack,
    ["addFriendBack"] = FriendController.onAddFriendBack,
    ["deleteFriendBack"] = FriendController.onDeleteFriendBack,
};

FriendController.s_nativeHandle = {

};

FriendController.s_eventHandle = {
    [EventConstants.friendOnlineStatus] = FriendController.onFriendOnlineStatus,
};

return FriendController