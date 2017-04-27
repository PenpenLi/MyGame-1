--
-- Author: melon
-- Date: 2016-12-21 11:56:09
--
local PopupModel = require('game.popup.popupModel')
local ScoreFeedbackView = require(VIEW_PATH .. "score/scoreFeedback")
local ScoreFeedbackVar = VIEW_PATH .. "score/scoreFeedback_layout_var"
local ScoreFeedbackPopup= class(PopupModel)

function ScoreFeedbackPopup.show(data)
    PopupModel.show(ScoreFeedbackPopup, ScoreFeedbackView, ScoreFeedbackVar, {name="ScoreFeedbackPopup"},data)
end

function ScoreFeedbackPopup.hide()
    PopupModel.hide(ScoreFeedbackPopup)
end

function ScoreFeedbackPopup:ctor()
    self:addShadowLayer()
    self:initVar()
    self:initPanel()
end 

function ScoreFeedbackPopup:dtor()
   
end 

function ScoreFeedbackPopup:initVar()
    self.bg = self:getUI("Bg")
    self:addCloseBtn(self.bg,13,16)
    self.desc = self:getUI("Desc")
    self.opiniont = self:getUI("Opiniont")
    self.commitBtn = self:getUI("CommitBtn")
    self.btnText = self:getUI("BtnText")
    self.desc:setText(bm.LangUtil.getText("SCORE", "TITLE2"))
    self.opiniont:setHintText(bm.LangUtil.getText("SCORE", "TIP2"),0xab,0x5f,0xec)
    self.opiniont:setMaxLength(200)
    self.btnText:setText(bm.LangUtil.getText("SETTING", "COMMIT"))
end

function ScoreFeedbackPopup:initPanel()
  
end

function ScoreFeedbackPopup:onCommitClick()
    local text = self.opiniont:getText()
    local filteredText = string.gsub(text," ","");
    if string.len(filteredText) <= 0 then  
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
    else
        self.commitBtn:setEnable(false)
        self:feedback(bm.LangUtil.getText("SCORE", "STAR",(self.args[i] or 4))..text,6)
    end
end


--提交反馈文字
function ScoreFeedbackPopup:feedback(itype,text)
    local params = {}
    params.username = nk.UserDataController.getUserName()
    params.contact = "cell - phone number"
    params.category = itype
    params.title = ""
    params.content = text 
    params.level = nk.UserDataController.getMlevel()
    self:setLoading(true)
    nk.FeedbackController:sendFeedback(params,function(result,content)
        self:setLoading(false)
        self.commitBtn:setEnable(true)
        local info = content
        if result then
            if info.flag ~= 1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            else 
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                self.opiniont:setText("")
            end
        end
    end)
end

function ScoreFeedbackPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.bg)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

return ScoreFeedbackPopup