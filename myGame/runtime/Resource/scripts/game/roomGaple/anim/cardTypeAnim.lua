local CardTypeAnim = class(Node)

CardTypeAnim.SINGLE = 1        -- 单倍结算
CardTypeAnim.DOUBLE = 2        -- 多付一倍
CardTypeAnim.TRIPLE = 3        -- 多付二倍
CardTypeAnim.QUARTET = 4       -- 多付三倍

local swf_typeMap = {
    [1] = {swfInfo = "qnRes/qnSwfRes/swf/SINGLE_swf_info",pinMap = "qnRes/qnSwfRes/swf/SINGLE_swf_pin"},
    [2] = {swfInfo = "qnRes/qnSwfRes/swf/double_swf_info",pinMap = "qnRes/qnSwfRes/swf/double_swf_pin"},
    [3] = {swfInfo = "qnRes/qnSwfRes/swf/TRIPLE_swf_info",pinMap = "qnRes/qnSwfRes/swf/TRIPLE_swf_pin"},
    [4] = {swfInfo = "qnRes/qnSwfRes/swf/quretet_swf_info",pinMap = "qnRes/qnSwfRes/swf/quretet_swf_pin"},
}

function CardTypeAnim:ctor(cardType)
    local swfInfo, pinMap
    if not swf_typeMap[cardType] then
        return
    end
    swfInfo = require(swf_typeMap[cardType].swfInfo)
    pinMap = require(swf_typeMap[cardType].pinMap)

    self:release()

    nk.SoundManager:playSound(nk.SoundManager.GAPLE_GAME_OVER)

    self.cardTypeSwfAnim = new(SwfPlayer,swfInfo,pinMap)
    self.cardTypeSwfAnim:setAlign(kAlignCenter)
    self:addChild(self.cardTypeSwfAnim)
    self.cardTypeSwfAnim:play(1,false,1,0,true)

    -- table.insert(nk.SWF,self.cardTypeSwfAnim)

    if self.cardTypeSwfAnim and cardType > 1 then
        self.cardTypeSwfAnim:setFrameEvent(self, function()
            self.numberNode = new(Node) 
            self.numberNode:setAlign(kAlignCenter)
            self.numberNode:setPos(6,65)
            self.numberNode:setLevel(10)
            self.cardTypeSwfAnim:addChild(self.numberNode)

            local XIcon = new(Image,"res/cardType/cardType_x.png")
            XIcon:setAlign(kAlignCenter)
            XIcon:setPos(-22,0)
            self.numberNode:addChild(XIcon)

            local numIcon = new(Image,"res/cardType/cardType_number_".. cardType ..".png")
            numIcon:setAlign(kAlignCenter)
            numIcon:setPos(22,0)
            self.numberNode:addChild(numIcon)

            self.numberNode:scaleTo({time = 0.3, srcX = 1.5, srcY = 1.5, scaleX = 1, scaleY = 1})
        end, 25)

        self.cardTypeSwfAnim:setCompleteEvent(self, function()
                self:release()
        end)
    end
end

function CardTypeAnim:release()
    if self.cardTypeSwfAnim then
        self.cardTypeSwfAnim:pause(0, false)
        self.cardTypeSwfAnim:removeFromParent(true)
    end

    if self.numberNode then
        self.numberNode:stopAllActions()
        self.numberNode:removeFromParent(true)
    end
end


return CardTypeAnim

