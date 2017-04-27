--
-- Author: tony
-- Date: 2014-08-24 17:58:50
--

local PopupModel = import('game.popup.popupModel')
local BuyInPopup = class(PopupModel)
local view = require(VIEW_PATH .. "roomQiuQiu.roomQiuQiu_buyin_layer")
local varConfigPath = VIEW_PATH .. "roomQiuQiu.roomQiuQiu_buyin_layer_layout_var"

-------------------------------- single function --------------------------

function BuyInPopup.show(data)  
    PopupModel.show(BuyInPopup, view, varConfigPath, {name="BuyInPopup"}, data, true) 
end

function BuyInPopup.hide()
    PopupModel.hide(BuyInPopup)
end

-------------------------------- base function --------------------------

function BuyInPopup:ctor(viewConfig, varConfigPath, param)
    self:addCloseBtn(self:getUI("bg"))
    self:addShadowLayer()
    self.param_ = param
    self.min_ = param.minBuyIn
    self.max_ = param.maxBuyIn
    self.defaultBuyIn = param.defaultBuyIn    --默认携带值,配置为self.max_ * 0.2
    self.range_ = self.max_ - self.min_
    self.step_ = math.ceil(self.range_ / 10)

    --middlePercent_就是默认携带百分比，设置为滑条的0.2，默认携带筹码数即滑条最大值max_*0.2，当身上的钱不足这个数，默认携带身上所有钱
   self.myMoneyPercent_ = ((nk.userData and nk.functions.getMoney() or 0) - self.min_) / self.range_
    self.middlePercent_ = ( self.defaultBuyIn - self.min_) / self.range_

    --标题
    local title = self:getUI("titleLabel") 
    title:setText(bm.LangUtil.getText("ROOM", "BUY_IN_TITLE"))

    self.m_richText = new(RichText, bm.LangUtil.getText("ROOM", "BUY_IN_BALANCE_TITLE", 0), 500, 30, kAlignLeft, "", 20, 211, 234, 255)
    self.m_richText:setPos(40, 104)
    self.m_richText:addTo(self:getUI("bg"))

    local minBuyinLabel = self:getUI("minBuyinLabel")
    minBuyinLabel:setText(bm.LangUtil.getText("ROOM", "BUY_IN_MIN"))

    local maxBuyinLabel = self:getUI("maxBuyinLabel")
    maxBuyinLabel:setText(bm.LangUtil.getText("ROOM", "BUY_IN_MAX"))

    local minBuyinMoney = self:getUI("minBuyinMoney")
    minBuyinMoney:setText(nk.updateFunctions.formatBigNumber(param.minBuyIn))

    local maxBuyinMoney = self:getUI("maxBuyinMoney")
    maxBuyinMoney:setText(nk.updateFunctions.formatBigNumber(param.maxBuyIn))

    self.curValueLabel_ = self:getUI("buyinMoneyLabel")

    self.subBtn_ = self:getUI("deleteButton")

    self.addBtn_ = self:getUI("addButton")

    self.trackBar_ = self:getUI("sliderProgress")

    self.thumbSlideLen_ = 450 - 100
    self.thumbLeft_ = -4
    self.thumbRight_ = 450 - 100
    self.thumb_ = self:getUI("thumbImage")

    self.stepRange_=self.min_*self.thumbSlideLen_/self.range_

    self.autoBuyInChkboxIcon_ = self:getUI("checkImage")

    local outoBuyinLabel = self:getUI("outoBuyinLabel")
    outoBuyinLabel:setText(bm.LangUtil.getText("ROOM", "BUY_IN_AUTO"))

    self.isAutoBuyin_ = param.isAutoBuyin
    self.autoBuyInChkboxIcon_:setVisible(self.isAutoBuyin_)

    local buyinLabel = self:getUI("buyinLabel")
    buyinLabel:setText(bm.LangUtil.getText("ROOM", "BUY_IN_BTN_LABEL"))

    self:onSliderPercentValueChanged_(math.min(self.middlePercent_, self.myMoneyPercent_), true, false)

    if not self.moneyChangeObserverId_ then
        self.moneyChangeObserverId_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, self.onMoneyChanged_))
    end
end

function BuyInPopup:dtor()
    if self.moneyChangeObserverId_ then
        nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyChangeObserverId_)
        self.moneyChangeObserverId_ = nil
    end
end

function BuyInPopup:onSliderPercentValueChanged_(newVal, forceUpdate, needSound)
    if self.posPercent_ then
        if self.posPercent_ <= self.myMoneyPercent_ then
            self.posPercent_ = self.myMoneyPercent_
        else
            self.posPercent_ = self.posPercent_ - math.max((self.posPercent_ - self.myMoneyPercent_) * 0.06, 2 / self.thumbSlideLen_)
            if self.posPercent_ <= self.myMoneyPercent_ then
                self.posPercent_ = self.myMoneyPercent_
            end
        end
    end

    if self.percentValue_ ~= newVal or forceUpdate then
        local moneyVal = math.round(self.min_ + self.range_ * newVal)
        if moneyVal > (nk.userData and nk.functions.getMoney() or 0) then
            self.curValueLabel_:setColor(255,131,11)
        else
            self.curValueLabel_:setColor(255,207,26)
        end
        self.thumb_:setPos(self.thumbLeft_ + self.thumbSlideLen_ * newVal)

        newVal = math.max(0, math.min(self.myMoneyPercent_, newVal, 1))

        self.prevValue_ = self.curValue_
        self.curValue_ = self:formatNumToIntMultipleOfK(math.round(self.min_ + self.range_ * newVal))
        self.curValueLabel_:setText(nk.updateFunctions.formatBigNumber(self.curValue_))
        if needSound and self.prevValue_ ~= self.curValue_  then
            nk.SoundManager:playSound(nk.SoundManager.GEAR_TICK)
        end
        self.percentValue_ = newVal
        self.trackBar_:setSize(newVal * self.thumbSlideLen_ + 100 * 0.5)
        self.subBtn_:setEnable(newVal > 0)
        self.addBtn_:setEnable(newVal < math.min(self.myMoneyPercent_, 1))
    end
end

function BuyInPopup:formatNumToIntMultipleOfK(moneyVal)
    local IntMoney = moneyVal - moneyVal%1000
    return IntMoney
end

function BuyInPopup:onMoneyChanged_(money)
    if self.m_richText then
        self.m_richText:removeFromParent(true)
    end
    self.m_richText = new(RichText, bm.LangUtil.getText("ROOM", "BUY_IN_BALANCE_TITLE", nk.updateFunctions.formatBigNumber(money or 0)), 500, 30, kAlignTopLeft, "", 20, 211, 234, 255)
    self.m_richText:setPos(40, 104)
    self.m_richText:addTo(self:getUI("bg"))
   self.myMoneyPercent_ = math.max(0, ((money or 0) - self.min_) / self.range_)
end

-------------------------------UI funcion--------------------------------------

function BuyInPopup:onDeleteButtonClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self.curValue_ = self.curValue_ - self.step_
    if self.curValue_ < self.min_ then
        self.curValue_ = self.min_
    elseif self.curValue_ > self.max_ then
        self.curValue_ = self.max_
    end
    self:onSliderPercentValueChanged_(math.min(self.myMoneyPercent_, (self.curValue_ - self.min_) / self.range_), false, false)
end

function BuyInPopup:onAddButtonClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self.curValue_ = self.curValue_ + self.step_
    if self.curValue_ < self.min_ then
        self.curValue_ = self.min_
    elseif self.curValue_ > self.max_ then
        self.curValue_ = self.max_
    end
    self:onSliderPercentValueChanged_(math.min(self.myMoneyPercent_, (self.curValue_ - self.min_) / self.range_), false, false)
end

function BuyInPopup:onThumbTouch_(finger_action, x, y, drawing_id_first, drawing_id_current) 
    Log.printInfo("finger_action" ..finger_action.. " x"..x.." y"..y.." drawing_id_first"..drawing_id_first.." drawing_id_current"..drawing_id_current)
    if finger_action == kFingerDown then
        self.isThumbTouching_ = true
        self.thumbTouchBeginX_ = x
        self.thumbBeginX_ = self.thumb_:getPos()
    elseif finger_action == kFingerMove then
        local movedX = x - self.thumbTouchBeginX_
        local toX = self.thumbBeginX_ + movedX
        if toX >= self.thumbRight_ then
            toX = self.thumbRight_
        elseif toX <= self.thumbLeft_ then
            toX = self.thumbLeft_
        end
        local mathMovedX= toX - self.thumbLeft_
        Log.printInfo("mathMovedX 1 " ..mathMovedX)
        mathMovedX=math.ceil(mathMovedX/self.stepRange_)*self.stepRange_
        Log.printInfo("mathMovedX 2 " ..mathMovedX)
        local val = mathMovedX / self.thumbSlideLen_
        val = val > 1 and 1 or val
        Log.printInfo("val " ..val)
        self:onSliderPercentValueChanged_(val, false, true)
    elseif finger_action == kFingerUp then
        self.isThumbTouching_ = false
        self.posPercent_ = (self.thumb_:getPos() - self.thumbLeft_) / self.thumbSlideLen_
        if self.posPercent_ > self.myMoneyPercent_ then
            self:onSliderPercentValueChanged_(math.min(self.myMoneyPercent_, self.posPercent_), true, false)
        end
    end
    return true
end

function BuyInPopup:onCheckButtonClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self.isAutoBuyin_ = not self.isAutoBuyin_
    nk.DictModule:setBoolean("gameData", nk.cookieKeys.AUTO_BUY_IN, self.isAutoBuyin_)
    nk.DictModule:saveDict("gameData")
    self.autoBuyInChkboxIcon_:setVisible(self.isAutoBuyin_)
end

function BuyInPopup:onBuyinButtonClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    BuyInPopup.hide()
    self.param_.callback(self.curValue_, self.isAutoBuyin_)
end

return BuyInPopup