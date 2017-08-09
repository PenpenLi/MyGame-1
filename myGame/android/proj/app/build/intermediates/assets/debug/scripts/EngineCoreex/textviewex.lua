--
-- Author: melon
-- Date: 2016-12-14 17:00:53
--
--textview高度足够时自动滚动
function TextView:autoMove()
    self:setPickable(false)
    self:setScrollBarWidth(0)
    local l1 = self:getFrameLength()
    local l2 = self:getViewLength()
    if l2>l1 then
        if self.m_direction == kVertical then
            self.m_drawing:setPos(nil,l1)
            local function move( ... )
                self.m_drawing:moveTo({time = (l2+l1)/18, y = -l2-l1,offset = true,onComplete = function()
                    self.m_drawing:setPos(nil,l1)
                    move()
                end})
            end
            move()
        else
            self.m_drawing:setPos(l1,nil)
            local function move( ... )
                self.m_drawing:moveTo({time = (l2+l1)/30,x = -l2-l1,offset = true,onComplete = function()
                    self.m_drawing:setPos(l1,nil)
                    move()
                end})
            end
            move()
        end
    end
end

function TextView:setMultiLines(multiLines)
    self.m_res.m_multiLines = multiLines
end