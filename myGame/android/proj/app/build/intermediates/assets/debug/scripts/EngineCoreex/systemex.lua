---
-- 获得宽的适配缩放比例.
--
-- @return #number 适配缩放比例。
System.getLayoutScaleWidth = function()
    return System.getScreenWidth() / System.getLayoutWidth();
end

---
-- 获得高的适配缩放比例.
--
-- @return #number 适配缩放比例。
System.getLayoutScaleHeight = function()
    return System.getScreenHeight() / System.getLayoutHeight();
end

---
-- 获得宽的矫正缩放比例.
--
-- @return #number 适配缩放比例。
System.getLayoutScaleWidthFix = function()
    local scale = System.getLayoutScale()
    if scale == System.getLayoutScaleWidth() then
      return 1
    else
      return System.getLayoutScaleWidth()/scale
    end
end

---
-- 获得高的矫正缩放比例.
--
-- @return #number 适配缩放比例。
System.getLayoutScaleHeightFix = function()
    local scale = System.getLayoutScale()
    if scale == System.getLayoutScaleHeight() then
      return 1
    else
      return System.getLayoutScaleHeight()/scale
    end
end