--
-- Author: tony
-- Date: 2014-07-10 13:47:18
--
local AnimManager = class()

-- local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local HddjController = require("game.roomGaple.hddjController")
local ChipFlayAnim = import("game.roomGaple.anim.chipFlayAnim")
local CardTypeAnim = import("game.roomGaple.anim.cardTypeAnim")
local RoomChatBubble = import("game.roomGaple.views.roomChatBubble")
local RoomSignalIndicator = import("game.roomQiuQiu.layers.roomSignalIndicator")
local expressionConfig = import("game.roomGaple.config.expressionConfig")
local ExpressionConfig = new(expressionConfig)
local LoadGiftControl = import("game.giftShop.loadGiftControl")

local DealerPosition = RoomViewPosition.DealerPosition
local SeatPosition = RoomViewPosition.SeatPosition

function AnimManager:ctor()
    
end

function AnimManager:createNodes()
    self.tableDealerPositionId_ = 5

    self.tableDealer_ = self.ctx.scene.nodes.dealerNode:getChildByName("dealerIcon")
    local dealer_x, dealer_y = self.tableDealer_:getUnalignPos() 
    -- self.tableDealer_:setPos()

    -- 信号
    self.signal_ = new(RoomSignalIndicator, self.ctx.scene.nodes.signalNode)

    self.clock_ = self.ctx.scene.nodes.dealerNode:getChildByName("clock")

    nk.GCD.PostDelay(self,function()
        if self.disposed_ then
            return false
        end
        local timeString = os.date("%H:%M", os.time())
        if not nk.updateFunctions.checkIsNull(self.clock_) then
            self.clock_:setText(timeString)
        end
        return true
    end, nil, 1000, true)

    -- 互动道具控制器
    self.hddjController = new(HddjController,self.ctx.scene.nodes.animNode)

    self:bindDataObservers_()
end

function AnimManager:onSignalStrengthChanged_(strength)
    if not nk.updateFunctions.checkIsNull(self.signal_) then
        self.signal_:setSignalStrength(strength or 0)
    end
end

-- positionId = 8 移动到荷官位置
function AnimManager:moveDealerTo(positionId, animation, isSelfDealer)   
    if positionId == nil then
        positionId = 8
    end

    local p = DealerPosition[positionId]
    --positionId为-1的时候
    if not p then
        p = DealerPosition[5]
        positionId = 5
    end
    if not nk.updateFunctions.checkIsNull(self.tableDealer_) then
        if isSelfDealer then
            -- 自己当庄家时位置
            p = DealerPosition[6]
        end    
        self.tableDealer_:stopAllActions()
        if animation then
            self.tableDealer_:moveTo({time = 0.5, x=p.x, y=p.y})
        else
            self.tableDealer_:setPos(p.x, p.y)
        end
        Log.printInfo("moveDealerToerToerTo p.x, p.y = ", p.x, p.y)
    end
    self.tableDealerPositionId_ = positionId
end

function AnimManager:rotateDealer(step)
    if self.tableDealerPositionId_ == 5 then
        return
    end
    local newPositionId = self.tableDealerPositionId_ - step
    if newPositionId > 4 then
        newPositionId = newPositionId - 4
    elseif newPositionId < 1 then
        newPositionId = newPositionId + 4
    end
    self:moveDealerTo(newPositionId, true, self.model:isSelfDealer())
end

function AnimManager:playCardTypeAnim(cardType)
    if self.cardTypeAnim_ then
        self.cardTypeAnim_:release()
        self.cardTypeAnim_:removeFromParent(true)
        delete(self.cardTypeAnim_)
        self.cardTypeAnim_ = nil
    end

    self.cardTypeAnim_ = new(CardTypeAnim,cardType)
    self.cardTypeAnim_:setLevel(2)
    self.cardTypeAnim_:setAlign(kAlignCenter)
    self.scene.nodes.animNode:addChild(self.cardTypeAnim_)
end

function AnimManager:playChipFlayAnim(direction, fromCtr, endCtr)
    if not self.chipFlayAnim_table then
        self.chipFlayAnim_table = {}
    end

    local chipFlayAnim = new(ChipFlayAnim, direction, fromCtr, endCtr)
    self.scene.nodes.animNode:addChild(chipFlayAnim)
    table.insert(self.chipFlayAnim_table,chipFlayAnim)

    self.m_chipFlayAnim_table_id = nk.GCD.PostDelay(self,function()
        table.removebyvalue(self.chipFlayAnim_table or {}, chipFlayAnim, true)
        chipFlayAnim:removeFromParent(true)
    end, nil, 3*1000) 
end

function AnimManager:playAddFriendAnimation(fromSeatId, toSeatId)
    local fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    local toPositionId = self.seatManager:getSeatPositionId(toSeatId)
    if not self.addFriendSprites_ then
        self.addFriendSprites_ = {}
    end

    if fromPositionId and toPositionId then
        local sp = new(Node)
        
        local addIcon = new(Image,"res/room/gaple/roomG_add_friend.png")
        addIcon:setAlign(kAlignCenter)

        table.insert(self.addFriendSprites_, sp)

        local fromNode = self.seatManager:getSeatCenterNode(fromSeatId)
        local toNode = self.seatManager:getSeatCenterNode(toSeatId)

        local fromNode_x, fromNode_y, toNode_x, toNode_y

        if fromNode and toNode then
            fromNode_x, fromNode_y = fromNode:getAbsolutePos()
            toNode_x, toNode_y = toNode:getAbsolutePos()

            self.scene.nodes.animNode:addChild(sp)
            sp:addChild(addIcon)
            sp:setPos(fromNode_x, fromNode_y)

            sp:moveTo({x = toNode_x, y = toNode_y, time = 1, onComplete = handler(self, function()
                sp:removeFromParent()
                table.removebyvalue(self.addFriendSprites_, sp, true)
            end)})
        end
    end

end

function AnimManager:playSendGiftAnimation(giftId, fromUid, toUidArr,callback)
    if self.giftUrlReqId_ then
        LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
    end

    self.giftUrlReqId_ = LoadGiftControl.getInstance():getGiftUrlById(giftId, handler(self, function(obj,url)
        self.giftUrlReqId_ = nil
        if nk.updateFunctions.checkIsNull(obj) then return end
        if url and string.len(url) > 5 and self:checkUidInSeat(toUidArr) then
            local fromSeatId = self.model:getSeatIdByUid(fromUid)
            local fromX, fromY = -50,-50
            if fromSeatId~=-1 then
                local seatCenterNode = self.seatManager:getSeatCenterNode(fromSeatId)
                if seatCenterNode then
                    fromX, fromY = seatCenterNode:getAbsolutePos()
                end
            end
            for _, toUid in ipairs(toUidArr) do
                local toSeatId = self.model:getSeatIdByUid(toUid)
                if toSeatId ~= -1 then
                    if not self.sendGiftViews_ then
                        self.sendGiftViews_ = {}
                    end
                    local giftCenterNode = self.seatManager:getSeatCenterNode(toSeatId)
                    local toX, toY = 0, 0
                    if giftCenterNode then
                        toX, toY = giftCenterNode:getAbsolutePos()
                    end

                    local giftNode = new(Node)
                    self.scene.nodes.animNode:addChild(giftNode)

                    local giftName = UrlImage.s_cacheFiles:get(url)
                    local giftImage 
                    if giftName then
                        giftImage = new(Image,giftName)
                        giftImage:setAlign(kAlignCenter)
                        giftNode:addChild(giftImage)
                        giftImage:addPropScaleSolid(0, 1, 1, kCenterDrawing);
                    end

                    giftNode:setPos(fromX, fromY)
                    table.insert(self.sendGiftViews_, giftNode)
                    if giftImage then
                        giftImage:scaleTo({time = 0.8, srcX = 0.5, srcY = 0.5, scaleX = 1, scaleY =1 })
                    end
                    giftNode:moveTo({x = toX, y = toY, time = 0.8 ,onComplete = handler(self, function()
                        local giftCenterNode = self.seatManager:getGiftCenterNode(toSeatId)
                        local toX, toY = 0, 0
                        if giftCenterNode then
                            toX, toY = giftCenterNode:getAbsolutePos()
                        end
                        if giftImage then
                            giftImage:scaleTo({time = 0.3, srcX = 1, srcY =1 ,scaleX =0.7, scaleY =0.7})
                        end
                        giftNode:moveTo({x = toX, y = toY, time = 0.3 ,onComplete = handler(self, function()
                            if callback then
                                callback()
                            end
                            giftNode:removeFromParent(true)
                            table.removebyvalue(self.sendGiftViews_, giftNode, true)
                            toSeatId = self.model:getSeatIdByUid(toUid)
                            if toSeatId ~= -1 then
                                self.seatManager:updateGiftUrl(toSeatId, giftId)
                            end
                        end)})
                        -- thank you 
                        if fromUid == nk.userData.uid and toUid ~= fromUid then 
                            local positionId = tonumber(self.seatManager:getSeatPositionId(toSeatId))
                            local isSelfView = (positionId == 3 or positionId == 5) 
                            self:showChatMsg(toSeatId,"Terima kasih!", isSelfView)
                        end  
                    end)})
                end
            end
        end
    end))    
end

function AnimManager:checkUidInSeat(uidArr)
    for _, uid in ipairs(uidArr) do
        if self.model:getSeatIdByUid(uid) ~= -1 then
            return true
        end
    end
    return false
end

--8号荷官位置
function AnimManager:playHddjAnimation(fromSeatId, toSeatId, hddjId, isSelf, num)
    local fromPositionId
    local toPositionId
    local fromNode
    local toNode
    if fromSeatId ~= 8 then
        fromPositionId = self.seatManager:getSeatPositionId(fromSeatId, isSelf)
        fromNode = self.seatManager:getSeatCenterNode(fromSeatId)
    else
        -- fromPositionId = 8
        -- fromNode = self.scene.nodes.dealerCenterNode
    end
    if toSeatId ~= 8  then
        toPositionId = self.seatManager:getSeatPositionId(toSeatId, isSelf)
        toNode = self.seatManager:getSeatCenterNode(toSeatId)
    else
        -- toPositionId = 8
        -- toNode = self.scene.nodes.dealerCenterNode
    end
    if not self.sendHddjs_ then
        self.sendHddjs_ = {}
    end
    
    num = num or 1
    for i=1, num do
        nk.GCD.PostDelay(self,function()
            local sp
            sp = self.hddjController:playHddj(fromPositionId, toPositionId, fromNode, toNode, hddjId, function()
                sp:removeFromParent(true)
                table.removebyvalue(self.sendHddjs_, sp, true)
            end)
            if sp then
                table.insert(self.sendHddjs_, sp)
            end
        end, nil, 0.2*i*1000)  
    end
end

function AnimManager:playExpression(seatId, expressionId, isSelf)
    local isNewExp = math.floor(expressionId / 100 )

    if not self.sendExpressions_ then
        self.sendExpressions_ = {}
        self.loadingExpressions_ = {}
        self.waitPlay_ = {}
    end
    if self.model.playerList[seatId] then
        local animName = "expression-" .. expressionId
        if not self.waitPlay_[animName] then
            self.waitPlay_[animName] = {}
        end
        table.insert(self.waitPlay_[animName], seatId)
        if self.disposed_ then
            self.loadingExpressions_[animName] = nil
            return
        end
        print("loaded ", expressionId)
        local toPlay = self.waitPlay_[animName]
        while #toPlay > 0 do
            local seatId = table.remove(toPlay, 1)
            print("play ..", expressionId, seatId)
            local scale = 1
            if isNewExp == 1 then
                scale = 1.2
            elseif isNewExp == 2 then
                scale = 1.5
            end
            self:playExpressionAnim_(isSelf, seatId, expressionId,scale,isNewExp)
        end

        self.waitPlay_[animName] = nil
        self.loadingExpressions_[animName] = nil
    end
end


function AnimManager:playExpressionAnim_(isSelf, seatId, expressionId, scale, isNewExp)
    if self.model.playerList[seatId] then
        local config = ExpressionConfig:getConfig(expressionId)
        if config then
            local seatCenterNode = self.seatManager:getSeatCenterNode(seatId)
            local imagesList = nk.functions.getExpImagesList(expressionId,config.frameNum,isNewExp);
            local drawing = new(Images,imagesList);
            drawing:addPropScaleSolid(0, scale, scale, kCenterDrawing);
            drawing:setAlign(kAlignCenter)
            if seatCenterNode then
                seatCenterNode:addChild(drawing)
            end

            local eachImageTime = 300
            if isNewExp == 1 then
                eachImageTime = 100
            elseif isNewExp == 2 then
                eachImageTime = 100
            end
            
            local animIndex = new(AnimInt,kAnimRepeat ,0,config.frameNum -1,config.frameNum*eachImageTime,-1)
            animIndex:setDebugName("playExpressionAnim_.animIndex");

            local propIndex = new(PropImageIndex,animIndex);
            propIndex:setDebugName("playExpressionAnim_.propIndex");
            drawing:doAddProp(propIndex,1);

            nk.GCD.PostDelay(self,function()
                drawing:removeAllProp()
                nk.functions.removeFromParent(drawing,true)
            end, nil, 3000)   
        end     
    end
end

--座位扣钱动画
function AnimManager:playChipsChangeAnimation(seatId, chipsChange, isSelf)
    if not self.chipsChange_ then
        self.chipsChange_ = {}
    end
    local positionId = self.seatManager:getSeatPositionId(seatId)
    local p = SeatPosition[positionId]
    if isSelf then
        p = SeatPosition[#SeatPosition]
    end
    local lb = nil
    if chipsChange > 0 then
        lb = new(Text,string.format("+$%s", math.abs(chipsChange)),0,0,kAlignCenter,nil,24,236,206,11)
    elseif chipsChange < 0 then
        lb = new(Text,string.format("-$%s", math.abs(chipsChange)),0,0,kAlignCenter,nil,24,236,206,11)
    end
    if lb then
        local lb_w,_ = lb:getSize()
        self.scene.nodes.animNode:addChild(lb)
        lb:setPos(p.x + math.abs(lb_w/2 - 80), p.y + 80)
        table.insert(self.chipsChange_, lb)
        lb:moveTo({x = p.x + math.abs(lb_w/2 - 80), y = p.y - 20, time = 2 ,onComplete = handler(self, function()
            lb:removeFromParent()
            table.removebyvalue(self.chipsChange_, lb, true)
        end)})
    end

end

--显示聊天消息
function AnimManager:showChatMsg(seatId, message, isSelf)
    if not self.chatBubbles_ then
        self.chatBubbles_ = {}
    end
    local bubble
    if seatId ~= -1 then
        local positionId = self.seatManager:getSeatPositionId(seatId)
        local chatNode = nil
        local chatNode_left, chatNode_right = self.seatManager:getSeatChatNode(seatId)
        if isSelf then
            positionId = #SeatPosition
        end
        local p = SeatPosition[positionId]
        if p then
            if positionId >= 1 and positionId <=3 then
                bubble = new(RoomChatBubble,message, RoomChatBubble.DIRECTION_RIGHT)
                chatNode = chatNode_right
            else
                bubble = new(RoomChatBubble,message, RoomChatBubble.DIRECTION_LEFT)
                chatNode = chatNode_left
            end
        end
        if chatNode then
            bubble:show(self.scene.nodes.animNode, p.x, p.y, chatNode)
        end
    end
    if bubble then
        table.insert(self.chatBubbles_, bubble)
        nk.GCD.PostDelay(self,function()
            nk.functions.removeFromParent(bubble,true)
            table.removebyvalue(self.chatBubbles_, bubble, true)
        end, nil, 5000)   
    end
end

function AnimManager:dtor()
    nk.GCD.Cancel(self)

    self:unbindDataObservers_()
    delete(self.hddjController)
    self.hddjController = nil

    self.disposed_ = true

    self:releaseChipFlayAnim()

    if self.cardTypeAnim_ then
        self.cardTypeAnim_:release()
        self.cardTypeAnim_:removeFromParent(true)
        delete(self.cardTypeAnim_)
        self.cardTypeAnim_ = nil
    end

    if self.addFriendSprites_ then
        for i,v in ipairs(self.addFriendSprites_) do
            v:removeAllProp()
            v:removeFromParent(true)
        end
        delete(self.addFriendSprites_)
        self.addFriendSprites_ = nil
    end

    if self.sendGiftViews_ then
        for i,v in ipairs(self.sendGiftViews_) do
            v:removeAllProp()
            v:removeFromParent(true)
        end
        delete(self.sendGiftViews_)
        self.sendGiftViews_ = nil
    end

    if self.chipsChange_ then
        for i,v in ipairs(self.chipsChange_) do
            v:removeAllProp()
            v:removeFromParent(true)
        end
        delete(self.chipsChange_)
        self.chipsChange_ = nil
    end 
    
    if self.signal_ then
        delete(self.signal_)
    end

    if self.sendHddjs_ then
        for i,v in ipairs(self.sendHddjs_) do
            v:removeAllProp()
            v:removeFromParent(true)
        end
        delete(self.sendHddjs_)
        self.sendHddjs_ = nil
    end 

    if self.chatBubbles_ then
        for i,chatBubble in ipairs(self.chatBubbles_) do
            delete(chatBubble)
            chatBubble = nil
        end
    end
end

function AnimManager:releaseChipFlayAnim()
    nk.GCD.CancelById(self,self.m_chipFlayAnim_table_id)
    if self.chipFlayAnim_table then
        for i,anim in ipairs(self.chipFlayAnim_table) do
            anim:removeFromParent(true)
        end
        self.chipFlayAnim_table = nil
        -- delete(self.chipFlayAnim_table)
    end
end

function AnimManager:bindDataObservers_()
    self.onSignalStengthHandlerId_ = nk.DataProxy:addDataObserver(nk.dataKeys.SIGNAL_STRENGTH, handler(self, self.onSignalStrengthChanged_))
end

function AnimManager:unbindDataObservers_()
    nk.DataProxy:removeDataObserver(nk.dataKeys.SIGNAL_STRENGTH, self.onSignalStengthHandlerId_)
end

return AnimManager