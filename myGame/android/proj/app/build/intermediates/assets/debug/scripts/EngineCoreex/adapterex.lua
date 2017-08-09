-- adapter.lua
-- Date: 2016-07-07
-- Last modification : 2016-07-07
-- Description: Implemented Adapter

---
-- Override @{core.adapter#Adapter.getView}.
-- 创建子View的时候，增加一个index参数
-- 
Adapter.getView = function(self, index)
    if not self.m_data[index] then
        return nil;
    end
	local view =  new(self.m_view,self.m_data[index], index);
	return view;
end