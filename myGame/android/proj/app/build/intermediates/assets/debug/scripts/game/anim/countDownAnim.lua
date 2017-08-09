--CountDownAnim.lua
--2016/07/14
--此文件由[BabeLua]插件自动生成
--auther: FordFan
--endregion

local CountDownAnim = {};

CountDownAnim.circleScanShaders = require("libEffect.shaders.circleScan");
CountDownAnim.Default_time = 10000;
CountDownAnim.AnimPause = false;

-- root 父节点
-- time 倒计时时间
-- args = {
--   img,  倒计时图片
--   pos={x,y}, 倒计时图片相对于root的偏移
--   align,  对齐方式相对于root
-- }

function CountDownAnim.play(root, time, args, isSelf, parentX, parentY)
    CountDownAnim.removeAnim()

    if args then
        args.img = args.img or kImageMap.common_loading_icon
    else
        args = {}
        args.img = kImageMap.common_loading_icon
    end

    -- if CountDownAnim.img ~= args.img then
        CountDownAnim.img = args.img
        CountDownAnim.circle = new(Image, CountDownAnim.img)
        
    -- end

    if args.align then
        CountDownAnim.circle:setAlign(args.align)
    end

    if args.pos then
        CountDownAnim.circle:setPos(args.pos.x, args.pos.y)
    end

    CountDownAnim.circle:addTo(root)
    
    local view = CountDownAnim.circle;
    local animTime = time or CountDownAnim.Default_time;
    local repeatTime = animTime/360;
    -- FwLog(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>repeatTime = " .. repeatTime)
    repeatTime = math.max(repeatTime, 0)
    local R, G, B = 0, 249, 0;
    if view ~= nil then
        view:setVisible(true);
        local anim = new(AnimInt,kAnimRepeat,0,0,repeatTime,-1)
        CountDownAnim.anim = anim
        local config = {startAngle = 0,endAngle = 0, displayClickWiseArea = -1}
        local x, y = root:getAbsolutePos()
        local w, h = root:getSize()
        -- local clock = os.clock()
        anim:setEvent(nil, function()
            -- local cur = os.clock()
            -- FwLog(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> anim:onEvent" .. (cur - clock))
            -- clock = cur
            if tolua.isnull(root) then
                CountDownAnim.removeAnim()
                return
            end
            if CountDownAnim.AnimPause then return end
            if isSelf and nk.userData.win and nk.userData.lose and (nk.userData.win + nk.userData.lose) == 0 then
                --新手引导
                local sins = math.sin(math.rad(config.endAngle))
                local coss = -math.cos(math.rad(config.endAngle))
                local startPos = {(parentX or RoomViewPosition.SeatPosition[4].x) + 150, (parentY or RoomViewPosition.SeatPosition[4].y) + 20}
                local endPos = {x + w*0.5 + h*0.5*sins, y + h*0.5 + h*0.5*coss}
                Log.printInfo("CountDownAnim", config.endAngle)
                EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_SHOW_MAKE_OPERATION, {startPos = startPos,endPos = endPos})
            end
            CountDownAnim.circle:setColor(R,G,B)
            --在135度到180开始
            if config.endAngle > 135 and config.endAngle < 180 then
                 if  R < 255 then
                    R = math.floor((config.endAngle - 135) * (255/30));
                    if R > 255 then
                        R = 255;
                    end
                 else
                    G = math.floor(249 - (config.endAngle - 165) * (77/15) );
                 end
            -- 从 260开始 Green 172 - 52 达到红色
            elseif config.endAngle > 260 then
                   R = 255;
                   if G > 52 then
                       --剩下100度，其实80度用于色差变化。
                       G = math.floor( 172 -  (config.endAngle - 260) * (120/80) ); 
                       if G < 52 then G = 52 end;
                   end
            end
            config.endAngle = config.endAngle+1
            CountDownAnim.circleScanShaders.applyToDrawing(view,config)
            if config.endAngle - config.startAngle>=360 or config.endAngle-config.startAngle < 0 then
                if view then
                    view:setVisible(false);
                end
                CountDownAnim.removeAnim()
            end  
        end)
    end
end

function CountDownAnim.resume()
    CountDownAnim.AnimPause = false;

end

function CountDownAnim.pause()
    CountDownAnim.AnimPause = true;
end

function CountDownAnim.stop()
    CountDownAnim.removeAnim()
end

function CountDownAnim.removeAnim()
    if CountDownAnim.anim then
        delete(CountDownAnim.anim)
        CountDownAnim.anim = nil
    end 
    CountDownAnim.releaseCircle()
end

function CountDownAnim.releaseCircle()
    if CountDownAnim.circle then 
        -- CountDownAnim.circle:setVisible(false);
        -- CountDownAnim.circle:removeFromParent(true)
        delete(CountDownAnim.circle)
        CountDownAnim.circle = nil
    end
end

return CountDownAnim