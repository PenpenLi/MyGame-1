-- StoreHistoryPopup.lua
-- Date : 2016-10-31
local PopupModel = import('game.popup.popupModel')
local StoreHistoryView = require(VIEW_PATH .. "store/store_history_layer")
local StoreHistoryInfo = VIEW_PATH .. "store/store_history_layer_layout_var"
local StoreHistoryItemLayer = require("game.store.layers.storeHistoryItemLayer")
local HistoryManager = require("game.store.history.historyManager")
local StoreHistoryPopup= class(PopupModel);

function StoreHistoryPopup.show(data)
	PopupModel.show(StoreHistoryPopup, StoreHistoryView, StoreHistoryInfo, {name="StoreHistoryPopup"}, data)
end

function StoreHistoryPopup.hide()
	PopupModel.hide(StoreHistoryPopup)
end

function StoreHistoryPopup:ctor(viewConfig)
	Log.printInfo("StoreHistoryPopup.ctor");

    self:initLayer()

    self.m_historyManager = HistoryManager.getInstance()
    self:setLoading(true)
    self.m_historyManager:loadHistory(handler(self, self.loadHistoryListResult))
    
end 

function StoreHistoryPopup:initLayer()
    self.bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.bg_)
    self:getUI("Text_title"):setText(bm.LangUtil.getText("STORE", "TITLE_HISTORY"))
    self.listview_history_ = self:getUI("ListView_history") 
    self.text_noData_ = self:getUI("Text_noData")
    self.text_noData_:setVisible(false)
end

function StoreHistoryPopup:loadHistoryListResult(status, data)
    self:setLoading(false)
    if status then
        Log.printInfo("StoreHistoryPopup","loadHistoryListResult")
        if not data or #data < 1 then
            self:onShowNoDataTip(true, bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
            return
        end
        self:onShowNoDataTip(false)
        local adapter = new(CacheAdapter, StoreHistoryItemLayer, data)
        self.listview_history_:setAdapter(adapter)
    end
end

function StoreHistoryPopup:onShowNoDataTip(status, str)
    self.text_noData_:setVisible(status)
    if str then
        self.text_noData_:setText(str)
    end
end

function StoreHistoryPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function StoreHistoryPopup:dtor()
    Log.printInfo("StoreHistoryPopup.dtor")
    self:setLoading(false)
    self.m_historyManager:autoDispose()
end 


return StoreHistoryPopup