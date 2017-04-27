
transition = {}

transition.sequence = 50

function transition.getSequence()
    transition.sequence = transition.sequence + 1
    return transition.sequence
end

--[[--

执行一个动作效果

~~~ lua

-- 等待 1.0 后开始移动对象
-- 耗时 1.5 秒，将对象移动到屏幕中央
-- 移动使用 backout 缓动效果
-- 移动结束后执行函数，显示 move completed
transition.execute(sprite, CCMoveTo:create(1.5, CCPoint(display.cx, display.cy)), {
    delay = 1.0,
    easing = "backout",
    onComplete = function()
        print("move completed")
    end,
})

~~~

transition.execute() 是一个强大的工具，可以为原本单一的动作添加各种附加特性。

transition.execute() 的参数表格支持下列参数：

-    delay: 等待多长时间后开始执行动作
-    easing: 缓动效果的名字及可选的附加参数，效果名字不区分大小写
-    onComplete: 动作执行完成后要调用的函数
-    time: 执行动作需要的时间

transition.execute() 支持的缓动效果：

-    backIn
-    backInOut
-    backOut
-    bounce
-    bounceIn
-    bounceInOut
-    bounceOut
-    elastic, 附加参数默认为 0.3
-    elasticIn, 附加参数默认为 0.3
-    elasticInOut, 附加参数默认为 0.3
-    elasticOut, 附加参数默认为 0.3
-    exponentialIn, 附加参数默认为 1.0
-    exponentialInOut, 附加参数默认为 1.0
-    exponentialOut, 附加参数默认为 1.0
-    In, 附加参数默认为 1.0
-    InOut, 附加参数默认为 1.0
-    Out, 附加参数默认为 1.0
-    rateaction, 附加参数默认为 1.0
-    sineIn
-    sineInOut
-    sineOut

@param CCNode target 显示对象
@param CCAction action 动作对象
@param table args 参数表格对象

@return mixed 结果 

]]
function transition.execute(trType, target, anim, args)
    assert(not tolua.isnull(target), "transition.execute() - target is not CCNode")
    assert(not tolua.isnull(anim), "transition.execute() - anim is not CCNode")
    anim:setEvent(nil, handler(target, function(obj)
        if trType == "rotateTo" then
            target:addPropRotateSolid(args.sequence, args.rotate, kCenterDrawing)
        elseif trType == "moveTo" then
            target:setPos(args.x, args.y)
        elseif trType == "fadeIn" then

        elseif trType == "fadeOut" then

        elseif trType == "scaleTo" then
            target:addPropScaleSolid(args.sequence, args.scaleX, args.scaleY)
        elseif trType == "fadeTo" then

        end
        obj:removeProp(args.sequence)
        if args and args.onComplete then
            args.onComplete()
        end
    end))
end

--[[--
将显示对象旋转到指定角度，并返回 CCAction 动作对象。

~~~ lua

-- 耗时 0.5 秒将 sprite 旋转到 180 度
transition.rotateTo(sprite, {rotate = 180, time = 0.5})

~~~

@param CCNode target 显示对象
@param table args 参数表格对象

@return mixed 结果

]]
function transition.rotateTo(target, args)
    -- assert(not tolua.isnull(target), "transition.rotateTo() - target is not CCNode")
    if not tolua.isnull(target) then
        return target:rotateTo(args)
    end
end

--[[--

将显示对象移动到指定位置，并返回 CCAction 动作对象。

~~~ lua

-- 移动到屏幕中心
transition.moveTo(sprite, {x = display.cx, y = display.cy, time = 1.5})
-- 移动到屏幕左边，不改变 y
transition.moveTo(sprite, {x = display.left, time = 1.5})
-- 移动到屏幕底部，不改变 x
transition.moveTo(sprite, {y = display.bottom, time = 1.5})

~~~

@param CCNode target 显示对象
@param table args 参数表格对象

@return mixed 结果

]]
function transition.moveTo(target, args)
    if not tolua.isnull(target) then
        return target:moveTo(args)
    end
end

--[[

淡入显示对象，并返回 CCAction 动作对象。 

fadeIn 操作会首先将对象的透明度设置为 0（0%，完全透明），然后再逐步增加为 255（100%，完全不透明）。

如果不希望改变对象当前的透明度，应该用 fadeTo()。 

~~~ lua

action = transition.fadeIn(sprite, {time = 1.5})

~~~

@param CCNode target 显示对象
@param table args 参数表格对象

@return mixed 结果

]]
function transition.fadeIn(target, args)
    -- assert(not tolua.isnull(target), "transition.fadeIn() - target is not CCNode")
    if not tolua.isnull(target) then
        return target:fadeIn(args)
    end
end

--[[

淡出显示对象，并返回 CCAction 动作对象。

fadeOut 操作会首先将对象的透明度设置为 255（100%，完全不透明），然后再逐步减少为 0（0%，完全透明）。

如果不希望改变对象当前的透明度，应该用 fadeTo()。 

~~~ lua

action = transition.fadeOut(sprite, {time = 1.5})

~~~

@param CCNode target 显示对象
@param table args 参数表格对象

@return mixed 结果

]]
function transition.fadeOut(target, args)
    -- assert(not tolua.isnull(target), "transition.fadeOut() - target is not CCNode")
    if not tolua.isnull(target) then
        return target:fadeOut(args)
    end
end

--[[--

将显示对象的透明度改变为指定值，并返回 CCAction 动作对象。 

~~~ lua

-- 不管显示对象当前的透明度是多少，最终设置为 128
transition.fadeTo(sprite, {opacity = 128, time = 1.5})

~~~

@param CCNode target 显示对象
@param table args 参数表格对象

@return mixed 结果

]]
function transition.fadeTo(target, args)
    -- assert(not tolua.isnull(target), "transition.fadeTo() - target is not CCNode")
    if not tolua.isnull(target) then
        return target:fadeTo(args)
    end
end

--[[--

将显示对象缩放到指定比例，并返回 CCAction 动作对象。

~~~ lua

-- 整体缩放为 50%
transition.scaleTo(sprite, {scale = 0.5, time = 1.5})
-- 单独水平缩放
transition.scaleTo(sprite, {scaleX = 0.5, time = 1.5})
-- 单独垂直缩放
transition.scaleTo(sprite, {scaleY = 0.5, time = 1.5})

~~~

@param CCNode target 显示对象
@param table args 参数表格对象

@return mixed 结果

]]
function transition.scaleTo(target, args)
    -- assert(not tolua.isnull(target), "transition.scaleTo() - target is not CCNode")
    if not tolua.isnull(target) then
        return target:scaleTo(args)
    end
end