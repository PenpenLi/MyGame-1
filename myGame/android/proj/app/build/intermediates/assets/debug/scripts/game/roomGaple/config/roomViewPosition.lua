--
-- Author: tony
-- Date: 2014-07-08 20:11:05
--
local RoomViewPosition = {}
local P = RoomViewPosition

-- Log.printInfo("RoomViewPosition SCREENWIDTH=" .. SCREENWIDTH .. " SCREENHEIGHT=" .. SCREENHEIGHT)

-- local seat_w,seat_h = 160, 165

-- wScale_fix = LayoutScaleWidthFix
-- hScale_fix = LayoutScaleHeightFix

P.SeatPosRules = {
    --右上
    [1] = {align = kAlignTopRight, x = 20, y = 110},         -- 780 110       
    --右下（自己入座时的位置）
    [2] = {align = kAlignBottomRight, x = 20, y = 140},         -- 780 335
    --左下（别人入座时的位置）
    [3] = {align = kAlignBottomLeft, x = 20, y = 140},         -- 20 335
    --左上
    [4] = {align = kAlignTopLeft, x = 20, y = 110},         -- 20 110
    --左下（自己入座时的位置）
    [5] = {align = kAlignBottomLeft, x = 65, y = 15},         -- 65 460
}

-- 座位位置（共五个座位）
P.SeatPosition = {
    --右上
    -- Point((DESIGNWIDTH - 20)*wScale_fix - seat_w, 110*hScale_fix),
    -- --右下（自己入座时的位置）
    -- Point((DESIGNWIDTH - 20)*wScale_fix - seat_w, (DESIGNHEIGHT - 140)*hScale_fix -  seat_h),
    -- --左下（别人入座时的位置）
    -- Point(20*wScale_fix, (DESIGNHEIGHT - 140)*hScale_fix -  seat_h),
    -- -- Point(65*wScale_fix, (DESIGNHEIGHT - 15)*hScale_fix -  seat_h),
    -- --左上
    -- Point(20*wScale_fix, 110*hScale_fix),
    -- --左下（自己入座时的位置）
    -- Point(65*wScale_fix, (DESIGNHEIGHT - 15)*hScale_fix -  seat_h),
}

-- 发牌位置
P.DealCardPosition = {
    -- Point((P.SeatPosition[1].x + 40)*wScale_fix , (P.SeatPosition[1].y - 32)*hScale_fix), 
    -- Point((P.SeatPosition[2].x + 40)*wScale_fix , (P.SeatPosition[2].y - 32)*hScale_fix), 
    -- Point((P.SeatPosition[3].x + 40)*wScale_fix , (P.SeatPosition[3].y - 32)*hScale_fix), 
    -- Point((P.SeatPosition[4].x + 40)*wScale_fix , (P.SeatPosition[4].y - 32)*hScale_fix),

}

-- dealer位置（没开局时dealer标志在5号位为荷官位置）
P.DealerPosition = {
    -- Point((P.SeatPosition[1].x - 80)*wScale_fix , (P.SeatPosition[1].y)*hScale_fix), 
    -- Point((P.SeatPosition[2].x - 80)*wScale_fix , (P.SeatPosition[2].y)*hScale_fix), 
    -- Point((P.SeatPosition[3].x + 80)*wScale_fix , (P.SeatPosition[3].y)*hScale_fix), 
    -- Point((P.SeatPosition[4].x + 80)*wScale_fix , (P.SeatPosition[4].y)*hScale_fix),
    -- Point(DESIGNWIDTH/2*wScale_fix, (DESIGNHEIGHT/2 - 100)*hScale_fix)
}

-- 牌摆放在桌子上的范围
P.TableRangle = {
    -- -- x1 = 220*wScale_fix, y1 = 120*hScale_fix,
    -- -- x2 = (DESIGNWIDTH - 220)*wScale_fix, y2 = (DESIGNHEIGHT - 220)*hScale_fix,
    -- x1 = 420*wScale_fix, y1 = 220*hScale_fix,
    -- x2 = (DESIGNWIDTH - 420)*wScale_fix, y2 = (DESIGNHEIGHT - 320)*hScale_fix,
}




--[[
4   1
3   2
5
]]
P.LampRorate = {
    255,
    290,
    70,
    105,
    53,
}

return RoomViewPosition