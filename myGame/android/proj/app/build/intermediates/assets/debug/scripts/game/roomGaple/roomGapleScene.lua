-- hallScene.lua
-- Last modification : 2016-05-11
-- Description: a scene in Hall moudle
local RoomGapleScene = class(GameBaseSceneAsync);

RoomGapleScene.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

function RoomGapleScene:ctor(viewConfig, controller)
end 

function RoomGapleScene:start()
    nk.enterRoomMoney = nk.userData.money
    self.currentTableStyle = 1 -- 默认为1
end

function RoomGapleScene:resume()
    nk.SoundManager:stopMusic()
    nk.PopupManager:removeAllPopup()
    nk.isInRoomScene = true
    nk.roomSceneType = "gaple"
    GameBaseScene.resume(self)
    self:initScene()
    nk.HornTextRotateAnim.setupScene("")

    self:requestCtrlCmd("RoomGapleController.setRoomSceneNode", self)
    self:requestCtrlCmd("RoomGapleController.createNodes")
    nk.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
end

function RoomGapleScene:pause()
    nk.isInRoomScene = false
    nk.roomSceneType = ""
    nk.PopupManager:removeAllPopup()
    GameBaseScene.pause(self)
end 

function RoomGapleScene:dtor()
    nk.exitRoomMoney = nk.userData.money
    nk.GCD.Cancel(self) 
    nk.limitTimer:removeTimeText(self.limitTimeText)    
    nk.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", self.onFirstRechargeStatusHandle_)
    if nk.enterRoomFromChoosePopup then
        EventDispatcher.getInstance():dispatch(EventConstants.showRoomChoosePopup)
        nk.enterRoomFromChoosePopup = false
    end
    TextureCache.instance():clean_unused()
end 

function RoomGapleScene:initScene()
    self:initMainView()
    self:initMenu()
    self:initTopInfo()
    self:initOperator()
end

--[[
RoomGapleScene nodes:
    animLayer:动画层
    oprNode:操作按钮层
    lampNode:桌面灯光层
    chipNode:桌面筹码层
    dealCardNode:手牌层
    seatNode:桌子层
        seat1~9:桌子
            giftImage:礼物图片(*)
            userImage:用户头像
            backgroundImage:桌子背景
    backgroundNode:背景层
        dealerImage:荷官图片
        tableTextLayer:桌面文字
        tableImage:桌子图片
        backgroundImage:背景图片
]]

function RoomGapleScene:initMainView()

    self.nodes = {}

    self.nodes.centerNode = self:getControl(self.s_controls["centerNode"])
    self.nodes.backgroundNode = self:getControl(self.s_controls["backgroundNode"])
    self.nodes.topInfoBg = self:getControl(self.s_controls["topInfoBg"])
    self.nodes.dealerNode = self:getControl(self.s_controls["dealerNode"])
    self.nodes.signalNode = self:getUI("signal")
    self.nodes.chipNode = self:getControl(self.s_controls["chipNode"])    
    self.nodes.seatNode = self:getControl(self.s_controls["seatNode"])
    self.nodes.dealCardNode = self:getControl(self.s_controls["dealCardNode"])
    self.nodes.lampNode = self:getControl(self.s_controls["lampNode"])
    self.nodes.oprNode = self:getControl(self.s_controls["oprNode"])
    self.nodes.animNode = self:getControl(self.s_controls["animNode"])
    self.topNode = self:getControl(self.s_controls["topNode"])
    self.nodes.popupNode = self:getControl(self.s_controls["popupNode"])

    self.waitbg = self:getUI("waitBg")
    self.waitbg:setVisible(false)
    self.waitText_ = self:getUI("waitText")
    self.waitText_:setText(bm.LangUtil.getText("ROOM", "WAIT_NEXT_ROUND"))

    self:initPosConfig()
    
    self.nodes.backgroundNode:setEventTouch(self,function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
        if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            EventDispatcher.getInstance():dispatch(EventConstants.evtBackgroundClick)
            if self.m_menuBg then
                self.m_menuBg:setVisible(false)
            end
        end
    end)
end

function RoomGapleScene:initPosConfig()
    local SeatPosition = RoomViewPosition.SeatPosition
    local SeatPosRules = RoomViewPosition.SeatPosRules
    local DealCardPosition = RoomViewPosition.DealCardPosition
    local DealerPosition = RoomViewPosition.DealerPosition
    local TableRangle = RoomViewPosition.TableRangle
    local center_x, center_y = self.nodes.centerNode:getUnalignPos()

    local TempSeatNode = {}
    for i = 1, 5 do
        local seatNode = new(Node)
        seatNode:setSize(160,165)
        seatNode:setAlign(SeatPosRules[i].align)
        seatNode:setPos(SeatPosRules[i].x,SeatPosRules[i].y)
        self.nodes.dealCardNode:addChild(seatNode)
        TempSeatNode[i] = seatNode
        local x, y =  seatNode:getUnalignPos()
        SeatPosition[i] = {}
        SeatPosition[i].x = x
        SeatPosition[i].y = y

        if i < 5 then
            DealCardPosition[i] = {}
            DealCardPosition[i].x = x + 70
            DealCardPosition[i].y = y + 50
        end

        DealerPosition[i] = {}
        if i <= 2 then
            DealerPosition[i].x = x
            DealerPosition[i].y = y + 15
        elseif i <= 4 then
            DealerPosition[i].x = x + 130
            DealerPosition[i].y = y + 15
        elseif i == 5 then
            local dealer = self.nodes.dealerNode:getChildByName("dealerIcon")
            dealer:setPos(center_x, center_y - 140)
            DealerPosition[i].x, DealerPosition[i].y = center_x, center_y - 140

            DealerPosition[i + 1] = {}
            DealerPosition[i + 1].x = x + 130
            DealerPosition[i + 1].y = y + 15
        end 
    end

    -- TableRangle.x1 = center_x - 180
    -- TableRangle.y1 = center_y - 60
    -- TableRangle.x2 = center_x + 180
    -- TableRangle.y2 = center_y + 60

    TableRangle.x1 = SeatPosition[4].x + 160 + 180
    TableRangle.y1 = center_y - 60
    TableRangle.x2 = SeatPosition[1].x - 180
    TableRangle.y2 = center_y + 60

    -- local cardRangle = new(Image, "res/common/common_poker_dark_overlay_h.png",nil, nil, 25, 25, 25, 25)
    -- self.nodes.backgroundNode:addChild(cardRangle)
    -- cardRangle:setPos(TableRangle.x1,TableRangle.y1)
    -- cardRangle:setSize(TableRangle.x2 - TableRangle.x1, TableRangle.y2 - TableRangle.y1)
end

function RoomGapleScene:initMenu()
    self.m_menuBtn = self:getControl(self.s_controls["menuBtn"])

    self.m_menuBg = self:getControl(self.s_controls["menuBg"])
    self.m_menuBg:setVisible(false)  

    self.m_returnBtn = self:getControl(self.s_controls["lobbyBtn"])
    self.m_changeRoomBtn = self:getControl(self.s_controls["changeRoomBtn"])
    self.m_standUpBtn = self:getControl(self.s_controls["standUpBtn"])
    self.m_settingBtn = self:getControl(self.s_controls["settingBtn"])
end

function RoomGapleScene:initTopInfo()
    self.m_prizePool = self:getControl(self.s_controls["prizePool"])
    self.m_prizePoolChipNode = self:getControl(self.s_controls["chip_node"])
    self.roomInfo_ = self:getControl(self.s_controls["roomInfo"])
    self.privateRoomInfo_ = self:getControl(self.s_controls["privateRoomInfo"])

    self.quickPayBtn = self:getUI("quickPayBtn")
    self.quickPayBtn:setOnClick(self,self.onQuickPayButtonClick)
    self.firstPayBtn = self:getUI("firstPayBtn")
    self.firstPayBtn:setOnClick(self,self.onFirstPayButtonClick)

    self.limitTimeBtn = self:getControl(self.s_controls["LimitTimeGift"])
    self.limitTimeNum = self:getControl(self.s_controls["NumText"])
    self.limitTimeNumBg = self:getControl(self.s_controls["NumBg"])
    self.limitTimeText = self:getControl(self.s_controls["LimitTimeText"])
    self.limitTimeBtn:setVisible(false)
    -- self.limitTimeBtn:addPropScaleSolid(0, 0.9, 0.9, kCenterDrawing)
    self.limitPos = self.limitTimeBtn:getPos()
    self.limitAlign = self.limitTimeBtn:getAlign()
    self:onLimitTimeOpen(nk.limitInfo)

    self.onFirstRechargeStatusHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", handler(self, self.recharge))
end

function RoomGapleScene:recharge(firstRechargeStatus)
    if firstRechargeStatus and firstRechargeStatus == 1 then
        self.firstRechargeStatus = firstRechargeStatus
        if nk.limitTimer:getTime()>0 then
            self.quickPayBtn:setVisible(false)
            self.firstPayBtn:setVisible(false)
        else
            self.firstPayBtn:setVisible(true)
            self.quickPayBtn:setVisible(false)
        end
    else
        self.quickPayBtn:setVisible(true)
        self.firstPayBtn:setVisible(false)
    end
end

function RoomGapleScene:initOperator()
    self.m_chatBtn = self:getControl(self.s_controls["chatBtn"])
    self.m_inviteBtn = self:getControl(self.s_controls["inviteBtn"])
    self.m_mallBtn = self:getControl(self.s_controls["mallBtn"])
    self.m_discountBg = self:getControl(self.s_controls["DiscountBg"])
    self.m_discountText = self:getControl(self.s_controls["DiscountText"])
    self.fbLoginReward = self:getControl(self.s_controls["fbLoginReward"])
    self.fbLoginReward:setText("+" .. nk.updateFunctions.formatBigNumber(nk.userData.inviteBackChips))
    --商城打折信息
    self.m_discountBg:setVisible(false)
    if nk.maxDiscount and nk.maxDiscount>0 then
        self.m_discountBg:setVisible(true)
        self.m_discountText:setText("+"..nk.maxDiscount.."%")
    end
end

function RoomGapleScene:onLimitTimeClick()
    nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_LIMIT_PAY

    nk.PopupManager:addPopup(require("game.limitTimeGiftbag.limitTimeGiftbagPopup"),"hall") 
end

function RoomGapleScene:onLimitTimeOpen(pack)
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

function RoomGapleScene:onLimitTimeClose(isBuySuccess)
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

-- 快捷支付按钮点击
function RoomGapleScene:onQuickPayButtonClick()
    Log.printInfo("RoomGapleScene","onQuickPayButtonClick")
    nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_FAST_PAY
    nk.updateFunctions.makeQuickPay()
    nk.AnalyticsManager:report("New_Gaple_gaple_room_quick_pay", "quickpPay")
end

-- 首充支付按钮点击
function RoomGapleScene:onFirstPayButtonClick()
    Log.printInfo("RoomGapleScene","onFirstPayButtonClick")
    nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_FISRT_PAY
    local FirstRechargePopup = require("game.firstRecharge.firstRechargePopup")
    nk.PopupManager:addPopup(FirstRechargePopup)
end


function RoomGapleScene:onMenuBtnClick()
    self.m_menuBg:setVisible(true)
end

function RoomGapleScene:onReturnBtnClick()
    Log.printInfo("RoomGapleScene onReturnBtnClick")
    self.m_menuBg:setVisible(false)
    self:requestCtrlCmd("RoomGapleController.onReturnBtnClick")
end

function RoomGapleScene:onStandUpBtnClick()
    nk.AnalyticsManager:report("New_Gaple_room_standUp", "room")
    -- 站起
    self.m_menuBg:setVisible(false)
    if not nk.isInSingleRoom then
        self:onStandupClick_()
    end
end

function RoomGapleScene:onSettingBtnClick()
    local SettingPopup = require("game.setting.settingPopup")
    nk.PopupManager:addPopup(SettingPopup,"roomGaple")  
    self.m_menuBg:setVisible(false)
end

function RoomGapleScene:onInviteBtnClick()
    Log.printInfo("RoomGapleScene onInviteBtnClick")
    nk.AnalyticsManager:report("New_Gaple_room_invite", "room")

    local InviteScene = require("game.invite.inviteScene")
    nk.PopupManager:addPopup(InviteScene,"roomGaple")
end

function RoomGapleScene:onMallBtnClick()
    Log.printInfo("RoomGapleScene onMallBtnClick")
    nk.AnalyticsManager:report("New_Gaple_room_store", "room")
    nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_SHOP_PAY
    local StorePopup = require("game.store.popup.storePopup")
    if self.m_controller and self.m_controller.ctx and self.m_controller.ctx.model then
        local level = self.m_controller.ctx.model:roomType()
        nk.PopupManager:addPopup(StorePopup,"roomGaple",true,level)
    end
end

function RoomGapleScene:onBackgroundTouch()
    -- body
end


function RoomGapleScene:removeLoading()

end

function RoomGapleScene:setRoomStyle(tableStyle)
    tableStyle = math.min(tableStyle, 3) -- 当前最大是3
    if tableStyle ~= self.currentTableStyle then
        local bgResPathDict = {kImageMap.roomG_bg, kImageMap.roomG_bg_middle, kImageMap.roomG_bg_top}
        local topResPathDict = {kImageMap.roomG_top_light, kImageMap.roomG_top_light_middle, kImageMap.roomG_top_light_top}
        -- FwLog("roomLevel = " .. roomLevel)
        self.nodes.backgroundNode:setFile(bgResPathDict[tableStyle])
        self.nodes.topInfoBg:setFile(topResPathDict[tableStyle])
        self.currentTableStyle = tableStyle
    end
end

function RoomGapleScene:setRoomInfoText(roomInfo)
    local tableStyle = roomInfo.tableStyle or 1
    self:setRoomStyle(tableStyle)
    -- local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[roomLevel]

    local str = ""
    if roomInfo.blind < 100000 then
        str = nk.updateFunctions.formatNumberWithSplit(roomInfo.blind)
    else
        str = nk.updateFunctions.formatBigNumber(roomInfo.blind)
    end
    local info = bm.LangUtil.getText("ROOM", "ROOM_INFO", str)
    local privateInfo = ""
    self.privateRoomInfo_:setVisible(false)
    if roomInfo.roomName and roomInfo.roomName ~= "" then
        privateInfo = bm.LangUtil.getText("ROOM", "PRIVATE_ROOMNAME_INFO", nk.symbolFilter(roomInfo.roomName))
        self.privateRoomInfo_:setVisible(false)
    end
    if roomInfo.tid and tonumber(roomInfo.tid) > 0 then
        privateInfo = privateInfo .. "\n" .. bm.LangUtil.getText("ROOM", "PRIVATE_ROOMID_INFO", roomInfo.tid)
    end
    self.roomInfo_:setText(info)
    self.privateRoomInfo_:setText(privateInfo)
end

function RoomGapleScene:onStandupClick_()
    self:requestCtrlCmd("RoomGapleController.onStandUpBtnClick")
end

function RoomGapleScene:doBackToHall(msg, isKick)

end

function RoomGapleScene:doBackToLogin(msg)

end

function RoomGapleScene:onChangeRoomBtnClick()
    nk.AnalyticsManager:report("New_Gaple_room_change", "room")

    self.m_menuBg:setVisible(false)
    self:onChangeRoom_()
end

function RoomGapleScene:playNowChangeRoom()
    self:onChangeRoom_(true)
end

function RoomGapleScene:onChangeRoom_()
    if nk.loginRoomSuccess then
        if not self.changeCD then
            self.changeCD = true
            self:requestCtrlCmd("RoomGapleController.onChangeRoomBtnClick")
            nk.GCD.PostDelay(self, function()
                self.changeCD = false
            end, nil, 3000)
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "REQUIRE_LATER"))
        end
    end
end

function RoomGapleScene:onShareFbClicked()
    nk.PopupManager:addPopup(require("game.hall.shareToFbPopup"), "roomGaple")
end

-- UI control in layer
RoomGapleScene.s_UIcontrols = 
{
    --[RoomGapleScene.s_controls.***] = {"***","***","***"};
};

-- UI control handle
RoomGapleScene.s_controlFuncMap = 
{
    --[RoomGapleScene.s_controls.***] = function;
};

-- Provide cmd handle to call
RoomGapleScene.s_cmdHandleEx = 
{
    ["RoomGapleScene.onMenuBtnClick"] = RoomGapleScene.onMenuBtnClick,
    ["openLimitTimeGiftbag"] = RoomGapleScene.onLimitTimeOpen,
    ["closeLimitTimeGiftbag"] = RoomGapleScene.onLimitTimeClose,
};

return RoomGapleScene
