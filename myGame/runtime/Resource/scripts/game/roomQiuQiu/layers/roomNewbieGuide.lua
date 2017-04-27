
--
-- Author: ziway
-- Date: 2016-01-04 15:12:28
-- 房间新手引导。喇叭输入的引导不放在这里，因为层级问题，要独立出去

local RoomNewbieGuide = class()

local lineColor
local textRect
local labelGap = 50

function RoomNewbieGuide:ctor()

end

function RoomNewbieGuide:dtor()
    self:removeEventListener()
end

function RoomNewbieGuide:removeEventListener()
	EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_SHOW_SIT_HERE, self, self.ROOM_GUIDE_SHOW_SIT_HERE)
    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_HIDE_SIT_HERE, self, self.ROOM_GUIDE_HIDE_SIT_HERE)

    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_SHOW_MAKE_OPERATION, self, self.ROOM_GUIDE_SHOW_MAKE_OPERATION)
    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_HIDE_MAKE_OPERATION, self, self.ROOM_GUIDE_HIDE_MAKE_OPERATION)

    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL, self, self.ROOM_GUIDE_SHOW_AUTO_CALL)
    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_HIDE_AUTO_CALL, self, self.ROOM_GUIDE_HIDE_AUTO_CALL)

    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD, self, self.ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD)
    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD, self, self.ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD)

    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL_ANY, self, self.ROOM_GUIDE_SHOW_AUTO_CALL_ANY)
    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_HIDE_AUTO_CALL_ANY, self, self.ROOM_GUIDE_HIDE_AUTO_CALL_ANY)

    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_HIDE_OPERATION_BAR, self, self.ROOM_GUIDE_HIDE_OPERATION_BAR)
    EventDispatcher.getInstance():unregister(EventConstants.ROOM_GUIDE_HIDE_ALL, self, self.ROOM_GUIDE_HIDE_ALL)
end

function RoomNewbieGuide:createNodes()
    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_SHOW_SIT_HERE, self, self.ROOM_GUIDE_SHOW_SIT_HERE)
    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_HIDE_SIT_HERE, self, self.ROOM_GUIDE_HIDE_SIT_HERE)

    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_SHOW_MAKE_OPERATION, self, self.ROOM_GUIDE_SHOW_MAKE_OPERATION)
    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_HIDE_MAKE_OPERATION, self, self.ROOM_GUIDE_HIDE_MAKE_OPERATION)

    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL, self, self.ROOM_GUIDE_SHOW_AUTO_CALL)
    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_HIDE_AUTO_CALL, self, self.ROOM_GUIDE_HIDE_AUTO_CALL)

    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD, self, self.ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD)
    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD, self, self.ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD)

    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL_ANY, self, self.ROOM_GUIDE_SHOW_AUTO_CALL_ANY)
    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_HIDE_AUTO_CALL_ANY, self, self.ROOM_GUIDE_HIDE_AUTO_CALL_ANY)

    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_HIDE_OPERATION_BAR, self, self.ROOM_GUIDE_HIDE_OPERATION_BAR)
    EventDispatcher.getInstance():register(EventConstants.ROOM_GUIDE_HIDE_ALL, self, self.ROOM_GUIDE_HIDE_ALL)
end

--提示坐下
function RoomNewbieGuide:ROOM_GUIDE_HIDE_SIT_HERE()
	if not nk.updateFunctions.checkIsNull(self.sitHere_) then
		self.sitHere_:removeFromParent()
	end
end

function RoomNewbieGuide:ROOM_GUIDE_SHOW_SIT_HERE(data)
	if self:gameTotalCount() <= 1 and nk.updateFunctions.checkIsNull(self.sitHere_) then
		self:createHintSitHere(data.startPos,data.endPos)
	end
end

function RoomNewbieGuide:createHintSitHere(nearPointPos,farPointPos)
	self.sitHere_ = new(Node)
	self.sitHere_:addTo(self.ctx.scene.nodes.guideNode)

    local content = new(TextView, bm.LangUtil.getText("ROOM_NEWBIE_GUIDE", "SIT_HERE"), 100, nil, kAlignLeft, nil, 18, 255, 255, 255)
    content:setAlign(kAlignLeft)
    content:setPos(30)
    local bgw, bgh = content:getSize()
    self.sitHere_:setSize(bgw + labelGap, bgh + labelGap*0.5)

    local bg = new(Image, kImageMap.room_newbie_guide_bg, nil, nil, 15, 15, 15, 15)
    bg:setSize(bgw + labelGap, bgh + labelGap*0.7)

    bg:addTo(self.sitHere_, 0)
    content:addTo(bg, 1)

    local line = new(Image, kImageMap.common_transparent_blank)
    local a = XYAnagle(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    local s = XYDistance(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    line:setSize(s)
    line:setPos(farPointPos[1] + 9, farPointPos[2] + 9)
    line:addPropRotateSolid(1, a, kCenterXY, 0, 0)
    line:addTo(self.sitHere_)

    local nearPoint = new(Image, kImageMap.room_newbie_guide_point)
    nearPoint:setPos(nearPointPos[1], nearPointPos[2])
    nearPoint:addTo(self.sitHere_,3)

    local farPoint = new(Image, kImageMap.room_newbie_guide_point)
    farPoint:setPos(farPointPos[1], farPointPos[2])
    farPoint:addTo(self.sitHere_,3)

	self:setLablePos("right",nearPoint,bg,content)
end

--提示进行操作，计时器
function RoomNewbieGuide:ROOM_GUIDE_HIDE_MAKE_OPERATION()
    if not nk.updateFunctions.checkIsNull(self.makeOperation_) then
        self.makeOperation_:removeFromParent()
        self.makeOperation_ = nil
        self.hasShow = true
    end

    self:ROOM_GUIDE_HIDE_OPERATION_BAR()
end

function RoomNewbieGuide:ROOM_GUIDE_SHOW_MAKE_OPERATION(data)
    local startPos = data.startPos
    local endPos = data.endPos
    if self:gameTotalCount() == 0 and not self.hasShow then
        if nk.updateFunctions.checkIsNull(self.makeOperation_) then
            self:createHintMakeOperation(startPos,endPos)
        else
            self.moNearPoint:setPos(startPos[1] - 9, startPos[2] - 9)
            self.moFarPoint:setPos(endPos[1] - 9, endPos[2] - 9)

            -- self.moline_:removeProp(1)
            local a = XYAnagle(endPos[1] - 9,endPos[2] - 9,startPos[1] - 9,startPos[2] - 9)
            local s = XYDistance(endPos[1] - 9,endPos[2] - 9,startPos[1] - 9,startPos[2] - 9)
            self.moline_:setSize(s)
            self.moline_:setPos(endPos[1], endPos[2])
            self.moline_:addPropRotateSolid(1, a, kCenterXY, 0, 0)
        end
    end
end

function RoomNewbieGuide:createHintMakeOperation(nearPointPos,farPointPos)
    self.makeOperation_ = new(Node)
    self.makeOperation_:addTo(self.ctx.scene.nodes.guideNode)

    local content = new(TextView, bm.LangUtil.getText("ROOM_NEWBIE_GUIDE", "MAKE_OPERATION"), 200, nil, kAlignLeft, nil, 18, 255, 255, 255)
    content:setAlign(kAlignLeft)
    content:setPos(30)

    local bgw, bgh = content:getSize()
    self.makeOperation_:setSize(bgw + labelGap, bgh + labelGap*0.5)

    local bg = new(Image, kImageMap.room_newbie_guide_bg, nil, nil, 15, 15, 15, 15)
    bg:setSize(bgw + labelGap, bgh + labelGap*0.7)

    bg:addTo(self.makeOperation_,0)
    content:addTo(bg,1)

    self.moline_ = new(Image, kImageMap.room_raise_split_line)
    local a = XYAnagle(farPointPos[1] - 9,farPointPos[2] - 9,nearPointPos[1] - 9,nearPointPos[2] - 9)
    local s = XYDistance(farPointPos[1] - 9,farPointPos[2] - 9,nearPointPos[1] - 9,nearPointPos[2] - 9)
    self.moline_:setSize(s)
    self.moline_:setPos(farPointPos[1], farPointPos[2])
    self.moline_:addPropRotateSolid(1, a, kCenterXY, 0, 0)
    self.moline_:addTo(self.makeOperation_)
    self.moline_:setVisible(false)

    self.moNearPoint = new(Image, kImageMap.room_newbie_guide_point)
    self.moNearPoint:setPos(nearPointPos[1] - 9, nearPointPos[2] - 9)
    self.moNearPoint:addTo(self.makeOperation_,3)
    self.moNearPoint:setVisible(false)

    self.moFarPoint = new(Image, kImageMap.room_newbie_guide_point)
    self.moFarPoint:setPos(farPointPos[1] - 9, farPointPos[2] - 9)
    self.moFarPoint:addTo(self.makeOperation_,3)
    self.moFarPoint:setVisible(false)

    self:setLablePos("topRight",self.moNearPoint,bg,content)
end

--提示自动跟注
function RoomNewbieGuide:ROOM_GUIDE_HIDE_AUTO_CALL()
    if not nk.updateFunctions.checkIsNull(self.autoCall_) then
        self.autoCall_:removeFromParent()
    end
end

function RoomNewbieGuide:ROOM_GUIDE_SHOW_AUTO_CALL(data)
    self:ROOM_GUIDE_HIDE_OPERATION_BAR()
    if self:gameTotalCount() <= 1 and nk.updateFunctions.checkIsNull(self.autoCall_) then
        self:createHintAutoCall(data.startPos,data.endPos)
    end
end

function RoomNewbieGuide:createHintAutoCall(nearPointPos,farPointPos)
    self.autoCall_ = new(Node)
    self.autoCall_:addTo(self.ctx.scene.nodes.guideNode)

    local content = new(TextView, bm.LangUtil.getText("ROOM_NEWBIE_GUIDE", "AUTO_CALL"), 200, nil, kAlignLeft, nil, 18, 255, 255, 255)
    content:setAlign(kAlignLeft)
    content:setPos(30)

    local bgw, bgh = content:getSize()
    self.autoCall_:setSize(bgw + labelGap, bgh + labelGap*0.5)

    local bg = new(Image, kImageMap.room_newbie_guide_bg, nil, nil, 15, 15, 15, 15)
    bg:setSize(bgw + labelGap, bgh + labelGap*0.7)

    bg:addTo(self.autoCall_,0)
    content:addTo(bg,1)

    local line = new(Image, kImageMap.room_raise_split_line)
    local a = XYAnagle(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    local s = XYDistance(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    line:setSize(s)
    line:setPos(farPointPos[1] + 9, farPointPos[2] + 9)
    line:addPropRotateSolid(1, a, kCenterXY, 0, 0)
    line:addTo(self.autoCall_)

    local nearPoint = new(Image, kImageMap.room_newbie_guide_point)
    nearPoint:setPos(nearPointPos[1], nearPointPos[2])
    nearPoint:addTo(self.autoCall_,3)

    local farPoint = new(Image, kImageMap.room_newbie_guide_point)
    farPoint:setPos(farPointPos[1], farPointPos[2])
    farPoint:addTo(self.autoCall_,3)

    self:setLablePos("top",nearPoint,bg,content)
end

--提示自动看/弃牌
function RoomNewbieGuide:ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD()
    if not nk.updateFunctions.checkIsNull(self.autoFold_) then
        self.autoFold_:removeFromParent()
    end
end

function RoomNewbieGuide:ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD(data)
    self:ROOM_GUIDE_HIDE_OPERATION_BAR()

    if self:gameTotalCount() <= 1 and nk.updateFunctions.checkIsNull(self.autoFold_) then
        self:createHintAutoFold(data.startPos,data.endPos)
    end
end

function RoomNewbieGuide:createHintAutoFold(nearPointPos,farPointPos)
    self.autoFold_ = new(Node)
    self.autoFold_:addTo(self.ctx.scene.nodes.guideNode)

    local content = new(TextView, bm.LangUtil.getText("ROOM_NEWBIE_GUIDE", "AUTO_CHECK_OR_FOLD"), 200, nil, kAlignLeft, nil, 18, 255, 255, 255)
    content:setAlign(kAlignLeft)
    content:setPos(30)

    local bgw, bgh = content:getSize()
    self.autoFold_:setSize(bgw + labelGap, bgh + labelGap*0.5)

    local bg = new(Image, kImageMap.room_newbie_guide_bg, nil, nil, 15, 15, 15, 15)
    bg:setSize(bgw + labelGap, bgh + labelGap*0.7)

    bg:addTo(self.autoFold_,0)
    content:addTo(bg,1)

    local line = new(Image, kImageMap.room_raise_split_line)
    local a = XYAnagle(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    local s = XYDistance(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    line:setSize(s)
    line:setPos(farPointPos[1] + 9, farPointPos[2] + 9)
    line:addPropRotateSolid(1, a, kCenterXY, 0, 0)
    line:addTo(self.autoFold_)

    local nearPoint = new(Image, kImageMap.room_newbie_guide_point)
    nearPoint:setPos(nearPointPos[1], nearPointPos[2])
    nearPoint:addTo(self.autoFold_,3)

    local farPoint = new(Image, kImageMap.room_newbie_guide_point)
    farPoint:setPos(farPointPos[1], farPointPos[2])
    farPoint:addTo(self.autoFold_,3)

    self:setLablePos("top",nearPoint,bg,content)
end

--提示自动跟任何注
function RoomNewbieGuide:ROOM_GUIDE_HIDE_AUTO_CALL_ANY()
    if not nk.updateFunctions.checkIsNull(self.autoCallAny_) then
        self.autoCallAny_:removeFromParent()
    end
end

function RoomNewbieGuide:ROOM_GUIDE_SHOW_AUTO_CALL_ANY(data)
    self:ROOM_GUIDE_HIDE_OPERATION_BAR()

    if self:gameTotalCount() <= 1 and nk.updateFunctions.checkIsNull(self.autoCallAny_) then
        self:createHintAutoCallAny(data.startPos,data.endPos)
    end
end

function RoomNewbieGuide:createHintAutoCallAny(nearPointPos,farPointPos)
    self.autoCallAny_ = new(Node)
    self.autoCallAny_:addTo(self.ctx.scene.nodes.guideNode)

    local content = new(TextView, bm.LangUtil.getText("ROOM_NEWBIE_GUIDE", "AUTO_CALL_ANY"), 200, nil, kAlignLeft, nil, 18, 255, 255, 255)
    content:setAlign(kAlignLeft)
    content:setPos(30)

    local bgw, bgh = content:getSize()
    self.autoCallAny_:setSize(bgw + labelGap, bgh + labelGap*0.5)

    local bg = new(Image, kImageMap.room_newbie_guide_bg, nil, nil, 15, 15, 15, 15)
    bg:setSize(bgw + labelGap, bgh + labelGap*0.7)

    bg:addTo(self.autoCallAny_,0)
    content:addTo(bg,1)

    local line = new(Image, kImageMap.room_raise_split_line)
    local a = XYAnagle(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    local s = XYDistance(farPointPos[1],farPointPos[2],nearPointPos[1],nearPointPos[2])
    line:setSize(s)
    line:setPos(farPointPos[1] + 9, farPointPos[2] + 9)
    line:addPropRotateSolid(1, a, kCenterXY, 0, 0)
    line:addTo(self.autoCallAny_)

    local nearPoint = new(Image, kImageMap.room_newbie_guide_point)
    nearPoint:setPos(nearPointPos[1], nearPointPos[2])
    nearPoint:addTo(self.autoCallAny_,3)

    local farPoint = new(Image, kImageMap.room_newbie_guide_point)
    farPoint:setPos(farPointPos[1], farPointPos[2])
    farPoint:addTo(self.autoCallAny_,3)

    self:setLablePos("top",nearPoint,bg,content)
end

--设置文本相对于近距离点的位置
function RoomNewbieGuide:setLablePos(direction,nearPoint,bg,label)
    local nearPointx, nearPointy = nearPoint:getPos()
    local nearPointw, nearPointh = nearPoint:getSize()
    local bgw, bgh = bg:getSize()
	if direction == "right" then
		bg:setPos(nearPointx - 5, nearPointy - bgh*0.5 + nearPointh*0.5)
    elseif direction == "topRight" then
        bg:setPos(nearPointx- 5, nearPointy - bgh + nearPointh)
    elseif direction == "top" then
        bg:setPos(nearPointx- 5, nearPointy - bgh*0.5 + nearPointh*0.5)
	end
end

--隐藏所有提示
function RoomNewbieGuide:ROOM_GUIDE_HIDE_ALL()
    self:ROOM_GUIDE_HIDE_SIT_HERE()
    self:ROOM_GUIDE_HIDE_MAKE_OPERATION()
    self:ROOM_GUIDE_HIDE_OPERATION_BAR()
end

--隐藏操作栏的提示
function RoomNewbieGuide:ROOM_GUIDE_HIDE_OPERATION_BAR()
    self:ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD()
    self:ROOM_GUIDE_HIDE_AUTO_CALL()
    self:ROOM_GUIDE_HIDE_AUTO_CALL_ANY()
end

function RoomNewbieGuide:hideOther(root)

end

function RoomNewbieGuide:gameTotalCount()
    return nk.userData.win + nk.userData.lose
end

return RoomNewbieGuide