--
-- Author: tony
-- Date: 2014-07-17 15:20:01
--
local OperationButton = import("game.roomQiuQiu.layers.operationButton")
local OperationButtonGroup = import("game.roomQiuQiu.layers.operationButtonGroup")
local RaiseSlider = import("game.roomQiuQiu.layers.raiseSlider")
local SeatStateMachine = import("game.roomQiuQiu.roomQiuQiuStateMachine")

local RoomImageButton = import("game.roomQiuQiu.layers.roomImageButton")
--local ExpressionPanel = import("app.module.room.views.expressionPanel")
local RoomTipsView = import("game.roomQiuQiu.layers.roomTipsView")

local RoomChatPopup = require("game.roomChat.roomChatPopup")

local OperationManager = class()

--别人操作
local LB_CHECK_AUTO = T("自动看牌")
local LB_CALL_BET = T("跟注")
local LB_CHECK_FOLD = T("看牌/弃牌")
local LB_CALL_ANY = T("跟任何注")

--自己操作
local LB_CHECK = T("看牌")
local LB_FOLD = T("弃牌")
local LB_RAISE = T("加注")
local LB_ALL_IN = T("全下")

local autoCallCount = 0         --自动跟注的数值，当有人加注，则取消自动跟注

function OperationManager:ctor()
end

function OperationManager:dtor()
    nk.GCD.Cancel(self)
    EventDispatcher.getInstance():unregister(EventConstants.evtBackgroundClick, self, self.onBackgroundClicked)
    self:removePropertyObservers()
end

function OperationManager:createNodes()
    local padding = 10

    -- 聊天按钮
    self.chatBtn = self.scene.nodes.oprNode:getChildByName("chatButton")
    self.chatBtn:setOnClick(self, self.onChatBtnClick)
    -- 聊天红点提示
    self.friendMsgNoReadTip = self.chatBtn:getChildByName("msgRedImage")
    self.friendMsgNoReadTip:setVisible(false)

    if nk.userData and nk.userData.chatRecord and #nk.userData.chatRecord > 0 then
        self.friendMsgNoReadTip:setVisible(true)
    end

    self.raiseSlider_ = new(RaiseSlider,self.model)
    self.raiseSlider_:setAlign(kAlignBottomRight)
    self.raiseSlider_:addTo(self.scene.nodes.popupNode, 3, 3)
    self.raiseSlider_:setPos(nil,OperationButton.BUTTON_HEIGHT + 10)
    self.raiseSlider_:onButtonClicked(handler(self, self.onRaiseSliderButtonClicked_))
    -- self.raiseSlider_:setValueRange(10000,10000, 400000,true)
    self.raiseSlider_:hidePanel()


    RoomTipsView.WIDTH = System.getScreenWidth() * 0.7 - 16 - padding
    self.tipsView_ = new(RoomTipsView)
    self.tipsView_:setPos(8, 44)
    self.tipsView_:setAlign(kAlignBottomRight)
    self.tipsView_:addTo(self.scene.nodes.oprNode)
    self.tipsView_:setVisible(false)

    -- 游戏中的操作层节点
    local oprBtnW = OperationButton.BUTTON_WIDTH + 10
    self.oprNode_ = self.scene.nodes.oprNode:getChildByName("gameOpNode")
    self.oprNode_:setVisible(false)
    self.checkGroup_ = new(OperationButtonGroup)
    self.oprBtn1_ = new(OperationButton)
    self.oprBtn1_:setLabel(LB_CALL_BET)
    self.oprBtn1_:setAlign(kAlignLeft)
    self.oprBtn1_:setPos(0)
    self.oprBtn1_:addTo(self.oprNode_)
    self.oprBtn2_ = new(OperationButton)
    self.oprBtn2_:setLabel(LB_CHECK_FOLD)
    self.oprBtn2_:setAlign(kAlignLeft)
    self.oprBtn2_:setPos(oprBtnW)
    self.oprBtn2_:addTo(self.oprNode_)
    self.oprBtn3_ = new(OperationButton)
    self.oprBtn3_:setLabel(LB_CALL_ANY)
    self.oprBtn3_:setAlign(kAlignLeft)
    self.oprBtn3_:setPos(oprBtnW*2)
    self.oprBtn3_:addTo(self.oprNode_)
    
    self.checkGroup_:add(1, self.oprBtn1_)
    self.checkGroup_:add(2, self.oprBtn2_)
    self.checkGroup_:add(3, self.oprBtn3_)
    -- self.scene:addEventListener(self.scene.EVT_BACKGROUND_CLICK, handler(self, self.onBackgroundClicked))

    self:addPropertyObservers()
    EventDispatcher.getInstance():register(EventConstants.evtBackgroundClick, self, self.onBackgroundClicked)
end

function OperationManager:startLoading()
    self.oprNode_:setVisible(false)
end

function OperationManager:stopLoading()
    self:updateOperationStatus()
end

--显示操作按钮，animation:是否使用动画(true/false)
function OperationManager:showOperationButtons(animation)
    self.oprNode_:stopAllActions()
    -- self.extOptView_:setVisible(false)
    if animation then
        self.oprNode_:setVisible(true)
        self.oprNode_:moveTo({time=0.5, x=0, y=0})
        -- transition.moveTo(self.tipsView_, {y = -80, time=0.5, onComplete=function() self.tipsView_:setVisible(false):stop() end})
    else
        self.oprNode_:setVisible(true)
        self.oprNode_:setPos(0, 0)
        self.tipsView_:setVisible(false)
        self.tipsView_:setPos(nil, -80)
        self.tipsView_:stop()
    end
end

--隐藏操作按钮，animation:是否使用动画(true/false)
function OperationManager:hideOperationButtons(animation)
    if animation then
        self.tipsView_:setVisible(true)
        self.tipsView_:play()
        -- self.tipsView_:moveTo(0.5, - 8 - RoomTipsView.WIDTH * 0.5,  44)
        self.oprNode_:moveTo({y=-100, time=0.5, onComplete=function() self.oprNode_:setVisible(false) end})
    else
        self.oprNode_:setVisible(false)
        self.oprNode_:setPos(0, -100)
        self.tipsView_:setVisible(true)
        self.tipsView_:play()
        self.tipsView_:setPos(nil, 44)
    end
    self.tipsView_:setVisible(false)
    
end

--禁用操作按钮
function OperationManager:blockOperationButtons()
    self:disabledStatus_()
end

-- 重置操作栏自动操作状态
function OperationManager:resetAutoOperationStatus()
    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil
    self:disabledStatus_()
end

--更新操作状态
function OperationManager:updateOperationStatus()
    nk.GCD.Cancel(self)
    self.raiseSlider_:hidePanel()

    local selfSeatId = self.model:selfSeatId()
    local gameStatus = self.model.gameInfo.gameStatus
    Log.dump(gameStatus, "gameStatus")  

    --不在位置上或者在等待开始游戏
    if not self.model:isSelfInSeat() or not self.model:isSelfInGame()  then
        self:disabledStatus_()
    else
        local selfPlayer = self.model:selfSeatData()
        local playerState = selfPlayer.statemachine:getState() 
        Log.dump(playerState, "playerState")       
        
        --如果是下注状态
        if playerState == SeatStateMachine.STATE_BETTING then 
            --如果是allin，自动发包看牌
            if selfPlayer.anteMoney == 0 then
                self:setBet_(consts.CLI_BET_TYPE_QIUQIU.CHECK,0)
                do return end
            end

            --下注面板，若之前勾选了自动看牌，但是有人加注，则取消自动看牌状态
            if self.autoAction_ == "LB_CALL_BET" and autoCallCount < self.model.gameInfo.quickCall then
                self:resetAutoOperationStatus()
                autoCallCount = self.model.gameInfo.quickCall
            else
                autoCallCount = self.model.gameInfo.quickCall
            end
            self:showBetOperationStatus(self.model.gameInfo.minAddAnte, self.model.gameInfo.maxAddAnte)
            --判断自动发包
            self:applyAutoOperation_()

        --如果是等待他人状态
        elseif playerState == SeatStateMachine.STATE_WAITING then
            --self.model.gameInfo.quickCall 为0 ，显示自动看牌，否则显示自动跟注XX
            --若之前勾选了自动跟注(不包括跟任何注)，但是有人加注，则取消自动跟注状态
            if self.autoAction_ == "LB_CALL_BET" and autoCallCount < self.model.gameInfo.quickCall then
                self:resetAutoOperationStatus()
                autoCallCount = self.model.gameInfo.quickCall
            else 
                autoCallCount = self.model.gameInfo.quickCall
            end
            self:showAutoOperationStatus()

        --其他状态无操作栏
        else
            self:disabledStatus_()
        end
    end
    
end

--设置筹码滑块
function OperationManager:setSliderStatus(minRaiseChips, maxRaiseChips)
    local selfSeatData = self.model:selfSeatData()
    --滑块最大值是否是所有携带,是即allin，否为最大加注值(其他玩家中最大携带)
    local isMaxAllin = maxRaiseChips == selfSeatData.anteMoney
    self.raiseSlider_:setValueRange(self.model.roomInfo.blind,minRaiseChips, maxRaiseChips,isMaxAllin)
end

--无法操作的状态
function OperationManager:disabledStatus_()
    self.chatBtn:setVisible(true)
    self:hideOperationButtons(false)
    self.raiseSlider_:hidePanel()
end

--下注操作时的界面状态
function OperationManager:showBetOperationStatus(minRaiseChips,maxRaiseChips)
    --a?b:c
    local str = autoCallCount == 0 and LB_CHECK or (LB_CALL_BET .." ".. nk.updateFunctions.formatBigNumber(autoCallCount))

    local all_in = (minRaiseChips == 0 and maxRaiseChips == 0)

    self.oprBtn1_:setLabel(str):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callCheckClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callFoldClickHandler))
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(not all_in):setCheckMode(false):onTouch(handler(self, self.callRaiseClickHandler))
    self:setSliderStatus(minRaiseChips, maxRaiseChips)

    self:showOperationButtons(false)
end

--设置自动操作的界面状态
function OperationManager:showAutoOperationStatus()
    self:showOperationButtons(false)
    --a?b:c
    local str = (autoCallCount == 0) and LB_CHECK_AUTO or (LB_CALL_BET .." ".. nk.updateFunctions.formatBigNumber(autoCallCount))

    self.oprBtn1_:setLabel(str):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn2_:setLabel(LB_CHECK_FOLD):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn3_:setLabel(LB_CALL_ANY):setEnabled(true):setCheckMode(true):onTouch(nil)

    self.raiseSlider_:hidePanel()
    self.checkGroup_:onChecked(function(id) 
        if id == 0 then
            if self.autoAction_ then 
                self.autoAction_ = nil
            end
            EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_HIDE_OPERATION_BAR)
        elseif id == 1 then
            self.autoAction_ = "LB_CALL_BET"
            local endPosx, endPosy = self.oprBtn1_:getAbsolutePos()
            local endPos = {endPosx + 40, endPosy + 40}
            local startPos = {endPosx + 40, endPosy - 20}
            EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL, {startPos = startPos,endPos = endPos})
        elseif id == 2 then
            self.autoAction_ = "LB_CHECK_FOLD"
            local endPosx, endPosy = self.oprBtn2_:getAbsolutePos()
            local endPos = {endPosx + 40, endPosy + 40}
            local startPos = {endPosx + 40, endPosy - 20}
            EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD, {startPos = startPos,endPos = endPos})
        else
            self.autoAction_ = "LB_CALL_ANY"
            local endPosx, endPosy = self.oprBtn3_:getAbsolutePos()
            local endPos = {endPosx + 40, endPosy + 40}
            local startPos = {endPosx - 40, endPosy - 20}
            EventDispatcher.getInstance():dispatch(EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL_ANY, {startPos = startPos,endPos = endPos})
        end
    end)
end

--点击看牌(跟注)按钮
function OperationManager:callCheckClickHandler(finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        --do 看牌或跟注
        if autoCallCount  == 0 then
            self:setBet_(consts.CLI_BET_TYPE_QIUQIU.CHECK,0)
        elseif autoCallCount > 0 then
            self:setBet_(consts.CLI_BET_TYPE_QIUQIU.CALL,autoCallCount)
        end

        autoCallCount = 0
        self.model.gameInfo.quickCall = 0

        self:disabledStatus_()
    end
end

--点击弃牌按钮
function OperationManager:callFoldClickHandler(finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        --do 弃牌
        self:setBet_(consts.CLI_BET_TYPE_QIUQIU.FOLD,0)

        autoCallCount = 0
        self.model.gameInfo.quickCall = 0

        self:disabledStatus_()
        EventDispatcher.getInstance():dispatch(EventConstants.SELF_CLICK_FOLD_CARD)
    end
end

--点击加注按钮
function OperationManager:callRaiseClickHandler(finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        --do 加注
        if not self.raiseSlider_:getVisible() then
            self.raiseSlider_:showPanel()
        else 
            self:onRaiseSliderButtonClicked_()

            autoCallCount = 0
            self.model.gameInfo.quickCall = 0

            self:disabledStatus_()
        end
    end
end

-- 下注
function OperationManager:setBet_(type , bet)
    nk.SocketController:setBet(type,bet)
end

-- 勾选了自动看牌跟注等，在这里自动发包
function OperationManager:applyAutoOperation_()
    local autoAction = self.autoAction_
    if autoAction == nil then
        return false
    elseif autoAction == "LB_CALL_BET" then
        -- 自动跟注 //
        if autoCallCount == 0 then
            self:setBet_(consts.CLI_BET_TYPE_QIUQIU.CHECK,0)
        else 
            self:setBet_(consts.CLI_BET_TYPE_QIUQIU.CALL,autoCallCount)
        end
    elseif autoAction == "LB_CHECK_FOLD" then
        -- 自动看牌/弃牌 //
        if autoCallCount == 0 then
            self:setBet_(consts.CLI_BET_TYPE_QIUQIU.CHECK,0)
        else 
            self:setBet_(consts.CLI_BET_TYPE_QIUQIU.FOLD,0)
            EventDispatcher.getInstance():dispatch(EventConstants.SELF_CLICK_FOLD_CARD)
        end
    elseif autoAction == "LB_CALL_ANY" then
        -- 自动跟任何注
        self:setBet_(consts.CLI_BET_TYPE_QIUQIU.CALL,autoCallCount)
    end

    autoCallCount = 0
    self.model.gameInfo.quickCall = 0

    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil

    self:disabledStatus_()
    return true
end

function OperationManager:onRaiseSliderButtonClicked_(tag)
    Log.printInfo("--------------------------------....--------",tag)
    local raiseSliderValue = self.raiseSlider_:getLabelValue()
    print("---->raiseSliderValue="..raiseSliderValue)

    if tag == 1 then
        raiseSliderValue = self.model.gameInfo.totalAnte*4 
    elseif tag == 2 then
        raiseSliderValue = self.model.gameInfo.totalAnte*2     
    elseif tag == 3 then
        raiseSliderValue = self.model.gameInfo.totalAnte*1
    elseif tag == 4 then
        raiseSliderValue = self.model.lastAnte * 3
    elseif tag == 5 then
        -- raiseSliderValue = self.raiseSlider_:getLabelValue()
    end
    print("---->raiseSliderValue="..raiseSliderValue)
    self:setBet_(consts.CLI_BET_TYPE_QIUQIU.RAISE,raiseSliderValue)

    self.raiseSlider_:hidePanel()
    self:disabledStatus_()
end

function OperationManager:onBackgroundClicked()
    if self.raiseSlider_ then
        self.raiseSlider_:hidePanel()
    end
end

function OperationManager:onChatBtnClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if not self.clicked then
        self.clicked = true
        if nk.loginRoomSuccess then
            nk.PopupManager:addPopup(RoomChatPopup,"RoomQiuQiu",self.ctx,2)
            self.friendMsgNoReadTip:setVisible(false)
        end
    end
    nk.GCD.PostDelay(self, function()
        self.clicked = false
    end, nil, 500)
end

function OperationManager:addPropertyObservers()
    self.chatRecordHandle = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", handler(self, function (obj, chatRecord)
        if not nk.updateFunctions.checkIsNull(obj) then
            if chatRecord and #chatRecord>0 then
                local isHave = nk.PopupManager:hasPopup(nil,"WAndFChatPopup")
                if not isHave then
                    obj.friendMsgNoReadTip:setVisible(true)  
                end
            else
                obj.friendMsgNoReadTip:setVisible(false)  
            end
        end
    end))
end

function OperationManager:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", self.chatRecordHandle)
end

return OperationManager