local PersonalRecentExpView = class(ScrollView)
local ExpItem = require("game.userInfo.roomUserinfo.expItem")
local PropManager = require("game.store.prop.propManager")

function PersonalRecentExpView:ctor(x, y, w, h, auto, popup)
    self.popup = popup
	self:initView()
end

function PersonalRecentExpView:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.PROP_INFO_CHANGED, self, self.refreshVipExpView)
end

function PersonalRecentExpView:initView()
    local textTip = new(Text, bm.LangUtil.getText("USERINFO","NO_PROP"), 0, 0, kAlignCenter, nil, 20, 255, 255, 255)
    textTip:addTo(self)
    local widthOfText = textTip:getSize()
    textTip:setPos(564 * 0.5 - widthOfText * 0.5, 200 * 0.5)
    self.textTip = textTip

    local roomId = tostring(self.popup.ctx.model.roomInfo.roomType) 
    local roomCostConf = self.popup.ctx.model.roomCostConf
    if roomCostConf ~= nil and roomCostConf[roomId] and roomCostConf[roomId][2] ~= nil then
        self.expCost = roomCostConf[roomId][2]
    end

    PropManager.getInstance():requestUserPropList(handler(self, self.loadUseExp))
    EventDispatcher.getInstance():register(EventConstants.PROP_INFO_CHANGED, self, self.refreshVipExpView)
end

function PersonalRecentExpView:refreshVipExpView()
    if self.vipExpViews then
        local hasExpProp = PropManager.getInstance():isPropValid(PropManager.ID_MONKEY_EXP)
        local isVip = nk.userData.vip and tonumber(nk.userData.vip) > 0
        for k, item in ipairs(self.vipExpViews) do
            if isVip or hasExpProp then
                item:setColor(255,255,255)
            else
                item:setColor(128,128,128)
            end
        end
    end
end

function PersonalRecentExpView:loadUseExp()
    if tolua.isnull(self) then return end
	self.m_space_v = 5
    self.m_space_h = 5
    local x, y = 0, 0
    local commonExp = nk.CommonExpManage.getCommonExp()
    if commonExp and type(commonExp) == "table" and #commonExp > 0 then
        -- local theExp = nil
        -- for k, v in ipairs(commonExp) do
        --     theExp = v
        -- end
        -- commonExp = {}
        -- for i = 1, 20 do
        --     table.insert(commonExp, theExp)
        -- end
        local COL_NUM = 5
        local item_w, item_h 
        local scale = 0.9
        local isVip = nk.userData.vip and tonumber(nk.userData.vip) > 0
        local hasExpProp = PropManager.getInstance():isPropValid(PropManager.ID_MONKEY_EXP)
        for i, exp in ipairs(commonExp) do
            if i <= nk.CommonExpManage.MAX_NUM then
                local item = new(ExpItem, exp)
                item:setDelegate(self, self.onExpItemCallback)
                item_w, item_h = item:getSize()
                item:addPropScaleSolid(0, scale, scale, kCenterDrawing)
                item_w, item_h = item_w * scale, item_h * scale
                
                x = ((i + COL_NUM - 1) % COL_NUM ) * (item_w + self.m_space_h)  + self.m_space_h
                y = math.floor( ( i - 1 ) / COL_NUM ) * (item_h +  self.m_space_v) + self.m_space_v
                
                item:setPos(x, y)
                self:addChild(item)

                local expId = tonumber(exp.expId or 0)
                if expId/100>=2 and expId/100<3 then
                    self.vipExpViews = self.vipExpViews or {}
                    if isVip or hasExpProp then
                        item:setColor(255,255,255)
                    else
                        item:setColor(128,128,128)
                    end
                    table.insert(self.vipExpViews, item)
                end
            end
        end
        local rowCount = math.ceil(math.min(#commonExp, nk.CommonExpManage.MAX_NUM) / COL_NUM)
        self.m_nodeH = (item_h + self.m_space_v) * rowCount + self.m_space_v
        self.textTip:setVisible(false)
    else
        self.textTip:setVisible(true)
    end
end

function PersonalRecentExpView:onExpItemCallback(expId)
    expId = checkint(expId)
    if self.popup.ctx.model:isSelfInSeat() then
        if expId / 100 < 1 then
            nk.SocketController:sendExpression(1, expId)
        elseif expId/100>=2 and expId/100<3 then
            local isVip = nk.userData.vip and tonumber(nk.userData.vip) > 0
            local hasExpProp = PropManager.getInstance():isPropValid(PropManager.ID_MONKEY_EXP)
            if isVip or hasExpProp then
                nk.SocketController:sendExpression(1, expId)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_NOTVIP_TIPS"))
            end
        else
            if self.expCost ~= 0 then
                nk.SocketController:sendRoomCostProp(self.expCost, 1, expId, 0)
            else
                nk.SocketController:sendExpression(1, expId)
            end
        end
        nk.AnalyticsManager:report("New_Gaple_selfInfo_face", "selfInfo")
        self.popup:hide()
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_MUST_BE_IN_SEAT"))
    end
end

return PersonalRecentExpView