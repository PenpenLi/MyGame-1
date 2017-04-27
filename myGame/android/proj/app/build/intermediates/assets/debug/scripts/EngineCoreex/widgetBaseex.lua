-- widgetBaseex.lua
-- Date: 2016-07-07
-- Last modification : 2016-07-07
-- Description: Implemented WidgetBase 

require("game.anim.transition");

---
-- @overwrite 设置可见性.
--
-- @param self
-- @param #boolean visible  visible为true，则widget在屏幕上可以看见，visible为false，则widget在屏幕上看不见。
local oldSetVisible = WidgetBase.setVisible
WidgetBase.setVisible = function(self, visible, isAutoVisible)
    oldSetVisible(self, visible)
    if not isAutoVisible then
        self.m_autoVisible = false
    end
end

---
-- @overwrite 从此widget内移除某个子节点，如果不需要清除子节点资源，则将子节点visible设置为false
--
-- @param self
-- @param #WidgetBase child 需要被移除的子节点。
-- @param #boolean doCleanup 是否需要对该child执行资源清除操作。
-- @param #boolean notAutoVisible 是否需要自动隐藏,true：不会自动隐; false or nil：自动隐藏. 默认自动隐藏
-- doCleanup为true，则会对child执行delete()操作，doCleanup为false则不会child执行delete()操作。

local oldRemoveChild = WidgetBase.removeChild
WidgetBase.removeChild = function(self, child, doCleanup, notAutoVisible)
    if doCleanup then
        child:removeAllProp()
    end
    local ret = oldRemoveChild(self, child, doCleanup, notAutoVisible)
    if not doCleanup and not notAutoVisible and child:getVisible() then
        -- 当被移除时，自动设置visible为false，当被添加时，再自动设置为true。当手动设置visible时，autoVisible将被设置为false
        child.m_autoVisible = true
        child:setVisible(false, true)
    end
    return ret == 0
end

---
-- 将自己从父节点中移除
--
-- @param self
-- @param #boolean doCleanup 是否需要对该child执行资源清除操作。
-- doCleanup为true，则会对child执行delete()操作，doCleanup为false则不会child执行delete()操作。
WidgetBase.removeFromParent = function(self, doCleanup)
    local parent = self:getParent()
    if parent then
    	parent:removeChild(self, doCleanup)
    end
end

---
-- @overwrite 添加子节点，将子节点设置为可见
--
-- @param self
-- @param #widget child 要添加的子节点
local oldAddChild = WidgetBase.addChild
WidgetBase.addChild = function(self, child)
    if not child then
        return
    end
    
    if child.m_parent then
        child.m_parent:removeChild(child, false, true);
    end
        
    local ret = child:setParent(self); 
    
    local index = #self.m_children+1;
    self.m_children[index] = child;
    self.m_rchildren[child] = index;

 
    if child.m_autoVisible then
        child:setVisible(true, true)
    end

    return ret;
end

---
-- 将自己添加到对应的节点
--
-- @param self
-- @param #widget parent 要添加的父节点
WidgetBase.addTo = function(self, parent)
    if parent then
    	parent:addChild(self)
    end
end

---
-- 移除自己所有的属性
--
-- @param self
WidgetBase.removeAllProp = function(self)
	self:stopAllActions()
    if not self.m_props then
        self.m_props = {}
    end
	for i, v in pairs(self.m_props) do 
		drawing_prop_remove(self.m_drawingID, i)
	end

	for i, v in pairs(self.m_props) do 
		delete(self.m_props[i]["prop"]);
		for _,v in pairs(self.m_props[i]["anim"]) do 
			delete(v);
		end
		self.m_props[i] = nil;
	end
end

---
-- 结合cocos,设置自身透明度
--
-- @param self
-- @param number opacity 透明度（0~255）
WidgetBase.opacity = function(self, opacity)
	if not opacity then
		opacity = 255
	end
    self:setTransparency(opacity/255)
end

---
-- 结合cocos,设置自身缩放值
--
-- @param self
-- @param number scale 缩放值（0~1）
WidgetBase.scale = function(self, scale)
    if not scale then
        scale = 1
    end
    self.m_width = self.m_width*scale
    self.m_height = self.m_height*scale
end

---
-- 设置自身灰度，从象棋中获取，此3.0引擎Lua库貌似去掉了这个接口
--
-- @param self
-- @param boolean isGray
WidgetBase.setGray = function(self, isGray)
    if isGray then
        self:setColor(128, 128, 128)
    else
        self:setColor(255, 255, 255)
    end
end

---
-- 获取自身的align值
--
-- @param self
-- @return number
WidgetBase.getAlign = function(self)
    return self.m_align or kAlignTopLeft;
end

-------------------------------------------- 动画相关 start ----------------------------------------
--- transtion 公共参数
-- time 动画时长
-- delay 延迟时长
-- onComplete 完成回调
-- needChange 移除动画后是否需要改变成动画结束的状态，默认为需要。不需要则设置false

---
-- private，添加动画，不建议手动调用
-- @param self
-- @param animType 动画类型
-- @param anim 动画属性对象
-- @param args 参考transtion的参数
WidgetBase.addAnim = function(self, animType, anim, args)
	if not self.m_anims then self.m_anims = {} end
    self.m_anims[args.sequence] = {}
	self.m_anims[args.sequence].anim = anim
	self.m_anims[args.sequence].args = args
	self.m_anims[args.sequence].animType = animType
end

---
-- 根据序列号移除动画
-- @param self
-- @param sequence 序列号
WidgetBase.removeAnimByS = function(self, sequence)
	if not self.m_anims then self.m_anims = {} end
	if self.m_anims[sequence] then
        self:doRemoveProp(sequence) -- removeProp will delete anim
        -- if self.m_anims[sequence].anim then
        --     -- delete(self.m_anims[sequence].anim)
        --     self.m_anims[sequence].anim = nil
        -- end
		self.m_anims[sequence] = nil
	end
end

---
-- 根据动画属性对象移除动画
-- @param self
-- @param anim 动画属性对象
WidgetBase.removeAnimByA = function(self, anim)
	if self.m_anims then
    	for i, v in pairs(self.m_anims) do
    		if v.anim == anim then
    		    self:doRemoveProp(i) -- removeProp will delete anim
                -- delete(v.anim)
    		    -- v = nil
                self.m_anims[i] = nil
            end
    	end
    end
end

---
-- 停止自身的全部动画
-- @param self
WidgetBase.stopAllActions = function(self)
	if self.m_anims then
    	for i, v in pairs(self.m_anims) do
    		self:doRemoveProp(i)
            --delete(v.anim)
    		self:afterAction(v.animType, v.args)
    		--v = nil
    	end
        self.m_anims = {}
    end
end

---
-- private，动作完成后的回调，不建议手动调用
-- @param self
-- @param animType 动画类型
-- @param args 参考transtion的参数
WidgetBase.afterAction = function(self, animType, args)
	if args.needChange == false then
		return
	end
	if animType == "rotateTo" then
		self:addPropRotateSolid(args.sequence, args.rotate, kCenterDrawing)
	elseif animType == "moveTo" then
		self:setPos(args.x, args.y)
	elseif animType == "fadeTo" then
		self:setTransparency(args.opacity)
	elseif animType == "scaleTo" then
		self:addPropScaleSolid(args.sequence, args.scaleX or 1, args.scaleY or 1)
	end
end

---
-- 将自己旋转至，部分参考transtion的参数
-- @param self
-- @param args 参考transtion的参数
-- args.rotate 旋转度数
WidgetBase.rotateTo = function(self, args)
    if not args then
        return
    end
    args.sequence = transition.getSequence()
    local anim = self:addPropRotate(args.sequence, kAnimNormal, args.time*1000, (args.delay or 0)*1000, 0, args.rotate, kCenterDrawing)
    self:addAnim("rotateTo", anim, args)
    if anim then
        anim:setEvent(nil, handler(self, function(obj)
            obj:removeAnimByS(args.sequence)
            if args.needChange ~= false then
            	obj:addPropRotateSolid(args.sequence, args.rotate, kCenterDrawing)
            end
            if args.onComplete then
                args.onComplete()
            end
        end))
    end
    return args.sequence
end

---
-- 将自己移动至，参考transtion的参数
-- @param self
-- @param args 参考transtion的参数
-- args.x, args.y 移动至相对于父节点的(x,y)
-- ** 平移属性移除后，x,y值是变化的
WidgetBase.moveTo = function(self, args)
    if not args then
        return
    end
    args.ox, args.oy = self:getPos()
    args.sequence = args.sequence or transition.getSequence()
    -- 传入的是距离差值
    if args.offset then
        args.x = (args.x or 0) + args.ox
        args.y = (args.y or 0) + args.oy
    else
        args.x = args.x or args.ox
        args.y = args.y or args.oy
    end
    local changex = args.x - args.ox
    local changey = args.y - args.oy
    if self.m_align == kAlignTopRight or self.m_align == kAlignRight or self.m_align == kAlignBottomRight then
        changex = -changex
    end
    if self.m_align == kAlignBottom or self.m_align == kAlignBottomLeft or self.m_align == kAlignBottomRight then
        changey = -changey
    end
    local anim = self:addPropTranslate(args.sequence, kAnimNormal, args.time*1000, (args.delay or 0)*1000, 0, changex, 0, changey)
    self:addAnim("moveTo", anim, args)
    if anim then
        anim:setEvent(nil, handler(self, function(obj)
            self:removeAnimByS(args.sequence)
            if args.needChange ~= false then
            	self:setPos(args.x, args.y)
            end
            if args.onComplete then
                args.onComplete()
            end
        end))
    end
    return args.sequence
end

---
-- 将自己曲线移动至，参考transtion的参数
-- @param self
-- @param args 参考transtion的参数
-- args.pos_t = {{x1,y1},{x2,y2}} 移动至相对于父节点的(x2,y2)，途中关键点x1,y1
-- ** 移动属性移除后，x,y值是变化的
WidgetBase.movesTo = function(self, args)
    if not args then
        return
    end
    args.ox, args.oy = self:getPos()
    args.sequence = transition.getSequence()

    local numArrayX = {}
    local numArrayY = {}

    -- 传入的是距离差值
    if args.offset then
        for i, v in ipairs(args.pos_t) do
            table.insert(numArrayX, v.x or 0)
            table.insert(numArrayY, v.y or 0)
        end
    else
        for i, v in ipairs(args.pos_t) do
            table.insert(numArrayX, ((v.x or args.ox) - args.ox))
            table.insert(numArrayY, ((v.y or args.oy) - args.oy))
        end
    end

    args.x = numArrayX[#numArrayX] + args.ox
    args.y = numArrayY[#numArrayY] + args.oy

    local numArrayX2 = {}
    local numArrayY2 = {}
    for i, v in ipairs(numArrayX) do
        -- v是相对于起始点的位移
        -- tdiffx, tdiffy是相对于上一个点的位移
        local tdiffx =  v - (numArrayX[i-1] or 0)
        local tdiffy =  numArrayY[i] - (numArrayY[i-1] or 0)

        local num = 40
        for j = num,  1, -1 do
            if tdiffx == 0 then
                table.insert(numArrayX2, (numArrayX[i-1] or 0))
            else
                table.insert(numArrayX2, v - (tdiffx/num)*(j-1))
            end
            if tdiffy == 0 then
                table.insert(numArrayY2, (numArrayY[i-1] or 0))
            else
                table.insert(numArrayY2, numArrayY[i] - (tdiffy/num)*(j-1))
            end
        end
    end

    table.foreach(numArrayX2, function(i,v)
            numArrayX2[i] = fix_pos_x(v)
            numArrayY2[i] = fix_pos_y(numArrayY2[i])
        end)

    local animResX = new(ResDoubleArray,numArrayX2)
    local animResY = new(ResDoubleArray,numArrayY2)

    local animx = new(AnimIndex,kAnimNormal,0,#(numArrayX2 or {})-1,args.time*1000,animResX,(args.delay or 0)*1000)
    animx:setDebugName("movesToAnimx")
    local animy = new(AnimIndex,kAnimNormal,0,#(numArrayY2 or {})-1,args.time*1000,animResY,(args.delay or 0)*1000)
    animy:setDebugName("movesToAnimy")
    local propTranslate = new(PropTranslate, animx, animy)

    self:doAddProp(propTranslate, args.sequence)
    self:addAnim("moveTo", anim, args)
    if animy then
        animy:setEvent(nil, function()
            if tolua.isnull(self) then
                FwLog(debug.traceback())
            end
            if self then
                self:removeAnimByS(args.sequence)
                if args.needChange ~= false then
                    self:setPos(args.x, args.y)
                end
            end
            -- delete(animx)
            -- delete(animy)
            -- delete(animResX)
            -- delete(animResY)
            if args.onComplete then
                args.onComplete()
            end
        end)
    end
    return args.sequence
end

---
-- 将自己渐入，参考transtion的参数
-- @param self
-- @param args 参考transtion的参数
WidgetBase.fadeIn = function(self, args)
    if not args then
        return
    end
    args.sequence = transition.getSequence()
    args.opacity = 1
    local anim = self:addPropTransparency(args.sequence, kAnimNormal, args.time*1000, (args.delay or 0)*1000, 0, 1)
    self:addAnim("fadeTo", anim, args)
    if anim then
        anim:setEvent(nil, handler(self, function(obj)
            obj:removeAnimByS(args.sequence)
            if args.needChange ~= false then
            	obj:setTransparency(1)
            end
            if args.onComplete then
                args.onComplete()
            end
        end))
    end
    return args.sequence
end

---
-- 将自己渐出，参考transtion的参数
-- @param self
-- @param args 参考transtion的参数
-- !!!!!不知道为什么，obj:setTransparency(0)在这里无效，所以在onComplete中设置不可见吧
WidgetBase.fadeOut = function(self, args)
    if not args then
        return
    end
    args.sequence = transition.getSequence()
    args.opacity = 0
    local anim = self:addPropTransparency(args.sequence, kAnimNormal, args.time*1000, (args.delay or 0)*1000, 1, 0)
    self:addAnim("fadeTo", anim, args)
    if anim then
        anim:setEvent(nil, handler(self, function(obj)
            obj:removeAnimByS(args.sequence)
            if args.needChange ~= false then
            	obj:setTransparency(0)
            end
            if args.onComplete then
                args.onComplete()
            end
        end))
    end
    return args.sequence
end

---
-- 将自己透明度变至，参考transtion的参数
-- @param self
-- @param args 参考transtion的参数
-- args.opacity 透明度（0~1）
WidgetBase.fadeTo = function(self, args)
    if not args then
        return
    end
    local opacity = args.opacity or 0
    if opacity < 0 then
        opacity = 0
    elseif opacity > 1 then
        opacity = 1
    end
    args.sequence = transition.getSequence()
    local anim = self:addPropTransparency(args.sequence, kAnimNormal, args.time*1000, (args.delay or 0)*1000, nil, opacity) -- 初始透明设为nil,待测是否报错
    self:addAnim("fadeTo", anim, args)
    if anim then
        anim:setEvent(nil, handler(self, function(obj)
            obj:removeAnimByS(args.sequence)
            if args.needChange ~= false then
            	obj:setTransparency(opacity)
            end
            if args.onComplete then
                args.onComplete()
            end
        end))
    end
    return args.sequence
end

---
-- 将自己缩放至，参考transtion的参数
-- @param self
-- @param args.scaleX，args.scaleY  x和y的缩放值
WidgetBase.scaleTo = function(self, args)
    if not args then
        return
    end
    args.sequence = transition.getSequence()
    args.scaleX = args.scaleX or 1
    args.scaleY = args.scaleY or 1
    local anim = self:addPropScale(args.sequence, kAnimNormal, args.time*1000, (args.delay or 0)*1000, args.srcX or 1, args.scaleX, args.srcY or 1, args.scaleY, kCenterDrawing)
    self:addAnim("scaleTo", anim, args)
    if anim then
        anim:setEvent(nil, handler(self, function(obj)
            obj:removeAnimByS(args.sequence)
            if args.needChange ~= false then
            	obj:addPropScaleSolid(args.sequence, args.scaleX, args.scaleY, kCenterDrawing)
            end
            if args.onComplete then
                args.onComplete()
            end
        end))
    end
    return args.sequence
end

-------------------------------------------- 动画相关 end ----------------------------------------