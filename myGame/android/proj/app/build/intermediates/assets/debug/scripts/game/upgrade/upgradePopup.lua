-- upgradePopup.lua
-- Date : 2016-08-10
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local UpgradeController = import("game.upgrade.upgradeController")
local UpgradeView = require(VIEW_PATH .. "upgrade/upgrade_layer")
local UpgradeInfo = VIEW_PATH .. "upgrade/upgrade_layer_layout_var"
local UpgradePopup= class(PopupModel)

UpgradePopup.isShowIng = false

function UpgradePopup.show(data)
	PopupModel.show(UpgradePopup, UpgradeView, UpgradeInfo, {name="UpgradePopup"}, data)
end

function UpgradePopup.hide()
    UpgradePopup.isShowIng = false
	PopupModel.hide(UpgradePopup)
end

function UpgradePopup:ctor(viewConfig)
	Log.printInfo("UpgradePopup.ctor");
    UpgradePopup.isShowIng = true
    self:addShadowLayer()
    self.controller_ = new(UpgradeController, self)
    self:initLayer()
end 

function UpgradePopup:initLayer()
    self:initWidget()
    local index = #nk.userData["invitableLevel"]
    local level = nk.userData["invitableLevel"][1]
    self.level_ = tonumber(level)

    self:initData()

    self:setLoading(true)
    self.controller_:getReward()
end

function UpgradePopup:initWidget()

    self.gold_bg = self:getUI("gold_bg")
    self.gold_bg:setVisible(false)

    self.text_reward_coin = self:getUI("text_reward")

    self.text_level_up = self:getUI("text_level_up")

    self.swf_level_up = self:getUI("swf_level_up")

    -- table.insert(nk.SWF, self.swf_level_up)

    self.swf_level_up:setCompleteEvent(self, function()
            self:hide()
     end)
end

function UpgradePopup:initData()
    self.text_level_up:setText(bm.LangUtil.getText("UPGRADE", "LEVEL_UP_MSG", self.level_))
end

function UpgradePopup:bg_touch(finger_action, x, y, drawing_id_first, drawing_id_current)
    --[[
    if finger_action == kFingerDown then
        self.button_box_:setEnable(false)

        if self.isCallback then
            self:hide()
        end
    elseif finger_action == kFingerUp then
        self.button_box_:setEnable(true)
        self:openListener()
    end
    --]]
end

function UpgradePopup:openListener()
    --[[
    if self.isShared then
        self:onShareListener_()
    else
        print("UpgradePopup:onOpenTreasureListener_")
        self:setLoading(true)
        self.controller_:getReward()
    end
    --]]
end

function UpgradePopup:afterGetReward(rewards)
    self.rewards_ = rewards

    self.gold_bg:setVisible(true)

    self.text_reward_coin:setText("+" .. rewards)

    self.swf_level_up:play(1,0,1,0,0)

    self.swf_play = true
end

function UpgradePopup:onSwfLeveUpClick()
    if self.swf_play then
        self:hide()
    end
end

function UpgradePopup:onShareListener_()
    print("UpgradePopup:onShareListener_")
    self.button_common_:setEnable(false)
    local feedData = clone(bm.LangUtil.getText("FEED", "UPGRADE_REWARD"))
    feedData.name = bm.LangUtil.formatString(feedData.name, self.level_ or "", self.rewards_ or "")
    feedData.picture = bm.LangUtil.formatString(feedData.picture, self.level_ or "")
    nk.FacebookNativeEvent:shareFeed(feedData, function(success, result)
       if success then
           self:hide()
           nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
       else
           nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))       
       end
    end)   
end

function UpgradePopup:setIsCallback()
    self.isCallback = true
end

function UpgradePopup:bt_common_click()
   self:openListener()
end

function UpgradePopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.swf_level_up)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function UpgradePopup:dtor()
    Log.printInfo("UpgradePopup.dtor");
    delete(self.controller_)

    self.swf_level_up:pause(0, false)
    -- delete(self.swf_level_up)
end 


return UpgradePopup