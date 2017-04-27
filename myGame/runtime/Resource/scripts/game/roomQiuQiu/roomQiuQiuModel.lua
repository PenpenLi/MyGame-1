--
-- Author: tony
-- Date: 2014-07-08 14:23:34
--
local SeatStateMachine = require("game.roomQiuQiu.roomQiuQiuStateMachine")
local HandCard = require("game.roomQiuQiu.layers.handCard")
local RoomQiuQiuModel = {}
local seatUICount = 7

function RoomQiuQiuModel.new()
    local instance = {}
    local datapool = {}
    local function getData(table, key)
        return RoomQiuQiuModel[key] or datapool[key]
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

function RoomQiuQiuModel:ctor()
    self.isInitialized = false
    self.isSelfInGame_ = false  
    self.selfSeatId_ = -1    
    self.roomType_ = 0
    self.roomInviteTime=-1
    self.playerList = {}
    self.gameInfo = {}
    self.roomInfo = {}
    self.lastAnte = 0 --最后一次下注
end

-- 是否是自己
function RoomQiuQiuModel:isSelf(uid)
    return nk.userData.uid == uid
end

-- 是否正在游戏（游戏开始至游戏刷新，弃牌置为false）
function RoomQiuQiuModel:isSelfInGame()
    return self.isSelfInGame_
end

-- 本人是否在座
function RoomQiuQiuModel:isSelfInSeat()
    return self.selfSeatId_ >= 0 and self.selfSeatId_ <= seatUICount
end

-- 本人是否为庄家
function RoomQiuQiuModel:isSelfDealer()
    return self.selfSeatId_ == self.gameInfo.dealerSeatId
end

--是否满座
function RoomQiuQiuModel:isFullSeat()
    for seatId = 0, seatUICount -1 do
        local player = self.playerList[seatId]
        if not player then
            return false
        end
    end
    return true
end

-- 获取自己的座位id
function RoomQiuQiuModel:selfSeatId()
    return self.selfSeatId_
end

-- 获取自己
function RoomQiuQiuModel:selfSeatData()
    if self.playerList then
    return self.playerList[self.selfSeatId_]
    else
        return nil
    end 
end

-- 获取庄家
function RoomQiuQiuModel:dealerSeatData()
    return self.playerList[self.gameInfo.dealerSeatId]
end

-- 获取当前房间类型
function RoomQiuQiuModel:roomType()
    return self.roomType_
end

-- 获取当前在桌人数
function RoomQiuQiuModel:getNumInSeat()
    local num = 0
    for i = 0, seatUICount -1 do
        if self.playerList[i] then
            num = num + 1
        end
    end

    return num
end
-- 获取牌桌所有用户的UID 
function RoomQiuQiuModel:getTableAllUid()
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

function RoomQiuQiuModel:getSeatIdByUid(uid)
    if self.playerList then
        for seatId = 0, seatUICount -1 do
            local player = self.playerList[seatId]
            if player and player.uid == uid then
                return seatId
            end
        end
    end
    return -1
end

function RoomQiuQiuModel:getSeatDataByUid(uid)
    if self.playerList then
        for seatId = 0, seatUICount -1 do
            local player = self.playerList[seatId]
            if player and player.uid == uid then
                return player
            end
        end
    end
    return nil
end

-- 获取本轮参与玩家人数
function RoomQiuQiuModel:getNumInRound()
    local num = 0
    for i = 0, seatUICount -1 do
        if self.playerList[i] and self.playerList[i].isPlay == 1 then
            num = num + 1
        end
    end
    return num
end

function RoomQiuQiuModel:getNewCardType(cardType, pointCount)
    return CardType.new(cardType, pointCount)
end

-- 等于-1当前没有邀请位置;否则,有邀请位置
function RoomQiuQiuModel:setRoomInvite(time)
    self.roomInviteTime=time
    -- needAdd=needAdd or false
    -- if needAdd then
    --     self.roomInviteTime=self.roomInviteTime+1
    -- end
    -- return self.roomInviteTime
end

function RoomQiuQiuModel:getRoomInvite()
    return self.roomInviteTime
end


function RoomQiuQiuModel:initWithLoginSuccessPack(pack)
    -- self.clearData()
    self.isInitialized = true
    self.isSelfInGame_ = false
    self.selfSeatId_ = -1
    self.roomType_ = 0
    self.roomInviteTime=-1
    nk.userData.roomBuyIn = nil

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
    -- FwLog("pack = " .. json.encode(pack))
    roomInfo.minBuyIn = pack.minAnte
    roomInfo.maxBuyIn = pack.maxAnte
    roomInfo.roomType = pack.tableLevel
    roomInfo.blind = pack.baseAnte
    roomInfo.playerNum = pack.maxSeatCnt
    roomInfo.defaultBuyIn = pack.defaultAnte
    roomInfo.tid     = pack.tableId
    local roomData = nk.functions.getRoomQiuQiuDataByLevel(roomInfo.roomType)
    if roomData then
        roomInfo.tableStyle = roomData.backdrop + 1
    end

    --房间level, 房间类型
    self.roomType_ = roomInfo.roomType

    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo
    
    --房间当前状态 ,具体类型在consts.SVR_GAME_STATUS中
    gameInfo.gameStatus = pack.tableStatus

    --庄家位置
    gameInfo.dealerSeatId = pack.dealerSeatId

    --每轮操作时间
    gameInfo.roundTime = pack.roundTime

    --当前操作者的座位，-1无效
    gameInfo.curDealSeatId = pack.curDealSeatId     
    
    --当前操作者剩余时间,0表示没有倒计时
    gameInfo.userAnteTime = pack.userOperatingTime

    --桌子上的总投注
    gameInfo.totalAnte = pack.totalAnte

    --快速跟注值
    gameInfo.quickCall = pack.quickCall
    gameInfo.minAddAnte = pack.nMinAnte    --加注最小值
    gameInfo.maxAddAnte = pack.nMaxAnte    --加注最大值

    --是否在游戏中,当游戏开始时为true，当弃牌时为false
    self.isSelfInGame_ = false  
    nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, false)
    
    --在玩玩家信息
    local playerList = {}
    self.playerList = playerList
    for i, player in ipairs(pack.playerList) do
        self:initSeatPlayer(player)
    end
    --其他消费配置 
    self.roomCostConf = nk.DataProxy:getData(nk.dataKeys.ROOM_COST)
end

function RoomQiuQiuModel:initSeatPlayer(player)
    local playerList = self.playerList
    player.userInfo = json.decode(player.userInfo)
    if not player.userInfo then
       player.userInfo = nk.functions.getUserInfo(true) 
    end
    playerList[player.seatId] = player
    
    local boolPlaying = (player.userStatus ~= consts.SVR_BET_STATE.USER_STATE_READY 
                        and player.userStatus ~= consts.SVR_BET_STATE.USER_STATE_GIVEUP
                        and player.userStatus ~= consts.SVR_BET_STATE.USER_STATE_STAND
                        )  

    --相当于 a?b:c --by ziway
    player.isPlay = boolPlaying and 1 or 0

    player.isSelf = self:isSelf(player.uid)        
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        self.isSelfInGame_ = boolPlaying

        --携带金币数+总下注金币数=用户坐下带入
        nk.userData.roomBuyIn = player.anteMoney + checkint(player.nCurAnte)   

        nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, true)
    end        

    -- player.onlineStatus
    -- player.hasConfirmCards
    -- player.specialCardsType
    -- player.cardsCount

    --亮牌
    if player.isOutCard == 1 then
        local cards = {}
        cards[1] = player.card1
        cards[2] = player.card2
        cards[3] = player.card3

        if player.cardsCount == 4 then
             cards[4] = player.card4
        end
        player.cards = cards

        player.card1 = nil
        player.card2 = nil
        player.card3 = nil
        player.card4 = nil
    end

    --弃牌的人，手牌数置0
    if player.userStatus == consts.SVR_BET_STATE.USER_STATE_GIVEUP then
        player.cardsCount = 0
    end

    player.isDealer =  (player.seatId == self.gameInfo.dealerSeatId)
    player.statemachine = new(SeatStateMachine, player , self.gameInfo.gameStatus)
end   


function RoomQiuQiuModel:processGameStart(pack)
    -- 设置gameInfo
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS_QIUQIU.TABLE_BET_ROUND  --房间状态
    self.gameInfo.dealerSeatId = pack.dealerSeatId      --庄家位置
    self.gameInfo.curDealSeatId = pack.dealerSeatId     --游戏刚开始第一个谈话的是庄家
    self.gameInfo.totalAnte = pack.nTotalAnte           --桌子上的总筹码堆
    self.roomInfo.blind = pack.blinds                  --更新房间底注
    
    --发牌，把上局所有人的亮牌标记清理(以前是发牌时所有人一定都参与，现在有复活时间)
    for k,player in pairs(self.playerList) do
        if player then
            player.isOutCard = 0
        end
    end

    for k,v in pairs(pack.anteMoneyList) do
        local i = v.seatId
        local player = self.playerList[i]
        if player then
            player.isPlay = 1
            player.isDealer =  ( i ==  self.gameInfo.dealerSeatId )        
            player.statemachine:doEvent(SeatStateMachine.Evt_GAME_START)
            
            player.isOutCard = player.isSelf and 1 or 0
            player.curAnte = v.baseAnte or pack.blinds         --普通场是pack.blinds，比赛场是v.baseAnte
            player.nCurAnte = v.baseAnte or pack.blinds

            player.anteMoney = v.anteMoney
            -- if v.userStatus then                     --比赛场才有的
            --     player.userStatus = v.userStatus
            --     if player.userStatus == consts.SVR_BET_STATE.USER_STATE_ALLIN then
            --         player.statemachine:doEvent(SeatStateMachine.Evt_ALL_IN)
            --     end
            -- end

            player.trunMoney = 0
            player.getExp = 0
            player.isPlayBeforeGameOver = 0

            player.cards = nil
            player.cardsCount = 3     --游戏开始包，所有桌子上的人三张牌

    	    if player.isSelf then
                self.isSelfInGame_ = true  
	            if pack.cards then
	                player.cards = pack.cards
	                player.cardsCount = #player.cards
	            else
	                player.cardsCount = 0 
	            end

            	nk.userData.roomBuyIn = player.anteMoney + pack.blinds     --开始带入筹码数
                if player.isDealer then
                    -- self.gameInfo.minAddAnte = pack.dealerMinAnte    --庄家加注最小值,非庄家此值无意义
                    -- self.gameInfo.maxAddAnte = pack.dealerMaxAnte    --庄家加注最大值，0：不可以加注，非庄家此值无意义
                    self.gameInfo.quickCall = 0
                end
            end
        end    
    end
end

function RoomQiuQiuModel:isChangeDealer()
    if self.gameInfo == nil or self.gameInfo.dealerSeatId == nil then
        return true
    end
    local oldDealer = self.gameInfo.dealerSeatId
    local maxMoney = 0
    local dealerSeatId = 0
    for i=0,seatUICount -1 do
        local player = self.playerList[i]
        if player then
            if player.anteMoney > maxMoney then
                dealerSeatId = player.seatId
                maxMoney = player.anteMoney
            end
        end
    end    
    return oldDealer ~= dealerSeatId
end

function RoomQiuQiuModel:processBetSuccess(pack)
    if not self.gameInfo then
        return  
    end
    self.gameInfo.totalAnte = pack.nTotalAnte  --桌上金币总数,即操作后的奖池总金币数
    
    local player = self.playerList[pack.seatId]

    if not player then
        return pack.seatId
    end
    self.lastAnte = pack.curAnte
    player.curAnte = pack.curAnte       -- 当前下注
    player.nCurAnte = (player.nCurAnte or 0) + player.curAnte       -- 总下注
    player.anteMoney = pack.anteMoney               -- 剩余携带


    if pack.userOperatingType == consts.SVR_BET_STATE.USER_STATE_CEKPOKER then
        player.statemachine:doEvent(SeatStateMachine.Evt_CEK)
    elseif pack.userOperatingType == consts.SVR_BET_STATE.USER_STATE_CALL then
        player.statemachine:doEvent(SeatStateMachine.Evt_CALL)
    elseif pack.userOperatingType == consts.SVR_BET_STATE.USER_STATE_LKUT then
        player.statemachine:doEvent(SeatStateMachine.Evt_RAISE)
    elseif pack.userOperatingType == consts.SVR_BET_STATE.USER_STATE_ALLIN then
        player.statemachine:doEvent(SeatStateMachine.Evt_ALL_IN)
    elseif pack.userOperatingType == consts.SVR_BET_STATE.USER_STATE_GIVEUP then
        player.statemachine:doEvent(SeatStateMachine.Evt_GIVE_UP)
        player.isPlay = 0
        player.isOutCard = 0

        if player.isSelf then
            self.isSelfInGame_ = false

            -- nk.taskController:updateStatus({TaskType.TYPE_5,TaskType.TYPE_7,TaskType.TYPE_9},self.roomInfo.roomType)
        end
    end

    if player.anteMoney < 0 then
        printError("anteMoney is "..player.anteMoney)
    end
    return pack.seatId
end

function RoomQiuQiuModel:processPot(pack)
    self.gameInfo.totalAnte = pack.totalAnte  
end

--发牌
function RoomQiuQiuModel:processDeal(pack)
    local player = self:selfSeatData()
    if player then 
        player.cards = pack.cards
        player.cardsCount = #pack.cards
        local handCard = new(HandCard)
        handCard:setCards(player.cards)
        player.handCard = handCard
        player.isOutCard = 0
    end
end

--亮牌
function RoomQiuQiuModel:processShowHand(pack)
    local player = self.playerList[pack.seatId] 
    player.cards = pack.cards
    player.isOutCard = 1
    player.cardsCount = #pack.cards
    local handCard = new(HandCard)
    handCard:setCards(player.cards)
    player.handCard = handCard
    player.statemachine:doEvent(SeatStateMachine.SHOW_POKER)
end

function RoomQiuQiuModel:processTurnTo(pack)
    self.gameInfo.curDealSeatId = pack.seatId     --轮到该位置id
    self.gameInfo.userAnteTime = pack.userOperatingTime  --谈话时间
    self.gameInfo.quickCall = pack.quickCall --跟注值

    local player = self.playerList[pack.seatId] 
    if player then
        player.statemachine:doEvent(SeatStateMachine.Evt_TURN_TO)
        if player.isSelf then
            self.gameInfo.minAddAnte = pack.nMinAnte    --加注最小值
            self.gameInfo.maxAddAnte = pack.nMaxAnte    --加注最大值
        end
    end
    
    return pack.seatId
end

function RoomQiuQiuModel:processFourthCardsStage(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS_QIUQIU.TABLE_BET_ROUND_4card
    
    local player = self:selfSeatData()
    if player and self:isSelfInGame() then
        player.cardsCount = 4
        player.specialCardsType = pack.specialCardsType

        --找出第四张牌
        if player.cards then --容错，友盟报错
            for i=1,player.cardsCount do
                if not self:isHasCard(player.cards,pack.cards[i]) then
                    player.cards[4] = pack.cards[i]
                end
            end 
        end
    end
end

-- function RoomQiuQiuModel:processGetPoker(pack)
--     local player = self.playerList[pack.seatId] 
    -- player.statemachine:doEvent(SeatStateMachine.GET_POKER)
--     if pack.type == 1 then
--         player.cardsCount = 3
--     else
--         player.cardsCount = 2
--     end
--     return pack.seatId
-- end

-- function RoomQiuQiuModel:processGetPokerBySelf(pack)
    
    -- player.isOutCard = 0
-- end

function RoomQiuQiuModel:isHasCard(cards,cardUnit)
    for i=1, #cards do
        if cards[i] == cardUnit then
            return true
        end
    end
    return false
end

function RoomQiuQiuModel:processSitDown(pack)
    self.playerList = self.playerList or {}  --容错，友盟报错
    self.gameInfo = self.gameInfo or {dealerSeatId = -1,gameStatus = consts.SVR_GAME_STATUS.TABLE_OPEN}
    
    local player = pack
    player.userInfo = json.decode(player.userInfo)

    if not player.userInfo then
       player.userInfo = nk.functions.getUserInfo(true) 
    end

    local prePlayer = self.playerList[player.seatId]
    local isAutoBuyin = false
    --如果新坐下的和之前的是同个人，只需要更新数据
    if prePlayer and prePlayer.uid == player.uid then
        isAutoBuyin = true

        prePlayer.anteMoney = player.anteMoney
        prePlayer.money = player.money
        prePlayer.userInfo = player.userInfo
        prePlayer.winTimes = player.winTimes
        prePlayer.loseTimes = player.loseTimes

        player = prePlayer
    else
        --如果原来是空座位或者是不同的人，就替换掉
        self.playerList[player.seatId] = player

    	player.isPlay = 0
    	player.isDealer = (player.seatId == self.gameInfo.dealerSeatId)  

        player.userStatus = consts.SVR_BET_STATE.USER_STATE_READY

	    player.statemachine = new(SeatStateMachine, player , self.gameInfo.gameStatus)
	    
	    player.isSelf = self:isSelf(player.uid)
    end
    
    -- 判断是否是自己
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        -- nk.userData['aUser.money'] = pack.money     --总筹码数含携带
        nk.functions.setMoney(pack.money)
        nk.userData.roomBuyIn = pack.anteMoney      --坐下带入筹码数
        player.userInfo.mavatar = nk.userData.micon
        player.userInfo.giftId = nk.userData['gift']
        nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())
        
    end
    return player.seatId, isAutoBuyin
end

function RoomQiuQiuModel:processStandUp(pack)
    local player = self.playerList[pack.seatId]
    if player and player.isSelf then       
        self.isSelfInGame_ = false
        self.selfSeatId_ = -1
        nk.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())
        
        nk.userData.roomBuyIn = nil

        -- 设置金钱
        if pack.money then
            nk.functions.setMoney(pack.money)
        end
    end
    player = nil
    self.playerList[pack.seatId] = nil
    return pack.seatId
end

function RoomQiuQiuModel:processGameOver(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS_QIUQIU.TABLE_GAME_OVER_SHARE_BONUS
    for _,row in ipairs(pack.playerList) do
       local player = self.playerList[row.seatId]
       if player then
            player.anteMoney = row.anteMoney   --剩余携带
            player.turnMoney = row.turnMoney   --金币变化数
            player.totalMoney = row.totalMoney --当前总金钱数
            player.userInfo.money = player.totalMoney
            player.isOutCard = row.isOutCard  --弃牌的人的牌和自己的牌不用翻转展示
            if player.isSelf then
                player.isOutCard = 0    --如果这里没有置0，结算时会出现又可以切牌的情况
            end

            player.specialCardsType = row.specialCardsType  --特殊牌型
            player.cardsCount = row.cardsCount --手牌数

            if player.isOutCard == 1 then
                local cards = {}
                cards[1] = row.card1
                cards[2] = row.card2
                cards[3] = row.card3
                if player.cardsCount == 4 then
                    cards[4] = row.card4
                end
                player.cards = cards
            end

            player.getExp = row.getExp          

            if player.isSelf then
                 -- 设置金钱
                -- nk.userData["aUser.money"] = player.totalMoney
                local money1 = nk.userData.money
                nk.functions.setMoney(player.totalMoney)
                local money2 = nk.userData.money
                nk.isWin = money2>money1 and 1 or 0                
                nk.userData.roomBuyIn = player.anteMoney      --结算时最新的所有携带
                --任务数据更新,总局数已经弃牌的不算
                if self.isSelfInGame_ then
                    -- nk.taskController:updateStatus({TaskType.TYPE_5,TaskType.TYPE_7,TaskType.TYPE_9},self.roomInfo.roomType)
                end
                if player.turnMoney > 0 then
                    -- nk.taskController:updateStatus({TaskType.TYPE_6,TaskType.TYPE_8,TaskType.TYPE_10},self.roomInfo.roomType)
                    nk.userData.win  = (nk.userData.win or 0)  + 1
                else
                    nk.userData.lose = (nk.userData.lose or 0) + 1
                end
                --更新自己的最好手牌数据
                -- self:processBestCard(player.cards)

                --更新最大赢钱数
                -- self:processMaxWinMoney(row.trunMoney)
                
            end
       end
    end

    local bonusList = {}
    self.gameInfo.bonusList = bonusList
    for i = 1,#pack.bonusList do
        local bonusPool = pack.bonusList[i]
        bonusList[i] = {}

        bonusList[i][1] = bonusPool.moneyPool

        len = bonusPool.playersCount

        bonusList[i]["chips"] = {}
        for j = 1, len do
            bonusList[i][j + 1] = bonusPool["seatId"..j]  --bonusPool["money"..j]
            table.insert(bonusList[i]["chips"], bonusPool["money"..j])
        end
    end

    -- local dealer = self:dealerSeatData()
    -- if dealer and dealer.trunMoney < 0 then 
    --     dealer.nCurAnte = - dealer.trunMoney
    -- end

    for i = 0, seatUICount -1 do
        local player = self.playerList[i]
        if player and player.isPlay == 1 then
            player.isPlayBeforeGameOver = player.isPlay
            player.isPlay = 0            
            player.statemachine:doEvent(SeatStateMachine.Evt_GAME_OVER)
        end
    end
    self.isSelfInGame_ = false
end



function RoomQiuQiuModel:processMaxWinMoney(winMoney)
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


--更新最大手牌
function RoomQiuQiuModel:processBestCard(nowCards)

    local needReportMaxCard = false
    local maxwcard = ""
    if nk.userData.best then
        if (nk.userData.best.maxwcard == nil) or (nk.userData.best.maxwcard == "") then
            for _,v in ipairs(nowCards) do
                maxwcard = maxwcard .. string.format("%X",v)
            end
        else
            local vals = string.sub(nk.userData.best.maxwcard, 1, 6)
            local len = math.floor(string.len(vals)/2)

            local cards = {}
            for i=1,len do
                cards[i] = string.sub(vals,2*i - 1,2*i)
            end

            -- local cards = {
            --     string.sub(vals, 1, 2), 
            --     string.sub(vals, 3, 4), 
            --     string.sub(vals, 5, 6)
            -- }

            local pokerCards = {}
            for i = 1, len do
                pokerCards[i] = (tonumber(string.sub(cards[i], 1, 1), 16) * 16 + tonumber(string.sub(cards[i], 2, 2), 16))
            end
                
            local lastMaxCard = new(HandCard)
            lastMaxCard:setCards(pokerCards)

            local handCard = new(HandCard)
            handCard:setCards(nowCards)

            if handCard:compare(lastMaxCard) > 0 then
                local max = ""
                for _,v in pairs(nowCards) do
                    maxwcard = maxwcard .. string.format("%X",v)
                end
            end
        end

        if maxwcard ~= "" then
            local info = {}
            local params = {}
            params.maxwcard = maxwcard
            info.multiValue = params
            nk.HttpController:execute("updateMemberBest", {game_param = info})
            nk.userData.best["maxwcard"] = maxwcard
        end
    end

    
end

function RoomQiuQiuModel:reset()  
    self.isSelfInGame_ = false
end

return RoomQiuQiuModel