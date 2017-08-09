

local GirlEyesAnim = class(Node)

function GirlEyesAnim:ctor(parent)
	self.index = 0
	self.m_node = new(Node)
	self.m_node:setAlign(kAlignTop)
	parent:addChild(self.m_node)
	self.m_eyes = new(Image,"res/hall/hall_girl_eyes_2.png")
	self.m_eyes:setAlign(kAlignTop)
	self.m_node:addChild(self.m_eyes)
	self.m_node:setVisible(false)
end

function GirlEyesAnim:startEyesAnim()
	nk.GCD.Cancel(self)
	nk.GCD.PostDelay(self, function()
		self.m_node:setVisible(false)
		local index = self.index%100 + 1 
		if index == 1 or index == 2 then
			self.m_node:setVisible(true)
			local file = string.format("res/hall/hall_girl_eyes_%d.png",index)
        	self.m_eyes:setFile(file)
        end
        self.index = self.index + 1
        if self.index >= 1000 then
        	self.index = 0
        end
    end, nil, 50, true)
end

function GirlEyesAnim:stopEyesAnim()
	nk.GCD.Cancel(self)
end

return GirlEyesAnim