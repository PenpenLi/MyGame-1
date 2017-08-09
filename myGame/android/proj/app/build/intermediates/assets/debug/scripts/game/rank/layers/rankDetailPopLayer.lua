-- rankDetailPopLayer.lua
-- Last modification : 2016-06-20
-- Description: a pay popup layer in rank moudle

local PopupModel = import('game.popup.popupModel')
local RankDetailPopLayer = class(PopupModel)
local view = require(VIEW_PATH .. "rank.rank_tip_pop_layer")
local varConfigPath = VIEW_PATH .. "rank.rank_tip_pop_layer_layout_var"
local CacheHelper = require("game.cache.cache")
local LoadingAnim = require("game.anim.loadingAnim")

-------------------------------- single function --------------------------

function RankDetailPopLayer.show(data)  
    PopupModel.show(RankDetailPopLayer, view, varConfigPath, {name="RankDetailPopLayer"}, data, true) 
end

function RankDetailPopLayer.hide()
    PopupModel.hide(RankDetailPopLayer)
end

-------------------------------- base function --------------------------

function RankDetailPopLayer:ctor(viewConfig, varConfigPath, data)
	Log.printInfo("RankDetailPopLayer.ctor");
    self:addShadowLayer()
    self.m_data = data

    -- 标题label
    local titleLabel = self:getUI("titleLabel")
    titleLabel:setText(bm.LangUtil.getText("RANKING", "DETAIL"))

    -- 马上玩牌label
    local playBtnLabel = self:getUI("playBtnLabel")
    playBtnLabel:setText(bm.LangUtil.getText("RANKING", "IM_PLAY_RANK"))

    -- 内容label
    -- self.m_tipContentLabel = self:getUI("tipContentLabel")
    

    -- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self:getUI("bg")) 

    self:requestData()
end 

function RankDetailPopLayer:dtor()
	Log.printInfo("RankDetailPopLayer.dtor");
end

function RankDetailPopLayer:requestData()
    local url = nk.userData.RANKREWARD_JSON
    if not url then
        return
    end
    self:onShowLoading(true)
    local cacheHelper = new(CacheHelper)
    cacheHelper:cacheFile(url, handler(self, function(obj, result, content)
            self:onShowLoading(false)
            if result then
                if self.m_tipContentLabel then
                    self.m_tipContentLabel:removeFromParent(true)
                    self.m_tipContentLabel = nil
                end
                self.m_tipContentLabel = new(RichText, bm.LangUtil.getText("RANKING", "DETAIL_CONTENT", self.m_data or 60, content.AWARD_NUM or "N"), 522, 214, kAlignLeft, "", 20, 255, 255, 255, true, 0)
                self.m_tipContentLabel:setAlign(kAlignTop)
                self.m_tipContentLabel:setPos(0, 100)
                self.m_tipContentLabel:addTo(self:getUI("bg"))
            end
        end), "rankRule", "tip")
end

function RankDetailPopLayer:onShowLoading(status)   
    if status then
        Log.printInfo("RankDetailPopLayer","onShowLoading true")
        self.m_loadingAnim:onLoadingStart()
    else
        Log.printInfo("RankDetailPopLayer","onShowLoading false")
        self.m_loadingAnim:onLoadingRelease()
    end
end

-------------------------------- UI function --------------------------

function RankDetailPopLayer:onCloseButtonClick()
    RankDetailPopLayer.hide()
end

function RankDetailPopLayer:onPlayButtonClick()
    EnterRoomManager.getInstance():enterGapleRoom()
    RankDetailPopLayer.hide()
end

-------------------------------- table config ------------------------

return RankDetailPopLayer