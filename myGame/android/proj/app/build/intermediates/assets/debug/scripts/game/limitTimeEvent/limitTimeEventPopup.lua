-- limitTimeEventPopup.lua
-- Data : 2016-12-1
-- Description: a scene in hall moudle
local PopupModel = import('game.popup.popupModel')
local MainScene = require('demo.demoScene')
local LimitTimeEventPopupLayer = require(VIEW_PATH .. "limitTimeEvent/limit_time_event_layer")
local varConfigPath = VIEW_PATH .. "limitTimeEvent/limit_time_event_layer_layout_var"

local FullServerEventLayer = require("game.limitTimeEvent.layers.fullServerEventLayer")

local LimitTimeEventPopup= class(PopupModel);

local PERSON_REWARD_COUNT = 3

function LimitTimeEventPopup.show(data)
	PopupModel.show(LimitTimeEventPopup, LimitTimeEventPopupLayer, varConfigPath, {name="LimitTimeEventPopup"}, data)
end

function LimitTimeEventPopup.hide()
	PopupModel.hide(LimitTimeEventPopup)
end

function LimitTimeEventPopup:ctor(viewConfig, varConfigPath)
	Log.printInfo("LimitTimeEventPopup.ctor")
    nk.limitTimeEventDataController:setPopupIsShow(true)
    nk.limitTimeEventDataController:reStartLoading()
    self:addShadowLayer()
    self.currTab_ = 1
    self:initScene()

    EventDispatcher.getInstance():register(EventConstants.update_limitTimeEvent_view, self, self.onGetEventDataCallback)
    EventDispatcher.getInstance():register(EventConstants.update_lTEvent_countDownTime, self, self.onRefreshCountdownTime)
    EventDispatcher.getInstance():register(EventConstants.limitTimeEvent_prize_result, self, self.updateSingleView)
    
    self:addPropertyObservers_()

    if nk.limitTimeEventDataController:getInit() then
        -- 更新个人活动界面
        self:updateSingleView(2)
        nk.limitTimeEventDataController:getCurReleaseTimer()
    end
end

--先弹框，再请求数据
function LimitTimeEventPopup:onShow()
    nk.limitTimeEventDataController:getEventData()
    self:setLoading(true)
end

function LimitTimeEventPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function LimitTimeEventPopup:dtor()
    nk.limitTimeEventDataController:reset()
    nk.limitTimeEventDataController:setPopupIsShow(false)
    EventDispatcher.getInstance():unregister(EventConstants.update_limitTimeEvent_view, self, self.onGetEventDataCallback)
    EventDispatcher.getInstance():unregister(EventConstants.update_lTEvent_countDownTime, self, self.onRefreshCountdownTime)
    EventDispatcher.getInstance():unregister(EventConstants.limitTimeEvent_prize_result, self, self.updateSingleView)
    self:removePropertyObservers()
end

function LimitTimeEventPopup:initScene()
    self.m_image_bg = self:getUI("Image_bg")
    self:addCloseBtn(self.m_image_bg)

    self.m_radioBtnGroup = self:getUI("RadioButtonGroup")
    self.m_radioBtnGroup:setOnChange(self,self.onRadiobtnClick) 
    self.m_person_text = self:getUI("persion_text")
    self.m_person_text:setText(bm.LangUtil.getText("LIMIT_TIME_EVENT","PERSON_EVENT"))
    self.m_fullService_text = self:getUI("fullService_text")
    self.m_fullService_text:setText(bm.LangUtil.getText("LIMIT_TIME_EVENT","FULLSERVER_EVENT"))
    self.m_persionEventRedPoint = self:getUI("persion_event_redPoint")
    self.m_persionEventRedPoint:setVisible(false)
    self.m_FullServerEventRedPoint = self:getUI("fullService_Event_redPoint")
    self.m_FullServerEventRedPoint:setVisible(false)

    self.m_person_view = self:getUI("persion_event_view")
    self.m_fullService_view = self:getUI("fullService_event_view")

    self.m_radioBtnGroup:setSelected(1)

    self:initPersonView()
end

local function handler2(func, ...)
    local args = {...}
    --obj,finger_action,,x,y,drawing_id_first,drawing_id_current
    return function(obj)
        func(obj, unpack(args))
    end
end

function LimitTimeEventPopup:initPersonView()
    self.limitTimeTxt = self:getUI("limitTimeTxt")
    --替换为richtxt
    local chtW,chtH = self.limitTimeTxt:getSize()
    self.timeRichText = new(RichText,"", chtW, chtH, kAlignCenter, "", 18, 255, 255, 255, false,0);
    self.timeRichText:setAlign(kAlignCenter)
    self.limitTimeTxt:getParent():addChild(self.timeRichText)
    self.limitTimeTxt:removeFromParent(true)

    --替换为richtxt
    self.gameCountTxt = self:getUI("gameCountTxt")  
    local chtW,chtH = self.gameCountTxt:getSize()
    self.countRichText = new(RichText,"", chtW, chtH, kAlignCenter, "", 18, 255, 255, 255, false,0);
    self.countRichText:setAlign(kAlignCenter)
    self.gameCountTxt:getParent():addChild(self.countRichText)
    self.gameCountTxt:removeFromParent(true)

    -- 设置进度条
    self.loginDayProgBar_ = self:getUI("progressBarImage")
    local loginDayProgBarBg = self:getUI("progressBg")
    self.progressNodeW = loginDayProgBarBg:getSize()
    self.loginDayProgBar_:setVisible(false)

    self.personalRuleTxt = self:getUI("personalRuleTxt")
    self.personalRuleTxt:setText("")

    self.buyBtnTxt = self:getUI("playBtnTxt")
    self.buyBtnTxt:setText(bm.LangUtil.getText("COMMON", "CONFIRM"))
    self.buyBtn = self:getUI("playBtn")
    self.buyBtn:setOnClick(self,self.onClickBtn)

    self.paperContainer = self:getUI("paperContainer")

    self.moreRewardContainer = {}
    for i = 1,PERSON_REWARD_COUNT do
        table.insert(self.moreRewardContainer,self:getUI("prize_"..i))

        local item = self.moreRewardContainer[i]

        item:setOnClick(self, handler2(self.clickPersonReward,i))

        local darkBg = item:getChildByName("darkBg")
        darkBg:setVisible(false)

        local hasGetIamge = item:getChildByName("hasGetIamge")
        hasGetIamge:setVisible(false)

        local prizeNameTxt = item:getChildByName("nameGroup"):getChildByName("prizeNameTxt")
        prizeNameTxt:setText("")

        local targetCountTxt = item:getChildByName("targetCountTxt")
        targetCountTxt:setText("")
    end

    if not self.m_fullServiceEventView then
        self.m_fullServiceEventView = new(FullServerEventLayer)
        self.m_fullServiceEventView:setDelegate(self,self.btn_go_click)
        self.m_fullService_view:addChild(self.m_fullServiceEventView)
    end
end


function LimitTimeEventPopup:onRadiobtnClick(index)
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self.currTab_ = index
    self:onTabChange(index)
end

function LimitTimeEventPopup:onTabChange(index)
    if index == 1 then
        -- 个人活动
        nk.AnalyticsManager:report("New_Gaple_limitTimeEvent_single", "limitTimeEventPopup")
        self.m_person_view:setVisible(true)
        self.m_fullService_view:setVisible(false)
    elseif index == 2 then
        --全服活动
        nk.AnalyticsManager:report("New_Gaple_limitTimeEvent_all", "limitTimeEventPopup")
        self.m_person_view:setVisible(false)
        self.m_fullService_view:setVisible(true)
    end
end

function LimitTimeEventPopup:clickPersonReward(index)
    if index then 
        -- Log.dump(index,">>>>>>>>>>>>>>>>>>>>>>>>>>> index")
        local arr = nk.limitTimeEventDataController:getSingleEventArr()
        if arr and arr[index] then
            nk.limitTimeEventDataController:getPrize(2, arr[index].num)
        end
    end
end

--1 表示全服活动奖品，2 表示个人活动奖品
function LimitTimeEventPopup:updateSingleView(type,code,sdata)
    if type ~= 2 then 
        return 
    end

    local arr = nk.limitTimeEventDataController:getSingleEventArr()
    if arr then 
        local finishTask = 0
        for i = 1,PERSON_REWARD_COUNT do
            local item = self.moreRewardContainer[i]
            local darkBg = item:getChildByName("darkBg")

            local tdata = arr[i]
            if tdata.prizeStatus ~= 1 then
                darkBg:setVisible(true)
                item:setEnable(false)
            else
                darkBg:setVisible(false)
                item:setEnable(true)
            end
            --达到目标数的任务
            if tdata.prizeStatus ~= 0 then
                finishTask = finishTask + 1
            end

            local hasGetIamge = item:getChildByName("hasGetIamge")
            hasGetIamge:setVisible(tdata.prizeStatus == 2)

            local prizeNameTxt = item:getChildByName("nameGroup"):getChildByName("prizeNameTxt")
            prizeNameTxt:setText(tdata.prize)

            local targetCountTxt = item:getChildByName("targetCountTxt")
            targetCountTxt:setText(tdata.num .. tdata.unit)

            local image_icon = item:getChildByName("Image_prop_icon")
            UrlImage.spriteSetUrl(image_icon,tdata.prize_icon,true)
        end

        local lastItem = arr[#arr]
        --如果最后一个任务不是未完成，说明任务数达成，可以隐藏立刻玩牌按钮
        -- if lastItem.prizeStatus ~= 0 then
        --     self.buyBtn:setVisible(false)
        -- else
        --     self.buyBtn:setVisible(true)
        -- end 

        local maxCount = lastItem.num
        local curCount = lastItem.curNum
        local progress = finishTask / PERSON_REWARD_COUNT
        if progress < 0 then
            progress = 0
        end
        if progress > 1 then
            progress = 1
        end
        if progress == 0 then
            self.loginDayProgBar_:setVisible(false)
        else
            if progress <= 0.1 then
                progress = 0.1
            end
            self.loginDayProgBar_:setVisible(true)
            self.loginDayProgBar_:setSize(progress * self.progressNodeW)
        end

        local paperUrl = lastItem.image
        local btnUrl = lastItem.btn_url
        local desc = lastItem.desc
        local btn_name = lastItem.btn_name

        if not self.personalRuleRichTxt then
            --替换为richtxt
            self.personalRuleRichTxt = new(RichText,desc or "", 441, 116, kAlignTopLeft, "", 20, 220, 190, 255, true)
            self:getUI("ruleScrollView"):addChild(self.personalRuleRichTxt)
        else
            self.personalRuleRichTxt:setText(desc or "")
        end

        self.buyBtnTxt:setText(btn_name or "")
        self.paperContainer:setRatio(1)
        UrlImage.spriteSetUrl(self.paperContainer,paperUrl,true)

        self.countRichText:setText(bm.LangUtil.getText("LIMIT_TIME_EVENT","GAME_COUNT", curCount))

        if sdata then
            nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"LimitTimeEventPopup",{{name=sdata.prize or "",icon = sdata.prize_icon or ""}}) 
        end
    end
end

function LimitTimeEventPopup:onGetEventDataCallback(data, kind, isNeedAnim)
    self:setLoading(false)
    if data then
        if kind == 1 then
            if data.all and data.all.counts and self.m_fullServiceEventView then
                -- 更新全服活动界面
                self.m_fullServiceEventView:updataView(data.all, isNeedAnim)
            end
            -- 更新个人活动界面
            self:updateSingleView(2)
      
        elseif kind == 2 and self.m_fullServiceEventView then
            self.m_fullServiceEventView:fullServerEventCurNumCallback(data, isNeedAnim)
        end
    end
end

function LimitTimeEventPopup:onRefreshCountdownTime(time_table)
    local text = bm.LangUtil.getText("LIMIT_TIME_EVENT","TIME_COUNTDOWN", time_table.time_str)
    if time_table.day > 1 then
        text = bm.LangUtil.getText("LIMIT_TIME_EVENT","END_TIME", time_table.time_end)
    end
    if self.m_fullServiceEventView then 
        self.m_fullServiceEventView:setCountdownTimeStr(text, time_table.time)
    end
    self.timeRichText:setText(text)
end

function LimitTimeEventPopup:onClickBtn()
    local SingleEventArr = nk.limitTimeEventDataController:getSingleEventArr()
    if SingleEventArr and SingleEventArr[1] then
        self:btn_go_click(SingleEventArr[1].btn_url,SingleEventArr[1].ext)
    end
end

function LimitTimeEventPopup:btn_go_click(btnUrl,ext)
    if not btnUrl then return end
    btnUrl = tostring(btnUrl)
    if btnUrl == "0" then

    elseif btnUrl == "1" then
        nk.roomChooseType = 1
        if GameConfig.ROOT_CGI_SID == "2" then
            nk.roomChooseType = 2
        end
        if ext and ext["room"] then
            if ext["room"] == "1" then
                nk.roomChooseType = 1
            elseif ext["room"] == "2" then
                nk.roomChooseType = 2
            end
        end
        nk.PopupManager:addPopup(require("game.roomChoose.roomChoosePopup"), "hall")
    elseif btnUrl == "2" then
        nk.AnalyticsManager:report("New_Gaple_quickStart", "quickStart")

        if GameConfig.ROOT_CGI_SID == "2" then
            EnterRoomManager.getInstance():enter99Room()
        else
            EnterRoomManager.getInstance():enterGapleRoom()
        end
    elseif btnUrl == "3" or btnUrl == "4" then
        local StorePopup = require("game.store.popup.storePopup")
        nk.PopupManager:addPopup(StorePopup, "PromotePopup")

    elseif btnUrl == "5" then
        StateMachine.getInstance():pushState(States.Friend, nil, nil, 2)
    elseif btnUrl == "6" then
        local FeedbackPopup = require("game.setting.feedbackLayer")
        nk.PopupManager:addPopup(FeedbackPopup,"PromotePopup")
    elseif btnUrl == "7" then
        local TaskPopup = require("game.task.taskPopup")
        nk.PopupManager:addPopup(TaskPopup,"PromotePopup")
    elseif btnUrl == "8" then
        StateMachine.getInstance():pushState(States.Rank)
    elseif btnUrl == "9" then
        local FansCodePopup = require("game.freeGold.fansCodePopup")
        nk.PopupManager:addPopup(FansCodePopup,"PromotePopup")
    elseif btnUrl == "10" then
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "hall")
    elseif btnUrl == "11" then
        nk.AnalyticsManager:report("New_Gaple_activity", "activity")

        nk.ActivityNativeEvent:activityOpen()
    elseif btnUrl == "12" then
        nk.GameNativeEvent:openBrowser(ext)
    elseif btnUrl == "13" then
        if nk.UpdateConfig and nk.UpdateConfig.facebookFansUrl then
            nk.GameNativeEvent:openBrowser(bm.LangUtil.getText("ABOUT", "FANS_URL"))
        end
    else

    end

    self:hide()
end

function LimitTimeEventPopup:addPropertyObservers_()
    -- 全服活动
    self.fullEventHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "fullEventPoint", handler(self, function(obj, visible)
        if not nk.updateFunctions.checkIsNull(self) then
            if nk.limitTimeEventDataController:getAllEventRewardStatus() ~= -1 then
                self.m_FullServerEventRedPoint:setVisible(visible)
            else
                self.m_FullServerEventRedPoint:setVisible(false)
            end

            if visible and self.m_fullServiceEventView then
                self.m_fullServiceEventView:setRewardBtnStatus(1)
            end
        end
    end))

    -- 个人活动
    self.singleEventHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "singleEventPoint", handler(self, function(obj, visible)
        if not nk.updateFunctions.checkIsNull(self) then
            self.m_persionEventRedPoint:setVisible(visible)
        end
    end))
end

function LimitTimeEventPopup:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "fullEventPoint", self.fullEventHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "singleEventPoint", self.singleEventHandle_)
end

return LimitTimeEventPopup