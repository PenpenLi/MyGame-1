
local FrameAnim = class()

-- images 图片列表
-- parent 父节点
-- frameNum 图片个数
-- time 播放时长
-- align 动画相对父节点的对齐方式
-- scale 缩放比例
-- scaleCenter 缩放中心点
-- x, y 动画相对于父节点在align下的偏移
-- callback 回调函数
-- name 动画名
function FrameAnim:ctor(images, parent, frameNum, time, callback, align, scale, scaleCenter, x, y, name)
    local Aalign = align or kAlignCenter
    local SCenter = scaleCenter or kCenterDrawing
    self.m_callback = callback

    self.m_drawing = new(Images,images)
    self.m_drawing:addPropScaleSolid(0, scale or 1, scale or 1, SCenter)
    self.m_drawing:setAlign(Aalign)
    self.m_drawing:setPos(x or 0, y or 0)
    parent:addChild(self.m_drawing)

    local animName = ""

    self.m_animIndex = new(AnimInt,kAnimRepeat ,0,frameNum -1,time,-1)
    animName = string.format("FrameAnim.animIndex %s",name or "")
    self.m_animIndex:setDebugName(animName)
    self.m_animIndex:setEvent(self,self.releaseAnim)

    self.m_propIndex = new(PropImageIndex,self.m_animIndex)
    animName = string.format("FrameAnim.propIndex %s",name or "")
    self.m_propIndex:setDebugName(animName)
    self.m_drawing:doAddProp(self.m_propIndex,1);
end

function FrameAnim:releaseAnim()
    self:stopAnim()
    if self.m_callback then
        self.m_callback()
    end
end

function FrameAnim:stopAnim()
    if self.m_drawing then
        if self.m_propIndex then
            self.m_drawing:doRemoveProp(1)
            -- self.m_drawing:removePropByID(self.m_propIndex.m_propID)
            -- delete(self.m_propIndex)
            self.m_propIndex = nil
        end
        if self.m_animIndex then
            delete(self.m_animIndex)
            self.m_animIndex = nil
        end
        self.m_drawing:removeFromParent(true)
        delete(self.m_drawing)
        self.m_drawing = nil
    end
end

function FrameAnim:dtor()

end


return FrameAnim