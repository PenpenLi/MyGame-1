-- hallScene.lua
-- Last modification : 2016-05-11
-- Description: a scene in Hall moudle
local PopupModel = import('game.popup.popupModel')
local RulesPopup = require("game.setting.rulesPopup")
local StorePopup = require("game.store.popup.storePopup")
local EaseMoveAnim = require("game.anim.easeMoveAnim") 
local RoomChoosePopup = class(PopupModel)
local RoomChooseItem = require('game.roomChoose.roomChooseItem')

local RoomChoosePopupLayer = require(VIEW_PATH .. "roomChoose.roomChoose_scene")
local varConfigPath = VIEW_PATH .. "roomChoose.roomChoose_scene_layout_var"


function RoomChoosePopup.show()
    PopupModel.show(RoomChoosePopup, RoomChoosePopupLayer, varConfigPath, {name="RoomChoosePopup", defaultAnim=false})
end

function RoomChoosePopup.hide()
     PopupModel.hide(RoomChoosePopup)
 end

function RoomChoosePopup:ctor(viewConfig, varConfigPath)
    Log.printInfo("RoomChoosePopup.ctor");
    self.m_defaultType = nk.roomChooseType or 1
    self.m_defaultStep = 1
    self.m_curViewData = {} 
    self.m_easeMoveTable = {}

    self:initScene()
    self:updataTopTitle()
    self:onRoomTypeSelect(self.m_defaultType)
    nk.HornTextRotateAnim.setupScene("")
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
    EventDispatcher.getInstance():register(EventConstants.close_limit_time_giftbag, self, self.onLimitTimeClose)
end 

function RoomChoosePopup:dtor()
    self:stopEnterAnim()
    nk.HornTextRotateAnim.setupScene("hall")
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
    EventDispatcher.getInstance():unregister(EventConstants.close_limit_time_giftbag, self, self.onLimitTimeClose)
    if not self.m_notAnim then
        EventDispatcher.getInstance():dispatch(EventConstants.showHallEnterAnim)
    end

    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", self.onFirstRechargeStatusHandle_)
end 

function RoomChoosePopup:initScene()
    self:initTopNode()
    self:initChangeTypeNode()
    self:initRoomStepNode()
    self:initRoomListView()
end

function RoomChoosePopup:initTopNode()
    self.m_returnBtn = self:getControl(self.s_controls["return_btn"])
    self.m_roomTypeChangeBtn = self:getControl(self.s_controls["title_btn"])
    self.m_titlePrivate = self:getControl(self.s_controls["title_p_icon"])
    self.m_titleGaple = self:getControl(self.s_controls["title_g_icon"])
    self.m_titleQiuQiu = self:getControl(self.s_controls["title_q_icon"])

    self.quickPayBtn = self:getUI("quickPayBtn")
    self.quickPayBtn:setOnClick(self,self.onQuickPayButtonClick)
    self.firstPayBtn = self:getUI("firstPayBtn")
    self.firstPayBtn:setOnClick(self,self.onFirstPayButtonClick)

    self.limitTimeBtn = self:getUI("LimitTimeBtn")
    self.limitTimeText = self:getUI("LimitTimeText")
    self.limitTimeNum = self:getUI("NumText")
    self.limitTimeNumBg = self:getUI("NumBg")
    self.limitTimeBtn:setVisible(false)
    self.limitPos_x, self.limitPos_y = self.limitTimeBtn:getPos()
    self:onLimitTimeOpen(nk.limitInfo)


    self.m_discountBg = self:getUI("DiscountBg")
    self.m_discountLabel = self:getUI("DiscountText")
    self.m_discountBg:setVisible(false)
    if nk.maxDiscount>0 then
        self.m_discountBg:setVisible(true)
        self.m_discountLabel:setText("+"..nk.maxDiscount.."%")
    end
    self.onFirstRechargeStatusHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", handler(self, self.recharge))
end

function RoomChoosePopup:onLimitTimeOpen(pack)
    if pack then
        local num = pack.num
        local tnum = pack.tnum
        if nk.limitTimer:getTime() >0 then
            nk.limitTimer:addTimeText(self.limitTimeText)
            if tnum and  num then
                if tnum>0 then
                    self.limitTimeNumBg:setVisible(true)
                    self.limitTimeNum:setText(num.."/"..tnum)
                else
                    self.limitTimeNumBg:setVisible(false)
                end
                if num==0 then
                    self.limitTimeBtn:setVisible(false) 
                else
                    self.limitTimeBtn:setVisible(true)
                    self.firstPayBtn:setVisible(false)
                end
            end
        end
    end
end


function RoomChoosePopup:onLimitTimeClick()
    if self.m_defaultType == 1 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_LIMIT_PAY
        nk.AnalyticsManager:report("New_Gaple_choose_gaple_limit_pay", "limitPay")
    elseif self.m_defaultType == 2 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_LIMIT_PAY
        nk.AnalyticsManager:report("New_Gaple_choose_qiuqiu_limit_pay", "limitPay")
    end

    nk.PopupManager:addPopup(require("game.limitTimeGiftbag.limitTimeGiftbagPopup"),"hall") 
end

function RoomChoosePopup:onLimitTimeClose(isBuySuccess)
    if isBuySuccess then
        self.firstRechargeStatus=0
    end
    self.limitTimeBtn:setVisible(false)
    if self.firstRechargeStatus and self.firstRechargeStatus==1 then
        self.firstPayBtn:setVisible(true)
        self.quickPayBtn:setVisible(false)
    else
        self.firstPayBtn:setVisible(false)
        self.quickPayBtn:setVisible(true)
    end
end

function RoomChoosePopup:recharge(firstRechargeStatus)
    if firstRechargeStatus and firstRechargeStatus == 1 then
        self.firstRechargeStatus = firstRechargeStatus
        if nk.limitTimer:getTime()>0 then
            self.quickPayBtn:setVisible(false)
            self.firstPayBtn:setVisible(false)
            local x,y = self.quickPayBtn:getPos()
            self.limitTimeBtn:setPos(x,self.limitPos_y)
        else
            self.firstPayBtn:setVisible(true)
            self.quickPayBtn:setVisible(false)
        end
    else
        self.limitTimeBtn:setPos(self.limitPos_x, self.limitPos_y)
        self.quickPayBtn:setVisible(true)
        self.firstPayBtn:setVisible(false)
    end
end
-- 快捷支付按钮点击
function RoomChoosePopup:onQuickPayButtonClick()
    Log.printInfo("RoomChoosePopup","onQuickPayButtonClick")
    if self.m_defaultType == 1 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_FAST_PAY
        nk.AnalyticsManager:report("New_Gaple_choose_gaple_quick_pay", "quickpPay")
    elseif self.m_defaultType == 2 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_FAST_PAY
        nk.AnalyticsManager:report("New_Gaple_choose_qiuqiu_quick_pay", "quickpPay")
    end
    nk.updateFunctions.makeQuickPay()
end

-- 首充支付按钮点击
function RoomChoosePopup:onFirstPayButtonClick()
    Log.printInfo("RoomChoosePopup","onFirstPayButtonClick")
    if self.m_defaultType == 1 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_FISRT_PAY
    elseif self.m_defaultType == 2 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_FISRT_PAY
    end
    local FirstRechargePopup = require("game.firstRecharge.firstRechargePopup")
    nk.PopupManager:addPopup(FirstRechargePopup)
end

function RoomChoosePopup:initChangeTypeNode()
    self.m_roomTypeNode = self:getControl(self.s_controls["roomTypeNode"])

    self.m_RoomTypeBtn1 = self:getControl(self.s_controls["roomType1"])
    self.m_RoomTypeBtn1:setOnClick(self, function( ... )
       self:onRoomTypeSelect(1)
    end)
    self.m_TypeSelect1 = self:getControl(self.s_controls["selected1"])

    self.m_RoomTypeBtn2 = self:getControl(self.s_controls["roomType2"])
    self.m_RoomTypeBtn2:setOnClick(self, function( ... )
       self:onRoomTypeSelect(2)
    end)
    self.m_TypeSelect2 = self:getControl(self.s_controls["selected2"])

    self.m_RoomTypeBtn3 = self:getControl(self.s_controls["roomType3"])
    self.m_RoomTypeBtn3:setOnClick(self, function( ... )
       self:onRoomTypeSelect(3)
    end)
    self.m_TypeSelect3 = self:getControl(self.s_controls["selected3"])

    self.m_TypeSelectGroup = {
        [1] = self.m_TypeSelect1,
        [2] = self.m_TypeSelect2,
        [3] = self.m_TypeSelect3,
    };
    self:onRoomTypeChangeBtnClick()
end

function RoomChoosePopup:onTypeChangeBgTouch()
    self.m_roomTypeNode:setVisible(false)
end

function RoomChoosePopup:onRoomTypeSelect(roomType)
    nk.AnalyticsManager:report("New_Gaple_roomType", "roomType")

    self.m_defaultType = roomType
    self.m_defaultStep = 1
    if roomType == 3 then
        -- 切换到私人房
    else
        self:updataTopTitle()
        self:onRoomStepChange(self.m_defaultStep)
    end
    self.m_roomTypeNode:setVisible(false)
end

function RoomChoosePopup:updataTopTitle()
    local title = {
        [1] = self.m_titleGaple,
        [2] = self.m_titleQiuQiu,
        [3] = self.m_titlePrivate,
    }
    for k,v in ipairs(title) do
        local visible = k == self.m_defaultType and true or false
        v:setVisible(visible)
    end
end

function RoomChoosePopup:initRoomStepNode()
    self.m_roomStepbg = self:getUI("roomStepbg")
    self.m_roomStepbg:setVisible(false)
    self.m_roomStepPemula = self:getUI("roomStepPemula")
    self.m_roomStepPemula:setVisible(true)

    self.m_roomStepBtn1 = self:getControl(self.s_controls["buttonLeft"])
    self.m_roomStepBtn1:setOnClick(self, self.onRoomStepBtn1Click)
    self.m_roomStepBtn2 = self:getControl(self.s_controls["buttonMiddle"])
    self.m_roomStepBtn2:setOnClick(self, self.onRoomStepBtn2Click)
    self.m_roomStepBtn3 = self:getControl(self.s_controls["buttonRight"])
    self.m_roomStepBtn3:setOnClick(self, self.onRoomStepBtn3Click)

    self.m_stepBtn = {}
    for i=1, 3 do
        local temp = {}
        temp.bg = self:getControl(self.s_controls["buttonBg" .. i])
        temp.name = self:getControl(self.s_controls["buttonName" .. i])
        table.insert(self.m_stepBtn,i,temp)
    end 
end

function RoomChoosePopup:onHelpBtnClick()
    nk.PopupManager:addPopup(RulesPopup,"hall",1)
end

function RoomChoosePopup:onMallBtnClick()
    if self.m_defaultType == 1 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_SHOP_PAY
    elseif self.m_defaultType == 2 then
        nk.payScene = consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_SHOP_PAY
    end
    nk.PopupManager:addPopup(StorePopup, "hall")
end

function RoomChoosePopup:onRoomStepBtn1Click()
    self:onRoomStepChange(1)
end

function RoomChoosePopup:onRoomStepBtn2Click()
    self:onRoomStepChange(2)
end

function RoomChoosePopup:onRoomStepBtn3Click()
    self:onRoomStepChange(3)
end

function RoomChoosePopup:updataStepButton()
    for k,button in ipairs(self.m_stepBtn) do
        local visible = k == self.m_defaultStep and true or false
        button.bg:setVisible(visible)

        if k == self.m_defaultStep then
            button.name:setColor(225,194,251)
        else
            button.name:setColor(179,135,231)
        end

    end
end

function RoomChoosePopup:onRoomStepChange(roomStep)
    self.m_defaultStep = roomStep
    local roomConfig = {}
    if self.m_defaultType == 1 then
        roomConfig = nk.DataProxy:getData(nk.dataKeys.TABLE_NEW_CONF) or {}
    elseif self.m_defaultType == 2 then
        roomConfig = nk.DataProxy:getData(nk.dataKeys.TABLE_99_NEW_CONF) or {}
    end
    self.m_curViewData = roomConfig[self.m_defaultStep]
    if self.m_curViewData then
        self:updataStepButton()
        self:createListView(self.m_curViewData)
    else
        self.m_roomListView:removeAllChildren()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "NOTOPEN")) 
    end
    if #roomConfig > 1 then
        self.m_roomStepbg:setVisible(true)
        self.m_roomStepPemula:setVisible(false)
    else
        self.m_roomStepbg:setVisible(false)
        self.m_roomStepPemula:setVisible(true)
    end
end

function RoomChoosePopup:initRoomListView()
    self.m_roomListView = self:getControl(self.s_controls["roomListView"])
    self.m_roomListView:setDirection(kVertical);
end


function RoomChoosePopup:onItemClick(data)
    -- RoomChoosePopup.hide()
    self.m_notAnim = true
    nk.enterRoomFromChoosePopup = true
    EventDispatcher.getInstance():dispatch(EventConstants.tryToEnterRoom, data, self.m_defaultType);
end

function RoomChoosePopup:onReturnBtnClick()
    Log.printInfo("RoomChoosePopup onReturnBtnClick")
    RoomChoosePopup.hide()
end

function RoomChoosePopup:onRoomTypeChangeBtnClick()
    Log.printInfo("RoomChoosePopup onRoomTypeChangeBtnClick")
    self.m_roomTypeNode:setVisible(true)
    for k,TypeSelect in ipairs(self.m_TypeSelectGroup) do
        TypeSelect:setVisible(k == self.m_defaultType)
    end
end

function RoomChoosePopup:createListView(curData)
    self:stopEnterAnim()
    self.m_roomListView:removeAllChildren()
    local pos_x, pos_y = 0, 0
    for index, data in ipairs(curData) do
        local item = new(RoomChooseItem, data, index, self.m_defaultType)
        item:setDelegate(self, self.onItemClick)
        local width, height = item:getSize()
        pos_x = (index+1)%2*width
        item:setPos(pos_x, pos_y)
        self.m_roomListView:addChild(item)
        if index%2 == 0 then
            pos_y = pos_y + height
        end   

        if QUALITY_MODE ~= 0 then
            local itemEaseMoveAnim = new(EaseMoveAnim)
            local bet = math.floor((index-1)/2)
            local layoutScale = System.getLayoutScale()/1.25
            itemEaseMoveAnim:move(item, nil, true, nil, nil, (600-200*bet)*layoutScale, -(600-200*bet)*layoutScale, 1000, 100*bet, 1, "easeInOutBack")
            table.insert(self.m_easeMoveTable,itemEaseMoveAnim)
        end
    end
    self.m_roomListView:update()

    self:getPlayerOnLineNum()
end

function RoomChoosePopup:stopEnterAnim()
    for i,anim in ipairs(self.m_easeMoveTable) do
        anim:stopMove()
    end
    self.m_easeMoveTable = {}
end

function RoomChoosePopup:getPlayerOnLineNum()
    local httpMethod = ""
    if self.m_defaultType == 1 then
        httpMethod = "GameServer.getRoomSitNumber"
    elseif self.m_defaultType == 2 then
        httpMethod = "GameServer.get99RoomSiteNumber"
    end
    if httpMethod ~= "" then
        nk.HttpController:execute(httpMethod, {game_param = {}})
    end
end

function RoomChoosePopup:onHttpProcesser(command, errorCode, data)
    if command == "GameServer.getRoomSitNumber" or command == "GameServer.get99RoomSiteNumber" then
        if errorCode == 1 and data and data.code == 1 then
            local onLineData = data.data
            if onLineData and onLineData[1] and onLineData[1][self.m_defaultStep] then
                EventDispatcher.getInstance():dispatch(EventConstants.UPDATE_ONLINE_NUM, onLineData[1][self.m_defaultStep])
            end
        end
    end
end

return RoomChoosePopup

--[[

-       data    {time=1472459551 code=1 exetime=0.0028519630432129 codemsg="" data={} sid="1" } 
        time    1472459551  number
        code    1   number
        exetime 0.0028519630432129  number
        codemsg ""  string
-       data    {[1]={} }   
-       [1] {[1]={} }   
-       [1] {60000=0 40000=0 10000=0 20000=0 100000=0 200000=0 }    
        60000   0   number
        40000   0   number
        10000   0   number
        20000   0   number
        100000  0   number
        200000  0   number
        sid "1" string


]]