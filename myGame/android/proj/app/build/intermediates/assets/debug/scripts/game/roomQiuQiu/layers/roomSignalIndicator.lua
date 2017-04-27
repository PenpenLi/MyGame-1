--
-- Author: tony
-- Date: 2014-08-31 13:49:30
--
local RoomSignalIndicator = class(Node)

function RoomSignalIndicator:ctor(root)
    self.signal1_ = root:getChildByName("signal1")
    self.signal2_ = root:getChildByName("signal2")
    self.signal3_ = root:getChildByName("signal3")
    self.signal4_ = root:getChildByName("signal4")

    self.signalNo_ = root:getChildByName("signalNo")
    self.signalNo_:setVisible(false)

    self.isFlashing_ = false
end

function RoomSignalIndicator:setSignalStrength(strength)
    self:setAllVisible(strength)
    self:flash_(strength == 0)
end

function RoomSignalIndicator:setAllVisible(strength)
    if strength == 0 then
        self.signal1_:setVisible(false)
        self.signal2_:setVisible(false)
        self.signal3_:setVisible(false)
        self.signal4_:setVisible(false)
        self.signalNo_:setVisible(true)
    else
        self.signal1_:setVisible(strength >= 1)
        self.signal2_:setVisible(strength >= 2)
        self.signal3_:setVisible(strength >= 3)
        self.signal4_:setVisible(strength >= 4)
        self.signalNo_:setVisible(false)
    end
end

function RoomSignalIndicator:flash_(isFlash)
    if self.isFlashing_ ~= isFlash then
        self.isFlashing_ = isFlash
        self.signalNo_:doRemoveProp(1)
        if isFlash then
            self.signalNo_:addPropRotate(1, kAnimRepeat, 300, -1, 0, 360, kCenterDrawing)
        end
    end
end

return RoomSignalIndicator