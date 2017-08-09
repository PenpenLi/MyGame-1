-- StorePopup.lua
-- Last modification : 2016-08-10
-- Description: a popup to show registerReward detail info 

local PopupModel = import('game.popup.popupModel')
local StorePopup = class(PopupModel)
local StorePopupController = import('game.store.popup.storePopupController')
local StorePopupLayer = require(VIEW_PATH .. "store.store_scene")
local varConfigPath = VIEW_PATH .. "store.store_scene_layout_var"

local StoreConfig = require("game.store.storeConfig")
local StorePayTypeItemLayer = require("game.store.layers.storePayTypeItemLayer")
local StorePropTypeItemLayer = require("game.store.layers.storePropTypeItemLayer")
local StoreGoodsItemLayer = require("game.store.layers.storeGoodsItemLayer")
local StorePropItemLayer = require("game.store.layers.storePropItemLayer")
local LoadingAnim = require("game.anim.loadingAnim")
local StoreHistoryPopup = require("game.store.layers.storeHistoryPopup")
local VipPopup = require("game.store.vip.vipPopup")

local GoodsTypeIds = {
    ["goods"]   = 1,
    ["prop"]  = 2,
} 

-------------------------------- single function --------------------------
function StorePopup.show(...)
    PopupModel.show(StorePopup, StorePopupLayer, varConfigPath, {name="StorePopup"}, ...) 
end

function StorePopup.hide()
    PopupModel.hide(StorePopup)
end

-------------------------------- base function --------------------------

function StorePopup:ctor(viewConfig, varConfigPath, isRoom, level, goto, tab)
	Log.printInfo("StorePopup.ctor");
    nk.AnalyticsManager:report("New_Gaple_store", "store")
    self.m_isRoom = isRoom
    self.m_roomLevel = level
    self.m_controller = new(StorePopupController, self, isRoom, level)
    self.m_goto = goto
    self.m_tab = tab
    self:addCloseBtn(self:getUI("bg"),10,10)
	self:init()
end 

function StorePopup:dtor()
	Log.printInfo("StorePopup.dtor")
    delete(self.m_controller)
    self.m_controller = nil
    delete(self.m_vipContentView)
    self.m_vipContentView = nil
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "vip", self.vipLevelHandle_)
end

-------------------------------- private function --------------------------

function StorePopup:init()
	Log.printInfo("StorePopup.init");
    self.m_titleIndex = 1

    self.m_rightView = self:getUI("rightView")

    local goodsTypeGroup = self:getUI("goodsTypeGroup")
    goodsTypeGroup:setOnChange(self,self.onGoodsTypeGroupChangeClick)

    -- 设置TAB标题文字
	local typeGoodsLabel = self:getUI("typeGoodsLabel")
	typeGoodsLabel:setText(bm.LangUtil.getText("STORE", "TITLE_CHIP"))
	local typePropsLabel = self:getUI("typePropsLabel")
	typePropsLabel:setText(bm.LangUtil.getText("STORE", "TITLE_PROPS"))

    -- 设置TAB切换监听
    -- goodsTypeView顶部商品类型
    self.m_typeGoodsRadiobutton = self:getUI("typeGoodsRadiobutton")  

    -- goodsTypeView顶部道具类型
    self.m_typePropsRadiobutton = self:getUI("typePropsRadiobutton")

    -- payTypeScrollerView左侧支付类型
    self.m_payTypeListView = self:getUI("payTypeListView")
    self.m_payTypeListView:setVisible(true)

    -- goodsListView 商品ListView
    self.m_goodsListView = self:getUI("goodsListView")
    self.m_goodsListView:setVisible(true)

    -- propTypeScrollerView左侧道具类型
    self.m_propTypeListView = self:getUI("propTypeListView")
    self.m_propTypeListView:setVisible(false)

    -- propListView 道具ListView
    self.m_propListView = self:getUI("propListView")
    self.m_propListView:setVisible(false)

    self.vip_view_ = self:getUI("View_vip")

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

    self:getUI("Text_privilege"):setText(bm.LangUtil.getText("STORE", "VIP_PRIVILEGE_INFO"))

    --vip到期时间
    self.m_vipTimeView = self:getUI("vipTimeView")
    self.m_vipTimeLabel = self:getUI("vipTimeLabel")

    -- noticeView vip View
--    self.m_noticeView = self:getUI("NoticeView")
--    self.m_noticeClip = self:getUI("NoticeClip")
--    self.noticeW,self.noticeH = self.m_noticeClip:getSize() 
--    self.m_noticeClip:setClip2(true, 0, 0,self.noticeW, self.noticeH)
--    self.noticeIndex = 1
--    self.noticeList = nil
--    self.m_controller:loadStoreNotice()
    -- 个人金币
    self.m_moneyView = self:getUI("moneyView")
    self.m_moenyLabel = self:getUI("myMoneyLabel")
    self.m_moenyLabel:setText(nk.updateFunctions.formatBigNumber(nk.userData.money))

    -- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self.m_rightView) 
    -- 商城女郎
    self.m_salerImage = self:getUI("salerImage")
    self.m_salerImage:setVisible(false)

    -- 没有数据提示
    self.m_noDataTipLabel = self:getUI("noDataTipLabel")
    self.m_noDataTipLabel:setVisible(false)
    --购买历史记录
    self.m_bt_history = self:getUI("Button_history")
    self.m_bt_history:setOnClick(self, self.onHistoryClick)
    self:fixScale()

    -- 金币监听
    self.moneyHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, function(obj, money)
        if not nk.updateFunctions.checkIsNull(obj) and money and money>=0 and not nk.isInSingleRoom then
            Log.printInfo("addPropertyObservers money = ", money)
            obj.m_moenyLabel:setText(nk.updateFunctions.formatBigNumber(money))
        end
    end))

    -- vip level
    self.vipLevelHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA,"vip", handler(self, function(obj,vip)
        local typeId = self:getGoodsTypeId()
        if  typeId ==  GoodsTypeIds.goods then
            local payId = self:getPayId()
            if payId then
                self:onPayTypeChangeClick(payId)
            end
        end
        self:updateVipNum()
	    self:updateVipProcess()
        self:updateVipTime()
    end))
end 

function StorePopup:updateVipNum()
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

function StorePopup:updateVipProcess()
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

function StorePopup:updateVipTime()
    local time = nk.userData.expiry_time or 0
    local vipLevel = nk.userData.vip or 0
    if tonumber(vipLevel) > 0 and tonumber(time) > os.time() then
        self.m_vipTimeView:setVisible(true)
        self.m_vipTimeLabel:setText(bm.LangUtil.getText("STORE", "VIP_EXPIRY_TIME", os.date("%Y-%m-%d",time )))
    else
        self.m_vipTimeView:setVisible(false)
    end   
end

function StorePopup:onShow()
    if self.m_goto and self.m_goto == "prop"then
        self.m_typePropsRadiobutton:setChecked(true)
        self:onGoodsTypeGroupChangeClick()  
        self:setGoodsTypeId(GoodsTypeIds.prop) 
        self.vip_view_:setVisible(false)
    else
        self.m_typeGoodsRadiobutton:setChecked(true)
        self.m_controller:loadPayConfig()    
        self:setGoodsTypeId(GoodsTypeIds.goods)
        self.vip_view_:setVisible(true)
    end
end

--商城公告
function StorePopup:playNotice(noticeList)
    if noticeList and not self.noticeList then
        self.noticeList = noticeList
    end
    if not self.noticeList then
        return
    end
    self.m_notice = new(Text,self.noticeList[self.noticeIndex],0,self.noticeH,kAlignLeft,nil,20,234,213,255)
    local w,h = self.m_notice:getSize()
    self.m_notice:setPos(self.noticeW+50,0)
    --self.m_noticeClip:addChild(self.m_notice)
    local oX,oY = self.m_notice:getPos()
    local tX = -w-10
    self.m_notice:moveTo({x = tX, time = (oX-tX)/80,onComplete = handler(self, function()
        self.noticeIndex = self.noticeIndex + 1
        if self.noticeIndex>#self.noticeList then
            self.noticeIndex = 1
        end     
        if self.m_notice then
            self.m_notice:removeFromParent(true)
        end
        self:playNotice()
        end)})
end

-- 调整屏幕适配
function StorePopup:fixScale()
	local leftView = self:getUI("leftView")
	fix_scale(leftView)
	fix_scale(self.m_rightView)
end

function StorePopup:onHistoryClick()
    nk.PopupManager:addPopup(StoreHistoryPopup,"StoreHistoryPopup")
end

function StorePopup:privilegeBtnClick()
    nk.AnalyticsManager:report("New_Gaple_store_vip_click", "store")
    nk.PopupManager:addPopup(VipPopup,"VipPopup")   
end

function StorePopup:onGoodsTypeGroupChangeClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if self.m_typeGoodsRadiobutton:isChecked() then
         nk.AnalyticsManager:report("New_Gaple_store_gold_click", "store")
        self:onTypeGoodsChecked(true)
        self:onTypePropsChecked(false)
    elseif self.m_typePropsRadiobutton:isChecked() then
        nk.AnalyticsManager:report("New_Gaple_store_prop_click", "store")
        self:onTypePropsChecked(true)
        self:onTypeGoodsChecked(false)        
    end
end

function StorePopup:onTypeGoodsChecked(status)
    local typeGoodsImage = self:getUI("typeGoodsImage")
    if status then
        typeGoodsImage:setFile(kImageMap.store_koin_down)
        self:setGoodsTypeId(GoodsTypeIds.goods)
        self:onShowGoodsView()
    else
        typeGoodsImage:setFile(kImageMap.store_koin_up)
    end
end

function StorePopup:onTypePropsChecked(status)
    local typePropsImage = self:getUI("typePropsImage")
    if status then
        typePropsImage:setFile(kImageMap.store_koin_down)
        self:setGoodsTypeId(GoodsTypeIds.prop)
        self:onShowPropView()
    else
        typePropsImage:setFile(kImageMap.store_koin_up)
    end
end

function StorePopup:onShowLoading(status)   
   if self.m_loadingAnim then 
        if status then
            Log.printInfo("StoreScene","onShowLoading true") 
            self.m_loadingAnim:onLoadingStart()
        else
            Log.printInfo("StoreScene","onShowLoading false")
            self.m_loadingAnim:onLoadingRelease()
        end
   end
end

function StorePopup:onShowGoodsView()
    Log.printInfo("StoreScene","onShowGoodsView")
    if self:getGoodsTypeId() == GoodsTypeIds.goods then
        self.m_payTypeListView:setVisible(true)
        self.m_goodsListView:setVisible(true)
        self.m_propTypeListView:setVisible(false)
        self.m_propListView:setVisible(false)
        self.m_salerImage:setVisible(false)
        self.m_moneyView:setVisible(true)
        self:onShowLoading(true)
        self:requestCtrlCmd("loadChipProductList", self:getPayId())
        self.vip_view_:setVisible(true)
    else
        -- TO DO 
    end
end

function StorePopup:onShowPropView()
    Log.printInfo("StoreScene","onShowPropView")
    if self:getGoodsTypeId() == GoodsTypeIds.prop then
        self.m_propTypeListView:setVisible(true)
        self.m_propListView:setVisible(false)
        self.m_payTypeListView:setVisible(false)
        self.m_goodsListView:setVisible(false)
        self.m_salerImage:setVisible(false)
        self.m_moneyView:setVisible(true)
        self:onShowLoading(true)
        self:requestCtrlCmd("loadPropProductList", self:getPropId())
        self.vip_view_:setVisible(false)
    else
        -- TO DO 
    end
end

function StorePopup:onShowNoDataTip(status, str)
    self.m_noDataTipLabel:setVisible(status)
    if str then
        self.m_noDataTipLabel:setText(str)
    end
end

-- payType 支付类型改变
function StorePopup:onPayTypeChangeClick(payId)
    Log.printInfo("StorePopup","onPayTypeChangeClick payId is " .. payId)
    self:setPayId(payId)
    self:onShowLoading(true)
    self:requestCtrlCmd("loadChipProductList", payId)
end

-- prop 道具类型改变
function StorePopup:onPropTypeChangeClick(propId)
    Log.printInfo("StorePopup","onPropTypeChangeClick propId is " .. propId)
    self:setPropId(propId)
    self:onShowLoading(true)
    self.m_propListView:setVisible(false)
    self:requestCtrlCmd("loadPropProductList", propId)
end

function StorePopup:onCallBack(...)
	if self.m_callFunc then
		self.m_callFunc((...))
	end
end

function StorePopup:setGoodsTypeId(str)
	self.m_baseData:setGoodsTypeViewId(str)
end

function StorePopup:getGoodsTypeId()
	return self.m_baseData:getGoodsTypeViewId()
end

function StorePopup:setPayId(str)
	self.m_baseData:setPayViewId(str)
end

function StorePopup:getPayId()
	return self.m_baseData:getPayViewId()
end

function StorePopup:setPropId(str)
	self.m_baseData:setPropViewId(str)
end

function StorePopup:getPropId()
	return self.m_baseData:getPropViewId()
end
-------------------------------- handle function --------------------------

-- 更新支付类型列表
function StorePopup:onUpdatePayTypeList(data)
    Log.printInfo("StorePopup","onUpdatePayTypeList")
    self:onShowLoading(false)

    if not data or #data < 1 then
        self:onShowNoDataTip(true, bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"))
        return
    end
    self:onShowNoDataTip(false)
    table.foreach(data, function(i, v)
            v.callback = handler(self, self.onPayTypeChangeClick)
        end)
    local adapter = new(CacheAdapter, StorePayTypeItemLayer, data)
    self.m_payTypeListView:setAdapter(adapter)

    local id = data[1].id
    self:setPayId(id)

    -- 加载第一个支付的商品列表
    self:onShowLoading(true)
    self:requestCtrlCmd("loadChipProductList", id)
end

-- 更新商品(金币)列表
function StorePopup:onUpdateGoodsList(paytype)
    Log.printInfo("StorePopup","onUpdateGoodsList")
    self:onShowLoading(false)
    local data = self.m_baseData:getGoodsData(paytype.id)
    if not data or #data < 1 then
        self:onShowNoDataTip(true, bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"))
        self.m_goodsListView:removeAllChildren(true)
        return
    end
    self:onShowNoDataTip(false)
    if paytype.id == self:getPayId() then
        self.m_goodsListView:removeAllChildren(true)
        local adapter = new(CacheAdapter, StoreGoodsItemLayer, data)
        self.m_goodsListView:setAdapter(adapter)
    end
end

-- 更新道具类型列表
function StorePopup:onUpdatePropTypeList(data)
    Log.printInfo("StorePopup","onUpdatePropTypeList")
    self:onShowLoading(false)
    if not data or #data < 1 then
        self:onShowNoDataTip(true, bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"))
        return
    end
    self:onShowNoDataTip(false)
    table.foreach(data, function(i, v)
            v.callback = handler(self, self.onPropTypeChangeClick)
        end)
    local adapter = new(CacheAdapter, StorePropTypeItemLayer, data)
    self.m_propTypeListView:setAdapter(adapter)

    local id = data[1].id
    local index = 1
    if self.m_tab then
        id = data[tonumber(self.m_tab)].id
        index = tonumber(self.m_tab)
    end       
    self:setPropId(id)
    self.m_propTypeListView:getAdapter():getView(index):setSelect(true)

    -- 加载第一个类型的道具列表
    self:onShowLoading(true)
    self:requestCtrlCmd("loadPropProductList", id)
end

-- 更新道具列表
function StorePopup:onUpdatePropList(data)
    Log.printInfo("StorePopup","onShowPropList")
    self:onShowLoading(false)
    if not data or #data < 1 then
        self:onShowNoDataTip(true, bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"))
        return
    end
    self.m_propListView:setVisible(true)
    self:onShowNoDataTip(false)
    local adapter = new(CacheAdapter, StorePropItemLayer, data)
    self.m_propListView:setAdapter(adapter)
end

-------------------------------- UI function --------------------------

-------------------------------- table config ------------------------

-- Provide cmd handle to call
StorePopup.s_cmdHandleEx = 
{
    --["***"] = function
    ["updateGoodsTypeList"] = StorePopup.onUpdateGoodsTypeList,
    ["updatePayTypeList"] = StorePopup.onUpdatePayTypeList,
    ["updateGoodsList"] = StorePopup.onUpdateGoodsList,
    ["updatePropTypeList"] = StorePopup.onUpdatePropTypeList,
    ["updatePropList"] = StorePopup.onUpdatePropList,
    ["showNoDataTip"] = StorePopup.onShowNoDataTip,
    ["playNotice"] = StorePopup.playNotice,
}

-------------------------------- ****private config*** ------------------------

function StorePopup:requestCtrlCmd(cmd, ...)
    if not self.m_controller then
        return
    end

    return self.m_controller:handleCmdEx(cmd, ...)
end

return StorePopup