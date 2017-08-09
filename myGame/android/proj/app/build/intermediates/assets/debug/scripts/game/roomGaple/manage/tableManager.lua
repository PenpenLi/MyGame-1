--
-- Author: tony
-- Date: 2014-07-08 15:00:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local TableManager = class()

local TotalChipsBoard = import("game.roomGaple.views.totalChipsBoard")
-- local RoomViewPosition = import(".RoomViewPosition")
local TouchLayer = import("game.roomGaple.views.touchLayer")
local SP = RoomViewPosition.SeatPosition
local Rangle = RoomViewPosition.TableRangle
local PokerCard = nk.pokerUI.PokerCard

local WCell, HCell = 34, 68
local CARD_WIDTH      = 62
local CARD_HEIGHT     = 120
local TableCenter_v = {}
local TableCenter_h = {}

local H_L = "horizontal_left"   --水平向左
local H_R = "horizontal_right"  --水平向右
local V_U = "vertical_up"       --垂直向上
local V_D = "vertical_down"     --垂直向下

local function getJoinValue(value, arg1, arg2)
    if value == arg1 then return {value, arg2} end
    if value == arg2 then return {value, arg1} end
    return nil
end


function TableManager:ctor()
    self.listCards_ = {}
    -- 头部对接点数
    self.point1_ = nil
    -- 尾部对接点数
    self.point2_ = nil
end

-- 返回牌在X轴所占大小
function TableManager:getSpaceX(card)
    return self:getRotation(card) % 180 == 0 and WCell or HCell
end

-- 返回牌在Y轴所占大小
function TableManager:getSpaceY(card)
    return self:getRotation(card) % 180 == 0 and HCell or WCell
end


function TableManager:createNodes()

    self.touchlayer_= new(TouchLayer,self.scene.nodes.chipNode)

    self.spriteBatchNode_ = new(Node)
    self.scene.nodes.chipNode:addChild(self.spriteBatchNode_)

    self.tableNode_ = new(Node)
    self.spriteBatchNode_:addChild(self.tableNode_)

    Clock.instance():schedule_once(function ( ... )

    end)

    local center_x, center_y = self.scene.nodes.centerNode:getUnalignPos()
    TableCenter_v = {x = center_x, y = center_y}

    -- 可出牌区域 
    self.cardSpace1_v = self:createSpace("v")
    self.cardSpace1_v:setEventTouch(self,self.onTouchSpace1_)
    local cardSpace1Touch = new(Image,kImageMap.common_transparent)
    local space1_w, space1_h = self.cardSpace1_v:getSize()
    cardSpace1Touch:setSize(space1_w*2, space1_h*2)
    cardSpace1Touch:setEventTouch(self,self.onTouchSpace1_)
    cardSpace1Touch:setAlign(kAlignCenter)
    self.cardSpace1_v:addChild(cardSpace1Touch)
    

    self.cardSpace2_v = self:createSpace("v")
    self.cardSpace2_v:setEventTouch(self,self.onTouchSpace2_)
    local cardSpace2Touch = new(Image,kImageMap.common_transparent)
    local space2_w, space2_h = self.cardSpace2_v:getSize()
    cardSpace2Touch:setSize(space2_w*2, space2_h*2)
    cardSpace2Touch:setEventTouch(self,self.onTouchSpace2_)
    cardSpace2Touch:setAlign(kAlignCenter)
    self.cardSpace2_v:addChild(cardSpace2Touch)

    -- dir:记录当前摆牌方向
    -- -- 第一张牌方向 H_L
    -- self.firstCard = {}
    -- self.firstCard.dir = H_L
    -- -- self.firstCard.nextDir = H_L
    -- -- 最后一张牌方向 H_R
    -- self.lastCard = {}
    -- self.lastCard.dir = H_R
    -- -- self.lastCard.nextDir = H_R

    self.cardSpace1_v.dir = H_L
    self.cardSpace2_v.dir = H_R

    --桌面显示总筹码数
    self.totalBoard_ = new(TotalChipsBoard,self.scene.m_prizePool)

    self:addRuleTips()
    self:addGameCountDownTips()

    EventDispatcher.getInstance():register(EventConstants.checkCardShow, self, self.checkCardEvent_)
    EventDispatcher.getInstance():register(EventConstants.handCardSelected, self, self.cardSelected)
    EventDispatcher.getInstance():register(EventConstants.tipsCardSelected, self, self.tipsCardEvent_)
end

function TableManager:createSpace(dir)
    local space = nil
    if dir == "v" then
        space = new(Image, "res/common/common_poker_space_v.png")
        space:setPos(TableCenter_v.x, TableCenter_v.y)
    end
    space:setAlign(kAlignCenter)
    self.spriteBatchNode_:addChild(space)
    space:setVisible(false)
    return space
end

function TableManager:addRuleTips()
    -- 旁观提示信息
    self.ruleTipsBg_ = self.scene.nodes.backgroundNode:getChildByName("ruleTipsBg")
    self.ruleTipsBg_:setVisible(false)
    self.clip_ = self.ruleTipsBg_:getChildByName("ruleTipsClip")
    self.ruleTipsText_ = self.clip_:getChildByName("ruleTipsText")
    local clip_w, clip_h = self.clip_:getSize()
    self.clip_:setClip2(true, 0, 0, clip_w, clip_h)

    self:initRuleTips()
end

function TableManager:initRuleTips()
    local tips = "Tips:"
    self.ruleTipsTab = {
        [1] = tips .. bm.LangUtil.getText("ROOM", "CARD_TIPS1"),
        [2] = tips .. bm.LangUtil.getText("ROOM", "CARD_TIPS2"),
        [3] = tips .. bm.LangUtil.getText("ROOM", "CARD_TIPS3"),
        [4] = tips .. bm.LangUtil.getText("ROOM", "CARD_TIPS4"),
        [5] = tips .. bm.LangUtil.getText("ROOM", "CARD_TIPS5"),
    }
end

function TableManager:runRuleTips()
    self.ruleTipsBg_:setVisible(true)
    local clip_w, clip_h = self.clip_:getSize()
    self.ruleTipsText_:setPos(clip_w, 0)
    self.ruleTipsText_:setText(self.ruleTipsTab[1])

    local count = 1
    self.runRule_id = nk.GCD.PostDelay(self, function()
        local text_w, text_h = self.ruleTipsText_:getSize()
        local text_x, _ = self.ruleTipsText_:getPos()
        if text_x < -text_w  then
            self.ruleTipsText_:setSize(0,text_h)
            self.ruleTipsText_:setText(self.ruleTipsTab[count%5 + 1])
            count = count + 1
            self.ruleTipsText_:setPos(clip_w, 0)
        else
            self.ruleTipsText_:setPos(text_x - 2, 0)
        end
    end, nil, 10, true)
end

function TableManager:stopRuleTips()
    self.ruleTipsBg_:setVisible(false)
    if self.runRule_id then
        nk.GCD.CancelById(self,self.runRule_id)
        self.runRule_id = nil
    end
end

function TableManager:addGameCountDownTips()
    -- 下一局游戏开始倒计时
    self.countDownTipsBg_ = self.scene.nodes.backgroundNode:getChildByName("countDownTipsBg")
    self.countDownTipsBg_:setVisible(false)
    self.countDownTipsText_ = self.countDownTipsBg_:getChildByName("countDownTipsText")
end

function TableManager:runCountDownTips(time)
    self:stopCountDownTips()
    self.countDownHandle = nk.GCD.PostDelay(self, function()
        if time <= 0 then
            self:stopCountDownTips()
        else
            local timeStr = bm.LangUtil.getText("ROOM", "COUNTDOWN",time)
            self.countDownTipsText_:setText(timeStr)
            time = time -1
        end
    end, nil, 1000, true)    
end

function TableManager:showCountDownTips()
    if not nk.updateFunctions.checkIsNull(self.countDownTipsBg_) then
        self.countDownTipsBg_:setVisible(true)
    end
end

function TableManager:stopCountDownTips()
    if not nk.updateFunctions.checkIsNull(self.countDownTipsBg_) then
        self.countDownTipsBg_:setVisible(false)
    end
    if self.countDownHandle then
        nk.GCD.CancelById(self,self.countDownHandle)
        Log.printInfo("stopCountDownTips stopCountDownTips stopCountDownTips")
        self.countDownHandle = nil
    end
end

-- 选中牌，显示/隐藏可出牌位置
function TableManager:cardSelected(card)
    -- Log.dump(card, "cardSelectedcardSelectedcardSelectedcardSelectedcardSelectedcardSelected")

    self.currentCard_ = card
    local temp = self.currentCard_
    if temp then
        if #self.listCards_ <= 0 or getJoinValue(self.point1_, temp:getUpPoint(), temp:getDownPoint()) then
            local dir = self:updateSpace1_(temp)
            if dir == "v" then
                self.cardSpace1_v:setVisible(true)
                Log.printInfo("cardSelected self.cardSpace1_v = ", self.cardSpace1_v:getPos())
            end
        else
            self.cardSpace1_v:setVisible(false)
        end

        if getJoinValue(self.point2_, temp:getUpPoint(), temp:getDownPoint()) then
            local dir = self:updateSpace2_(temp)
            if dir == "v" then
                self.cardSpace2_v:setVisible(true)
            end
        else
            self.cardSpace2_v:setVisible(false)
        end
    else
        self.cardSpace1_v:setVisible(false)
        self.cardSpace2_v:setVisible(false)
    end

    if temp and self.touchlayer_ then
        self.touchlayer_:playerMove(temp,self.tableNode_)
    elseif self.touchlayer_ then
        self.touchlayer_:playerMove(nil,self.tableNode_)
    end
end

function TableManager:hideCradSpaceTips()
    if self.cardSpace1_v then
        self.cardSpace1_v:setVisible(false)
    end
    if self.cardSpace2_v then
        self.cardSpace2_v:setVisible(false)
    end
end

-- 出牌，并计算下一个出牌位置,出牌动画放在服务器广播玩家出牌后播放
function TableManager:onTouchSpace1_(evt)
    self:sendCard(1)
end

-- 出牌，并计算下一个出牌位置,出牌动画放在服务器广播玩家出牌后播放
function TableManager:onTouchSpace2_(evt)
    self:sendCard(2)
end

function TableManager:sendCard(pos)
    if self.currentCard_ and self.currentCard_.getPointValue  then
        nk.SocketController:sendCard(nk.userData.uid, 1, self.currentCard_:getPointValue(), pos)
        self.currentCard_ = nil
    end
    self:removeCardTips()
end

-- 出牌
-- pointValue:牌值 
-- x,y:牌的初始位置
-- where:1-接龙在头部，2-接龙在尾部
function TableManager:doPlayCard_(pointValue, x, y, where, needAnim)
    -- 复制一张手牌
    self.m_needAnim = needAnim
    local tempCard = new(PokerCard):setCard(pointValue)

    local card = nil
    local dir, spacePos_x, spacePos_y = nil, nil, nil

    -- 出牌动画
    local space, joinValue

    local sequence = transition.getSequence()

    local listCard, listCardValue, listCard_dir, listCard_pos = nil, pointValue, nil, 0

    if #self.listCards_ <= 0 or where == 1 then
        dir, spacePos_x, spacePos_y = self:updateSpace1_(tempCard)
        listCard_dir = dir
        card = new(PokerCard,dir):setCard(pointValue)
        space = self.cardSpace1_v
        --计算下一个接入点
        if #self.listCards_ > 0 then
            joinValue = self.point1_
            local point = getJoinValue(joinValue, card:getUpPoint(), card:getDownPoint())
            if not point then
                -- --数据错误后，同步一次桌子信息
                nk.SocketController:tableSYNC()
                return
            end
            self.point1_ = point[2]
        else
            self.point1_ = card:getDownPoint()
            self.point2_ = card:getUpPoint()
        end
        listCard_pos = 1
    else
        dir, spacePos_x, spacePos_y = self:updateSpace2_(tempCard)
        listCard_dir = dir
        card = new(PokerCard,dir):setCard(pointValue)
        space = self.cardSpace2_v
        joinValue = self.point2_
        local point = getJoinValue(joinValue, card:getUpPoint(), card:getDownPoint())
        if not point then
            --数据错误后，同步一次桌子信息
            nk.SocketController:tableSYNC()
            return
        end
        self.point2_ = point[2]
        listCard_pos = 0
    end

    Log.printInfo("doPlayCard_",x, y)
    Log.printInfo("doPlayCard_",spacePos_x, spacePos_y)

    self.tableNode_:addChild(card)

    -- 计算牌所需要旋转的角度
    local targetRot = self:getRotation(space)
    if joinValue == card:getUpPoint() then
        targetRot = targetRot - 180
    end

    -- listCard, listCardValue, listCard_dir, listCard_pos
    spacePos_x, spacePos_y = space:getPos()
    listCard = new(PokerCard,listCard_dir):setCard(listCardValue)
    self.tableNode_:addChild(listCard)
    listCard:setPos(spacePos_x, spacePos_y)

    Log.printInfo("doPlayCard_pos",spacePos_x, spacePos_y)
    Log.printInfo("doPlayCard_pos",self.cardSpace1_v:getPos())
    Log.printInfo("doPlayCard_pos",self.cardSpace2_v:getPos())




    listCard:addPropScaleSolid(0, 0.58, 0.58, kCenterDrawing,0,0)
    listCard:addPropRotateSolid(1, targetRot, kCenterDrawing)
    listCard.rotate = targetRot
    listCard:setVisible(false)
    if listCard_pos == 1 then
        table.insert(self.listCards_, 1, listCard)
    else
        table.insert(self.listCards_, listCard)
    end


    if not nk.reLoginRoom and not nk.reLoginRoom_ and self.m_needAnim and not self.m_isCardMoving  then
    -- if not nk.reLoginRoom and not nk.reLoginRoom_ and self.m_needAnim  then
        self.m_isCardMoving = true
        card:setPos(x, y)
        card:moveTo({x = spacePos_x, y = spacePos_y, time = 0.3 ,onComplete = handler(self, function()
            card:setPos(spacePos_x,spacePos_y)
            self.m_isCardMoving = false

            card:removeFromParent(true)
            delete(card)
            card = nil

            listCard:setVisible(true)

        end)})
        card:scaleTo({time = 0.3, srcX = 1, srcY = 1, scaleX = 0.58, scaleY = 0.58})
        card:rotateTo({time=0.3, rotate=targetRot, delay=-1})
    else
        card:setPos(spacePos_x, spacePos_y)
        sequence = transition.getSequence()
        card:addPropScaleSolid(sequence, 0.58, 0.58, kCenterDrawing,0,0)
        sequence = transition.getSequence()
        card:addPropRotateSolid(sequence, targetRot, kCenterDrawing)
        self.m_isCardMoving = false

        card:removeFromParent(true)
        delete(card)
        card = nil
        
        listCard:setVisible(true)
    end
    Log.printInfo("nk.reLoginRoom nk.reLoginRoom = ", nk.reLoginRoom)
    Log.printInfo("nk.reLoginRoom nk.reLoginRoom_ = ", nk.reLoginRoom_)

    Log.printInfo("doPlayCard_ space = ", space.pos)


    

    space.dir = space.nextDir or space.dir
    space.nextDir = space.dir

    self.cardSpace1_v:setVisible(false)
    self.cardSpace2_v:setVisible(false)

    -- Log.printInfo("TableManager:doPlayCard_ asd",pointValue, where, listCard:getUpPoint(), listCard:getDownPoint(), self.point1_, self.point2_)
    self:updateTablePosition()   
    delete(tempCard)
end

function TableManager:setRotation(target, rotate)
    return transition.getSequence()
end

function TableManager:setRotation(target, rotate)
    target:removeAllProp()
    sequence = transition.getSequence()
    target:addPropRotateSolid(sequence, rotate, kCenterDrawing)
    target.rotate = rotate
end

function TableManager:getRotation(target)
    return target.rotate or 0
end

-- 计算target在头部出牌的位置
-- 以对接点数为大点数来设置cardSpace1_的角度
function TableManager:updateSpace1_(target)
    local pos_x, pos_y = 0, 0
    local space1_ = "h"
    if #self.listCards_ > 0 then
        print(">>>>>>>> space1", self.cardSpace1_v.dir, self.cardSpace1_v.nextDir)
        local startCard = self.listCards_[1]
        local startCard_x, startCard_y = startCard:getPos()
        if self.cardSpace1_v.dir == H_L then   
            self:setRotation(self.cardSpace1_v, target:isDouble() and 0 or -90)
            if startCard_x <= Rangle.x1 and not startCard:isDouble() then 
                self:setRotation(self.cardSpace1_v, 0)
                if not target:isDouble() then
                    pos_y = startCard_y - self:getSpaceY(startCard) * 0.5
                else
                    pos_y = startCard_y
                end
                self.cardSpace1_v.nextDir = V_U
            else
                pos_y = startCard_y
            end
            self.cardSpace1_v:setPos(startCard_x - self:getSpaceX(startCard) * 0.5 - self:getSpaceX(self.cardSpace1_v) * 0.5, pos_y)
        elseif self.cardSpace1_v.dir == H_R then 
            self:setRotation(self.cardSpace1_v, target:isDouble() and 0 or 90)
            if startCard_x >= Rangle.x2 and not startCard:isDouble() then 
                self:setRotation(self.cardSpace1_v, 0)
                if not target:isDouble() then
                    pos_y = startCard_y - self:getSpaceY(startCard) * 0.5
                else
                    pos_y = startCard_y
                end
                self.cardSpace1_v.nextDir = V_U
            else
                pos_y = startCard_y
            end
            self.cardSpace1_v:setPos(startCard_x + self:getSpaceX(startCard) * 0.5 + self:getSpaceX(self.cardSpace1_v) * 0.5, startCard_y)
        elseif self.cardSpace1_v.dir == V_U then 
            self:setRotation(self.cardSpace1_v, 0)
            if startCard_y <= Rangle.y1 then 
                if self.cardSpace1_v:getPos() < TableCenter_v.x then 
                    self:setRotation(self.cardSpace1_v, 90)
                    if not target:isDouble() then
                        pos_x = startCard_x + self:getSpaceX(startCard) * 0.5
                    else
                        pos_x = startCard_x
                    end
                    self.cardSpace1_v.nextDir = H_R
                else                 
                    self:setRotation(self.cardSpace1_v, -90)
                    if not target:isDouble() then
                        pos_x = startCard_x - self:getSpaceX(startCard) * 0.5
                    else
                        pos_x = startCard_x
                    end
                    self.cardSpace1_v.nextDir = H_L
                end
            else
                pos_x = startCard_x
            end
            self.cardSpace1_v:setPos(pos_x, startCard_y - self:getSpaceY(startCard) * 0.5 - self:getSpaceY(self.cardSpace1_v) * 0.5)              
        end
    else
        self.cardSpace1_v:setPos(TableCenter_v.x, TableCenter_v.y)
        self:setRotation(self.cardSpace1_v, target:isDouble() and 0 or 90)
    end
    return "v", pos_x, pos_y
end



-- 计算target在尾部出牌的位置
-- 以对接点数为大点数来设置cardSpace2_的角度
function TableManager:updateSpace2_(target)
    local pos_x, pos_y = 0, 0
    local space2_ = "h"
    if #self.listCards_ > 0 then 
        print(">>>>>>>> space2", self.cardSpace2_v.dir,self.cardSpace2_v.nextDir)
        local endCard = self.listCards_[#self.listCards_]
        local endCard_x, endCard_y = endCard:getPos()
        if self.cardSpace2_v.dir == H_L then
            self:setRotation(self.cardSpace2_v, target:isDouble() and 0 or -90)
            if endCard_x <= Rangle.x1 and not endCard:isDouble() then
                self:setRotation(self.cardSpace2_v, 180)
                if not target:isDouble() then
                    pos_y = endCard_y + self:getSpaceY(endCard) * 0.5
                else
                    pos_y = endCard_y
                end              
                self.cardSpace2_v.nextDir = V_D
            else
                pos_y = endCard_y
            end
            self.cardSpace2_v:setPos(endCard_x - self:getSpaceX(endCard) * 0.5 - self:getSpaceX(self.cardSpace2_v) * 0.5, pos_y)
        elseif self.cardSpace2_v.dir == H_R then
            self:setRotation(self.cardSpace2_v, target:isDouble() and 0 or 90)
            if endCard_x >= Rangle.x2 and not endCard:isDouble() then
                self:setRotation(self.cardSpace2_v, 180)
                if not target:isDouble() then
                    pos_y = endCard_y + self:getSpaceY(endCard) * 0.5
                else
                    pos_y = endCard_y
                end
                self.cardSpace2_v.nextDir = V_D
            else
                pos_y = endCard_y
            end
            self.cardSpace2_v:setPos(endCard_x + self:getSpaceX(endCard) * 0.5 + self:getSpaceX(self.cardSpace2_v) * 0.5, pos_y)
        elseif self.cardSpace2_v.dir == V_D then
            self:setRotation(self.cardSpace2_v, 180)
            if endCard_y >= Rangle.y2 then
                if self.cardSpace2_v:getPos() < TableCenter_v.x then
                    self:setRotation(self.cardSpace2_v, 90)
                    if not target:isDouble() then
                        pos_x = endCard_x + self:getSpaceX(endCard) * 0.5
                    else
                        pos_x = endCard_x
                    end
                    self.cardSpace2_v.nextDir = H_R
                else
                    self:setRotation(self.cardSpace2_v, -90)
                    if not target:isDouble() then
                        pos_x = endCard_x - self:getSpaceX(endCard) * 0.5
                    else
                        pos_x = endCard_x
                    end
                    self.cardSpace2_v.nextDir = H_L
                end
            else
                pos_x = endCard_x
            end
            self.cardSpace2_v:setPos(pos_x, endCard_y + self:getSpaceY(endCard) * 0.5 + self:getSpaceY(self.cardSpace2_v) * 0.5)           
        end
    else
        self.cardSpace2_v:setPos(TableCenter_v.x, TableCenter_v.y)
        self:setRotation(self.cardSpace2_v, target:isDouble() and 0 or 90)
    end
    return "v", pos_x, pos_y
end

-- 更新桌面的牌
-- list:例如{0x12,0x23,0x34}
function TableManager:updateTable(list,firstOutCardValue)
    dump(list, "list >>>>>>>>>>list list list")
    local cIndex = math.floor(#list / 2) 
    local dir, spacePos_x, spacePos_y = nil, nil, nil

    -- 查找第一张出的牌在列表中的位置
    for index,value in ipairs(list) do
        if value == firstOutCardValue then
            cIndex = index
            break
        end
    end

    local card, space, joinValue, targetRot
    --更新上半部分的牌
    for i = cIndex, 1, -1 do
        space = self.cardSpace1_v
        -- 创建牌
        local tempCard  = new(PokerCard):setCard(list[i])
        dir, spacePos_x, spacePos_y = self:updateSpace1_(tempCard)
        delete(tempCard)
        card = new(PokerCard,dir)
        card:setCard(list[i])
        self.tableNode_:addChild(card)

        -- 计算牌所需要旋转的角度
        targetRot = self:getRotation(space)
        if joinValue == card:getUpPoint() then
            targetRot = targetRot - 180
        end
        self:setRotation(card, targetRot)

        local sequence = transition.getSequence()
        card:addPropScaleSolid(0, 0.58, 0.58, kCenterDrawing)
        card:setPos(space:getPos())

        --计算下一个接入点
        if #self.listCards_ > 0 then
            print("TableManager:updateTable asd 1 ", cIndex, #self.listCards_, card:getPointValue(), card:getUpPoint(), card:getDownPoint(), self.point1_, self.point2_)
            joinValue = self.point1_
            local point = getJoinValue(joinValue, card:getUpPoint(), card:getDownPoint())
            if not point then
                --数据错误后，同步一次桌子信息
                nk.SocketController:tableSYNC()
                return
            end
            self.point1_ = point[2]
        else
            print("TableManager:updateTable asd 2 ", cIndex, #self.listCards_, card:getPointValue(), card:getUpPoint(), card:getDownPoint(), self.point1_, self.point2_)
            self.point1_ = card:getDownPoint()
            self.point2_ = card:getUpPoint()
        end

        table.insert(self.listCards_, 1, card)
        space.dir = space.nextDir or space.dir
        space.nextDir = space.dir
    end
    --更新下半部分的牌
    for i = cIndex + 1, #list do
        space = self.cardSpace2_v
        -- 创建牌
        local tempCard = new(PokerCard):setCard(list[i])
        dir, spacePos_x, spacePos_y = self:updateSpace2_(tempCard)
        delete(tempCard)
        card = new(PokerCard,dir)
        card:setCard(list[i])
        self.tableNode_:addChild(card)

        -- 计算牌所需要旋转的角度
        targetRot = self:getRotation(space)
        if joinValue == card:getUpPoint() then
            targetRot = targetRot - 180
        end
        self:setRotation(card, targetRot)

        local sequence = transition.getSequence()
        card:addPropScaleSolid(0, 0.58, 0.58, kCenterDrawing)
        card:setPos(space:getPos())

        --计算下一个接入点
        joinValue = self.point2_
        print("TableManager:updateTable asd 3 ", cIndex, #self.listCards_, card:getPointValue(), card:getUpPoint(), card:getDownPoint(), self.point1_, self.point2_)
        local point = getJoinValue(joinValue, card:getUpPoint(), card:getDownPoint())
        if not point then
            --数据错误后，同步一次桌子信息
            nk.SocketController:tableSYNC()
            return
        end
        self.point2_ = point[2]

        table.insert(self.listCards_, card)      
        space.dir = space.nextDir or space.dir
        space.nextDir = space.dir
    end  
    self:updateTablePosition()
end

--更新桌子上牌的容器，使其居中
function TableManager:updateTablePosition()
    if self.m_tablePosition_id then
        nk.GCD.CancelById(self,self.m_tablePosition_id)
        self.m_tablePosition_id = nil
    end

    if #self.listCards_ <= 2 then return end
    
    if not nk.reLoginRoom and not nk.reLoginRoom_ and self.m_needAnim then
        self.m_tablePosition_id = nk.GCD.PostDelay(self, function()
            -- 停止-- 0.3秒的动画
            self.spriteBatchNode_:stopAllActions()
            if self.listCards_ and #self.listCards_ <= 2 then return end
            local startCard = self.listCards_[1]
            local endCard = self.listCards_[#self.listCards_]
            local _, startCard_y = startCard:getPos()
            local _, endCard_y = endCard:getPos()
            local offset = (startCard_y + endCard_y) * 0.5 - TableCenter_v.y

            if math.abs(offset) > 30 then
                -- 0.3秒的动画
                self.spriteBatchNode_:moveTo({x=0,y=-offset,time=0.3 })
            end
        end, nil, 200)
    else

    end
end

-- 登录成功，设置登录筹码堆
function TableManager:setLoginChipStacks()
    local roomInfo = self.model.roomInfo
    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList

    -- 奖池筹码堆
    self.totalBoard_:playAddAnim(gameInfo.totalAnte)
    -- self.totalBoard_:setValue(gameInfo.totalAnte)
end

-- 玩家出牌动画
function TableManager:showCard(pack,needAnim)
    -- 播放出牌动画
    if 1 == pack.opType then
        -- 玩家自己出牌
        if pack.uid == nk.userData.uid then 
            local seatId = self.model:getSeatIdByUid(pack.uid)
            local seatView = self.seatManager:getSeatView(seatId)
            if seatView then
                self.currentCard_ = seatView:findHandCardByValue(pack.card)
            end
            if self.currentCard_ then
                local localPos = {}
                localPos.x, localPos.y = self.currentCard_:getAbsolutePos()

                self:doPlayCard_(self.currentCard_:getPointValue(), localPos.x, localPos.y, pack.cardPos, needAnim) 
                local data = {card = self.currentCard_, uid = pack.uid}
                EventDispatcher.getInstance():dispatch(EventConstants.handCardUsed, data)
                self.currentCard_ = nil
            end
            self:removeCardTips()
            self.touchlayer_:setLayerTouchEnabled(false)
            self.touchlayer_:playerMove(nil,self.tableNode_)
        else
            local seatId = self.model:getSeatIdByUid(pack.uid)
            local seatView = self.seatManager:getSeatView(seatId)
            if seatView then
                self.currentCard_ = seatView:findHandCardByValue(pack.card)
            end
            if self.currentCard_ then
                local data = {card = self.currentCard_, uid = pack.uid}
                EventDispatcher.getInstance():dispatch(EventConstants.handCardUsed, data)
                self.currentCard_ = nil
            end
            local positionId  = self.seatManager:getSeatPositionId(seatId)
            local x = SP[positionId] and SP[positionId].x or 0
            local y = SP[positionId] and SP[positionId].y or 0
            self:doPlayCard_(pack.card, x, y, pack.cardPos, needAnim)
        end
    elseif 0 == pack.opType then
        -- 过费动画
        print("uid pass pack.uid ", pack.uid)
    end
    self.touchlayer_:setLayerTouchEnabled(false)
    if pack.nextUid and pack.nextUid == nk.userData.uid then
        self.touchlayer_:setLayerTouchEnabled(true)
    end
end

function TableManager:checkCardEvent_(moveEnd)
    if self.cardMove_gcd then
        nk.GCD.CancelById(self,self.cardMove_gcd)
        self.cardMove_gcd = nil
    end

    if self.currentCard_ then
        if #self.listCards_ > 0 then
            local show, pos = self:checkShow()
            if moveEnd and show and pos>0 then
                self:sendCard(pos)
                self.cardMove_gcd = nk.GCD.PostDelay(self, function()
                    EventDispatcher.getInstance():dispatch(EventConstants.cardMoveBack)
                end, nil, 1000)    
            elseif moveEnd then
                self.touchlayer_:playerMove(nil,self.tableNode_)
                EventDispatcher.getInstance():dispatch(EventConstants.cardMoveBack)
            end
        elseif moveEnd then
            self:sendCard(pos)
            self.cardMove_gcd = nk.GCD.PostDelay(self, function()
                EventDispatcher.getInstance():dispatch(EventConstants.cardMoveBack)
            end, nil, 1000)  
        end
    end
end

-- 出牌提示
function TableManager:tipsCardEvent_()
    print("tipsCardEvent_ tipsCardEvent_ tipsCardEvent_ tipsCardEvent_ tipsCardEvent_ ")
    if nk.functions.getSpaceShouldTips() then
        nk.functions.setSpaceShouldTips(false)
        flag = true
        if not self.tipsNode1_ then
            self.tipsNode1_ = new(Node)
            self.tipsNode1_:setAlign(kAlignTop)

            local tips_bg1 = new(Image,"res/room/gaple/roomG_hand_tips_bg.png", nil, nil, 15, 15, 15, 15)
            tips_bg1:setSize(320,60)
            tips_bg1:setAlign(kAlignTop)
            self.tipsNode1_:addChild(tips_bg1)

            local tips_node = new(Image,"res/room/gaple/roomG_hand_tips_node.png")
            tips_node:setAlign(kAlignBottom)
            tips_node:setPos(0, -16)
            tips_bg1:addChild(tips_node)

            local text = bm.LangUtil.getText("ROOM", "CARD_TIPS2")
            local tipsText1_ = new(TextView, text, 300, 50, kAlignCenter, nil, 16, 255, 255, 255)
            tipsText1_:setPos(0,-5)
            tipsText1_:setAlign(kAlignCenter)
            tips_bg1:addChild(tipsText1_)
        end

        local space1_v_visible = self.cardSpace1_v:getVisible() 
        local space2_v_visible = self.cardSpace2_v:getVisible()
        local position = 0

        nk.functions.removeFromParent(self.tipsNode1_ , false)

        local tips_x, tip_y = TableCenter_v.x, TableCenter_v.y
        if space1_v_visible then
            position = 1
            if space1_v_visible then
                -- self.cardSpace1_v:addChild(self.tipsNode1_)
                tips_x, tip_y = self.cardSpace1_v:getUnalignPos()
            end
        elseif space2_v_visible then
            position = 2
            if space2_v_visible then
                -- self.cardSpace2_v:addChild(self.tipsNode1_)
                tips_x, tip_y = self.cardSpace2_v:getUnalignPos()
            end
        end
        self.spriteBatchNode_:addChild(self.tipsNode1_)
        self.tipsNode1_:setPos(tips_x, tip_y - 70)
        self.tipsNode1_:setVisible(false)
        if position ~= 0 then
            self.tipsNode1_:setVisible(true)
        end
    end
end

function TableManager:removeCardTips()
    if self.tipsNode1_ then
        nk.functions.removeFromParent(self.tipsNode1_, true)
    end
end

function TableManager:checkShow()
    local pos = 0
    local show = false

    local space1_v_visible = self.cardSpace1_v:getVisible()
    local space2_v_visible = self.cardSpace2_v:getVisible()

    local space1_result, space2_result = false, false
    local offset1, offset2 = 0, 0
    if space1_v_visible then
        local cardSpace = nil
        local dir
        if space1_v_visible then
            cardSpace = self.cardSpace1_v
            dir = "v"
        end
        space1_result, offset1 = self:checkPos(cardSpace,dir)
    end
    if space2_v_visible then
        local cardSpace = nil
        if space2_v_visible then
            cardSpace = self.cardSpace2_v
            dir = "v"
        end
        space2_result, offset2 = self:checkPos(cardSpace,dir)
    end

    if space1_result and not space2_result then
        show = true
        pos = 1
    elseif space2_result and not space1_result then
        show = true
        pos = 2
    elseif space2_result and space1_result then
        show = true
        pos = offset1 <= offset2 and 1 or 2
    end

    return show, pos
end

function TableManager:checkPos(cardSpace,dir)
    local currentCard_x, currentCard_y = self.currentCard_:getAbsolutePos()
    currentCard_x = currentCard_x/System.getLayoutScale()
    currentCard_y = currentCard_y/System.getLayoutScale()

    local cardSpace_x, cardSpace_y = cardSpace:getAbsolutePos()
    cardSpace_x = cardSpace_x/System.getLayoutScale()
    cardSpace_y = cardSpace_y/System.getLayoutScale()

    local offset_x = currentCard_x - cardSpace_x
    local offset_y = currentCard_y - cardSpace_y

    local show = false
    local offset = offset_x^2 + offset_y^2

    if offset_x <= 60 and offset_y <= 60 then
        show = true
        Log.printInfo("checkPos true true true true true true true true true ")
    end


    return show, offset
end

-- 重置筹码视图
function TableManager:reset()
    self.totalBoard_:playAddAnim(0)
    for i,v in ipairs(self.listCards_) do
        v:removeFromParent(true)
        delete(v)
        v = nil
    end

    self.tableNode_:removeAllChildren(true)

    self.listCards_ = {}
    self.point1_ = nil
    self.point2_ = nil
    self.tableNode_:setPos(0, 0)  
    self.spriteBatchNode_:setPos(0, 0)  
    self.cardSpace1_v:setPos(TableCenter_v.x, TableCenter_v.y)
    self.cardSpace2_v:setPos(TableCenter_v.x, TableCenter_v.y)
    self.cardSpace1_v.dir = H_L
    self.cardSpace2_v.dir = H_R  
    self.cardSpace1_v.nextDir = nil
    self.cardSpace2_v.nextDir = nil

    if self.scene and self.scene.start_pos then
        self.scene.start_pos:setString("start_pos:")
    end 
    if self.scene and self.scene.start_space_pos then
        self.scene.start_space_pos:setString("start_space_pos:")
    end
    if self.scene and self.scene.end_pos then
        self.scene.end_pos:setString("end_pos:")
    end
    if self.scene and self.scene.end_space_pos then
        self.scene.end_space_pos:setString("end_space_pos:")
    end
    self:stopRuleTips()
    self.totalBoard_:stopAddAnim()
end

-- 清理
function TableManager:dtor()
    self.listCards_ = {}
    nk.GCD.Cancel(self)

    EventDispatcher.getInstance():unregister(EventConstants.checkCardShow, self, self.checkCardEvent_)
    EventDispatcher.getInstance():unregister(EventConstants.handCardSelected, self, self.cardSelected)
    EventDispatcher.getInstance():unregister(EventConstants.tipsCardSelected, self, self.tipsCardEvent_)

    self:stopRuleTips()
    self.totalBoard_:stopAddAnim()
    self:stopCountDownTips()
end

return TableManager
--]]

