
local view = require(VIEW_PATH .. "giftShop.my_view")
local varConfigPath = VIEW_PATH .. "giftShop.my_view_layout_var"
local Gzip = require('core/gzip')

local GiftItem = require("game.giftShop.layers.giftItem")

local MyGiftLayer = class(GameBaseLayer, false)

function MyGiftLayer:ctor(giftShopController,popdata)
	Log.printInfo("MyGiftLayer.ctor");
	super(self, view, varConfigPath)

    self:setSize(self.m_root:getSize());

    self.m_popdata = popdata
    self.m_giftShopCtrl = giftShopController

    self.m_defaultIndex = 0

	self:initScene()

    self:onAllBtnClick()
end

function MyGiftLayer:initScene()
    self.m_selfBuyBtn_bg = self:getUI("self_buy_bg")
    self.m_selfBuy_text = self:getUI("self_buy_text")

    self.m_friendSendBtn_bg = self:getUI("friend_send_bg")
    self.m_friendSend_text = self:getUI("friend_send_text")

    self.m_systemSendBtn_bg = self:getUI("system_send_bg")
    self.m_systemSend_text = self:getUI("system_send_text")

    self.m_noGiftTips = self:getUI("noGift_tips")
    self.m_noGiftTips:setVisible(false)

    self.m_all_btn_bg = self:getUI("all_btn_bg")
    self.m_all_btn_text = self:getUI("all_btn_text")

    self.m_btnText = {
        [1] = self.m_selfBuy_text,
        [2] = self.m_friendSend_text,
        [3] = self.m_systemSend_text,
        [4] = self.m_all_btn_text  -- all 是后加的，虽然显示为第一项，放到这里数组4
    }

    self.m_giftScrollView = self:getUI("gift_scroll_view")
end

function MyGiftLayer:getShopGiftData()
    return self.m_giftShopCtrl.classifyMyGiftData
end

function MyGiftLayer:onSelfBuyBtnClick()
    if self.m_defaultIndex ~= 1 then
        self.m_defaultIndex = 1
        self:onGiftGroupChangeClick()
    end
end

function MyGiftLayer:onFriendsSendBtnClick()
    if self.m_defaultIndex ~= 2 then
        self.m_defaultIndex = 2
        self:onGiftGroupChangeClick()
    end
end

function MyGiftLayer:onSystemSendBtnClick()
    if self.m_defaultIndex ~= 3 then
        self.m_defaultIndex = 3
        self:onGiftGroupChangeClick()
    end
end

function MyGiftLayer:onAllBtnClick()
    if self.m_defaultIndex ~= 4 then
        self.m_defaultIndex = 4
        self:onGiftGroupChangeClick()
    end
end

function MyGiftLayer:onGiftGroupChangeClick()
    self.m_selfBuyBtn_bg:setVisible(false)
    self.m_friendSendBtn_bg:setVisible(false)
    self.m_systemSendBtn_bg:setVisible(false)
    self.m_all_btn_bg:setVisible(false)

    if self.m_defaultIndex == 1 then
        self.m_selfBuyBtn_bg:setVisible(true)
    elseif self.m_defaultIndex == 2 then
        self.m_friendSendBtn_bg:setVisible(true)
    elseif self.m_defaultIndex == 3 then
        self.m_systemSendBtn_bg:setVisible(true)
    elseif self.m_defaultIndex == 4 then
        self.m_all_btn_bg:setVisible(true)
    end

    for i,txt in ipairs(self.m_btnText) do
        if i == self.m_defaultIndex then
            txt:setColor(240,220,255)
        else
            txt:setColor(179,115,231)
        end
    end

    self:creatGiftScrollView(self.m_defaultIndex)
end

function MyGiftLayer:refreshGiftPopup()
    if self.m_defaultIndex <= 0 then
        self.m_defaultIndex = 1
    end
    self:creatGiftScrollView(self.m_defaultIndex)
end

function MyGiftLayer:creatGiftScrollView(level)
    self.m_myShopGiftData = self:getShopGiftData()
    self.m_giftScrollView:removeAllChildren(true)
    --self.m_giftScrollView.m_nodeH = 0
    self:setLoading(true)
    if self.m_myShopGiftData[level] and #self.m_myShopGiftData[level] > 0 then
        local x, y = 0, 0
        for i,giftData in ipairs(self.m_myShopGiftData[level]) do
            local giftItem = new(GiftItem,giftData,self.m_popdata,i,2)
            local item_w, item_h = giftItem:getSize()

            giftItem:setDelegate(self, self.onGiftItemSelested)
            giftItem:setData()

            x = (i+3)%4*item_w
            y = math.floor((i-1)/4)*item_h

            giftItem:setPos(x,y)
            self.m_giftScrollView:addChild(giftItem)
        end
        self:setLoading(false)
        self.m_noGiftTips:setVisible(false)

        -- item每次初始化，会选中玩家当前的item，m_selectGiftId_ 记录已经点击的item，如果有，选中上次点击的item
        if self.m_selectGiftId_ and self.m_selectGiftId_ ~= 0 then
            EventDispatcher.getInstance():dispatch(EventConstants.giftSelected, {pnid = self.m_selectGiftId_, viewIndex = 2})
        end
    else
        self:setLoading(false)
        self.m_noGiftTips:setVisible(true)
    end
    self.m_giftScrollView:gotoTop()
end

function MyGiftLayer:setLoading(isLoading)
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

function MyGiftLayer:onGiftItemSelested(pnid)
    self.m_selectGiftId_ = pnid
end

function MyGiftLayer:dtor()
    self:setLoading(false)
    local mainViewIndex = self.m_giftShopCtrl:getMainViewIndex()
    if mainViewIndex and mainViewIndex == 2 then
        if self.m_selectGiftId_ == nil or (self.m_selectGiftId_ == nk.userData["gift"]) or ( self.m_selectGiftId_ == 0) then
            return 
        end

        local params = {}
        params.pnid = self.m_selectGiftId_
        nk.HttpController:execute("useGift", {game_param = params}, nil, handler(self, function (obj, errorCode, data)
            if errorCode == 1 and data and data.code == 1 then
                nk.userData["gift"] = self.m_selectGiftId_
                if self.m_popdata and self.m_popdata.isRoom then
                    nk.SocketController:sendRoomGift(self.m_selectGiftId_,{nk.userData.uid})
                end
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_SUCCESS_TOP_TIP"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
            end
        end ))
    end
end

MyGiftLayer.s_eventHandle = 
{
    [EventConstants.refreshGiftPopup] = MyGiftLayer.refreshGiftPopup,
};

return MyGiftLayer