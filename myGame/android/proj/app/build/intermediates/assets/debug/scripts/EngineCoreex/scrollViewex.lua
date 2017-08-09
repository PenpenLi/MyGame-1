-- scrollViewex.lua
-- Date: 2016-07-02
-- Last modification : 2016-07-02
-- Description: Implemented ScrollViewex 

ScrollView.setFloatLayout = function(self, status)
    self.m_floatLayout = status
end

---
-- Override @{core.drawing#DrawingBase.addChild}.
-- 增加floatLayout判断，是否自动流排列
-- 
-- @param self
-- @param child 子节点对象。详见： @{core.drawing#DrawingBase.addChild}.
ScrollView.addChild = function(self, child)
    self.m_mainNode:addChild(child);

    if self.m_autoPositionChildren then
    	child:setAlign(kAlignTopLeft);
        local w,h = child:getSize();
    	if self.m_floatLayout then
            if self.m_nodeH == 0 then
                self.m_nodeH = h;
            end
            child:setPos(self.m_nodeW,self.m_nodeH - h);
	    	if self.m_nodeW + 2*w > self.m_width then
	    		self.m_nodeW = 0
                self.m_nodeH = self.m_nodeH + h;
	    	else
	    		self.m_nodeW = self.m_nodeW + w
	    	end
	    else
            child:setPos(self.m_nodeW,self.m_nodeH);
	        if self.m_direction == kVertical then
	            self.m_nodeH = self.m_nodeH + h;
	        else
	            self.m_nodeW = self.m_nodeW + w;
	        end
	    end
    else
        local x,y = child:getUnalignPos();
        local w,h = child:getSize();

        if self.m_direction == kVertical then
            self.m_nodeH = (self.m_nodeH > y + h) and self.m_nodeH or (y + h);
        else
            self.m_nodeW = (self.m_nodeW > x + w) and self.m_nodeW or (x + w);
        end
    end

    ScrollView.update(self);
end

