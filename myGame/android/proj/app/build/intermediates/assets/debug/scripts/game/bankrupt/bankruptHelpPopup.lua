-- BankruptHelpPopup.lua
-- Date : 2016-08-11
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local bankruptHelpView = require(VIEW_PATH .. "bankrupt/bankrupt_help_layer")
local bankruptHelpInfo = VIEW_PATH .. "bankrupt/bankrupt_help_layer_layout_var"
local BankruptHelpPopup= class(PopupModel);

local FirstRechargePopup = require("game.firstRecharge.firstRechargePopup")

function BankruptHelpPopup.show(data)
	PopupModel.show(BankruptHelpPopup, bankruptHelpView, bankruptHelpInfo, {name="BankruptHelpPopup"}, data)


end

function BankruptHelpPopup.hide()
	PopupModel.hide(BankruptHelpPopup)
end

function BankruptHelpPopup:ctor(viewConfig)
    Log.printInfo("BankruptHelpPopup.ctor")
    self:addShadowLayer()
    local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
    self.subsidizeChips_ = nk.userData.bankruptcyGrant.money[rewardTime] or 0
    self.limitedTimes_ = nk.userData.bankruptcyGrant.num or 0
    self.limitedDay_ = nk.userData.bankruptcyGrant.day or 1

    self:initLayer()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end 

function BankruptHelpPopup:initLayer()
     self:initWidget()
end

function BankruptHelpPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)   

    self:getUI("Text_title"):setText(bm.LangUtil.getText("CRASH", "TITLE"))
    self:getUI("Text_bt_get"):setText(bm.LangUtil.getText("CRASH", "GET"))

    self:getUI("Text_tip"):setText(bm.LangUtil.getText("CRASH", "CHIPS_TIPS"))
    self:getUI("Text_info"):setText(bm.LangUtil.getText("CRASH", "CHIPS_INFO", self.limitedDay_,self.limitedTimes_))
  --  self:getUI("Text_reward"):setText(bm.LangUtil.getText("CRASH", "CHIPS", self.subsidizeChips_))

    if nk.userData.bankruptcyGrant and nk.functions.getMoney() < nk.userData.bankruptcyGrant.maxBmoney and
        nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
            self:getUI("Image_item1"):setVisible(true)
    else
        self:getUI("Image_item1"):setVisible(false)

        self:getUI("Image_item3"):setPos(self:getUI("Image_item2"):getPos())
        self:getUI("Image_item2"):setPos(self:getUI("Image_item1"):getPos())

       -- self.image_bg_:setSize(725, 459 - 116)
    end

    -- 2
    self:getUI("Text_bt_get2"):setText(bm.LangUtil.getText("CRASH", "BTN_GET_TEXT2"))
    self:getUI("Text_tip2"):setText(bm.LangUtil.getText("CRASH", "INVITE_FRIEND_TIPS"))
    self:getUI("Text_info2"):setText(bm.LangUtil.getText("CRASH", "INVITE_FRIEND_INFO"))

    -- 3
    self:getUI("Text_bt_get3"):setText(bm.LangUtil.getText("CRASH", "BTN_GET_TEXT3"))
    self:getUI("Text_tip3"):setText(bm.LangUtil.getText("CRASH", "BUY_CHIPS_TIPS"))
    self:getUI("Text_info3"):setText(bm.LangUtil.getText("CRASH", "BUY_CHIPS_INFO"))

    if nk.userData["firstRechargeStatus"] == 1 then
        -- 首冲
        self:getUI("Img_bonus"):setVisible(true)
        self:getUI("Img_discount"):setVisible(false)
    else
        -- 商店购买
        self:getUI("Img_bonus"):setVisible(false)

        if nk.maxDiscount > 0 then
            self:getUI("Img_discount"):setVisible(true)
            self:getUI("discount"):setText("+"..nk.maxDiscount.."%")
            self:getUI("discount"):addPropRotateSolid(1, -30, kCenterDrawing)
        end
        
    end
end

-- 破产补助
function BankruptHelpPopup:bt_get_click()
    if self.rewardHttping then
       return
    end
    self.rewardHttping = true
    self:setLoading(true)
   
    nk.HttpController:execute("Bankruptcy.receiveBankruptcy", {game_param ={mid = nk.userData.uid}})
end

-- 邀请奖励
function BankruptHelpPopup:bt_get_click2()
    local InviteScene = require("game.invite.inviteScene")
    nk.PopupManager:addPopup(InviteScene,"BankruptHelpPopup")
end

-- 购买金币
function BankruptHelpPopup:bt_get_click3()
    if nk.userData["firstRechargeStatus"] == 1 then
        -- 首冲
        nk.PopupManager:addPopup(FirstRechargePopup, "bankrupt") 
    else
        -- 商店购买
        local StorePopup = require("game.store.popup.storePopup")
        nk.PopupManager:addPopup(StorePopup)
    end

end

function BankruptHelpPopup:onHttpProcesser(command, code, content)
    if  command == "Bankruptcy.receiveBankruptcy" then
      self.rewardHttping = nil
      self:setLoading(false)

      if code ~= 1 then
        return
      end

      local retData = content.data
      if tonumber(content.code) == 1  then
        local addmoney = checkint(retData.addmoney or retData.addMoney)
        local money = checkint(retData.money)
        local times = checkint(retData.times);
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD", addmoney))

        nk.functions.setMoney(money)
        if nk.userData.bankruptcyGrant then
          nk.userData.bankruptcyGrant.bankruptcyTimes = times;
        end

        if not nk.updateFunctions.checkIsNull(self) then
          self:hide()
        end
      elseif tonumber(content.code) == -3 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "OTHER_TIME_LABEL"))
      end
    end
end

function BankruptHelpPopup:setLoading(isLoading)
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

function BankruptHelpPopup:dtor()
    Log.printInfo("BankruptHelpPopup.dtor");
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end 


return BankruptHelpPopup