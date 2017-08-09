--
-- Author: ziway
-- Date: 2016-10-24 16:24:19
--
local PopupModel = import('game.popup.popupModel')
local EditSelfInfoView = require(VIEW_PATH .. "userInfo/editSelfInfo_layer")
local EditSelfInfoVar = VIEW_PATH .. "userInfo/editSelfInfo_layer_layout_var"
local EditSelfInfoPopup = class(PopupModel)

function EditSelfInfoPopup.show(data)
	   PopupModel.show(EditSelfInfoPopup, EditSelfInfoView, EditSelfInfoVar, {name="EditSelfInfoPopup"}, data)
end

function EditSelfInfoPopup.hide()
	   PopupModel.hide(EditSelfInfoPopup)
end

function EditSelfInfoPopup:ctor(viewConfig)
	Log.printInfo("EditSelfInfoPopup.ctor");
    self:addShadowLayer()
    self:initLayer()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
    self.propertyHandlers = {}
    self.propertyNames = {"sign"}
    local hanlders = {
        handler(self, self.onSignatureChanged),
    }
    for i = 1, #self.propertyNames do
        table.insert(self.propertyHandlers, nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, 
            self.propertyNames[i], hanlders[i]))
    end
    nk.AnalyticsManager:report("New_Gaple_open_edit_info")
end 

function EditSelfInfoPopup:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
    if self.propertyHandlers then
        for i = 1, #self.propertyHandlers do
            nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, self.propertyNames[i], self.propertyHandlers[i])
        end
        self.propertyHandlers = nil
    end
end 

function EditSelfInfoPopup:checkLoading()
    if not self.memLoading and not self.signLoading then
        self:setLoading(false)
        self:hide()
    end
end
function EditSelfInfoPopup:onHttpProcesser(command, errorCode, data)
    if command == "Member.updateMinfo" then
        if errorCode ~= HttpErrorType.SUCCESSED then
            return 
        end
        self.memLoading = false
        self:checkLoading()
        if not data then return end

        if data.code ~= 1  then
            Log.printInfo("UserPopup", "modify failed.")
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_FAILD"))
            return
        end
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_SUCCESS"))  
    elseif command == "postSignOrDynamics" then  --下面的回调已经做了数据处理，这里是解耦,限定做此界面的UI变化
        self.signLoading = false
        self:checkLoading()
    end
end

function EditSelfInfoPopup:initLayer()
     self:initWidget()
end

function EditSelfInfoPopup:bt_close_click()
     self:onBgTouch()
end

function EditSelfInfoPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)

    self.titleTxt = self:getUI("titleTxt")
    self.titleTxt:setText(bm.LangUtil.getText("USERINFO", "MODIFY_SELF_INFO"))
    self.titleTxt:setColor(0xfa,0xe6,0xff)

    self.nameTitleTxt = self:getUI("nameTitleTxt")
    self.nameTitleTxt:setText(bm.LangUtil.getText("SETTING", "NICK"))
    self.nameTitleTxt:setColor(0xfa,0xe6,0xff)

    self.sexTitleTxt = self:getUI("sexTitleTxt")
    self.sexTitleTxt:setText(bm.LangUtil.getText("USERINFO", "SEX"))
    self.sexTitleTxt:setColor(0xfa,0xe6,0xff)

    self.manTitleTxt = self:getUI("manTxt")
    self.manTitleTxt:setText(bm.LangUtil.getText("USERINFO", "SEX_MAN"))
    self.womanTitleTxt = self:getUI("womanTxt")
    self.womanTitleTxt:setText(bm.LangUtil.getText("USERINFO", "SEX_WOMAN"))

    self.headTitleTxt = self:getUI("headTitleTxt")
    self.headTitleTxt:setText(bm.LangUtil.getText("USERINFO", "AVATAR"))

    self.signTitleTxt = self:getUI("signTitleTxt")
    self.signTitleTxt:setText(bm.LangUtil.getText("USERINFO", "SIGN_TXT"))
    self.signTitleTxt:setColor(0xfa,0xe6,0xff)

    --此引用下面有用的
    self.fbTitleTxt = self:getUI("fbTitleTxt")


    self.changeHeadBtn = self:getUI("changeHeadBtn")
    self.changeHeadBtn:setOnClick(self,self.onPhotoManagerClick)
    --替换为richtxt，因为要加下划线
    self.changeHeadTxt = self:getUI("changeHeadTxt")
    local chtW,chtH = self.changeHeadTxt:getSize()
    self.m_richText = new(RichText,"", chtW, chtH, kAlignCenter, "", 20, 255, 255, 255, false,0);
    self.m_richText:setAlign(kAlignCenter)
    self.changeHeadTxt:getParent():addChild(self.m_richText)
    self.changeHeadTxt:removeFromParent(true)

    self.m_richText:setText("#u"..bm.LangUtil.getText("USERINFO", "GOTO_CHANGE"))
    -- self.m_richText:setEventTouch(self,self.onPhotoManagerClick)

    -- self.nowTxt = self:getUI("nowTxt")
    -- self.nowTxt:setText(bm.LangUtil.getText("USERINFO", "QUICK_CHANGE"))
    -- self.nowTxt:setEventTouch(self,self.onPhotoManagerClick)

    self.btnTxt = self:getUI("btnTxt")
    self.btnTxt:setText(bm.LangUtil.getText("USERINFO", "COMFIRM_INFO"))

    --编辑名字
    self.EditText_name_ = self:getUI("EditText_name_")
    self.EditText_name_:setText(nk.UserDataController.getUserName())
    self.EditText_name_:setMaxLength(15)

    --编辑按钮
    local x,y = self.EditText_name_:getPos()
    local w,h = self.EditText_name_:getSize()
    self.Image_edit = self:getUI("Image_edit")
    self.Image_edit:setOnClick(self,self.onEditBtnHandler)

    --编辑签名
    self.EditText_sign = self:getUI("EditText_sign")
    self.EditText_sign:setText(nk.UserDataController.getUserSign()[1])
    self.EditText_sign:setMaxLength(50)
    self.EditText_sign:setHintText(bm.LangUtil.getText("USERINFO", "SIGN_HINT_TEXT"),0xab,0x5f,0xec)

    --性别选择框
    self.checkBox_group_sex = self:getUI("CheckBoxGroup_sex")
    self.checkBox_group_sex:setOnChange(self,self.checkbox_sex_select)
    self:checkbox_sex_select(nk.UserDataController.getUserSex())

    --fb主页开关
    self.fb_switchBtn = self:getUI("Button_effect37")
    self.fb_switchBtn:setOnClick(self,self.effect_bt_click)
    --初始化

    self.fb_default = (nk.UserDataController.getFBindex() == 2)  --2 是打开，1是关闭
    self:set_checked(self.fb_switchBtn, self.fb_default)

    local lastLoginType = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    self.fbTitleTxt:setVisible(lastLoginType ==  "FACEBOOK")
end

function EditSelfInfoPopup:onEditBtnHandler()

end

function EditSelfInfoPopup:onPhotoManagerClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
    if kFingerUp==finger_action then
        local PhotoManagerPopup  = require("game.photoManager.photoManagerPopup") 
        nk.PopupManager:addPopup(PhotoManagerPopup) 
    end
end

function EditSelfInfoPopup:checkbox_sex_select(index)
     self.checkBox_group_sex:getCheckBox(1):setChecked(false)
     self.checkBox_group_sex:getCheckBox(2):setChecked(false)

     self.checkBox_group_sex:getCheckBox(tonumber(index)):setChecked(true)
end

function EditSelfInfoPopup:effect_bt_click()
    self.fb_default = not self.fb_default
    self:set_checked(self.fb_switchBtn, self.fb_default)
end

  -- switch
function EditSelfInfoPopup:set_checked(widget,enable)
    if enable then
        widget:getChildByName("Image_switch"):setPos(50)
    else
        widget:getChildByName("Image_switch"):setPos(0)
    end
end

function EditSelfInfoPopup:setLoading(isLoading)
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

function EditSelfInfoPopup:confirmInfo()
    if self.memLoading or self.signLoading then
        -- nk.TopTipManager:showTopTip(T("修改中"))   
        return
    end

    local a = self.EditText_name_:getText()
    local b = nk.UserDataController.getUserName()
    local c = nk.UserDataController.getUserSex()
    local d = self.checkBox_group_sex:getResult()
    local e = nk.UserDataController.getFBindex()

    local FBindex = self.fb_default and 2 or 1

    if (a ~= b and a ~= "") or (c ~= d[1]) or (e ~= FBindex) then
        local params = {}
        if a ~= b then
             params.name = a
        end

        if c ~= d[1] then 
            params.msex = d[1]
        end

        if e ~= FBindex then
           params.FBindex = FBindex
        end

        self.memLoading = true
        self:setLoading(true)

        nk.HttpController:execute("Member.updateMinfo", {game_param = params})
    end

    local j = string.trim(self.EditText_sign:getText())
    local k = nk.UserDataController.getUserSign()[1]

    if (j ~= k and j ~= "") then

        self.signLoading = true
        self:setLoading(true)

        --test delay
        -- nk.GCD.PostDelay(self,function()
            self.UploadSignature(j)
        -- end,nil,5000)
    end

end

function EditSelfInfoPopup:setLoading(isLoading)
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

function EditSelfInfoPopup:onSignatureChanged(sign)
    if self.EditText_sign then
        self.EditText_sign:setText(sign[1])
    end
end

function EditSelfInfoPopup.UploadSignature(content)
    nk.HttpController:execute("postSignOrDynamics", {game_param = {mid = nk.userData.uid, type = 2,content = content}}, nil, 
        function (errorCode, data)
            if data and data.code == 1 and checkint(data.data) > 0 then
                nk.UserDataController.setUserSign(content, data.data)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_SUCCESS"))  
                nk.AnalyticsManager:report("New_Gaple_publish_sign")
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_FAILD"))   
            end
            --解耦
            EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,"postSignOrDynamics",
                HttpErrorType.SUCCESSED,data)
        end
    )
end

return EditSelfInfoPopup