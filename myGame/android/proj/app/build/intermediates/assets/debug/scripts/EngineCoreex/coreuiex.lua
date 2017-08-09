
-------fix core----------------

ResText.setText = function(self, str, width, height, r, g, b)
	if self.m_str == str and r == self.m_r and g == self.m_g and b == self.m_b then return end
    ResText.dtor(self);
    ResText.ctor(self,
    str or self.m_str,
    width or self.m_width,
    height or self.m_height,
    self.m_align,
    self.m_font,
    self.m_fontSize,
    r or self.m_r,
    g or self.m_g,
    b or self.m_b,
    self.m_multiLines);
end

-------fix ui----------------

EditText.setHintText = function(self, str, r, g, b)
    str = EditText.convert2SafePlatformString(self,str);

    local text = EditText.getText(self);
    self.m_hintText = str or EditText.s_hintText or EditText.s_defaultHintText;
    self.m_hintTextColorR = r or EditText.s_hintTextColorR or EditText.s_defaultHintTextColorR;
    self.m_hintTextColorG = g or EditText.s_hintTextColorG or EditText.s_defaultHintTextColorG;
    self.m_hintTextColorB = b or EditText.s_hintTextColorB or EditText.s_defaultHintTextColorB;
    
    if text == " " then
        EditText.setText(self,str);
    end
end

function event_ime_close_global(strNewValue, flag)

    if EditTextGlobal then
       EditTextGlobal:setVisible(true)
        EditTextGlobal.setText(EditTextGlobal,strNewValue);
        if (not strNewValue) or strNewValue == "" or strNewValue == EditTextGlobal.m_hintText then
            EditTextGlobal.setHintText(EditTextGlobal,EditTextGlobal.m_hintText, EditTextGlobal.m_hintTextColorR,EditTextGlobal.m_hintTextColorG,EditTextGlobal.m_hintTextColorB);
        else
            EditTextGlobal.setText(EditTextGlobal,strNewValue,nil,nil,EditTextGlobal.m_textColorR,EditTextGlobal.m_textColorG,EditTextGlobal.m_textColorB);
        end
        EditTextGlobal.onTextChange(EditTextGlobal);
    end
    EditTextGlobal = nil;
end

EditTextView.setHintText = function(self, str, r, g, b)
    str = EditTextView.convert2SafePlatformString(self,str);

    local text = EditTextView.getText(self);
    self.m_hintText = str or EditTextView.s_hintText or EditTextView.s_defaultHintText;
   -- FwLog("EditTextView.setHintText ex str = " .. str .. r .. g .. b)
    self.m_hintTextColorR = r or EditTextView.s_hintTextColorR or EditTextView.s_defaultHintTextColorR;
    self.m_hintTextColorG = g or EditTextView.s_hintTextColorG or EditTextView.s_defaultHintTextColorG;
    self.m_hintTextColorB = b or EditTextView.s_hintTextColorB or EditTextView.s_defaultHintTextColorB;
    
    if text == " " then
        EditTextView.setText(self,str);
    end
end

EditTextView.setText = function(self, str,width, height,r,g,b)
    self.m_textColorR = r or self.m_textColorR;
    self.m_textColorG = g or self.m_textColorG;
    self.m_textColorB = b or self.m_textColorB;
   
    if str == self.m_hintText then
        TextView.setText(self,str,width,height, self.m_hintTextColorR, self.m_hintTextColorG, self.m_hintTextColorB);
    else
        TextView.setText(self,str,width,height, self.m_textColorR, self.m_textColorG, self.m_textColorB);
    end
end

function event_ime_close_global_view(strNewValue, flag)

    if EditTextViewGlobal then
          EditTextViewGlobal:setVisible(true)
        EditTextViewGlobal.setText(EditTextViewGlobal,strNewValue);
        if (not strNewValue) or strNewValue == "" or strNewValue == EditTextViewGlobal.m_hintText then
            EditTextViewGlobal.setHintText(EditTextViewGlobal,EditTextViewGlobal.m_hintText, EditTextViewGlobal.m_hintTextColorR,EditTextViewGlobal.m_hintTextColorG,EditTextViewGlobal.m_hintTextColorB);
        else

            EditTextViewGlobal.setText(EditTextViewGlobal,strNewValue,nil,nil,EditTextViewGlobal.m_textColorR,EditTextViewGlobal.m_textColorG,EditTextViewGlobal.m_textColorB);
        end

        EditTextViewGlobal.onTextChange(EditTextViewGlobal);
    end
    EditTextViewGlobal = nil;
end

ScrollableNode.releaseScroller = function(self)
    if self.m_scroller then
        delete(self.m_scroller);
        self.m_scroller = nil;
    end
end

ScrollableNode.onScroll = function(self, scroll_status, diff, totalOffset, isMarginRebounding)
    if ScrollableNode.hasScrollBar(self) and (not isMarginRebounding) then
        self.m_scrollBar:setScrollPos(totalOffset);
        self.m_scrollBar:setVisible(true);
    end

    if kScrollerStatusStop == scroll_status then
        if ScrollableNode.hasScrollBar(self) then
            self.m_scrollBar:setVisible(false);
        end
    end
    --ugly , refactor later
    if isMarginRebounding then
        local align;
        if totalOffset >= 0 then
            if self.m_direction == kVertical then
                align = kAlignTop;
            else
                align = kAlignLeft;
            end
        else
            if self.m_direction == kVertical then
                align = kAlignBottom;
            else
                align = kAlignRight;
            end
        end
        if kScrollerStatusMoving == scroll_status and (not self.m_lastIsMarginRebouding) then
            if self.m_margrinReboudingCallback.func then
                self.m_margrinReboudingCallback.func(self.m_margrinReboudingCallback.obj,kScrollerStatusStart,align);
            end
        elseif kScrollerStatusStop == scroll_status then
            if self.m_margrinReboudingCallback.func then
                self.m_margrinReboudingCallback.func(self.m_margrinReboudingCallback.obj,kScrollerStatusStop,align);
            end
        end
    end
    self.m_lastIsMarginRebouding = isMarginRebounding;
end

ScrollBar.setScrollPos = function(self, scrollPos)
    self.m_scrollPos = scrollPos;

    scrollPos = -scrollPos;

    local posInFrame = scrollPos / self.m_viewLength * self.m_frameLength;
    local length = self.m_normalLength;

    if posInFrame < 0 then
        length = self.m_normalLength + posInFrame;
        length = length < self.m_smallestLength and self.m_smallestLength or length;
        posInFrame = 0;
    elseif posInFrame + self.m_normalLength > self.m_frameLength then
        length = self.m_frameLength - posInFrame;
        if length < self.m_smallestLength then
            posInFrame = self.m_frameLength - self.m_smallestLength;
            length = self.m_smallestLength;
        end
    end

    if self.m_direction == kVertical then
        ScrollBar.setPos(self,nil,self.m_startPos+posInFrame);
        ScrollBar.setSize(self,nil,length);
    else
        ScrollBar.setPos(self,self.m_startPos+posInFrame,nil);
        ScrollBar.setSize(self,length,nil);
    end

    -- ScrollBar.setVisible(self,true);
end

if DETECT_MEM_LEAK then
    local dict = {}
    setmetatable(dict, {__mode = "v"})
    local arrayForString = {}
    local baseCnt = 1

    local originNew = new
    function new(...)
        local o = originNew(...)

        if typeof(o, WidgetBase) then
            local info = debug.getinfo(2)
            local str = baseCnt .. ":" .. info.source .. ",line = " .. info.currentline
            dict[str] = o
            table.insert(arrayForString, str)
            baseCnt = baseCnt + 1

            -- if string.match(str, "swf.lua") then
            --     FwLog("new str 1 = " .. str)
            --     FwLog("new str 2 = " .. debug.getinfo(3).currentline)
            -- end
        end

        return o
    end

    local originDelete = delete
    function delete(o)
        if typeof(o, WidgetBase) then
            for k, v in ipairs(arrayForString) do
                if dict[v] and dict[v] == o then
                    -- FwLog("delete v = " .. v)
                    -- if string.match(v, "swf.lua") then
                        -- FwLog(debug.traceback())
                    -- end
                    table.remove(arrayForString, k)
                    break
                end
            end
        end
        originDelete(o)
    end

    function onDebugKeyDown(key)
        if key == 65 or key == 32 then
            -- lastArrayStrNil = {}
            FwLog("start to check the arrayForString:" .. #arrayForString)
            collectgarbage()
            for k, v in ipairs(arrayForString) do
                local isExist = true
                if not dict[v] then
                    -- FwLog("")
                    isExist = false
                    -- table.insert(lastArrayStrNil, v)
                    FwLog(v .. (isExist and ":true" or ":false ********************"))
                end
            end
            return
        end
    end
end