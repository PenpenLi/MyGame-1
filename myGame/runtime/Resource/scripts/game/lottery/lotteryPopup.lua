 --
-- Author: melon
-- Date: 2016-11-30 15:01:04
--
local PopupModel = require('game.popup.popupModel')
local LotteryView = require(VIEW_PATH .. "lottery/lottery")
local LotteryVar = VIEW_PATH .. "lottery/lottery_layout_var"
local LotteryPopup= class(PopupModel)

function LotteryPopup.show(data)
    PopupModel.show(LotteryPopup, LotteryView, LotteryVar, {name="LotteryPopup"}, data)
end

function LotteryPopup.hide()
    PopupModel.hide(LotteryPopup)
end

function LotteryPopup:ctor()
    self:addShadowLayer()
    self:initVar()
    self:initPanel()
    EventDispatcher.getInstance():register(EventConstants.rewardClosed, self, self.canLottery)    
    EventDispatcher.getInstance():register(EventConstants.getLotteryConfig, self, self.initPrize)
    EventDispatcher.getInstance():register(EventConstants.updateLotteryTimes, self, self.updateLotteryTimes)
    nk.LotteryController:loadNewConfig(self)
    nk.AnalyticsManager:report("New_Gaple_lottery", "lottery")
end 

function LotteryPopup:dtor()
    self:removeLotteryEffect()
    self:cancelSchedule(self.schedule)
    if self.schedule1 then
        self.schedule1:cancel()
        self.schedule1 = nil
    end
    if self.schedule1 then
        self.schedule1:cancel()
        self.schedule1 = nil
    end
    EventDispatcher.getInstance():unregister(EventConstants.rewardClosed, self, self.canLottery)
    EventDispatcher.getInstance():unregister(EventConstants.getLotteryConfig, self, self.initPrize)
    EventDispatcher.getInstance():unregister(EventConstants.updateLotteryTimes, self, self.updateLotteryTimes)

end 

function LotteryPopup:canLottery()
    self.isCanLottery = true
    self:setIsCanClose(true)
end

function LotteryPopup:initVar()
    self.prizePos = {ccp(-2,-58),ccp(128,-58),ccp(257,-58),ccp(257,68),ccp(257,196),ccp(128,196),
                    ccp(-2,196),ccp(-131,196),ccp(-261,196),ccp(-261,68),ccp(-261,-58),ccp(-131,-58)}
    self.isCanLottery = true
    self.selectIndex = 1
end
function LotteryPopup:initPanel()
    self.bg = self:getUI("Bg")
    self.select = self:getUI("Select")
    self.num = self:getUI("Num")
    self.closeBtn = self:getUI("CloseButton")
    self.closeBtn:setClickSound(nk.SoundManager.CLOSE_BUTTON)
    self.select:setLevel(2)
    if nk.LotteryController.lotteryData then
        self:initPrize(nk.LotteryController.lotteryData)
    else
        self:setLoading(true)   
    end
end

function LotteryPopup:updateLotteryTimes()
    self.num:setText(bm.LangUtil.getText("LOTTERY", "NUM",nk.lotteryTimes or 0))
end

function LotteryPopup:updateGetLotteryTimes()
    if self.lotteryData then
        self.tip:setText(string.format(self.lotteryData.rule,nk.lotteryCounts))
    end
end

function LotteryPopup:onShow()
    
end

function LotteryPopup:initPrize(data)
    self:setLoading(false)   
    if not self.tip  then
        self.tip = new(RichText, string.format(data.rule,nk.lotteryCounts or 0), 550, 50, kAlignLeft, "", 18, 220, 190, 255,true)
        self.tip:setPos(50, -150)
        self.tip:addTo(self.bg)
    else
        self.tip:setText(string.format(data.rule,nk.lotteryCounts or 0))
    end
    self.lotteryData = data
    self.prizeList = data.prizeList
    for i,v in ipairs(data.prizeList) do
        local prize = SceneLoader.load(require(VIEW_PATH .. "lottery/lotteryItem"))
        prize:setPos(self.prizePos[i].x,self.prizePos[i].y)
        prize:setLevel(1)
        self.bg:addChild(prize)
        local prizeIcon = prize:getChildByName("PrizeIcon")
        local prizeName = prize:getChildByName("PrizeName")
        prizeName:setText(v.name)
        if string.find(v.image,"http") then
            UrlImage.spriteSetUrl(prizeIcon, v.image,true)
        elseif v.image~="" then
            prizeIcon:setFile(v.image)   
        end
    end
end


function LotteryPopup:OnLotteryClick()
    if self.isCanLottery and self.prizeList and nk.LotteryController.isConfigLoaded then
        nk.AnalyticsManager:report("New_Gaple_start_lottery", "lottery")
        self:setLoading(true)
        nk.LotteryController:runLottery(self)
    end
end

function LotteryPopup:onGetlotteryResult(code,id)
    self:setLoading(false)
    if code==1 then
        for i,v in ipairs(self.prizeList) do
            if tonumber(v.id)== tonumber(id) then
                self:startLottery(i)
                return
            end
        end
    elseif code==-2 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "TIP1"))
        return
    elseif code==-4 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "TIP2"))
        return
    end
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "TIP4"))
end

function LotteryPopup:startLottery(lotteryIndex)
    if not self.schedule then
        self.isCanLottery  = false
        self:setIsCanClose(false)
        self:removeLotteryEffect()
        local rotationSum = 5
        local index = 0
        local value = 14
        local difValue = 2
        local interval = 0.03
        local step = 0
        local stepSum = rotationSum*12+lotteryIndex-self.selectIndex
        self.schedule = Clock.instance():schedule(function(dt)
            index = index + 1
            if index>value then
                if step<=6 then
                    value = value - difValue
                end
                if stepSum-step<=8 then
                    value = value + difValue
                end
                index = 0
                step = step + 1
                self.selectIndex = self.selectIndex + 1
                if self.selectIndex>12 then
                    self.selectIndex = 1
                end
                nk.SoundManager:playSound(nk.SoundManager.LOTTERY)
                self.select:setPos(self.prizePos[self.selectIndex].x,self.prizePos[self.selectIndex].y)
                if stepSum==step then
                    self:cancelSchedule()
                    self.schedule1 = Clock.instance():schedule_once(function ()
                        nk.SoundManager:playSound(nk.SoundManager.GET_LOTTERY)
                        self:addLotteryEffect(lotteryIndex)
                    end,0.2) 
                end
            end
        end, interval)
    end
end

--增加抽中的效果
function LotteryPopup:addLotteryEffect(lotteryIndex)
    self.ef1 = new(Image,"res/lottery/lottery_select_light.png")
    self.ef1:setAlign(kAlignCenter)
    self.ef1:setPos(self.prizePos[self.selectIndex].x,self.prizePos[self.selectIndex].y)
    self.ef1:setLevel(3)
    self.bg:addChild(self.ef1)
    self.ef1:addPropRotate(1, kAnimRepeat, 3000, -1, 0, 360, kCenterDrawing)
    self.ef2 = new(Image,"res/lottery/lottery_select_star.png")
    self.ef2:setAlign(kAlignCenter)
    self.ef2:setLevel(3)
    self.ef2:setPos(self.prizePos[self.selectIndex].x,self.prizePos[self.selectIndex].y)
    self.bg:addChild(self.ef2)
    self.ef2:addPropTransparency(1, kAnimLoop, 500, -1, 0, 1)
    self.schedule2 = Clock.instance():schedule_once(function ()
        self:removeLotteryEffect()
        nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"lotteryPopup",{self.prizeList[lotteryIndex]}) 
    end,1) 
end

--移除抽中的效果
function LotteryPopup:removeLotteryEffect()
    if self.ef1 then
        self.ef1:removeFromParent(true)
        self.ef1:doRemoveProp(1)
        self.ef1 = nil
    end
    if self.ef2 then
        self.ef2:removeFromParent(true)
        self.ef2:doRemoveProp(1)
        self.ef2 = nil
    end
end

function LotteryPopup:cancelSchedule()
    if self.schedule then
        self.schedule:cancel()
        self.schedule = nil
    end
end

function LotteryPopup:OnCloseClick()
    if self.isCanLottery then
        self:onClose()
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "TIP3"))
    end
end

function LotteryPopup:loadLotteryConfig()
  
end

function LotteryPopup:requestLottery()
  
end

function LotteryPopup:setLoading(isLoading)
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

return LotteryPopup