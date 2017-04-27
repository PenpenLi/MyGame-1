--
-- Author: johnny@boomegg.com
-- Date: 2014-07-28 17:38:39
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ChipFlayAnim = class(Node)

ChipFlayAnim.direction_player_to_top = 1        -- 玩家飞向奖池
ChipFlayAnim.direction_player_to_player = 2     -- 玩家飞向玩家
ChipFlayAnim.direction_win = 3                  -- 结算框飞向玩家
ChipFlayAnim.direction_top_to_player = 4        -- 奖池飞向玩家

ChipFlayAnim.scale_to_small = 0.8       -- 缩小比例
ChipFlayAnim.scale_to_big = 1.2         -- 放大比例
ChipFlayAnim.scale_to_normal = 1        -- 正常比例

function ChipFlayAnim:ctor(direction, fromCtr, endCtr)
    if nk.updateFunctions.checkIsNull(fromCtr) or nk.updateFunctions.checkIsNull(endCtr) then
        return
    end
    -- 加载拼图
    nk.SoundManager:playSound(nk.SoundManager.CHIPSFLAY)
    local moveScale = 1
    local sweepLightScale = 1
    if direction == ChipFlayAnim.direction_player_to_top then
        moveScale = ChipFlayAnim.scale_to_big
        sweepLightScale = ChipFlayAnim.scale_to_normal
    elseif direction == ChipFlayAnim.direction_player_to_player then
        moveScale = ChipFlayAnim.scale_to_normal
        sweepLightScale = ChipFlayAnim.scale_to_small
    elseif direction == ChipFlayAnim.direction_win then
        moveScale = ChipFlayAnim.scale_to_normal
        sweepLightScale = ChipFlayAnim.scale_to_small
    elseif direction == ChipFlayAnim.direction_top_to_player then
        moveScale = ChipFlayAnim.scale_to_small
        sweepLightScale = ChipFlayAnim.scale_to_small
    end

    local moveCell = 1
    local particleCell = 0.1 * 1000
    local sweepLightCell = 0.1 * 1000
    local scaleCell = 0.1 * 1000

    -- local startP_x, startP_y = nk.functions.formatAbsolutePos(fromCtr)
    -- local endP_x, endP_y = nk.functions.formatAbsolutePos(endCtr)

    local startP_x, startP_y = fromCtr:getAbsolutePos()
    local endP_x, endP_y = endCtr:getAbsolutePos()

    self.m_chip_node = {}

    self.m_light = {}


    for i = 1, 4 do
        nk.GCD.PostDelay(self,function()

            local chip_node = new(Node)
            chip_node:setPos(startP_x, startP_y)
            chip_node:setAlign(kAlignCenter)
            self:addChild(chip_node)

            table.insert(self.m_chip_node,chip_node)

            local chip = new(Image,"res/chips/chip_small.png")  
            chip_node:addChild(chip)
            chip:setAlign(kAlignCenter)

            local light = new(Image,"res/chips/chip_small_light.png")
            chip:addChild(light)
            light:setAlign(kAlignCenter)

            table.insert(self.m_light,light)

            if moveScale >1 then
                chip_node:scaleTo({time = moveCell, srcX = 1, srcY = 1, scaleX = moveScale, scaleY = moveScale})
            end

            light:fadeIn({time = moveCell})

            chip_node:moveTo({x = endP_x, y = endP_y, time = moveCell, onComplete = handler(self, function()
                nk.GCD.PostDelay(self,function()
                    light:removeAllProp()
                    chip_node:removeAllProp()
                    chip_node:removeFromParent(true)
                end, nil, 0.2*1000)
            end)})

        end, nil, (i-1)*0.1*1000)
    end

    nk.GCD.PostDelay(self,function()
        local imagesList = self:createImagesList(1,10)
        self.m_particle = new(Images,imagesList)

        self.m_particle:setPos(endP_x, endP_y)
        self.m_particle:setAlign(kAlignCenter)
        self:addChild(self.m_particle)

        local animIndex = new(AnimInt,kAnimRepeat , 0, 10-1, 10*particleCell, -1)
        animIndex:setDebugName("self.m_particle.animIndex");

        local propIndex = new(PropImageIndex,animIndex);
        propIndex:setDebugName("self.m_particle.propIndex");
        self.m_particle:doAddProp(propIndex,1);

    end, nil, moveCell*1000)

    nk.GCD.PostDelay(self,function()
        if not tolua.isnull(self.m_particle) then
            self.m_particle:removeAllProp()
            self.m_particle:removeFromParent(true)
        end
    end, nil, moveCell*1000 + 10*particleCell)   

    nk.GCD.PostDelay(self,function()
        local imagesList = self:createImagesList(2,12)
        self.m_sweepLight = new(Images,imagesList)

        self.m_sweepLight:setPos(endP_x, endP_y)
        self.m_sweepLight:setAlign(kAlignCenter)
        self:addChild(self.m_sweepLight)
        self.m_sweepLight:addPropScaleSolid(0, sweepLightScale, sweepLightScale, kCenterDrawing)

        local animIndex = new(AnimInt,kAnimRepeat , 0, 12-1, 12*sweepLightCell, -1)
        animIndex:setDebugName("self.m_sweepLight.animIndex");

        local propIndex = new(PropImageIndex,animIndex);
        propIndex:setDebugName("self.m_sweepLight.propIndex");
        self.m_sweepLight:doAddProp(propIndex,1);

    end, nil, moveCell*1000 + 10*particleCell - 0.5*1000)

    nk.GCD.PostDelay(self,function()
        if not tolua.isnull(self.m_sweepLight) then
            self.m_sweepLight:removeAllProp()
            self.m_sweepLight:removeFromParent(true)
        end
    end, nil, moveCell*1000 + 10*particleCell + 12*sweepLightCell - 0.5*1000 - 1)

    self.total_time = moveCell*1000 + 10*particleCell


end

function ChipFlayAnim:createImagesList(imageType,num)
    local name
    if imageType == 1 then
        name = "res/chips/particle00%02d.png"
    else
        name = "res/chips/sweepLight00%02d.png"
    end

    local list = {}
    for i=1,num do
        local imageName = string.format(name,i)
        table.insert(list,imageName)
    end
    return list
end

function ChipFlayAnim:dtor()
    nk.SoundManager:stopSound(nk.SoundManager.CHIPSFLAY)
    if self.m_light then
        for i,light in ipairs(self.m_light) do
            light:removeAllProp()
        end
    end
    if self.m_chip_node then
        for i,chip_node in ipairs(self.m_chip_node) do
            chip_node:removeAllProp()
            chip_node:removeFromParent(true)
        end
    end
    if self.m_particle then
        self.m_particle:removeAllProp()
    end
    if self.m_sweepLight then
        self.m_sweepLight:removeAllProp()
    end
    nk.GCD.Cancel(self)
end


return ChipFlayAnim

