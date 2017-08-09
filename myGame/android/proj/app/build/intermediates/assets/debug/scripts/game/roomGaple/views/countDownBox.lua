
local RoomFreeChipPopup = require("game.roomFreeChip.roomFreeChipPopup")
local RoomFreeChipController = require("game.roomFreeChip.roomFreeChipController")

local CountDownBox  = class(Node)

function CountDownBox:ctor(ctx)
    self.ctx = ctx

    self.isFinished = false
    self.remainTime = 0
    self.reward = 0
    self.boxStatus_ = -1

    self.finishedButton = new(Button,"res/room/gaple/count_down_box_finished.png")
    self.finishedButton:setAlign(kAlignBottom)
    self.finishedButton:setVisible(false)
    self:addChild(self.finishedButton)
    self.finishedButton:setOnClick(self,self.showRoomFreeChip)

    self.rewardButton = new(Button,"res/room/gaple/count_down_box_reward.png")
    self.rewardButton:setAlign(kAlignBottom)
    self.rewardButton:setVisible(false)
    self:addChild(self.rewardButton)
    self.rewardButton:setOnClick(self,self.showRoomFreeChip)

    self.rewardLight = new(Image,"res/room/gaple/count_down_box_reward_light.png")
    self.rewardLight:setAlign(kAlignBottom)
    self.rewardLight:setVisible(false)
    self:addChild(self.rewardLight)

    self.countButton = new(Button,"res/room/gaple/count_down_box_normal.png")
    self.countButton:setAlign(kAlignBottom)
    self.countButton:setPos(-5,0)
    self.countButton:setVisible(true)
    self:addChild(self.countButton)
    self.countButton:setOnClick(self,self.showRoomFreeChip)

    self.timeBack_ = new(Image,"res/room/gaple/count_down_text_bg.png")
    self.timeBack_:setAlign(kAlignBottom)
    self.timeBack_:setPos(-5,0)
    self:addChild(self.timeBack_)

    self.timeLabel = new(Text,"00:00", 0, 0, kAlignCenter, nil, 16, 255, 255, 255)
    self.timeLabel:setAlign(kAlignCenter)
    self.timeBack_:addChild(self.timeLabel)


    self:bindDataObserver()

    local params = {}
    self.getInfoRequestId_ = nk.HttpController:execute("getChest", {game_param = params}, nil, handler(self, function (obj, errorCode, data)
        self.getInfoRequestId_ = nil
        if errorCode == 1 and data and data.code == 1 then
            local callData = data.data
            self.isFinished = callData.time <= 0 and callData.nextMoney == 0
            self.remainTime = callData.time or 0
            self.reward = callData.nextMoney or 0
            self.multiple = callData.multiple or 1
            if self.showFunc and self.timeLabel.m_res then
                self:showFunc()
            end
        end
    end ))
end

function CountDownBox:showFunc()
    self.countDown = false

    self:showStatus()

    -- 重连
    if self.ctx.model:isSelfInSeat() then
        self:sitDownFunc()
    end
end

function CountDownBox:showStatus()
    if self.isFinished then
        self:countDownStatus(false)
    elseif not self.isFinished and self.remainTime and self.remainTime <= 0 then
        self:countDownStatus(false)
    else
        self:countDownStatus(self.ctx.model:isSelfInSeat())
    end

    self:onShowOpenBox()

    if not tolua.isnull(self.m_rFChipCtrl) then
        self.m_rFChipCtrl:setBoxData(self:getBoxData())
    end
end

function CountDownBox:onShowOpenBox()
    if tolua.isnull(self.timeLabel) then
        return
    end

    local rewardButtonIsShow = false

    --设置宝箱
    if (not self.isFinished and self.remainTime and self.remainTime <= 0) 
        or (nk.userData["invitableLevel"] and #nk.userData["invitableLevel"] ~= 0) 
        or nk.taskController:getTaskCanGetNum() > 0 
        then
        self.finishedButton:setVisible(false)
        self.rewardButton:setVisible(true)
        self.rewardLight:setVisible(true)
        -- self.rewardLight:runAction(CCRepeatForever:create(transition.sequence({
        --     CCRotateTo:create(2, 180), 
        --     CCRotateTo:create(2, 360)
        -- })))
        self.countButton:setVisible(false)

        rewardButtonIsShow = true
    else
        self.finishedButton:setVisible(false)
        self.rewardButton:setVisible(false)
        self.rewardLight:setVisible(false)
        -- transition.stopTarget(self.rewardLight)
        self.countButton:setVisible(true)
    end

    --设置文本
    if self.remainTime and self.remainTime > 0 then
        local timeStr = nk.TimeUtil:getTimeString(self.remainTime)
        self.timeLabel:setText(timeStr)
    elseif self.isFinished then
        self.timeLabel:setText("")
        self.timeBack_:setVisible(false)
        if rewardButtonIsShow then
            self.timeLabel:setText(bm.LangUtil.getText("COUNTDOWNBOX", "CLICK_GET"))
            self.timeBack_:setVisible(true)
        end
    else
        self.timeLabel:setText(bm.LangUtil.getText("COUNTDOWNBOX", "CLICK_GET"))
    end
end

function CountDownBox:onShowTaskRedPoint()
    self:onShowOpenBox()
end

function CountDownBox:onHideUpgradeRedPoint()
    self:onShowOpenBox()
end

function CountDownBox:countDownStatus(status)
    if self.countDown and not status then
        if self.postDelay_id then
            nk.GCD.CancelById(self,self.postDelay_id)
        end
    end
    if not self.countDown and status then
        self.postDelay_id = nk.GCD.PostDelay(self, function()
			self:countFunc()
	    end, nil, 1000, true)
    end
    self.countDown = status
end

function CountDownBox:countFunc()
    self.remainTime = self.remainTime or 0
    self.remainTime = self.remainTime - 1
    if self.remainTime <= 0 then
        self:showStatus()
    end

    self:showTime()

    if not tolua.isnull(self.m_rFChipCtrl) then
        self.m_rFChipCtrl:setBoxData(self:getBoxData())
    end
end

function CountDownBox:showTime() 
    self:onShowOpenBox()
end 

function CountDownBox:getBoxData()
    local boxData = {}
    boxData.isFinished = self.isFinished
    boxData.remainTime = self.remainTime
    boxData.reward = self.reward
    return boxData
end

function CountDownBox:showRoomFreeChip()
    nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_NORMAL)

    self.m_rFChipCtrl = new(RoomFreeChipController)
    nk.PopupManager:addPopup(RoomFreeChipPopup,"roomGaple",self.ctx, self.m_rFChipCtrl)
    self.m_rFChipCtrl:setBoxData(self:getBoxData())

    self.finishedButton:setEnable(false)
    self.rewardButton:setEnable(false)
    self.countButton:setEnable(false)

    nk.GCD.PostDelay(self, function()
		self.finishedButton:setEnable(true)
        self.rewardButton:setEnable(true)
        self.countButton:setEnable(true)
    end, nil, 2000)


    nk.taskController:setTaskCanGetNum()
end


function CountDownBox:getBoxRewardSucc(callData)
    if callData then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "REWARD", self:formatMoney(self.reward)))
        EventDispatcher.getInstance():dispatch(EventConstants.GET_COUNTDOWNBOX_REWARD, self.reward)
        self.isFinished = callData.nextTime <= 0 and callData.nextMoney == 0
        self.remainTime = callData.nextTime or 0
        self.reward = callData.nextMoney or 0

        self:showStatus()
        self:showTime()
    end
end

function CountDownBox:getBoxRewardFail(errData)
    if errData and type(errData) == "table" and errData.errorCode then
        if errData.errorCode == -1 then
            --已经全部领取完
            self.isFinished = true
            self.remainTime = 0
        elseif errData.errorCode == -3 then
            --时间未到，校正时间
            local retData = errData.retData
            self.remainTime = retData.data.nextTime
            self:showStatus()
            self:showTime()
        end
    end
end

function CountDownBox:formatMoney(money)
    if money then
        if money < 100000 then
            money = nk.updateFunctions.formatNumberWithSplit(money)
        else
            money = nk.updateFunctions.formatBigNumber(money)
        end
    end
    return money or 0
end

function CountDownBox:bindDataObserver()
    self.onDataObserver = nk.DataProxy:addDataObserver(nk.dataKeys.SIT_OR_STAND, handler(self, self.sitStatusFunc))

    EventDispatcher.getInstance():register(EventConstants.getRFCBoxRewardSucc, self, self.getBoxRewardSucc)
    EventDispatcher.getInstance():register(EventConstants.getRFCBoxRewardFail, self, self.getBoxRewardFail)
    EventDispatcher.getInstance():register(EventConstants.FREE_CHIP_CAN_GET_REWARD_NUM, self, self.onShowTaskRedPoint)
    EventDispatcher.getInstance():register(EventConstants.FREE_CHIP_GET_LEVEL_UP_REWARD, self, self.onHideUpgradeRedPoint)
end

function CountDownBox:unbindDataObserver()
    nk.DataProxy:removeDataObserver(nk.dataKeys.SIT_OR_STAND, self.onDataObserver)

    EventDispatcher.getInstance():unregister(EventConstants.getRFCBoxRewardSucc, self, self.getBoxRewardSucc)
    EventDispatcher.getInstance():unregister(EventConstants.getRFCBoxRewardFail, self, self.getBoxRewardFail)
    EventDispatcher.getInstance():unregister(EventConstants.FREE_CHIP_CAN_GET_REWARD_NUM, self, self.onShowTaskRedPoint)
    EventDispatcher.getInstance():unregister(EventConstants.FREE_CHIP_GET_LEVEL_UP_REWARD, self, self.onHideUpgradeRedPoint)
end

function CountDownBox:sitStatusFunc(isSit)
    if tolua.isnull(self) then
        return
    end

    if isSit then
        self:sitDownFunc() 
    else 
        self:standUpFunc()
    end
end

function CountDownBox:sitDownFunc()     
    local params = {}
   	self.getInfoRequestId2_ = nk.HttpController:execute("getChest", {game_param = params}, nil, handler(self, function (obj, errorCode, data)
        self.getInfoRequestId2_ = nil
        if errorCode == 1 and data and data.code == 1 then
        	local callData = data.data
        	self.isFinished = callData.time <= 0 and callData.nextMoney == 0
            self.remainTime = callData.time
            self.reward = callData.nextMoney
            self.multiple = callData.multiple or 1
            if self.showStatus and self.timeLabel.m_res then
                self:showStatus()
            end
        end
    end ))
end

function CountDownBox:standUpFunc()
    self:countDownStatus(false)
end

function CountDownBox:dtor()
    self:unbindDataObserver()

    if self.getInfoRequestId_ then
    	delete(self.getInfoRequestId_)
        self.getInfoRequestId_ = nil
    end

    if self.getInfoRequestId2_ then
        delete(self.getInfoRequestId2_)
        self.getInfoRequestId2_ = nil
    end

    nk.GCD.Cancel(self)
end

return CountDownBox