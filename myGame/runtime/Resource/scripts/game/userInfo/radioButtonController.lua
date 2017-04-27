
local RadioButtonController = class()

function RadioButtonController:ctor(buttons, radioRes)
	self.buttons = buttons
	self.radioRes = radioRes
	assert(self.radioRes.unchoice, "radioRes.unchoice not exist!")
	assert(self.radioRes.choice, "radioRes.choice not exist!")
	for i = 1, #buttons do
		-- buttons[i]:setName(i)
		buttons[i]:setOnClick(i, function(index)
			self:onClick(index)
		end)
	end
end

function RadioButtonController:dtor()

end

function RadioButtonController:registerCallback(callback)
	self.callback = callback
end

function RadioButtonController:onClick(index)
	-- assert(index, "index not exist!")
	local btnClicked = self.buttons[index]
	if self.btnChoice then
		self.btnChoice:getChildByName("Image_radio"):setFile(self.radioRes.unchoice)
	end
	if self.btnChoice ~= btnClicked then
		btnClicked:getChildByName("Image_radio"):setFile(self.radioRes.choice)
		self.btnChoice = btnClicked
		if self.callback then self.callback(index) end
	else
		self.btnChoice = nil
		if self.callback then self.callback(0) end
	end
end

return RadioButtonController