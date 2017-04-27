--
-- Author: tony
-- Date: 2014-07-08 15:00:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ChipManager = class()

local ChipsSpriteConfig = import("game.roomQiuQiu.manager.chipsSpriteConfig")
local BetChipView = import("game.roomQiuQiu.layers.betChipView")
local RoomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")
local ChipsAnimation = import("game.roomQiuQiu.layers.chipsAnimation")
local SP = RoomViewPosition.SeatPosition
local GCP = RoomViewPosition.GetChipsPosition
local SeatCount = 7

function ChipManager:ctor()

end

function ChipManager:createNodes()
    self.textBgBatchNode_ = self.scene.nodes.chipNode
    -- 文字背景层，不移动，根据positionId确定位置
    self.betChipTextBgs_ = {}
    
    -- 文字标签层，不移动，根据positionId或者potId确定位置
    self.betChipTextLabels_ = {}
    for i = 1, SeatCount do
        self.betChipTextBgs_[i] = new(Image, kImageMap.qiuqiu_chip_text_bg,nil,nil,25,25,0,0)
        self.betChipTextBgs_[i]:setSize(120,24)
        self.betChipTextBgs_[i]:addTo(self.textBgBatchNode_)
        self.betChipTextBgs_[i]:setVisible(false)

        self.betChipTextLabels_[i] = new(Text, "999.9M", 30, 30, kAlignCenter, "", 20, 255, 204, 0)
        self.betChipTextLabels_[i]:setAlign(kAlignCenter)
        self.betChipTextLabels_[i]:addTo(self.betChipTextBgs_[i])
    end
    --桌面显示总筹码数
    local totalBoardBg = self.scene.nodes.tableNode:getChildByName("chipsBoardImage")
    self.totalBoard_ = totalBoardBg:getChildByName("chipsValueLabel")

    -- --测试start
    -- self.test_ = 0
    -- math.randomseed(os.time())
    -- self.onClick = function(evt)

    --     local a = {10,10,10,10,10,10,10}
    --     if self.test_ < #a then
    --         local x = a[self.test_ + 1]
    --         self:betChip({curAnte=x, nCurAnte = x, seatId=self.test_})
    --     else
    --         -- local bonusList_1 = {{50, 0, 2, chips={25, 25}}}
    --         local bonusList_2 = {
    --             {35, 0,1 ,2,3,4,5,6,chips={5,5,5,5,5,5,5}},
    --             {35,  0,1 ,2,3,4,5,6,chips={5,5,5,5,5,5,5}},
    --             -- {400 , 0 ,1,2, chips={400}},
    --             -- {12345432 * 6, 0, chips={12345432* 6}},
    --             -- {12345432 * 6, 0, chips={12345432* 6}},
    --             -- {12345432 * 6, 1, chips={12345432* 6}},
    --             -- {12345432 * 6, 0, chips={12345432* 6}},
    --         }
    --         local bonusList = bonusList_1 or bonusList_2   --通过注释其中一个来选择
    --         local bonusListLen = #bonusList

    --         self:GameOverShareBonus(bonusList)

    --         local resetDelayTime = 4 +  (bonusListLen == 1 and 0 or bonusListLen * 2)  
    --         local selfSeat = self.seatManager:getSelfSeatView()
    --         if selfSeat then
    --             selfSeat:playWinAnimation(resetDelayTime - 2)
    --         end

    --         -- nk.GCD.CancelById(sefl,self.anid)
    --         self.anid = nk.GCD.PostDelay(self, function()
    --             -- 重置筹码堆
    --             for _, v in pairs(self.betChipViews_) do
    --                 v:reset()
    --             end

    --             self:recyclePotChipsData_()
    --         end,nil,(resetDelayTime - 2) * 1000)

    --         self.test_ = -1             
    --     end
    --     self.test_ = self.test_ + 1
    -- end
    -- self.totalBoard_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
    --   if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
    --        self:onClick()
    --   end
    --   end) 
    -- 测试end


    -- 筹码容器
    self.chipBatchNode_ = new(Node)
    self.chipBatchNode_:setFillParent(true, true)
    self.chipBatchNode_:addTo(self.scene.nodes.chipNode)
        
    -- 下注筹码视图，key由seatId确定
    self.betChipViews_ = {}
    for i = 0, SeatCount - 1 do
        self.betChipViews_[i] = new(BetChipView, self.chipBatchNode_, self, i)
    end
end

function ChipManager:GameOverShareBonus(bonusList)
    if bonusList then
        if #bonusList == 1 then
            self:chipToPlayer(bonusList[1])
        elseif #bonusList > 1 then
            self:chipSplitToPlayer(bonusList)
        end
    end
end


-- 登录成功，设置登录筹码堆
function ChipManager:setLoginChipStacks()
    local roomInfo = self.model.roomInfo
    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList

    if self.chipsConfig == nil then
        self.chipsConfig = new(ChipsSpriteConfig, roomInfo.blind)
    end

    -- 奖池筹码堆
    local valformat = string.format("%013.0f", gameInfo.totalAnte)
    self.totalBoard_:setText((getFormatNumber(valformat, ", ")))

    -- 下注筹码堆
    for i = 0, SeatCount - 1 do
        if playerList[i] then
            local betTotalChips = playerList[i].nCurAnte
            local seatId        = playerList[i].seatId
            local positionId    = self.seatManager:getSeatPositionId(seatId)
            self.betChipViews_[seatId]:resetChipStack(betTotalChips)
        end
    end
end

-- 筹码下注动画
function ChipManager:betChip(player)
    local curAnte = player.curAnte
    local nCurAnte  = player.nCurAnte
    local seatId        = player.seatId
    local positionId    = self.seatManager:getSeatPositionId(seatId)
    -- 播放下注动画
    self.betChipViews_[seatId]:moveFromSeat(curAnte, nCurAnte)
end

function ChipManager:clearChip(seatId)    
    local positionId    = self.seatManager:getSeatPositionId(seatId)
    self.betChipViews_[seatId]:reset(0)
    self:modifyBetText(0, positionId)
end

-- 设置下注筹码数字
function ChipManager:modifyBetText(chips, positionId, position)
    if chips > 0 then
        local nstr = {"1st: ", "2nd: ", "3rd: ", "4th: ", "5th: ", "6th: ", "7th: "}
        local text = nstr[positionId] .. nk.updateFunctions.formatBigNumber(chips)
        self.betChipTextLabels_[positionId]:setText(text)
        self.betChipTextBgs_[positionId]:setPos(position.x - 30, position.y)
        self.betChipTextBgs_[positionId]:setVisible(true)
    else
        self.betChipTextBgs_[positionId]:setVisible(false)   
    end
end

-- 播放筹码变化动画
function ChipManager:playMoneyChangeAnimation(moneyChange, positionId , seatId)
    if moneyChange and moneyChange > 0 then
        local strMoney = nk.updateFunctions.formatBigNumber(moneyChange)
        local chipsAnim = new(ChipsAnimation)
        chipsAnim:play("+" .. strMoney, {x=SP[positionId].x + 94, y=SP[positionId].y + 90, root=self.scene.nodes.chipNode})
        local seatView = self.seatManager:getSeatView(seatId)
        if seatView then
            seatView:SetAniSeatChipTxt(moneyChange)
        end
    end    
end



function ChipManager:chipMoveToPlayer(positionArr)
    -- Log.dump(positionArr, ">>>>>>>>>>>>>>>>>>>>>>>>>> chipMoveToPlayer")
    local len = #positionArr
    if self.allChipsData_ then
        local n = #self.allChipsData_
        for i = n, 1, -1 do
            local sp = self.allChipsData_[i]:getSprite()
            if not tolua.isnull(sp) then
                sp:stopAllActions()
                sp:fadeOut({time = BetChipView.MOVE_TO_POT_DURATION, delay=(n - i) * BetChipView.MOVE_DELAY_DURATION})

                local toPlayer = i % len + 1   --平均分给每一个位置
                local position = self.seatManager:getSeatPositionId(positionArr[toPlayer])  
                local p = RoomViewPosition.GetSeatPostionNearBy(position)

                sp:moveTo({
                    time = BetChipView.MOVE_TO_POT_DURATION, 
                    x = p.x ,
                    y = p.y,
                    delay = (n - i) * BetChipView.MOVE_DELAY_DURATION
                })
            end
        end
    end
end
-- 直接结算，不用分池，筹码飞向某位玩家
function ChipManager:chipToPlayer(args)
    local positionId
    local seatId
    local seatWinner = {}
    local seatArg = 2   --第二位开始

    local lstChips = args["chips"]

    -- --- win动画
    for n = 1, #lstChips do
        seatId = args[n + 1]
        if seatId then
            local seatView = self.seatManager:getSeatView(seatId)
            seatView:playWinAnimation()
        end
    end

    nk.SoundManager:playSound(nk.SoundManager.MOVE_CHIP_NEW_LONG)
    --- 飞筹码
    for i = 0, SeatCount - 1 do
        self.betChipViews_[i]:moveToPot(false)   --allChipsData_会在这里收集betChipViews_所有筹码UI的引用
        self:modifyBetText(0, i + 1)    -- 重置筹码显示文本

        if args[seatArg] then
            seatId = args[seatArg]
            table.insert(seatWinner,seatId)
        end
        seatArg = seatArg + 1
    end    
    self:chipMoveToPlayer(seatWinner)

    nk.GCD.PostDelay(self, function()
        -- 飞筹码数字
        for n = 1, #lstChips do
            seatId = args[n + 1]
            if seatId then
                local positionId = self.seatManager:getSeatPositionId(seatId)
                if positionId then
                    self:playMoneyChangeAnimation(lstChips[n], positionId, seatId)
                end
            end
        end
    end, nil, 500, false)

    -- destroy
    nk.GCD.PostDelay(self, function()
        for _, v in pairs(self.betChipViews_) do
            v:reset()
        end
    end, nil,1500)   
end

-- 先分池,再结算
function ChipManager:chipSplitToPlayer(args)
    dump(args, "pot chips info >>>")
    -- 分池数据
    self.chipsArgs_ = args
    self.allChipsData_ = {}
    self.potChipsData_ = {}
    --合并筹码
    for i = 0, SeatCount - 1 do
        self.betChipViews_[i]:moveToPot(true)   --allChipsData_会在这里收集betChipViews_所有筹码UI的引用
        self:modifyBetText(0, i + 1)
    end

    -- 分奖池
    nk.GCD.PostDelay(self, function()
        self:splitChips_()
    end, nil, 500, false)

    -- win动画
    nk.GCD.PostDelay(self, function()
        local winSeatId = {}
        for i1,v1 in ipairs(self.chipsArgs_) do
            for i2,v2 in ipairs(v1) do
                if i2 > 1 and not table.indexof(winSeatId, v2) then
                    table.insert(winSeatId, v2)
                    local seatView = self.seatManager:getSeatView(v2)
                    seatView:playWinAnimation()
                end
            end
        end
    end, nil, 3000, false)

    local potIndex = 0
    -- 分给玩家
    nk.GCD.PostDelay(self, function()
        self:splitToPlayer_(potIndex)
       potIndex = potIndex + 1
       if potIndex <= #self.chipsArgs_ then
            return true
       else
            -- destroy
            nk.GCD.PostDelay(self, function()
                self:recyclePotChipsData_()
                nk.GCD.Cancel(self)
                end, nil, 2000, false)
            return false
       end
    end, nil, 1500, true)
end

-- 合并奖池后，开始分池
function ChipManager:splitChips_()
    if not self.chipsConfig then
        return
    end
    -- 奖池中的筹码
    local len = #self.chipsArgs_
    local pos
    for n,v in ipairs(self.chipsArgs_) do
        pos = GCP(len, n)

        -- local chipsData = self.chipsConfig:getChipDataFromArr(self.allChipsData_, v[1])
        local chipsData = self.chipsConfig:getChipDataFromArr(self.allChipsData_, v["chips"])
        local existRect = self.chipsConfig:existRectChipCount(chipsData)
        self:modifyBetText(v[1], n, pos)

        table.insert(self.potChipsData_, chipsData)     --每个池的数据存一下全局

        --圆形分柱,最多4柱
        local maxCount = 15         --一柱最多几个
        local cirCount = #chipsData - existRect     --圆形筹码多少个，
        if cirCount <= 15 then
            maxCount = 15
        elseif cirCount <= 30 then
            maxCount = math.ceil(cirCount / 2)
        elseif cirCount <= 45 then
            maxCount = math.ceil(cirCount / 3)
        elseif cirCount <= 60 then
            maxCount = math.ceil(cirCount / 4)
        else
            maxCount = math.ceil(cirCount / 4)
        end  

        local index, offsetX ,offsetY= 0, 0,0  -- 层级和偏移值
        local rankIndexCir,rankIndexRect = 0,0  --在筹码柱中的位置索引，圆形筹码才分柱，方形不分柱
        for i, chipData in ipairs(chipsData) do
            local position = BetChipView.getSplitPosition()
            local sp = chipData:getSprite()
            if not nk.updateFunctions.checkIsNull(sp) then
                sp:opacity(255)
                if not sp:getParent() then
                    sp:addTo(self.chipBatchNode_, i)
                    sp:setPos(position.x, position.y)
                end
                index = i
                offsetX = 0
                chipData:setRankIndex(0)    --重置在筹码柱中的位置索引

                --如果有方形筹码要调整位置
                if existRect > 0 and chipData:getType() then
                     --方形筹码
                    chipData:setRankIndex(rankIndexRect + 1)
                    offsetX = 25
                    offsetY = 0

                    rankIndexRect = rankIndexRect + 1

                    sp:setLevel(#chipsData + index)   --保证方形在前面
                else
                    local offxTemp = -10
                    --所在柱索引
                    local heapIndex = math.floor(rankIndexCir / maxCount)
                    if existRect > 0 then         --如果有方形筹码，圆形筹码包围方形,像个厂字
                        offxTemp = -25
                        
                        if heapIndex == 0 or heapIndex == 1 then
                            offsetX = offxTemp
                        else
                            offsetX = offxTemp + (heapIndex - 1)* 35
                        end
                        if heapIndex >= 1 then  --从第二堆开始要往上摆放
                            offsetY = -40
                        else
                            offsetY = 0
                        end
                        sp:setLevel(heapIndex >=1 and (index) or (#chipsData+index))  --保证第一柱圆形筹码在前面
                    else
                        offxTemp = -10            --没有方形筹码，圆形筹码靠一起，第四柱放在第三注下面

                        if heapIndex == 0 or heapIndex == 2 then
                            offsetX = offxTemp
                        else
                            offsetX = offxTemp + 35
                        end
                        if heapIndex >= 2 then  --从第三堆开始要往上摆放
                            offsetY = -40
                        else
                            offsetY = 0
                        end
                        sp:setLevel(heapIndex >=2 and (index) or (#chipsData+index))  --保证第一、二柱圆形筹码在前面

                    end

                    chipData:setRankIndex(rankIndexCir % maxCount + 1)
                    rankIndexCir = rankIndexCir + 1
                end

                sp:stopAllActions()
                sp:moveTo({time=BetChipView.MOVE_TO_POT_DURATION, x=pos.x + offsetX, y=pos.y - 35 + offsetY - chipData:getRankIndex() * BetChipView.GAP_WITH_CHIPS, delay=BetChipView.MOVE_DELAY_DURATION})
                sp:rotateTo({time=BetChipView.MOVE_FROM_SEAT_DURATION, rotate=math.random(-10, 10), delay=BetChipView.MOVE_DELAY_DURATION})
                if i == 1 then
                    self.chipBatchNode_:removeChild(sp, false)
                    self.chipBatchNode_:addChild(sp)                    
                end          
            end
        end
    end
end

-- 轮流分池,给玩家分筹码, potIndex-筹码池索引
function ChipManager:splitToPlayer_(n)
    if n <= 0 then
        return
    end

    local seatId
    local seatArg = 2
    local args = self.chipsArgs_[n]
    local chipsData = self.potChipsData_[n]
    
    --容错，友盟报错
    if not chipsData or not args then
        return
    end

    nk.SoundManager:playSound(nk.SoundManager.MOVE_CHIP_NEW_LONG)
    local chipsCount = #chipsData

    table.sort(chipsData, function(a, b)
        return a:getRankIndex() > b:getRankIndex()
    end)

    for i = 1, chipsCount do
        seatArg = args[seatArg] and seatArg or 2   --从索引2开始是座位id，遇到空的，又从2开始
        seatId = args[seatArg]
        local sp = chipsData[i]:getSprite()  
        if seatId and not nk.updateFunctions.checkIsNull(sp) then
            local positionId = self.seatManager:getSeatPositionId(seatId)
            sp:opacity(255)
            if not sp:getParent() then
                assert(not nk.updateFunctions.checkIsNull(self.chipBatchNode_), "error:self.chipBatchNode_ is null")
                sp.addTo(self.chipBatchNode_)
            end

            --根据索引决定运动时间和延迟时间
            local delayTime = chipsData[i]:getRankIndex() * BetChipView.MOVE_DELAY_DURATION * 2
            if delayTime > BetChipView.MOVE_TO_POT_DURATION then
                delayTime = BetChipView.MOVE_TO_POT_DURATION
            end

            sp:removeAllProp()
            local pos = RoomViewPosition.GetSeatPostionNearBy(positionId)
            
            sp:moveTo({time=BetChipView.MOVE_TO_POT_DURATION - delayTime, x=pos.x, y=pos.y, delay=delayTime})
            sp:fadeOut({time=0.25, delay=BetChipView.MOVE_TO_POT_DURATION - 0.13})
        end
        seatArg = seatArg + 1
    end
    self:modifyBetText(0, n)
    for i = 1, #args["chips"] do
        local pos_id = self.seatManager:getSeatPositionId(args[i + 1])                 
        local seat_id = args[i + 1]
        nk.GCD.PostDelay(self, function()
            self:playMoneyChangeAnimation(args["chips"][i], pos_id , seat_id)
        end, nil, 500, false)
    end
end

-- 回收奖池筹码
function ChipManager:recyclePotChipsData_()
    if self.potChipsData_ then
        for i,v in ipairs(self.potChipsData_) do
            self:recycleChipData(v)
        end
    end
    self.potChipsData_ = nil

    if self.allChipsData_ then
        if #self.allChipsData_ > 0 then
            self:recycleChipData(self.allChipsData_)
        end
    end
    self.allChipsData_ = nil
end

function ChipManager:addPotChipsData(chipData)
    self.allChipsData_ = self.allChipsData_ or {}
    table.insert(self.allChipsData_, chipData)
end

-- 从对象池获取筹码数据
function ChipManager:getChipData(chips, chipDataArr)
    if self.chipsConfig then
       return self.chipsConfig:getChipData(chips, chipDataArr)
    end
    return {}
end


-- 回收筹码数据
function ChipManager:recycleChipData(chipDataArr)
    if self.chipsConfig then
        self.chipsConfig:recycleChipData(chipDataArr)
    end
end

-- 重置筹码视图
function ChipManager:reset()
    -- 重置定时器
    nk.GCD.Cancel(self)
    -- 重置筹码堆
    for _, v in pairs(self.betChipViews_) do
        v:reset()
    end

    self:recyclePotChipsData_()
    -- 隐藏文字显示区
    for i = 1, SeatCount do
        self.betChipTextBgs_[i]:setVisible(false)
    end

    local valformat = string.format("%013.0f", 0)
    self.totalBoard_:setText((getFormatNumber(valformat, ", ")))
end

-- 清理
function ChipManager:dtor()
    -- 重置定时器
    nk.GCD.Cancel(self)
    -- 释放下注和奖池筹码视图
    if self.betChipViews_ then
        for _, v in pairs(self.betChipViews_) do
            delete(v)
            v = nil
        end
    end

    if self.chipsConfig then
        delete(self.chipsConfig)
        self.chipsConfig = nil
    end
end

return ChipManager