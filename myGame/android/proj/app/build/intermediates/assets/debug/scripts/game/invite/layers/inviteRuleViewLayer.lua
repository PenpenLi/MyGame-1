-- inviteRuleViewLayer.lua
-- Create Date : 2016-07-08
-- Last modification : 2016-07-08
-- Description: a people item layer in invite moudle

local InviteRuleViewLayer = class(GameBaseLayer, false)
local view = require(VIEW_PATH .. "invite.invite_rule_view_layer")
local varConfigPath = VIEW_PATH .. "invite.invite_rule_view_layer_layout_var"
local InviteAwardItemLayer = require("game.invite.layers.inviteAwardItemLayer")
local LoadingAnim = require("game.anim.loadingAnim")
local CacheHelper = require("game.cache.cache")

function InviteRuleViewLayer:ctor()
	Log.printInfo("InviteRuleViewLayer", "ctor")
    super(self, view, varConfigPath)
    self:setSize(self.m_root:getSize())

    -----------
    -- 标记字段
    -----------

    -- 正在加载规则数据
    self.m_isGetRuleData_ing = false
    self.m_isGetRuleData_ed = false
    -----------
    -- 标记字段 end
    -----------

    -- bgView
    self.m_bgView = self:getUI("bgView")
    -- contentView
    self.m_contentView = self:getUI("contentView")
    -- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self.m_bgView)
end 

function InviteRuleViewLayer:dtor()
	Log.printInfo("InviteRuleViewLayer", "dtor")
end

function InviteRuleViewLayer:onShow()
	Log.printInfo("InviteFriendViewLayer", "onShow");
	if self.m_isGetRuleData_ed or self.m_isGetRuleData_ing then
		return 
	end
	self:getRuleData()
end

-- 获取对应天数的奖励数据
function InviteRuleViewLayer:getRuleData()
	Log.printInfo("InviteRuleViewLayer", "getRuleData ")
	if nk.userData.INVITE_RULE_JSON then
		self.m_isGetRuleData_ing = true
		self:onShowLoading(true)
		local cacheHelper = new(CacheHelper)
	    cacheHelper:cacheFile(nk.userData.INVITE_RULE_JSON, handler(self, function(obj, result, content)
	            self.m_isGetRuleData_ing = false
	            self:onShowLoading(false)
	            if result then
	                self.m_isGetRuleData_ed = true
                    self:createContent(content)
	            else
	                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
	            end
	        end), "inviteRule", "data")
	end
end

function InviteRuleViewLayer:createContent(data)
	if data then
		self.m_contentView:removeAllChildren(true)
		self.m_contentH = 10
		for i, v in ipairs(data) do
			if v.text then
				local contentText = new(TextView, v.text, 615, nil, kAlignTopLeft, nil, 18, 255, 255, 255)
				contentText:setPos(10, self.m_contentH)
				self.m_contentView:addChild(contentText)
				local _, h = contentText:getSize()
				self.m_contentH = self.m_contentH + h + 10
			end
			if v.data and not table_is_empty(v.data) then
				local dataNode = new(Node)
                dataNode:setPos(nil, self.m_contentH)
				local iconNodeList = {}
				local bg = new(Image, kImageMap.invite_top_bg)               
				bg:setFillParent(true, true)
				dataNode:addChild(bg)
				local line = new(Image, kImageMap.invite_line)
				line:setAlign(kAlignCenter)
               -- line:setPos(0,-20)
				dataNode:addChild(line)
				local iconNodeW, iconNodeH
				for k, t in ipairs(v.data) do
					local icon = new(Image, kImageMap.invite_box)
                    UrlImage.spriteSetUrl(icon, v.imgUrl)
					iconNodeW, iconNodeH = icon:getSize()
					local text1 = new(Text, t[1] .. " " .. v.name, 30, 30, kAlignCenter, nil, 14, 255, 255, 255)
                    if k == #v.data then
                        text1:setAlign(kAlignTopRight)
                    else
                        text1:setAlign(kAlignTop)
                    end					
					text1:setPos(nil, -20)
					icon:addChild(text1)
					local text2 = new(Text, t[2], 30, 30, kAlignCenter, nil, 14, 255, 255, 255)
                    if k == #v.data then
                        text2:setAlign(kAlignBottomRight)
                    else
                        text2:setAlign(kAlignBottom)
                    end	
					text2:setPos(nil, -20)
					icon:addChild(text2)
                    icon:addTo(dataNode)
					table.insert(iconNodeList, icon)
                    
                    local totalNum = #iconNodeList
                    local gap = 615/(totalNum-1)
                    local currentX = 0
                    table.foreach(iconNodeList, function(i, v)
                            if i == #iconNodeList then
                                 currentX = -10
                            end
                            v:setPos(currentX + (i-1)*gap, 20)
                        end)

				end
				dataNode:setSize(677, iconNodeH + 50)
                self.m_contentH = self.m_contentH + iconNodeH + 60
                dataNode:addTo(self.m_contentView)
			end
		end
	end
end

function InviteRuleViewLayer:onShowLoading(status)	
	if status then
		Log.printInfo("InviteRuleViewLayer","onShowLoading true")
		self.m_loadingAnim:onLoadingStart()
	else
		Log.printInfo("InviteRuleViewLayer","onShowLoading false")
		self.m_loadingAnim:onLoadingRelease()
	end
end

return InviteRuleViewLayer