local PopupModel = require('game.popup.popupModel')
local PropManager = require("game.store.prop.propManager")
local MyPropItemView = require("game.userInfo.myprop.myPropItemView")
local SendPropPopup = class(PopupModel)
PopupModel.RegisterClassFuncs(SendPropPopup, "SendPropPopup", nil, nil)

function SendPropPopup:ctor(_, _, infoOfPerson)
    self.infoOfPerson = infoOfPerson
	self:addShadowLayer(kImageMap.common_transparent_blank)
	local popupBg = new(Image, kImageMap.common_popup_bg_small1)
	popupBg:addTo(self)
	popupBg:setAlign(kAlignCenter)
	popupBg:setEventTouch(self, self.onPopupBgTouch)
	self.widthOfView, self.heightOfView = popupBg:getSize()
	local titleBg = new(Image, kImageMap.common_pop_bg_title)
	titleBg:addTo(popupBg)
	titleBg:setAlign(kAlignTop)
	titleBg:setPos(0, 13)
	self.m_root = popupBg
	local titleTxt = new(Text, bm.LangUtil.getText("USERINFO", "SEND_PROP_TITLE"))
	titleTxt:addTo(titleBg)
	titleTxt:setAlign(kAlignCenter)

	self:addCloseBtn(popupBg, 25, 30)

	local scrollContainer = new(ScrollView, 16, 100, self.widthOfView - 30, self.heightOfView - 130 - 100, false)
	scrollContainer:addTo(self.m_root)
	scrollContainer:setDirection(kVertical)
    self.scrollContainer = scrollContainer

    local image = new(Image, kImageMap.userInfo_sendprop_tips_bg)
    image:addTo(self.m_root)
    image:setPos(16, 100 + self.heightOfView - 130 - 100)
    image:setSize(self.widthOfView - 30, 30)

    local node = new(Node)
    -- local text = new(Text, bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_TIPS"), nil, nil, nil, nil, 16, 0xe6, 0xd7, 0xfb)
    local text = new(Text, bm.LangUtil.getText("USERINFO", "PROP_PLEASE_CHOOSE_SENDPROP_TIPS"), nil, nil, nil, nil, 16, 0xe6, 0xd7, 0xfb)
    text:addTo(node)
    local text2 = new(Text, "", nil, nil, nil, nil, 16, 0xff, 0xf6, 0x00)
    text2:addTo(node)
    local w, h = text:getSize()
    text2:setPos(w, 0)
    self.textFee = text2
    self.textTips = text
    node:addTo(image)
    node:setAlign(kAlignCenter)
    node:setSize(w + text2:getSize(), h)

    local btnSend = new(Button, kImageMap.common_btn_yellow)
	btnSend:addTo(self.m_root)
	btnSend:setAlign(kAlignBottom)
	btnSend:setPos(0, 30)
	local textBtn = new(Text, bm.LangUtil.getText("GIFT", "PRESENT_GIFT_BUTTON_LABEL"))
	textBtn:addTo(btnSend)
	textBtn:setAlign(kAlignCenter)
	btnSend:setOnClick(self, self.onSendBtnClick)
    btnSend:setEnable(false)
    self.btnSend = btnSend

	PropManager.getInstance():requestUserPropList(handler(self, self.initView))
    EventDispatcher.getInstance():register(EventConstants.PROP_INFO_CHANGED, self, self.onPropInfoChanged)
end

function SendPropPopup:dtor()
    if self.selectedFrame then
        delete(self.selectedFrame)
        self.selectedFrame = nil
    end
    EventDispatcher.getInstance():unregister(EventConstants.PROP_INFO_CHANGED, self, self.onPropInfoChanged)
end

function SendPropPopup:initView(status, data)
	if tolua.isnull(self) then return end
	if not status then return end
	local scrollContainer = self.scrollContainer
    scrollContainer:removeAllChildren(true)

    local listOfPropInfo = {}
    for i, v in ipairs(data) do
        local config = PropManager.getInstance():getPropConfigByPnid(1, v.pnid)
        if config and tonumber(config.sendStatus) == 1 then
    	   table.insert(listOfPropInfo, v)
        end
    	-- table.insert(listOfPropInfo, v)
    	-- table.insert(listOfPropInfo, v)
    	-- table.insert(listOfPropInfo, v)
    end
    local COL_NUM = 4
    local item_w, item_h = 100, 98
    local SPACE_H, SPACE_V = 20, 20
    for i, v in ipairs(listOfPropInfo) do
        -- getPropItem(self, itemClass, v):addTo(scrollContainer)
        local x = ((i + COL_NUM - 1) % COL_NUM ) * (item_w + SPACE_H)  + SPACE_H + 20
        local y = math.floor( ( i - 1 ) / COL_NUM ) * (item_h +  SPACE_V) + 10
        local item = new(MyPropItemView, v)
        item:addTo(scrollContainer)
        item:setPos(x, y)
        item:setTouchDelegate(self, self.onPropClick)
    end
    local rowCount = math.ceil(#listOfPropInfo / COL_NUM)
    scrollContainer.m_nodeH = (item_h + SPACE_V) * rowCount + SPACE_V
    scrollContainer:update()
end

function SendPropPopup:onSendBtnClick()
	if self.selectedItem then
        nk.AnalyticsManager:report("New_Gaple_click_sendprop_sendprop")
        local data, config = self.selectedItem.data, self.selectedItem.config
        local cost = tonumber(config.fee) or 0
        if cost >= checkint(nk.userData.money) then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_MONEY_NOT_ENOUGH"))
            return
        end
        local SendPropConfirmPopup = require("game.userInfo.myprop.sendPropConfirmPopup")
        nk.PopupManager:addPopup(SendPropConfirmPopup, "sendprop", self.infoOfPerson, function()
            if not tolua.isnull(self) then
                self.btnSend:setEnable(false)
            end
            PropManager.getInstance():sendProp(data.pnid, self.infoOfPerson.aUser.mid, function(status)
                if not tolua.isnull(self) and not status then
                    self.btnSend:setEnable(true)
                end
            end)
        end)
    end
end

function SendPropPopup:onPropClick(item)
    if not self.selectedFrame then
        local deco2 = new(Image, kImageMap.lottery_select)
        deco2:setAlign(kAlignCenter)
        deco2:setLevel(1)
        deco2:addPropScaleSolid(0, 0.78, 0.77, kCenterDrawing)
        self.selectedFrame = deco2
    end
    if self.selectedItem ~= item then
        self.selectedFrame:addTo(item)
        self.btnSend:setEnable(true)
        self.selectedItem = item
        local data, config = item.data, item.config
        if self.textTips and self.textFee and config then
            local cost = config.fee or 0
            self.textTips:setText(bm.LangUtil.getText("USERINFO", "PROP_SENDPROP_TIPS"), 0, 0)
            self.textFee:setText(nk.updateFunctions.formatBigNumber(cost) .. " " .. bm.LangUtil.getText("COMMON", "COINS"), 0, 0)
            local w, h = self.textTips:getSize()
            self.textFee:setPos(w, 0)
            self.textTips:getParent():setSize(w + self.textFee:getSize(), h)
        end
    else
        self.selectedFrame:removeFromParent(false)
        self.btnSend:setEnable(false)
        self.selectedItem = nil
        if self.textTips and self.textFee then
            self.textTips:setText(bm.LangUtil.getText("USERINFO", "PROP_PLEASE_CHOOSE_SENDPROP_TIPS"), 0, 0)
            self.textFee:setText("", 0, 0)
            self.textTips:getParent():setSize(self.textTips:getSize())
        end
    end
end

function SendPropPopup:onPropInfoChanged(data)
    -- body
    self:onPropClick(self.selectedItem)
    self:initView(true, data)
end

return SendPropPopup