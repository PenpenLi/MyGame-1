-- rankData.lua
-- Last modification : 2016-06-03
-- Description: a data in Rank moudle

local RankData = class(GameBaseData);
local RankConfig = require("game.rank.rankConfig")

function RankData:ctor(controller)
	Log.printInfo("RankData.ctor");
end

function RankData:dtor()
	Log.printInfo("RankData.dtor");
end

-- -- 第一标题index，默认1
-- function RankData:setMainTabIndex(index)
-- 	self.m_mainTabIndex = index
-- end

-- function RankData:getMainTabIndex()
-- 	return self.m_mainTabIndex or 1
-- end

-- -- 第二标题index，默认1
-- function RankData:setSubTabIndex(index)
-- 	self.m_subTabIndex = index
-- end

-- function RankData:getSubTabIndex()
-- 	return self.m_subTabIndex or 1
-- end

-- 总排行数据
function RankData:setTotalRank(typeStr, data)
	if not self.m_totalRank then
		self.m_totalRank = {}
	end
	self.m_totalRank[typeStr] = data
end

function RankData:appendTotalRank(typeStr, data)
	if not self.m_totalRank or not self.m_totalRank[typeStr] then
		self:setTotalRank(typeStr, data)
		return
	end
	table.foreach(data, function(i, v)
            table.insert(self.m_totalRank[typeStr], v)
        end)
end

function RankData:getTotalRank(typeStr)
	if not self.m_totalRank then
		return {}
	end
	return self.m_totalRank[typeStr]
end

-- 总排行中自己的数据
function RankData:setMyTotalRank(typeStr, data)
	if not self.m_myTotalRank then
		self.m_myTotalRank = {}
	end
	self.m_myTotalRank[typeStr] = data
end

function RankData:getMyTotalRank(typeStr)
	if not self.m_myTotalRank then
		return {}
	end
	return self.m_myTotalRank[typeStr]
end

-- 好友数据
function RankData:setFriendsData(data)
	self.m_friendsData = data
end

function RankData:getFriendsData()
	return self.m_friendsData
end

-- 自己一周内的牌局记录（排行榜中使用）
function RankData:setMyGameData(data)
	self.m_myGameData = data
end

function RankData:getMyGameData()
	if not self.m_myGameData then
		self.m_myGameData = {
            mid = nk.userData.mid,
	        name =  nk.userData.name, 
	        micon = nk.userData.micon, 
	        money = nk.functions.getMoney(), 
	        msex = nk.userData.msex,
	        incMoney = 0,
	        ptotal = 0,
	        pwin = 0,
	        plose = 0,
	    }
	end
	return self.m_myGameData
end

----------------------------http-------------------------

function RankData:onGetMyGameDataBack(errorCode,data)
	Log.printInfo("RankData.onGetMyGameDataBack");
	Log.dump(data);
	if errorCode == HttpErrorType.SUCCESSED then
        if data then
            local retData = data.data
            self:setMyGameData(retData.ranksList)
        end
    end
    self:requestCtrlCmd("getMyGameDataBack", errorCode, data)
end

----------------------------table config---------------------

-- Event to register and unregister
RankData.s_eventHandle = {
    -- [Event ] = function
    [EventConstants.httpProcesser] = RankData.onHttpPorcesser,
};

RankData.s_httpRequestsCallBack = {
	-- ["Http.load"] = RankData.loadCallBack,
	["getMyGameData"] = RankData.onGetMyGameDataBack,
}

-- Provide handle to call
RankData.s_cmdConfig = 
{
	--["***"] = function
};

return RankData