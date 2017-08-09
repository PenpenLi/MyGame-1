--
-- Author: melon
-- Date: 2016-11-04 18:45:34
--
local oldctor= Text.ctor
Text.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b)
    oldctor(self, str, width, height, align, fontName, fontSize, r, g, b)
    self:setColor(r,g,b)
end

local oldSetText = Text.setText
Text.setText = function(self, str, width, height, r, g, b)
    if not tolua.isnull(self) then
        local r1,g1,b1 = self:getColor()
        r = r or r1
        g = g or g1
        b = b or b1
        oldSetText(self, str, width, height, r, g, b)
    end
end

local s_oldEditTextViewDtor = EditTextView.dtor
EditTextView.dtor = function(self)
	if EditTextViewGlobal == self then
		EditTextViewGlobal = nil
	end
    s_oldEditTextViewDtor(self)
end