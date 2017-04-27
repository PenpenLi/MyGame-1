-- rankController.lua
-- Last modification : 2016-06-12
-- Description: a controller in rank moudle

local RankController = class(GameBaseController);
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")
local RankDataManager = require("game.rank.rankDataManager")
local RankConfig = require("game.rank.rankConfig")
local FriendDataManager = require("game.friend.friendDataManager")

function RankController:ctor(state, viewClass, viewConfig, dataClass, ...)
	Log.printInfo("RankController.ctor");
    self.m_state = state;
    -----------
    -- 标记字段
    -----------

    -- 第一标题index
    self.m_mainTabIndex = 1
    -- 第二标题index
    self.m_subTabIndex = 2

    -- 加载各总排行榜列表状态
    self.m_isGetRankList_ing = {}
    self.m_isGetRankList_ed = {}

    -- 各总排行榜列表总页数
    self.m_rankTolPages = {}
    -- 各总排行榜列表当前页数
    self.m_rankCurrPages = {}

    -- 加载好友数据
    self.m_isGetFriendsData_ing = false

    -- 各排行榜的滚动状态
    self.m_scrollPos = {}
    -----------
    -- 标记字段 end
    -----------

    --self:getFriendsData()
    local mainType = RankConfig.mainType[self.m_mainTabIndex]
    self:getRankData(mainType)
    self:getMyGameData()
end

function RankController:resume()
    Log.printInfo("RankController.resume");
	GameBaseController.resume(self);
end

function RankController:pause()
    Log.printInfo("RankController.pause");
	GameBaseController.pause(self);
end

function RankController:dtor()
    RankDataManager.getInstance():autoDispose()
end

-------------------------------- private function --------------------------

-- Provide state to call
function RankController:onBack()
    StateMachine.getInstance():popState()
end

-- 获取榜单数据(提前设置好第一标题index和第二标题index)
function RankController:getRankData(mainType, isLoadMore)
    Log.printInfo("RankController","getRankData")
    -- 是否已经加载过此榜单
    if self.m_isGetRankList_ed[mainType] then
        -- 是否加载更多
        if isLoadMore then
            if self.m_rankTolPages[mainType] > self.m_rankCurrPages[mainType] then
                self:requestRankData(mainType)
                return
            end
            -- 直接return，加载更多的请求往往不会切换mainTabIndex和subTabIndex
            return
        else
            local subType = RankConfig.subType[self.m_subTabIndex]
            if subType == "total" then
                local data = self.m_baseData:getTotalRank(mainType)
                self:updateView("updateRankList", mainType, subType, data)
                local myRank = self.m_baseData:getMyTotalRank(mainType)
                self:updateView("updateMyRank", mainType, myRank)
                return
            end
        end
    else
        self:requestRankData(mainType)
    end
end

function RankController:requestRankData(mainType)
    Log.printInfo("RankController","requestRankData")
    RankDataManager.getInstance():loadRankData(mainType, (self.m_rankCurrPages[mainType] or 0) + 1, handler(self, self.onGetRankDataBack))
end

-- 获取榜单数据结果
function RankController:onGetRankDataBack(status, retData)
    Log.printInfo("RankController","onGetRankDataBack")
    if status then
        if retData then
            self.m_rankTolPages[retData.type] = retData.tolPage
            self.m_baseData:setMyTotalRank(retData.type, retData.userRank)
            if self.m_rankCurrPages[retData.type] and self.m_rankCurrPages[retData.type] >= retData.page then
                -- 当前页码与获取的页码重复，或当前页码大于获取的页码，获取的页抛弃
                return
            end
            self.m_isGetRankList_ed[retData.type] = true
            self.m_baseData:appendTotalRank(retData.type, retData.list)
            self.m_rankCurrPages[retData.type] = retData.page

            local mainType = RankConfig.mainType[self.m_mainTabIndex]
            local subType = RankConfig.subType[self.m_subTabIndex]
            local listData = self.m_baseData:getTotalRank(mainType)
            if retData.type == mainType then
                local itemIndex
                if self.m_scrollPos[mainType] then
                    itemIndex = self.m_scrollPos[mainType]
                    self.m_scrollPos[mainType] = nil
                end
                self:updateView("updateRankList", mainType, subType, listData, itemIndex)
                self:updateView("updateMyRank", mainType, retData.userRank)
            end
        end
    else
        -- TODO 提示下失败吧
    end
end

-- noCheckStatus 不需要检查状态
function RankController:getFriendsData(noCheckStatus)
    Log.printInfo("RankController","getFriendsData")
    if self.m_isGetFriendsData_ing then  
        return
    end
    self.m_isGetFriendsData_ing = true
    FriendDataManager.getInstance():loadFriendData(handler(self, function(obj, status, data)
            self.m_isGetFriendsData_ing = false
            if status then  
                if self.m_baseData then
                    self.m_baseData:setFriendsData(clone(data))

                    if not table.keyof(self.m_baseData:getFriendsData(), self.m_baseData:getMyGameData()) then
                        table.insert(self.m_baseData:getFriendsData(), self.m_baseData:getMyGameData())
                    end
                
                    self:sortFriendsData(self.m_baseData:getFriendsData())
                    if not noCheckStatus then
                        Clock.instance():schedule_once(function(dt)
                            local uidList_ = FriendDataManager.getInstance():getFriendsUidList()
                            nk.SocketController:checkFriendStatus(nk.userData.mid,#uidList_,uidList_)
                        end, 0.5)
                    end                
                end           
            else

            end
        end))
end

-- 请求自己一周内的牌局记录
function RankController:getMyGameData()
    Log.printInfo("RankController","getMyGameData")
    nk.HttpController:execute("getMyGameData", {})
end

-- 将好友列表重新排序，并刷新页面
function RankController:sortFriendsData(data)
    Log.printInfo("RankController","sortFriendsData")
    if RankConfig.subType[self.m_subTabIndex] == "friend" then
        if #data > 0 then
            table.sort(data, function (a, b) 
                    a.name = a.name or ""
                    b.name = b.name or ""
                    if a[RankConfig.friendsType[self.m_mainTabIndex]] == b[RankConfig.friendsType[self.m_mainTabIndex]] then
                        return a.name < b.name
                    end
                    return a[RankConfig.friendsType[self.m_mainTabIndex]] > b[RankConfig.friendsType[self.m_mainTabIndex]]
                end)
            for i, v in ipairs(data) do
                v.rank = i
            end
        end
        self:updateView("updateRankList", RankConfig.mainType[self.m_mainTabIndex], RankConfig.subType[self.m_subTabIndex], data)
        local myGameData = self.m_baseData:getMyGameData()
        self:updateView("updateMyRank", RankConfig.mainType[self.m_mainTabIndex], myGameData)
    end
end

function RankController:onShowRanking()
    local mainType = RankConfig.mainType[self.m_mainTabIndex]
    local subType = RankConfig.subType[self.m_subTabIndex]
    Log.printInfo("RankController","onShowRanking mainType:" .. mainType .. " subType:" .. subType)
    if subType == "friend" then
        self:getFriendsData()
    elseif subType == "total" then
        self:getRankData(mainType)
    end
end

-------------------------------- handle function --------------------------

-- 设置第一标题
function RankController:onSetMainTabIndex(index)
    Log.printInfo("RankController","onSetMainTabIndex index:" .. index)
    self.m_mainTabIndex = index
    self:onShowRanking()
end

-- 设置第二标题
function RankController:onSetSubTabIndex(index)
    Log.printInfo("RankController","onSetSubTabIndex index:" .. index)
    self.m_subTabIndex = index
    self:onShowRanking()
end

-- 请求自己一周内的牌局记录结果
function RankController:onGetMyGameDataBack(errorCode, data)
    Log.printInfo("RankController","onGetMyGameDataBack")
    if errorCode == HttpErrorType.SUCCESSED then
        if data then
            local retData = data.data
            local myGameData = retData.userRank
            self.m_baseData:setMyGameData(myGameData)
            local friendsData = self.m_baseData:getFriendsData()
            if friendsData then
                friendsData[tostring(nk.userData.mid)] = myGameData
                self:sortFriendsData(friendsData)
            end
        end
    else
        -- TO DO 提示下失败吧
    end
end

function RankController:onLoadMore(itemIndex)
    local mainType = RankConfig.mainType[self.m_mainTabIndex]
    local subType = RankConfig.subType[self.m_subTabIndex]
    if subType == "total" then
        self.m_scrollPos[mainType] = itemIndex
        self:getRankData(mainType, true)
    end
end

-------------------------------- event listen ------------------------

-- 好友状态更新
function RankController:onFriendOnlineStatus()
    local mainType = RankConfig.mainType[self.m_mainTabIndex]
    local subType = RankConfig.subType[self.m_subTabIndex]
    self:getFriendsData(true)
end

-- 好友数量更新
function RankController:onFriendChange()
    self:getFriendsData()
end

-------------------------------- native event -----------------------------

-------------------------------- table config ------------------------

RankController.s_cmdHandleEx = 
{
    ["back"] = RankController.onBack,
    ["setMainTabIndex"] = RankController.onSetMainTabIndex,
    ["setSubTabIndex"] = RankController.onSetSubTabIndex,
    ["loadMore"] = RankController.onLoadMore,
    ["getMyGameDataBack"] = RankController.onGetMyGameDataBack,
    ["getRankDataBack"] = RankController.onGetRankDataBack,
};

RankController.s_nativeHandle = {

};

RankController.s_eventHandle = {
    [EventConstants.friendOnlineStatus] = RankController.onFriendOnlineStatus,
    [EventConstants.addFriendData] = RankController.onFriendChange,
    [EventConstants.deleteFriendData] = RankController.onFriendChange,
}

return RankController