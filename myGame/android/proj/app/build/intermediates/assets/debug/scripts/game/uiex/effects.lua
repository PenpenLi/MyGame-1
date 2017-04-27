-- effects.lua
-- Last modification : 2016-06-08
-- Description: all effects to use
-- 特效使用方法

Effects = {}

local stencilMask = require 'libEffect.shaders.stencilMask'
local grayScale = require 'libEffect.shaders.grayScale'

-------------------------------- static function -----------------------------
---
-- 设置drawing遮罩
-- @param #WidgetBase drawing 被遮罩的drawing
-- @param string maskFile 遮罩的图片路径
-- @param table posConfig {x,y,w,h} 相对于drawing的位置，若为nil则根据drawing的位置设置maskDrawing的位置
-- @param #WidgetBase parent 
Effects.setMask = function(drawing, maskFile, pos, parent)
    local oldParent = drawing:getParent()

    local oldX, oldY = drawing:getPos()
    local oldW, oldH = drawing:getSize()
    local oldAlign = drawing:getAlign()

    if not pos then pos = {x=0, y=0, w=oldW, h=oldH}end
    
    local maskDrawing = new(Image, maskFile)
    maskDrawing:setAlign(oldAlign)
    maskDrawing:setSize(pos.w, pos.h)
    maskDrawing:setPos(oldX + pos.x, oldY + pos.y)
    
    parent = parent or oldParent
    stencilMask.applyToDrawing(parent, drawing, maskDrawing)
end

---
-- 设置drawing灰度
-- @param #WidgetBase drawing 设置灰度的drawing
-- @param number value 灰度值0~1，1为原色，0为灰色
Effects.setGray = function(drawing, value)
    if type(value) ~= "number" then
        value = 1
    end
    grayScale.applyToDrawing(drawing, {intensity=value})
end