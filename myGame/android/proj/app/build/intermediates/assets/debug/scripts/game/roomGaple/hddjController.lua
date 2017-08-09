--
-- Author: johnny@boomegg.com
-- Date: 2014-08-14 22:11:43
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local HddjController = class()

HddjController.hddjConfig = {
    [1] = {frameNum=13, iconScale = 1.3, x=-30, y=0, iconX=47, iconY=30, rotation=2},
    [2] = {frameNum=16, x=5, y=-50, iconX=29, iconY=5, soundDelay=0.2},
    [3] = {frameNum=17, x=5, y=-15,iconX=0, iconY=0},
    [5] = {frameNum=15, iconX=2, iconY=15, x=-55, y=-60,scale = 1.4,iconScale = 1.4},
    [6] = {frameNum=17, iconScale=0.8, curvePath=true, delay=0, rotation=3, x=5, y=-10, iconX=20, iconY=10, soundDelay=0.2},
    [7] = {frameNum=13, scale=1.6, iconScale=1.6, x=0, y=-25, iconX=40, iconY=25},
    [8] = {frameNum=15, x=-85, y=-40, iconX=40, iconY=25, soundDelay=0.2},
    [9] = {frameNum=20, delay=0, x=0, y=-7, iconX=-10, iconY=-10},
    [11] = {frameNum=12, iconScale = 1.7, x=-25, y=-20, iconX=35, iconY=20},
    [12] = {frameNum=16, iconScale = 1.5,x =2,y =-25, iconX=42, iconY=20},
}

HddjController.hddjConfig_99 = {
    [1] = {frameNum=13, iconScale = 1.3, x=-11, y=18, iconX=62, iconY=52, rotation=2},
    [2] = {frameNum=16, x=36, y=-22, iconX=42, iconY=25, soundDelay=0.2},
    [3] = {frameNum=17, x=-6, y=-2,iconX=11, iconY=5},
    [5] = {frameNum=15, iconX=40, iconY=50, x=-5, y=-10,scale = 1,iconScale = 1},
    [6] = {frameNum=17, iconScale=0.8, curvePath=true, delay=0, rotation=3, x=0, y=30, iconX=30, iconY=25, soundDelay=0.2},
    [7] = {frameNum=13, scale=1.4, iconScale=1.6, x=22, y=-2, iconX=56, iconY=43},
    [8] = {frameNum=15, x=-75, y=-20, iconX=52, iconY=42, soundDelay=0.2},
    [9] = {frameNum=20, delay=0, x=13, y=10, iconX=6, iconY=10},
    [11] = {frameNum=12, iconScale = 1.7, x=-10, y=0, iconX=50, iconY=47},
    [12] = {frameNum=16, iconScale = 1.5,x =12,y =0, iconX=60, iconY=48},
}


local SeatPosition = RoomViewPosition.SeatPosition

function loadBasicResource(callback)
    local resource = {
        "atlas/hddj1.png",
        "atlas/hddj2.png",
        "atlas/hddj3.png",
        "atlas/hddj5.png",
        "atlas/hddj6.png",
        "atlas/hddj7.png",
        "atlas/hddj8.png",
        "atlas/hddj9.png",
        "atlas/hddj12.png",
        "atlas/hddj13.png",
        "atlas/hddj14.png",
        "atlas/hddj15.png",
        "atlas/hddj16.png",
        "atlas/hddj17.png",
        "atlas/hddj18.png",
        "atlas/hddj19.png",
    }
    local len = #resource
    for i = 1, len do
        TextureCache.instance():get_async(resource[i], function() 
            len = len - 1
            if len == 0 then
                callback()
            end
        end)
    end
end

function HddjController:ctor(container)
    loadBasicResource(function()
        if tolua.isnull(self) then return end
        self.container_ = container
        self.loadedHddjIds_ = {}
        self.loadingHddj_ = {}
        if nk.roomSceneType == "qiuqiu" then
            local roomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")
            SeatPosition = roomViewPosition.SeatPosition
            HddjController.hddjConfig = HddjController.hddjConfig_99
        else
            SeatPosition = RoomViewPosition.SeatPosition
            HddjController.hddjConfig = HddjController.hddjConfig
        end
    end)

end

function HddjController:dtor()
    self.loadedHddjIds_ = nil
    self.loadingHddj_ = nil
    self.isDisposed_ = true
    if self.schedule1 then
        self.schedule1:cancel()
    end
    if self.schedule2 then
        self.schedule2:cancel()
    end
    if self.schedule3 then
        self.schedule3:cancel()
    end
    nk.GCD.Cancel(self)
end

function HddjController:playHddj(fromPositionId, toPositionId, fromNode, toNode, hddjId, completeCallback)
    if fromNode and toNode then
        local fromNodePos = {}
        fromNodePos.x, fromNodePos.y = fromNode:getAbsolutePos()
        local toNodePos = {}
        toNodePos.x, toNodePos.y = toNode:getAbsolutePos()
        if self.isDisposed_ then
            return
        elseif hddjId == 11 then -- 1.5.5版本，去掉绿饮 
            return
        elseif hddjId == 10 then
            return self:playTissue(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
        elseif hddjId == 4 then
            return self:playKiss(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
        elseif hddjId == 13 then
            return self:playDogAni(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
        elseif hddjId == 14 then
            return self:playLove(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)    
        elseif hddjId == 15 then
            local container = new(Node)
            self.container_:addChild(container)
            new(require("game.roomGaple.hddjPluggin15"), container, fromNodePos, toNodePos):play(completeCallback)
            return container
        elseif hddjId == 16 then
            return self:playDurianAni(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
        elseif hddjId == 17 then
            local container = new(Node)
            self.container_:addChild(container)
            new(require("game.roomGaple.anim.hddjCakeAnim"), container, fromNodePos, toNodePos):play(completeCallback)
            return container
        elseif hddjId == 18 then
            local container = new(Node)
            self.container_:addChild(container)
            new(require("game.roomGaple.anim.hddjDragonflyAnim"), container, fromNodePos, toNodePos):play(completeCallback)
            return container
        elseif hddjId == 19 then
            local container = new(Node)
            self.container_:addChild(container)
            new(require("game.roomGaple.anim.hddjShieldAnim"), container, fromNodePos, toNodePos):play(completeCallback)
            return container
        else
            return self:playHddjAnim(hddjId, fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
        end
    end
end

function HddjController:createImagesList(id,frameNum)
    local name =  "res/hddjs/hddj%d/hddj%d_%04d.png"
    local list = {}
    for i=1,frameNum do
        local imageName = string.format(name,id,id,i)
        table.insert(list,imageName)
    end
    return list
end

function HddjController:playHddjAnim(hddjId, fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
    local container = new(Node)
    self.container_:addChild(container)

    self:playHddjAnim_(hddjId, container, drawing, fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)

    return container
end

function HddjController:playHddjAnim_(hddjId, container, drawing, fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
    local config = HddjController.hddjConfig[hddjId]
    if not config then 
        nk.GCD.PostDelay(self, function()
               completeCallback()
            end, nil, (1 + 0.1 + (0.01)*1000))
        return 
    end 

    local iconNode = new(Node)
    iconNode:setPos(fromNodePos.x, fromNodePos.y)
    container:addChild(iconNode)

    local imageName = string.format("res/room/hddj/hddj_%d.png",hddjId)
    if hddjId==2 then
        imageName = "res/room/hddj/hddj_2_1.png"
    end
    local icon = new(Image,imageName)
    local scale = config.iconScale or 1
    icon:setAlign(kAlignCenter)
    icon:addPropScaleSolid(0, scale, scale, kCenterDrawing)
    iconNode:addChild(icon)


    if config.rotation then
        local animLoading = nil
        if fromNodePos.x < toNodePos.x then
            animLoading = new(AnimDouble,kAnimNormal,0,360 * config.rotation,1000,-1)
        else
            animLoading = new(AnimDouble,kAnimNormal,360 * config.rotation,0,1000,-1)
        end
        local propLoading = new(PropRotate,animLoading,kCenterDrawing)
        icon:doAddProp(propLoading,1)
    end

    local eachImageTime = math.floor(1000/8)

    -- 曲线
    config.curvePath = false
    if config.curvePath then
        
    else
        if hddjId==2 then
            toNodePos = {x= toNodePos.x+35,y = toNodePos.y-35}   
        end
        iconNode:moveTo({x = toNodePos.x, y = toNodePos.y, time = 1 ,onComplete = handler(self, function()
            icon:removeAllProp()
            nk.functions.removeFromParent(iconNode,true)
            if not config.soundDelay then
                nk.SoundManager:playHddjSound(hddjId)
            end

            local imagesList = self:createImagesList(hddjId,config.frameNum) 
            local drawing = new(Images,imagesList) 
            local scale = config.scale or 1
            drawing:setAlign(kAlignCenter)
            drawing:addPropScaleSolid(0, scale, scale, kCenterDrawing)

            drawing:setPos(toNodePos.x, toNodePos.y)
            container:addChild(drawing) 

            local animIndex = new(AnimInt,kAnimNormal ,0,config.frameNum -1,config.frameNum*eachImageTime,-1)
            animIndex:setDebugName("playHddjAnim.animIndex") 

            local propIndex = new(PropImageIndex,animIndex) 
            propIndex:setDebugName("playHddjAnim.propIndex") 
            drawing:doAddProp(propIndex,1) 

            nk.GCD.PostDelay(self,function()
                drawing:removeAllProp()
                nk.functions.removeFromParent(drawing,true)
            end, nil, config.frameNum*eachImageTime)    

        end)})
    end

    nk.GCD.PostDelay(self,function()
       completeCallback()
    end, nil, (1 + (config.delay or 0.1) + (config.soundDelay or 0) + 0.01)*1000 + config.frameNum*eachImageTime)

    if config.soundDelay then
        nk.GCD.PostDelay(self,function()
           nk.SoundManager:playHddjSound(hddjId)
        end, nil, (1 + (config.delay or 0.1) + config.soundDelay)*1000)
    end

end

function HddjController:playTissue(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
    local tissueNode = new(Node)
    tissueNode:setPos(fromNodePos.x, fromNodePos.y)
    self.container_:addChild(tissueNode)

    local tissueSpr = new(Image,"res/room/hddj/hddj_tissue.png")
    tissueSpr:setAlign(kAlignCenter)
    tissueSpr:addPropScaleSolid(0, 1.4, 1.4, kCenterDrawing)
    tissueNode:addChild(tissueSpr)

    tissueNode:moveTo({x = toNodePos.x, y = toNodePos.y, time = 1 ,onComplete = handler(self, function()
            tissueNode:setPos(toNodePos.x, toNodePos.y)
            local tissueNode_x, tissueNode_y = tissueNode:getPos()
            local space = -2
            local moveRepeat = nk.GCD.PostDelay(self,function()
                tissueNode_x, _ = tissueNode:getPos()
                if tissueNode_x >=  toNodePos.x + 30  then
                    space = -2
                elseif tissueNode_x <=  toNodePos.x - 30 then
                    space = 2
                end
                tissueNode:setPos(tissueNode_x + space,tissueNode_y)
            end, nil, 17, true) 

            local tissueMusic = nk.GCD.PostDelay(self,function()
                nk.SoundManager:playHddjSound(10)
            end, nil, 1000)

            local tissueAnim = nk.GCD.PostDelay(self,function()
                nk.GCD.CancelById(self,tissueMusic)
                nk.GCD.CancelById(self,moveRepeat)
                nk.GCD.CancelById(self,tissueAnim)
                tissueNode:removeAllProp()
                nk.functions.removeFromParent(tissueNode,true)
            end, nil, 3000)    

        end)})

    return tissueNode
end

function HddjController:playKiss(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)

    local kissAnimNode = new(Node)
    kissAnimNode:setPos(fromNodePos.x, fromNodePos.y)
    self.container_:addChild(kissAnimNode)

    local kissIcon = new(Image,"res/room/hddj/hddj_kiss_lip_icon.png")
    kissIcon:setAlign(kAlignCenter)
    kissIcon:addPropScaleSolid(0, 1.2, 1.2, kCenterXY )
    kissAnimNode:addChild(kissIcon)

    kissAnimNode:moveTo({x = toNodePos.x, y = toNodePos.y, time = 1 ,onComplete = handler(self, function()
        kissIcon:removeAllProp()
        kissIcon:removeFromParent(true)
        self:playKissNextStep(kissAnimNode, fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
        end)})

    return kissAnimNode
end

function HddjController:playKissNextStep(kissAnimNode, fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
    local kissIcon = new(Image,"res/room/hddj/hddj_kiss_lip_icon.png")
    local kissHeart = nil

    nk.SoundManager:playHddjSound(4)
    kissIcon:setAlign(kAlignCenter)

    kissAnimNode:setPos(toNodePos.x, toNodePos.y)
    kissAnimNode:addChild(kissIcon)

    local easing = require("libEffect.easing")

    local table_I = {}
    local table_H = {}

    local dataTime_I = easing.getEaseArray("easeInOutCubic", 500, 1.2, 1.4)
    table_I.resTime_I = new(ResDoubleArray, dataTime_I)

    table_I.animTime_I = new(AnimIndex, kAnimLoop, 0, #dataTime_I - 1, 500, table_I.resTime_I, 1)

    table_I.propScale_I = new(PropScale, table_I.animTime_I, table_I.animTime_I, kCenterDrawing)
    kissIcon:doAddProp(table_I.propScale_I, 0)

    local kissHeartGcd = nk.GCD.PostDelay(self,function()
        nk.SoundManager:playHddjSound(4)

        kissHeart = new(Image,"res/room/hddj/hddj_kiss_heart.png")
        kissHeart:setAlign(kAlignCenter)
        kissAnimNode:addChild(kissHeart)

        local dataTime_H = easing.getEaseArray("easeInOutCirc", 400, 0, 20)
        table_H.resTime_H = new(ResDoubleArray, dataTime_H)

        local dataBend_H = easing.getEaseArray("easeInOutCirc", 1000, 0, -100)
        table_H.resBend_H = new(ResDoubleArray, dataBend_H)

        table_H.animTime_H = new(AnimIndex, kAnimRepeat, 0, #dataTime_H - 1, 400, table_H.resTime_H, 1)
        table_H.animBend_H = new(AnimIndex, kAnimNormal, 0, #dataBend_H - 1, 1000, table_H.resBend_H, 1)

        table_H.propTranslate = new(PropTranslate, table_H.animTime_H, table_H.animBend_H)
        kissHeart:doAddProp(table_H.propTranslate, 0)


        local dataScale_H = easing.getEaseArray("easeInOutCirc", 1000, 1, 1.4)
        table_H.resScale_H = new(ResDoubleArray, dataScale_H)

        table_H.animScale_H = new(AnimIndex, kAnimNormal, 0, #dataScale_H - 1, 1000, table_H.resScale_H, 1)

        table_H.propScale_H = new(PropScale, table_H.animScale_H, table_H.animScale_H, kCenterDrawing)
        kissHeart:doAddProp(table_H.propScale_H, 1)


        table_H.animBend_H:setEvent(table_H,function ()
            kissHeart:doRemoveProp(0)
            kissHeart:doRemoveProp(1)

            -- delete(table_H.propTranslate) 
            -- delete(table_H.propScale_H) 

            -- delete(table_H.animBend_H) 
            -- delete(table_H.animTime_H) 
            -- delete(table_H.animScale_H) 

            -- delete(table_H.resBend_H) 
            -- delete(table_H.resTime_H)  
            -- delete(table_H.resScale_H)   

            kissHeart:removeFromParent(true)
        end)
    end, nil, 1100, true)

    nk.GCD.PostDelay(self,function()
        nk.GCD.CancelById(self,kissHeartGcd) 
        if kissHeart and kissIcon then
            kissHeart:doRemoveProp(0)
            kissHeart:doRemoveProp(1)
            -- delete(table_H.propTranslate) 
            -- delete(table_H.propScale_H) 
            -- delete(table_H.animBend_H) 
            -- delete(table_H.animTime_H) 
            -- delete(table_H.animScale_H) 
            -- delete(table_H.resBend_H) 
            -- delete(table_H.resTime_H)  
            -- delete(table_H.resScale_H)   

            kissHeart:removeFromParent(true)

            kissIcon:doRemoveProp(0)
            -- delete(table_I.propScale_I) 
            -- delete(table_I.animTime_I) 
            -- delete(table_I.resTime_I) 

            kissIcon:removeFromParent(true)
        end

        completeCallback()
    end, nil, 3200) 
end

function HddjController:playDurianAni(fromPositionId, toPositionId,completeCallback,fromNodePos, toNodePos)
    Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> playDurianAni")
    local config = {frameNum = 9}
    local hddjId = 16

    local container = new(Node)
    self.container_:addChild(container)

    local iconNode = new(Node)
    iconNode:setPos(fromNodePos.x, fromNodePos.y)
    container:addChild(iconNode)


    local imageName = "res/room/hddj/hddj_durian.png"
    local icon = new(Image,imageName)
    icon:setAlign(kAlignCenter)
    iconNode:addChild(icon)
    
    --右边为正方向,isReverse为true就是左边
    local isReverse = fromNodePos.x > toNodePos.x

    local startValue = 0
    local endValue = 0

    if not isReverse then
        startValue = 0
        endValue = 360 * 1
    else
        startValue = 360 * 1
        endValue = 0
    end

    local totalRun = 1200
    --params: sequence, animType, duration, delay, startValue, endValue, center, x, y
    icon:addPropRotate(0, kAnimNormal, totalRun, 0, startValue, endValue, kCenterDrawing, 0, 0)

    local eachImageTime = math.floor(1000/12)
    iconNode:moveTo({x = toNodePos.x, y = toNodePos.y, time = totalRun/1000 ,onComplete = handler(self, function()
            icon:removeAllProp()
            icon:addPropTransparency(1, kAnimNormal, 790, 0, 1, 0)
            local nextPx,nextPy = toNodePos.x +50,toNodePos.y - 30
            if isReverse then
                nextPx,nextPy = toNodePos.x - 50,toNodePos.y - 30
            end
            iconNode:moveTo({x = nextPx, y = nextPy, time = 0.8,onComplete =function()
                icon:removeAllProp()
                nk.functions.removeFromParent(iconNode,true)
            end})
            
            local name =  "res/hddjs/hddj%d/hddj%d_Durian_%04d.png"
            local imagesList = {}
            for i=1,config.frameNum do
                local imageName = string.format(name,hddjId,hddjId,i)
                table.insert(imagesList,imageName)
            end

            local drawing = new(Images,imagesList);
            drawing:removeAllProp()
            drawing:setAlign(kAlignCenter)
            drawing:addPropTranslateSolid(0,toNodePos.x,toNodePos.y)
            drawing:addPropScaleSolid(1, isReverse and -1 or 1, 1, kCenterDrawing)

            container:addChild(drawing)

            local animIndex = new(AnimInt,kAnimNormal ,0,config.frameNum - 1,config.frameNum*eachImageTime,-1)
            animIndex:setDebugName("playHddjAnim.animIndex");

            local propIndex = new(PropImageIndex,animIndex);
            propIndex:setDebugName("playHddjAnim.propIndex");
            drawing:doAddProp(propIndex,2);

            nk.GCD.PostDelay(self,function()
                drawing:removeAllProp()
                nk.functions.removeFromParent(drawing,true)
            end, nil, config.frameNum*eachImageTime)    

        end)})

    nk.GCD.PostDelay(self,function()
       completeCallback()
    end, nil, totalRun + config.frameNum*eachImageTime)

    -- nk.GCD.PostDelay(self,function()
       nk.SoundManager:playHddjSound(hddjId)
    -- end, nil, 0)
    
    return iconNode
end

function HddjController:playDogAni(fromPositionId, toPositionId,completeCallback,fromNodePos, toNodePos)
    Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> playDogAni")
    local config = {frameNum = 15}
    local hddjId = 13

    local container = new(Node)
    self.container_:addChild(container)

    local iconNode = new(Node)
    iconNode:setPos(fromNodePos.x, fromNodePos.y)
    container:addChild(iconNode)


    local imageName = "res/room/hddj/hddj_bone.png"
    local icon = new(Image,imageName)
    icon:setAlign(kAlignCenter)
    iconNode:addChild(icon)
    
    --右边为正方向,isReverse为true就是左边
    local isReverse = fromNodePos.x > toNodePos.x

    local startValue = 0
    local endValue = 0

    if not isReverse then
        startValue = 45
        endValue = 360 * 1 + 45
    else
        startValue = 360 * 1 - 45
        endValue = 0 - 45
    end

    local totalRun = 0
    local moveTime = 500
    --params:sequence, animType, duration, delay, startX, endX, startY, endY, center, x, y
    icon:addPropScale(0, kAnimNormal, 300, totalRun, 0.2, 1, 0.2, 1, kCenterDrawing, 0, 0)
    totalRun = totalRun + 300 --上一次持续时间
    icon:addPropScale(1, kAnimNormal, 300, totalRun, 1, 0.8, 1, 0.8, kCenterDrawing, 0, 0)
    totalRun = totalRun + 300 --上一次持续时间

    --params: sequence, animType, duration, delay, startValue, endValue, center, x, y
    icon:addPropRotate(2, kAnimNormal, moveTime, totalRun + 100, startValue, endValue, kCenterDrawing, 0, 0)
    totalRun = totalRun + moveTime + 100  --延迟时间 + 上一次持续时间


    local eachImageTime = math.floor(1000/12)
    iconNode:moveTo({x = toNodePos.x, y = toNodePos.y, time = moveTime / 1000 ,delay = (totalRun - moveTime) / 1000,onComplete = handler(self, function()
            icon:removeAllProp()
            nk.functions.removeFromParent(iconNode,true)
            
            local imagesList = self:createImagesList(hddjId,config.frameNum);
            local drawing = new(Images,imagesList);
            drawing:removeAllProp()
            drawing:setAlign(kAlignCenter)
            drawing:addPropTranslateSolid(0,toNodePos.x,toNodePos.y)
            drawing:addPropScaleSolid(1, isReverse and -1 or 1, 1, kCenterDrawing)

            container:addChild(drawing)

            local animIndex = new(AnimInt,kAnimNormal ,0,config.frameNum - 1,config.frameNum*eachImageTime,-1)
            animIndex:setDebugName("playHddjAnim.animIndex");

            local propIndex = new(PropImageIndex,animIndex);
            propIndex:setDebugName("playHddjAnim.propIndex");
            drawing:doAddProp(propIndex,2);

            nk.GCD.PostDelay(self,function()
                drawing:removeAllProp()
                nk.functions.removeFromParent(drawing,true)
            end, nil, config.frameNum*eachImageTime)    

        end)})

    nk.GCD.PostDelay(self,function()
       completeCallback()
    end, nil, totalRun + config.frameNum*eachImageTime)

    -- nk.GCD.PostDelay(self,function()
       nk.SoundManager:playHddjSound(hddjId)
    -- end, nil, 0)
    
    return iconNode
end

function HddjController:playLove(fromPositionId, toPositionId, completeCallback, fromNodePos, toNodePos)
    nk.SoundManager:playHddjSound(14)
    local loveNode = new(Node)
    self.container_:addChild(loveNode)
    local eachImageTime = 88
    local angle = nk.functions.getAngle(fromNodePos,toNodePos)

    --弓箭动画
    local bowList = {}
    for i=1,17 do
        table.insert(bowList,string.format("res/hddjs/hddj14/hddj14_bow%03d.png",i))
    end
    local bow = new(Images,bowList) 
    bow:setAlign(kAlignCenter)
    bow:addPropRotateSolid(1, angle, kCenterDrawing)
    bow:setPos(fromNodePos.x, fromNodePos.y)
    loveNode:addChild(bow)

    local animIndex = new(AnimInt,kAnimNormal ,0,16,16*eachImageTime,-1)
    animIndex:setDebugName("playHddjAnim.animIndex") 

    local propIndex = new(PropImageIndex,animIndex) 
    propIndex:setDebugName("playHddjAnim.propIndex") 
    bow:doAddProp(propIndex,2) 

    --爱心动画
    local loveList = {}
    for i=1,17 do
        table.insert(loveList,string.format("res/hddjs/hddj14/hddj14_love%04d.png",i))
    end
    local love = new(Images,loveList) 
    love:setAlign(kAlignCenter)
    love:setPos(toNodePos.x, toNodePos.y)
    loveNode:addChild(love)
    local animIndex = new(AnimInt,kAnimNormal ,0,16,16*eachImageTime,-1)
    animIndex:setDebugName("playHddjAnim.animIndex") 
    local propIndex = new(PropImageIndex,animIndex) 
    propIndex:setDebugName("playHddjAnim.propIndex") 
    love:doAddProp(propIndex,2) 

    local fromPos = fromNodePos
    local toPos = {x = toNodePos.x,y = toNodePos.y-15}
    self.schedule1 =Clock.instance():schedule_once(function(dt)
        self:createArrow(loveNode,0.9,fromPos,toPos,eachImageTime)
    end, 13*eachImageTime/1000)

    local fromPos = {x = fromNodePos.x,y = fromNodePos.y-30}
    local toPos = {x = toNodePos.x,y = toNodePos.y-43}
    self.schedule2 =Clock.instance():schedule_once(function(dt)
        self:createArrow(loveNode,0.3,fromPos,toPos,eachImageTime)
    end, 13*eachImageTime/1000+0.05)

    local fromPos = {x = fromNodePos.x,y = fromNodePos.y+30}
    local toPos = {x = toNodePos.x+25,y = toNodePos.y+32}
    self.schedule3 =Clock.instance():schedule_once(function(dt)
        self:createArrow(loveNode,0.5,fromPos,toPos,eachImageTime,completeCallback)
    end, 13*eachImageTime/1000+0.1)
    
    return loveNode
end


function HddjController:bowHitLove(loveNode,scale,fromPos,toPos,eachImageTime,completeCallback)
            --击中动画
        local hitList = {}
        for i=1,14 do
            table.insert(hitList,string.format("res/hddjs/hddj14/hddj14_hit%03d.png",i))
        end
        local hit = new(Images,hitList) 
        hit:setAlign(kAlignCenter)
        hit:setPos(toPos.x, toPos.y)
        local angle = nk.functions.getAngle(fromPos,toPos)
        hit:addPropRotateSolid(0, angle, kCenterDrawing)
        hit:addPropScaleSolid(1, scale,scale, kCenterDrawing)
        loveNode:addChild(hit)
        local animIndex = new(AnimInt,kAnimNormal ,0,13,13*eachImageTime,-1)
        animIndex:setDebugName("playHddjAnim.animIndex") 
        local function callback( ... )
            if not self.isDisposed_ and completeCallback then
                completeCallback()
            end
        end
        animIndex:setEvent(self,callback)
        local propIndex = new(PropImageIndex,animIndex) 
        propIndex:setDebugName("playHddjAnim.propIndex") 
        hit:doAddProp(propIndex,2) 
    end

function HddjController:createArrow(loveNode,scale,fromPos,toPos,eachImageTime,callback)
    local node = new(Node)
    node:setPos(fromPos.x, fromPos.y)
    loveNode:addChild(node)
    local angle = nk.functions.getAngle(fromPos,toPos)
    local arrow = new(Image,"res/hddjs/hddj14/hddj14_arrow001.png")
    arrow:setAlign(kAlignRight)
    arrow:addPropScaleSolid(1, scale, scale, kCenterXY,91,8)
    arrow:addPropRotateSolid(2, angle, kCenterXY,91,8)
    node:addChild(arrow)
    node:moveTo({x = toPos.x, y = toPos.y, time = 0.3,onComplete = handler(self, function()
        arrow:removeAllProp()
        node:removeFromParent(true)
        self:bowHitLove(loveNode,scale,fromPos, toPos,eachImageTime,callback)
        end)})
end    


return HddjController