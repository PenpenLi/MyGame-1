--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PopupModel = import('game.popup.popupModel')
local popupView = require(VIEW_PATH .. "promote/promote_layer")
local varConfigPath = VIEW_PATH .. "promote/promote_layer_layout_var"

local CacheHelper = require("game.cache.cache")

local PromotePopup = class(PopupModel);

function PromotePopup.show(data)
    PopupModel.show(PromotePopup, popupView, varConfigPath, {name="PromotePopup"}, data)
end

function PromotePopup.hide()
	PopupModel.hide(PromotePopup)
end

function PromotePopup:ctor(viewConfig, varConfigPath, data)
    self.data_ = data;
    self:addShadowLayer()
	self:initLayer()

	self:setData()
	-- self:requestPromoteInfo()

	-- Clock.instance():schedule(function (dt)
 --                self:requestPromoteInfo()
 --            end, 5)
	
end

function PromotePopup:initLayer()
	self.image_bg_ = self:getUI("Image_bg")
	self:addCloseBtn(self.image_bg_)

	self.Text_title = self:getUI("Text_title")
	self.btn_go_text = self:getUI("btn_go_text")
	self.Image_info = self:getUI("Image_info")

	self.btn_go = self:getUI("btn_go")

	self.Text_title:setVisible(false)
	self.btn_go:setVisible(false)
end


function PromotePopup:requestPromoteInfo()
	self:setLoading(true)

	local cacheHelper = new(CacheHelper)
        cacheHelper:cacheFile(nk.userData.SKIP_JSON, handler(self, function(obj, result, content)

        		if not tolua.isnull(self) then
	                self:setLoading(false)

	                if result then
	            		self.Text_title:setVisible(true)
						self.btn_go:setVisible(true)

	                    self.promoteData_ = content
	                    self:setData()
	                else
	                    
	                end
	            end

            end), "promoteInfo", "data")
end

function PromotePopup:setData()

	-- self.Text_title:setText(self.promoteData_["1"].name)
	-- self.btn_go_text:setText(self.promoteData_["1"].btn)
	-- -- UrlImage.spriteSetUrl(self.Image_info, "http://ppt.downhot.com/d/file/p/2014/08/12/9d92575b4962a981bd9af247ef142449.jpg") -- 网上图片3M大小
	-- -- UrlImage.spriteSetUrl(self.Image_info, "https://mvgliddn01-static.akamaized.net/dominogaple/androidid/task/660x310.png?1478572630")
	--  UrlImage.spriteSetUrl(self.Image_info, self.promoteData_["1"].pic)
	
	self.Text_title:setVisible(true)
	self.btn_go:setVisible(true)

	self.Text_title:setText(nk.promoteController.PromoteConfigData_["1"].name)
	self.btn_go_text:setText(nk.promoteController.PromoteConfigData_["1"].btn)
	UrlImage.spriteSetUrl(self.Image_info, nk.promoteController.PromoteConfigData_["1"].pic)
end

function PromotePopup:btn_go_click()
	 -- 0 : ["大厅"],
 -- 1 : ["房间"],
 -- 2 : ["开始游戏"],
 -- 3 : ["商城/商城"],
 -- 4 : ["充值"],
 -- 5 : ["好友"],
 -- 6 : ["反馈/帮助"],
 -- 7 : ["每日必做/任务"],
 -- 8 : ["排行榜"],
 -- 9 : ["兑奖/兑换"],
 -- 10 : ["用户信息"]
 -- 11 : ["活动中心"]
 -- 12 : ["浏览器页面"]
 -- 13 : ["粉丝页"]

 	local target = nk.promoteController.PromoteConfigData_["1"].flag or 0

 	-- target = "7"

	if target == "0" then

 	elseif target == "1" then
 		if nk.promoteController.PromoteConfigData_["1"].ext["room"] == "1" then
 			nk.roomChooseType = 1
    		nk.PopupManager:addPopup(require("game.roomChoose.roomChoosePopup"), "hall")
 		elseif nk.promoteController.PromoteConfigData_["1"].ext["room"] == "2" then
 			nk.roomChooseType = 2
    		nk.PopupManager:addPopup(require("game.roomChoose.roomChoosePopup"), "hall")
 		end
 	elseif target == "2" then
 		nk.AnalyticsManager:report("New_Gaple_quickStart", "quickStart")

	    if GameConfig.ROOT_CGI_SID == "2" then
	        EnterRoomManager.getInstance():enter99Room()
	    else
	        EnterRoomManager.getInstance():enterGapleRoom()
	    end
 	elseif target == "3" or target == "4" then
 		local StorePopup = require("game.store.popup.storePopup")
        nk.PopupManager:addPopup(StorePopup, "PromotePopup")

    elseif target == "5" then
    	StateMachine.getInstance():pushState(States.Friend, nil, nil, 2)
    elseif target == "6" then
    	local FeedbackPopup = require("game.setting.feedbackLayer")
        nk.PopupManager:addPopup(FeedbackPopup,"PromotePopup")
    elseif target == "7" then
    	local TaskPopup = require("game.task.taskPopup")
        nk.PopupManager:addPopup(TaskPopup,"PromotePopup")
    elseif target == "8" then
    	StateMachine.getInstance():pushState(States.Rank)
    elseif target == "9" then
    	local FansCodePopup = require("game.freeGold.fansCodePopup")
        nk.PopupManager:addPopup(FansCodePopup,"PromotePopup")
    elseif target == "10" then
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "hall")
    elseif target == "11" then
    	nk.AnalyticsManager:report("New_Gaple_activity", "activity")

    	nk.ActivityNativeEvent:activityOpen()
    elseif target == "12" then
    	nk.GameNativeEvent:openBrowser(nk.promoteController.PromoteConfigData_["1"].ext)
    elseif target == "13" then
    	if nk.UpdateConfig and nk.UpdateConfig.facebookFansUrl then
            nk.GameNativeEvent:openBrowser(bm.LangUtil.getText("ABOUT", "FANS_URL"))
        end
 	else

 	end

 	self:hide()



 	--[[
 	if target=="store" or target=="recharge" then                                                 --到商城
        local StorePopup = require("game.store.popup.storePopup")
        nk.PopupManager:addPopup(StorePopup, "hall")
    elseif target=="friend" then                                                --到好友
        StateMachine.getInstance():pushState(States.Friend, nil, nil, 2)
    elseif target=="feedback" then                                              --到反馈
        local FeedbackPopup = require("game.setting.feedbackLayer")
        nk.PopupManager:addPopup(FeedbackPopup,"hall")  
    elseif target=="task" then                                                  --到任务
        local TaskPopup = require("game.task.taskPopup")
        nk.PopupManager:addPopup(TaskPopup,"hall") 
    elseif target=="rank" then                                                  --到排行榜
        StateMachine.getInstance():pushState(States.Rank)
    elseif target=="propstore" then                                             --到兑奖、兑换
        local FansCodePopup = require("game.freeGold.fansCodePopup")
        nk.PopupManager:addPopup(FansCodePopup,"hall")  
    elseif target=="info" then                                              --到个人信息
        local UserPopup = require("game.userInfo.userPopup")
        nk.PopupManager:addPopup(UserPopup,"hall")
    elseif target=="invite" then                                                --邀请界面

    elseif target=="fans" then                                                  --到粉丝页
        if nk.UpdateConfig and nk.UpdateConfig.facebookFansUrl then
            nk.GameNativeEvent:openBrowser(bm.LangUtil.getText("ABOUT", "FANS_URL"))
        end
    elseif target=="recharge" and desc=="first" then                             --首充
        -- cocos 版本也是屏蔽的
        -- if nk.userData["firstPay"] and nk.userData["firstPay"]==0 then
        --     FirstGiftBagPopup.new()
        -- else
        --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("ACTIVITY", "NO_FIRST_PAY"))
        -- end
    else
    end
    --]]
end

function PromotePopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.image_bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function PromotePopup:dtor()
	
end

return PromotePopup
