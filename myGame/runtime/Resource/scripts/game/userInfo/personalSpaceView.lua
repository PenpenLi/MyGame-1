local PersonDynamicPopup = require("game.dynamic.personDynamicPopup")
local PersonalInfoDelegate = require("game.userInfo.personalInfoDelegate")
local PersonalSpaceView = class(GameBaseLayer)

function PersonalSpaceView:ctor(viewConfig, varConfig, popup)
	self.popup = popup
	self:initView()

	if self.popup.isUser then
		self.propertyHandlers = {}
		self.propertyNames = {"sign", "dyna", "tdyna"}
		local hanlders = {
			handler(self, self.onSignatureChanged),
			handler(self, self.onDynamicsChanged),
			handler(self, self.onDynamicsCntChanged),
		}
		for i = 1, #self.propertyNames do
			table.insert(self.propertyHandlers, nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, 
				self.propertyNames[i], hanlders[i]))
		end
	end

	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
	if not self.popup.isUser then
		EventDispatcher.getInstance():register(EventConstants.THUMB_UP, self, self.onThumbUpedCallback)
	end
end

function PersonalSpaceView:dtor()
	if self.propertyHandlers then
		for i = 1, #self.propertyHandlers do
			nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, self.propertyNames[i], self.propertyHandlers[i])
		end
		self.propertyHandlers = nil
	end
	if self.infoOfPerson and self.popup.isUser then --需要
		self:uploadChanged()
	end
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
	if not self.popup.isUser then
		EventDispatcher.getInstance():unregister(EventConstants.THUMB_UP, self, self.onThumbUpedCallback)
	end
end

function PersonalSpaceView:onHttpProcesser(command, code, content)
	
end

function PersonalSpaceView:onThumbUpedCallback(uid, type, content)
	if self.infoOfPerson and content.data > 0 and content.data == self.infoOfPerson.aUser.dyna[4] then -- dynamItem页面点赞msgid如果是最近动态，点赞数加1
		self.infoOfPerson.aUser.dyna[3] = (tonumber(self.infoOfPerson.aUser.dyna[3]) or 0) + 1
		self.infoOfPerson.aUser.dyna[5] = 0
		self:getUI("Text_thumpUp_num"):setText(self.infoOfPerson.aUser.dyna[3])
		self:getUI("Button_thump_up"):setEnable(false)
	end
end

function PersonalSpaceView:uploadChanged()
	local text = string.trim(self:getUI("Edit_signature"):getText())
	if text ~= nk.UserDataController.getUserSign()[1] and text ~= "" then
		local EditSelfInfoPopup = require("game.userInfo.EditSelfInfoPopup")
		EditSelfInfoPopup.UploadSignature(text)
	end
end

function PersonalSpaceView:initView()
	self:getUI("Button_publish"):setVisible(false)
	self:getUI("Button_delete"):setVisible(false)
	self:getUI("Button_thump_up"):setEnable(false)
	self:getUI("Edit_signature"):setEnable(false)
	-- self:getUI("Edit_signature"):setPickable(false)
	self:getUI("Edit_signature"):setScrollBarWidth(0)
	self:getUI("Image_edit_sign"):setVisible(false)

	self:getUI("Text_signature_key"):setText(bm.LangUtil.getText("USERINFO", "KEY_SIGNATURE"))	
	self:getUI("Text_news_key"):setText(bm.LangUtil.getText("USERINFO", "KEY_NEW_ACTIVITY"))	
	self:getUI("Text_news_date"):setText("")	
	
	local content = bm.LangUtil.getText("USERINFO", "ACTIVITY_EMPTY")
	self:getUI("Text_news_content"):setText(content, nil, nil, 0xab, 0x5f, 0xec)
	if self.popup.isUser then
		self:getUI("Edit_signature"):setMaxLength(50)
		self:getUI("Edit_signature"):setHintText(bm.LangUtil.getText("USERINFO", "SIGN_HINT_TEXT"), 0xab, 0x5f, 0xec)
	else
		self:getUI("Edit_signature"):setText(content, nil, nil, 0xab, 0x5f, 0xec)
	end
	local thumbUpCnt = 0
	self:getUI("Text_thumpUp_num"):setText(thumbUpCnt)
	local btnSeeAll = self:getUI("Button_see_all")
	local totalCnt = "?"
	local keyStringBtnSeeAll = bm.LangUtil.getText("USERINFO", "BTN_SEE_ALL", totalCnt)
	local richText = new(RichText,"#u"..keyStringBtnSeeAll .."#n", nil, nil, kAlignLeft, "", 20, 0xc7, 0x7f, 0xf1, false, 0)
	richText:addTo(btnSeeAll)
	self.richText = richText
	local w, h = richText:getSize()
	self:getUI("Button_see_all"):setSize(w, 26)
	btnSeeAll:getChildByName("Text17"):setVisible(false)
end

function PersonalSpaceView:setData(data)
	self.infoOfPerson = data
	if data.aUser.mid == nk.userData.uid then
		self:getUI("Button_publish"):setVisible(true)
		self:getUI("Button_delete"):setVisible(true)
		self:getUI("Button_thump_up"):setEnable(false)
		self:getUI("Edit_signature"):setEnable(true)
		self:getUI("Image_edit_sign"):setVisible(true)
	else
		self:getUI("Button_publish"):setVisible(false)
		self:getUI("Button_delete"):setVisible(false)
		self:getUI("Button_thump_up"):setEnable(true)
		self:getUI("Edit_signature"):setEnable(false)
		self:getUI("Image_edit_sign"):setVisible(false)
	end

	if data.aUser.sign and data.aUser.sign[1] ~= "" then
		self:getUI("Edit_signature"):setText(data.aUser.sign[1], nil, nil, 255, 255, 255)
	end
	self:onDynamicsCntChanged(data.aUser.tdyna)
	self:refreshDynaView()
end

function PersonalSpaceView:refreshDynaView()
	local data = self.infoOfPerson
	if data.aUser.dyna and data.aUser.dyna[1] and data.aUser.dyna[1] ~= "" then
		self:getUI("Text_news_date"):setVisible(true)
		self:getUI("Text_news_date"):setText(self.popup.RepresentTime(data.aUser.dyna[2]))	
		self:getUI("Text_news_content"):setText(data.aUser.dyna[1], nil,  nil, 255, 255, 255)	
		self:getUI("Text_thumpUp_num"):setText(data.aUser.dyna[3])
		self:getUI("Button_see_all"):setVisible(true)
		self:getUI("Button_thump_up"):setVisible(true)
		self:getUI("Text_thumpUp_num"):setVisible(true)
		self:getUI("Button_delete"):setVisible(self.popup.isUser)
		if self.infoOfPerson.aUser.dyna[5] ~= 1 then
			self:getUI("Button_thump_up"):setEnable(false)
		end
		-- local totalCnt = tonumber(self.infoOfPerson.aUser.tdyna) or 0
		-- local keyStringBtnSeeAll = bm.LangUtil.getText("USERINFO", "BTN_SEE_ALL", totalCnt)
		-- self.richText:setText("#u"..keyStringBtnSeeAll .."#n")
	else
		self:getUI("Text_news_date"):setVisible(false)
		local content = bm.LangUtil.getText("USERINFO", "ACTIVITY_EMPTY")
		self:getUI("Text_news_content"):setText(content, nil,  nil, 0xab, 0x5f, 0xec)
		self:getUI("Text_thumpUp_num"):setVisible(false)
		self:getUI("Button_thump_up"):setVisible(false)
		self:getUI("Button_delete"):setVisible(false)
		self:getUI("Button_see_all"):setVisible(false)
	end
end

function PersonalSpaceView:onBtnPublishClick()
	nk.PopupManager:addPopup(require("game.userInfo.WritePersonDynamics"))
end


function PersonalSpaceView:onBtnDeleteClick()
	if self.infoOfPerson.aUser.dyna[5] == 1 then
		local args = {
		    messageText = T("是否删除动态"), 
		    callback = function (type)
		        if type == nk.Dialog.SECOND_BTN_CLICK then
                    self:onSureDeleteCallBack()
                end
		    end
		}
		nk.PopupManager:addPopup(nk.Dialog, self.popup.currentScene, args)
	end
end

function PersonalSpaceView:onSureDeleteCallBack()
	nk.HttpController:execute("Social.delDynamic", {game_param = {
			mid = self.popup.personalUid,
			msgid = self.infoOfPerson.aUser.dyna[4],
			isinfo = 1,
		}}, nil, function(errorCode, data)
		if errorCode == 1 and data and data.code == 1 then
			self:getUI("Button_delete"):setEnable(true)
			nk.userData.tdyna = math.max((tonumber(nk.userData.tdyna) or 1) - 1, 0)
	        if type(data.data) == "number" then
	        	nk.UserDataController.setUserDyna({"", 0, 0, 0, 0})
	        else
	        	nk.UserDataController.setUserDyna(data.data[2])
	        end
	        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "DELDYNAMIC_SUCC"))  
	    else
	        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "DELDYNAMIC_FAIL"))   
	    end
	end)
	nk.AnalyticsManager:report("New_Gaple_delete_dyna")
end

function PersonalSpaceView:onSignatureChanged(sign)
	if self.infoOfPerson then
		self.infoOfPerson.aUser.sign = sign
		if sign[1] == "" then
			if self.popup.isUser then
				self:getUI("Edit_signature"):setText("")
			else
				self:getUI("Edit_signature"):setText(bm.LangUtil.getText("USERINFO", "ACTIVITY_EMPTY"), nil, nil, 0xab, 0x5f, 0xec)
			end
		else
			self:getUI("Edit_signature"):setText(sign[1], nil, nil, 255, 255, 255)
		end
	end
end

function PersonalSpaceView:onDynamicsChanged(dyna)
	if self.infoOfPerson then
		self.infoOfPerson.aUser.dyna = dyna
		self:refreshDynaView()
	end
end

function PersonalSpaceView:onDynamicsCntChanged(cnt)
	if self.infoOfPerson then
		-- FwLog(">>>>>>>>>>>>>>>>>>> onDynamicsCntChanged cnt = " .. cnt)
		self.infoOfPerson.aUser.tdyna = cnt
		local totalCnt = tonumber(self.infoOfPerson.aUser.tdyna) or 0
		local keyStringBtnSeeAll = bm.LangUtil.getText("USERINFO", "BTN_SEE_ALL", totalCnt)
		self.richText:setText("#u"..keyStringBtnSeeAll .."#n")
	end
end

function PersonalSpaceView:onButtonThumpUpClick()
	if self.infoOfPerson.aUser.dyna[5] == 1 then
		self:getUI("Button_thump_up"):setEnable(false)
		PersonalInfoDelegate.getInstance():thumbUp({
			uid = self.popup.personalUid,
			mid = nk.UserDataController.getUid(),
			type = 1,
			msgid = self.infoOfPerson.aUser.dyna[4],
		})
	end
end

function PersonalSpaceView:onBtnSeeAllClick()
	if self.infoOfPerson then
		nk.PopupManager:addPopup(PersonDynamicPopup, self.popup.currentScene, self.infoOfPerson.aUser.mid)
	end
end

return PersonalSpaceView