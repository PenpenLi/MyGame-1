-- raiseSlider.lua
-- Last modification : 2016-07-15
-- Description: a slider layer in room qiuqiu moudle

local RaiseSlider = class(GameBaseLayer, false)
local itemView = require(VIEW_PATH .. "roomQiuQiu.roomRaiseSlider_layer")
local varConfigPath = VIEW_PATH .. "roomQiuQiu.roomRaiseSlider_layer_layout_var"

local THUMB_BOUND_TOP = 0
local THUMB_BOUND_BOTTOM = 0
local THUMB_BOUND_HEIGHT = 0
local THUMB_BOUND_WIGHT = 0

local BAR_HEIGHT = 0

function RaiseSlider:ctor(model)
    Log.printInfo("RaiseSlider.ctor");
    self.model = model
    super(self, itemView, varConfigPath)

    local w, h = self.m_root:getSize()
    self:setSize(w, h)

    --加注Slider滑块
    self.thumb_ = self:getUI("image_bar")
    self.thumb_:setEventTouch(self,self.onThumbTouch_)
    self.thumb_:setLevel(1)    
    local bw,bh = self.thumb_:getSize()
    BAR_HEIGHT = bh

    --加注Slider蓝色指示条
    self.trackBlue_ = self:getUI("fg")
    THUMB_BOUND_WIGHT,THUMB_BOUND_HEIGHT = self.trackBlue_:getSize()
    THUMB_BOUND_TOP = THUMB_BOUND_HEIGHT - BAR_HEIGHT + 4
    THUMB_BOUND_BOTTOM = 0
    THUMB_BOUND_HEIGHT = THUMB_BOUND_TOP - THUMB_BOUND_BOTTOM

    -- Log.dump(THUMB_BOUND_TOP,">>>>>>>>>>>>>>>>>>>>>>>>>>>>> THUMB_BOUND_TOP")
    -- Log.dump(THUMB_BOUND_BOTTOM,">>>>>>>>>>>>>>>>>>>>>>>>>>>>> THUMB_BOUND_BOTTOM")

    --遮罩
    self.trackBlue_ = Mask.setMask(self.trackBlue_, kImageMap.roomRs_color_track)

    -- 加注label,当前数值
    self.label_ = self:getUI("countTxt")
    self.label_:setText("")

    self.btnPot4 = self:getUI("btnPot4")
    self.btnPot4:setOnClick(self,self.btnHandler_1)
    self.btnPot4Txt = self:getUI("btnPot4Txt")
    self.btnPot4Txt:setText("4 pot")

    self.btnPot2 = self:getUI("btnPot2")
    self.btnPot2:setOnClick(self,self.btnHandler_2)
    self.btnPot2Txt = self:getUI("btnPot2Txt")
    self.btnPot2Txt:setText("2 pot")

    self.btnPot1 = self:getUI("btnPot1")
    self.btnPot1:setOnClick(self,self.btnHandler_3)
    self.btnPot1Txt = self:getUI("btnPot1Txt")
    self.btnPot1Txt:setText("1 pot")

    self.btnBet3 = self:getUI("btnBet3")
    self.btnBet3:setOnClick(self,self.btnHandler_4)
    self.btnBet3Txt = self:getUI("btnBet3Txt")
    self.btnBet3Txt:setText("3*bet")

    --all in 按钮
    self.btnAllin_ = self:getUI("allInBtn")
    self.btnAllin_:setVisible(false)
    self.btnAllin_:setOnClick(self, self.btnHandler_5)

    -- 初始化
    self:setValueRange(0, 0, 0, true)
    self:setSliderPercentValue(0)
end
function RaiseSlider:onBgTouch()
    
end

function RaiseSlider:btnHandler_1()
    self:onButtonClicked_(1)
end

function RaiseSlider:btnHandler_2()
    self:onButtonClicked_(2)
end

function RaiseSlider:btnHandler_3()
    self:onButtonClicked_(3)
end

function RaiseSlider:btnHandler_4()
    self:onButtonClicked_(4)
end

function RaiseSlider:btnHandler_5()
    self:onButtonClicked_(5)
end

function RaiseSlider:showPanel()
    self:setSliderPercentValue(0)
    self:updateBtnState()
    return self:setVisible(true)
end

function RaiseSlider:updateBtnState()
    local seatData = self.model:selfSeatData()
    if seatData then
        local anteMoney = seatData.anteMoney
        local totalAnte = self.model.gameInfo.totalAnte
        local max = self.valueMax_
        local min = self.valueMin_
        if totalAnte and totalAnte >0 and anteMoney >= 4*totalAnte and max>=4*totalAnte and min<=4*totalAnte then
            self.btnPot4:setEnable(true)   
        else
            self.btnPot4:setEnable(false)                
        end    
        if totalAnte and totalAnte >0 and anteMoney >= 2*totalAnte and max>=2*totalAnte and min<=2*totalAnte then
            self.btnPot2:setEnable(true)    
        else
            self.btnPot2:setEnable(false)        
        end  
        if totalAnte and totalAnte >0 and anteMoney >= totalAnte and max>=totalAnte and min<=totalAnte then
            self.btnPot1:setEnable(true)    
        else
            self.btnPot1:setEnable(false)        
        end                         
        if self.model.lastAnte and self.model.lastAnte ~= 0 and anteMoney >= 3*self.model.lastAnte 
            and max>=3*self.model.lastAnte and min<=3*self.model.lastAnte then
            self.btnBet3:setEnable(true)       
        else
            self.btnBet3:setEnable(false)       
        end
    end
end

function RaiseSlider:setButtonStatus(allPotEnabled, q3PotEnabled, halfPotEnabled, tripleEnabled, isMaxAllin)
    self.isMaxAllin_ = isMaxAllin
end

function RaiseSlider:hidePanel()
    self:setSliderPercentValue(0)
    return self:setVisible(false)
end

function RaiseSlider:onButtonClicked(callback)
    self.buttonClickedCallback_ = callback
    return self
end

function RaiseSlider:setValueRange(baseMin, valueMin, valueMax , isMaxAllin)
    valueMin = nil and 0 or valueMin
    valueMax = nil and 0 or valueMax
    printf("slider range %s~%s", valueMin, valueMax)
    self.valueMin_ = valueMin
    self.valueMax_ = valueMax
    self.valueRange_ = valueMax - valueMin
    print("---->valueMin="..valueMin.." valueMax="..valueMax)
    if self.valueRange_<=0 then
        self.stepRange_=1
    else
        self.stepRange_=baseMin/4*THUMB_BOUND_HEIGHT/self.valueRange_
    end
    
    self.isMaxAllin_ = isMaxAllin
    return self
end

function RaiseSlider:setValue(val)
    if self.valueRange_ and self.valueRange_ > 0 then
        self:setSliderPercentValue(val / self.valueRange_)
    else
        self:setSliderPercentValue(0)
    end
    return self
end

function RaiseSlider:getValue()
    return math.round(self:getSliderPercentValue() * self.valueRange_ + self.valueMin_)
end

function RaiseSlider:getLabelValue()
    local sliderValue=self:getSliderPercentValue()
    if sliderValue==1 or sliderValue==0 then         --取上下限时不取整
        return self:getValue() 
    elseif self.valueMin_ == self.valueMax_ then     --上下限相等时也不取整，不然取整会超出或者不足
        return self.valueMin_
    else                                             --在中间的值可以取整
        local labelValue=self.label_:getText()
        local needReturnNum=nk.updateFunctions.formatBigStrToNum(labelValue)
        return needReturnNum
    end 
    return self:getValue()  
end

function RaiseSlider:setSliderPercentValue(newVal)
    assert(newVal >= 0 and newVal <= 1, "slider value must be between 0 and 1")
    self:onSliderPercentValueChanged_(newVal, true)
    self.thumb_:setPos(nil, THUMB_BOUND_TOP - THUMB_BOUND_HEIGHT * newVal)

    local x,y = self.thumb_:getPos()
    -- Log.dump(y,">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> self.thumb_")
    return self
end

function RaiseSlider:getSliderPercentValue()
    local _, y = self.thumb_:getPos()
    return (THUMB_BOUND_TOP - y) / THUMB_BOUND_HEIGHT
end

function RaiseSlider:onSliderPercentValueChanged_(newVal, forceUpdate, needSound)
    if self.percentValue_ ~= newVal or forceUpdate then
        self.percentValue_ = newVal
        if newVal == 1 then
            nk.SoundManager:playSound(nk.SoundManager.GEAR_FULL)
            if self.isMaxAllin_ then
                if self.allinState_ ~= true then
                    -- self.trackYellow_:setVisible(true)
                    self.btnAllin_:setVisible(true)
                end
                self.allinState_ = true
            else
                self.btnAllin_:setVisible(false)
                -- self.trackYellow_:setVisible(false)
            end
        else
            if self.isMaxAllin_ then
                if self.allinState_ ~= false then
                    self.btnAllin_:setVisible(false)
                    -- self.trackYellow_:setVisible(false)
                end
                self.allinState_ = false
            else
                self.btnAllin_:setVisible(false)
                -- self.trackYellow_:setVisible(false)
            end
        end
        self.prevValue_ = self.curValue_
        self.curValue_ = self:getValue()
        local curTime = os.time()
        local prevTime = self.lastRaiseSliderGearTickPlayTime_ or 0
        if needSound and self.prevValue_ ~= self.curValue_  and curTime - prevTime > 0.05 then
            self.lastRaiseSliderGearTickPlayTime_ = curTime
            nk.SoundManager:playSound(nk.SoundManager.GEAR_TICK)
        end
        print("---->----format before self.curValue_="..self.curValue_)
        if self.curValue_ > 9999 then
            self.curValue_ = nk.updateFunctions.formatBigNumber(self:formatNumToIntMultipleOfK(self.curValue_))
        end
        self.label_:setText(self.curValue_)

        self.trackBlue_:setSize(THUMB_BOUND_WIGHT,THUMB_BOUND_HEIGHT * newVal + 10) --加10是因为会有缝隙
    end
end

function RaiseSlider:formatNumToIntMultipleOfK(moneyVal)
    local IntMoney = moneyVal - moneyVal%1000
    return IntMoney
end

function RaiseSlider:onThumbTouch_(finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        _, self.thumbBeginY_ = self.thumb_:getPos()
        -- x,y为全局坐标
        self.wholeBeginY_ = y
    elseif finger_action == kFingerMove then

        local movedY =  y - self.wholeBeginY_
        movedY = math.ceil(movedY/self.stepRange_)*self.stepRange_

        local toY = self.thumbBeginY_ + movedY
        if toY >= THUMB_BOUND_TOP then
            toY = THUMB_BOUND_TOP
        elseif toY <= THUMB_BOUND_BOTTOM then
            toY = THUMB_BOUND_BOTTOM
        end
        self.thumb_:setPos(nil, toY)
        -- local val = (toY - THUMB_BOUND_BOTTOM) / THUMB_BOUND_HEIGHT
        local val = (THUMB_BOUND_TOP -toY) / THUMB_BOUND_HEIGHT
        print_string(val)
        self:onSliderPercentValueChanged_(val, false, true)
    elseif finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self.thumbBeginY_ = nil
        self.wholeBeginY_ = nil
    end
end

function RaiseSlider:onButtonClicked_(tag)
    Log.printInfo(">>>>>>>>>>>>>>>>>>>>>>>>> RaiseSlider:onButtonClicked_",tag)
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    -- if self.buttonClickedCallback_ then
    --     self.buttonClickedCallback_(tag)
    -- end

    if self.buttonClickedCallback_ then
        -- and (
            -- tag == 1 and self.btnPot4:isEnabled() or
            -- tag == 2 and self.btnPot2:isEnabled() or
            -- tag == 3 and self.btnPot1:isEnabled() or
            -- tag == 4 and self.btnBet3:isEnabled() or
            -- tag == 5 and self.btnAllin_:isEnabled()) then
        self.buttonClickedCallback_(tag)
    end
end

return RaiseSlider