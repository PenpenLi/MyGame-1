-- SettingPopup.lua
-- Data : 2016-06-01

local PopupModel = import('game.popup.popupModel')
local AboutPopup = require("game.setting.aboutPopup")
local RulesPopup = require("game.setting.rulesPopup")
local LogoutPopup = require("game.logout.logoutPopup")
local FeedbackPopup = require("game.setting.feedbackLayer")
local settingView = require(VIEW_PATH .. "setting/setting_layer")
local settingInfo = VIEW_PATH .. "setting/setting_layer_layout_var"

local SettingPopup= class(PopupModel);

--settingLayer.getInstance = function ()
--	if not settingLayer.s_instance then
--		settingLayer.s_instance = new(settingLayer,settingView);
--        settingLayer.s_instance:addToRoot() 
--       settingLayer.s_instance:setFillParent(true,true);
--	end
--	return settingLayer.s_instance;
--end

function SettingPopup.show(data)
	PopupModel.show(SettingPopup, nil, nil, {name="SettingPopup"}, data)
end

function SettingPopup.hide()
	PopupModel.hide(SettingPopup)
end

function SettingPopup:ctor(viewConfig)
  Log.printInfo("SettingPopup.ctor");
  self:addShadowLayer(kImageMap.common_transparent_blank)

  self.loaderInfo = SceneLoader.loadAsync(settingView, function(ret)
    if tolua.isnull(self) then
      delete(ret)
      return
    end
    self.m_root = ret
    self.m_root:addTo(self)
    self.m_controlsMap = {}
    self:addEventListeners()
    if settingInfo then
      self:declareLayoutVar(settingInfo)
    end
    if self.showOutPopup then
      self.showOutPopup()
    end
    self:initLayer()
  end)
end 

function SettingPopup:resume()
    GameBaseLayer.resume(self);    
end

function SettingPopup:initLayer()
    self:initWidget()
    self:initUserData()
    local itemClass = require(VIEW_PATH .. "setting/setting_item")
    SceneLoader.loadAsync(itemClass, function(ret)
      if tolua.isnull(self) then
        delete(ret)
        return
      end
      self:createSettingList(ret)
      self:initData()
      -- 反馈红点
      self.feedbackHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "feedbackPoint", handler(self, function(obj, visible)
        self.image_fb_redPoint_:setVisible(visible)
      end))
    end)
end

function SettingPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_,15,13)
    self.image_head_ = self:getUI("Image_head")
    self.image_head_ = Mask.setMask(self.image_head_, kImageMap.common_head_mask_min)
    self.text_name_ = self:getUI("Text_name")
    self.text_id_ = self:getUI("Text_id")
    self.text_type_ = self:getUI("Text_type")
    self.button_switch_account_ = self:getUI("Button_switch_account")
    self.button_switch_account_:setOnClick(self,self.switch_account_bt_click)
    self:getUI("Text_title"):setText(bm.LangUtil.getText("SETTING","TITLE")) 
    self.text_logout_ = self:getUI("Text_switch_account")
    self.text_logout_:setText(bm.LangUtil.getText("SETTING","LOGOUT"))
    self.text_logout_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:switch_account_bt_click()
                                          end
                                          end)   
    
    self.button_switch_account_:setVisible(not nk.isInRoomScene)
    self.text_logout_:setVisible(not nk.isInRoomScene)

    self.view_clip_ = self:getUI("View_clip")
    local w,h = self.view_clip_:getSize()
  --  local x,y = self.view_clip_:getPos()
    self.view_clip_:setClip2(true,0,0,w,h) 
end


function SettingPopup:createSettingList(node)
    self.settingItem = node -- SceneLoader.load(itemClass)
    self.view_clip_:addChild(self.settingItem)

    self.button_switch_ = self.settingItem:getChildByName("Button_switch")
    self.button_switch_:addPropRotateSolid(2,180,kCenterDrawing)
    self.button_switch_:setOnClick(self,self.switch_bt_click)
    self.text_height_ = self.settingItem:getChildByName("Text_height")
    self.text_height_:setText(bm.LangUtil.getText("SETTING", "GAOJI"))

    self.button_dafen_ = self.settingItem:getChildByName("Button_dafen")
    self.button_dafen_:setOnClick(self, self.dafen_text_click) 
    self.button_dafen_:getChildByName("Text_dafen"):setText(bm.LangUtil.getText("SETTING","CHECK"))

    self.button_about_ = self.settingItem:getChildByName("Button_about")
    self.button_about_:setOnClick(self, self.about_text_click) 
    self.button_about_:getChildByName("Text_about"):setText(bm.LangUtil.getText("SETTING","CHECK"))

    self.button_rules_ = self.settingItem:getChildByName("Button_rules")
    self.button_rules_:setOnClick(self, self.rules_text_click) 
    self.button_rules_:getChildByName("Text_rules"):setText(bm.LangUtil.getText("SETTING","CHECK"))

    self.button_feedback_ = self.settingItem:getChildByName("Button_feedback")
    self.button_feedback_:setOnClick(self, self.feedback_text_click) 
    self.button_feedback_:getChildByName("Text_feedback"):setText(bm.LangUtil.getText("SETTING","CHECK"))

    self.button_fans_ = self.settingItem:getChildByName("Button_fans")
    self.button_fans_:setOnClick(self, self.fans_text_click) 
    self.button_fans_:getChildByName("Text_fans"):setText(bm.LangUtil.getText("SETTING","CHECK"))

    self.button_push_ = self.settingItem:getChildByName("Button_push")
    self.button_push_:setOnClick(self,self.push_bt_click)

    self.button_effect_ = self.settingItem:getChildByName("Button_effect")
    self.button_effect_:setOnClick(self,self.effect_bt_click)

    self.button_shake_ = self.settingItem:getChildByName("Button_shake")
    self.button_shake_:setOnClick(self,self.shake_bt_click)

    self.button_auto_site_ = self.settingItem:getChildByName("Button_auto_site")
    self.button_auto_site_:setOnClick(self,self.auto_site_bt_click)

    self.button_message_ = self.settingItem:getChildByName("Button_message")
    self.button_message_:setOnClick(self,self.message_bt_click)

    self.button_auto_buy_ = self.settingItem:getChildByName("Button_auto_buy")
    self.button_auto_buy_:setOnClick(self,self.auto_buy_bt_click)

    self.button_music_ = self.settingItem:getChildByName("Button_music")
    self.button_music_:setOnClick(self, self.music_bt_click)
    if nk.isInRoomScene then
        self.button_music_:setEnable(false)
    end

    self.settingItem:getChildByName("Text_effect"):setText(bm.LangUtil.getText("SETTING", "SOUND"))
    self.settingItem:getChildByName("Text_music"):setText(bm.LangUtil.getText("SETTING", "MUSIC"))
    self.settingItem:getChildByName("Text_shake"):setText(bm.LangUtil.getText("SETTING", "VIBRATE"))
    self.settingItem:getChildByName("Text_rules_tip"):setText(bm.LangUtil.getText("SETTING", "PLAY_RULES"))
    self.settingItem:getChildByName("Text_auto_site"):setText(bm.LangUtil.getText("SETTING", "AUTO_SIT"))
    self.settingItem:getChildByName("Text_feedback_tip"):setText(bm.LangUtil.getText("SETTING", "FEEDBACK"))
    
    self.settingItem:getChildByName("Text_auto_buy"):setText(bm.LangUtil.getText("SETTING", "AUTO_BUYIN"))
    self.settingItem:getChildByName("Text_about_tip"):setText(bm.LangUtil.getText("SETTING", "ABOUT"))
    self.settingItem:getChildByName("Text_push"):setText(bm.LangUtil.getText("SETTING", "PUSH"))
    self.settingItem:getChildByName("Text_fans_tip"):setText(bm.LangUtil.getText("SETTING", "FANS"))
    self.settingItem:getChildByName("Text_message"):setText(bm.LangUtil.getText("SETTING", "MESSAGE"))
    self.settingItem:getChildByName("Text_grade"):setText(bm.LangUtil.getText("SETTING", "APP_STORE_GRADE"))
    self.settingItem:getChildByName("Text_version"):setText(bm.LangUtil.getText("SETTING","CURRENT_VERSION", GameConfig.CUR_VERSION))

    self.image_fb_redPoint_ = self.button_feedback_:getChildByName("Text_feedback"):getChildByName("Image_fb_redPoint")
    self.image_fb_redPoint_:setVisible(false)

end

function SettingPopup:initUserData()
    --头像
    local micon = nk.userData["micon"]
    if not micon or not string.find(micon, "http") then
        -- 默认头像 
        if nk.userData["msex"] and tonumber(nk.userData["msex"]) ==1 then
            self.image_head_:setFile(kImageMap.common_male_avatar)
        else
            self.image_head_:setFile(kImageMap.common_female_avatar)
        end
    elseif micon then
        -- 上传的头像
        UrlImage.spriteSetUrl(self.image_head_, micon)
    end 
    --名字
    self.text_name_:setText(nk.updateFunctions.limitNickLength(nk.UserDataController.getUserName(),8))
    if nk.userData.vip and tonumber(nk.userData.vip) > 0 then
        self.text_name_:setColor(0xa0,0xff,0x00)
    end

    --id 登录方式
    local loginType = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    if loginType == "" or loginType == "GUEST" then 
        self.text_type_:setText(bm.LangUtil.getText("LOGIN", "GU_LOGIN"))
        self.text_id_:setText(nk.UserDataController.getUid())
        local fbBindStatus = nk.DictModule:getInt("gameData", nk.cookieKeys.GUEST_BIND_FB_STATUS, -5)
        if fbBindStatus == 1 then
            local fbName = nk.DictModule:getString("gameData", nk.cookieKeys.GUEST_BIND_FB_NAME, "")
            if fbName ~= "" then
              self.text_id_:setText(nk.UserDataController.getUid() .. " (" .. bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL7", nk.updateFunctions.limitNickLength(fbName,8)) .. ")")
            else
              self.text_id_:setText(nk.UserDataController.getUid() .. " (" .. bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL8") .. ")")
            end
        end
    else
        self.text_type_:setText(bm.LangUtil.getText("LOGIN", "FB_LOGIN"))
        self.text_id_:setText(nk.UserDataController.getUid())
    end
end

function SettingPopup:initData()
   --音效
   local effect = nk.DictModule:getBoolean("gameData", nk.cookieKeys.VOLUME, true)
   self:set_checked(self.button_effect_,effect)

   --震动
   local shake = nk.DictModule:getBoolean("gameData", nk.cookieKeys.SHOCK, true)
   self:set_checked(self.button_shake_,shake)

   --自动坐下
   local autoSit = nk.DictModule:getBoolean("gameData", nk.cookieKeys.AUTO_SIT, true)
   self:set_checked(self.button_auto_site_,autoSit)

   --自动购买
   local autobuy = nk.DictModule:getBoolean("gameData", nk.cookieKeys.AUTO_BUY_IN, true)
   self:set_checked(self.button_auto_buy_,autobuy)

   --push
   local push = nk.DictModule:getBoolean("gameData", nk.cookieKeys.PUSH, true)
   self:set_checked(self.button_push_,push)

   --喇叭消息
   local message = nk.DictModule:getBoolean("gameData", nk.cookieKeys.MESSAGE, true)
   self:set_checked(self.button_message_,message)  

   --背景音乐
   local music = nk.DictModule:getBoolean("gameData", nk.cookieKeys.MUSIC, true)
   self:set_checked(self.button_music_, music)
end

function SettingPopup:switch_account_bt_click()
     EventDispatcher.getInstance():dispatch(EventConstants.logout)
end

function SettingPopup:auto_buy_bt_click()
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.AUTO_BUY_IN, not nk.DictModule:getBoolean("gameData", nk.cookieKeys.AUTO_BUY_IN, true))
    self:set_checked(self.button_auto_buy_,nk.DictModule:getBoolean("gameData", nk.cookieKeys.AUTO_BUY_IN, true))
end

function SettingPopup:message_bt_click()
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.MESSAGE, not nk.DictModule:getBoolean("gameData", nk.cookieKeys.MESSAGE, true))
    self:set_checked(self.button_message_,nk.DictModule:getBoolean("gameData", nk.cookieKeys.MESSAGE, true))
end

function SettingPopup:auto_site_bt_click()
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.AUTO_SIT, not nk.DictModule:getBoolean("gameData", nk.cookieKeys.AUTO_SIT, true))
    self:set_checked(self.button_auto_site_,nk.DictModule:getBoolean("gameData", nk.cookieKeys.AUTO_SIT, true))
end

function SettingPopup:shake_bt_click()
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.SHOCK, not nk.DictModule:getBoolean("gameData", nk.cookieKeys.SHOCK, true))
    self:set_checked(self.button_shake_,nk.DictModule:getBoolean("gameData", nk.cookieKeys.SHOCK, true))
end

function SettingPopup:effect_bt_click()
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.VOLUME, not nk.DictModule:getBoolean("gameData", nk.cookieKeys.VOLUME, true))
    self:set_checked(self.button_effect_,nk.DictModule:getBoolean("gameData", nk.cookieKeys.VOLUME, true))
end

function SettingPopup:push_bt_click()
    nk.DictModule:setBoolean("gameData",nk.cookieKeys.PUSH, not nk.DictModule:getBoolean("gameData", nk.cookieKeys.PUSH, true))
    self:set_checked(self.button_push_,nk.DictModule:getBoolean("gameData", nk.cookieKeys.PUSH, true))
end

function SettingPopup:music_bt_click()
  nk.DictModule:setBoolean("gameData",nk.cookieKeys.MUSIC, not nk.DictModule:getBoolean("gameData",nk.cookieKeys.MUSIC, true))
  self:set_checked(self.button_music_,nk.DictModule:getBoolean("gameData",nk.cookieKeys.MUSIC, true))
  if nk.DictModule:getBoolean("gameData", nk.cookieKeys.MUSIC, true) then
      nk.SoundManager:playMusic(nk.SoundManager.BG_MUSIC, true)
  else 
      nk.SoundManager:stopMusic()
  end
end


-- switch
function SettingPopup:set_checked(widget,enable)
    if enable then
        widget:getChildByName("Image_switch"):setPos(50)
    else
        widget:getChildByName("Image_switch"):setPos(0)
    end
end

function SettingPopup:dafen_text_click()
   nk.GameNativeEvent:openBrowser(nk.UpdateConfig.googleStoreUrl)
end

function SettingPopup:update_bt_click(args)

end

function SettingPopup:about_text_click(args)
    nk.AnalyticsManager:report("New_Gaple_setting_about", "setting")
    nk.PopupManager:addPopup(AboutPopup,"setting")     
end

function SettingPopup:rules_text_click(args)
    nk.AnalyticsManager:report("New_Gaple_setting_rule", "setting")
    nk.PopupManager:addPopup(RulesPopup,"setting")
end

function SettingPopup:feedback_text_click(args)
    nk.AnalyticsManager:report("New_Gaple_setting_feedback", "setting")
    nk.PopupManager:addPopup(FeedbackPopup,"setting")  
end

function SettingPopup:fans_text_click()
   nk.GameNativeEvent:openBrowser(bm.LangUtil.getText("ABOUT", "FANS_URL"))
end

function SettingPopup:switch_bt_click() 
  local _,y = self.settingItem:getPos()
  if y == 0 then
     self.settingItem:setPos(0,-230)
     self.button_switch_:doRemoveProp(2)
     self.text_height_:setText(bm.LangUtil.getText("SETTING", "PUTONG"))
  else
     self.settingItem:setPos(0,0)
     self.button_switch_:addPropRotateSolid(2,180,kCenterDrawing)
     self.text_height_:setText(bm.LangUtil.getText("SETTING", "GAOJI"))
  end
  
end

function SettingPopup:onCloseBtnClick()
  self:onBgTouch()
end

function SettingPopup:onBgTouch()
     --保存设置
    nk.DictModule:saveDict("gameData")
	 self:hide()
end

function SettingPopup:pause()
	GameBaseLayer.pause(self);
end 

function SettingPopup:dtor()
    -- Log.printInfo("SettingPopup.dtor");
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "feedbackPoint", self.feedbackHandle_)
    SceneLoader.killLoader(self.loaderInfo)
end 


return SettingPopup