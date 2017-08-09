--
-- Author: melon
-- Date: 2016-12-21 11:54:21
--
local PopupModel = require('game.popup.popupModel')
local ScoreRewardView = require(VIEW_PATH .. "score/scoreReward")
local ScoreRewardVar = VIEW_PATH .. "score/scoreReward_layout_var"
local ScoreRewardPopup= class(PopupModel)

function ScoreRewardPopup.show(data)
    PopupModel.show(ScoreRewardPopup, ScoreRewardView, ScoreRewardVar, {name="ScoreRewardPopup"},data)
end

function ScoreRewardPopup.hide()
    nk.AnalyticsManager:report("New_Gaple_close_score_reward", "score")
    PopupModel.hide(ScoreRewardPopup)
end

function ScoreRewardPopup:ctor()
    self:addShadowLayer()
    self:initVar()
    self:initPanel()
end 

function ScoreRewardPopup:dtor()
   
end 

function ScoreRewardPopup:initVar()
end

function ScoreRewardPopup:initPanel()
    self.bg = self:getUI("Bg")
    self:addCloseBtn(self.bg,16,23)
    self.title = self:getUI("Title")
    self.btnText = self:getUI("BtnText")
    self.title:setText(bm.LangUtil.getText("SCORE", "TITLE1"))
    self.tip = new(RichText, bm.LangUtil.getText("SCORE", "TIP1",  nk.fiveStarConf and nk.fiveStarConf.rewardMoney or "2M"), 270,150, kAlignLeft, "", 20, 255, 255, 255,true)
    self.tip:setPos(65, -20)
    self.tip:addTo(self.bg)
end

function ScoreRewardPopup:onGoClick()
    self:onClose()
    nk.fiveStar = 1
    nk.AnalyticsManager:report("New_Gaple_score_go_goole", "score")
    nk.GameNativeEvent:openBrowser(nk.UpdateConfig.googleStoreUrl)
    nk.HttpController:execute("FiveStarGrade.getReward", {game_param = {mid = nk.userData.uid,star=5}}, nil, handler(self, function (obj, errorCode, data)
        if errorCode==1 and data.code==1 then
            
        end
    end ))
end

return ScoreRewardPopup