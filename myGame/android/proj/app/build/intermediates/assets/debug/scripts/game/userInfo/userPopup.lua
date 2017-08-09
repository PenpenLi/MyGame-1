-- UserPopup.lua
-- Date : 2016-06-01
-- Description: 
local PopupModel = import('game.popup.popupModel')
local RulesPopup = require("game.setting.rulesPopup")
local userInfoView = require(VIEW_PATH .. "userInfo/userInfo_layer")
local userInfo = VIEW_PATH .. "userInfo/userInfo_layer_layout_var"
local ChangeHeadPopup = require("game.userInfo.changeHeadPopup")
local GiftShopPopup = require("game.giftShop.giftShopPopup")
local EditSelfInfoPopup = require("game.userInfo.EditSelfInfoPopup")
local WritePersonDynamics = require("game.userInfo.WritePersonDynamics")
local LoadGiftControl = import("game.giftShop.loadGiftControl")

local UserPopup = class(PopupModel)

function UserPopup.show(data)
	PopupModel.show(UserPopup, userInfoView, userInfo, {name="UserPopup"}, data)  
end

function UserPopup.hide()
	PopupModel.hide(UserPopup)
end

function UserPopup:ctor(viewConfig)
	Log.printInfo("UserPopup.ctor");
  EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
  EventDispatcher.getInstance():register(EventConstants.getMemberInfoCallback, self, self.onGetMemberInfoCallback)
  self:initLayer()
end 

function UserPopup:initLayer()
  self:initWidget()
  self:addPropertyObservers()
  self:initUserInfoNode()
end

function UserPopup:addPropertyObservers()
    self.miconHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "micon", handler(self, function (obj, micon)      
        if not nk.updateFunctions.checkIsNull(obj) then
            Log.printInfo("UserPopup", "micon = " .. micon)
            if not string.find(micon, "http") then
                -- 默认头像 
                if nk.userData.msex and tonumber(nk.userData.msex) ==1 then
                    self.image_head_:setFile(kImageMap.common_male_avatar)
                else
                    self.image_head_:setFile(kImageMap.common_female_avatar)
                end
            else
                -- 上传的头像
                UrlImage.spriteSetUrl(obj.image_head_, micon)
            end           
        end
    end))

    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        self.giftImageHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "gift", handler(self, function (obj)
            if not nk.updateFunctions.checkIsNull(obj) then
                if self.giftUrlReqId_ then
                    LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
                end
                self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(nk.userData["gift"], handler(self, function(obj,url)
                    self.giftUrlReqId_ = nil
                    if not nk.updateFunctions.checkIsNull(obj) then
                        if url and string.len(url) > 5 then
                            obj.bt_gift_:setVisible(false)
                            if obj.bt_gift_big then
                                UrlImage.spriteSetUrl(obj.bt_gift_big, url)
                            end
                        else
                          obj.bt_gift_:setVisible(true)
                        end
                    end
                end))
            end
        end))
    end

end

function UserPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self.bt_userinfo_ = self:getUI("Button_info")
    self.bt_userinfo_:setOnClick(self,self.onUserInfoBtnClick) 

    self.bt_userprop_ = self:getUI("Button_prop")
    self.bt_userprop_:setOnClick(self,self.onUserPropBtnClick)

    self.text_info_ = self:getUI("Text_info")
    self.text_info_:setText(bm.LangUtil.getText("STORE", "MYINFO"))

    self.text_prop_ = self:getUI("Text_prop")
    self.text_prop_:setText(bm.LangUtil.getText("STORE", "TITLE_MY_PROP"))
    self.text_prop_:setColor(199,127,241)

    self.view_info_ = self:getUI("View_info")
    self.view_prop_ = self:getUI("View_prop")


    self.EditText_name_ = self:getUI("EditText_name")
    self.Text_uid_ = self:getUI("Text_uid")

    self.CheckBox_group_ = self:getUI("CheckBoxGroup_sex")
    self.CheckBox_group_:setOnChange(self,self.checkbox_group)
    self.text_m_ = self:getUI("Text_m")
    self.text_m_:setText(bm.LangUtil.getText("USERINFO", "SEX_MAN"))
    self.text_w_ = self:getUI("Text_w")
    self.text_w_:setText(bm.LangUtil.getText("USERINFO", "SEX_WOMAN"))


    self.bt_help_ = self:getUI("Button_help")
    self.bt_help_:setOnClick(self,self.bt_help_click)
    self.Text_winRate_ = self:getUI("Text_winRate")
    self.Button_changeHead_ = self:getUI("Button_change_head")
    self.Button_changeHead_:setOnClick(self,self.onChangeHeadClick)

    self.Text_rank_ = self:getUI("Text_rank")
    self.Text_total_ = self:getUI("Text_total")
    self.Text_moneyH_ = self:getUI("Text_moneyH")
    self.Text_winHeight_ = self:getUI("Text_winHeight")
    self.Text_lv_ = self:getUI("Text_lv")
    self.View_lv_ = self:getUI("View_level")
    self.Text_bestCard_ = self:getUI("Text_bestCard")
    self.image_best_ = self:getUI("Image_best")
    local _, h = self.image_best_:getSize()
    self.image_best_:addPropScaleSolid(0, 0.6, 0.6, kCenterXY,0,h/2);

    self.image_card_list_ = {}
    for i =1,4 do 
         table.insert(self.image_card_list_, self:getUI("View_card" .. tostring(i)))
    end

    self.Text_gradeNum_ = self:getUI("Text_gradeNum")
    self.Text_gold_ = self:getUI("Text_gold")
    self.image_progress_bg_ = self:getUI("Image_progress_bg")
    self.image_progress = self:getUI("Image_progress")
    self.image_progress:setVisible(false)

    self.ScrollView_propList_ = self:getUI("ScrollView_propList")
    self.ScrollView_propList_:setAlign(KAlignCenter)
    self.ScrollView_propList_:setDirection(kVertical)

    self.bt_gift_ = self:getUI("Button_gift")
    self.bt_gift_:setOnClick(self,self.bt_gift_click)

    self.bt_gift_big = self:getUI("Button_gift_big")
    self.bt_gift_big:setOnClick(self,self.bt_gift_click)    

    self.text_no_prop_ = self:getUI("Text_no_prop")

    self.image_head_bg_ = self:getUI("Image_head_bg")

    self.image_head_ = self:getUI("Image_head")
    self.image_head_ = Mask.setMask(self.image_head_, kImageMap.common_head_mask_big)
    self.image_head_:setEventTouch(self,self.onPhotoManagerClick)  
end

--玩家信息
function UserPopup:initUserInfoNode()

    local param = {}
    param.uid = nk.UserDataController.getUid()
    nk.UserDataController.getMemberInfo(param)
end

function UserPopup:onGetMemberInfoCallback()
    if not self.EditText_name_ or not self.EditText_name_.m_res then return end
    --名字
    self.EditText_name_:setText(nk.updateFunctions.limitNickLength(nk.UserDataController.getUserName(),20))
    --id money
    self.Text_uid_:setText(nk.UserDataController.getUid())
    self.Text_gold_:setText(nk.updateFunctions.formatNumberWithSplit(nk.functions.getMoney()))
    --性别 等级
    self:checkbox_group(nk.UserDataController.getUserSex()) 
    local level = nk.UserDataController.getMlevel()
    self.Text_lv_:setText("Lv:" .. level)
    local image = new(Image,"res/level/level_" .. level .. ".png")
    self.View_lv_:addChild(image)
    --进度
    local exp = nk.UserDataController.getExp()
    if not exp then return end
    local ratio, progress, all = nk.Level:getLevelUpProgress(exp)
    if exp>0 then
         local progress_w = self.image_progress_bg_:getSize()          
         local _,progress_h = self.image_progress:getSize()
         self.image_progress:setVisible(true)
         self.image_progress:setSize(ratio*progress_w, progress_h)
    end
    self.Text_gradeNum_:setText(progress .. "/" .. all)
    --胜率
    local winRate = 0.0
    if nk.UserDataController.getWinNum() > 0 then
         winRate = math.round((nk.UserDataController.getWinNum() / (nk.UserDataController.getWinNum() +nk.UserDataController.getLoseNum())) * 1000) / 10
    end 
    self.Text_winRate_:setText(bm.LangUtil.getText("USERINFO","WIN_RATE_HISTORY") .. tostring(winRate) .. "%")
    --排名
    self.Text_rank_:setText(bm.LangUtil.getText("USERINFO","INFO_RANKING") .. "100")
    self.Text_total_:setText(bm.LangUtil.getText("USERINFO","GENERAL_NUMBER") .. tostring(nk.UserDataController.getWinNum() +nk.UserDataController.getLoseNum()))

    local winHeight = nk.userData["aBest.maxwmoney"]
    if not winHeight then winHeight = 0 end
    self.Text_winHeight_:setText(bm.LangUtil.getText("USERINFO","MAX_WIN_HISTORY") .. tostring(winHeight))

    local moneyH = nk.userData["aBest.maxmoney"]
    if not moneyH then moneyH = 0  end
    self.Text_moneyH_:setText(bm.LangUtil.getText("USERINFO","MAX_MONEY_HISTORY") .. tostring(moneyH))
    --最佳牌型
    if nk.UserDataController.getMaxwcard() then
    
    end
   -- nk.userData["aBest.maxwcard"] = "4,5,37,102"
    --nk.userData["aBest.maxwcardvalue"] = 154
   self.Text_bestCard_:setText(bm.LangUtil.getText("USERINFO","BEST_CARD_TYPE_HISTORY"))
   self.image_best_:setVisible(false)
   if nk.userData["aBest.maxwcard"] ~= "" then
        local cards = {}
        cards=string.split(nk.userData["aBest.maxwcard"], ',')
        if self.pokerCards then
            for i,v in ipairs(cards) do
                 self.pokerCards[i]:setCard(checkint(v))                            
            end
        else
            self.pokerCards = {}
            local PokerCard = nk.pokerUI.PokerCard
            for i,v in ipairs(cards) do
                  self.pokerCards[i] = new(PokerCard)
                  self.pokerCards[i]:setCard(checkint(v))
                  self.image_card_list_[i]:addChild(self.pokerCards[i])
            end  
        end

        if nk.userData["aBest.maxwcardvalue"] ~= "" then
             local specialCardNum = checkint(nk.userData["aBest.maxwcardvalue"])-153 
             if specialCardNum > 0 and specialCardNum <= 5 then
                 local typeIcon = string.format("res/room/qiuqiu/qiuqiu_card_mode_%d.png",specialCardNum)
                 self.image_best_:setFile(typeIcon)
                 self.image_best_:setVisible(true)
             end
        end
   end  
end

--玩家道具
function UserPopup:initUserPropNode()
     self:createListView()
end

function UserPopup:onChangeHeadClick()
      nk.PopupManager:addPopup(ChangeHeadPopup,"hall")
end

function UserPopup:createListView(data)
    
    local params = {}
    params.pcid = 3
    self:setLoading(true)
   	nk.HttpController:execute("getUserProps", {game_param = params})
end

function UserPopup:onHttpProcesser(command, code, data)
    if command == "getUserProps" then
        if code ~= HttpErrorType.SUCCESSED then
            return 
        end
        local itemClass = require(VIEW_PATH .. "userInfo/propItem_view")
        self:setLoading(false)
        if not data or data.code ~= 1  then
            Log.printInfo("get props failed.")
            return
        end
        local info = data.data
        if #info <= 0 then
            self.text_no_prop_:setVisible(true)
            self.text_no_prop_:setText(bm.LangUtil.getText("USERINFO","NO_PROP"))
        end

        for i,v in ipairs(info) do
             local propItem = SceneLoader.load(itemClass)
             local item = propItem:getChildByName("Image_item")
             item:setSize(213,185)
             item:setPos(math.mod(i-1,3)*223 +8, math.floor((i-1)/3)*195)
             self.ScrollView_propList_:addChild(item)

             local text_name = item:getChildByName("Text_prop_name")
             text_name:setText(bm.LangUtil.getText("USERINFO","LABA"))
             local image_icon = item:getChildByName("Image_prop_icon")
             image_icon:setFile("res/userInfo/userInfo_laba.png")
             local text_time = item:getChildByName("Text_prop_deadline")
             text_time:setText(bm.LangUtil.getText("USERINFO","USE_TIME") .. ":" .. v.pcnter .. T("个") )
        end
    elseif command == "Member.updateMinfo" then
        if code ~= HttpErrorType.SUCCESSED then
            return 
        end
        if not data or data.code ~= 1  then
            Log.printInfo("UserPopup", "modify failed.")
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_FAILD",nextLevelReward))
            return
        end
        local a = self.EditText_name_:getText()
        local b = nk.UserDataController.getUserName()
        local c = nk.UserDataController.getUserSex()
        local d = self.CheckBox_group_:getResult()
        --大厅改名字
        if a ~= b then
            nk.userData["name"] = a           
        end    
        
        --改性别      
        if c ~= d[1] then
            nk.userData["msex"] = d[1]           
        end      
        
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_SUCCESS",nextLevelReward))    
        self:hide()        
    end    
end

function UserPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.image_bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function UserPopup:onUserInfoBtnClick()
    self.text_info_:setColor(255,255,255)
    self.text_prop_:setColor(199,127,241)
    self.view_info_:setVisible(true)
    self.view_prop_:setVisible(false)

    nk.PopupManager:addPopup(EditSelfInfoPopup)

end

function UserPopup:onUserPropBtnClick()
    self.text_info_:setColor(199,127,241)
    self.text_prop_:setColor(255,255,255)
    if not self.initProp_ then
        self.initProp_ = true
         self:initUserPropNode()
    end
    self.view_info_:setVisible(false)
    self.view_prop_:setVisible(true)
    
    nk.PopupManager:addPopup(WritePersonDynamics)
end

function UserPopup:checkbox_group(index,check)
   self.CheckBox_group_:getCheckBox(1):setChecked(false)
   self.CheckBox_group_:getCheckBox(2):setChecked(false)

   self.CheckBox_group_:getCheckBox(tonumber(index)):setChecked(true)

end

function UserPopup:bt_help_click()
    nk.PopupManager:addPopup(RulesPopup,"hall",3)
end

function UserPopup:bt_gift_click()
    nk.PopupManager:addPopup(GiftShopPopup,"hall",2,false,nk.userData.uid) 
end

function UserPopup:bt_close_click()
  self:onBgTouch()
end

function UserPopup:onBgTouch()
    local a = self.EditText_name_:getText()
    local b = nk.UserDataController.getUserName()
    local c = nk.UserDataController.getUserSex()
    local d = self.CheckBox_group_:getResult()
    if a ~= b and a ~= "" or c ~= d[1] then
        local params = {}
        if a ~= b then
             params.name = a
        end

        if c ~= d[1] then 
            params.msex = d[1]
        end

        nk.HttpController:execute("Member.updateMinfo", {game_param = params})
    else
        self:hide()
    end

	 
end

function UserPopup:onPhotoManagerClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
    if kFingerUp==finger_action then
        local PhotoManagerPopup  = require("game.photoManager.photoManagerPopup") 
        nk.PopupManager:addPopup(PhotoManagerPopup,"hall") 
    end
end

function UserPopup:dtor()
    Log.printInfo("UserPopup.dtor")
    if self.giftUrlReqId_ then
        LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
        self.giftUrlReqId_ = nil
    end 
    if self.miconHandle_ then
        nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "micon", self.miconHandle_)
    end
    if self.giftImageHandle_ then
        nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "gift", self.giftImageHandle_)
    end

    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
    EventDispatcher.getInstance():unregister(EventConstants.getMemberInfoCallback, self, self.onGetMemberInfoCallback)
end 


return UserPopup