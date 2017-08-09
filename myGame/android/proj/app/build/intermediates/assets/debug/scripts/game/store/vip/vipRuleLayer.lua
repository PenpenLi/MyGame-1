-- vipRulePopLayer.lua
-- Last modification : 2016-11-08
-- Description: a pay popup layer in vip moudle

local PopupModel = import('game.popup.popupModel')
local VipRulePopLayer = class(PopupModel)
local vipRuleView = require(VIEW_PATH .. "store.store_vip_rule")
local varConfigPath = VIEW_PATH .. "store.store_vip_rule_layout_var"
local VipRulePopItemLayer = require("game.store.vip.vipRulePopItemLayer")

-------------------------------- single function --------------------------

function VipRulePopLayer.show()  
    PopupModel.show(VipRulePopLayer, vipRuleView, varConfigPath, {name="VipRulePopLayer"}, nil, true) 
end

function VipRulePopLayer.hide()
    PopupModel.hide(VipRulePopLayer)
end

-------------------------------- base function --------------------------

function VipRulePopLayer:ctor(viewConfig)
	Log.printInfo("VipRulePopLayer.ctor");
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)
    self.m_vipListView = self:getUI("ListView_vip")

    self.radio_bt_group_ = self:getUI("RadioButtonGroup")
    self.radio_bt_group_:setOnChange(self,self.radio_bt_click) 
    self.text_l_ = self:getUI("Text_l")
    self.text_l_:setText(bm.LangUtil.getText("USERINFO","KEY_VIP_LV"))
    self.text_r_ = self:getUI("Text_r")
    self.text_r_:setText(bm.LangUtil.getText("FRIEND","MAIN_TAB_TEXT")[3])
    self.radio_bt_group_:setSelected(1)

    self.view_level_ = self:getUI("View_vip_level")
    self.view_rule_ = self:getUI("View_vip_rule")

    self.textView_rule_ = self:getUI("TextView_rule")

    self.currTab_ = 1  
end 

function VipRulePopLayer:onShow()
    self:onTabChange(self.currTab_)  
end

function VipRulePopLayer:radio_bt_click(index)
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self.currTab_ = index
    self:onTabChange(index)
end

function VipRulePopLayer:onTabChange(index)
    if index == 1 and not self.dayListViewInit_ then
        self.dayListViewInit_ = true
        self:setLevelData()
    elseif index == 2 and not self.growListViewInit_ then
        self.growListViewInit_ = true
        self:setRuleData()
    end

    self:showListview(index)
end

function VipRulePopLayer:showListview(index)
   if index == 1 then
      self.view_level_:setVisible(true)
      self.view_rule_:setVisible(false)
      self.text_l_:setColor(255,255,255)
      self.text_r_:setColor(199,127,241)
   else
      self.view_level_:setVisible(false)
      self.view_rule_:setVisible(true)
      self.text_l_:setColor(199,127,241)
      self.text_r_:setColor(255,255,255)
   end
end

function VipRulePopLayer:setLevelData()
    self:setLoading(true)
    nk.vipController:loadConfig(nk.userData.VIP_JSON, function(result, data)
        self:setLoading(false)
    	if result and data then
            local key_table  = {}
            local show_table = {}
            for key,_ in pairs(data) do
            	table.insert(key_table, key)
            end

            table.sort(key_table)
            for i,key in pairs(key_table) do
                local vipContent = {}
                vipContent.index_ = i
                vipContent.vip = key
                vipContent.describe = nk.updateFunctions.formatBigNumber(tonumber(data[key].data.score))
                table.insert(show_table, vipContent)
            end
            
            local adapter = new(CacheAdapter, VipRulePopItemLayer, show_table)
            self.m_vipListView:setAdapter(adapter)
    	end
    end)
end

function VipRulePopLayer:setRuleData()
    self:setLoading(true)
    nk.vipController:loadConfig(nk.userData.VIP_JSON, function(result, data)
        self:setLoading(false)
    	if result and data then
            if not data["1"] or not data["1"].data then return end
            local ruleInfo = data["1"].data.vipRule  --php≈‰÷√‘⁄‘™Àÿ°∞1°±
            self.textView_rule_:setText(ruleInfo)            
    	end
    end)
end

function VipRulePopLayer:setLoading(isLoading)
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

function VipRulePopLayer:dtor()
    self:setLoading(fasle)
	Log.printInfo("VipRulePopLayer.dtor");
end

return VipRulePopLayer