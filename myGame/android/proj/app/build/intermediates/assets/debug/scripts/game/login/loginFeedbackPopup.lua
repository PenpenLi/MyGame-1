-- loginFeedbackPopup.lua
-- Date : 2016-08-08
-- Description: 
local PopupModel = import('game.popup.popupModel')
local loginFeedbackView = require(VIEW_PATH .. "login/login_feedback")
local loginFeedbackInfo = VIEW_PATH .. "login/login_feedback_layout_var"
local LoginFeedbackPopup= class(PopupModel);

LoginFeedbackPopup.Type = {"PAY","LOGIN","ACCOUNT","BUG","SUGGEST","COMPLAIN","OTHER"}

function LoginFeedbackPopup.show(data)
	PopupModel.show(LoginFeedbackPopup, loginFeedbackView, loginFeedbackInfo, {name="LoginFeedbackPopup"}, data)
end

function LoginFeedbackPopup.hide()
	PopupModel.hide(LoginFeedbackPopup)
end

function LoginFeedbackPopup:ctor(viewConfig)
	Log.printInfo("LoginFeedbackPopup.ctor");
    self:addShadowLayer()
    self:initLayer()
end 

function LoginFeedbackPopup:initLayer()
     self:initWidget()
end

function LoginFeedbackPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)   

    self.text_title_ = self:getUI("Text_title")
    self.text_title_:setText(bm.LangUtil.getText("SETTING", "FEEDBACK"))

    self.text_type_ = self:getUI("Text_type")
    self.text_type_:setText(bm.LangUtil.getText("SETTING", "TYPE"))
    self.showType_ = false
    self.text_type_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:type_text_click()
                                          end
                                          end) 

    self.editText_ = self:getUI("EditTextView_content")
    self.editText_:setHintText(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
    self.editText_:setMaxLength(200)

    self.image_type_ = self:getUI("Image_zhankai")
    self.image_type_:setVisible(false)

    self.radio_bt_type_ = self:getUI("RadioButtonGroup_type")
    self.radio_bt_type_:setOnChange(self,self.radio_bt_click)

    self.bt_commit_ = self:getUI("Button_commit")
    self.bt_commit_:setOnClick(self,self.bt_commit_click)
    self.bt_commit_:setEnable(true)
    self.text_commit_ = self:getUI("Text_commit")
    self.text_commit_:setText(bm.LangUtil.getText("SETTING","COMMIT"))

    self.text_type_list_={}
    for i = 1,7  do
        table.insert(self.text_type_list_,self:getUI("Text_type_" .. i))
    end
    for i,v in ipairs(self.text_type_list_) do
        v:setText(bm.LangUtil.getText("SETTING",LoginFeedbackPopup.Type[i]))
    end

end

function LoginFeedbackPopup:type_text_click()
    self.showType_ = not self.showType_

    self.image_type_:setVisible(self.showType_)
end

function LoginFeedbackPopup:radio_bt_click(index)
    self.showType_ = false
    self.image_type_:setVisible(false)
    self.text_type_:setText(self.text_type_list_[index]:getText())
    self.type_fb_ = index
end

function LoginFeedbackPopup:bt_commit_click()
    local text = self.editText_:getText()
    local filteredText = string.gsub(self.editText_:getText()," ","");
    local len  = string.len(filteredText) 
    if len <= 0 then  
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
        return  
    elseif not self.type_fb_ then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEEDBACK_TYPE"))
        return
    end
    self.bt_commit_:setEnable(false)
    self:feedback(self.type_fb_,self.editText_:getText())
end

--提交反馈文字
function LoginFeedbackPopup:feedback(itype,text)
    local params = {}
    params.username = nk.userData["name"]
    params.contact = "cell - phone number"
    params.category = itype
    params.title = ""
    params.content = text
    params.level = nk.userData["mlevel"]

    self:setLoading(true)
    nk.FeedbackController:sendFeedback(params,function(result,content)
         self:setLoading(false)
         self.bt_commit_:setEnable(true)
         local info = content
         if result then
              if info.flag ~= 1 then
                  Log.printInfo("commit feedback faild.")
                  nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
              else 
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                self.editText_:setText("")
                self.text_type_:setText(bm.LangUtil.getText("SETTING", "TYPE"))
                self.type_fb_ = nil
                self.radio_bt_type_:clear()
              end
         end
    end)
end

function LoginFeedbackPopup:setLoading(isLoading)
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

function LoginFeedbackPopup:dtor()
    Log.printInfo("LoginFeedbackPopup.dtor");
end 


return LoginFeedbackPopup