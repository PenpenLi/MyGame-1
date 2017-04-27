-- LogoutPopup.lua
-- Date : 2016-08-05
-- Description: 
local PopupModel = import('game.popup.popupModel')
local logoutView = require(VIEW_PATH .. "logout/logout_layer")
local logoutInfo = VIEW_PATH .. "logout/logout_layer_layout_var"
local LogoutController = import('game.logout.logoutController')
local TaskPopup = require("game.task.taskPopup")
local LogoutPopup= class(PopupModel);

function LogoutPopup.show(data)
	PopupModel.show(LogoutPopup, logoutView, logoutInfo, {name="LogoutPopup"}, data)
end

function LogoutPopup.hide()
	PopupModel.hide(LogoutPopup)
end

function LogoutPopup:ctor(viewConfig)
	Log.printInfo("LogoutPopup.ctor");
    self:addShadowLayer()
    self:initLayer()
end 

function LogoutPopup:initLayer()
     self:initWidget()
     self:initData()
end

function LogoutPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)  
     
    self.bt_sure_ = self:getUI("Button_sure")
    self.bt_sure_:setOnClick(self,self.bt_sure_click)
    self:getUI("Text_sure"):setText(bm.LangUtil.getText("COMMON", "LOGOUT"))

    self.bt_cancel_ = self:getUI("Button_cancel")
    self.bt_cancel_:setOnClick(self,self.bt_cancel_click)
    self:getUI("Text_cancel"):setText(bm.LangUtil.getText("COMMON", "CONTINUE"))

    self:getUI("Text_title"):setText(bm.LangUtil.getText("COMMON", "LOGOUT"))

    self.text_tip_ =  self:getUI("Text_tip")
    self.text_tip_:setVisible(false)

    self.text_left_tilte_ = self:getUI("Text_left_title")
    self.textview_left_content_ = self:getUI("TextView_left_content")
    self.image_left_item_ = self:getUI("Image_left_item")

    self.text_right_title_ = self:getUI("Text_right_title")
    self.textview_right_content_ = self:getUI("TextView_right_content")
    self.image_right_item_ = self:getUI("Image_right_item")


    self.text_left_goto_ = self:getUI("Text_left_goto")
    self.text_left_goto_:setText(bm.LangUtil.getText("SETTING", "SHARE_APK"))
    self.text_left_goto_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:left_text_click()
                                          end
                                          end)  

    self.text_right_goto_ = self:getUI("Text_right_goto")
    self.text_right_goto_:setText(bm.LangUtil.getText("SETTING", "SHARE_APK_TIP"))
    self.text_right_goto_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:right_text_click()
                                          end
                                          end)  
end

function LogoutPopup:initData()
	--????????
	if nk.userData.loginReward and nk.userData.loginReward.day and nk.userData.loginReward.days then
		local day = checkint(nk.userData.loginReward.day) + 1
		if day > 6 then
			day = 6
		end
        if nk.userData.loginReward.days[day] then
    		local tipString = bm.LangUtil.getText("LOGOUT", "TIP_TEXT", " " .. nk.userData.loginReward.days[day] .. " ")
            self.text_tip_:setVisible(true)
            self.text_tip_:setText(tipString)
        end
	end

    if nk.userData.LOGOUT_JSON then
        LogoutController:getInstance():loadConfig(nk.userData.LOGOUT_JSON, function(success, data)
            if success then
                self.logoutData_ = data
                Log.dump(data, "logoutData")
                if data and data.right then
	                self.text_right_title_:setText(data.right.title)
	                self.text_right_goto_:setText(data.right.act .. " >")
	                if data.right.content and data.right.content ~= "" then
				    	self.textview_right_content_:setText(data.right.content)
				    	self.image_right_item_:setVisible(false)
				    elseif data.right.pic and data.right.pic ~= "" then
				    	self.textview_right_content_:setVisible(false)
                        UrlImage.spriteSetUrl(self.image_right_item_, data.right.pic)
				    end
				    
				end
				if data and data.left then
	                self.text_left_tilte_:setText(data.left.title)
	                self.text_left_goto_:setText(data.left.act .. " >")
	                if data.left.content and data.left.content ~= "" then
				    	self.textview_left_content_:setText(data.left.content)
				    	self.image_left_item_:setVisible(false)
				    elseif data.left.pic and data.left.pic ~= "" then
				    	self.textview_left_content_:setVisible(false)
                        UrlImage.spriteSetUrl(self.image_left_item_, data.left.pic)
				    end
				    
				end
            end
        end)
    end
end

function LogoutPopup:left_text_click()
   self:hide()
	if self.logoutData_ and self.logoutData_.left and self.logoutData_.left.condition then
        local tcontents = json.decode(self.logoutData_.left.condition)
        self:goToDo(tcontents[1][1], tcontents[1][3], tcontents[1][4])
    end
end

function LogoutPopup:right_text_click()
    self:hide()
    if self.logoutData_ and self.logoutData_.right and self.logoutData_.right.condition then
        local tcontents = json.decode(self.logoutData_.right.condition)
        self:goToDo(tcontents[1][1], tcontents[1][3], tcontents[1][4])
    end   
end

function LogoutPopup:goToDo(goToType, goLevel, goGameType)
    if goToType >= 5 and goToType <=10 then  --????????????
        if goLevel > 0 then
             nk.SocketController:getRoomAndLogin(goLevel, 0)
        else
             nk.SocketController:quickPlayQiuQiu()
        end 
    elseif goToType == 11 or goToType == 12 then
        local InviteScene = require("game.invite.inviteScene")
        nk.PopupManager:addPopup(InviteScene,"hall")
    elseif goToType == 21 then
        nk.ActivityNativeEvent:activityOpen()
    elseif goToType == 22 then
        nk.GameNativeEvent:openBrowser(nk.userData.commentUrl)
    elseif goToType == 23 then
        nk.PopupManager:addPopup(TaskPopup,"hall")
    end
end

function LogoutPopup:bt_sure_click()
    EventDispatcher.getInstance():dispatch(EventConstants.logout)
end

function LogoutPopup:bt_cancel_click()
    self:hide()
    nk.SocketController:quickPlayQiuQiu()
end

function LogoutPopup:dtor()
    Log.printInfo("LogoutPopup.dtor");
    LogoutController:getInstance():autoDispose()
end 


return LogoutPopup