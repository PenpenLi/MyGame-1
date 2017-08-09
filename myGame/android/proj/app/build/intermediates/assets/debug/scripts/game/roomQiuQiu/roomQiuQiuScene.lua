-- roomQiuQiuScene.lua
-- Last modification : 2016-05-11
-- Description: a scene in Hall moudle
local RoomQiuQiuScene = class(GameBaseSceneAsync);

RoomQiuQiuScene.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

RoomQiuQiuScene.PrepareLoad = {
    "res/room/qiuqiu/qiuqiu_table_green.png",
    "res/room/qiuqiu/qiuqiu_table_purple.png",
    "res/room/qiuqiu/qiuqiu_table_red.png",
    "res/room/qiuqiu/qiuqiu_background.png",
    -- "res/room/qiuqiu/qiuqiu_card_type.png",
    "res/room/qiuqiu/dealer/room_dealer_normal.png",
    "atlas/qiuqiu.png",
    "atlas/roomRs.png",
    "res/room/gaple/roomG_more_bg.png",
    -- "res/common/common_nophoto.jpg",
    -- "res/room/qiuqiu/modifyCardCircle.png",
    -- "res/room/qiuqiu/modifyCardSpin.png",
    -- "res/room/qiuqiu/change_card_mode.png",

}

local SeatViewConfig = require(VIEW_PATH .. "roomQiuQiu.roomQiuQiu_seat_layer")
local RaiseSliderConfig = require(VIEW_PATH .. "roomQiuQiu.roomRaiseSlider_layer")

RoomQiuQiuScene.PreloadEditViews = {
    SeatViewConfig,
    SeatViewConfig,
    SeatViewConfig,
    SeatViewConfig,
    SeatViewConfig,
    SeatViewConfig,
    SeatViewConfig,
    RaiseSliderConfig,
}

function RoomQiuQiuScene:ctor(viewConfig, controller, dataClass, varConfig)
    nk.enterRoomMoney = nk.userData.money
    self.currentTableStyle = 1
end

function RoomQiuQiuScene:start()
    self:initScene()
end

function RoomQiuQiuScene:resume()
    nk.SoundManager:stopMusic()
    nk.PopupManager:removeAllPopup()
    nk.isInRoomScene = true
    nk.roomSceneType = "qiuqiu"
    GameBaseScene.resume(self)
    nk.HornTextRotateAnim.setupScene("")
    nk.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
end

function RoomQiuQiuScene:pause()
    nk.isInRoomScene = false
    nk.roomSceneType = ""
    nk.PopupManager:removeAllPopup()
    GameBaseScene.pause(self)
    nk.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
end 

function RoomQiuQiuScene:dtor()
    nk.exitRoomMoney = nk.userData.money
    nk.GCD.Cancel(self) 
    nk.limitTimer:removeTimeText(self.limitTimeText)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", self.onFirstRechargeStatusHandle_)
    if nk.enterRoomFromChoosePopup then
        EventDispatcher.getInstance():dispatch(EventConstants.showRoomChoosePopup)
        nk.enterRoomFromChoosePopup = false
    end
    TextureCache.instance():clean_unused()
end 

------------------------- private function ----------------------------
function RoomQiuQiuScene:initScene()
    self:initMainView()

    -- 房间信息Label
    self.roomInfo_ = self:getUI("roomInfoLabel")

    self.changeRoomBtn_ = self:getUI("changButton")
    self.standupBtn_ = self:getUI("standUpButton")
    self.leftTableImage = self:getUI("leftTableImage")
    self.rightTableImage = self:getUI("rightTableImage")

    self.quickPayBtn = self:getUI("quickPayBtn")
    self.quickPayBtn:setOnClick(self,self.onQuickPayButtonClick)
    self.firstPayBtn = self:getUI("firstPayBtn")
    self.firstPayBtn:setOnClick(self,self.onFirstPayButtonClick)

    self:setChangeRoomButtonMode(1)

    self.dealerChipLabel = self:getUI("dealerChipLabel")
    local isFirstSendDearlerChip = nk.DictModule:getBoolean("gameData", nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP .. nk.userData.uid, false)
    if isFirstSendDearlerChip then
        self.dealerChipLabel:setVisible(false)
    end

    -- TODO 清理聊天记录
    self.m_discountBg = self:getUI("DiscountBg")
    self.m_discountText = self:getUI("DiscountLabel")
    self.limitTimeBtn = self:getUI("LimitTimeBtn")
    self.limitPos = self.limitTimeBtn:getPos()
    self.limitAlign = self.limitTimeBtn:getAlign()
    self.limitTimeNum = self:getUI("NumText")
    self.limitTimeNumBg = self:getUI("NumBg")
    self.limitTimeText = self:getUI("LimitTimeText")
    self.fbLoginReward = self:getUI("fbLoginReward")
    self.fbLoginReward:setText("+" .. nk.updateFunctions.formatBigNumber(nk.userData.inviteBackChips))
    --商城打折信息
    self.m_discountBg:setVisible(false)
    if checkint(nk.maxDiscount) > 0 then
        self.m_discountBg:setVisible(true)
        self.m_discountText:setText("+"..nk.maxDiscount.."%")
    end
    self.limitTimeBtn:setVisible(false)
    self:onLimitTimeOpen(nk.limitInfo)
    self.onFirstRechargeStatusHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", handler(self, self.recharge))
end

function RoomQiuQiuScene:onLimitTimeClick()
    nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_LIMIT_PAY

    nk.PopupManager:addPopup(require("game.limitTimeGiftbag.limitTimeGiftbagPopup"),"hall") 
end

function RoomQiuQiuScene:onLimitTimeOpen(pack)
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
                end
            end
        end
    end
end

function RoomQiuQiuScene:onLimitTimeClose(isBuySuccess)
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

function RoomQiuQiuScene:recharge(firstRechargeStatus)
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

--[[
RoomQiuQiuScene nodes:
    animLayer:动画层
    oprNode:操作按钮层
    dealCardNode:手牌层
    chipNode:桌面筹码层
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

function RoomQiuQiuScene:initMainView()
    local bg = self:getUI("bg")
    bg:setEventTouch(self,function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
        if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            EventDispatcher.getInstance():dispatch(EventConstants.evtBackgroundClick)
        end
    end)
    self.bg = bg

    self.nodes = {}
    self.nodes.tableNode = self:getUI("tableNode")
    self.nodes.dealerNode = self:getUI("dealerNode")
    self.nodes.topNode = self:getUI("topNode")
    self.nodes.signalNode = self:getUI("signalNode")
    -- self.nodes.signalNode:setVisible(false)
    self.nodes.seatNode = self:getUI("seatNode")
    self.nodes.chipNode = self:getUI("chipNode")    
    self.nodes.dealCardNode = self:getUI("dealCardNode")
    self.nodes.oprNode = self:getUI("oprNode")
    self.nodes.animNode = self:getUI("animNode")
    self.nodes.guideNode = self:getUI("guideNode")
    self.nodes.menuNode = self:getUI("menuNode")
    self.nodes.popupNode = self:getUI("popupNode")

    self.nodes.dealerCenterNode = self:getUI("dealer_center_node")
    self.nodes.dealerChatNode = self:getUI("dealer_chat_node")
    self.nodes.dealerTouchNode = self:getUI("dealerTouchNode")

    local menuShadow = self:getUI("shadowBg")
    menuShadow:setEventTouch(self, self.onMenuShadowTouch)
end

function RoomQiuQiuScene:makeSelfInSeat()
    local model = self.model
    model.gameInfo = model.gameInfo or {gameStatus = consts.SVR_GAME_STATUS.TABLE_OPEN}

    model.playerList = model.playerList or {}
    local selfTemp = {
        uid = nk.userData.uid,
        seatId = 3 ,
        userStatus = consts.SVR_BET_STATE.USER_STATE_READY,
        userInfo = json.encode(nk.functions.getUserInfo()),
        anteMoney = 0,
        isOutCard = 0,
        cardsCount = 0,
    }
    model:initSeatPlayer(selfTemp)

    for i = 1,6 do 
        local selfTemp2 = {
            uid = 10052 + i,
            seatId = i == 3 and 0 or i,
            userStatus = consts.SVR_BET_STATE.USER_STATE_READY,
            userInfo = json.encode(nk.functions.getUserInfo()),
            anteMoney = 0,
            isOutCard = 0,
            cardsCount = 0,
        }
        model:initSeatPlayer(selfTemp2)
    end

    --这里开始设置测试需要的数据
    model.gameInfo.dealerSeatId = 3
    self.seatManager:initSeats({seatNum = 7}, model.playerList)

    for k,player in pairs(model.playerList) do
        player.cardsCount = 3
        player.cards = {
                [1] = 12,
                [2] = 16,
                [3] = 21,
            }
        player.isPlay = 1
        player.isOutCard = 1
    end

    self.m_controller:showMyCard()

    local pack = {}
    pack.cards = {
        [1] = 12,
        [2] = 16,
        [3] = 21,
        [4] = 34
    }
    pack.seatIds = {
        [1] = 3,
        [2] = 4
    }
    nk.GCD.PostDelay(self, function()
        self.m_controller:SVR_RECEIVE_FOURTH_CARD(pack)

    end,nil,0)

    --测试代码
    for i = 0,6 do 
        local seatView = self.ctx.seatManager:getSeatView(i)
        seatView:showCardTypeIf(1)
        seatView:showConfirmCardsIcon2(model:selfSeatId() == i)
    end

    model.gameInfo.gameStatus = consts.SVR_GAME_STATUS_QIUQIU.TABLE_GAME_OVER_SHARE_BONUS
    self.seatManager:showHandCard()
end

-- 设置换房还是站起模式
function RoomQiuQiuScene:setChangeRoomButtonMode(mode)
    if mode == 1 then
        -- self.changeRoomBtn_:setVisible(true)
        -- self.standupBtn_:setVisible(false)
    else
        -- self.changeRoomBtn_:setVisible(false)
        -- self.standupBtn_:setVisible(true)
    end
end

function RoomQiuQiuScene:setRoomStyle(tableStyle)
    tableStyle = math.min(tableStyle, 3) -- 当前最大是3
    if tableStyle ~= self.currentTableStyle then
        local bgResPathDict = {kImageMap.qiuqiu_table_green, kImageMap.qiuqiu_table_purple, kImageMap.qiuqiu_table_red}
        -- FwLog("tableStyle = " .. tableStyle)
        self.leftTableImage:setFile(bgResPathDict[tableStyle])
        self.rightTableImage:setFile(bgResPathDict[tableStyle])
        self.currentTableStyle = tableStyle
    end
end

-- 设置房间基本信息Label
function RoomQiuQiuScene:setRoomInfoText(roomInfo)
    -- local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[math.floor((roomInfo.roomType - 1) / 6) + 1]
    local tableStyle = roomInfo.tableStyle or 1
    self:setRoomStyle(tableStyle)

    local str = ""
    if roomInfo.blind < 100000 then
        str = nk.updateFunctions.formatNumberWithSplit(roomInfo.blind)
    else
        str = nk.updateFunctions.formatBigNumber(roomInfo.blind)
    end
    local info = bm.LangUtil.getText("ROOM", "ROOM_INFO_QIUQIU", roomInfo.tid, str)
    self.roomInfo_:setText(info)
end

-- flag是否转到低场
function RoomQiuQiuScene:onChangeRoom(flag)
    if nk.loginRoomSuccess then
        if not self.changeCD then
            self.changeCD = true
            self:requestCtrlCmd("changeRoom", flag)
            nk.GCD.PostDelay(self, function()
                self.changeCD = false
            end, nil, 3000)
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "REQUIRE_LATER"))
        end
    end
end

-- 移除loading
function RoomQiuQiuScene:removeLoading()
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
end

-- 菜单背景触摸
function RoomQiuQiuScene:onMenuShadowTouch(finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self.nodes.menuNode:setVisible(false)
    end
end

------------------------- handle function ----------------------------

-- 荷官语言回复
function RoomQiuQiuScene:onShowDealerSpeak()

end

------------------------------- UI function ---------------------------------

-- 快捷支付按钮点击
function RoomQiuQiuScene:onQuickPayButtonClick()
    Log.printInfo("RoomQiuQiuScene","onQuickPayButtonClick")
    nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_FAST_PAY
    nk.updateFunctions.makeQuickPay()
    nk.AnalyticsManager:report("New_Gaple_qiuqiu_room_quick_pay", "quickpPay")
end

-- 首充支付按钮点击
function RoomQiuQiuScene:onFirstPayButtonClick()
    Log.printInfo("RoomQiuQiuScene","onFirstPayButtonClick")
    nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_FISRT_PAY
    local FirstRechargePopup = require("game.firstRecharge.firstRechargePopup")
    nk.PopupManager:addPopup(FirstRechargePopup)
end

-- 菜单按钮点击
function RoomQiuQiuScene:onMenuBtnClick()
    Log.printInfo("RoomQiuQiuScene","onMenuBtnClick")
    self.nodes.menuNode:setVisible(true)
end

-- 返回大厅按钮点击
function RoomQiuQiuScene:onLobbyBtnClick()
    Log.printInfo("RoomQiuQiuScene","onLobbyBtnClick")
    self.nodes.menuNode:setVisible(false)
    self:requestCtrlCmd("onLobbyBtnClick")
end

-- 更换房间按钮点击
function RoomQiuQiuScene:onChangeRoomBtnClick()
    Log.printInfo("RoomQiuQiuScene","onChangeRoomBtnClick")
    nk.AnalyticsManager:report("New_Gaple_room_change", "room")
    self.nodes.menuNode:setVisible(false)
    self:onChangeRoom()
end

-- 站起按钮点击
function RoomQiuQiuScene:onStandUpBtnClick()
    nk.AnalyticsManager:report("New_Gaple_room_standUp", "room")
    Log.printInfo("RoomQiuQiuScene","onStandUpBtnClick")
    self.nodes.menuNode:setVisible(false)
    self:requestCtrlCmd("standUp")
end

-- 设置按钮点击
function RoomQiuQiuScene:onSettingBtnClick()
    Log.printInfo("RoomQiuQiuScene","onSettingBtnClick")
    self.nodes.menuNode:setVisible(false)
    local SettingPopup = require("game.setting.settingPopup")
    nk.PopupManager:addPopup(SettingPopup,"RoomQiuQiu")  
end

-- 菜单Node背景阴影
function RoomQiuQiuScene:onMenuShadowTouch(finger_action, x, y, drawing_id_first, drawing_id_current)
    Log.printInfo("RoomQiuQiuScene", "onMenuShadowTouch");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self.nodes.menuNode:setVisible(false)
    end
end

-- 邀请按钮点击
function RoomQiuQiuScene:onInviteBtnClick()
    Log.printInfo("RoomQiuQiuScene","onInviteBtnClick")
    nk.AnalyticsManager:report("New_Gaple_room_invite", "room")
    
    local InviteScene = require("game.invite.inviteScene")
    nk.PopupManager:addPopup(InviteScene,"RoomQiuQiu")
end

-- 商城按钮点击
function RoomQiuQiuScene:onMallBtnClick()
    Log.printInfo("RoomQiuQiuScene","onMallBtnClick")
    nk.AnalyticsManager:report("New_Gaple_room_store", "room")
    nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_SHOP_PAY
    local StorePopup = require("game.store.popup.storePopup")
    local level = self.m_controller.ctx.model:roomType()
    nk.PopupManager:addPopup(StorePopup,"RoomQiuQiu",true,level)
end

-- 牌型帮助按钮点击
function RoomQiuQiuScene:onCardTypeButtonClick()
    Log.printInfo("RoomQiuQiuScene","onCardTypeButtonClick")
    nk.AnalyticsManager:report("New_Gaple_room_card", "room")

    local CardTypePopup = import("game.roomQiuQiu.layers.cardTypePopup")
    nk.PopupManager:addPopup(CardTypePopup, "RoomQiuQiu")
end

-- 聊天按钮点击
function RoomQiuQiuScene:onChatButtonClick()
    Log.printInfo("RoomQiuQiuScene","onChatButtonClick")
    
end

-- 打赏按钮点击
function RoomQiuQiuScene:onDealerChipButtonClick()
    Log.printInfo("RoomQiuQiuScene","onDealerChipButtonClick")
    if self.m_controller.ctx.model:isSelfInSeat() then
        local roomData = nk.functions.getRoomQiuQiuDataByLevel(self.m_controller.ctx.model.roomInfo.roomType)
        if not roomData or not roomData.fee then
            return
        end
        
        -- 打赏
        nk.SocketController:sendChipToGirl(roomData.fee)

        -- 缓存下次不显示“打赏”提示
        nk.DictModule:setBoolean("gameData", nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP .. nk.userData.uid, true)
        if  self.dealerChipLabel then
            self.dealerChipLabel:setVisible(false)
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_IN_SEAT"))
    end
end

-------------------------------- listen function -----------------------------


-------------------------------- table config ---------------------------------

-- Provide cmd handle to call
RoomQiuQiuScene.s_cmdHandleEx = 
{
    ["updateChangeRoomButtonMode"] = RoomQiuQiuScene.setChangeRoomButtonMode,
    ["showDealerSpeak"] = RoomQiuQiuScene.onShowDealerSpeak,
    ["menuBtnClick"] = RoomQiuQiuScene.onMenuBtnClick,
    ["openLimitTimeGiftbag"] = RoomQiuQiuScene.onLimitTimeOpen,
    ["closeLimitTimeGiftbag"] = RoomQiuQiuScene.onLimitTimeClose,
};

return RoomQiuQiuScene
