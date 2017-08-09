-- RegisterRewardPopup.lua
-- Last modification : 2016-08-10
-- Description: a popup to show registerReward detail info 

local PopupModel = import('game.popup.popupModel')
local RegisterRewardPopup = class(PopupModel);
local RegisterRewardPopupLayer = require(VIEW_PATH .. "popup.register_reward_pop_layer")
local varConfigPath = VIEW_PATH .. "popup.register_reward_pop_layer_layout_var"

local  PromotePopup = require("game.promote.promotePopup")

-------------------------------- single function --------------------------
function RegisterRewardPopup.show(data)
    PopupModel.show(RegisterRewardPopup, RegisterRewardPopupLayer, varConfigPath, {name="RegisterRewardPopup"}, data) 
end

function RegisterRewardPopup.hide()
    PopupModel.hide(RegisterRewardPopup)
end

-------------------------------- base function --------------------------

function RegisterRewardPopup:ctor(viewConfig, varConfigPath, data)
	Log.printInfo("RegisterRewardPopup.ctor");
    self.m_data = data
    self:addShadowLayer()
    self:getUI("CloseBtn"):setClickSound(nk.SoundManager.CLOSE_BUTTON)
	self:init(data)
end 

function RegisterRewardPopup:onCloseBtnClick()
    nk.promoteController:isShow("RegisterRewardPopup")
    RegisterRewardPopup.hide()
end

function RegisterRewardPopup:dtor()
	Log.printInfo("RegisterRewardPopup.dtor")
end

-------------------------------- private function --------------------------

function RegisterRewardPopup:init(data)
	Log.printInfo("RegisterRewardPopup.init");

    self.playLabel = self:getUI("playLabel")
    if nk.userData.registerRewardAward.ret==0 then
        self.playLabel:setText(bm.LangUtil.getText("DAILY_TASK", "GET_REWARD"))
    else
        self.playLabel:setText(bm.LangUtil.getText("LOGINREWARD", "IMMEDIATELY_PLAY"))
    end
    local tipLabel = self:getUI("Text_info")
    tipLabel:setText(bm.LangUtil.getText("REGISTERREWARD", "INFO"))

    local rewardConfig = nk.userData.registerRewardAward.config
    local registerReward = nk.userData.registerRewardAward.reward
    local times = checkint(registerReward.time)
    local dayLabels = {}
    self.item = {}
    self.shader = {}
    self.start = {}
    self.light = {}
    for i=1, 3 do
        local item = self:getUI("itembg" .. i)
        self.item[i] = item
        local rewardLabel = item:getChildByName("moneyLabel")
        rewardLabel:setText(rewardConfig[i][1])
        self.shader[i] = item:getChildByName("shader")
        dayLabels[i] = item:getChildByName("dayLabel")
        if nk.userData.registerRewardAward.ret==0 then
            if  i <  times then
                self.shader[i]:setVisible(true)
            elseif  i == times then
                self.shader[i]:setVisible(false)
            else
                self.shader[i]:setVisible(false)                
            end
        else 
            if  i <= times then
                self.shader[i]:setVisible(true)
            elseif  i == times+1 then
                self.shader[i]:setVisible(false)   
            else
                self.shader[i]:setVisible(false)          
            end
        end     
    end
    if times == 1 then
        dayLabels[1]:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_TODAY"))
        dayLabels[2]:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_TOMORROW"))
        dayLabels[3]:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_THIRD_DAY"))
    elseif times == 2 then
        dayLabels[1]:setText(bm.LangUtil.getText("LOGIN", "REIGSTER_REWARD_FIRST_DAY"))
        dayLabels[2]:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_TODAY"))
        dayLabels[3]:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_TOMORROW"))
    else
        dayLabels[1]:setText(bm.LangUtil.getText("LOGIN", "REIGSTER_REWARD_FIRST_DAY"))
        dayLabels[2]:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_SECOND_DAY"))
        dayLabels[3]:setText(bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_TODAY"))
    end

    --vip 
    local vipLevel = tonumber(nk.userData.vip or 0)
    self:getUI("Text_vip"):setText(bm.LangUtil.getText("STORE","VIP_BE_VIP")) 

    local w,h = self.item[1]:getSize()
             -- 奖励光
    self.highLight= new(Image, kImageMap.login_reward_light_big)
    self.highLight:setAlign(kAlignCenter)
    self.highLight:setSize(108,158)
    -- 奖励星星
    local start = new(Image, kImageMap.login_reward_start)
    start:setAlign(kAlignCenter)
    start:setSize(100,105)
    start:addTo(self.highLight)

    local selected = new(Image, kImageMap.login_reward_item_s,nil,nil,20,20,20,20)
    selected:setAlign(kAlignCenter)
    selected:setSize(w,h)
    selected:addTo(self.highLight)

    local vipItem = self:getUI("itembg_vip")
    self.viplight = vipItem:getChildByName("light")
    self.vipStart = vipItem:getChildByName("star")
    self.vipShader = vipItem:getChildByName("Image_shader")
    self.vipBtn = vipItem:getChildByName("Button_vip")
    if nk.userData.registerRewardAward.ret==0 then
        self.highLight:addTo(self.item[times]) 
        if vipLevel > 0 then
            self.vipShader:setVisible(false)
            self.vipBtn:setVisible(false) 
        else
            self.vipShader:setVisible(false)
            self.vipBtn:setVisible(true) 
        end
    else
        if times<3 then
            self.highLight:addTo(self.item[times+1])
        else
            delete(self.highLight)  
            self.highLight = nil          
        end
        if vipLevel > 0 then
            self.vipShader:setVisible(true)
            self.vipStart:setVisible(false)
            self.viplight:setVisible(false)
            self.vipBtn:setVisible(false) 
        else
            self.vipShader:setVisible(false)
            self.vipBtn:setVisible(true) 
        end
    end   
    if vipLevel < 1 then vipLevel = 1 end
    local reward = nk.vipController:getLoginReward(vipLevel)  
    vipItem:getChildByName("dayLabel"):setText("VIP" .. vipLevel)
    vipItem:getChildByName("moneyLabel"):setText(nk.updateFunctions.formatBigNumber(checkint(reward)).." "..bm.LangUtil.getText("COMMON", "COINS")) 
       
end 

function RegisterRewardPopup:onVipClick()  
    nk.PopupManager:addPopup(require("game.store.vip.vipPopup"),"hall",nil,nil,"vip")
    PopupModel.onClose(self)
end

function RegisterRewardPopup:onUpdate()
    -- body
end

function RegisterRewardPopup:setOtherInfo(typeStr, rankType)
    if typeStr and typeStr == "rank" then
        
    else
        
    end
end

function RegisterRewardPopup:onCallBack(...)
	if self.m_callFunc then
		self.m_callFunc((...))
	end
end

function RegisterRewardPopup:setLoading(isLoading)
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

function RegisterRewardPopup:onPlayButtonClick()
    if  nk.userData.registerRewardAward.ret==0 then
        self:setLoading(true)
        nk.HttpController:execute("Login.getLoginReward", {game_param = {mid = nk.userData.uid}}, nil, handler(self, function (obj, errorCode, data)
            if not tolua.isnull(self) then
                self:setLoading(false)
            end
            if errorCode==1 and data and data.code==1 and data.data then
                nk.userData.registerRewardAward.ret = data.data.ret

                --红点
                EventDispatcher.getInstance():dispatch(EventConstants.freeMoney, 5)

                local money1 = nk.functions.getMoney()
                nk.functions.setMoney(data.data.money)
                local money2 = nk.functions.getMoney()
                if not tolua.isnull(self) then
                    if checkint(nk.userData.vip)>0 then
                        self.vipShader:setVisible(true)
                        self.viplight:setVisible(false)
                        self.vipStart:setVisible(false)
                    else
                        self.vipShader:setVisible(false)
                    end
                    local times =checkint(nk.userData.registerRewardAward.reward.time)
                    self.shader[times]:setVisible(true)
                    local function callback( ... )
                        local strMoney = nk.updateFunctions.formatBigNumber(checkint(money2-money1))
                        local chipsAnim = new(require("game.roomQiuQiu.layers.chipsAnimation"))
                        chipsAnim:play("+" .. strMoney, {x=175, y=80, root=self})
                        self.playLabel:setText(bm.LangUtil.getText("LOGINREWARD", "IMMEDIATELY_PLAY"))
                        nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"RegisterRewardPopup",{{name=strMoney,icon = kImageMap.common_coin_107}})
                    end
                    if times>=3 then
                        self.highLight:setVisible(false)
                        callback()
                    else
                        self.shader[times+1]:setVisible(false)
                        self.highLight:moveTo({time =0.5, x = 140,offset=true, onComplete = handler(self, function (obj)
                            callback()
                        end    
                        )})   
                    end
                end   
            end
        end ))
    else
        if GameConfig.ROOT_CGI_SID == "2" then
            EnterRoomManager.getInstance():enter99Room()
        else
            EnterRoomManager.getInstance():enterGapleRoom()
        end
        nk.isFromLoginPromoteTag = false
    end
end

function RegisterRewardPopup:onBgTouch()
    PopupModel.onBgTouch(self)
    nk.promoteController:isShow("RegisterRewardPopup")
end

return RegisterRewardPopup