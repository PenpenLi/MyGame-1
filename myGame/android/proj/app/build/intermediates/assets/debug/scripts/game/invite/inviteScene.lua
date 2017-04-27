-- inviteScene.lua
-- Date: 2016-07-02
-- Last modification : 2016-07-02
-- Description: a scene in Invite moudle
local PopupModel = import('game.popup.popupModel')

local InviteScene = class(PopupModel);
local InviteSceneView = require(VIEW_PATH .. "invite.invite_scene")
local InviteSceneVar = VIEW_PATH .. "invite.invite_scene_layout_var"
local InviteConfig = require("game.invite.inviteConfig")
local InviteFriendViewLayer = require("game.invite.layers.inviteFriendViewLayer")
local InviteMyAwardViewLayer = require("game.invite.layers.inviteMyAwardViewLayer")
local InviteRuleViewLayer = require("game.invite.layers.inviteRuleViewLayer")

function InviteScene.show(data)
	PopupModel.show(InviteScene, InviteSceneView, InviteSceneVar, {name="InviteScene"}, data)
end

function InviteScene.hide()
	PopupModel.hide(InviteScene)
end

function InviteScene:ctor()
	Log.printInfo("InviteScene.ctor");
	self:addShadowLayer()
    -- 初始化界面数据
    self:initScene()
end 

function InviteScene:dtor()
	nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "inviteIsGet", self.inviteIsGetHandle_)
    Log.printInfo("InviteScene.dtor");
    delete(self.m_inviteContentView)
    self.m_inviteContentView = nil
    delete(self.m_myAwardContentView)
    self.m_myAwardContentView = nil
    delete(self.m_ruleContentView)
    self.m_ruleContentView = nil
end

-------------------------------- private function --------------------------

function InviteScene:initScene(viewType)	
	local imageBg = self:getUI("Image_bg")
    self:addCloseBtn(imageBg)

	-- 设置TAB切换监听
	local titleGroup = self:getUI("radioButtonGroup")
	titleGroup:setOnChange(self,self.onTitleGroupChangeClick);
	-- 邀请好友
	self.m_inviteRadiobutton = self:getControl(self.s_controls["inviteRadiobutton"])
	self:getUI("inviteFriendLabel"):setText(bm.LangUtil.getText("FRIEND", "MAIN_TAB_TEXT")[1])

	-- 我的奖励
	self.m_myAwardRadiobutton = self:getControl(self.s_controls["myAwardRadiobutton"])
	self:getUI("myAwardLabel"):setText(bm.LangUtil.getText("FRIEND", "MAIN_TAB_TEXT")[2])

	-- 我的奖励红点
	self.m_inviteRedPoint = self:getUI("inviteRed")
	self.m_inviteRedPoint:setVisible(false)

	-- 规则
	self.m_ruleRadiobutton = self:getControl(self.s_controls["ruleRadiobutton"])
	self:getUI("ruleLabel"):setText(bm.LangUtil.getText("FRIEND", "MAIN_TAB_TEXT")[3])

	-----邀请好友-----

	-- inviteView 邀请好友View
	self.m_inviteView = self:getControl(self.s_controls["inviteView"])

    -- myAwardView 我的奖励View
	self.m_myAwardView = self:getControl(self.s_controls["myAwardView"])

	-- ruleView 规则View
	self.m_ruleView = self:getControl(self.s_controls["ruleView"])

	self.m_inviteRadiobutton:setChecked(true)
	self:onShowInviteView()

	-- 邀请奖励红点监听
    self.inviteIsGetHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "inviteIsGet", handler(self, function(obj, inviteIsGet)
        if inviteIsGet and inviteIsGet >0 then
            self.m_inviteRedPoint:setVisible(true)
        else   
            self.m_inviteRedPoint:setVisible(false) 
        end
    end))
end

function InviteScene:onTitleGroupChangeClick()
    Log.printInfo("InviteScene", "onTitleGroupChangeClick")
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if self.m_inviteRadiobutton:isChecked() then
    	self:onShowInviteView()
    elseif self.m_myAwardRadiobutton:isChecked() then
    	self:onShowMyAwardView()
    elseif self.m_ruleRadiobutton:isChecked() then
    	self:onShowRuleView()
    end
end

-- 邀请好友模块 --

function InviteScene:onShowInviteView()
    nk.AnalyticsManager:report("New_Gaple_invite_friend", "invite")
	self.m_inviteView:setVisible(true)
	self.m_myAwardView:setVisible(false)
	self.m_ruleView:setVisible(false)
	if not self.m_inviteContentView then
		self.m_inviteContentView = new(InviteFriendViewLayer)
		self.m_inviteView:addChild(self.m_inviteContentView)
	end
	self.m_inviteContentView:onShow()
end

-- 我的奖励模块 --

function InviteScene:onShowMyAwardView()
    nk.AnalyticsManager:report("New_Gaple_invite_reward", "invite")
	self.m_myAwardView:setVisible(true)
	self.m_ruleView:setVisible(false)
	self.m_inviteView:setVisible(false)
	if not self.m_myAwardContentView then
		self.m_myAwardContentView = new(InviteMyAwardViewLayer)
		self.m_myAwardView:addChild(self.m_myAwardContentView)
	end
	self.m_myAwardContentView:onShow()
end

-- 规则模块 --
function InviteScene:onShowRuleView()
    nk.AnalyticsManager:report("New_Gaple_invite_rule", "invite")
	self.m_ruleView:setVisible(true)
	self.m_myAwardView:setVisible(false)
	self.m_inviteView:setVisible(false)
	if not self.m_ruleContentView then
		self.m_ruleContentView = new(InviteRuleViewLayer)
		self.m_ruleView:addChild(self.m_ruleContentView)
	end
	self.m_ruleContentView:onShow()
end

return InviteScene