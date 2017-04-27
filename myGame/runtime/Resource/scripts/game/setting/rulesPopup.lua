-- loginScene.lua
-- Last modification : 2016-06-01
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local rulesView = require(VIEW_PATH .. "setting/setting_rules")
local rulesInfo = VIEW_PATH .. "setting.setting_rules_layout_var"
local ListViewEx = require("game/uiex/listView/listViewEx")
local ListItem = require("game/uiex/listView/listItem")
local RuleListItem = require("game/setting/ruleListItem")
local LevelListItem = require("game/setting/levelListItem")
local RulesPopup= class(PopupModel);

RulesPopup.RULE             = 1
RulesPopup.RULE_QIUQIU      = 2
RulesPopup.LEVEL            = 3


function RulesPopup.show(data)
	PopupModel.show(RulesPopup, rulesView, rulesInfo, {name="RulesPopup"}, data)
end

function RulesPopup.hide()
	PopupModel.hide(RulesPopup)
end

function RulesPopup:ctor(viewConfig,varConfig,data)
	Log.printInfo("RulesPopup.ctor");
    self:addShadowLayer()
    self.goto_ = data
    self.curPageIdx_ = self.goto_ or RulesPopup.RULE 
    self:initLayer()
    self:onTabChange(self.goto_ or RulesPopup.RULE)
end 

function RulesPopup:initLayer()
     self:initWidget()
end

function RulesPopup:initWidget()

    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)
    self.radio_bt_group_ = self:getUI("RadioButtonGroup")
    self.radio_bt_group_:setOnChange(self,self.radio_bt_click)
    self.radio_bt_group_:setSelected(self.goto_ or RulesPopup.RULE )

    self.text_rule = self:getUI("Text_l")
    self.text_rule99 = self:getUI("Text_m")
    self.text_level = self:getUI("Text_r")
    local tab = bm.LangUtil.getText("HELP", "SUB_TAB_TEXT")
    self.text_rule:setText(tab[3])
    self.text_rule99:setText(tab[4])
    self.text_level:setText(tab[5])
      
    self.listview_rule_ = new(ListViewEx,{x = 0,y =0,w= 660,h = 400},ListItem)
    self.listview_rule_:setPos(26,95)
    self.image_bg_:addChild(self.listview_rule_)

    self.listview_rule99_ = new(ListViewEx,{x = 0,y =0,w= 660,h = 400},RuleListItem)
    self.listview_rule99_:setPos(26,95)
    self.image_bg_:addChild(self.listview_rule99_)

    self.listview_level_ = new(ListViewEx,{x = 0,y =0,w= 660,h = 400},LevelListItem)
    self.listview_level_:setPos(26,95)
    self.image_bg_:addChild(self.listview_level_)   
   
end

function RulesPopup:radio_bt_click(index)
    self.curPageIdx_ = index
    self:onTabChange(index)
end

function RulesPopup:onTabChange(selectedTab)
    print("rules view selectedTab:"..selectedTab)
    if selectedTab == RulesPopup.RULE and not self.ruleListViewInit_ then
        --基本规则列表
        -- self.ruleListViewInit_ = true
        self:setListData()
    elseif selectedTab == RulesPopup.RULE_QIUQIU and not self.rule99ListViewInit_ then
        --99规则列表
        -- self.rule99ListViewInit_ = true
        self:setListData()
    elseif selectedTab == RulesPopup.LEVEL and not self.levelListViewInit_ then
        --等级说明列表
        -- self.levelListViewInit_ = true
        self:setListData()
    end

    self:showTable(selectedTab)
end

function RulesPopup:setListData()
    self:setLoading(true)
    local doSetDataFunc = function()
        self.isLoaded  = true
        if self.anim_frame_ then 
            delete(self.anim_frame_) 
            self.anim_frame_ = nil
        end
        if self.curPageIdx_ == RulesPopup.RULE then  
            self:setRuleListData()        
        elseif self.curPageIdx_ == RulesPopup.RULE_QIUQIU then
            self:set99RuleListData()   
        else
            self:setLevelListData()   
        end
        self:setLoading(false)
    end
    if not self.isLoaded then
        -- if self.anim_frame_ then 
        --     delete(self.anim_frame_) 
        --     self.anim_frame_ = nil
        -- end
        -- self.anim_frame_ = new(AnimInt,kAnimNormal,0,1,100,-1)
        -- self.anim_frame_:setEvent(self, doSetDataFunc)
        doSetDataFunc()
    else
        doSetDataFunc()
    end
end

function RulesPopup:setLoading(isLoading)
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

function RulesPopup:setRuleListData()
    self.ruleListViewInit_ = true
    local data = bm.LangUtil.getText("HELP", "RULE")
    self.listview_rule_:setData(data)
end

function RulesPopup:set99RuleListData()
    self.rule99ListViewInit_ = true
    local data = bm.LangUtil.getText("HELP", "RULE_QIUQIU")
    self.listview_rule99_:setData(data)
end

function RulesPopup:setLevelListData()
    self.levelListViewInit_ = true
    local data = bm.LangUtil.getText("HELP", "LEVEL")
    local expData = nk.Level:getExpConfigData()
    if expData then
        data[1] = {T("经验计算公式"),{{T("场次"),T("底筹"), T("弃牌和输"), T("赢")}}}
        table.insertto(data[1][2], expData)
    end

    local levelData = nk.Level:getLevelConfigData()   
    if levelData then
        data[2] = {T("升级奖励"),{{"LV", T("称号"), T("所有EXP"), T("升级奖励")}}}
        table.insertto(data[2][2], levelData)        
    end
    self.listview_level_:setData(data)
end

function RulesPopup:showTable(selectedTab)
    if self.listview_rule_ then self.listview_rule_:setVisible(selectedTab == RulesPopup.RULE) end
    if self.listview_rule99_ then self.listview_rule99_:setVisible(selectedTab == RulesPopup.RULE_QIUQIU) end
    if self.listview_level_ then self.listview_level_:setVisible( selectedTab == RulesPopup.LEVEL) end

    --(selectedTab == RulesPopup.RULE) and self.text_rule:setColor(255,255,255) or self.text_rule:setColor(199,127,241)
end

function RulesPopup:dtor()
    Log.printInfo("RulesPopup.dtor");
    if self.anim_frame_ then 
        delete(self.anim_frame_) 
        self.anim_frame_ = nil
    end
end 


return RulesPopup