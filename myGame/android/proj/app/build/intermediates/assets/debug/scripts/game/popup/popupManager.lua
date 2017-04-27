----[[
local PopupManager = class()

function PopupManager:ctor()
	self.m_PopupMap = {}
	EventDispatcher.getInstance():register(EventConstants.dismissPopupByName, self, self.removePopupByName)
end

function PopupManager:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.dismissPopupByName, self, self.removePopupByName)
end

function PopupManager:addPopup(popup, owner, ...)
	popup.show(...)
	local has, index = self:hasCreate(owner, popup.name)
	popup.time = os.time()
	if not has then
		table.insert(self.m_PopupMap,popup)
	else
		self:removePopupByName(popup.name)
		-- table.remove(self.m_PopupMap,index)
		table.insert(self.m_PopupMap,popup)
	end
end

--只显示最上面的弹窗
function PopupManager:showTopPopup()
	local len = #self.m_PopupMap 
	if len>1 then
		for i=1,len-1 do
			if self.m_PopupMap[i].s_instance then
				self.m_PopupMap[i].s_instance:setVisible(false)
			end
		end	
		if self.m_PopupMap[len].s_instance then
			self.m_PopupMap[len].s_instance:setVisible(true)
		end
	elseif len==1 then
		if self.m_PopupMap[1].s_instance then
			self.m_PopupMap[1].s_instance:setVisible(true)
		end
	end
end

function PopupManager:hasCreate(owner, name)
	local flag, index = false, nil
	for k,popup in ipairs(self.m_PopupMap) do
		if popup.name == name then
			flag = true
			index = k
			break
		end
	end
	return flag, index
end

-- 检测弹框是否显示
function PopupManager:hasPopup(owner, name)
	local flag = false
	if name then
		for j,popup in ipairs(self.m_PopupMap) do
			if popup.s_instance and popup.name == name then
				flag = true
				break
			end
		end
	else
		flag = #self.m_PopupMap > 0
	end
	return flag
end

function PopupManager:removeAllPopup()
	for j,popup in ipairs(self.m_PopupMap) do
		delete(popup.s_instance)
	 	popup.s_instance = nil
	end
	self.m_PopupMap = {}
end

function PopupManager:removePopupByName(name)
	for k,popup in ipairs(self.m_PopupMap) do
		if popup.name == name then
	 		-- popup.s_instance:removeFromParent(true)
			delete(popup.s_instance)
	 		popup.s_instance = nil
			self:releaseDialog(popup)
			break
		end
	end
end

function PopupManager:dismissDialog()
	local index = (#self.m_PopupMap > 0) and #self.m_PopupMap or 1
    if self.m_PopupMap[index] then
		delete(self.m_PopupMap[index].s_instance);
	 	self.m_PopupMap[index].s_instance = nil;
		self:releaseDialog(self.m_PopupMap[index])
		return true
	end
	return false
end

function PopupManager:sortDialog()
	table.sort(self.m_PopupMap, function(popup1, popup2)
        return popup1.time > popup2.time
    end)
end

function PopupManager:releaseDialog(popup)
	table.removebyvalue(self.m_PopupMap, popup, true)
end

return PopupManager

--]]

--[[
local PopupManager = class()

function PopupManager:ctor()
	self.m_PopupMap = {}

end

function PopupManager:addPopup(popup,owner,...)
	popup.show(...)
	popup.owner = owner

	local has, index = self:hasCraete(owner,popup.name)
	if not has then
		table.insert(self.m_PopupMap[owner],popup)
	else
		self.m_PopupMap[owner][index] = popup
	end
end

function PopupManager:hasCraete(owner,name)
	local flag, index = false, nil
	if self.m_PopupMap[owner] then
		for k,popup in ipairs(self.m_PopupMap[owner]) do
			if popup.name == name then
				flag = true
				index = k
				break
			end
		end
	else
		self.m_PopupMap[owner] = {}
		flag = false
	end
	return flag, index
end

function PopupManager:hasPopup(owner,name)
	local flag = false
	if owner and name then
		if self.m_PopupMap[owner] then
			for k,popup in pairs(self.m_PopupMap[owner]) do
				if popup.s_instance and popup.name == name then
					flag = true
					break
				end
			end
		end
	elseif name then
		for k,popupMap in pairs(self.m_PopupMap) do
			for j,popup in pairs(popupMap) do
				if popup.s_instance and popup.name == name then
					flag = true
					break
				end
			end
		end
	end
	return flag
end

function PopupManager:removeAllPopup(owner)
	for k,popupMap in pairs(self.m_PopupMap) do
		for j,popup in pairs(popupMap) do
			if popup.name == "WAndFChatPopup" then
				popup:hide()
			elseif popup.owner == owner then
				popup:hide()
			end
		end
	end
	self.m_PopupMap[owner] = {}
	Log.printInfo("removeAllPopup removeAllPopup")
end

function PopupManager:removePopupByName(owner,name)
	if self.m_PopupMap[owner] then 
		for k,popup in pairs(self.m_PopupMap[owner]) do
			if popup.name == name then
				popup:hide()
			end
		end
	end
end

function PopupManager:dismissDialog()
-- æŽ§åˆ¶å…³é—­çš„å…ˆåŽé¡ºåº?æ ¹æ®æ—¶é—´æŽ’åºï¼?æˆ–è°ƒæ•´å­˜å‚¨ç»“æž?
	for k,popupMap in pairs(self.m_PopupMap) do
		for j,popup in pairs(popupMap) do
			if popup.s_instance then
				popup:hide()
				return true
			end
		end
	end
	return false
end

return PopupManager
--]]