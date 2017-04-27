
--
-- Author: shanks
-- Date: 2014.09.09
--

local TimeUtil = class()

function TimeUtil:ctor()
    
end

-- 将一个时间数转换成"00:00"格式
function TimeUtil:getTimeString(timeInt)
    if not timeInt or (tonumber(timeInt) <= 0) then
        return "00:00"
    else
        return string.format("%02d:%02d", math.floor((timeInt/60)%60), timeInt%60)
    end
end

-- 将一个时间数转换成"00:00:00"格式
function TimeUtil:getTimeString1(timeInt)
    if not timeInt or (tonumber(timeInt) <= 0) then
        return "00:00:00"
    else
        return string.format("%02d:%02d:%02d", math.floor(timeInt/(60*60)), math.floor((timeInt/60)%60), timeInt%60)
    end
end

-- 将一个时间数转换成"00"分格式
function TimeUtil:getTimeMinuteString(timeInt)
    if not timeInt or (tonumber(timeInt) <= 0) then
        return "00"
    else
        return string.format("%02d", math.floor((timeInt/60)%60))
    end
end

-- 将一个时间数转换成"00“秒格式
function TimeUtil:getTimeSecondString(timeInt)
    if not timeInt or (tonumber(timeInt) <= 0) then
        return "00"
    else
        return string.format("%02d", timeInt%60)
    end
end

function TimeUtil:getRemainHour(timeInt)
    if not timeInt or (tonumber(timeInt) <= 0) then
        return 0
    else
        return math.floor((timeInt/3600))
    end
end

function TimeUtil:getRemainDay(timeInt)
    if not timeInt or (tonumber(timeInt) <= 0) then
        return 0
    else
        return math.ceil((timeInt/3600/24))
    end
end

return TimeUtil