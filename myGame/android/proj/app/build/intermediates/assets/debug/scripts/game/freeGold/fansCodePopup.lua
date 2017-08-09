-- FansCodePopup.lua
-- Date : 2016-08-10
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local FansCodeView = require(VIEW_PATH .. "free/fans_layer")
local FansCodeInfo = VIEW_PATH .. "free/fans_layer_layout_var"
local FreeSharePopup = require("game.freeGold.freeSharePopup")
local FansCodePopup= class(PopupModel)

function FansCodePopup.show(data)
	PopupModel.show(FansCodePopup, FansCodeView, FansCodeInfo, {name="FansCodePopup"}, data)
end

function FansCodePopup.hide()
	PopupModel.hide(FansCodePopup)
end

function FansCodePopup:ctor(viewConfig)
	Log.printInfo("FansCodePopup.ctor");
    self:addShadowLayer()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
    self:initLayer()
end 

function FansCodePopup:initLayer()
     self:initWidget()
end

function FansCodePopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)   

    self.text_title_ = self:getUI("Text_title")
    self.text_title_:setText(bm.LangUtil.getText("ECODE", "TITLE"))

    self.editText_code_ = self:getUI("EditText_code")
    self.editText_code_:setHintText(bm.LangUtil.getText("ECODE", "EDITDEFAULT"))
    self.editText_code_:setMaxLength(11)

    self:getUI("Text_bt_code"):setText(bm.LangUtil.getText("ECODE", "EXCHANGE"))
    self:getUI("Text_bt_link"):setText(bm.LangUtil.getText("ECODE", "FANS"))
    self.textview_desc = self:getUI("TextView_content")
    self.textview_desc:setText(bm.LangUtil.getText("ECODE", "DESC"))
    self.textview_desc:setScrollBarWidth(0)
    self.textView_url = self:getUI("TextView_url")
    self.url_ = bm.LangUtil.getText("ABOUT", "FANS_URL")
    self.textView_url:setText(self.url_)
    self.textView_url:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:bt_fans_click()
                                          end
                                          end) 
    self.bt_code = self:getUI("Button_code")

end

function FansCodePopup:bt_code_click()
    self.bt_code:setEnable(false)
    local text = self.editText_code_:getText()
    local filteredText = string.gsub(self.editText_code_:getText()," ","");
    local len  = string.len(filteredText) 
    if len<6 or len>11 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))
        self.bt_code:setEnable(true)
    else
        self:setLoading(true)
        nk.HttpController:execute("Invite.checkConversionCode", {game_param ={code = text}})
    end
end

function FansCodePopup:onHttpProcesser(command, code, content)
    if command == "Invite.checkConversionCode" then
        self:setLoading(false)
        self.bt_code:setEnable(true)
        if code ~= 1 then
            return
        end
        if content.code then
            if  content.code == 1 then
                Log.dump(content, "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
                local data_ = content.data
                if data_ and data_.addMoney then
                    local text = {}
                    text.isGet = true
                    text.name = data_.name
                    nk.PopupManager:addPopup(FreeSharePopup, "hall", text)
                end
            elseif content.code == -1 then  
                local text = {}
                text.isGet = false
                text.name = ""                                                                                                                                                        
                nk.PopupManager:addPopup(FreeSharePopup, "hall", text) 
            elseif content.code == -4 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_END"))      
            elseif content.code == -6 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_INVALID")) 
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))  
            end  
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))  
        end
    end
end

function FansCodePopup:bt_fans_click()
   nk.GameNativeEvent:openBrowser(self.url_)
end

function FansCodePopup:setLoading(isLoading)
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

function FansCodePopup:dtor()
    Log.printInfo("FansCodePopup.dtor");
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end 


return FansCodePopup