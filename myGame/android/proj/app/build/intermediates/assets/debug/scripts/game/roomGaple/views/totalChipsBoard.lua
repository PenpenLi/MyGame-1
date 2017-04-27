--
-- Author: Jackie
-- Date: 2015-08-06 09:41:44
-- 房间桌子上的筹码计数板

local  TotalChipsBoard = class()

function TotalChipsBoard:ctor(prizePool)
	print("TotalChipsBoardTotalChipsBoard jielong")
	self.prizePool = prizePool
	self.chipsValue_ = 0;
	self:setValue(self.chipsValue_)

end

function TotalChipsBoard:setValue(val)
	if val then
		self.chipsValue_ = val
		local formatVal = string.format("%013d",tonumber(val))
		self.prizePool:setText(getFormatNumber(formatVal, ","))
	end

end

function TotalChipsBoard:playAddAnim(totalValue)
	-- self:stopAddAnim()
	-- self:setValue(self.chipsValue_)
	-- if totalValue then
	-- 	local offset = totalValue - self.chipsValue_
	-- 	local total = totalValue
	-- 	local speed = offset/50
	-- 	local value = self.chipsValue_
	-- 	if offset > 0 then
	-- 		self.schedulerHandle =scheduler.scheduleGlobal(handler(self, function()
	-- 	        if value < total then
	-- 	        	self:setValue(value)
	-- 	            value = value + speed
	-- 	        else
	-- 	            self:setValue(total)
	-- 	            self:stopAddAnim()
	-- 	        end 
	-- 	    end), 0.01)
	-- 	else
	-- 		self:setValue(total)
	-- 	end
	-- 	self.chipsValue_ = total
	-- end
	self:setValue(totalValue)
end

function TotalChipsBoard:stopAddAnim()
	-- if self.schedulerHandle then
 --        scheduler.unscheduleGlobal(self.schedulerHandle)
 --        self.schedulerHandle = nil
 --    end
end

return TotalChipsBoard
