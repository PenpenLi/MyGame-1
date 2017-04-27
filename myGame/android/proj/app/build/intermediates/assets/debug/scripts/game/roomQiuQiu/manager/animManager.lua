--
-- Author: tony
-- Date: 2014-07-10 13:47:18
--
local AnimManager = class()
local HddjController = require("game.roomGaple.hddjController")
local RoomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")
local SendChipView = import("game.roomQiuQiu.layers.sendChipView")
local RoomChatBubble = import("game.roomGaple.views.roomChatBubble")
local RoomSignalIndicator = import("game.roomQiuQiu.layers.roomSignalIndicator")

local expressionConfig = import("game.roomGaple.config.expressionConfig")
local ExpressionConfig = new(expressionConfig)
local LoadGiftControl = import("game.giftShop.loadGiftControl")

local DealerPosition = RoomViewPosition.DealerPosition
local SeatPosition = RoomViewPosition.SeatPosition
local DealCardStartPosition = RoomViewPosition.DealCardStartPosition

function AnimManager:ctor()
    
end

function AnimManager:createNodes()
    self.tableDealerPositionId_ = 8
    self.tableDealer_ = self.ctx.scene.nodes.dealerNode:getChildByName("dealerSignImage")

    self.signal_ = new(RoomSignalIndicator, self.ctx.scene.nodes.signalNode)

    self.clock_ = self.ctx.scene.nodes.topNode:getChildByName("clockLabel")

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
    self.hddjController = new(HddjController, self.ctx.scene.nodes.animNode)

    self:bindDataObservers_()
end

function AnimManager:onSignalStrengthChanged_(strength)
    Log.printInfo("AnimManager","onSignalStrengthChanged_ strength:" .. (strength or 0))
    if self.signal_ then
        self.signal_:setSignalStrength(strength or 0)
    end
end

-- positionId = 8 移动到荷官位置
function AnimManager:moveDealerTo(positionId, animation)   
    if positionId == nil then
        positionId = 8
    end
    local p = DealerPosition[positionId]
    local p2 = DealCardStartPosition[positionId]
    --positionId为-1的时候
    if not p then
        p = DealerPosition[8]
        p2 = DealCardStartPosition[8]
        positionId = 8
    end
    self.tableDealer_:stopAllActions()

    --说明
    --庄家标志原来是放在dealcard层的，现放在dealer层，坐标乱了，做个坐标转换 --by ziway
    local x,y = p.x,p.y
    local gx,gy = self.ctx.scene.nodes.dealCardNode:convertPointToSurface(x,y)
    local lx,ly = self.ctx.scene.nodes.dealerNode:convertSurfacePointToView(gx,gy)
    if animation then
        self.tableDealer_:moveTo({time = 0.5, x=lx, y=ly})
    else
        self.tableDealer_:setPos(lx,ly)
    end    
    self.tableDealerPositionId_ = positionId
end

function AnimManager:rotateDealer(step)
    if self.tableDealerPositionId_ == 8 then
        return
    end
    local newPositionId = self.tableDealerPositionId_ - step
    if newPositionId > 7 then
        newPositionId = newPositionId - 7
    elseif newPositionId < 1 then
        newPositionId = newPositionId + 7
    end
    self:moveDealerTo(newPositionId, true)
end

function AnimManager:playAddFriendAnimation(fromSeatId, toSeatId)
    local fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    local toPositionId = self.seatManager:getSeatPositionId(toSeatId)
    if not self.addFriendSprites_ then
        self.addFriendSprites_ = {}
    end

    if fromPositionId and toPositionId then
        local sp = new(Node)
        self.scene.nodes.animNode:addChild(sp)
        local addIcon = new(Image,"res/room/gaple/roomG_add_friend.png")
        addIcon:setAlign(kAlignCenter)
        sp:addChild(addIcon)

        table.insert(self.addFriendSprites_, sp)

        local fromNode = self.seatManager:getSeatCenterNode(fromSeatId)
        local fromNode_x, fromNode_y = fromNode:getAbsolutePos()

        local toNode = self.seatManager:getSeatCenterNode(toSeatId)
        local toNode_x, toNode_y = toNode:getAbsolutePos()

        sp:setPos(fromNode_x, fromNode_y)

        sp:moveTo({x = toNode_x, y = toNode_y, time = 1, onComplete = handler(self, function()
          sp:removeFromParent()
          table.removebyvalue(self.addFriendSprites_, sp, true)
        end)})
    end
end

--打赏筹码给荷官
function AnimManager:playSendChipAnimation(fromSeatId, toSeatId, chips)
    self.seatManager:updateSeatState(fromSeatId)

    local fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    local toPositionId = self.seatManager:getSeatPositionId(toSeatId)

    local toNode = self.scene.nodes.dealerCenterNode
    local toX, toY = toNode:getAbsolutePos()

    local seatCenterNode = self.seatManager:getSeatCenterNode(fromSeatId)
    
    local fromX,fromY
    if fromPositionId ~= -1 then
        fromX, fromY = seatCenterNode:getAbsolutePos()
    else
        fromX, fromY = 0, 0
    end
    
    local totalChipData_ = self.chipManager:getChipData(chips, {})

    -- 动画
    local startIndex = self.lastBetChipIndex_ and self.lastBetChipIndex_ or 0 + 1
    local endIndex = #totalChipData_

    for i=startIndex, endIndex do
        self.lastBetChipIndex_ = i
        local sp = totalChipData_[i]:getSprite()
        if not nk.updateFunctions.checkIsNull(sp) then
            sp:setPos(fromX - 17 , fromY - 17)
            if not sp:getParent() then
                self.scene.nodes.animNode:addChild(sp)
            end

            sp:moveTo({x = toX - 17 , y = toY - 17 , time = 1, delay = 0.075, onComplete = handler(self, function()
                sp:removeFromParent(true)
                self.chipManager:recycleChipData({totalChipData_[i]})
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
                fromX, fromY = seatCenterNode:getAbsolutePos()
            end
            for _, toUid in ipairs(toUidArr) do
                local toSeatId = self.model:getSeatIdByUid(toUid)
                if toSeatId ~= -1 then
                    if not self.sendGiftViews_ then
                        self.sendGiftViews_ = {}
                    end

                    local giftCenterNode = self.seatManager:getSeatCenterNode(toSeatId)
                    local toX, toY = giftCenterNode:getAbsolutePos()

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
                        giftImage:scaleTo({time = 0.8, srcX = 0.5, srcY = 0.5, scaleX = 1, scaleY = 1})
                    end
                    giftNode:moveTo({x = toX, y = toY, time = 0.8 ,onComplete = handler(self, function()
                        local giftCenterNode = self.seatManager:getGiftCenterNode(toSeatId)
                        local toX, toY = giftCenterNode:getAbsolutePos()
                        if giftImage then
                            giftImage:scaleTo({time = 0.3, srcX = 1, srcY =1 ,scaleX =0.5, scaleY = 0.5})
                        end
                        giftNode:moveTo({x = toX, y = toY, time = 0.3 ,onComplete = handler(self, function()
                            if callback then
                                callback()
                            end
                            giftNode:removeFromParent()
                            table.removebyvalue(self.sendGiftViews_, giftNode, true)
                            toSeatId = self.model:getSeatIdByUid(toUid)
                            if toSeatId ~= -1 then
                                self.seatManager:updateGiftUrl(toSeatId, giftId)
                            end
                              
                        end)})
                        -- thank you 
                        if fromUid == nk.userData.uid and toUid ~= fromUid then 
                            self:showChatMsg(toSeatId,"Terima kasih!")
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
function AnimManager:playHddjAnimation(fromSeatId, toSeatId, hddjId, num)
    local fromPositionId
    local toPositionId
    local fromNode
    local toNode
    if fromSeatId ~= 8 then
        fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
        fromNode = self.seatManager:getSeatCenterNode(fromSeatId)
    end
    fromPositionId = fromPositionId or  8
    fromNode = fromNode or self.scene.nodes.dealerCenterNode
    if toSeatId ~= 8  then
        toPositionId = self.seatManager:getSeatPositionId(toSeatId)
        toNode = self.seatManager:getSeatCenterNode(toSeatId)
    end
    toPositionId = toPositionId or 8
    toNode = toNode or self.scene.nodes.dealerCenterNode

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

function AnimManager:playExpression(seatId, expressionId)
    local isNewExp = math.floor(expressionId / 100 )

    if not self.sendExpressions_ then
        self.sendExpressions_ = {}
        self.loadingExpressions_ = {}
        self.waitPlay_ = {}
        self.loadedExpressions_ = {}
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
            self:playExpressionAnim_(seatId, expressionId, scale, isNewExp)
        end

        self.waitPlay_[animName] = nil
        self.loadingExpressions_[animName] = nil
    end
end


function AnimManager:playExpressionAnim_(seatId, expressionId, scale, isNewExp)
    if self.model.playerList[seatId] then
        local config = ExpressionConfig:getConfig(expressionId)
        if config then
            local seatCenterNode = self.seatManager:getSeatCenterNode(seatId)
            local x, y = seatCenterNode:getAbsolutePos()
            local imagesList = nk.functions.getExpImagesList(expressionId,config.frameNum,isNewExp);
            local drawing = new(Images,imagesList);
            drawing:setAlign(kAlignCenter)
            drawing:addPropScaleSolid(0, scale, scale, kCenterDrawing);
            seatCenterNode:addChild(drawing);

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
function AnimManager:playChipsChangeAnimation(seatId, chipsChange)
    if not self.chipsChange_ then
        self.chipsChange_ = {}
    end
    local positionId = self.seatManager:getSeatPositionId(seatId)
    local p = SeatPosition[positionId]
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
function AnimManager:showChatMsg(seatId, message)
    if not self.chatBubbles_ then
        self.chatBubbles_ = {}
    end
    local bubble
    if seatId ~= -1 then
        local positionId = self.seatManager:getSeatPositionId(seatId)
        local chatNode = nil
        local chatNode_left, chatNode_right = self.seatManager:getSeatChatNode(seatId)
        local p = SeatPosition[positionId]
        if p then
            if positionId >= 1 and positionId <=3 then
                bubble = new(RoomChatBubble, message, RoomChatBubble.DIRECTION_RIGHT)
                chatNode = chatNode_right
            else
                bubble = new(RoomChatBubble, message, RoomChatBubble.DIRECTION_LEFT)
                chatNode = chatNode_left
            end
            if chatNode then
                bubble:show(self.scene.nodes.animNode, p.x, p.y, chatNode)
            end
        end
    end
    if bubble then
        table.insert(self.chatBubbles_, bubble)
        nk.GCD.PostDelay(self,function()
            bubble:removeFromParent(true)
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

    if self.signal_  then
        delete(self.signal_)
        self.signal_ = nil
    end
end



function AnimManager:bindDataObservers_()
    self.onSignalStengthHandlerId_ = nk.DataProxy:addDataObserver(nk.dataKeys.SIGNAL_STRENGTH, handler(self, self.onSignalStrengthChanged_))
end

function AnimManager:unbindDataObservers_()
    nk.DataProxy:removeDataObserver(nk.dataKeys.SIGNAL_STRENGTH, self.onSignalStengthHandlerId_)
end

return AnimManager