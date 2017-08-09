-- LoginRewardPopup.lua
-- Last modification : 2016-07-08
-- Description: a popup to show reward when login succ
local PopupModel = import('game.popup.popupModel')

local LoginRewardPopup = class(PopupModel);
local LoginRewardPopupLayer = require(VIEW_PATH .. "popup.login_reward_pop_layer")
local varConfigPath = VIEW_PATH .. "popup.login_reward_pop_layer_layout_var"

local  PromotePopup = require("game.promote.promotePopup")

-------------------------------- single function --------------------------
function LoginRewardPopup.show(data)
    PopupModel.show(LoginRewardPopup, LoginRewardPopupLayer, varConfigPath, {name="LoginRewardPopup"}, data, true)
end

function LoginRewardPopup.update()
    if LoginRewardPopup.s_instance and LoginRewardPopup.s_instance.updateData then
	    LoginRewardPopup.s_instance:updateData();
    end
end

 function LoginRewardPopup.hide()
     PopupModel.hide(LoginRewardPopup)
 end

-------------------------------- base function --------------------------

function LoginRewardPopup:ctor(viewConfig, varConfigPath, data)
	Log.printInfo("LoginRewardPopup.ctor");
    self.m_data = data
    self:addShadowLayer()
	self:init(data)
end 

function LoginRewardPopup:dtor()
	Log.printInfo("LoginRewardPopup.dtor")
    nk.GCD.Cancel(self)
    self.loginDayProgBar_:stopAllActions()
end

-------------------------------- private function --------------------------

function LoginRewardPopup:init(data)
	Log.printInfo("LoginRewardPopup.init");

    self.m_popupBg = self:getUI("popup_bg")
    self:getUI("closeButton"):setClickSound(nk.SoundManager.CLOSE_BUTTON)
    self.btnText = self:getUI("shareLabel")
    if nk.userData.loginReward.ret == 0 then
        self.btnText:setText(bm.LangUtil.getText("DAILY_TASK", "GET_REWARD"))
    else
        self.btnText:setText(bm.LangUtil.getText("LOGINREWARD", "IMMEDIATELY_PLAY")) 
    end
    -- 连续登陆提示
	local datas = nk.LoginRewardController:getLoginRewardData() or {}
    self.loginRewardData = datas
    local lastDay = datas[#datas]
    local accumulation = nk.userData.loginReward.accumulation
    local todayStr = checkint(nk.userData.loginReward.day)  
    if todayStr>=6 then
        todayStr = 6
    end
    self.todayStr = todayStr
    self.accumulationDays = checkint(nk.userData.loginReward.accumulationDays)
    if self.accumulationDays>lastDay.day then
        self.accumulationDays = self.accumulationDays%lastDay.day
    end
    local tipString = bm.LangUtil.getText("LOGINREWARD", "CONTINUOUS_DAY", self.accumulationDays, lastDay.day, lastDay.name)
    local richLabel = new(RichText, tipString, 800, 30, kAlignLeft, "", 16, 189, 160, 227)
    richLabel:setAlign(kAlignTop)
    richLabel:setPos(nil, 120)
    self.m_popupBg:addChild(richLabel)

    -- 设置进度条
    self.loginDayProgBar_ = self:getUI("progressBarImage")
    local loginDayProgBarBg = self:getUI("progressBg")
    self.progressNodeW = loginDayProgBarBg:getSize()
    local value = self.accumulationDays/lastDay.day
    if value<=0 then
        self.loginDayProgBar_:setVisible(false)
    else
        self.loginDayProgBar_:setSize(self.progressNodeW*value)
    end
    self.itemSp = {}
    self.item = {}
    if datas then
        local num = #datas
        for i, v in ipairs(datas) do
            local x = -50+self.progressNodeW*v.day/lastDay.day
            self.item[i] = new(Node)
            self.item[i]:setAlign(kAlignLeft)
            self.item[i]:setPos(x, 0)
            self.item[i]:setSize(72, 125)
            loginDayProgBarBg:addChild(self.item[i])
            -- 奖品图片
            self.itemSp[i] = new(Image, "res/common/chest1.png")
            self.itemSp[i]:setAlign(kAlignCenter)
            self.item[i]:addChild(self.itemSp[i])
            if self.accumulationDays<v.day then
                self.itemSp[i]:setColor(128,128,128)
                self.itemSp[i]:addPropScaleSolid(1, 0.7, 0.7, kCenterDrawing)
            else 
                if accumulation[tostring(v.day)]==0 then
                    self.itemSp[i]:addPropScale(1,kAnimLoop,200,-1,0.8,0.7,0.8,0.7,kCenterDrawing)
                    local function callback(self,finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
                        self:onChestClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time,i)  
                    end
                    self.itemSp[i]:setEventTouch(self,callback) 
                else
                    local getRewardsIcon = new(Image, kImageMap.common_check_big)
                    getRewardsIcon:addTo(self.item[i])
                    getRewardsIcon:setAlign(kAlignCenter)
                    getRewardsIcon:setPos(30, 20)
                    self.itemSp[i]:setColor(128,128,128)
                    self.itemSp[i]:addPropScaleSolid(1, 0.7, 0.7, kCenterDrawing)
                end
            end
            -- 天数
            local dayText = new(Text, bm.LangUtil.getText("LOGINREWARD", "DAYS", v.day), 148, 40, kAlignCenter, nil, 16, 201, 149, 254)
            dayText:setAlign(kAlignTop)
            self.item[i]:addChild(dayText)
            -- 奖品名称
            local nameText = new(TextView, v.name, 90, 90, kAlignTop, nil, 12, 242, 232, 253)
            nameText:setAlign(kAlignTop)
            nameText:setScrollBarWidth(0)
            nameText:setPos(0, 92)
            self.item[i]:addChild(nameText)
        end
    end

    -- 六天连续登录奖励
    local itemsView = self:getUI("itemsView")
    self.rewardDay = {}
    local rewardDayTable
    local rewardDay_width = 110
    local rewardDay_heigh = 145
    local rewardYesterDay
    -- vip reward
    local vipLevel = tonumber(nk.userData.vip or 1)
    if vipLevel < 1 then vipLevel = 1 end

    local vipDay = new(Image, kImageMap.login_reward_item_bg,nil,nil,20,20,20,20)
    vipDay:setSize(rewardDay_width,rewardDay_heigh)
    vipDay:setPos(18,275)
    self.m_popupBg:addChild(vipDay)    

    local tipVip = new(Text,"VIP "..vipLevel,100,35,kAlignCenter,nil, 18, 201, 149, 254)
    tipVip:setAlign(kAlignTop)
    vipDay:addChild(tipVip)

    local itemSp = new(Image, kImageMap.common_coin_107)
    itemSp:setAlign(kAlignCenter)
    vipDay:addChild(itemSp)
    local itemW, itemH = itemSp:getSize()
    local value = 72/itemH
    itemSp:setSize(value*itemW, value*itemH)

           -- 奖励光
    local rewardLight = new(Image, kImageMap.login_reward_light_big)
    rewardLight:setAlign(kAlignCenter)
    rewardLight:setSize(rewardDay_width,rewardDay_heigh-10)
    rewardLight:addTo(itemSp)
    -- 奖励星星
    local start = new(Image, kImageMap.login_reward_start)
    start:setAlign(kAlignCenter)
    start:setSize(100,105)
    start:addTo(itemSp)

    local vipReward = nk.vipController:getLoginReward(vipLevel)
    self.vipReward_ = nk.updateFunctions.formatBigNumber(checkint(vipReward))

    local rewardName = new(Text,  self.vipReward_.." "..bm.LangUtil.getText("COMMON", "COINS"), 148, 40, kAlignCenter, nil, 20, 0xff, 0xc8, 0x4b)
    rewardName:setAlign(kAlignBottom)
    rewardName:setPos(nil,-5)
    vipDay:addChild(rewardName)

    if checkint(nk.userData.vip) > 0 then
        vipDay:setPos(16,285)
        local nowTime = os.date("%Y%m%d", os.time())
        local beVipTime = nk.DictModule:getString("gameData","BE_VIP_TIME" or "")

        self.vipLoginRewardGet = function()
              -- 已领取遮罩
            local gettedMask = new(Image, kImageMap.common_rounded_rect_10, nil, nil, 5, 5, 5, 5)
            gettedMask:setSize(rewardDay_width-4,rewardDay_heigh-4)
            gettedMask:setAlign(kAlignCenter)
            vipDay:addChild(gettedMask)
            -- 已领取图标
            local getted = new(Image, kImageMap.login_reward_text_gettd)
            getted:setAlign(kAlignCenter)
            vipDay:addChild(getted)
            local value = rewardDay_width/121
            getted:setSize(rewardDay_width, value*78)
            start:removeFromParent(true)
            rewardLight:removeFromParent(true)
        end
        if nk.userData.loginReward.ret == 1 then
            self.vipLoginRewardGet() 
        end    
    else  
        local  beVip = new(Button, kImageMap.common_btn_yellow_s)  
        beVip:setOnClick(self,function()
            nk.payScene = consts.PAY_SCENE.HALL_LOGIN_SHOP_PAY
            nk.PopupManager:addPopup(require("game.store.vip.vipPopup"),"hall",nil,nil,"vip")
            PopupModel.onClose(self)
        end)
        beVip:setPos(18,425)
        local width,height = beVip:getSize()
        beVip:setSize(0.8*width, 0.8*height)
        self.m_popupBg:addChild(beVip) 

        local text_bt = new(Text,bm.LangUtil.getText("STORE", "VIP_BE_VIP"),90,30,kAlignCenter,nil, 18, 255, 255, 255)
        text_bt:setAlign(kAlignCenter)
        beVip:addChild(text_bt)
    end

    -- reward detail
    for i=1, 6 do
        local x = 5 + (i - 1) * (rewardDay_width+2)
        local y = 0
        local mass
        
        -- bg
        self.rewardDay[i] = new(Image, kImageMap.login_reward_item_bg,nil,nil,20,20,20,20)
        self.rewardDay[i]:setAlign(kAlignLeft)
        self.rewardDay[i]:setSize(rewardDay_width,rewardDay_heigh)
        self.rewardDay[i]:setLevel(7-i)
        self.rewardDay[i]:setPos(x)
        self.rewardDay[i]:addTo(itemsView)

        local dayIndex = i
        if dayIndex >= 6 then
            dayIndex = "6+"
        end

        -- 天数label
        local rewardDayTable = new(Text, bm.LangUtil.getText("LOGINREWARD", "DAYS", (dayIndex)), 148, 40, kAlignCenter, nil, 18, 230, 215, 251)
        rewardDayTable:setAlign(kAlignTop)
        self.rewardDay[i]:addChild(rewardDayTable)
        if i == todayStr then 
            rewardDayTable:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_TODAY"))
        elseif i-1 == todayStr then  
            rewardDayTable:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_TOMORROW"))
        end
        -- chip mass
        local index = i
        if index == 6 then
            index = 7
        end
        mass = new(Image, kImageMap["common_coin_10" .. index])
        mass:addTo(self.rewardDay[i])
        local massW, massH = mass:getSize()
        mass:setSize(0.5*massW, 0.5*massH)
        mass:setAlign(kAlignCenter)

        -- 奖励label
        local rewardName = new(Text,nk.userData.loginReward.days[i].." "..bm.LangUtil.getText("COMMON", "COINS"), 148, 40, kAlignCenter, nil, 20, 0xff, 0xc8, 0x4b)
        rewardName:setAlign(kAlignBottom)
        rewardName:setPos(nil,-5)
        self.rewardDay[i]:addChild(rewardName)
        if nk.userData.loginReward.ret == 0 then
            if i < todayStr then 
                -- 已领取遮罩
                local gettedMask = new(Image, kImageMap.common_rounded_rect_10, nil, nil, 5, 5, 5, 5)
                gettedMask:setSize(rewardDay_width - 4, rewardDay_heigh - 4)
                gettedMask:setAlign(kAlignCenter)
                gettedMask:addTo(self.rewardDay[i])
                -- 已领取图标
                local getted = new(Image, kImageMap.login_reward_text_gettd)
                getted:setAlign(kAlignCenter)
                getted:addTo(self.rewardDay[i])
                local value = rewardDay_width/121
                getted:setSize(rewardDay_width, value*78)
            elseif i  == todayStr then
                   -- 奖励光
                self.rewardLight = new(Image, kImageMap.login_reward_light_big)
                self.rewardLight:setAlign(kAlignCenter)
                self.rewardLight:addTo(self.rewardDay[i])
                self.rewardLight:setSize(rewardDay_width, rewardDay_heigh - 10)
                -- 奖励星星
                self.start = new(Image, kImageMap.login_reward_start)
                self.start:addTo(self.rewardDay[i])
                self.start:setAlign(kAlignCenter)
                self.start:setSize(100,105)
                --Highlight
                self.highLight = new(Image, kImageMap.login_reward_item_s,nil,nil,20,20,20,20)
                self.highLight:addTo(self.rewardDay[i])
                self.highLight:setSize(rewardDay_width, rewardDay_heigh)
            end
        else
            if i <= todayStr then  
                -- 已领取遮罩
                local gettedMask = new(Image, kImageMap.common_rounded_rect_10, nil, nil, 5, 5, 5, 5)
                gettedMask:setSize(rewardDay_width - 4, rewardDay_heigh - 4)
                gettedMask:setAlign(kAlignCenter)
                gettedMask:addTo(self.rewardDay[i])
                -- 已领取图标
                local getted = new(Image, kImageMap.login_reward_text_gettd)
                getted:setAlign(kAlignCenter)
                getted:addTo(self.rewardDay[i] )
                local value = rewardDay_width/121
                getted:setSize(rewardDay_width, value*78)
            elseif i - 1 == todayStr then
                   -- 奖励光
                self.rewardLight = new(Image, kImageMap.login_reward_light_big)
                self.rewardLight:setAlign(kAlignCenter)
                self.rewardLight:addTo(self.rewardDay[i])
                self.rewardLight:setSize(rewardDay_width, rewardDay_heigh - 10)
                -- 奖励星星
                self.start = new(Image, kImageMap.login_reward_start)
                self.start:setAlign(kAlignCenter)
                self.start:addTo(self.rewardDay[i])
                self.start:setSize(100,105)
                --Highlight
                self.highLight = new(Image, kImageMap.login_reward_item_s,nil,nil,20,20,20,20)
                self.highLight:addTo(self.rewardDay[i])
                self.highLight:setSize(rewardDay_width, rewardDay_heigh)
            end
        end
    end

    -- 登陆奖励提示
    local tipLabel = self:getUI("tipLabel")
    tipLabel:setText(bm.LangUtil.getText("LOGINREWARD", "PROMPT", nk.userData.loginReward.days[6]))
end 

function LoginRewardPopup:onChestClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time,index)
    if kFingerDown== finger_action then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    elseif kFingerUp== finger_action then
        self:setLoading(true)
        local rewardData = self.loginRewardData[index]
        nk.HttpController:execute("Login.getAttachAward", {game_param = {mid = nk.userData.uid,day = rewardData.day}}, nil,
        handler(self, function (obj, errorCode, data)
            self:setLoading(false)
            if errorCode==1 and data and data.code==1 then
                nk.userData.loginReward.accumulation[tostring(rewardData.day)] = 1
                local money1 = nk.functions.getMoney()
                nk.functions.setMoney(money1+data.data.money)
                if not tolua.isnull(self) then
                    local  getRewardsIcon = new(Image, kImageMap.common_check_big)
                    getRewardsIcon:addTo(self.item[index])
                    getRewardsIcon:setAlign(kAlignCenter)
                    getRewardsIcon:setPos(30, 20)
                    self.itemSp[index]:setPickable(false)
                    self.itemSp[index]:doRemoveProp(1)
                    self.itemSp[index]:addPropScaleSolid(1, 0.7, 0.7, kCenterDrawing)
                    self.itemSp[index]:setColor(128,128,128)
                    local strMoney = nk.updateFunctions.formatBigNumber(data.data.money)
                    local chipsAnim = new(require("game.roomQiuQiu.layers.chipsAnimation"))
                    chipsAnim:play("+" .. strMoney, {x=175, y=80, root=self})
                    local rewardList = rewardData.awardDetail
                    nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"RegisterRewardPopup",rewardList)
                end
            end   
        end ))
    end     
end    

function LoginRewardPopup:onCloseReward()
    if self.shadowLayer then
        self.shadowLayer:removeFromParent(true)
        self.shadowLayer = nil
    end
end

function LoginRewardPopup:onCallBack(...)
	if self.m_callFunc then
		self.m_callFunc((...))
	end
end

function LoginRewardPopup:setLoading(isLoading)
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

-------------------------------- handle function --------------------------
--马上玩牌按钮。。
function LoginRewardPopup:onShareButtonClick()  
    if nk.userData.loginReward.ret==0 then
        self:setLoading(true)
        nk.HttpController:execute("Login.getLoginReward", {game_param = {mid = nk.userData.uid}}, nil,
        handler(self, function (obj, errorCode, data)
            if not tolua.isnull(self) then
                self:setLoading(false)
            end
            if errorCode==1 and data and data.code==1 and data.data then
                nk.userData.loginReward.ret = data.data.ret
                --红点
                EventDispatcher.getInstance():dispatch(EventConstants.freeMoney, 5)
                local money1 = nk.functions.getMoney()
                nk.functions.setMoney(data.data.money)
                local money2 = nk.functions.getMoney()
                if not tolua.isnull(self) then
                    local time = 0.5
                    local rewardDay_width = 110
                    local rewardDay_heigh = 145
                    local gettedMask = new(Image, kImageMap.common_rounded_rect_10, nil, nil, 5, 5, 5, 5)
                    gettedMask:setSize(rewardDay_width - 4, rewardDay_heigh - 4)
                    gettedMask:setAlign(kAlignCenter)
                    gettedMask:addTo(self.rewardDay[self.todayStr])
                    -- 已领取图标
                    local getted = new(Image, kImageMap.login_reward_text_gettd)
                    getted:setAlign(kAlignCenter)
                    getted:addTo(self.rewardDay[self.todayStr])
                    local value = rewardDay_width/121
                    getted:setSize(rewardDay_width, value*78)
                    if checkint(nk.userData.vip) > 0 then
                        self.vipLoginRewardGet() 
                    end    
                    local function callback( ... )
                        self.btnText:setText(bm.LangUtil.getText("LOGINREWARD", "IMMEDIATELY_PLAY")) 
                        local strMoney = nk.updateFunctions.formatBigNumber(checkint(money2-money1))
                        local chipsAnim = new(require("game.roomQiuQiu.layers.chipsAnimation"))
                        chipsAnim:play("+" .. strMoney, {x=175, y=80, root=self})
                        nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"RegisterRewardPopup",{{name=strMoney,icon =kImageMap.common_coin_107}})
                    end
                    if self.todayStr >=6 then
                        callback()
                        self.rewardLight:setVisible(false)
                        self.start:setVisible(false)
                        self.highLight:setVisible(false)
                    else
                        self.rewardLight:moveTo({time =time, x = 112,offset=true, onComplete = handler(self, function (obj)
                            if not tolua.isnull(self) then
                               callback()
                            end
                        end    
                            )})
                        self.start:moveTo({time = time, x = 112,offset=true})
                        self.highLight:moveTo({time = time, x = 112,offset=true})
                    end
                end
            end   
        end ))
    else 
        if GameConfig.ROOT_CGI_SID == "2" then
            nk.SocketController:quickPlayQiuQiu()
        else
            nk.SocketController:quickPlayGaple()
        end
        LoginRewardPopup.hide()
        nk.isFromLoginPromoteTag = false -- 从其他界面进入就不在弹登录弹窗了
    end   
end

function LoginRewardPopup:onCloseBtnClick()
    LoginRewardPopup.hide()

    nk.promoteController:isShow("LoginRewardPopup")
end

function LoginRewardPopup:onBgTouch()
    PopupModel.onBgTouch(self)

    nk.promoteController:isShow("LoginRewardPopup")
end

-------------------------------- table config ------------------------

-- Provide cmd handle to call
LoginRewardPopup.s_cmdHandleEx = 
{

}

return LoginRewardPopup