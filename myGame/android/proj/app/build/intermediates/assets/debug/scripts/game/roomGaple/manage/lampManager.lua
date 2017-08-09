--
-- Author: tony
-- Date: 2014-07-08 14:59:10
--
local LampManager = class()
-- local RoomViewPosition = import(".views.RoomViewPosition")

--客户端自己的位置
local middleSeatId = 3

function LampManager:ctor()
end

function LampManager:createNodes()
    self.lamp_ = self.scene.nodes.lampNode:getChildByName("lampNod")
    _, self.lampDefaultH_ = self.lamp_:getSize()
    -- local propScaleSolid = new(PropScaleSolid,  1, 2.5, kCenterXY, 35, 0)
    -- self.lamp_:doAddProp(propScaleSolid, 4)
    self.lamp_:setVisible(false)
    self.lampPostionId_ = 1
    -- 当前旋转值
    self.rotateVal_ = 0
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

function LampManager:turnTo(positionId, animation, isSelf)
    local seatPos
    local flag = false
    if isSelf and positionId == middleSeatId then
        flag = true
        seatPos = RoomViewPosition.SeatPosition[5];
    else
        seatPos = RoomViewPosition.SeatPosition[positionId]
    end
    if not seatPos then
        seatPos = RoomViewPosition.SeatPosition[1]
        self.lampPostionId_ = 1
    else
        self.lampPostionId_ = positionId
    end
    Log.printInfo("lamp turn to seatPostion " .. self.lampPostionId_ .. (animation and " with animation" or ""))

    local rotate = RoomViewPosition.LampRorate[self.lampPostionId_]
    if flag then
        rotate = RoomViewPosition.LampRorate[5]
    end
    self:setLampRotation(animation, rotate)
end

function LampManager:setLampRotation(animation, rotation)
    if animation then
        if not self.lamp_:checkAddProp(3) then
            self.lamp_:doRemoveProp(3)
            self.lamp_:doRemoveProp(4)
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

        local anim = self.lamp_:addPropRotate(3, kAnimNormal, 500, 0, 0, animRotate, kCenterXY, 0, 0)
        if anim then
            anim:setEvent(nil, handler(self, function()
                self.lamp_:doRemoveProp(3)
                self.signRotateVal_ = nil
                self.rotateVal_ = rotation
                self:setRotate()
            end))
        end
    else
        self.rotateVal_ = rotation
        self:setRotate()
    end
end

-- 重新设置并添加静态旋转属性
function LampManager:setRotate()
    if not self.lamp_:checkAddProp(1) then
        self.lamp_:doRemoveProp(1)
    end
    local propRotateSolid = new(PropRotateSolid, self.rotateVal_, kCenterXY, 0, 0)
    self.lamp_:doAddProp(propRotateSolid, 1)
end

function LampManager:dtor()
    if self.lamp_ then
        self.lamp_:doRemoveProp(1)
        self.lamp_:doRemoveProp(4)
    end
end

return LampManager