--
-- Author: tony
-- Date: 2014-07-08 14:59:10
--
local LampManager = class()
local RoomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")

function LampManager:ctor()
end

function LampManager:createNodes()
    self.lamp_ = self.ctx.scene.nodes.tableNode:getChildByName("lampImage")
    _, self.lampDefaultH_ = self.lamp_:getSize()
    self.lamp_:setVisible(false)
    self.lampPostionId_ = 1
    -- 当前旋转值
    self.rotateVal_ = 0
    self.scaleVal_ = 1
    self:turnTo(1, false)
end

function LampManager:show()
    self.lamp_:setVisible(true)
end

function LampManager:hide()
    self.lamp_:setVisible(false)
end

function LampManager:getPositionId()
    return self.lampPostionId_ or 1
end

function LampManager:turnTo(positionId, animation)
    local rotate = RoomViewPosition.LampRorate[positionId]
    local seatLightScale = RoomViewPosition.LampScale[positionId] or 1
    self:setLampRotation(animation, rotate, seatLightScale)
end

function LampManager:setLampRotation(animation, rotation, scale)
    animation = false
    if animation then
        self.lamp_:stopAllActions()
        if not self.lamp_:checkAddProp(3) then
            self.lamp_:removeProp(3)
            self.lamp_:removeProp(4)
            if self.signScaleVal_ then
                self.scaleVal_ = self.signScaleVal_
                self.signScaleVal_ = nil
            end
            if self.signRotateVal_ then
                self.rotateVal_ = self.signRotateVal_
                self.signRotateVal_ = nil
                self:setRotate()
            end
        end
        -- 标记anim的旋转值，当还没完成，又调用旋转动画，主动removeProp时直接赋值
        self.signRotateVal_ = rotation
        local animRotate = rotation - (self.rotateVal_ or 0)
        if animRotate < 0 then
            animRotate = animRotate + 360
        end
        if animRotate > 180 then
            animRotate = animRotate - 360
        end

        local anim = self.lamp_:addPropRotate(3, kAnimNormal, 500, -1, 0, animRotate, kCenterXY, 35, 0)
        if anim then
            anim:setEvent(nil, function()
                self.lamp_:removeProp(3)
                self.signRotateVal_ = nil
                self.rotateVal_ = rotation
            end)
        end
        local anim = self.lamp_:addPropScale(4, kAnimNormal, 500, -1, 1, 1, 1, scale, kCenterXY, 35, 0)
        if anim then
            anim:setEvent(nil, function()
                self.lamp_:removeProp(4)
                self.signScaleVal_ = nil
                self.scaleVal_ = scale
                self:setRotate()
            end)
        end
    else
        self.scaleVal_ = scale
        self.rotateVal_ = rotation
        self:setRotate()
    end
end

-- 重新设置并添加静态旋转属性
function LampManager:setRotate()
    if not self.lamp_:checkAddProp(1) then
        self.lamp_:doRemoveProp(1)
    end
    self.lamp_:addPropRotateSolid(1, self.rotateVal_, kCenterXY, 35, 0)
    if not self.lamp_:checkAddProp(2) then
        self.lamp_:doRemoveProp(2)
    end
    self.lamp_:addPropScaleSolid(2, 1, self.scaleVal_, kCenterXY, 35, 0)
end

function LampManager:dtor()
    if self.lamp_ then
        self.lamp_:doRemoveProp(3)
        self.lamp_:doRemoveProp(4)
    end
end

return LampManager