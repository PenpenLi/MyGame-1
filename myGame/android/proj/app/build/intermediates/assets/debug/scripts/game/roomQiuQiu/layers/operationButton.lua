--
-- Author: tony
-- Date: 2014-07-17 15:26:44
--

local OperationButton = class(Node)

OperationButton.BUTTON_WIDTH = 202
OperationButton.BUTTON_HEIGHT = 70

function OperationButton:ctor()
    local btnW = OperationButton.BUTTON_WIDTH
    local btnH = OperationButton.BUTTON_HEIGHT

    self:setSize(btnW, btnH)
    
    self.isEnabled_ = true
    self.isCheckMode_ = false
    self.isChecked_ = false
    self.isPressed_ = false

    self.backgrounds_ = {}
    self.backgrounds_.oprUp = new(Image, kImageMap.qiuqiu_btn_purple)
    self.backgrounds_.oprUp:addTo(self)
    self.backgrounds_.oprDown = new(Image, kImageMap.qiuqiu_btn_purple)
    self.backgrounds_.oprDown:addTo(self)
    self.backgrounds_.checkUp = new(Image, kImageMap.qiuqiu_btn_blue)
    self.backgrounds_.checkUp:addTo(self)
    self.backgrounds_.checkDown = new(Image, kImageMap.qiuqiu_btn_blue)
    self.backgrounds_.checkDown:addTo(self)
    self.backgrounds_.checkSelected = new(Image, kImageMap.qiuqiu_btn_blue)
    self.backgrounds_.checkSelected:addTo(self)

    self.iconCheckBg_ = new(Image, kImageMap.qiuqiu_opr_check_bg)
    self.iconCheckBg_:setAlign(kAlignLeft)
    self.iconCheckBg_:setPos(15)
    self.iconCheckBg_:addTo(self) 
    self.iconCheckIcon_ = new(Image, kImageMap.qiuqiu_opr_check_icon)
    self.iconCheckIcon_:setAlign(kAlignLeft)
    self.iconCheckIcon_:setPos(15)
    self.iconCheckIcon_:addTo(self)

    self.label_ = new(Text, "", 130, 140, kAlignCenter, "", 22, 207, 234, 208)
    self.label_:setAlign(kAlignLeft)
    self.label_:setPos(65)
    self.label_:addTo(self)
    self:updateView_()

    self:setEventTouch(self, self.onTouch_)
end

function OperationButton:setEnabled(isEnabled)
    self.isEnabled_ = isEnabled
    self:updateView_()
    return self
end

function OperationButton:setLabel(label_)
    self.label_:setText(label_)
    return self
end

function OperationButton:getLabel()
    return self.label_:getText()
end

function OperationButton:isChecked()
    return self.isChecked_
end

function OperationButton:setChecked(isChecked, triggerHandler)
    local oldChecked = self.isChecked_
    self.isChecked_ = isChecked
    if isChecked ~= oldChecked and self.checkHandler_ and triggerHandler then
        self.checkHandler_(self, isChecked)
    end
    self:updateView_()
    return self
end

function OperationButton:setCheckMode(isCheckMode)
    self.isCheckMode_ = isCheckMode
    self:updateView_()
    return self
end

function OperationButton:onTouch(touchHandler)
    self.touchHandler_ = touchHandler
    return self
end

function OperationButton:onCheck(checkHandler)
    self.checkHandler_ = checkHandler
    return self
end

function OperationButton:onTouch_(finger_action, x, y, drawing_id_first, drawing_id_current)
    if self.isEnabled_ then
        if finger_action == kFingerDown then
            self.isPressed_ = true
        elseif finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self.isPressed_ = false
            if self.isCheckMode_ then
                self.isChecked_ = not self.isChecked_
                if self.checkHandler_ then
                    self.checkHandler_(self, self.isChecked_)
                end
            end
        elseif finger_action == kFingerUp then
            self.isPressed_ = false
        end

        self:updateView_()

        if self.touchHandler_ then
            self.touchHandler_(finger_action, x, y, drawing_id_first, drawing_id_current)
        end
    end
end

function OperationButton:updateView_()
    if self.isCheckMode_ then
        self.iconCheckBg_:setVisible(true)
        if self.isChecked_ then
            self.iconCheckIcon_:setVisible(true)
        else
            self.iconCheckIcon_:setVisible(false)
        end
        self.label_:setAlign(kAlignLeft)
        self.label_:setPos(65)
    else
        self.iconCheckBg_:setVisible(false)
        self.iconCheckIcon_:setVisible(false)
        self.label_:setAlign(kAlignCenter)
        self.label_:setPos(0)
    end

    if not self.isEnabled_ then
        self:selectBackground("oprDown")
        self.label_:setColor(131,136,145) --灰
    elseif self.isCheckMode_ then
        if self.isPressed_ then
            self:selectBackground("checkDown")
            self.label_:setColor(95,142,96) --绿
        elseif self.isChecked_ then
            self:selectBackground("checkSelected")
            self.label_:setColor(207,234,208) --淡绿
        else
            self:selectBackground("checkUp")
            self.label_:setColor(207,234,208)
        end
    else
        if self.isPressed_ then
            self:selectBackground("oprDown")
            self.backgrounds_.oprDown:setColor(128,128,128)
            self.label_:setColor(95,142,96)
        else
            self:selectBackground("oprUp")
            self.label_:setColor(95,142,96)
        end
        self.label_:setColor(255,255,255)
    end
end

function OperationButton:selectBackground(name)
    for k, v in pairs(self.backgrounds_) do
        if k == name then
            v:setColor(255,255,255)
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end
end

return OperationButton