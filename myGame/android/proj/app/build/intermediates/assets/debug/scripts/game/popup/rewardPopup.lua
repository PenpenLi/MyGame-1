--
-- Author: melon
-- Date: 2016-12-01 15:34:09
-- Last modification : 2017-01-18
local PopupModel = require('game.popup.popupModel')
local RewardView = require(VIEW_PATH .. "popup/reward_pop_layer")
local RewardVar = VIEW_PATH .. "popup/reward_pop_layer_layout_var"
local am = require('animation')
local RewardPopup= class(PopupModel)

local swfMap = {swfInfoLua = "qnRes/qnSwfRes/swf/reward_swf_info",swfPinLua = "qnRes/qnSwfRes/swf/reward_swf_pin"}

function RewardPopup.show(...)
    PopupModel.show(RewardPopup, RewardView, RewardVar, {name="RewardPopup"}, ...)
end

function RewardPopup.hide()
    PopupModel.hide(RewardPopup)
end

function RewardPopup:ctor()
    self:addShadowLayer(kImageMap.common_transparent_blank)
    self:initSwf()
end 

function RewardPopup:dtor()
    EventDispatcher.getInstance():dispatch(EventConstants.rewardClosed,nil)
end 

function RewardPopup:initSwf()
    self.swf_ = new(SwfPlayer, require(swfMap.swfInfoLua), require(swfMap.swfPinLua))
    self.swf_:setAlign(kAlignCenter)
    self:addChild(self.swf_)
    self.swf_:play(1,false,1,0,false)
    self.swf_:setFrameEvent(self,self.showGoods,10)
    self.swf_:setCompleteEvent(self,self.endSwf)
end

function RewardPopup:showGoods()
    local rewardList = self.args[1]
    local count = #rewardList
    local dis = 150
    local startX = 0
    if count%2==0 then
        startX = -(count/2 - 1)*150 - 75
    else
        startX = -((count-1)/2)*150
    end
    self.iconBg = {}
    for i,v in ipairs(rewardList) do
        local nameStr = v.name
        if not nameStr then
            nameStr = v[1]
        end
        local iconPath = v.icon or v.image
        if not iconPath then
            iconPath = v[2]
        end
        self.iconBg[i] = new(Image,"res/reward/reward_item_bg.png")
        self.iconBg[i]:setVisible(false)
        self.iconBg[i]:animate(am.sequence(am.prop("rotation",0,0,0.05*(i)),self:appear()))
        self.iconBg[i]:setAlign(kAlignCenter)
        self.iconBg[i]:setPos(startX+150*(i-1),20)
        self:addChild(self.iconBg[i])
        local icon = new(Image,kImageMap["default_qiuqiu"])
        icon:setAlign(kAlignCenter)
        icon:setSize(77,41)
        self.iconBg[i]:addChild(icon)        
        if string.find(iconPath,"http") then
            UrlImage.spriteSetUrl(icon, iconPath)
        elseif iconPath~="" then
            icon:setFile(iconPath)
        end
        local name = new(Text, nameStr, 0, 0, kAlignCenter, nil, 20, 0xff, 0xf6, 0x00)
        name:setAlign(kAlignCenter)
        name:setPos(nil,60)
        self.iconBg[i]:addChild(name)
    end
end

function RewardPopup:appear()
    return am.keyframes{
        {0.0, {scale=Point(0.0,0.0),visible= true, scale_at_anchor_point=true}, am.ease},
        {0.15, {scale=Point(1.15,1.15)}, am.ease},
        {0.3, {scale=Point(1,1)},       am.ease},
    }
end

function RewardPopup:endSwf()
    delete(self.swf_)
    self.swf_ = nil

    local icons =  self.iconBg
    self.iconBg = {}
    if icons then
        for _,icon in pairs(icons) do    
            icon:stopAllAnimations()
            icon:removeFromParent(true)
        end
    end

    self:onClose()  
end

function RewardPopup:onBgTouch()
    self:endSwf()
end

return RewardPopup