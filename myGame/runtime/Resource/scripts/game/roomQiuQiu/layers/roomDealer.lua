--
-- Author: johnny@boomegg.com
-- Date: 2014-08-20 13:32:49
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FrameAnim = require("game.anim.frameAnim")

local RoomDealer = class(Node)

local hddjList = {6, 9, 7, 4, 3}

function RoomDealer:ctor(nodes)
    self.nodes = nodes
    self.dealer_gift_table = {}
    if self.nodes.dealerTouchNode then
        self.nodes.dealerTouchNode:setEventTouch(self, self.onDealerTouchNodeTouch)
        self.nodes.dealerTouchNode:setVisible(false)

        self.dealer_circle = self.nodes.dealerTouchNode:getChildByName("dealer_circle")

        self.dealer_gift_1 = self.nodes.dealerTouchNode:getChildByName("dealer_gift_1")
        self.dealer_gift_1:setOnClick(self,self.onDealerGift1Click)
        self.dealer_gift_2 = self.nodes.dealerTouchNode:getChildByName("dealer_gift_2")
        self.dealer_gift_2:setOnClick(self,self.onDealerGift2Click)
        self.dealer_gift_3 = self.nodes.dealerTouchNode:getChildByName("dealer_gift_3")
        self.dealer_gift_3:setOnClick(self,self.onDealerGift3Click)
        self.dealer_gift_4 = self.nodes.dealerTouchNode:getChildByName("dealer_gift_4")
        self.dealer_gift_4:setOnClick(self,self.onDealerGift4Click)
        self.dealer_gift_5 = self.nodes.dealerTouchNode:getChildByName("dealer_gift_5")
        self.dealer_gift_5:setOnClick(self,self.onDealerGift5Click)

        self.dealer_gift_table = {
            [1] = self.dealer_gift_1,
            [2] = self.dealer_gift_2,
            [3] = self.dealer_gift_3,
            [4] = self.dealer_gift_4,
            [5] = self.dealer_gift_5,
        }

    end
end

function RoomDealer:createImages(imageType)
    local name = ""
    local frameNum = 0
    if imageType == "knock" then
        name = "res/room/qiuqiu/dealer/room_dealer_knock_%d.png"
        frameNum = 4
    elseif imageType == "kiss" then
        name = "res/room/qiuqiu/dealer/room_dealer_kiss_%d.png"
        frameNum = 5
    end
    local list = {}
    for i=1,frameNum do
        local imageName = string.format(name,i)
        table.insert(list,imageName)
    end
    return list
end

-- FrameAnim:ctor(images, parent, frameNum, time, callback, align, scale, scaleCenter, x, y, name)

 -- 敲桌子
function RoomDealer:tapTable(callback)
    local images = self:createImages("knock")
    if self.m_dealerAnim then
        self.m_dealerAnim:stopAnim()
    end
    self.m_dealerAnim = new(FrameAnim,images,self,4,800,callback)
end

-- -- 亲嘴玩家
 function RoomDealer:kissPlayer(callback)
    local images = self:createImages("kiss")
    if self.m_dealerAnim then
        self.m_dealerAnim:stopAnim()
    end
    self.m_dealerAnim = new(FrameAnim,images,self,5,500,callback)
    self:playKissHeart()
 end

--飘心
function RoomDealer:playKissHeart()
    local easing = require("libEffect.easing")
    if not self.heartNode then
        self.heartNode = new(Node)
        self.heartNode:setAlign(kAlignCenter)
        self.heartNode:setPos(-55,-20)
        self:addChild(self.heartNode)
    end
    -- if not self.m_kissHeart_table then
    --     self.m_kissHeart_table = {}
    -- end
    local  kissHeart = new(Image,"res/room/qiuqiu/dealer/room_dealer_heart.png")
    self.heartNode:addChild(kissHeart)
    -- table.insert(self.m_kissHeart_table,kissHeart)
    kissHeart:scaleTo({time = 2.5, srcX = 0, srcY = 0, scaleX = 1.4, scaleY = 1.4 })
    local pList  = {ccp(20, -8),ccp(-15, -16),ccp(15, -24),ccp(-10, -32),ccp(10, -40),ccp(-5, -48)}
    kissHeart:movesTo({time=3, pos_t= pList, onComplete=function() 
        -- local node = table.remove(self.m_kissHeart_table,1)            
        kissHeart:removeFromParent(true)
        if self.heartNode then
            local children = self.heartNode:getChildren()
            if children and #children == 0 then
                -- FwLog("delete self.heartNode.................................................")
                self.heartNode:removeFromParent(true)
                self.heartNode = nil
            end
        end
    end})

    -- local table_H = {}
    -- table_H.kissHeart = new(Image,"res/room/qiuqiu/dealer/room_dealer_heart.png")
    -- heartNode:addChild(table_H.kissHeart)

    -- local dataTime_H = easing.getEaseArray("easeInOutCirc", 800, 0, 20)
    -- table_H.resTime_H = new(ResDoubleArray, dataTime_H)

    -- local dataBend_H = easing.getEaseArray("easeInOutCirc", 2000, 0, -50)
    -- table_H.resBend_H = new(ResDoubleArray, dataBend_H)

    -- table_H.animTime_H = new(AnimIndex, kAnimRepeat, 0, #dataTime_H - 1, 800, table_H.resTime_H, 1)
    -- table_H.animBend_H = new(AnimIndex, kAnimNormal, 0, #dataBend_H - 1, 2000, table_H.resBend_H, 1)

    -- table_H.propTranslate = new(PropTranslate, table_H.animTime_H, table_H.animBend_H)
    -- table_H.kissHeart:doAddProp(table_H.propTranslate, 0)


    -- local dataScale_H = easing.getEaseArray("easeInOutCirc", 2000, 0.2, 1.4)
    -- table_H.resScale_H = new(ResDoubleArray, dataScale_H)

    -- table_H.animScale_H = new(AnimIndex, kAnimNormal, 0, #dataScale_H - 1, 2000, table_H.resScale_H, 1)

    -- table_H.propScale_H = new(PropScale, table_H.animScale_H, table_H.animScale_H, kCenterDrawing)
    -- table_H.kissHeart:doAddProp(table_H.propScale_H, 1)

    -- table.insert(self.m_kissHeart_table,table_H)


    -- table_H.animBend_H:setEvent(table_H,function ()
    --     if self.m_kissHeart_table[1] then
    --         self.m_kissHeart_table[1].kissHeart:removeProp(0)
    --         self.m_kissHeart_table[1].kissHeart:removeProp(1)

    --         delete(self.m_kissHeart_table[1].propTranslate) 
    --         delete(self.m_kissHeart_table[1].propScale_H) 

    --         delete(self.m_kissHeart_table[1].animBend_H) 
    --         delete(self.m_kissHeart_table[1].animTime_H) 
    --         delete(self.m_kissHeart_table[1].animScale_H) 

    --         delete(self.m_kissHeart_table[1].resBend_H) 
    --         delete(self.m_kissHeart_table[1].resTime_H)  
    --         delete(self.m_kissHeart_table[1].resScale_H)   

    --         self.m_kissHeart_table[1].kissHeart:removeFromParent(true)
    --         delete(self.m_kissHeart_table[1].kissHeart)
    --         self.m_kissHeart_table[1].kissHeart = nil

    --         delete(self.m_kissHeart_table[1])
    --         self.m_kissHeart_table[1] = nil
    --         table.remove(self.m_kissHeart_table,1)
    --     end
    -- end)
end

function RoomDealer:onDealerGift1Click()
    self.m_hddjList_index = 1
    self:onSendDealerGift()
end

function RoomDealer:onDealerGift2Click()
    self.m_hddjList_index = 2
    self:onSendDealerGift()
end

function RoomDealer:onDealerGift3Click()
    self.m_hddjList_index = 3
    self:onSendDealerGift()
end

function RoomDealer:onDealerGift4Click()
    self.m_hddjList_index = 4
    self:onSendDealerGift()
end

function RoomDealer:onDealerGift5Click()
    self.m_hddjList_index = 5
    self:onSendDealerGift()
end

function RoomDealer:onDealerTouchNodeTouch(finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        self:onHideAnim_()
    end
end

function RoomDealer:onSendDealerGift()
    local hddjId = hddjList[self.m_hddjList_index]
    if hddjId then
        EventDispatcher.getInstance():dispatch(EventConstants.ROOM_DEALE_RPROP, hddjId)
        self:onHideAnim_()
    end
end

function RoomDealer:onShowAnim_()
    self:stopAnim()

    self.nodes.dealerTouchNode:setVisible(true)

    for i,gift in ipairs(self.dealer_gift_table) do
        gift:setVisible(false)
    end

    self.dealer_circle:setPos(0,-100)
    self.dealer_circle:setVisible(true)
    self.dealer_circle:fadeIn({time=0.5})
    self.dealer_circle:moveTo({x=0, y=0, time=0.2, onComplete=function() 
        self.dealer_circle:stopAllActions()
        for i, gift in pairs(self.dealer_gift_table) do
            gift:stopAllActions()
            local animTime = 0.2
            transition.fadeIn(gift,  {time = animTime, delay = animTime*(i-1)*animTime, onComplete=function() 
                gift:setVisible(true)
            end})
        end
    end})
end

function RoomDealer:onHideAnim_()
    self:stopAnim()
    self.nodes.dealerTouchNode:setVisible(false)
end

function RoomDealer:stopAnim()
    self.dealer_circle:stopAllActions()
    for i, gift in pairs(self.dealer_gift_table) do
        gift:setVisible(false)
        gift:stopAllActions()
    end
end

function RoomDealer:dtor()
    if self.m_dealerAnim then
        self.m_dealerAnim:releaseAnim()
    end

    self:stopAnim()
end

return RoomDealer