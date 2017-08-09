
local TabController = class()

function TabController:ctor(tabContainer, tabInfo, eachTabBgCtorArgsLeft, eachTabBgCtorArgsCenter, eachTabBgCtorRight, decoTabFunc)
	self.tabContainer = tabContainer
	self.tabInfo = tabInfo
	self.eachTabBgCtorArgsLeft = eachTabBgCtorArgsLeft
	self.eachTabBgCtorArgsCenter = eachTabBgCtorArgsCenter or eachTabBgCtorArgsLeft
	self.eachTabBgCtorRight = eachTabBgCtorRight or eachTabBgCtorArgsLeft
	self.decoTabFunc = decoTabFunc
end

function TabController:dtor()

end

function TabController:clearTabs()
	
end

function TabController:setTabs(tabNames, selectedIndex)
	self:clearTabs()
	self.listOfTabBg = {}
	local tabContainer = self.tabContainer
	local width, height = self.tabInfo.width, self.tabInfo.height
	local startX = self.tabInfo.startX
	local startY = self.tabInfo.startY
	local numOfTabs = #tabNames
	local eachWidth = width / numOfTabs
	self.selectedIndex = selectedIndex
	for i = 1, numOfTabs do
		local tabBtn = new(Button,"res/common/common_blank.png")
		tabBtn:setSize(eachWidth, height)
		tabBtn:addTo(tabContainer)
		local args = self.eachTabBgCtorArgsCenter
		local flag = "center"
		if  i == 1 then
			args = self.eachTabBgCtorArgsLeft
			flag = "left"
		elseif i == numOfTabs then
			args = self.eachTabBgCtorRight
			flag = "right"
		end
		local tabBg = new(Image, unpack(args))
		tabBg:setSize(eachWidth, height) -- 减4，留按钮空隙
		tabBg:addTo(tabBtn)
		tabBtn:setPos(startX + (i - 1) * eachWidth, startY)
		local text = new(Text, tabNames[i], nil, nil, nil, nil, 20, 255, 255, 255)
		text:addTo(tabBtn)
		text:setAlign(kAlignCenter)
		table.insert(self.listOfTabBg, tabBg)
		if i ~= self.selectedIndex then
			tabBg:setVisible(false)		
		end
		if self.decoTabFunc then
			self.decoTabFunc(tabBg, flag)
		end
		tabBtn:setName(i)
		tabBtn:setOnClick(self, function()
			self:onTabBtnClick(tabBtn)
		end)
	end
	if self.onTabClickCallback and self.selectedIndex then
		self.onTabClickCallback(self.selectedIndex)
	end
end 

function TabController:setSelectIndex(index)
	self.selectedIndex = index or 1
	local numOfTabs = #self.listOfTabBg
	for i = 1, numOfTabs do
		self.listOfTabBg[i]:setVisible(i == self.selectedIndex)
	end
	if self.onTabClickCallback then
		self.onTabClickCallback(self.selectedIndex)
	end
end

function TabController:onTabBtnClick(btnClicked)
	self:setSelectIndex(tonumber(btnClicked:getName()))
end

function TabController:registerCallback(onTabClickCallback)
	self.onTabClickCallback = onTabClickCallback
end

return TabController