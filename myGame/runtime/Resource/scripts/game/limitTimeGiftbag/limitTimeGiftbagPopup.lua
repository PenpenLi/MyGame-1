-- AboutPopup.lua
-- Date : 2016-08-25
-- Description: a scene in login moudle
local PopupModel = require('game.popup.popupModel')
local LimitTimeGiftbagView = require(VIEW_PATH .. "limitTimeGiftbag/limitTimeGiftbag")
local LimitTimeGiftbagVar = VIEW_PATH .. "limitTimeGiftbag/limitTimeGiftbag_layout_var"
local LimitTimeController = require("game.limitTimeGiftbag.limitTimeController")
local LimitTimeItem = require("game.limitTimeGiftbag.limitTimeItem")
local LimitTimeGiftbagPopup= class(PopupModel)

function LimitTimeGiftbagPopup.show(data)
	PopupModel.show(LimitTimeGiftbagPopup, LimitTimeGiftbagView, LimitTimeGiftbagVar, {name="LimitTimeGiftbagPopup"}, data)
end

function LimitTimeGiftbagPopup.hide()
    PopupModel.hide(LimitTimeGiftbagPopup)
end

function LimitTimeGiftbagPopup:ctor()
    nk.AnalyticsManager:report("New_Gaple_limitTimeGiftbag", "limitTimeGiftbag")
    self:addShadowLayer()
    self.controller = new(LimitTimeController,self)
    self:initVar()
    self:initPanel()
end 

function LimitTimeGiftbagPopup:dtor()
    Log.printInfo("LimitTimeGiftbagPopup:dtor")
    nk.limitTimer:removeTimeText(self.limitTimeText)
    delete(self.controller)
    self.controller = nil
end 

function LimitTimeGiftbagPopup:initVar()
    self.isExpand = false
    self.curPayIndex = 1
end
function LimitTimeGiftbagPopup:initPanel()
    self.bg = self:getUI("Bg")
    self.contentView = self:getUI("ContentView")
    self.tip = new(RichText, bm.LangUtil.getText("LIMIT_TIME_GIFTBAG", "TIP", "--","--","--"), 500, 30, kAlignLeft, "", 20, 255, 255, 255,true)
    self.tip:setPos(100, -160)
    self.tip:addTo(self.contentView)

    self.text1 = self:getUI("Text1")
    self.text2 = self:getUI("Text2")
    self.text3 = self:getUI("Text3")
    self.payIcon = self:getUI("PayIcon")
    self.gift1 = self:getUI("Gift1")
    self.gift2 = self:getUI("Gift2")
    self.gift3 = self:getUI("Gift3")
    self.gift4 = self:getUI("Gift4")
    self.giftName1 = self:getUI("GiftName1")
    self.giftName2 = self:getUI("GiftName2")
    self.giftName3 = self:getUI("GiftName3")
    self.giftName4 = self:getUI("GiftName4")
    self.giftList = {self.gift1,self.gift2,self.gift3,self.gift4}
    self.giftNameList = {self.giftName1,self.giftName2,self.giftName3,self.giftName4}
    self.buyText = self:getUI("BuyText")
    self.limitTimeText = self:getUI("Time")
    self.payMore = self:getUI("PayMore")
    self.payListView = self:getUI("PayListView")
    self.buyText:setText(bm.LangUtil.getText("COMMON", "BUY"))
    self.text1:setText(bm.LangUtil.getText("LIMIT_TIME_GIFTBAG", "TEXT1"))
    self.text2:setText(bm.LangUtil.getText("LIMIT_TIME_GIFTBAG", "TEXT2"))
    self.text3:setText(bm.LangUtil.getText("LIMIT_TIME_GIFTBAG", "TEXT3"))
    self.textDiscount = self:getUI("Text_discount")
    self.textDiscount:addPropRotateSolid(2,330,kCenterDrawing)

    if nk.limitTimer:getTime()>0 then
        nk.limitTimer:addTimeText(self.limitTimeText)
    end
    self:addCloseBtn(self.bg,18,15)
    self.contentView:setVisible(false) 
end

function LimitTimeGiftbagPopup:initLimitTimeGiftbag(data)
    self:setLoading(false)
    self.contentView:setVisible(true)
    self.payDataList = data.pay.pmode 
    self.limid = data.pay.limid
    local rewards = data.reward
    if rewards then
        for i,v in ipairs(rewards) do
            if i<5 then
                UrlImage.spriteSetUrl(self.giftList[i], v.icon,true)
                self.giftNameList[i]:setText(v.name)
            end
        end
    end
    self:initPayList()
    self.textDiscount:setText(bm.LangUtil.getText("LIMIT_TIME_GIFTBAG", "PERCENT", data.percent or 0))
end

function LimitTimeGiftbagPopup:initPayList()
    local lastPayType = nk.updateFunctions.getUserLastPayData().pmode
    for i,v in ipairs(self.payDataList) do
        if tonumber(lastPayType) ==tonumber(v.pmode) then
            self.curPayIndex = i
            break
        end
    end
    local adapter = new(CacheAdapter, LimitTimeItem,self.payDataList)
    self.payListView:setAdapter(adapter)
    self.payListView:setOnItemClick(self, self.onListItemClick)
    self:onListItemClick(adapter,nil,self.curPayIndex,nil,nil)
    if self.controller then
        local configs = {}
        for k,v in pairs(self.payDataList) do
            local config = {}
            config.id = tonumber(v.pmode)
            table.insert(configs,config)
        end
        self.controller:initPayConfig(configs)
    end
end

function LimitTimeGiftbagPopup:onShow()
    self:loadLimitTimeGiftbag()
end

function LimitTimeGiftbagPopup:onListItemClick(adapter,view,index,viewX,viewY)
    Log.printInfo("onListItemClick", index, viewX, viewY)
    self.payMore:setVisible(false)
    self.isExpand = false
    self.curPayIndex = index
    for i = 1,adapter:getCount() do
        local item = adapter:getView(i)
        item:updataBg(index)
    end
    local payData = self.payDataList[index]
    self.payIcon:setFile("res/payType/first_recharge_"..payData.pmode.."_icon.png")
    self.tip:setText(bm.LangUtil.getText("LIMIT_TIME_GIFTBAG", "TIP",payData.amount,payData.unit,nk.updateFunctions.formatBigNumber(payData.name)), 500, 30, kAlignLeft, "", 20, 255, 255, 255)
end

function LimitTimeGiftbagPopup:onPayChangeClick()
    Log.printInfo("LimitTimeGiftbagPopup:onPayChangeClick")
    if not self.isExpand then
        self.payMore:setVisible(true)
    else
        self.payMore:setVisible(false)
    end
    self.isExpand = not self.isExpand

end

function LimitTimeGiftbagPopup:onBuy()
    if nk.limitTimer.duringDelay then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LIMIT_TIME_GIFTBAG", "END"))   
    else
        if self.controller then
            local payData = self.payDataList[self.curPayIndex]
            if payData then
                payData.limid  = self.limid 
                payData.pid = payData.id
                payData.ptype = 1
                self.controller:buyLimitGiftbag(payData)
                nk.AnalyticsManager:report("New_Gaple_limitTimeGiftbag_buy", "limitTimeGiftbag")
            end
        end
    end 

end

function LimitTimeGiftbagPopup:onLimitTimeClose()
    self:onClose()
end

function LimitTimeGiftbagPopup:loadLimitTimeGiftbag()
    self:setLoading(true)
    if self.controller then
        self.controller:loadLimitTimeGiftbag()
    end
end

function LimitTimeGiftbagPopup:setLoading(isLoading)
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

return LimitTimeGiftbagPopup