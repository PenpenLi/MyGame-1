
LabelEx = class();
----------------------------public--------------------------------
--text
LabelEx.setText = function(p_labelHandle,p_value,p_which)
    LabelEx.__setProp(p_labelHandle,'text',p_value,p_which);
end

LabelEx.getText = function(p_labelHandle,p_value,p_which)
    return LabelEx.__getProp(p_labelHandle,'text',p_which);
end

--size
LabelEx.setFontSzie = function(p_labelHandle,p_value,p_which)
    LabelEx.__setProp(p_labelHandle,'size',p_value,p_which);
end

LabelEx.getFontSize = function(p_labelHandle,p_value,p_which)
    return LabelEx.__getProp(p_labelHandle,'size',p_which);
end

--color
LabelEx.setFontColor = function(p_labelHandle,p_value,p_which)
    LabelEx.__setProp(p_labelHandle,'color',p_value,p_which);
end

LabelEx.getFontColor = function(p_labelHandle,p_value,p_which)
    return LabelEx.__getProp(p_labelHandle,'color',p_which);
end

----------------------------private-------------------------------
LabelEx.__checkType = function(p_labelHandle)
    if type(p_labelHandle) ~= 'userdata' then
        return false;
    end

    if tostring(p_labelHandle.___type) ~= 'class(Label)' then
        return false;
    end
    
    return true;
end

--设置属性
LabelEx.__setProp = function(p_labelHandle,p_prop,p_value,p_which)
                                               --p_which  默认为1 
   
    if not (LabelEx.__checkType(p_labelHandle)) then
        return;
    end

    if type(p_prop) ~= 'string' then
        return;
    end

    if type(p_value) == 'nil' then
        return;
    end

    if type(p_which) ~= 'number' then
        p_which = 1;
    end

    local _configData = p_labelHandle:get_data();
    _configData[p_which][p_prop] = p_value;
    p_labelHandle:set_data(_configData);

end

--得到属性
LabelEx.__getProp = function(p_labelHandle,p_prop,p_which)
                                               --p_which  默认为1 
   
    if not (LabelEx.__checkType(p_labelHandle)) then
        return;
    end

    if type(p_prop) ~= 'string' then
        return;
    end

    if type(p_which) ~= 'number' then
        p_which = 1;
    end
    
    local _configData = p_labelHandle:get_data();
   return  rawget(_configData[p_which],p_prop);
end
