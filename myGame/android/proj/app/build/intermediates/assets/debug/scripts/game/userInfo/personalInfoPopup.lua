
local PopupModel = require('game.popup.popupModel')
local LayerConfig = require(VIEW_PATH .. "userInfo/personalInfo_layer")
local LayerVarPath = VIEW_PATH .. "userInfo/personalInfo_layer_layout_var"
local TabController = require("game.userInfo.tabController")
local RadioButtonController = require("game.userInfo.radioButtonController")
local PersonalDetailView = require("game.userInfo.personalDetailView")
local PersonalSpaceView = require("game.userInfo.personalSpaceView")
local PersonalHDPropView = require("game.userInfo.personalHDPropView")
local PersonalMyPropView = require("game.userInfo.personalMyPropView")
local PersonalRecentExpView = require("game.userInfo.personalRecentExpView") --最近表情recent expression

local LoadGiftControl = require("game.giftShop.loadGiftControl")

local FriendDataManager = require("game.friend.friendDataManager") 
local PersonalInfoDelegate = require("game.userInfo.personalInfoDelegate") 

local PersonalInfoPopup = class(PopupModel)
PopupModel.RegisterClassFuncs(PersonalInfoPopup, "PersonalInfoPopup", nil, nil) --register show and hide

function PersonalInfoPopup:ctor(viewConfig, varConfigPath, data, ctx, seatInfo)--前2个参数适用于父类构造函数
	self:addShadowLayer(kImageMap.common_transparent_blank)
	self.loaderInfo = SceneLoader.loadAsync(LayerConfig, function(ret)
		if tolua.isnull(self) then
			delete(ret)
			return
		end
		self.m_root = ret
		self.m_root:addTo(self)
		self.m_controlsMap = {}
		self:addEventListeners()
		if LayerVarPath then
	        self:declareLayoutVar(LayerVarPath)
	    end
		self.ctx = ctx --只有房间里会传这个值
		self.data = data --只有其他用户会传这个值
		self.seatInfo = seatInfo --只有房间里其他用户会传这个值
		-- FwLog("PersonalInfoPopup:ctor >>>>>>>>>>>>>>>>" .. json.encode(data))
		self.currentScene = self.ctx and self.ctx.sceneName or "hall"
		if self.data then
			self.personalUid = self.data.mid
			if seatInfo and seatInfo.uid then
				self.personalUid = seatInfo.uid
			end
			if seatInfo and seatInfo.mid then
				self.personalUid = seatInfo.mid
			end
		else
			self.personalUid = nk.UserDataController.getUid()
		end
		-- self.personalUid = 105032
		self.isUser = self.personalUid == nk.UserDataController.getUid()
		if self.isUser then
			nk.AnalyticsManager:report("New_Gaple_open_my_info")
		else
			nk.AnalyticsManager:report("New_Gaple_open_other_info")
		end
		self:initView()
		self:initListeners()
		nk.UserDataController.getMemberInfo({uid = self.personalUid})
		nk.reportConfig:loadReportConfig()
		if not self.isUser then
			FriendDataManager.getInstance():loadFriendData(function()
				if self.isInitDone then
					self:refreshToolBarList()
				end
			end)
		end
		self.isInitDone = true
		TextureCache.instance():clean_unused()
		if self.showOutPopup then
			self.showOutPopup()
		end
	end)
end

function PersonalInfoPopup:dtor()
	self:removeListeners()
	if self.tabController then
		delete(self.tabController)
		self.tabController = nil
	end
	if self.gagData then
		nk.DataProxy:setData(nk.dataKeys.ROOM_GAG, self.gagData)
    	nk.DataProxy:cacheData(nk.dataKeys.ROOM_GAG)
	end
	nk.DictModule:saveDict("gameData")--保存数据
	self.isInitDone = nil
	if self.flyingThumbs then
		for i = 1, #self.flyingThumbs do
			delete(self.flyingThumbs[i])
		end
		self.flyingThumbs = nil
	end
	SceneLoader.killLoader(self.loaderInfo)
end

function PersonalInfoPopup:initListeners()
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpCallback)
	EventDispatcher.getInstance():register(EventConstants.getMemberInfoCallback, self, self.onPersonalInfoCallback)
	EventDispatcher.getInstance():register(EventConstants.onPopBgTouch, self, self.onPopBgTouch)
	if self.isUser then
		self.giftId = nk.userData["gift"]
		self.propertyHandlers = {}
		self.propertyNames = {"micon", "msex", "name", "money", "FBindex", "sign"}
		local hanlders = {
			handler(self, self.onIconChangedCallback),
			handler(self, self.onSexChangedCallback),
			handler(self, self.onNameChangedCallback),
			handler(self, self.onMoneyChangedCallback),
			handler(self, self.onFBindexChangedCallback),
			handler(self, self.onSignatureChanged),
		}
		if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
			table.insert(self.propertyNames, "gift")
			table.insert(hanlders, handler(self, self.onGiftChangedCallback))
		end
		for i = 1, #self.propertyNames do
			table.insert(self.propertyHandlers, nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, 
				self.propertyNames[i], hanlders[i]))
		end
		EventDispatcher.getInstance():register(EventConstants.update_photo, self, self.onPersonalPhotoUpdate)
		EventDispatcher.getInstance():register(EventConstants.updateFBBindStatus, self, self.onUpdateFBBindStatus)
	else
		EventDispatcher.getInstance():register(EventConstants.addFriendData, self, self.onAddFriendCallback)
   	 	EventDispatcher.getInstance():register(EventConstants.deleteFriendData, self, self.onDelFriendCallback)
   	 	EventDispatcher.getInstance():register(EventConstants.THUMB_UP, self, self.onThumbUpedCallback)
	end
end

function PersonalInfoPopup:removeListeners()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpCallback)
	EventDispatcher.getInstance():unregister(EventConstants.getMemberInfoCallback, self, self.onPersonalInfoCallback)
	EventDispatcher.getInstance():unregister(EventConstants.onPopBgTouch, self, self.onPopBgTouch)
	if self.giftUrlReqId_ then
		LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
		self.giftUrlReqId_ = nil
	end 
	if self.isUser then
		EventDispatcher.getInstance():unregister(EventConstants.update_photo, self, self.onPersonalPhotoUpdate)
		EventDispatcher.getInstance():unregister(EventConstants.updateFBBindStatus, self, self.onUpdateFBBindStatus)
	end
	if self.isUser and self.propertyHandlers then
		for i = 1, #self.propertyHandlers do
			nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, self.propertyNames[i], self.propertyHandlers[i])
		end
		self.propertyHandlers = nil
	elseif not self.isUser then
		EventDispatcher.getInstance():unregister(EventConstants.addFriendData, self, self.onAddFriendCallback)
    	EventDispatcher.getInstance():unregister(EventConstants.deleteFriendData, self, self.onDelFriendCallback)
    	EventDispatcher.getInstance():unregister(EventConstants.THUMB_UP, self, self.onThumbUpedCallback)
	end
end

function PersonalInfoPopup:initView()
	self.user_icon = Mask.setMask(self:getUI("Image_user_icon"), kImageMap.common_head_mask_middle, {scale = 1, align = 0, x = -1.5, y = -1})

	self:getUI("Button_camera"):setVisible(self.isUser)
	self:getUI("Button_thumbup"):setVisible(not self.isUser)
	self:getUI("Button_camera"):setEnable(false)
	self:getUI("Button_gift_big"):setVisible(self.isUser)
	self:getUI("Image_gift_icon"):setVisible(self.isUser)
	self:getUI("Button_close"):setClickSound(nk.SoundManager.CLOSE_BUTTON)

	local btnEditProfile = self:getUI("Button_edit_user_profile")
	btnEditProfile:setVisible(self.isUser)
	if self.isUser then
		local richText = new(RichText,"#u"..bm.LangUtil.getText("USERINFO", "KEY_EDIT_PROFILE") .."#n", nil, nil, kAlignLeft, "", 20, 255, 255, 255, false, 0)
		richText:addTo(btnEditProfile)
		local x,y = btnEditProfile:getChildByName("Text33"):getPos()
		richText:setPos(x ,y - 2.5)-- - 20
		btnEditProfile:getChildByName("Text33"):setVisible(false)
	end

	local hdPropPlug = self:getUI("View_hd_prop_plugin")
	hdPropPlug:setVisible(false)
	local radioButtonController = new(RadioButtonController, {
		hdPropPlug:getChildByName("Button_x3"),
		hdPropPlug:getChildByName("Button_x5"),
	}, {choice = "/res/userInfo/userInfo_choosed.png", unchoice = "/res/userInfo/userInfo_uchosed.png"})
	radioButtonController:registerCallback(function (choiceIndex)
		-- FwLog(">>>>>>>>>>>>>>>>>>> choiceIndex = " .. choiceIndex)
		local sendNum = 1
		if choiceIndex == 1 then
			sendNum = 3
		elseif choiceIndex == 2 then
			sendNum = 5
		end
		if self.sendHDPropNum ~= sendNum then
			self.sendHDPropNum = sendNum
			nk.DictModule:setInt("gameData", nk.cookieKeys.PROP_SENT_MORE_NUM, sendNum)
		end
	end)
	local sendNum = nk.DictModule:getInt("gameData", nk.cookieKeys.PROP_SENT_MORE_NUM, 1)
	if sendNum == 3 then
		radioButtonController:onClick(1)
	elseif sendNum == 5 then
		radioButtonController:onClick(2)
	end

	if not self.isUser then
		self:getUI("Button_thumbup"):setEnable(PersonalInfoDelegate.getInstance():checkIsThumbable(self.personalUid, 3))
	end

	self:initTabView()
	self:initToolBar()
	self:initPhotos()
end

function PersonalInfoPopup:initTabView()
	local tabControllerSelect = 1
	if self.currentScene == "hall" then
		if self.isUser then
			self.tabNames = {"Space", "Detail", "MyProp"}
		else
			self.tabNames = {"Space", "Detail"}
		end
	else
		if self.isUser then
			if self.ctx and self.ctx.model and self.ctx.model:isSelfInSeat() then
				tabControllerSelect = 4
				self.tabNames = {"Space", "Detail", "MyProp", "RecentExp"}
			else
				self.tabNames = {"Space", "Detail", "MyProp"}
			end
		else
			if self.ctx and self.ctx.model and self.ctx.model:isSelfInSeat() then
				tabControllerSelect = 3
			end
			self.tabNames = {"Space", "Detail", "HDProp"}
		end
	end
	-- self.tabNames = {"Space", "Detail",  "MyProp", "RecentExp"}--"HDProp",
	local languageTabe = {
		Space = bm.LangUtil.getText("USERINFO", "TAB_SPACE"),
		Detail = bm.LangUtil.getText("USERINFO", "TAB_DETAIL"),
		HDProp = bm.LangUtil.getText("USERINFO", "TAB_HDPROP"),
		MyProp = bm.LangUtil.getText("USERINFO", "TAB_MYPROP"),
		RecentExp = bm.LangUtil.getText("USERINFO", "TAB_RECENTEXP"),
	}
	local tabContainer = self:getUI("Image_tab")
	local w, h = tabContainer:getSize()
	self.tabController = new(TabController, tabContainer, {width = w - 0, 
		height = 43, startX = 0, startY = 2}, 
		{"res/userInfo/userInfo_tab3_left.png", nil, nil, 50, 50, 18, 18},
		{"res/userInfo/userInfo_tab3_center.png", nil, nil, 50, 50, 18, 18},
		{"res/userInfo/userInfo_tab3_right.png", nil, nil, 50, 50, 18, 18}
		-- ,function(tab, flag)
		-- 	local wOfTab, hOfTab = tab:getSize()
		-- 	local upperLight = new(Image, "res/userInfo/userInfo_tab_upper_light.png")
		-- 	local wOfLight = upperLight:getSize()
		-- 	upperLight:addTo(tab)
		-- 	upperLight:setAlign(kAlignTop)
		-- 	upperLight:setPos(15, -3)
		-- 	local downLight = new(Image, "res/userInfo/userInfo_tab_upper_light.png")
		-- 	downLight:addTo(tab)
		-- 	downLight:setAlign(kAlignBottom)
		-- 	downLight:setPos(15, -1)
		-- end
	)
	self.tabController:registerCallback(handler(self, self.onTabControllerCallback))
	local tabShowNames = {}
	for i = 1, #self.tabNames do
		table.insert(tabShowNames, languageTabe[self.tabNames[i]])
	end
	self.tabControllerSelect = tabControllerSelect
	self.tabController:setTabs(tabShowNames)
end

function PersonalInfoPopup:onShow()
	if self.tabController then
		self.tabController:setSelectIndex(self.tabControllerSelect)
	end
end

function PersonalInfoPopup:initToolBar()
	-- local toolbarList = {"FbPage", "Follow", "Unfollow", "HideMsg", "ShowMsg", "Gift", "Trace"}
	self:refreshToolBarList()
end

function PersonalInfoPopup:refreshToolBarList()
	local toolbarList = {}
	if self.infoOfPerson then
		-- FwLog(">>>>>>> self.infoOfPerson.aUser.sitemid" .. self.infoOfPerson.aUser.sitemid)
		if tonumber(self.infoOfPerson.aUser.lid) == 1 and self.infoOfPerson.aUser.sitemid ~= "" then
			if tonumber(self.infoOfPerson.aUser.FBindex) == 2 then
				table.insert(toolbarList, "FbPage")
			end
		end
	end
	if self.isUser then
		table.insert(toolbarList, "Gift")

		local lastLoginType = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    	if lastLoginType ==  "GUEST" then
			local fbBindStatus = nk.DictModule:getInt("gameData", nk.cookieKeys.GUEST_BIND_FB_STATUS, -5)
    		if fbBindStatus == -1 or fbBindStatus == -5 then
				table.insert(toolbarList, "FbBind")
			elseif fbBindStatus == 1 then
				table.insert(toolbarList, "FbBinded")
			end
    	end
	else
		-- local isFollow = true
		-- if isFollow then
		-- 	table.insert(toolbarList, "Unfollow")
		-- else
		-- 	table.insert(toolbarList, "Follow")
		-- end
		local isFriend = FriendDataManager.getInstance():checkHasFriend({mid = self.personalUid})
		if isFriend then
			table.insert(toolbarList, "DelFrd")
		else
			table.insert(toolbarList, "AddFrd")
		end
		if self.currentScene ~= "hall" then
			local gagData = nk.DataProxy:getData(nk.dataKeys.ROOM_GAG)
			local isMsgShow = true
			if gagData then
				for _, v in ipairs(gagData) do
		            if v.uid == self.personalUid then
		                if v.time - os.time() > 24*3600 then
		                	table.removebyvalue(gagData, v)
		                else
		                	isMsgShow = false
		                end
		                break
		            end
		        end	
			end
			if isMsgShow then
				table.insert(toolbarList, "HideMsg")
			else
				table.insert(toolbarList, "ShowMsg")
			end
		else
			table.insert(toolbarList, "Trace")
		end
		table.insert(toolbarList, "Gift")
		table.insert(toolbarList, "SendProp")
		table.insert(toolbarList, "Report")
	end
	self.toolbarList = toolbarList
	self:onToolBarListChange()
end

function PersonalInfoPopup:onToolBarListChange()
	self.toolRes = self.toolRes or {
		FbPage = "res/userInfo/userInfo_toolbar_fb.png",
		Follow = "res/userInfo/userInfo_toolbar_follow.png",
		Unfollow = "res/userInfo/userInfo_toolbar_unfollow.png",
		HideMsg = "res/userInfo/userInfo_toolbar_hidemsg.png",
		ShowMsg = "res/userInfo/userInfo_toolbar_showmsg.png",
		Gift = "res/userInfo/userInfo_toolbar_gift.png",
		Trace = "res/userInfo/userInfo_toolbar_trace.png",
		AddFrd = "res/userInfo/userInfo_toolbar_addfriend.png",
		DelFrd = "res/userInfo/userInfo_toolbar_deletefriend.png",
		SendProp = "res/userInfo/userInfo_toolbar_sendprop.png",
		Report = "res/userInfo/userInfo_toolbar_report.png", -- 举报
		FbBind = "res/userInfo/userInfo_toolbar_unFbBind.png", -- 未绑定FB账号按钮
		FbBinded = "res/userInfo/userInfo_toolbar_fbBind.png", -- 已绑定FB账号按钮
	}
	local missedFile = "/ui/image.png"
	local container = self:getUI("View_toolbar")
	local children = container:getChildren()
	for _, v in pairs(children) do
		if type(v) == "table" then
			v.flagForToolbar = 1
		end
	end
	for i = 1, #self.toolbarList do
		local toolName = self.toolbarList[i]
		local btn = container:getChildByName(toolName)
		if not btn then
			btn = new(Button, kImageMap.common_transparent)--_blank
			btn:addTo(container)
			btn:setName(toolName)
			btn:setSize(60, 60)
			btn:setOnClick(toolName, function(name)
				self:onToolbarBtnClick(name)
			end)
			local image = new(Image, self.toolRes[toolName] or missedFile)
			image:addTo(btn)
			image:setName("Image")
			image:setAlign(kAlignCenter)
		else
			btn.flagForToolbar = nil
		end
		btn:setPos(0 + 70 * (i - 1), 0)
		if "SendProp" == toolName then
			btn:setPos(0 + 70 * (i - 1), -4)
		end
	end
	local childrenAgain = container:getChildren()
	for _, v in pairs(childrenAgain) do
		if type(v) == "table" and v.flagForToolbar == 1 then
			FwLog("Delete Button " .. v:getName())
			delete(v)
		end
	end
end

function PersonalInfoPopup:initPhotos()
	local photoContainer = self:getUI("View_album")
	self.photoList = {}
	self.photoListInfo = {}
	for i = 1, 4 do 
		local photoBtn = photoContainer:getChildByName("Button_photo_" .. i)
		local photoView = photoBtn:getChildByName("View")
		local photoImage = photoView:getChildByName("Image_photo")
		table.insert(self.photoList, Mask.setMask(photoImage, "/res/userInfo/userInfo_photo_mask.png", {w = 87, h = 79, x = 5, y = 9}))
		photoBtn:setOnClick(i, function(index)
			if self.photoListInfo[index] then
				self:showPhotoGallery(self.photoListInfo[index])
			else
				self:onBtnCameraClick()
			end
		end)
	end
end

function PersonalInfoPopup:onHttpCallback(command, code, data)
	FwLog("PersonalInfoPopup:onHttpCallback, command = " .. command)
	-- if command == "useProps" and self.isUser and code == 1 then
	-- 	for i, v in ipairs(self.tabNames) do
	-- 		if v == "MyProp" then
	-- 			if self.tabViewDict[i] and self.tabViewDict[i].requestProp then
	-- 				self.tabViewDict[i]:requestProp()
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function PersonalInfoPopup:onPersonalInfoCallback(data)
	local mid = data.aUser.mid or 0
	if tonumber(mid) ~= tonumber(self.personalUid) then return end -- may be other response
	self.infoOfPerson = data

	local name = nk.updateFunctions.limitNickLength(data.aUser.name, 15) or ""
	local mlevel = data.aUser.mlevel or 1
	local money = data.aUser.money or 0
	local charm = data.aUser.charm or 0
	local micon = data.aUser.micon or "1" 
	local msex = tonumber(data.aUser.msex) or 0
	local vipLv = tonumber(data.aUser.vip) or 0
	-- if self.isUser then-- temporary statement
	-- 	vipLv = tonumber(nk.userData.vip) or 0
	-- end
	if self.isUser then
		nk.userData.money = money
		nk.userData.vip = vipLv
	end

	local textName = self:getUI("Text_person_name")
	assert(textName, self.s_controls and json.encode(self.s_controls) or "self.s_controls is null")
	textName:setText(name)
	textName:setScrollBarWidth(0)
	self:getUI("Text_person_uid"):setText("ID:" .. mid)
	self:getUI("Text_person_lv"):setText("Lv." .. mlevel)
	self:getUI("Text_person_money"):setText(nk.updateFunctions.formatBigNumber(money))
	self:getUI("Text_person_charm"):setText(charm)
	self:getUI("Image_lv_icon"):setFile("/res/level/level_" .. math.min(30, mlevel)..".png")
	self.LoadIconToNode(self.user_icon, micon, msex, true)

	local data = {}
	data.uid = self.personalUid
	data.micon = micon
	EventDispatcher.getInstance():dispatch(EventConstants.playerIconChange, data)

	local data2 = {}
	data2.uid = self.personalUid
	data2.money = money
	EventDispatcher.getInstance():dispatch(EventConstants.playerMoneyChange, data2)

	local btnUserIcon = self:getUI("Button_userIcon")
	local vipIcon = self:getUI("View_vip")

	if vipLv > 0 then
		self:DrawVip(vipIcon, vipLv)
        textName:setColor(0xa0,0xff,0x00)
	end
	local imgSexFrame = btnUserIcon:getChildByName("Image_sex_frame")
	if msex == 1 then
		self:getUI("Image_sex_icon"):setFile(kImageMap.common_sex_man_icon)
		imgSexFrame:setFile("/res/userInfo/userInfo_usericon_bg_man.png")
	else
		self:getUI("Image_sex_icon"):setFile(kImageMap.common_sex_woman_icon)
		imgSexFrame:setFile("/res/userInfo/userInfo_usericon_bg_woman.png")
	end

	self:getUI("Button_camera"):setEnable(true)
	if self.tabViewDict and self.tabViewDict[self.tabIndex] and self.tabViewDict[self.tabIndex].setData then
		self.tabViewDict[self.tabIndex]:setData(self.infoOfPerson)
	end
	self:refreshToolBarList()
	self:refreshPhoto()
end

function PersonalInfoPopup:DrawVip(node,vipLevel)
    node:removeAllChildren(true)

    local vipbs = new(Image, kImageMap.vip_bs)
    vipbs:setAlign(kAlignCenter)
    vipbs:addPropScaleSolid(0, 0.2, 0.2, kCenterDrawing);
    vipbs:setPos(15,18)
    node:addChild(vipbs) 

    local vipIcon = new(Image,"res/common/vip_big/v.png")
    node:addChild(vipIcon)
    vipIcon:setPos(28,8)
    vipLevel = tonumber(vipLevel)

    if vipLevel >=10 then
        local num1 = math.modf(vipLevel/10)
        local num2 = vipLevel%10

        local vipNum1 = new(Image,"res/common/vip_big/" .. num1 .. ".png")
        vipNum1:setPos(38,8)
        node:addChild(vipNum1)
        local vipNum2 = new(Image,"res/common/vip_big/" .. num2 .. ".png")
        vipNum2:setPos(49,8)
        node:addChild(vipNum2)
    else
        local vipNum = new(Image,"res/common/vip_big/" .. vipLevel .. ".png")
        vipNum:setPos(38,8)
        node:addChild(vipNum)
    end   
end

function PersonalInfoPopup:onBtnThumbUpClick()
	if not self.infoOfPerson then return end
	self:getUI("Button_thumbup"):setEnable(false)
	PersonalInfoDelegate.getInstance():thumbUp({
		uid = self.personalUid,
		mid = nk.UserDataController.getUid(),
		type = 3,
	}, function(data)
		if data and data.code == 1 and checkint(data.data) > 0 then
			if not nk.updateFunctions.checkIsNull(self) then
				self.infoOfPerson.aUser.dyna[5] = 0
			end
		end
	end)
end

function PersonalInfoPopup:refreshPhoto()
	if self.infoOfPerson then
		local images = self.infoOfPerson.aUser.images
		local index = 1
		local iconUrl = self.infoOfPerson.aUser.iconurl
		local micon = self.infoOfPerson.aUser.micon
		if images then
			for k, v in ipairs(images) do
				local fullUrl = v.url
				if not string.find(fullUrl, "http") then
					fullUrl = iconUrl .. v.url
				end
				if v.url ~= "" and fullUrl ~= micon then
					self.photoList[index]:setFile(kImageMap.userInfo_nophoto)
					UrlImage.spriteSetUrl(self.photoList[index], fullUrl)
					self.photoListInfo[index] = fullUrl
					index = index + 1
					if index == 5 then break end
				end
			end
		end
	end
end

function PersonalInfoPopup:onBtnEditUserProfileClick()
	-- FwLog("PersonalInfoPopup:onBtnEditUserProfileClick")
	if self.tabViewDict then
		nk.PopupManager:addPopup(require("game.userInfo.EditSelfInfoPopup"))
		for k, v in ipairs(self.tabNames) do
			if v == "Space" then
				local subView = self.tabViewDict[k]
				if subView then
					subView:uploadChanged()
				end
				break
			end
		end
	end
end

function PersonalInfoPopup:onBtnCameraClick()
	if not self.isUser then return end
	nk.PopupManager:addPopup(require("game.photoManager.photoManagerPopup"), self.currentScene) 
end

function PersonalInfoPopup:onBtnGiftClick()
	if self.ctx then 
		self:openGiftPopupInRoom()
	else
		nk.PopupManager:addPopup(require("game.giftShop.giftShopPopup"), self.currentScene, 2, false, nk.userData.uid)
	end
end

function PersonalInfoPopup:onBtnUserIconClick()
	if self.infoOfPerson and string.find(self.infoOfPerson.aUser.micon, "http") then
		-- see the photo
		self:showPhotoGallery(self.infoOfPerson.aUser.micon)
	else
		self:onBtnCameraClick()
	end
end

function PersonalInfoPopup:showPhotoGallery(url)
    local photoDataList = {}
    local images = self.infoOfPerson.aUser.images
    local iconUrl = self.infoOfPerson.aUser.iconurl
    local index = nil
    if images then
	    for i, v in ipairs(images) do
	        if v and v.url ~= "" then
	        	local fullUrl = v.url
	        	if not string.find(v.url, "http") then
	        		fullUrl = iconUrl .. v.url
	        	end
	            table.insert(photoDataList, fullUrl)
	            if fullUrl == url then
	            	index = #photoDataList
	            end
	        end
	    end
	end
    if index == nil then
    	table.insert(photoDataList, url)
    	index = #photoDataList
   	end 
    local PhotoViewPopup = require('game.photoManager.photoViewPopup')
    nk.PopupManager:addPopup(PhotoViewPopup,"hall",photoDataList, index) 
end

function PersonalInfoPopup:onToolbarBtnClick(toolName)
	-- {"FbPage", "Follow", "Unfollow", "HideMsg", "ShowMsg", "Gift", "Trace"}
	if toolName == "FbPage" then
		nk.FacebookNativeEvent:openPage(self.infoOfPerson.aUser.sitemid)
		nk.AnalyticsManager:report("New_Gaple_info_click_fb")
		-- nk.GameNativeEvent:openBrowser("https://www.facebook.com/" .. self.infoOfPerson.aUser.sitemid)
	elseif toolName == "Follow" then
	elseif toolName == "Unfollow" then
	elseif toolName == "HideMsg" then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "GAG_TIPS"))
		local gagData = self.gagData or nk.DataProxy:getData(nk.dataKeys.ROOM_GAG) or {}
		local isHandled = false
        for k, v in ipairs(gagData) do
			if v and v.uid == self.personalUid then
				v.time = os.time()
				isHandled = true
				break
			end
		end
		if not isHandled then
			table.insert(gagData, {uid = self.personalUid, time = os.time()})
		end
        self.gagData = gagData
        self:refreshToolBarList()
        nk.AnalyticsManager:report("New_Gaple_info_click_fo")
	elseif toolName == "ShowMsg" then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "GAG_CANCEL_TIPS"))
		local gagData = self.gagData or nk.DataProxy:getData(nk.dataKeys.ROOM_GAG) or {}
		for k, v in ipairs(gagData) do
			if v and v.uid == self.personalUid then
				table.removebyvalue(gagData, v)
				break
			end
		end
        self.gagData = gagData
        self:refreshToolBarList()
        nk.AnalyticsManager:report("New_Gaple_info_click_fo")
	elseif toolName == "Gift" then
		if self.isUser then
			if self.ctx then 
				self:openGiftPopupInRoom()
			else
				nk.PopupManager:addPopup(require("game.giftShop.giftShopPopup"), self.currentScene, 2, false, nk.userData.uid)
			end 
		else
			nk.AnalyticsManager:report("New_Gaple_friend_gift", "friend_gift")
			if self.ctx then -- viewIndex, isRoom, uid, allTableId, tableNum, toUidArr, level, notRoom
				self:openGiftPopupInRoom()
			else
				nk.PopupManager:addPopup(require("game.giftShop.giftShopPopup"), self.currentScene, 1, false, self.personalUid,"",0,{self.personalUid}, 0, true)
			end
		end
		nk.AnalyticsManager:report("New_Gaple_info_click_gf")
	elseif toolName == "Trace" then
		local ret = nk.SocketController:trackFriend(self.personalUid)
		if ret then
    		EnterRoomManager.getInstance():enterRoomLoading()
    	else
    		nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL_2"))
    	end
    	nk.AnalyticsManager:report("New_Gaple_info_click_tr")
	elseif toolName == "DelFrd" then
		local params = {}
        params.mid = nk.userData.mid
        params.fid = self.personalUid
        nk.HttpController:execute("deleteFriend", {game_param = params})
        self:getUI("View_toolbar"):getChildByName(toolName):setEnable(false)
	elseif toolName == "AddFrd" then
		nk.AnalyticsManager:report("New_Gaple_rank_add", "rank")
        local params = {}
        params.mid = nk.userData.mid
        params.fid = self.personalUid
        nk.HttpController:execute("addFriend", {game_param = params})
        self:getUI("View_toolbar"):getChildByName(toolName):setEnable(false)
	elseif toolName == "SendProp" then
		local SendPropPopup = require("game.userInfo.myprop.sendPropPopup")
		nk.PopupManager:addPopup(SendPropPopup, self.currentScene, self.infoOfPerson)
		nk.AnalyticsManager:report("New_Gaple_click_sendprop_personinfo")
	elseif toolName == "Report" then
        self:createReportView()
		nk.AnalyticsManager:report("New_Gaple_info_click_report")
	elseif toolName == "FbBind" then
		local fbBindingPopup = require("game.userInfo.fbBindingPopup")
		nk.PopupManager:addPopup(fbBindingPopup)  
	elseif toolName == "FbBinded" then
		local fbBindStatus = nk.DictModule:getInt("gameData", nk.cookieKeys.GUEST_BIND_FB_STATUS, -5)
	    if fbBindStatus == 1 then
	        local fbName = nk.DictModule:getString("gameData", nk.cookieKeys.GUEST_BIND_FB_NAME, "")
	        if fbName ~= "" then
	            nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL4", fbName))
	        else
	            nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL2"))
	        end
	    end
	end
end

local function handler2(func, ...)
    local args = {...}
    return function(obj)
        func(obj, unpack(args))
    end
end

function PersonalInfoPopup:createReportView()
	local container = self:getUI("View_toolbar")
    local reportBtn = container:getChildByName("Report")
    local minW = 180

    local reportConfig = nk.reportConfig:getReportConfig()
    if reportConfig and reportConfig.list then

    	local btnNum = 0
    	for i,v in pairs(reportConfig.list) do
    		btnNum = btnNum + 1
    	end

    	if btnNum <= 0 then
    		return
    	end

	    local reportView = reportBtn:getChildByName("reportView")
	    if not reportView then
		    reportView = new(Node)
		    reportView:setName("reportView")
		    reportView:setAlign(kAlignTop)
		    reportBtn:addChild(reportView)

		    local reportBg = new(Image,kImageMap.scoreqp,nil,nil,50,20,15,25)
		    reportBg:setAlign(kAlignBottomLeft)
		    reportBg:setPos(-40,0)
		    reportView:addChild(reportBg)

		    local btn = new(Button,"res/common/common_btn_purple_s.png")
			local btnW = btn:getSize()
			local startX = 0 - (btnNum - 1) * (btnW + 10) * 0.5
			local count = 0
		    for i,v in pairs(reportConfig.list) do
		    	count = count + 1
		    	local sendReportBtn = new(Button,"res/common/common_btn_purple_s.png")
			    sendReportBtn:setPos(startX + (btnW + 10) * (count - 1),10+40+5)
			    sendReportBtn:setAlign(kAlignTop)
			    reportBg:addChild(sendReportBtn)
			    sendReportBtn:setOnClick(self, handler2(self.onSendReportBtnClick,tonumber(i),v))

			    local btnText = new(Text, v, 150, 50, kAlignCenter, nil, 18)
			    btnText:setAlign(kAlignCenter)
			    sendReportBtn:addChild(btnText)
		    end

		    local bgW = btnNum*(btnW + 10) > minW and btnNum*(btnW + 10) or minW
		    reportBg:setSize(bgW , 40 + 80)

		    local text = bm.LangUtil.getText("USERINFO", "REPORT_TIPS", checkint(reportConfig.num))
		    local testText = new(TextView,text,bgW-30,0,kAlignTopLeft,nil,16,255,255,255)
		    local w,h = testText:getSize()
		    delete(testText)
		    testText = nil

		    local tips = new(TextView,text,w,40,kAlignCenter,nil,16,255,255,255)
		    tips:setPos(0,10)
		    tips:setAlign(kAlignTop)
		    reportBg:addChild(tips)
		else
			reportView:setVisible(not reportView:getVisible())
		end
		self.reportView = reportView
	end
end

function PersonalInfoPopup:onPopBgTouch()
	if self.reportView then
		self.reportView:setVisible(false)
	end
end

function PersonalInfoPopup:onSendReportBtnClick(index, reportContent)
	local container = self:getUI("View_toolbar")
    local reportBtn = container:getChildByName("Report")
    local reportView = reportBtn:getChildByName("reportView")
    if reportView then
    	reportView:setVisible(false)
    end
    if index then
    	nk.reportConfig:report(self.personalUid, index, reportContent)
    end
end

function PersonalInfoPopup:openGiftPopupInRoom()
	if self.ctx then -- viewIndex, isRoom, uid, allTableId, tableNum, toUidArr, level, notRoom
		local GiftShopPopup = import("game.giftShop.giftShopPopup")
		local roomUid = ""
	    local roomOtherUserUidArray = ""
	    local tableNum = 0
	    local toUidArr = {}
	    local level = self.ctx.model:roomType()
		for i = 0, 8 do
        	if self.ctx.model.playerList[i] then
	            if self.ctx.model.playerList[i].uid > 0 then
	                tableNum = tableNum + 1
	                roomUid = roomUid..","..self.ctx.model.playerList[i].uid
	                roomOtherUserUidArray = string.sub(roomUid,2)
	                table.insert(toUidArr, self.ctx.model.playerList[i].uid)
	            end
	        end
	    end
		nk.PopupManager:addPopup(GiftShopPopup, self.currentScene, 1, true, self.personalUid, roomOtherUserUidArray, tableNum, toUidArr, level)
		self:hide()
	end
end

function PersonalInfoPopup:onTabControllerCallback(tabIndex)
	self.tabViewDict = self.tabViewDict or {}
	self.tabIndex = tabIndex
	if not self.tabViewDict[tabIndex] then
		local tabName = self.tabNames[tabIndex]
		local subView = nil
		local container = self:getUI("Image_subview")
		local width, height = container:getSize()
		if tabName == "Detail" then
			subView = new(PersonalDetailView, width, height, self)
		elseif tabName == "Space" then
			subView = new(PersonalSpaceView, 
				require(VIEW_PATH .. "userInfo/personalInfoSpace_view"), 
				VIEW_PATH .. "userInfo/personalInfoSpace_view_layout_var",
				self)
		elseif tabName == "HDProp" then
			subView = new(PersonalHDPropView, width, height, self)--0, 5, 564, 220, false
			subView.onShowFunc = function()
				self:getUI("View_hd_prop_plugin"):setVisible(true)
			end
			subView.onHideFunc = function()
				self:getUI("View_hd_prop_plugin"):setVisible(false)
			end
		elseif tabName == "MyProp" then
			subView = new(PersonalMyPropView, width, height, self)
		elseif tabName == "RecentExp" then
			subView = new(PersonalRecentExpView, 0, 0, width, height, false, self)
		end
		if subView then
			subView:addTo(container)
			subView:setAlign(kAlignTopLeft)
			self.tabViewDict[tabIndex] = subView
			-- if subView.setPopup then
			-- 	subView:setPopup(self)
			-- end
		end
	end
	for index, subView in pairs(self.tabViewDict) do
		local isShow = tabIndex == index
		subView:setVisible(isShow)
		if subView.setData and self.infoOfPerson then
			subView:setData(self.infoOfPerson)
		end
		if isShow and subView.onShowFunc then
			subView.onShowFunc()
		elseif not isShow and subView.onHideFunc then
			subView.onHideFunc()
		end
	end
end

-- 礼物资源加载成功
function PersonalInfoPopup:onGiftLoadedCallback(url)
	self.giftUrlReqId_ = nil
	if not nk.updateFunctions.checkIsNull(self) then
		local image = self:getUI("Image_gift_icon")
		if image then
			if url and string.len(url) > 5 then
				UrlImage.spriteSetUrl(image, url)
			else
				image:setFile("/res/common/common_gift_icon.png")
			end
		end
	end
end

-- [UserPopup] 礼物改变
function PersonalInfoPopup:onGiftChangedCallback(giftId)
	if not nk.updateFunctions.checkIsNull(self) then
		if self.giftUrlReqId_ then
			LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
		end
		self.giftId = giftId
		if self.giftId then
			self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(self.giftId, handler(self, self.onGiftLoadedCallback))
		end
	end
end

-- [UserPopup] 头像改变
function PersonalInfoPopup:onIconChangedCallback(micon)
	if not nk.updateFunctions.checkIsNull(self) then
		if self.infoOfPerson and self.isGoingToRefreshPhoto == nil then
			self.isGoingToRefreshPhoto = Clock.instance():schedule_once(function()
				if not nk.updateFunctions.checkIsNull(self) then
					self.LoadIconToNode(self.user_icon, micon, self.infoOfPerson.aUser.msex, true)
					self.infoOfPerson.aUser.images = nk.userData.photos
					self.infoOfPerson.aUser.micon = micon
					self:refreshPhoto()
					self.isGoingToRefreshPhoto = nil
				end
			end, 0)
		end
	end
end

function PersonalInfoPopup:onPersonalPhotoUpdate()
	self:onIconChangedCallback(nk.userData.micon)
end

function PersonalInfoPopup:onUpdateFBBindStatus()
	self:refreshToolBarList()
end

function PersonalInfoPopup:onFBindexChangedCallback(FBindex)
	if not nk.updateFunctions.checkIsNull(self) then
		if self.infoOfPerson then
			self.infoOfPerson.aUser.FBindex = FBindex
			self:refreshToolBarList()
		end
	end
end

function PersonalInfoPopup:onSignatureChanged(sign)
	if self.infoOfPerson then
		self.infoOfPerson.aUser.sign = sign
	end
end

function PersonalInfoPopup:onNameChangedCallback(name)
	if self.infoOfPerson then
		self.infoOfPerson.aUser.name = name
		self:getUI("Text_person_name"):setText(name)
	end
end

function PersonalInfoPopup:onMoneyChangedCallback(money)
	if self.infoOfPerson then
		self.infoOfPerson.aUser.money = money
		self:getUI("Text_person_money"):setText(nk.updateFunctions.formatBigNumber(money))
	end
end

function PersonalInfoPopup:onSexChangedCallback(sex)
	if self.infoOfPerson then
		self.infoOfPerson.aUser.msex = sex
		local btnUserIcon = self:getUI("Button_userIcon")
		local imgSexFrame = btnUserIcon:getChildByName("Image_sex_frame")
		if tonumber(sex) == 1 then
			self:getUI("Image_sex_icon"):setFile(kImageMap.common_sex_man_icon)
			imgSexFrame:setFile("/res/userInfo/userInfo_usericon_bg_man.png")
		else
			self:getUI("Image_sex_icon"):setFile(kImageMap.common_sex_woman_icon)
			imgSexFrame:setFile("/res/userInfo/userInfo_usericon_bg_woman.png")
		end
		self.LoadIconToNode(self.user_icon, self.infoOfPerson.aUser.micon, self.infoOfPerson.aUser.msex, true)
	end
end

-- 用户若被点赞，则刷新魅力值
function PersonalInfoPopup:onThumbUpedCallback(uid, type, data, fromOrnil)
	if uid == self.personalUid and self.infoOfPerson then -- 很有可能回包的时候又打开了面板，self.infoOfPerson只有在第二个回包才有值
		self.infoOfPerson.aUser.mcharm = (tonumber(self.infoOfPerson.aUser.mcharm) or 0) + 1
	   	self.infoOfPerson.aUser.charm = (tonumber(self.infoOfPerson.aUser.charm) or 0) + 1
	   	local fromX, fromY
	   	if type == 3 then
	   		fromX, fromY = self:getUI("Button_thumbup"):getAbsolutePos()
	   	else
	   		if fromOrnil then
	   			fromX, fromY = fromOrnil.x, fromOrnil.y
	   		else
		   		local subView = self:getSubView("Space")
		   		if subView then
		   			fromX, fromY = subView:getUI("Button_thump_up"):getAbsolutePos()
		   		end
		   	end
	   	end
	   	local onComplete = function()
			self:getUI("Text_person_charm"):setText(self.infoOfPerson.aUser.charm)
		   	-- refresh detail
		   	local subView = self:getSubView("Detail")
		   	if subView then
				subView:setData(self.infoOfPerson)
			end
		end
	   	if fromX and fromY then
			local w, h = self:getUI("Image_ThumbIcon"):getSize()
			local toX, toY = self:getUI("Image_ThumbIcon"):getAbsolutePos()
			self.flyingThumbs = self.flyingThumbs or {}
			table.insert(self.flyingThumbs, self.PlayFlyingThumb({from = {x = fromX - 8, y = fromY - 7}, to = {x = toX - 8, y = toY - 8},
				onComplete = onComplete}))
		else
			onComplete()
		end
	end
end



function PersonalInfoPopup.LoadIconToNode(nodeImage, micon, msex, isAvatar)
	if string.find(micon, "http") then
        -- local index = tonumber(micon) or 1
        -- nodeImage:setFile(nk.s_headFile[index])-- 默认头像 
        nodeImage:setFile(kImageMap.userInfo_nophoto)
    	UrlImage.spriteSetUrl(nodeImage, micon)-- 上传的头像
    else
    	if tonumber(msex) == 1 then
	    	nodeImage:setFile("res/photoManager/avatar_big_male.png")
	    else
	    	nodeImage:setFile("res/photoManager/avatar_big_female.png")
	    end
    end 
end

function PersonalInfoPopup:onAddFriendCallback(status, data)
    if status and tonumber(data.mid) == tonumber(self.personalUid) then
        local container = self:getUI("View_toolbar")
        local btn = container:getChildByName("AddFrd")
        if btn then
        	btn:setName("DelFrd")
        	btn:setOnClick("DelFrd", function(name)
				self:onToolbarBtnClick(name)
			end)
        	btn:getChildByName("Image"):setFile(self.toolRes["DelFrd"])
        	btn:setEnable(true)
        end
    end
end

function PersonalInfoPopup:onDelFriendCallback(status, mid)
    if status and tonumber(mid) == tonumber(self.personalUid) then
        local container = self:getUI("View_toolbar")
        local btn = container:getChildByName("DelFrd")
        if btn then
        	btn:setName("AddFrd")
        	btn:setOnClick("AddFrd", function(name)
				self:onToolbarBtnClick(name)
			end)
        	btn:getChildByName("Image"):setFile(self.toolRes["AddFrd"])
        	btn:setEnable(true)
        end
    end
end

function PersonalInfoPopup:getSubView(subViewName)
	for k, v in ipairs(self.tabNames) do
		if v == subViewName then
			local subView = self.tabViewDict[k]
			if subView then
				return subView
			end
		end
	end
	return nil
end

function PersonalInfoPopup.RepresentTime(timeStamp)
    local strToday = os.date("%x")
    -- local strTomorrow = os.date("%x", os.time() + 24 * 3600)
    local strTime = os.date("%x", timeStamp)
    if strTime == strToday then
    	local tabTime = os.date("*t", timeStamp)
        return string.format("%02d:%02d", tabTime.hour, tabTime.min)
    else
    	local tabTime = os.date("*t", timeStamp)
    	-- local tabTodayTime = os.date("*t")
    	-- if tabTime.year == tabTodayTime.year then
    	-- 	return string.format("%02d-%02d", tabTime.month, tabTime.day)
	    -- else
	    	return string.format("%02d-%02d-%02d", tabTime.year, tabTime.month, tabTime.day)
	    -- end
    end
end

function PersonalInfoPopup.PlayFlyingThumb(params)
	params = params or {}
	local from = params.from or {x = 100, y = 400}
	local to = params.to or {x = 500, y = 400}
	local onComplete = params.onComplete
	local image = new(Image, kImageMap.thumb_up)
	image:addToRoot()
	image:addPropScaleSolid(1, 0.8, 0.8, kCenterDrawing)
	image:setLevel(10000)
	local anim = image:addPropTranslate(0, kAnimNormal, 0.5*1000, 0, from.x, to.x, from.y, to.y)
	anim:setEvent(nil, function()
		delete(image)
		if onComplete then onComplete() end
	end)
	return image
end

return PersonalInfoPopup