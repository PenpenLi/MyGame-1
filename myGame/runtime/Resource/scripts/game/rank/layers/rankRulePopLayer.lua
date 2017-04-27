-- rankRulePopLayer.lua
-- Last modification : 2016-06-20
-- Description: a pay popup layer in rank moudle

local PopupModel = import('game.popup.popupModel')
local RankRulePopLayer = class(PopupModel)
local rankRuleView = require(VIEW_PATH .. "rank.rank_rule_pop_layer")
local varConfigPath = VIEW_PATH .. "rank.rank_rule_pop_layer_layout_var"
local RankRulePopItemLayer = require("game.rank.layers.rankRulePopItemLayer")
local CacheHelper = require("game.cache.cache")
local LoadingAnim = require("game.anim.loadingAnim")

-- 更新规则列表
local update_rule_scroll

-------------------------------- single function --------------------------

function RankRulePopLayer.show()  
    PopupModel.show(RankRulePopLayer, rankRuleView, varConfigPath, {name="RankRulePopLayer"}, nil, true) 
end

function RankRulePopLayer.hide()
    PopupModel.hide(RankRulePopLayer)
end

-------------------------------- base function --------------------------

function RankRulePopLayer:ctor(viewConfig)
	Log.printInfo("RankRulePopLayer.ctor");

    -- 标记字段
    -- tab index
    self.m_tabIndex = 1
    self.m_isGetData_ing = false
    -- 是否已经创建award
    self.m_isAwardCreate = false
    -- 是否已经创建rule
    self.m_isRuleCreate = false
    -- 标记字段end

    -- 每日牌局榜label
    self.m_titleAwardLabel = self:getUI("titleAwardLabel")
    -- 规则label
    self.m_titleRuleLabel = self:getUI("titleRuleLabel")
    -- 关闭btn
    self.m_closeButton = self:getUI("closeButton")

    local titleGroup = self:getUI("radioButtonGroup")
    titleGroup:setOnChange(self,self.onTitleGroupChangeClick);

    self.m_awardRadiobutton = self:getControl(self.s_controls["awardRadiobutton"])
    self.m_awardRadiobutton:setChecked(true)

    self.m_ruleRadiobutton = self:getControl(self.s_controls["ruleRadiobutton"])

    self.m_titleAwardLabel = self:getUI("titleAwardLabel")
    self.m_titleRuleLabel = self:getUI("titleRuleLabel")
    self.m_titleAwardLabel:setText(bm.LangUtil.getText("RANKING", "MAIN_TAB_TEXT")[1] or "RANKING")
    self.m_titleRuleLabel:setText(bm.LangUtil.getText("RANKING", "RULE_TAB_TEXT")[2] or "Peraturan")


    self.m_contentRankLabel = self:getUI("contentRankLabel")
    self.m_contentAwardLabel = self:getUI("contentAwardLabel")
	-- 奖励listview
	self.m_awardListView = self:getUI("awardListView")
    -- 规则scrollview
    self.m_ruleScrollView = self:getUI("ruleScrollView")
    -- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self:getUI("comtentBg")) 

    self:requestData()
    self:addShadowLayer()
end 

function RankRulePopLayer:dtor()
	Log.printInfo("RankRulePopLayer.dtor");
end

-- tab 的改变监听
function RankRulePopLayer:onTitleGroupChangeClick()
    Log.printInfo("RankRulePopLayer", "onTitleGroupChangeClick")
    if self.m_awardRadiobutton:isChecked() then
        self.m_tabIndex = 1
        self:showAwardView()
    elseif self.m_ruleRadiobutton:isChecked() then
        self.m_tabIndex = 2
        self:showRuleView()
    end
end

function RankRulePopLayer:showAwardView()
    self.m_awardListView:setVisible(true)
    self.m_contentRankLabel:setVisible(true)
    self.m_contentAwardLabel:setVisible(true)
    self.m_ruleScrollView:setVisible(false)
    self:setData()
end

function RankRulePopLayer:showRuleView()
    self.m_ruleScrollView:setVisible(true)
    self.m_awardListView:setVisible(false)
    self.m_contentRankLabel:setVisible(false)
    self.m_contentAwardLabel:setVisible(false)
    self:setData()
end

function RankRulePopLayer:requestData()
    if self.m_isGetData_ing then
        return
    end
    if self.m_datas then
        return
    end
    self.m_isGetData_ing = true
    local url = nk.userData.RANKREWARD_JSON
    if not url then
        return
    end
    self:onShowLoading(true)
    local cacheHelper = new(CacheHelper)
    cacheHelper:cacheFile(url, handler(self, function(obj, result, content)
            self:onShowLoading(false)
            self.m_isGetData_ing = false
            if result then
                self.m_datas = content
                self:setData()
            end
        end), "rankRule", "data")
end

function RankRulePopLayer:setData()
    if not self.m_datas then
        self:requestData()
        return
    end
    if self.m_tabIndex == 1 then
        if self.m_datas.AWARD then
            if self.m_isAwardCreate then
                return
            end
            for i, v in ipairs(self.m_datas.AWARD) do
                v.index_ = i
            end
            local adapter = new(CacheAdapter, RankRulePopItemLayer, self.m_datas.AWARD)
            self.m_awardListView:setAdapter(adapter)
            self.m_isAwardCreate = true
        end
    elseif self.m_tabIndex == 2 then
        if self.m_datas.RULE then
            if self.m_isRuleCreate then
                return
            end
            update_rule_scroll(self.m_ruleScrollView, self.m_datas.RULE)
            self.m_isRuleCreate = true
        end
    end
end

function RankRulePopLayer:onShowLoading(status)   
    if status then
        Log.printInfo("RankRulePopLayer","onShowLoading true")
        self.m_loadingAnim:onLoadingStart()
    else
        Log.printInfo("RankRulePopLayer","onShowLoading false")
        self.m_loadingAnim:onLoadingRelease()
    end
end

-------------------------------- UI function --------------------------

function RankRulePopLayer:onCloseButtonClick()
    RankRulePopLayer.hide();
end

-------------------------------- table config ------------------------

update_rule_scroll = function(content, data)
    -- data.title
    -- data.content
    local currentH = 0
    for i, v in ipairs(data) do
        local item = new(Node)
        item:setFillParent(true)
        item.m_data = v
        item.m_title = new(TextView, item.m_data.title, 650, nil, kAlignLeftTop, nil, 22, 246, 183, 1)
        item.m_title:setPos(20, currentH + 20)
        item:addChild(item.m_title)
        local _, h = item.m_title:getSize()
        currentH = currentH + h + 20

        item.m_content = new(TextView, item.m_data.content, 650, nil, kAlignLeftTop, nil, 22, 221, 208, 248)
        item.m_content:setPos(20, currentH + 8)
        item:addChild(item.m_content)
        local _, h = item.m_content:getSize()
        currentH = currentH + h + 8
        content:addChild(item)
    end
end

return RankRulePopLayer