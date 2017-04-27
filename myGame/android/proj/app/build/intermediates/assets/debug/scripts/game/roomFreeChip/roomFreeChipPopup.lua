
local PopupModel = import('game.popup.popupModel')

local RoomFreeChipPopupLayer = require(VIEW_PATH .. "popup.room_freeChip_pop_layer")
local varConfigPath = VIEW_PATH .. "popup.room_freeChip_pop_layer_layout_var"

local RoomFreeChipController = require("game.roomFreeChip.roomFreeChipController")

local RoomFreeChipPopup = class(PopupModel)

function RoomFreeChipPopup.show(...)
	PopupModel.show(RoomFreeChipPopup, RoomFreeChipPopupLayer, varConfigPath, {name="RoomFreeChipPopup", defaultAnim=false}, ...)
end

function RoomFreeChipPopup.hide()
	PopupModel.hide(RoomFreeChipPopup)
end

function RoomFreeChipPopup:dtor()
    self.m_popup_bg:stopAllActions()
    EventDispatcher.getInstance():unregister(EventConstants.refreshBoxView, self, self.setBoxView)
    EventDispatcher.getInstance():unregister(EventConstants.FREE_CHIP_CAN_GET_REWARD_NUM, self, self.onShowTaskRedPoint)
    EventDispatcher.getInstance():unregister(EventConstants.FREE_CHIP_GET_LEVEL_UP_REWARD, self, self.onHideUpgradeRedPoint)
end

function RoomFreeChipPopup:ctor(viewConfig, varConfigPath, ctx, rFChipCtrl)
    self:addShadowLayer()
    self.ctx = ctx
    self.m_rFChipCtrl = rFChipCtrl
    self.m_onLineBox_clicked = false
    self.m_levelUp_clicked = false
    self:initScene()
    self:addShadowLayer()

    EventDispatcher.getInstance():register(EventConstants.refreshBoxView, self, self.setBoxView)
    EventDispatcher.getInstance():register(EventConstants.FREE_CHIP_CAN_GET_REWARD_NUM, self, self.onShowTaskRedPoint)
    EventDispatcher.getInstance():register(EventConstants.FREE_CHIP_GET_LEVEL_UP_REWARD, self, self.onHideUpgradeRedPoint)

    self:onShowPopup()
    self:onHideUpgradeRedPoint()
end

function RoomFreeChipPopup:initScene()
    self.m_dailyTask_redPoint = self:getUI("dailyTask_redPoint")
    self.m_onLineBox_redPoint = self:getUI("onLineBox_redPoint")
    self.m_levelUp_redPoint = self:getUI("levelUp_redPoint")

    self.m_dailyTask_redPoint:setVisible(false)
    self.m_onLineBox_redPoint:setVisible(false)
    self.m_levelUp_redPoint:setVisible(false)

    self.m_dailyTask_desc = self:getUI("dailyTask_desc")
    self.m_onLineBox_time = self:getUI("onLineBox_time")
    self.m_mextLevel = self:getUI("mextLevel")

    self.m_box_normal = self:getUI("box_normal")
    self.m_box_reward = self:getUI("box_reward")
    self.m_box_finished = self:getUI("box_finished")


    self.m_popup_bg = self:getUI("popup_bg")
    if nk.roomSceneType == "gaple" then
        self.m_popup_bg:setPos(0,60)
    elseif nk.roomSceneType == "qiuqiu" then
        self.m_popup_bg:setPos(0,175)
    end
end

function RoomFreeChipPopup:getBoxData()
    self.m_boxData = self.m_rFChipCtrl:getBoxData()
end

function RoomFreeChipPopup:onDailyTaskBtnClick()
    local TaskPopup = require("game.task.taskPopup")
    nk.PopupManager:addPopup(TaskPopup,"roomGaple")
end

function RoomFreeChipPopup:onLevelUpTextTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self:onLevelUpBtnClick()
    end
end

function RoomFreeChipPopup:onLevelUpBtnClick()
    if self.m_levelUp_clicked then return end
    self.m_levelUp_clicked = false
    local UpgradePopup = require("game.upgrade.upgradePopup")
    if nk.userData["invitableLevel"] and #nk.userData["invitableLevel"] > 0 then
        nk.PopupManager:addPopup(UpgradePopup, "roomGaple")
    else
        local ratio, progress, all = nk.Level:getLevelUpProgress(nk.userData["exp"])
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "NO_UPLEVEL_AWARD",all-progress))
    end 
    nk.GCD.PostDelay(self, function(obj)
        self.m_levelUp_clicked = false
    end, nil, 4000)
end

function RoomFreeChipPopup:onOnLineBoxClick()
    self:getBoxData()
    if not self.m_boxData or self.m_onLineBox_clicked then
        return 
    end
    self.m_onLineBox_clicked = true
	if self.m_boxData.boxStatus_ == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "FINISHED"))
    elseif self.m_boxData.boxStatus_ == 2 then
        self.m_rFChipCtrl:requestGetChest()
    else
        if self.ctx.model:isSelfInSeat() then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "NEEDTIME", 
            nk.TimeUtil:getTimeMinuteString(self.m_boxData.remainTime), nk.TimeUtil:getTimeSecondString(self.m_boxData.remainTime), self:formatMoney(self.m_boxData.reward)))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "SITDOWN"))
        end
    end

    nk.GCD.PostDelay(self, function(obj)
        self.m_onLineBox_clicked = false
    end, nil, 4000)
end

function RoomFreeChipPopup:formatMoney(money)
    if money < 100000 then
        money = nk.updateFunctions.formatNumberWithSplit(money)
    else
        money = nk.updateFunctions.formatBigNumber(money)
    end

    return money
end

function RoomFreeChipPopup:setBoxView()
    self:getBoxData()
    self.m_box_reward:setVisible(false)
    self.m_box_normal:setVisible(false)
    self.m_box_finished:setVisible(false)
    self.m_onLineBox_redPoint:setVisible(false)

    local timeStr = ""
    if self.m_boxData.boxStatus_ == 1 then
        self.m_box_finished:setVisible(true)
        timeStr = bm.LangUtil.getText("COUNTDOWNBOX", "TODAYFINISH")
    elseif self.m_boxData.boxStatus_ == 2 then
        self.m_onLineBox_redPoint:setVisible(true)
        self.m_box_reward:setVisible(true)
        timeStr = bm.LangUtil.getText("COUNTDOWNBOX", "CLICK_GET")
    else
        self.m_box_normal:setVisible(true)
        timeStr = nk.TimeUtil:getTimeString(self.m_boxData.remainTime) .. "  +"  .. self:formatMoney(tonumber(self.m_boxData.reward))
    end
    self.m_onLineBox_time:setText(timeStr)
end

function RoomFreeChipPopup:onShowTaskRedPoint(num)
    if self.m_dailyTask_redPoint then
        if num > 0 then
            self.m_dailyTask_redPoint:setVisible(true)
            self.m_dailyTask_desc:setText(bm.LangUtil.getText("COUNTDOWNBOX", "CLICK_GET"))
        else
            self.m_dailyTask_redPoint:setVisible(false)
            self.m_dailyTask_desc:setText(bm.LangUtil.getText("COUNTDOWNBOX", "CLICK_SEE"))
        end
    end
end

function RoomFreeChipPopup:onHideUpgradeRedPoint()
    if nk.userData["invitableLevel"] and #nk.userData["invitableLevel"] > 0 then
        self.m_levelUp_redPoint:setVisible(true)
        self.m_mextLevel:setText(bm.LangUtil.getText("COUNTDOWNBOX", "CLICK_GET"))
    else
        self.m_levelUp_redPoint:setVisible(false)
        local ratio, progress, all, nothing, nextLevelReward = nk.Level:getLevelUpProgress(nk.userData["exp"])
        self.m_mextLevel:setText(bm.LangUtil.getText("COUNTDOWNBOX", "EXP_LACK", nextLevelReward))
    end
end

function RoomFreeChipPopup:onShowPopup()
    self.m_popup_bg:stopAllActions()
    self.m_popup_bg:setPos(-305)
    transition.moveTo(self.m_popup_bg, {time=0.3, x=0, easing="OUT"})
end

return RoomFreeChipPopup