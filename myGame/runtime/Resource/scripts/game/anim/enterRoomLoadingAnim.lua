local Z_ORDER = 1001

local EnterRoomLoadingAnim = class()

function EnterRoomLoadingAnim:ctor(roomType)
	self.roomType = roomType or 1
end

local function createResString(imageName,nImages)
	local resStrList = {}
	for i=1, nImages do
		local strTmp=kImageMap[string.format(imageName,i)]
		table.insert(resStrList,strTmp)
	end
	return resStrList
end

function EnterRoomLoadingAnim:addLoading(blurPng)
	self.m_created = true
	
	self.m_baseNode = new(Node)
	self.m_baseNode:setLevel(Z_ORDER)
	self.m_baseNode:setFillParent(true, true)
	self.m_baseNode:setEventTouch(self,self.onShieldingLayerTouch)
	self.m_baseNode:setEventDrag(self,self.onShieldingLayerTouch)
	
	

	if blurPng then
		local bg = new(Image, "res/room/loading/" .. (blurPng or "blur_green.jpg"))
		bg:setFillParent(true)
		bg:setAlign(kAlignCenter)
		self.m_baseNode:addChild(bg)
	else
		-- local bg = new(Image, kImageMap.common_full_screen_tip_bg)
		-- bg:setFillParent(true)
		-- bg:setAlign(kAlignCenter)
		-- self.m_baseNode:addChild(bg)
	end

	local imageFiles = createResString("loading_chip_%d", 12)

	self.m_loadingIcons = new(Images, imageFiles)
	self.m_loadingIcons:setAlign(kAlignCenter)
	self.m_loadingIcons:setPos(0, -44)
	self.m_baseNode:addChild(self.m_loadingIcons)

	self.m_loadingText = new(TextView, bm.LangUtil.getText("ROOM", "ENTERING_MSG"),  400, nil, kAlignCenter, nil, 24, 255, 255, 255)
	self.m_loadingText:setAlign(kAlignCenter)
	self.m_loadingText:setPos(0, 50)
	self.m_baseNode:addChild(self.m_loadingText)

	self.m_loadingCloseBtn = new(Button, kImageMap.common_pop_close)
	self.m_loadingCloseBtn:setAlign(kAlignTopRight)
	-- self.m_loadingCloseBtn:setPos(200, -90)
	self.m_loadingCloseBtn:setPos(20, 20)
	self.m_loadingCloseBtn:setOnClick(self, self.onCloseBtnClick)
	self.m_loadingCloseBtn:setVisible(false)
	self.m_baseNode:addChild(self.m_loadingCloseBtn)

	self.m_baseNode:addToRoot()

	self.m_baseNode:setVisible(false)
end

function EnterRoomLoadingAnim:getTips()
	local tipsTable
	local tipsNum
	local tips
	if self.roomType == 1 then
		tipsTable = bm.LangUtil.getText("ROOM", "ENTER_TIPS_GAPLE")
	elseif self.roomType == 2 then
		tipsTable = bm.LangUtil.getText("ROOM", "ENTER_TIPS_QIUQIU")
	end
	tipsNum = #tipsTable
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
	tips = tipsTable[math.random(1,tipsNum)]
	return tips
end

-- 屏蔽层点击
function EnterRoomLoadingAnim:onShieldingLayerTouch()
	
end

function EnterRoomLoadingAnim:onLoadingStart(delay, textStr, callback, blurPng)
	self.m_callback = callback
	if not self.m_created then
		self:addLoading(blurPng)
	end
	self:onLoadingRelease()
	self.m_baseNode:setVisible(true)
	nk.ignoreBack = true
	if textStr then
		self.m_loadingText:setText(textStr)
	else
		local tips = self:getTips()
		if tips then
			-- nk.TopTipManager:showTopTip(tips)
			self.m_loadingText:setText(tips)
		end
	end
	--创建一个可变值[0,11]
	self.m_animIndex = new(AnimInt, kAnimRepeat, 0, 11, 800, -1)
	self.m_animIndex:setDebugName("EnterRoomLoadingAni.m_animIndex")
	--创建一个ImageIndex prop
	self.m_propImageIndex = new(PropImageIndex, self.m_animIndex)
	self.m_loadingIcons:addProp(self.m_propImageIndex, 0)
	-- 延迟多少秒后，显示关闭按钮
	self.clock = Clock.instance():schedule_once(function()
		if not tolua.isnull(self.m_loadingCloseBtn) then
			self.m_loadingCloseBtn:setVisible(true)
		end
	end, delay/1000)
end

function EnterRoomLoadingAnim:onCloseBtnClick()
	self.m_loadingCloseBtn:setVisible(false)
	self:onLoadingRelease()
	if self.m_callback then
		self.m_callback()
	end
end

function EnterRoomLoadingAnim:onLoadingRelease()
	nk.ignoreBack = false
	if self.m_animIndex then
		self.m_loadingIcons:removeProp(0)
		delete(self.m_animIndex)
		self.m_animIndex = nil
	end
	if self.m_propImageIndex then
		delete(self.m_propImageIndex)
		self.m_propImageIndex = nil
	end
	if self.clock then 
		self.clock:cancel() 
		self.clock = nil
	end
	self.m_baseNode:setVisible(false)
end

function EnterRoomLoadingAnim:dtor()
	self:onLoadingRelease()
	if self.m_baseNode then
		delete(self.m_baseNode)
		self.m_baseNode = nil
		self.m_created = nil
	end
end

return EnterRoomLoadingAnim
