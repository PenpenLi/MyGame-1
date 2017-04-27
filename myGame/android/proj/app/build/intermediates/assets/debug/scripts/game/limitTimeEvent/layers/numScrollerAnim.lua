-- numScrollerAnim.lua

local numList = require("view/Android_960_640/limitTimeEvent/number_list")

local NumScrollerAnim = class()

local OFFSET_O = 16

local MAX_NUM = 99999999

local EACH_NUM_H = 44

local MAX_LENGTH = 8
local CUR_LENGTH = MAX_LENGTH

local MIN_TABLE = {0,0,0,0,0,0,0,0}
local MAX_TABLE = {9,9,9,9,9,9,9,9}

local test_num = {
	originNum = 123011,
	resetChangeBigNum = math.random(200,5000),
}

function NumScrollerAnim:ctor(parentNode)
	Log.printInfo("NumScrollerAnim.ctor");

	self.m_nodeTable = parentNode
	self.m_numTable = {}
	self.m_numClicle = {}
	self.m_step2Move = {}
	self.m_isNumChangeing = {}

	self.m_curViewNum = 0  -- 当前界面显示num
	self.m_directNum = 0  -- 目标数字，即动画结束时数字，也是请求返回的全服活动进度
	self.m_animStartNum = 0 -- 动画开始时数字
	self.m_animEndNum = self.m_directNum -- 动画结束时数字
	self.m_lastDirectNum = self.m_directNum -- 上次滚轮动画的目标值

    self:setTotleChangeTime(1.5)
    self:createNumList()

end

function NumScrollerAnim:dtor()
	self:stopScroll()
end

function NumScrollerAnim:getIsNumChangeing()
	local flag = false
	for i,isChangeing in ipairs(self.m_isNumChangeing) do
		if isChangeing then
			flag = true
			break
		end
	end
	return flag
end

function NumScrollerAnim:onStartCurScrollerAnim(directNum, isNeedAnim)
	if self:getIsNumChangeing() then 
		self:onStopCurScrollerAnim()
	end
	math.randomseed(tostring(os.time()):reverse():sub(1,6))
	if isNeedAnim then
		self.m_directNum = directNum or 0
		-- self.m_animStartNum = self.m_directNum - math.random(200,5000)
		self.m_animStartNum = self.m_lastDirectNum or 0
		self:setNumBar(self.m_animStartNum)
		self:getEachNumOffsetAndMove(self.m_animStartNum, self.m_directNum)
		self.m_lastDirectNum = self.m_directNum
	else
		local allEvent = nk.limitTimeEventDataController:getAllEvent()
		if allEvent and allEvent.num then
			self:setNumBar(tonumber(allEvent.num))
		else
			self:setNumBar(directNum)
		end
	end
end

function NumScrollerAnim:setTotleChangeTime(time)
	-- 秒为单位
	self.m_totleTime = time or 5
end

function NumScrollerAnim:createNumList()
	for i,node in ipairs(self.m_nodeTable) do
		local num = SceneLoader.load(numList)
		num:setAlign(kAlignTop)
		node:removeAllChildren(true)
		node:addChild(num)
		num:setPos(0,OFFSET_O)

		table.insert(self.m_numTable, num)
		table.insert(self.m_numClicle, 0)
		table.insert(self.m_isNumChangeing, false)
	end
end

-- 设置当前显示数字，没有动画
function NumScrollerAnim:setNumBar(num)
	local curNum_table = self:getEachNum(num)
	for i=1, MAX_LENGTH do
		local curNum =  curNum_table[i] or 0
		if self.m_numTable[i] then
			self.m_numTable[i]:setPos(0,-1*curNum*EACH_NUM_H + OFFSET_O)
		end
	end
	-- 当前界面显示num
	self.m_curViewNum = num
end

function NumScrollerAnim:onStopCurScrollerAnim()
	self:stopScroll()
	self:setNumBar(self.m_directNum)
	self.m_lastDirectNum = self.m_directNum
end

-- 获取滚动开始时的数字
function NumScrollerAnim:getStartNum(directNum)
	local offsetNum = math.random(12354,6883502)
	return directNum - offsetNum
end

-- 获取数字的每一位
function NumScrollerAnim:getEachNum(num)
	local curNum_table = {}
	num = checkint(num)
	if num > 0 and num <= MAX_NUM then
		while(num>0)
		do
			table.insert(curNum_table,math.floor(num%10))
		    num = math.floor(num/10);
		end
		for i=1,MAX_LENGTH do
			if not curNum_table[i] then
				curNum_table[i] = 0
			end
		end
	elseif num <= 0 then
		curNum_table = MIN_TABLE
	elseif num > MAX_NUM then
		curNum_table = MAX_TABLE
	end
	return curNum_table
end

-- 获取每个位置数字的滚动距离
function NumScrollerAnim:getEachNumOffsetAndMove(curRum, directNum)
	if checkint(curRum) == checkint(directNum) then
		return
	end

	local curRumTab = self:getEachNum(curRum)
	local directNumTab = self:getEachNum(directNum)
	local offNum = directNum - curRum

	-- 从个位开始 有哪几个位置需要动画
	local needAnimNumCount = 0
	local eachNumOffset = MIN_TABLE


	----[[
	-- 第一段，fromValue ---> 0
	-- 第二段，1 ---> 0  循环 self.m_numClicle[index] 次
	-- 第三段，0 ---> toValue

	-- self.m_numClicle
	-- 	0: (第一段 和 第三段) 或 fromValue ---> toValue
	-- 	n: 第一段 、 第二段 、第三段


	for i=#curRumTab, 1, -1 do
		if directNumTab[i] then
			if (curRumTab[i] ~= directNumTab[i] and self.m_numTable[i]) or 
				(curRumTab[i] == directNumTab[i] and needAnimNumCount > 0) then
				needAnimNumCount = needAnimNumCount + 1

				if i == #curRumTab then
					self.m_numClicle[i] = 0
				else
					if needAnimNumCount == 1 or needAnimNumCount == 2 then
						self.m_numClicle[i] = 0
					else
						-- 低位比高位多转一圈
						self.m_numClicle[i] = self.m_numClicle[i+1] + 1
					end
				end
			elseif i == #curRumTab then
				-- 不用变化
				self.m_numClicle[i] = 0
			end
		end
	end
	--]]

	for i=1,needAnimNumCount do
		local curRumTab_each = curRumTab[i]
		local directNumTab_each = directNumTab[i]
		if self.m_numTable[i] then
			self:startScroll(self.m_numTable[i], curRumTab_each, directNumTab_each, i, needAnimNumCount)
		end
	end

	-- Log.dump(curRum, "curRum = ")
	-- Log.dump(directNum, "directNum = ")
	-- for i,v in ipairs(self.m_numClicle) do
	-- 	Log.dump(i, "i = ")
	-- 	Log.dump(v, "directNum[i] = ")
	-- end
end

function NumScrollerAnim:startScroll(numNode, fromValue, toValue, index, needAnimNumCount)
	if self.m_numClicle[index] == 0 then
		self.m_isNumChangeing[index] = true
		self.m_numTable[index]:stopAllActions()

		if index == needAnimNumCount then
			-- 第一个需要变化的数字
			-- fromValue ---> toValue
			if toValue == 0 then
				toValue = 10
			end
			transition.moveTo(self.m_numTable[index], {time=self.m_totleTime, x=0, y=-1*toValue*EACH_NUM_H + OFFSET_O, onComplete=handler(self, function()
						if not nk.updateFunctions.checkIsNull(self) then
	                    	self.m_isNumChangeing[index] = false
						end
	                end)})
		else
			local step1Num = (10 - fromValue)
			local step3Num = toValue

			local totleNumTime = step1Num + step3Num
			local eachNumTime = self.m_totleTime/totleNumTime

			-- 第一段，fromValue ---> 0
			-- 第三段，0 ---> toValue
			local time1 = step1Num*eachNumTime
			local time3 = step3Num*eachNumTime

			transition.moveTo(self.m_numTable[index], {time=time1, x=0, y=-10*EACH_NUM_H + OFFSET_O, onComplete=handler(self, function()
						if not nk.updateFunctions.checkIsNull(self) then
							self.m_numTable[index]:setPos(0,OFFSET_O)
						    transition.moveTo(self.m_numTable[index], {time=time3, x=0, y=-1*toValue*EACH_NUM_H + OFFSET_O, onComplete=handler(self, function()
						    			if not nk.updateFunctions.checkIsNull(self) then
					                    	self.m_isNumChangeing[index] = false
										end
						    		end)})
						end
					end)})
		end

	elseif self.m_numClicle[index] > 0 then
		-- Log.printInfo(self.m_numClicle[index], "first self.m_numClicle[index] = ")
		-- Log.printInfo(index, "first index = ")
		-- fromValue ---> 0，  1 ---> 0， 0 ---> toValue

		self.m_isNumChangeing[index] = true

		if self.m_step2Move[index] then
			self.m_numTable[index]:doRemoveProp(5);
	        delete(self.m_step2Move[index])
	        self.m_step2Move[index] = nil;
		end
		self.m_numTable[index]:stopAllActions()

		local step1Num = (10 - fromValue)
		local step2Num = 10*self.m_numClicle[index]
		local step3Num = toValue

		local totleNumTime = step1Num + step2Num + step3Num
		local eachNumTime = self.m_totleTime/totleNumTime

		-- 第一段，fromValue ---> 0
		-- 第二段，1 ---> 0  循环 self.m_numClicle[index] 次
		-- 第三段，0 ---> toValue
		local time1 = step1Num*eachNumTime
		local time2 = 10*eachNumTime
		local time3 = step3Num*eachNumTime

		transition.moveTo(self.m_numTable[index], {time=time1, x=0, y=-10*EACH_NUM_H + OFFSET_O, onComplete=handler(self, function()
					if not nk.updateFunctions.checkIsNull(self) then
						self.m_numTable[index]:setPos(0,OFFSET_O)
	                    self.m_step2Move[index] = self.m_numTable[index]:addPropTranslate(5, kAnimRepeat, time2*1000, -1, 0, 0, OFFSET_O, -10*EACH_NUM_H + OFFSET_O)
	                    self.m_step2Move[index]:setEvent(self, function()
	                    		if not nk.updateFunctions.checkIsNull(self) then
		                    		self.m_numClicle[index] = self.m_numClicle[index] - 1
		                    		-- Log.printInfo("qian qian qian qian qian qian ")
		                    		-- Log.printInfo(self.m_numClicle[index], "self.m_numClicle[index] = ")
		                    		-- Log.printInfo("dou dou dou dou dou dou ")
		                    		self.m_numTable[index]:setPos(0,OFFSET_O)
		                    		if self.m_numClicle[index] <= 0 then
		                    			if self.m_step2Move[index] then
									        self.m_numTable[index]:doRemoveProp(5);
									        delete(self.m_step2Move[index])
									        self.m_step2Move[index] = nil;
									    end

										self.m_numTable[index]:setPos(0,OFFSET_O)
									    transition.moveTo(self.m_numTable[index], {time=time3, x=0, y=-1*toValue*EACH_NUM_H + OFFSET_O, onComplete=handler(self, function()
									    			if not nk.updateFunctions.checkIsNull(self) then
								                    	self.m_isNumChangeing[index] = false
													end
									    		end)})
		                    		end
		                    	end
	                    	end);
	                end
                end)})

	end
end

function NumScrollerAnim:stopScroll()
	for i,num in ipairs(self.m_numTable) do
		if self.m_step2Move[i] then
			self.m_numTable[i]:doRemoveProp(5);
	        delete(self.m_step2Move[i])
	        self.m_step2Move[i] = nil;
		end
		num:stopAllActions()
		self.m_isNumChangeing[i] = false
	end
end




return NumScrollerAnim