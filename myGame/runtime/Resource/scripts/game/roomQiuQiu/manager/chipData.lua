--
-- Author: johnny@boomegg.com
-- Date: 2014-07-18 17:21:23
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ChipData = class()

function ChipData:ctor(spriteName, key, type)
    self:newChipSprite(spriteName, key, type)

    self.rankIndex = 0
end

-- spriteName:筹码图片路径
-- key:筹码数量
-- type:筹码图标类型-方形(true)/圆形(false)
function ChipData:newChipSprite(spriteName, key, type)
    if self.sprite_ then
        self.sprite_:setFile(spriteName)
    else
        self.sprite_ = new(Image, spriteName)
    end
    self.key_ = key
    self.type_ = type
    return self
end

function ChipData:getSprite()
    return self.sprite_
end

function ChipData:getKey()
    return self.key_
end

function ChipData:getType()
	return self.type_
end

function ChipData:dtor()
	if self.sprite_ then
    	delete(self.sprite_)
        self.sprite_ = nil
	end
    self.key_ = nil
end

--在各自的筹码柱中的索引，10个一柱
function ChipData:setRankIndex(index)
    self.rankIndex = index
end

function ChipData:getRankIndex()
    return self.rankIndex
end

return ChipData