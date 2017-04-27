--
-- Author: Jackie
-- Date: 2015-08-07 11:50:44
-- 牌型确认的倒计时框

local CardModeConfirm = class()

local LB_SET_ORDER = T("确认顺序")
local LB_CONFIRM   = T("确认")

function CardModeConfirm:ctor(root)
	self.m_root = root
    local tipLabel = root:getChildByName("tipLabel")
    tipLabel:setText(LB_SET_ORDER)
    self.confirmBtn_ = root:getChildByName("confirmButton")
    self.confirmBtn_:setOnClick(self, self.onClickConfirm)
	self.timeSprite_ = root:getChildByName("timeImage")
end

function CardModeConfirm:onClickConfirm(evt)
	if self.confirmHandler then
		self.confirmHandler()
		self.confirmHandler = nil
	end
	nk.GCD.Cancel(self)
	self.m_root:setVisible(false)
end


function CardModeConfirm:show()
	self.m_root:setVisible(true)
end


function CardModeConfirm:hide()
	self.m_root:setVisible(false)
end

function CardModeConfirm:startTime(countDownTime,confirmHandler,timeOverHandler)
	self.confirmHandler = confirmHandler

	self:setTime(countDownTime)
	self.m_root:setVisible(true)

	nk.GCD.Cancel(self)   --防止倒数中，home出去又回来的情况
	nk.GCD.PostDelay(self, function()
			if self.time_ - 1 >= 1 then
				self:setTime(self.time_ - 1)	
			else
				nk.GCD.Cancel(self)
				if timeOverHandler then    --服务器要统计没有操作超时，这里取消超时发确认包，只做禁止点击
				   timeOverHandler()
				end
				self.m_root:setVisible(false)
			end
		end, nil, 1000, true)
end

function CardModeConfirm:setTime(t)
	self.time_ = t
	if not nk.updateFunctions.checkIsNull(self.timeSprite_) and self.timeSprite_.m_res and kImageMap["t_" .. t] then
		self.timeSprite_:setFile(kImageMap["t_" .. t])
	end
end  

function CardModeConfirm:reset()
	nk.GCD.Cancel(self)
	self.m_root:setVisible(false)
end  

return CardModeConfirm
