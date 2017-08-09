local easing = require("libEffect.easing")

local EaseMoveAnim = class()

EaseMoveAnim.ctor = function()
    
end

EaseMoveAnim.move = function(self, node, xMove, yMove, xStart, xOffset, yStart, yOffset, moveTime, delayTime, sequence, animType, callback)
	self.m_table_H = {}
	self.m_sequence = sequence or 0
    self.m_animIndex = nil
    self.m_node = node
    self.m_callback = callback

    self:stopMove()   

	local dataTime_H 
	if xMove then
		dataTime_H = easing.getEaseArray(animType, moveTime, xStart, xOffset)
	    self.m_table_H.resTime_H = new(ResDoubleArray, dataTime_H)
    	self.m_table_H.animTime_H = new(AnimIndex, kAnimNormal, 0, #dataTime_H - 1, moveTime, self.m_table_H.resTime_H, delayTime)
        self.m_animIndex = self.m_table_H.animTime_H
	end

    local dataBend_H
    if yMove then
	    dataBend_H = easing.getEaseArray(animType, moveTime, yStart, yOffset)
	    self.m_table_H.resBend_H = new(ResDoubleArray, dataBend_H)
    	self.m_table_H.animBend_H = new(AnimIndex, kAnimNormal, 0, #dataBend_H - 1, moveTime, self.m_table_H.resBend_H, delayTime)
        self.m_animIndex = self.m_table_H.animBend_H
	end

    self.m_table_H.propTranslate = new(PropTranslate, self.m_table_H.animTime_H, self.m_table_H.animBend_H)
    node:doAddProp(self.m_table_H.propTranslate, self.m_sequence)

    self.m_animIndex:setEvent(self,self.releaseAnim)
end

EaseMoveAnim.releaseAnim = function(self)
    self:stopMove()
    if self.m_callback then
        self.m_callback()
    end
end

EaseMoveAnim.stopMove = function(self)
	self.m_node:doRemoveProp(self.m_sequence)

    -- delete(self.m_table_H.propTranslate)

    -- delete(self.m_table_H.animBend_H) 
    -- delete(self.m_table_H.animTime_H) 

    -- delete(self.m_table_H.resBend_H) 
    -- delete(self.m_table_H.resTime_H)  
end

return EaseMoveAnim