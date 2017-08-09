--
-- Author: Tom
-- Date: 2014-09-04 15:06:16
--
local ANIM_TIME = 2


local ChangeChipAnim = class(Node)

-- chip:变化的金币数量
-- pos_x,pos_y:相对于父节点的坐标

function ChangeChipAnim:ctor(chip, pos_x, pos_y)
    
    self.pos_x = pos_x or LEFT
    self.pos_y = pos_y or TOP 

    local chipNumber = self:formatMoney(chip)

    self.chipChangeAnimation_ = new(Image,"res/common/common_yellowbackground.png")
    self.chipChangeAnimation_:setPos(0,0)
    self.chipChangeAnimation_:setAlign(kAlignBottom)
    self:addChild(self.chipChangeAnimation_)

    if chip >= 0 then
        self.chipChangeLabel_ = new(Text,"+".. chipNumber,150,35,kAlignCenter, nil, 32, 244, 205, 86)
        self.chipChangeLabel_:setPos(0,0)
        self.chipChangeLabel_:setAlign(kAlignCenter)
        self.chipChangeAnimation_:addChild(self.chipChangeLabel_)
    else
        self.chipChangeLabel_ = new(Text,"-".. chipNumber,150,35,kAlignCenter, nil, 32, 188, 188, 188)
        self.chipChangeLabel_:setPos(0,0)
        self.chipChangeLabel_:setAlign(kAlignCenter)
        self.chipChangeAnimation_:addChild(self.chipChangeLabel_)
    end

    self.chipChangeLabel_:moveTo({x=0,y=-60,time=ANIM_TIME })

    nk.GCD.PostDelay(self, function()
        self:release()
    end, nil, 2010)

end

function ChangeChipAnim:formatMoney(money)
    money = math.abs(money)
    if money < 1000 then
        money = nk.updateFunctions.formatNumberWithSplit(money)
    else
        money = nk.updateFunctions.formatBigNumber(money)
    end

    return money
end

function ChangeChipAnim:release()
    nk.GCD.Cancel(self)
    if self.chipChangeAnimation_ then
        self.chipChangeAnimation_:removeFromParent(true)
        delete(self.chipChangeAnimation_)
        self.chipChangeAnimation_ = nil
    end
end

function ChangeChipAnim:dtor()
    self:release()
end

return ChangeChipAnim