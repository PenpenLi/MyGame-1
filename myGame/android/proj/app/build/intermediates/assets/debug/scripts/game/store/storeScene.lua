-- storeScene.lua
-- Create Data: 2016-06-03
-- Last modification : 2016-07-06
-- Description: a scene in Store moudle

local StoreScene = class(GameBaseScene)
local StoreConfig = require("game.store.storeConfig")
local StorePayTypeItemLayer = require("game.store.layers.storePayTypeItemLayer")
local StorePropTypeItemLayer = require("game.store.layers.storePropTypeItemLayer")
local StoreGoodsItemLayer = require("game.store.layers.storeGoodsItemLayer")
local StorePropItemLayer = require("game.store.layers.storePropItemLayer")
local StoreHistoryItemLayer = require("game.store.layers.storeHistoryItemLayer")
local LoadingAnim = require("game.anim.loadingAnim")
local StoreHistoryPopup = require("game.store.layers.storeHistoryPopup")

local GoodsTypeIds = {
	["goods"]	= 1,
	["prop"]  = 2,
	["history"] = 3,
} 

function StoreScene:ctor(viewConfig,controller)
	Log.printInfo("StoreScene.ctor")
    -- 初始化数据
    self:initScene()
end 

function StoreScene:resume()
    Log.printInfo("StoreScene.resume")
    GameBaseScene.resume(self)
end

function StoreScene:pause()
    Log.printInfo("StoreScene.pause")
    nk.PopupManager:removeAllPopup()
	GameBaseScene.pause(self)
end 

function StoreScene:dtor()
    Log.printInfo("StoreScene.dtor")
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyHandle_)
    -- self.m_titleHandle:cancel()
    -- self.m_titleHandle = nil
end

-------------------------------- private function --------------------------

function StoreScene:initScene(goodsType)

	local storeTitleImage = self:getUI("storeTitleImage")
    local lightImage_1 = self:getUI("lightImage_1")
    local lightImage_2 = self:getUI("lightImage_2")
	self.m_titleIndex = 1

	-- 调度每1秒执行某函数。
--    self.m_titleHandle = Clock.instance():schedule(function(dt)
--		if self.m_titleIndex == 1 then
--			self.m_titleIndex = 2
--           	lightImage_2:scaleTo({srcX=0.5, scaleX=1, srcY=0.5, scaleY=1, time=0.8})
--		else
--			self.m_titleIndex = 1
--           	lightImage_1:scaleTo({srcX=0.5, scaleX=1, srcY=0.5, scaleY=1, time=0.8})
--		end
--		storeTitleImage:setFile(kImageMap["store_title_bg_" .. self.m_titleIndex])
--	end, 1)

	self.m_rightView = self:getUI("rightView")

	-- 设置TAB标题文字
	local typeGoodsLabel = self:getUI("typeGoodsLabel")
	typeGoodsLabel:setText(bm.LangUtil.getText("STORE", "TITLE_CHIP"))
	local typePropsLabel = self:getUI("typePropsLabel")
	typePropsLabel:setText(bm.LangUtil.getText("STORE", "TITLE_PROPS"))
	local typeHistoryLabel = self:getUI("typeHistoryLabel")
	--typeHistoryLabel:setText(bm.LangUtil.getText("STORE", "TITLE_HISTORY"))

	local goodsTypeGroup = self:getUI("goodsTypeGroup")
	goodsTypeGroup:setOnChange(self,self.onGoodsTypeGroupChangeClick)

	-- 设置TAB切换监听
	-- goodsTypeView顶部商品类型
	self.m_typeGoodsRadiobutton = self:getUI("typeGoodsRadiobutton")
	self.m_typeGoodsRadiobutton:setChecked(true)

	-- goodsTypeView顶部道具类型
	self.m_typePropsRadiobutton = self:getUI("typePropsRadiobutton")

	-- goodsTypeView顶部历史记录类型
	self.m_typeHistoryRadiobutton = self:getUI("typeHistoryRadiobutton")

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

    -- historyView 购买历史View
	self.m_historyView = self:getUI("historyView")
	self.m_historyView:setVisible(false)

    -- historyListView 购买历史ListView
	self.m_historyListView = self:getUI("historyListView")

    -- 个人金币
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
    self:fixScale()

    -- 金币监听
    self.moneyHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, function(obj, money)
        if not nk.updateFunctions.checkIsNull(obj) and money and money>=0 and not nk.isInSingleRoom then
            Log.printInfo("addPropertyObservers money = ", money)
            obj.m_moenyLabel:setText(nk.updateFunctions.formatBigNumber(money))
        end
    end))

    --购买历史记录
    self.m_bt_history = self:getUI("Button_history")
    self.m_bt_history:setOnClick(self, self.onHistoryClick)
end

-- 调整屏幕适配
function StoreScene:fixScale()
	local leftView = self:getUI("leftView")
	fix_scale(leftView)
	fix_scale(self.m_rightView)
end

function StoreScene:onHistoryClick()
	nk.PopupManager:addPopup(StoreHistoryPopup,"StoreHistoryPopup")
end

function StoreScene:setGoodsTypeId(str)
	self.m_baseData:setGoodsTypeViewId(str)
end

function StoreScene:getGoodsTypeId()
	return self.m_baseData:getGoodsTypeViewId()
end

function StoreScene:setPayId(str)
	self.m_baseData:setPayViewId(str)
end

function StoreScene:getPayId()
	return self.m_baseData:getPayViewId()
end

function StoreScene:setPropId(str)
	self.m_baseData:setPropViewId(str)
end

function StoreScene:getPropId()
	return self.m_baseData:getPropViewId()
end

-- Provide state to call
function StoreScene:onBack()

end

function StoreScene:onGoodsTypeGroupChangeClick()
	if self.m_typeGoodsRadiobutton:isChecked() then
		self:onTypeGoodsChecked(true)
		self:onTypePropsChecked(false)
		self:onTypeHistoryChecked(false)
	elseif self.m_typePropsRadiobutton:isChecked() then
		self:onTypePropsChecked(true)
		self:onTypeGoodsChecked(false)
		self:onTypeHistoryChecked(false)
	elseif self.m_typeHistoryRadiobutton:isChecked() then
		self:onTypeHistoryChecked(true)
		self:onTypePropsChecked(false)
		self:onTypeGoodsChecked(false)
	end
end

function StoreScene:onTypeGoodsChecked(status)
	local typeGoodsImage = self:getUI("typeGoodsImage")
	if status then
		typeGoodsImage:setFile(kImageMap.store_koin_down)
		self:setGoodsTypeId(GoodsTypeIds.goods)
		self:onShowGoodsView()
	else
		typeGoodsImage:setFile(kImageMap.store_koin_up)
	end
end

function StoreScene:onTypePropsChecked(status)
	local typePropsImage = self:getUI("typePropsImage")
	if status then
		typePropsImage:setFile(kImageMap.store_koin_down)
		self:setGoodsTypeId(GoodsTypeIds.prop)
		self:onShowPropView()
	else
		typePropsImage:setFile(kImageMap.store_koin_up)
	end
end

function StoreScene:onTypeHistoryChecked(status)
	local typeHistoryImage = self:getUI("typeHistoryImage")
	if status then
		typeHistoryImage:setFile(kImageMap.store_koin_down)
		self:setGoodsTypeId(GoodsTypeIds.history)
		self:onShowHistoryView()
	else
		typeHistoryImage:setFile(kImageMap.store_koin_up)
	end
end

function StoreScene:onShowLoading(status)	
	if status then
		Log.printInfo("StoreScene","onShowLoading true")
		self.m_loadingAnim:onLoadingStart()
	else
		Log.printInfo("StoreScene","onShowLoading false")
		self.m_loadingAnim:onLoadingRelease()
	end
end

function StoreScene:onShowGoodsView()
	Log.printInfo("StoreScene","onShowGoodsView")
	if self:getGoodsTypeId() == GoodsTypeIds.goods then
		self.m_payTypeListView:setVisible(true)
		self.m_goodsListView:setVisible(true)
		self.m_propTypeListView:setVisible(false)
		self.m_propListView:setVisible(false)
		self.m_historyView:setVisible(false)
		self.m_salerImage:setVisible(false)
		self:onShowLoading(true)
		self:requestCtrlCmd("loadChipProductList", self:getPayId())
	else
		-- TO DO 
	end
end

function StoreScene:onShowPropView()
	Log.printInfo("StoreScene","onShowPropView")
	if self:getGoodsTypeId() == GoodsTypeIds.prop then
		self.m_propTypeListView:setVisible(true)
		self.m_propListView:setVisible(false)
		self.m_payTypeListView:setVisible(false)
		self.m_goodsListView:setVisible(false)
		self.m_historyView:setVisible(false)
		self.m_salerImage:setVisible(false)
		self:onShowLoading(true)
		self:requestCtrlCmd("loadPropProductList", self:getPropId())
	else
		-- TO DO 
	end
end

function StoreScene:onShowHistoryView()
	Log.printInfo("StoreScene","onShowHistoryView")
	if self:getGoodsTypeId() == GoodsTypeIds.history then
		self.m_salerImage:setVisible(true)
		self.m_historyView:setVisible(true)
		self.m_payTypeListView:setVisible(false)
		self.m_goodsListView:setVisible(false)
		self.m_propTypeListView:setVisible(false)
		self.m_propListView:setVisible(false)
		self:requestCtrlCmd("loadHistoryList")
	else
		-- TO DO 
	end
end

function StoreScene:onShowNoDataTip(status, str)
    self.m_noDataTipLabel:setVisible(status)
    if str then
        self.m_noDataTipLabel:setText(str)
    end
end

-- payType 支付类型改变
function StoreScene:onPayTypeChangeClick(payId)
	Log.printInfo("StoreScene","onPayTypeChangeClick payId is " .. payId)
	self:setPayId(payId)
	self:onShowLoading(true)
	self:requestCtrlCmd("loadChipProductList", payId)
end

-- prop 道具类型改变
function StoreScene:onPropTypeChangeClick(propId)
	Log.printInfo("StoreScene","onPropTypeChangeClick propId is " .. propId)
	self:setPropId(propId)
	self:onShowLoading(true)
    self.m_propListView:setVisible(false)
	self:requestCtrlCmd("loadPropProductList", propId)
end

-------------------------------- handle function --------------------------

-- 更新支付类型列表
function StoreScene:onUpdatePayTypeList(data)
	Log.printInfo("StoreScene","onUpdatePayTypeList")
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
function StoreScene:onUpdateGoodsList(paytype)
	Log.printInfo("StoreScene","onUpdateGoodsList")
	self:onShowLoading(false)
	local data = self.m_baseData:getGoodsData(paytype.id)
	if not data or #data < 1 then
		self:onShowNoDataTip(true, bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"))
		return
	end
	self:onShowNoDataTip(false)
	if paytype.id == self:getPayId() then
	    local adapter = new(CacheAdapter, StoreGoodsItemLayer, data)
		self.m_goodsListView:setAdapter(adapter)
    end
end

-- 更新道具类型列表
function StoreScene:onUpdatePropTypeList(data)
	Log.printInfo("StoreScene","onUpdatePropTypeList")
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
    self:setPropId(id)

    -- 加载第一个类型的道具列表
    self:onShowLoading(true)
    self:requestCtrlCmd("loadPropProductList", id)
end

-- 更新道具列表
function StoreScene:onUpdatePropList(data)
	Log.printInfo("StoreScene","onShowPropList")
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

-- 更新购买历史列表
function StoreScene:onUpdateHistoryList(data)
	Log.printInfo("StoreScene","onShowPropList")
	self:onShowLoading(false)
	if not data or #data < 1 then
		self:onShowNoDataTip(true, bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
		return
	end
	self:onShowNoDataTip(false)
	local adapter = new(CacheAdapter, StoreHistoryItemLayer, data)
	self.m_historyListView:setAdapter(adapter)
end

function StoreScene:onGotoTab(index)
	Log.printInfo("StoreScene","onGotoTab")
	if index == 1 then
		self.m_typeGoodsRadiobutton:setChecked(true)

	elseif index == 2 then
		self.m_typePropsRadiobutton:setChecked(true)
	elseif index == 3 then
		self.m_typeHistoryRadiobutton:setChecked(true)
	end
	self:onGoodsTypeGroupChangeClick()
end

-------------------------------- UI function -----------------------------

function StoreScene:onCloseButtonClick()
	Log.printInfo("StoreScene","onCloseButtonClick")
	self:requestCtrlCmd("back")
end

-------------------------------- table config -----------------------------

-- Provide cmd handle to call
StoreScene.s_cmdHandleEx = 
{
    --["***"] = function
    ["updateGoodsTypeList"] = StoreScene.onUpdateGoodsTypeList,
    ["updatePayTypeList"] = StoreScene.onUpdatePayTypeList,
    ["updateGoodsList"] = StoreScene.onUpdateGoodsList,
    ["updatePropTypeList"] = StoreScene.onUpdatePropTypeList,
    ["updatePropList"] = StoreScene.onUpdatePropList,
    ["updateHistoryList"] = StoreScene.onUpdateHistoryList,
    ["showNoDataTip"] = StoreScene.onShowNoDataTip,
    ["gotoTab"] = StoreScene.onGotoTab,
}

return StoreScene