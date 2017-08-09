--
-- Author: Jackie
-- Date: 2015-09-15 16:50:29
--
local ChipData = import("game.roomQiuQiu.manager.chipData")

local ChipsSpriteConfig = class()

--筹码额度(圆形+方形)
local NBase = {
        [1]           = "n_1",
        [2]           = "n_2",
        [5]           = "n_5",
        [10]          = "n_10",
        [20]          = "n_20",
        [50]          = "n_50",
        [100]         = "n_100",
        [200]         = "n_200",
        [500]         = "n_500",
        [1000]        = "n_1k",
        [2000]        = "n_2k",
        [5000]        = "n_5k",
        [10000]       = "n_10k",
        [20000]       = "n_20k",
        [50000]       = "n_50k",
        [100000]      = "n_100k",
        [200000]      = "n_200k",
        [500000]      = "n_500k", 
        [1000000]     = "n_1m",
        [2000000]     = "n_2m",  
        [5000000]     = "n_5m",      
        [10000000]    = "n_10m",    
        [20000000]    = "n_20m",     
        [50000000]    = "n_50m",    
        [100000000]   = "n_100m",   
        [200000000]   = "n_200m",   
        [500000000]   = "n_500m",  
        [1000000000]  = "n_1b",      
        [2000000000]  = "n_2b",      
        [5000000000]  = "n_5b",      
        [10000000000] = "n_10b",     
        [50000000000] = "n_50b",   
}

local NBase_ = {
    [1000000]       = "n_1m_",
    [2000000]       = "n_2m_",
    [5000000]       = "n_5m_",
    [10000000]      = "n_10m_",
    [20000000]      = "n_20m_",
    [50000000]      = "n_50m_",
    [100000000]     = "n_100m_",
    [200000000]     = "n_200m_",
    [500000000]     = "n_500m_",
    [1000000000]    = "n_1b_",  
    [2000000000]    = "n_2b_",       
    [5000000000]    = "n_5b_",       
    [10000000000]   = "n_10b_",      
    [50000000000]   = "n_50b_",      
    [100000000000]  = "n_100b_",     
    [200000000000]  = "n_200b_",     
    [500000000000]  = "n_500b_",
}

-- 使用方形筹码的场次范围
local NPlace = {
	{ante = 5000000000, value = 100000000000},
	{ante = 500000000, value = 10000000000},
	{ante = 50000000, value = 1000000000},
	{ante = 1000000, value = 100000000},
	{ante = 200000, value = 10000000},
	{ante = 0, value = 1000000},
}

-- ante:房间底筹
function ChipsSpriteConfig:ctor(ante)  
	self.ante = ante or 0
    -- self.chipDataPool_ = {}
    self.chipKeys_ = table.keys(NBase)
    table.sort(self.chipKeys_, function(a, b)
        return a < b
    end)
end

-- 获得对象
function ChipsSpriteConfig:retrive(spriteName, key, type)
    local chipData
    chipData = new(ChipData, spriteName, key, type)
    return chipData
end

--获取场次的最小方形筹码
function ChipsSpriteConfig:getMinRectValue()
	for i,v in ipairs(NPlace) do
		if self.ante >= v.ante then
			return v.value
		end
	end
end

-- 从对象池获取筹码数据,数字转筹码
function ChipsSpriteConfig:getChipData(chips, chipDataArr)
    print(">>> ChipManager => getChipData", chips)
    chipDataArr = chipDataArr or {}
	-- 获取指定单位的筹码,chips筹码值，unit筹码货币值
    local function getChipByType(chips, unit, targetArr)
	    chips = chips or 0
	    targetArr = targetArr or {}

	    local minValue = self:getMinRectValue()    --当前场次的最小方形筹码值
	    local n = math.floor(chips / unit)         --当前币值最多取几个
	    local index = #targetArr                   --为了让方形筹码放后面，圆形筹码插入放前面
        local chipData
	    for i=1, n do
	    	if unit >= minValue then      --当前币值用方形
                chipData = self:retrive(kImageMap["chip_" .. string.gsub(NBase_[unit], "n_", "")], unit, true)
	        	table.insert(targetArr, chipData)
	        else        --当前币值用圆形
                chipData = self:retrive(kImageMap["chip_" .. string.gsub(NBase[unit], "n_", "")], unit, false)
	        	index = index + 1
	        	table.insert(targetArr, index, chipData)
	    	end
	    end
	    return targetArr 
    end

    local n = #self.chipKeys_
    local key
    for i = n, 1, -1 do
        key = self.chipKeys_[i]
        if chips >= key then
            chipDataArr = getChipByType(chips, key, chipDataArr) 
            chips = chips % key      --取余就是剩余值
        end
        if chips <=0 then
            break
        end
    end
    return chipDataArr
end


function ChipsSpriteConfig:getChipDataFromArr(chipDataArr,value)
    local arr = {}
    if type(value) == "number" then
        arr = self:getChipDataFromExistArr(chipDataArr,value)
    elseif type(value) == "table" and #value > 0 then
        for k,v in ipairs(value) do
            table.insertto(arr,self:getChipDataFromExistArr(chipDataArr,v))
        end
        if #arr > 1 then
            table.sort(arr, function(a, b)
                return a:getKey() and b:getKey() and a:getKey() > b:getKey()
            end)
        end
    end
    return arr
end

-- 从一堆筹码中分离出一定数额的筹码
-- chipDataArr已经创建的，chips目标数额
function ChipsSpriteConfig:getChipDataFromExistArr(chipDataArr, chips)
    table.sort(chipDataArr, function(a, b)
        return a:getKey() > b:getKey()
    end)
    local arr = {}
    local tempChip
    local nLen, pos
    while chips > 0 do
        nLen = #chipDataArr
        pos = 1
        for i = 1, nLen do
            pos = i
            if chips >= chipDataArr[i]:getKey() then
                break
            end
        end
        tempChip = table.remove(chipDataArr, pos)
        --先把小额的用光了，在用大额的找零
        if tempChip then
            if chips >= tempChip:getKey() then
                table.insert(arr, tempChip)
                chips = chips - tempChip:getKey()
            else
                local a1 = self:getChipData(chips)
                local a2 = self:getChipData(tempChip:getKey() - chips)
                for k, v in pairs(a1) do
                    table.insert(arr, v)
                    local sp = v:getSprite()
                    sp:setPos(tempChip:getSprite():getPos())
                end
                for k, v in pairs(a2) do
                    table.insert(chipDataArr, v)
                    local sp = v:getSprite()
                    sp:setPos(tempChip:getSprite():getPos())                    
                end
                if #chipDataArr > 1 then
                    table.sort(chipDataArr, function(a, b)
                        return a:getKey() and b:getKey() and a:getKey() < b:getKey()
                    end)
                end
                chips = 0
                local sp = tempChip:getSprite()
                sp:removeFromParent(true)
                self:recycleChipData({tempChip})
            end
        else
            chips = 0
        end
    end
    return arr
end

-- 是否存在矩形筹码
function ChipsSpriteConfig:existRectChipCount(chipDataArr)
    local count = 0
    for _, chipData in pairs(chipDataArr) do
        if chipData:getType() then
            count = count + 1
        end
    end
    return count
end

-- 回收筹码数据
function ChipsSpriteConfig:recycleChipData(chipDataArr)
    if chipDataArr then
        for _, chipData in pairs(chipDataArr) do
            local sp = chipData:getSprite()
            if not tolua.isnull(sp) then
                sp:removeAllProp()
                sp:removeFromParent(true)
            end 
        end
    end
end

function ChipsSpriteConfig:dtor()
    self.chipKeys_ = nil
end

return ChipsSpriteConfig