--
-- Author: JasonLi
-- Date: 2016-02-17 10:20:28
-- 喇叭数据管理类

local GameBroadCastHistoryManager = class()

GameBroadCastHistoryManager.fileName = "broadcast"
GameBroadCastHistoryManager.broadCastHistory = {}
GameBroadCastHistoryManager.maxNum = 20

function GameBroadCastHistoryManager:ctor()
	self:readBroadCastHistory()
end 

function GameBroadCastHistoryManager:setBroadCastData(data)
	GameBroadCastHistoryManager.broadCastHistory = data
	self:saveBroadCastHistory()
end

function GameBroadCastHistoryManager:getBroadCastData()
	return GameBroadCastHistoryManager.broadCastHistory
end

function GameBroadCastHistoryManager:readBroadCastHistory()
    local content = nk.DictModule:getString(GameBroadCastHistoryManager.fileName, nk.cookieKeys.GAME_BROADCAST, "")
    content = json.decode(content)
    if content and content ~= "" then
		GameBroadCastHistoryManager.broadCastHistory = content
	end
end

function GameBroadCastHistoryManager:addBroadCast(msg)
	if msg then
		local broadCastList = self:getBroadCastData()
		self:isNeedRemove(broadCastList)
		table.insert(broadCastList,msg)
		self:setBroadCastData(broadCastList)
		EventDispatcher.getInstance():dispatch(EventConstants.refreshBroadcastList, broadCastList)
	end
end

function GameBroadCastHistoryManager:isNeedRemove(broadCastList)
	if #broadCastList >= GameBroadCastHistoryManager.maxNum then
		table.remove(broadCastList, 1)
	end
end

function GameBroadCastHistoryManager:deleteBroadCast()
	local broadCastList = self:getBroadCastData()
	if #broadCastList > GameBroadCastHistoryManager.maxNum then
		table.remove(broadCastList, 1)
		self:setBroadCastData(broadCastList)
	end
end

function GameBroadCastHistoryManager:saveBroadCastHistory()
    nk.DictModule:setString(GameBroadCastHistoryManager.fileName, nk.cookieKeys.GAME_BROADCAST, json.encode(GameBroadCastHistoryManager.broadCastHistory))
    nk.DictModule:saveDict(GameBroadCastHistoryManager.fileName)
end

return GameBroadCastHistoryManager