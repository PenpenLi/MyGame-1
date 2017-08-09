
local view = require(VIEW_PATH .. "giftShop.shop_view")
local varConfigPath = VIEW_PATH .. "giftShop.shop_view_layout_var"
local Gzip = require('core/gzip')

local GiftItem = require("game.giftShop.layers.giftItem")

local ShopGiftLayer = class(GameBaseLayer, false)

function ShopGiftLayer:ctor(giftShopController,popdata)
	Log.printInfo("ShopGiftLayer.ctor");
	super(self, view, varConfigPath)

    self:setSize(self.m_root:getSize());

    self.m_popdata = popdata
    self.m_giftShopCtrl = giftShopController
    self.m_defaultIndex = 1

	self:initScene()
    self:setGiftBtnStatus()

    self.m_giftType_btn_1:setChecked(true)

    self:onGiftGroupChangeClick()
end

function ShopGiftLayer:initScene()
    self.m_giftRadioBtnGroup = self:getUI("giftRadioBtnGroup")
    self.m_giftRadioBtnGroup:setOnChange(self,self.onGiftGroupChangeClick);

    self.m_giftType_btn_1 = self:getUI("giftType_btn_1")
    self.m_btn_1_text = self:getUI("btn_1_name")
    self.m_btn_1_bg = self:getUI("btn_1_bg")
    self.m_giftType_btn_2 = self:getUI("giftType_btn_2")
    self.m_btn_2_text = self:getUI("btn_2_name")
    self.m_btn_2_bg = self:getUI("btn_2_bg")
    self.m_giftType_btn_3 = self:getUI("giftType_btn_3")
    self.m_btn_3_text = self:getUI("btn_3_name")
    self.m_btn_3_bg = self:getUI("btn_3_bg")
    self.m_giftType_btn_4 = self:getUI("giftType_btn_4")
    self.m_btn_4_text = self:getUI("btn_4_name")
    self.m_btn_4_bg = self:getUI("btn_4_bg")
    self.m_giftType_btn_5 = self:getUI("giftType_btn_5")
    self.m_btn_5_text = self:getUI("btn_5_name")
    self.m_btn_5_bg = self:getUI("btn_5_bg")

    self.m_btnText = {
        [1] = self.m_btn_1_text,
        [2] = self.m_btn_2_text,
        [3] = self.m_btn_3_text,
        [4] = self.m_btn_4_text,
        [5] = self.m_btn_5_text,
    }

    self.m_btnBg = {
        [1] = self.m_btn_1_bg,
        [2] = self.m_btn_2_bg,
        [3] = self.m_btn_3_bg,
        [4] = self.m_btn_4_bg,
        [5] = self.m_btn_5_bg,
    }

    self.m_giftScrollView = self:getUI("gift_scroll_view")

    self.m_sendAllBtn = self:getUI("sendAll_btn")
    self.sendAll_btn_text = self:getUI("sendAll_btn_text")
    self.sendAll_btn_text:setPickable(false)
    self.m_sendAllBtn_text = self:getUI("sendAll_btn_text")

    self.m_sendBtn = self:getUI("send_btn")
    self.m_sendBtn_text = self:getUI("send_btn_text")

    self.m_buyBtn = self:getUI("buy_btn")
    self.m_buyBtn_text = self:getUI("buy_btn_text")
end

function ShopGiftLayer:setGiftBtnStatus()
    self.m_sendAllBtn:setVisible(false)
    self.m_sendBtn:setVisible(false)
    self.m_buyBtn:setVisible(false)
    if self.m_popdata.isRoom then
        self.m_sendAllBtn:setVisible(true)
        self.m_sendBtn:setVisible(true)
        self.m_sendAllBtn_text:setText(bm.LangUtil.getText("GIFT","BUY_TO_TABLE_GIFT_BUTTON_LABEL",tostring(self.m_popdata.tableNum_)))
        
        if self.m_popdata.useId_ == nk.userData.uid then 
            self.m_sendBtn_text:setText(bm.LangUtil.getText("COMMON","BUY"))   
        else
            self.m_sendBtn_text:setText(bm.LangUtil.getText("GIFT","PRESENT_GIFT_BUTTON_LABEL"))
        end
    else
        self.m_buyBtn:setVisible(true)
        if self.m_popdata.useId_ == nk.userData.uid then 
            self.m_buyBtn_text:setText(bm.LangUtil.getText("COMMON","BUY"))   
        else
            self.m_buyBtn_text:setText(bm.LangUtil.getText("GIFT","PRESENT_GIFT_BUTTON_LABEL"))
        end
    end
end

function ShopGiftLayer:getShopGiftData()
    return self.m_giftShopCtrl.classifyGiftData
end

function ShopGiftLayer:refreshGiftPopup()
    if self.m_defaultIndex <= 0 then
        self.m_defaultIndex = 1
    end
    self.m_giftType_btn_1:setChecked(true)
    self:onGiftGroupChangeClick(self.m_defaultIndex)
end

function ShopGiftLayer:onGiftGroupChangeClick()
    if self.m_giftType_btn_1:isChecked() then
        self.m_defaultIndex = 1
    elseif self.m_giftType_btn_2:isChecked() then
        self.m_defaultIndex = 2
    elseif self.m_giftType_btn_3:isChecked() then
        self.m_defaultIndex = 3
    elseif self.m_giftType_btn_4:isChecked() then
        self.m_defaultIndex = 4
    elseif self.m_giftType_btn_5:isChecked() then
        self.m_defaultIndex = 5
    end

    for i,txt in ipairs(self.m_btnText) do
        if i == self.m_defaultIndex then
            txt:setColor(240,220,255)
        else
            txt:setColor(179,115,231)
        end
    end

    for i,btnBg in ipairs(self.m_btnBg) do
        btnBg:setVisible(i == self.m_defaultIndex)
    end

    self:creatGiftScrollView(self.m_defaultIndex)
end

function ShopGiftLayer:creatGiftScrollView(level)
    self.m_selfShopGiftData = self:getShopGiftData()
    self.m_giftScrollView:removeAllChildren(true)
    -- self.m_giftScrollView.m_nodeH = 0
    self:setLoading(true)
    if self.m_selfShopGiftData[level] and #self.m_selfShopGiftData[level] > 0 then

        self.m_data = self.m_selfShopGiftData[level]

        local x, y = 0, 0
        for i,giftData in ipairs(self.m_selfShopGiftData[level]) do
            local giftItem = new(GiftItem,giftData,self.m_popdata,i,1)
            local item_w, item_h = giftItem:getSize()

            giftItem:setDelegate(self, self.onGiftItemSelested)
            giftItem:setData()

            x = (i+3)%4*item_w
            y = math.floor((i-1)/4)*item_h

            giftItem:setPos(x,y)
            self.m_giftScrollView:addChild(giftItem)
        end
        self:setLoading(false)
    else
        self:setLoading(false)
    end
    self.m_giftScrollView:gotoTop()
end


function ShopGiftLayer:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
            self.juhua_ = nil
        end
    end
end

function ShopGiftLayer:onGiftItemSelested(pnid)
    self.m_selectGiftId_ = pnid
end

-- 给牌桌的多人购买
function ShopGiftLayer:onSendAllBtnClick()
-- 调试
    if not self.m_popdata.toUidArr_ then
        return
    end

    nk.AnalyticsManager:report("New_room_send_gift_all", "room")
    
    if self:isMoneyEnough(#self.m_popdata.toUidArr_,true,self.m_popdata.level_) then    --在房间买给桌子上所有人
        self:setLoading(true)
        if self.m_selectGiftId_ == nil then
            self:setLoading(false)
            return 
        end
            
        self.m_sendAllBtn:setEnable(false)

        local params = {}
        params.pnid = self.m_selectGiftId_
        params.fid = self.m_popdata.useIdArray_
        nk.HttpController:execute("buyGift", {game_param = params}, nil, handler(self, function (obj, errorCode, data)
            if not nk.updateFunctions.checkIsNull(obj) and self.m_sendAllBtn.m_res then
                self:setLoading(false)
                self.m_sendAllBtn:setEnable(true)
                if errorCode == 1 and data and data.code == 1 then
                    local money = checkint(data.data.money)
                    local subMoney = checkint(data.data.subMoney)

                    if money and money>=0 then
                        nk.functions.setMoney(money)
                    end
                    
                    if self.m_popdata.isRoom then
                        nk.SocketController:sendRoomGift(self.m_selectGiftId_,self.m_popdata.toUidArr_)
                    end
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP"))
                    EventDispatcher.getInstance():dispatch(EventConstants.closeGiftPopup)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_TABLE_GIFT_FAIL_TOP_TIP"))
                end
            end
        end ))
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "NOT_ENOUGH_CHIPS"))
    end
end

-- 给牌桌的单个人购买
function ShopGiftLayer:requestPresentGiftData()
-- 调试
    self:setLoading(true)
    if self.m_selectGiftId_ == nil then
        self:setLoading(false)
        return 
    end

    nk.AnalyticsManager:report("New_room_send_gift_one", "room")

    self.m_sendBtn:setEnable(false)

    local params = {}
    params.pnid = self.m_selectGiftId_
    params.fid = self.m_popdata.useId_
    nk.HttpController:execute("buyGift", {game_param = params}, nil, handler(self, function (obj, errorCode, data)
        if not nk.updateFunctions.checkIsNull(obj) and self.m_sendBtn.m_res then
            self:setLoading(false)
            self.m_sendBtn:setEnable(true)
            if errorCode == 1 and data and data.code == 1 then
                    
                local money = checkint(data.data.money)
                local subMoney = checkint(data.data.subMoney)

                if money and money>=0 then
                    nk.functions.setMoney(money)
                end

                -- nk.userData["gift"] = self.m_selectGiftId_
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_SUCCESS_TOP_TIP"))

                if self.m_popdata.isRoom then
                    nk.SocketController:sendRoomGift(self.m_selectGiftId_,{self.m_popdata.useId_})
                end
                EventDispatcher.getInstance():dispatch(EventConstants.closeGiftPopup)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_FAIL_TOP_TIP"))
            end
        end
    end ))
end

-- 给自己购买
function ShopGiftLayer:buyGiftRequest()
-- 调试
    self:setLoading(true)
    if self.m_selectGiftId_ == nil then
        self:setLoading(false)
        return 
    end

    self.m_buyBtn:setEnable(false)

    local params = {}
    params.pnid = self.m_selectGiftId_
    params.fid = nk.userData.uid
    nk.HttpController:execute("buyGift", {game_param = params}, nil, handler(self, function (obj, errorCode, data)
        if not nk.updateFunctions.checkIsNull(obj) and self.m_buyBtn.m_res then
            self:setLoading(false)
            self.m_buyBtn:setEnable(true)
            if errorCode == 1 and data and data.code == 1 then
                    
                local money = checkint(data.data.money)
                local subMoney = checkint(data.data.subMoney)

                if money and money>=0 then
                    nk.functions.setMoney(money)
                end

                nk.userData["gift"] = self.m_selectGiftId_
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_SUCCESS_TOP_TIP"))

                if self.m_popdata.isRoom then
                    nk.SocketController:sendRoomGift(self.m_selectGiftId_,{nk.userData.uid})
                end
                EventDispatcher.getInstance():dispatch(EventConstants.closeGiftPopup)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_FAIL_TOP_TIP"))
            end
        end
    end ))
end

-- 
function ShopGiftLayer:buyGiftHanler()
    if self.m_popdata.isRoom then
        if self:isMoneyEnough(1,true,self.m_popdata.level_) then
            if self.m_popdata.useId_ == nk.userData.uid then
                self:buyGiftRequest()
            else
                self:requestPresentGiftData()
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "NOT_ENOUGH_CHIPS"))
        end
    elseif self.m_popdata.notRoom then
        if self:isMoneyEnough(1,false,self.m_popdata.level_) then
            self:requestPresentGiftData()
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "NOT_ENOUGH_CHIPS"))
        end
    else
        if self:isMoneyEnough(1,false) then
            self:buyGiftRequest()
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "NOT_ENOUGH_CHIPS"))
        end
    end
end

function ShopGiftLayer:isMoneyEnough(count,isRoom,roomLevel)
    local giftPrice = self:getGiftPrice()
    return nk.functions.checkMoneyisEnough(count,isRoom,roomLevel,giftPrice)
end

function ShopGiftLayer:getGiftPrice()
    if self.m_data and self.m_selectGiftId_ then
        for _, k in pairs(self.m_selfShopGiftData) do
            for _, v in pairs(k) do
                if tonumber(v.pnid) == tonumber(self.m_selectGiftId_) then
                    return v.money
                end
            end
        end
    end
    return 0
end

function ShopGiftLayer:dtor()
    self:setLoading(false)
end

ShopGiftLayer.s_eventHandle = 
{
    [EventConstants.refreshGiftPopup] = ShopGiftLayer.refreshGiftPopup,
};

return ShopGiftLayer

