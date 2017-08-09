--
-- Author: tony
-- Date: 2014-07-08 14:23:34
--

local RoomModel = {}
local seatUICount = 4

function RoomModel.new()
    local instance = {}
    local datapool = {}
    local function getData(table, key)
        return RoomModel[key] or datapool[key]
    end
    local function setData(table, key, value)
        datapool[key] = value
    end
    local function clearData(self)
        local newdatapool = {}
        for k, v in pairs(datapool) do
            if type(v) == "function" then
                newdatapool[k] = v
            end
        end
        datapool = newdatapool
        return self
    end
    instance.clearData = clearData
    local mtable = {__index = getData, __newindex = setData}
    setmetatable(instance, mtable)
    instance:ctor()
    return instance
end

function RoomModel:ctor()
    self.isSelfInGame_ = false  
    self.selfSeatId_ = -1    
    self.roomType_ = 0
    self.roomInviteTime=0
    self.playerList = {}
    self.gameInfo = {}
    self.roomInfo = {}
end

-- 是否是自己
function RoomModel:isSelf(uid)
    return nk.userData.uid == uid
end

-- 是否正在游戏（游戏开始至游戏刷新，弃牌置为false）
function RoomModel:isSelfInGame()
    return self.isSelfInGame_
end

-- 本人是否在座
function RoomModel:isSelfInSeat()
    local selfInSeat = self.selfSeatId_ >= 0 and self.selfSeatId_ <= seatUICount
    consts.SVR_USER_STATE.USER_STATE_INSEAT = selfInSeat
    return selfInSeat
end

-- 本人是否为庄家
function RoomModel:isSelfDealer()
    return self.selfSeatId_ == self.gameInfo.dealerSeatId
end


-- 获取自己的座位id
function RoomModel:selfSeatId()
    return self.selfSeatId_
end

-- 获取自己
function RoomModel:selfSeatData()
    return self.playerList[self.selfSeatId_]
end

-- 获取庄家
function RoomModel:dealerSeatData()
    return self.playerList[self.gameInfo.dealerSeatId]
end

-- 获取当前房间类型
function RoomModel:roomType()
    return self.roomType_
end

-- 获取当前在桌人数
function RoomModel:getNumInSeat()
    local num = 0
    for i = 0, seatUICount -1 do
        if self.playerList[i] then
            num = num + 1
        end
    end

    return num
end
-- 获取牌桌所有用户的UID 
function RoomModel:getTableAllUid()
    local tableAllUid = ""
    local userUid = ""
    local toUidArr = {}
    for seatId = 0, seatUICount -1 do
        local player = self.playerList[seatId]
        if player and player.uid then
            userUid = userUid..","..player.uid
            table.insert(toUidArr, player.uid)
        end
        tableAllUid = string.sub(userUid,2)
    end
    return tableAllUid,toUidArr
end

function RoomModel:getSeatIdByUid(uid)
    for seatId = 0, seatUICount -1 do
        local player = self.playerList[seatId]
        if player and player.uid == uid then
            return seatId
        end
    end
    return -1
end


-- 获取本轮参与玩家人数
function RoomModel:getNumInRound()
    local num = 0
    for i = 0, seatUICount -1 do
        if self.playerList[i] and self.playerList[i].isPlay == 1 then
            num = num + 1
        end
    end
    return num
end

function RoomModel:roomInvite(needAdd)
    needAdd=needAdd or false
    if needAdd then
        self.roomInviteTime=self.roomInviteTime+1
    end
    return self.roomInviteTime
end


function RoomModel:initWithLoginSuccessPack(pack)
    self.isSelfInGame_ = false
    self.selfSeatId_ = -1
    self.roomType_ = 0
    self.roomInviteTime=0

    --座位配置
    local seatsInfo = {}
    self.seatsInfo = seatsInfo
    seatsInfo.seatNum = pack.maxSeatCnt
    for i=1, pack.maxSeatCnt do
        local seatId = i - 1
        local seatInfo = {}
        seatInfo.seatId = seatId
        seatsInfo[seatId] = seatInfo
    end
    
    --房间信息
    local roomInfo = {}
    self.roomInfo = roomInfo
    roomInfo.roomType = pack.tableLevel
    roomInfo.playerNum = pack.maxSeatCnt
    roomInfo.tid     = pack.tableId
    local roomData = nk.functions.getRoomDataByLevel(roomInfo.roomType, nk.isInSingleRoom)
    roomInfo.blind = pack.baseAnte           -- 房间底注 
    roomInfo.minBuyIn = roomData.minBuyIn        -- 最小携带
    roomInfo.maxBuyIn = roomData.maxBuyIn        -- 最大携带
    roomInfo.defaultBuyIn = roomData.quickBuyIn  -- 默认携带
    -- local levelNameMap = {["Bonus"] = 1, ["Pemula"] = 2, ["Ahli"] = 3}
    roomInfo.tableStyle = roomData.backdrop + 1 -- 房间桌布风格
    roomInfo.fee = pack.fee                 -- 房间台费
    roomInfo.escapeMoney = pack.escapeMoney   -- 逃跑扣费
    roomInfo.ownerUid = pack.ownerUid or 0   -- 房主UID【私人房】
    roomInfo.roomName = pack.roomName   -- 房间名【私人房】

    consts.SIDECHIPS_STATUS.BUY_BLIND = roomInfo.blind

    --房间level, 房间类型
    self.roomType_ = roomInfo.roomType
    -- nk.GameBroadcastNotice:setRoomType(self.roomType_)

    -- dump(roomInfo, "roomInforoomInforoomInforoomInforoomInfo")

    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo
    
    --房间当前状态 ,具体类型在consts.SVR_GAME_STATUS中
    gameInfo.gameStatus = pack.tableStatus

    --庄家位置
    gameInfo.dealerSeatId = pack.dealerSeatId

    --当前操作者的座位，-1无效
    gameInfo.curDealSeatId = pack.curOpSeatId
    
    --当前操作者剩余时间,0表示没有倒计时
    gameInfo.userAnteTime = pack.opTime or 5

    --桌子上的总奖池
    gameInfo.totalAnte = pack.moneyPool

    --桌子上第一张牌点数
    gameInfo.headCardValue = pack.headCardValue

    --桌子上最后一张牌点数
    gameInfo.tailCardValue = pack.tailCardValue

    --第一张出的牌在列表中的位置
    gameInfo.firstOutCardValue = pack.firstOutCardValue

    --是否在游戏中,当游戏开始时为true，当弃牌时为false
    self.isSelfInGame_ = false  

    nk.functions.setMoney(pack.money)

    --在玩玩家信息
    local playerList = {}
    self.playerList = playerList
    if pack.playerList then
        for i, player in ipairs(pack.playerList) do
            player.userInfo = json.decode(player.userInfo)
            if not player.userInfo then
               player.userInfo = nk.functions.getUserInfo(true) 
            end
            player.userInfo.money = player.money       
            playerList[player.seatId] = player
            
            local boolPlaying = player.userStatus == consts.SVR_USER_STATE.USER_STATE_GAMEING 

            player.isPlay = boolPlaying and 1 or 0

            player.isSelf = self:isSelf(player.uid)        
            if player.isSelf then
                self.selfSeatId_ = player.seatId
                self.isSelfInGame_ = boolPlaying   
                nk.functions.setMoney(player.money)       
            end        

            player.cardsCount = player.cards and #player.cards or 0
            player.isDealer =  (player.seatId == self.gameInfo.dealerSeatId)
        end   
    end

    -- 桌面的牌
    local tableCardList = {}
    self.tableCardList = tableCardList
    if pack.tableCardList then
        for i, cardValue in ipairs(pack.tableCardList) do
            tableCardList[i] = cardValue;
        end
    end

    --其他消费配置 
    self.roomCostConf = nk.DataProxy:getData(nk.dataKeys.ROOM_COST)
    if self.roomCostConf ~= nil and self.roomCostConf[tostring(self.roomType_)] == nil then
        -- 这里是为了加入私人房的配置
        self.roomCostConf[tostring(self.roomType_)] = {}
        self.roomCostConf[tostring(self.roomType_)][1] = roomData.prop
        self.roomCostConf[tostring(self.roomType_)][2] = roomData.expression
    end

    if pack.sideChipsList and #pack.sideChipsList > 0 then
        local curSideChips = pack.sideChipsList[1]
        if curSideChips.sideChip > 0 then
            consts.SIDECHIPS_STATUS.BUY_STATUS = 1
            consts.SIDECHIPS_STATUS.BUY_BET = curSideChips.sideChip / consts.SIDECHIPS_STATUS.BUY_BLIND
            consts.SIDECHIPS_STATUS.BUY_TYPE = curSideChips.cardType
        end
    end

    if not nk.isInSingleRoom then
        self:getRoomfunction()
    end
end

function RoomModel:getRoomfunction()
    -- cocos版本 接龙房间边注玩法相关
    -- 1.5.0 版本不做
    -- 具体 边注玩法代码 搜索cocos版本 SIDECHIPS_STATUS 即可
end

function RoomModel:processGameStart(pack)
    -- 设置gameInfo
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.GAME_RUNING  --房间状态
    self.gameInfo.dealerSeatId = pack.dealerSeatId      --庄家位置
    self.gameInfo.curDealSeatId = pack.dealerSeatId     --游戏刚开始第一个谈话的是庄家
    self.gameInfo.totalAnte = pack.moneyPool            --桌子上的总筹码堆
    self.gameInfo.userAnteTime = pack.opTime            --操作时间
    for i = 0, seatUICount -1 do
        local player = self.playerList[i]
        if player then
            player.isPlay = 1
            player.userStatus = 1
            player.isDealer =  ( i ==  self.gameInfo.dealerSeatId )        
            player.isOutCard = player.isSelf and 1 or 0
            player.userInfo.money = player.userInfo.money - self.roomInfo.fee
            if player.isSelf then 
                nk.functions.setMoney(player.userInfo.money)   
            end

            for k,v in pairs(pack.playerCradList) do
                if v.seatId == player.seatId then
                    player.cards = v.cards
                    break;
                end
            end

            if player.cards then
                player.cardsCount = #player.cards
            else
                player.cardsCount = 0
            end
            player.turnMoney = 0
            player.getExp = 0
            player.isPlayBeforeGameOver = 0

            if player.isSelf then
                self.isSelfInGame_ = true  
            end
        end
    end 
end

function RoomModel:processPot(moneyPool)
    if self.gameInfo then
        self.gameInfo.totalAnte = moneyPool  
    end
end

function RoomModel:processTurnTo(pack)
    if pack.nextUid ~= 0 then
        local seatId = self:getSeatIdByUid(pack.nextUid)
        if self.gameInfo then
            self.gameInfo.curDealSeatId = pack.seatId     --轮到该位置id
            self.gameInfo.userAnteTime = pack.opTime  --谈话时间
        end
        return seatId
    else
        return -1
    end
end

function RoomModel:processSitDown(pack)
    print("RoomModel:processSitDown")
    local player = pack
    local prePlayer = self.playerList[player.seatId]
    local isAutoBuyin = false
    if prePlayer then
        if prePlayer.uid == player.uid then
            isAutoBuyin = true
        end
    end

    player.userInfo = json.decode(player.userInfo)
    if not player.userInfo then
       player.userInfo = nk.functions.getUserInfo(true) 
    end

    player.isPlay = 0
    player.userStatus = 0
    player.isDealer = (player.seatId == self.gameInfo.dealerSeatId)   
    self.playerList[player.seatId] = player
    player.isSelf = self:isSelf(player.uid)
    -- 判断是否是自己
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        player.userInfo.mavatar = nk.userData.micon
        player.userInfo.giftId = nk.userData.gift
        nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())
        --更新互动道具数量

        --获取道具数量
        -- 2001 互动道具 1.0.1版本互动道具使用时直接消耗金币 jasonli
    end
    return player.seatId, isAutoBuyin
end

function RoomModel:processStandUp(pack)
    print("RoomModel:processStandUp")
    local player = self.playerList[pack.seatId]
    if player and player.isSelf then              
        self.isSelfInGame_ = false
        self.selfSeatId_ = -1
        nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())
        
        -- 设置金钱
        if pack.money then
            nk.functions.setMoney(pack.money)   
        end
    end
    player = nil
    self.playerList[pack.seatId] = nil
    return pack.seatId
end

function RoomModel:processGameOver(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.GAME_STOP
    for _,row in ipairs(pack.playerList) do
       local player = self.playerList[row.seatId]
       if player then
            player.anteMoney = row.money   --剩余携带
            player.turnMoney = row.turnMoney   --金币变化数
            player.totalMoney = row.money  --当前总金钱数
            player.userInfo.money = player.totalMoney
            player.isOutCard = row.isOutCard or 1 --弃牌的人的牌和自己的牌不用翻转展示
            if player.isSelf then  
                player.isOutCard = 0    --如果这里没有置0，结算时会出现又可以切牌的情况
            end

            player.cardsCount = #row.cards --手牌数

            if player.isOutCard == 1 then
                player.cards = row.cards
            end

            if player.isSelf and pack.winnerUid == nk.userData.uid then
                player.getExp = pack.exp_win
            elseif player.isSelf then
                player.getExp = pack.exp_lose
            end

            if player.isSelf then
                -- 设置金钱
                local money1 = nk.userData.money
                nk.functions.setMoney(row.money)   
                local money2 = nk.userData.money
                nk.isWin = money2>money1 and 1 or 0
            end
       end
    end

    for i = 0, seatUICount -1 do
        local player = self.playerList[i]
        if player then
            player.isPlayBeforeGameOver = player.isPlay
            player.isPlay = 0    
            player.userStatus = 0        
        end
    end
    self.isSelfInGame_ = false
end



function RoomModel:processMaxWinMoney(winMoney)
    if nk.userData.best and nk.userData.best.maxwmoney then
        if winMoney > nk.userData.best.maxwmoney then
            local info = {}
            local params = {}
            params.maxwmoney = winMoney
            info.multiValue = params
            nk.HttpController:execute("updateMemberBest", {game_param = info})
            nk.userData.best["maxwmoney"] = info.maxwmoney
        end
    end
end

function RoomModel:reset()  
    self.isSelfInGame_ = false
end

return RoomModel