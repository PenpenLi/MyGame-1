--
-- Author: melon
-- Date: 2016-12-20 17:41:55
--
local PopupModel = require('game.popup.popupModel')
local ScoreView = require(VIEW_PATH .. "score/score")
local ScoreVar = VIEW_PATH .. "score/score_layout_var"
local ScorePopup= class(PopupModel)

function ScorePopup.show(data)
    PopupModel.show(ScorePopup, ScoreView, ScoreVar, {name="ScorePopup"},data)
end

function ScorePopup.hide()
    nk.AnalyticsManager:report("New_Gaple_close_score", "score")
    PopupModel.hide(ScorePopup)
end

function ScorePopup:ctor()
    nk.AnalyticsManager:report("New_Gaple_open_score", "score")
    self:addShadowLayer()
    self:initVar()
    self:initPanel()
end 

function ScorePopup:dtor()
   
end 

function ScorePopup:initVar()
   self.star = 0
end

function ScorePopup:initPanel()
    self.bg = self:getUI("Bg")
    self:addCloseBtn(self.bg,16,23)
    self.title = self:getUI("Title")
    self.tip = self:getUI("Tip")
    self.btnText = self:getUI("BtnText")
    self.title:setText(bm.LangUtil.getText("SCORE", "TITLE"))
    self.tip:setText(bm.LangUtil.getText("SCORE", "TIP"))
    self.btnText:setText(bm.LangUtil.getText("SETTING", "COMMIT"))
    self.disX = 85
    self.starList = {}
    for i=1,5 do
        self.starList[i] = new(Image, kImageMap.scoreStar1)
        self.starList[i]:setPos(-3*self.disX+self.disX*i,33)
        self.starList[i]:setAlign(kAlignCenter)
        self.bg:addChild(self.starList[i])
        local function callback(self,finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
            self:onStarClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time,i)  
        end
        self.starList[i]:setEventTouch(self,callback) 
    end
end

function ScorePopup:createLevelTip(index)
    if self.imageTip then
        self.imageTip:removeFromParent(true)
    end
    self.imageTip = new(Image,kImageMap.scoreqp,nil,nil,50,20,15,25)
    self.imageTip:setAlign(kAlignCenter)
    self.imageTip:setSize(84,46)
    self.bg:addChild(self.imageTip)
    self.textTip = new(Text,bm.LangUtil.getText("SCORE", "LEVEL")[index], 0, 25, kAlignCenter, nil, 20, 255, 255, 255)
    self.textTip:setAlign(kAlignCenter)
    self.textTip:setPos(0,-5)
    self.imageTip:addChild(self.textTip)
    self.imageTip:setTransparency(0)
    self.imageTip:setPos(-3*self.disX+self.disX*index+10,-18)
    self.imageTip:fadeIn({time=0.5})
    local w1 = self.textTip:getSize()
    local w2 = self.imageTip:getSize()
    if w1+20>w2 then
        self.imageTip:setSize(w1+20)
    end
end

function ScorePopup:onCommitClick()
    if self.star>=5 then
        nk.AnalyticsManager:report("New_Gaple_score_star_"..self.star, "score")
        self:onClose()
        nk.PopupManager:addPopup(require("game.score.scoreRewardPopup"),"hall") 
    elseif self.star>=1 then
        nk.AnalyticsManager:report("New_Gaple_score_star_"..self.star, "score")
        self:onClose()
        nk.PopupManager:addPopup(require("game.score.scoreFeedbackPopup"),"hall",self.star) 
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCORE", "TIP3"))        
    end
end

function ScorePopup:onStarClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time,index)  
    if kFingerDown== finger_action then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self.star = index
        self:createLevelTip(index)
        for i=1,index do
            self.starList[i]:setFile(kImageMap.scoreStar2)
        end
        for i=index+1,#self.starList do
            self.starList[i]:setFile(kImageMap.scoreStar1)
        end
    elseif kFingerUp== finger_action then
    end    
end

function ScorePopup:setLoading(isLoading)
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

return ScorePopup