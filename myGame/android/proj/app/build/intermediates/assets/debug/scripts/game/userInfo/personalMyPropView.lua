local PersonalMyPropView = class(Node)
local RegisterImageTouchFunc
local PropManager = require("game.store.prop.propManager")
local MyPropItemView = require("game.userInfo.myprop.myPropItemView")
local SynthesisPropPopup = require("game.userInfo.myprop.synthesisPropPopup")
local PropDetailPopup = require("game.userInfo.myprop.propDetailPopup")

function PersonalMyPropView:ctor(width, height, popup)
	self.widthOfView, self.heightOfView = width, height
	self.popup = popup
	self:initView()
    EventDispatcher.getInstance():register(EventConstants.PROP_INFO_CHANGED, self, self.onPropInfoChanged)
end

function PersonalMyPropView:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.PROP_INFO_CHANGED, self, self.onPropInfoChanged)
end

function PersonalMyPropView:initView()
	local textTip = new(Text, bm.LangUtil.getText("USERINFO","NO_PROP"), 0, 0, kAlignCenter, nil, 20, 255, 255, 255)
    textTip:addTo(self)
    local widthOfText = textTip:getSize()
    textTip:setPos(self.widthOfView * 0.5 - widthOfText * 0.5, 220 * 0.5)
    self.textTip = textTip
    self.textTip:setVisible(false)
    self:setLoading(true)
    self:requestProp()
end

function PersonalMyPropView:requestProp()
    PropManager.getInstance():requestUserPropList(handler(self, self.setProps))
end

function getPropItem(self, itemClass, v)
    local propItem = SceneLoader.load(itemClass)
    local item = propItem:getChildByName("Image_item")
    propItem:setSize(190,180)
    item:setAlign(kAlignCenter)
    -- item:setPos(math.mod(i-1,3)*223 +8, math.floor((i-1)/3)*195)
    local text_name = item:getChildByName("Text_prop_name")
    item:getChildByName("Image_shine_bg"):setVisible(v.shine == true)
    text_name:setText(v.name)
    local image_icon = item:getChildByName("Image_prop_icon")
    if v.pcid then
    image_icon:setFile(kImageMap.common_transparent)
    PropManager.getInstance():getPropListById(PropManager.TYPE_PROP, function(status, propType, data)
        if status and not tolua.isnull(self) then
            if data then
                for i = 1, #data do
                    if(tonumber(data[i]["pnid"]) == tonumber(v.pnid)) then
                        UrlImage.spriteSetUrl(image_icon, data[i]["image"])
                        break
                    end
                end
            end
        end
    end)
    end
    -- item:setEventTouch(self, v.handler)
    RegisterImageTouchFunc(item, self, v.handler)
    if v.cnt then 
        local text_time = item:getChildByName("Text_prop_deadline")
        -- text_time:setText(bm.LangUtil.getText("USERINFO","USE_TIME") .. ":" .. v.cnt .. T("个"))
        text_time:setText("x" .. v.cnt)
    end
    return item
end

function PersonalMyPropView:setProps(status, data)
    if tolua.isnull(self) then
        return 
    end
    self:setLoading(false)
    if not status then
        if not self.scrollContainer then
            self.textTip:setVisible(true)
        end
        return
    end
	local itemClass = require(VIEW_PATH .. "userInfo/propItem_view")
    local info = data
    -- if #info <= 0 and false then
        -- self.textTip:setVisible(true)
    -- else
	self.textTip:setVisible(false)
	local scrollContainer = self.scrollContainer
    if not scrollContainer then
        scrollContainer = new(ScrollView, 0, 0, self.widthOfView, self.heightOfView, false)
    	scrollContainer:addTo(self)
    	scrollContainer:setDirection(kVertical)
        self.scrollContainer = scrollContainer
    else
        scrollContainer:removeAllChildren(true)
    end
    local listOfPropInfo = {{pcid = -1, icon = kImageMap.userInfo_propItem_exchange, title = bm.LangUtil.getText("USERINFO", "SYNTHESIS_PROP")},}
     -- {pcid = -1,}, {pcid = -1,}, {pcid = -1,}, {pcid = -1,}, {pcid = -1,}, {pcid = -1,}, {pcid = -1,}, {pcid = -1,}, {pcid = -1,}, {pcid = -1,}}
    for i = 1, #info + 1 do
        if i ~= #info + 1 then
            -- if tonumber(info[i].pnid) == 1001 then -- 只显示喇叭，以后加了道具不显示 -- pcid(类型), pnid(道具ID), pid
            --     table.insert(listOfPropInfo, {name = bm.LangUtil.getText("USERINFO","LABA"),
            --         -- file = "res/userInfo/userInfo_laba.png",
            --         handler = self.onPropClick,
            --         pcnter = info[i].pcnter,
            --         pcnter = info[i].pcnter,
            --         shine = true,
            --         pcid = info[i].pcid,
            --         pnid = info[i].pnid,
            --         })
            -- end
            table.insert(listOfPropInfo, info[i])
        else
            table.insert(listOfPropInfo, {name = bm.LangUtil.getText("COMMON","BUY_PROP"),
                handler = self.onMoreBtnClick
                })
        end
    end
    local COL_NUM = 4
    local item_w, item_h = 100, 98
    local SPACE_H, SPACE_V = 20, 20
    for i, v in ipairs(listOfPropInfo) do
        -- getPropItem(self, itemClass, v):addTo(scrollContainer)
        local x = ((i + COL_NUM - 1) % COL_NUM ) * (item_w + SPACE_H)  + SPACE_H + 10
        local y = math.floor( ( i - 1 ) / COL_NUM ) * (item_h +  SPACE_V) + SPACE_V
        local item = new(MyPropItemView, v)
        item:addTo(scrollContainer)
        item:setPos(x, y)
        item:setTouchDelegate(self, self.onPropClick)
    end
    local rowCount = math.ceil(#listOfPropInfo / COL_NUM)
    scrollContainer.m_nodeH = (item_h + SPACE_V) * rowCount + SPACE_V
    scrollContainer:update()
	-- end
end

function PersonalMyPropView:onPropClick(item)
    local data, config = item.data, item.config
    if data.pcid == -1 then
        nk.AnalyticsManager:report("New_Gaple_click_synt_personinfo")
        nk.PopupManager:addPopup(SynthesisPropPopup, self.popup.currentScene)
    elseif checkint(data.pcid) > 0 then
        if checkint(data.pcid) == 1 then -- 喇叭
            --喇叭，打开喇叭面板
            local WAndFChatPopup = require("game.chat.wAndFChatPopup")
            local roomType = nil
            if self.popup.ctx then
                roomType = self.popup.ctx.model:roomType()
            end
            nk.PopupManager:addPopup(WAndFChatPopup, self.popup.currentScene, roomType, nil)
        else
            nk.AnalyticsManager:report("New_Gaple_click_prop_personinfo")
            if config then -- 一般都有
                nk.PopupManager:addPopup(PropDetailPopup, self.popup.currentScene, data, config)
            end
        end
    else
        local vipPopup = require("game.store.vip.vipPopup")
        if self.popup.ctx and self.popup.ctx.model then
            local level = self.popup.ctx.model:roomType()
            nk.PopupManager:addPopup(vipPopup, self.popup.currentScene, true, level, "prop")
        else
            nk.PopupManager:addPopup(vipPopup, self.popup.currentScene, nil, nil, "prop")
        end
        self.popup:hide()
    end
end

-- function PersonalMyPropView:onPropClick()
--     --喇叭，打开喇叭面板
--     local WAndFChatPopup = require("game.chat.wAndFChatPopup")
--     local roomType = nil
--     if self.popup.ctx then
--         roomType = self.popup.ctx.model:roomType()
--     end
--     nk.PopupManager:addPopup(WAndFChatPopup, self.popup.currentScene, roomType, nil)
-- end

-- function PersonalMyPropView:onMoreBtnClick()
--     local StorePopup = require("game.store.popup.storePopup")
--     if self.popup.ctx and self.popup.ctx.model then
--         local level = self.popup.ctx.model:roomType()
--         nk.PopupManager:addPopup(StorePopup, self.popup.currentScene, true, level, "prop")
--     else
--         nk.PopupManager:addPopup(StorePopup, self.popup.currentScene, nil, nil, "prop")
--     end
--     self.popup:hide()
-- end

function PersonalMyPropView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self)    
            self.juhua_.loading_node:setPos(self.widthOfView * 0.5, 220 * 0.5)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function PersonalMyPropView:onPropInfoChanged(data)
    -- body
    self:setProps(true, data)
end

RegisterImageTouchFunc = function(image, instance, touchFunc)
    local clickPos
    local isMove
    image:setEventTouch(instance, function(_, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
        if finger_action == kFingerDown then
            clickPos = {x = x, y = y}
        elseif finger_action == kFingerMove then
            if math.abs(x - clickPos.x) > 5 or math.abs(y - clickPos.y) > 5 then
                isMove = true
            end
        elseif finger_action == kFingerUp then
            if isMove then 
                isMove = false
                return 
            end
            touchFunc(instance)
        end
    end)
end

return PersonalMyPropView