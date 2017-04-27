-- VipPopup.lua
-- Last modification : 2017-01-20
-- Description: a people item layer in vip moudle
local vipItemLayer = require("game.store.vip.vipItemlayer")
local VipRulePopup = require("game.store.vip.vipRuleLayer")
local PopupModel = import('game.popup.popupModel')
local vipView = require(VIEW_PATH .. "store.store_vip_layer")
local vipInfo = VIEW_PATH .. "store.store_vip_layer_layout_var"
local VipPopup = class(PopupModel)

function VipPopup.show(...)
    PopupModel.show(VipPopup, vipView, vipInfo, {name="VipPopup"},...)
end

function VipPopup.hide()
    PopupModel.hide(VipPopup)
end

function VipPopup:ctor()
	Log.printInfo("VipLayer", "ctor")
    self:addShadowLayer(kImageMap.common_transparent_blank)
    self:setSize(self.m_root:getSize())

    self.image_bg_ = self:getUI("View_bg")
    self:addCloseBtn(self.image_bg_,-25,-55)

    self:getUI("Text_recharge"):setText(bm.LangUtil.getText("CRASH", "IMM_CHARGE"))

    --vip Icon
    self.vipIcon_gray_ = self:getUI("Image_vip_gray")
    self.vipIcon_light_ = self:getUI("Image_vip_light")

    --vip Num
    self.vipNum1_ = self:getUI("Image_vip_num_1")
    self.vipNum2_ = self:getUI("Image_vip_num_2")

    --vip progress
    self.progress_bg_ = self:getUI("Image_progress_bg")
    self.progress_ = self:getUI("Image_progress")
    self.progress_:setVisible(false)
    self.progress_text_ = self:getUI("Text_vip_process")
    self.next_text_ = self:getUI("Text_vip_next")

    self.privilege_text_ = self:getUI("Text_privilege")

    --button
    self.bt_left_ = self:getUI("Button_left")
    self.bt_right_ = self:getUI("Button_right")

    --autoscrollview
    self.scrollView_ = self:getUI("ScrollView_goods")
    self.scrollView_:setDirection(kVertical)

    self.pageNum_ = 0
end 

function VipPopup:dtor()
	Log.printInfo("VipPopup", "dtor")
	nk.vipController:dispose()
    self:setLoading(false)
end

function VipPopup:onShow()
    self:setLoading(true)
	self:updateVipNum()
	self:updateVipProcess()

	local vipLevel = nk.userData.vip or 0
	if tonumber(vipLevel) < 1 then
		vipLevel = 1
	end
	self:updateVipContent(vipLevel)
end

function VipPopup:onQuestionClick()
    nk.PopupManager:addPopup(VipRulePopup,"store")
end

function VipPopup:updateVipNum()
	local vipLevel = nk.userData.vip or 0
	if tonumber(vipLevel) < 1 then
		self.vipIcon_light_:setVisible(false)
		self.vipIcon_gray_:setVisible(true)
		self.vipNum2_:setVisible(false)
		self.vipNum1_:setFile("res/store/vip_num/0.png")
	else
		self.vipIcon_light_:setVisible(true)
		self.vipIcon_gray_:setVisible(false)
		if tonumber(vipLevel) >= 10 then
			local num1 = math.modf(tonumber(vipLevel)/10)
			local num2 = tonumber(vipLevel)%10
			if num == 0 then num = 10 end
			self.vipNum1_:setFile("res/store/vip_num/" .. num1 .. ".png")
			self.vipNum2_:setFile("res/store/vip_num/" .. num2 .. ".png")
		else
			self.vipNum2_:setVisible(false)
			self.vipNum1_:setFile("res/store/vip_num/" .. vipLevel .. ".png")
		end
	end
end

function VipPopup:updateVipProcess()
	local vipLevel = nk.userData.vip or 0
	local vipScore = nk.userData.score or 0
     
    local showVip = tonumber(vipLevel) + 1

    nk.vipController:loadConfig(nk.userData.VIP_JSON, function(result, data)
    	if result then
    		local vipData = data[tostring(showVip)]
            local vipTop = false
    		if not vipData then
                --当前是最高vip了 
                vipData = data[tostring(vipLevel)]
                vipTop = true
            end
    		local totalScore = vipData.data.score or 1
    		local ratio = tonumber(vipScore)/tonumber(totalScore)
    		if ratio > 0 then
                if ratio > 1 then ratio = 1 end
	    	    local progress_w = self.progress_bg_:getSize()          
		        local _,progress_h = self.progress_:getSize()
		        self.progress_:setVisible(true)
		        self.progress_:setSize(ratio*progress_w, progress_h)
            else
                self.progress_:setVisible(false)
    		end

    		self.next_text_:setText(bm.LangUtil.getText("STORE", "VIP_NEXT_TIP", totalScore, showVip))
            if vipTop then
                self.next_text_:setText(bm.LangUtil.getText("STORE", "VIP_TOP"))
            end
            if tonumber(vipScore) > tonumber(totalScore) then vipScore = totalScore end
    		self.progress_text_:setText(vipScore .. "/" .. totalScore)
    	end
    end)
end

function VipPopup:updateVipContent(vipLevel)
	self.pageNum_ = tonumber(vipLevel)
	nk.vipController:loadConfig(nk.userData.VIP_JSON,function(result, data)
        self:setLoading(false) 
		if result then 
            local vipData = data[tostring(vipLevel)]
    		if not vipData then return end
            update_vip_award_scroll(self.scrollView_, vipData.show)

            self.privilege_text_:setText(bm.LangUtil.getText("STORE", "VIP_PRIVILEGE", string.upper(vipData.data.vipName or "vip0"), vipData.data.time or 0))

            if self.pageNum_  <= 1 then
            	self.bt_left_:setVisible(false)
            else
            	self.bt_left_:setVisible(true)
            end

            if self.pageNum_  >= tonumber(nk.userData.vip or 0) then
            	self.bt_right_:setVisible(false)
            else
            	self.bt_right_:setVisible(true)
            end
		end
	end)
end

function VipPopup:setLoading(isLoading)
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

function VipPopup:onLeftBtClick()
	self.pageNum_ = self.pageNum_ - 1
	self:updateVipContent(self.pageNum_)
end

function VipPopup:onRightBtClick()
	self.pageNum_ = self.pageNum_ + 1
	self:updateVipContent(self.pageNum_)
end

function VipPopup:rechargeBtnClick()
   if not nk.PopupManager:hasCreate(nil,"StorePopup") then
        nk.PopupManager:addPopup(require("game.store.popup.storePopup"))
   end
   self:onClose()
   nk.DataCenterManager:report("btn_vipLayer_pay")
end


update_vip_award_scroll = function(content, data)
	-- data.img
	-- data.name
    local setItemData = function(root)
        local richLabel = new(RichText, root.m_data.name, 205, 52, kAlignLeft, "", 16, 255, 255, 255,true)
        richLabel:setAlign(kAlignTopLeft)
        root.text_:addChild(richLabel)
        UrlImage.spriteSetUrl(root.icon_, root.m_data.img, root:callback())
    end
    content:removeAllChildren(true)
	for i, v in ipairs(data) do
    	local item = new(vipItemLayer)
        item.m_data = v
        setItemData(item)
        item:setPos(math.mod(i-1,2)*310, math.floor((i-1)/2)*91)
        content:addChild(item)
    end
end

return VipPopup