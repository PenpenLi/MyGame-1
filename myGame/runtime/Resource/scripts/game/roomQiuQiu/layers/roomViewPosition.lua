--
-- Author: tony
-- Date: 2014-07-08 20:11:05
--
local RoomViewPosition = {}
local P = RoomViewPosition

local cx, cy = 480, 300


    --         7    荷官    1   

    -- 6                            2
    
    --     5        4            3


-- 座位位置（8号位为荷官位置，打赏用到）
P.SeatPosition = {
    {x=623, y=4},
    {x=776, y=196},
    {x=653, y=378},
    {x=314, y=378},
    {x=100, y=378},
    {x=-10, y=196},
    {x=138, y=4},
    {x=500, y=100},
}

-- 发牌位置
P.DealCardPosition = {
    {x=P.SeatPosition[1].x + 140,    y=P.SeatPosition[1].y + 75}, 
    {x=P.SeatPosition[2].x + 140,    y=P.SeatPosition[2].y + 75}, 
    {x=P.SeatPosition[3].x + 140,    y=P.SeatPosition[3].y + 75}, 
    {x=P.SeatPosition[4].x + 140,    y=P.SeatPosition[4].y + 75}, 
    {x=P.SeatPosition[5].x + 30,    y=P.SeatPosition[5].y + 75}, 
    {x=P.SeatPosition[6].x + 30,    y=P.SeatPosition[6].y + 75}, 
    {x=P.SeatPosition[7].x + 30,    y=P.SeatPosition[7].y + 75},
}

--发牌开始位置（8号位为荷官位置）
P.DealCardStartPosition = {
    {x=465, y=157},
    {x=465, y=157},
    {x=465, y=157},
    {x=465, y=157},
    {x=465, y=157},
    {x=465, y=157},
    {x=465, y=157},
    {x=465, y=157},
}

-- dealer位置（没开局时dealer标志在8号位为荷官位置）
P.DealerPosition = {
    {x=694, y=166}, 
    {x=786, y=224}, 
    {x=754, y=382}, 
    {x=396, y=382},
    {x=185, y=382},
    {x=148, y=224},
    {x=245, y=166},
    {x=506, y=164}
}

-- lamp 针对每个座位的旋转值
P.LampRorate = {
    240,
    270,
    300,
    30,
    70,
    95,
    130,
}

-- lamp 针对每个座位的y缩放值
P.LampScale = {
    2.6,
    2.4,
    2,
    1.5,
    2.4,
    3.3,
    3.2,
}

local PotPosition = {
    n_2 = {
        {x = cx - 100, y = cy}, 
        {x = cx + 100, y = cy}, 
    },
    n_3 = {
        {x = cx - 150, y = cy}, 
        {x = cx, y = cy}, 
        {x = cx + 150, y = cy}, 
    },
    n_4 = {
        {x = cx - 160, y = cy + 20}, 
        {x = cx + 50, y = cy + 20}, 
        {x = cx - 50, y = cy - 50}, 
        {x = cx + 160, y = cy - 50}, 
    },
    n_5 = {
        {x = cx - 200, y = cy + 20},
        {x = cx, y = cy + 30},                  
        {x = cx + 200, y = cy + 20},                         
        {x = cx - 100, y = cy - 50},
        {x = cx + 100, y = cy - 50}, 
    },
    n_6 = {
        {x = cx - 250, y = cy + 20}, 
        {x = cx - 50 , y = cy + 20}, 
        {x = cx + 150, y = cy + 20},  
        {x = cx - 150, y = cy - 50}, 
        {x = cx + 50, y = cy - 50}, 
        {x = cx + 250, y = cy - 50},  
    }       
}

-- 桌子中间区域分割成n个放筹码的位置
-- 并返回第i个位置的坐标(1开始)
P.GetChipsPosition = function(n, i)
    local pos = {x = cx, y = cy}
    if n>= 2 and n<= 6 then
        pos = PotPosition["n_" .. n][i]
    end
    return pos
end

local RectBiger = { --(x:300-660  y:270-330)
    x1 = cx + (-180), 
    y1 = cy + (-30), 
    x2 = cx + (180), 
    y2 = cy + (30)
}
local RectSmall = { --(x:400-560 y:270-330)
    x1 = cx + (-80), 
    y1 = cy + (-30), 
    x2 = cx + (80), 
    y2 = cy + (30)
}
-- 在一个矩形区域内获得下注筹码的随机坐标
P.GetRandomPosition = function()
    local rect = math.random(0, 100) > 80 and RectBiger or RectSmall
    return {x=math.random(rect.x1, rect.x2), y=math.random(rect.y1, rect.y2)}
end 

P.GetSeatPostionNearBy = function(n)
    if P.SeatPosition[n] then
        return {x=P.SeatPosition[n].x+ 75+ math.random(-30, 30), y=P.SeatPosition[n].y+70  +  math.random(-30, 30)}
    end
    return {x=0,y=0}
end

return RoomViewPosition