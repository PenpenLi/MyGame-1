--
-- Author: johnny@boomegg.com
-- Date: 2014-07-18 16:25:22
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local BetChipView = class()
local RoomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")
local SP = RoomViewPosition.SeatPosition
local DP = RoomViewPosition.DealerPosition

local GRP = RoomViewPosition.GetRandomPosition

BetChipView.MOVE_FROM_SEAT_DURATION = 0.4
BetChipView.MOVE_TO_POT_DURATION = 0.6
BetChipView.MOVE_DELAY_DURATION = 0.015

BetChipView.GAP_WITH_CHIPS = 3

-- 筹码汇聚的随机坐标
BetChipView.getSplitPosition = function()
    return {x=DP[8].x - 20 + math.random(1, 20), y=DP[8].y + math.random(1, 20)}
end 

function BetChipView:ctor(parent, manager, seatId)
    self.parent_ = parent
    self.manager_ = manager
    self.seatId_ = seatId
    self.betTotalChips_ = 0
    self.lastBetChipIndex_ = 0
end

-- 重置筹码堆 , 刚登陆或者重连进来用来
function BetChipView:resetChipStack(betChips)
    if self.betTotalChips_ == betChips then
        return self
    else
        self.betTotalChips_ = betChips
    end
    if self.betTotalChips_ > 0 then
        self.manager_:recycleChipData(self.totalChipData_ and self.totalChipData_ or {})
        self.totalChipData_ = {}
        self.lastBetChipIndex_ = 0
        self:moveFromSeat(self.betTotalChips_, self.betTotalChips_)
    end

    return self
end
 
-- 获取下注总筹码
function BetChipView:getBetTotalChips()
    return self.betTotalChips_ or 0
end

-- 下注从座位飞出到下注位置
-- betChips当前下注筹码， betTotalChips下注总筹码
function BetChipView:moveFromSeat(betChips, betTotalChips)
    if checkint(betChips) > 0 then
        -- 初始化筹码数组
        if self.betTotalChips_ == 0 then
            self.totalChipData_ = {}        --筹码UI池
        end
        if betTotalChips then
            self.betTotalChips_ = betTotalChips
        else
            self.betTotalChips_ = self.betTotalChips_ + betChips
        end
        self.totalChipData_ = self.manager_:getChipData(betChips, self.totalChipData_)  --筹码UI池
        -- 动画
        local positionId = self.manager_.seatManager:getSeatPositionId(self.seatId_)
        local startIndex = self.lastBetChipIndex_ + 1
        local endIndex = #self.totalChipData_
        for i=startIndex, endIndex do
            self.lastBetChipIndex_ = i
            local sp = self.totalChipData_[i]:getSprite()
            if not nk.updateFunctions.checkIsNull(sp) then
                sp:setPos(SP[positionId].x + 70, SP[positionId].y+70)
                if not sp:getParent() then
                    sp:addTo(self.parent_)
                end
                local p = GRP()
                sp:removeAllProp()
                sp:moveTo({time = BetChipView.MOVE_FROM_SEAT_DURATION, x=p.x, y=p.y, delay = i * BetChipView.MOVE_DELAY_DURATION})
            end
        end
    end

    return self
end

-- toPot等于true所有筹码飞到一起,开始分奖池,否则是直接飞向玩家(在这里只是收集引用)
function BetChipView:moveToPot(toPot)
    if self.totalChipData_ then
        local n = #self.totalChipData_
        for i = n, 1, -1 do
            local sp = self.totalChipData_[i]:getSprite()
            if not nk.updateFunctions.checkIsNull(sp) then
                sp:removeAllProp()
                if toPot then
                    local position = BetChipView.getSplitPosition() 
                    self.manager_:addPotChipsData(self.totalChipData_[i])    --chipManager收集所有引用
		            sp:moveTo({time = BetChipView.MOVE_TO_POT_DURATION, x=position.x, y=position.y, delay = (n - i) * BetChipView.MOVE_DELAY_DURATION 
                    -- ,onComplete = handler(self, function()
	                   --  if not nk.updateFunctions.checkIsNull(sp) then
	                   --      sp:removeFromParent(true)
	                   --      delete(sp)
	                   --      sp = nil
	                   --  end
	                -- end)
                    })
                else
                    self.manager_:addPotChipsData(self.totalChipData_[i])    --chipManager收集所有引用
                end
                
            end
        end
    end
    return self
end

function BetChipView:reset()
    -- 回收筹码数据
    if self.totalChipData_ then
        self.manager_:recycleChipData(self.totalChipData_)
        delete(self.totalChipData_)
        self.totalChipData_ = nil
    end
    self.betTotalChips_ = 0
    self.lastBetChipIndex_ = 0
end

-- 清理
function BetChipView:dtor()
    self:reset()
end

return BetChipView