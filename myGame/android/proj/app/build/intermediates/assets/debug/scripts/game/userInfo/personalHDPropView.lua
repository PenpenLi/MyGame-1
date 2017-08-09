local PersonalHDPropView = class(Node)


function PersonalHDPropView:ctor(width, height, popup)
    self.widthOfView, self.heightOfView = width, height
    self.popup = popup
	self:initView()
end

function PersonalHDPropView:dtor()
    
end

function PersonalHDPropView:initView()
	self:createPropsList()

    local expCost = 0
    local ctx = self.popup.ctx
    if not nk.isInSingleRoom and ctx and ctx.model then
        local roomId = tostring(ctx.model.roomInfo.roomType) 
        local roomCostConf = ctx.model.roomCostConf
        -- FwLog("roomCostConf >> " .. json.encode(roomCostConf))
        if roomCostConf ~= nil and roomId and roomCostConf[roomId] and roomCostConf[roomId][1] ~= nil then
            expCost = roomCostConf[roomId][1]
        end
    end
    -- expCost = 10000000000000 --expCost
    self.expCost = expCost
    if self.expCost > 0 then
        local image = new(Image, kImageMap.common_transparent_blank)
        image:setSize(self.widthOfView, 24)
        image:setPos(0, self.heightOfView - 24)
        image:addTo(self)
        local textTips = new(Text, 
            T("每发送一次互动道具需消耗%s金币", nk.updateFunctions.formatBigNumber(expCost)),
            nil, nil, nil, nil, 16, 255, 255, 255)
        textTips:addTo(self)
        local widthOfText = textTips:getSize()
        textTips:setPos((self.widthOfView - widthOfText) * 0.5, self.heightOfView - 24)
    end
end

-- 这个是道具对应的具体id，key：默认显示的index，    value：id
local hddjIdFormat = {9,4,18,19,1,2,3,5,6,7,8,10,12,13,14,15,16,17}

local isVipProp = {[13] = true,[14] = true,[15] = true,[16] = true,[17] = true}
function PersonalHDPropView:creatHDData()
    local temp = {}

    for i,v in ipairs(hddjIdFormat) do
        temp[i] = {}
        temp[i].isVipProp = isVipProp[v] and 1 or 0
        temp[i].hddjId = v
        temp[i].index = i
    end

    if checkint(nk.userData.vip) > 0 then
        table.sort(temp,function(a,b)
            if a.isVipProp > b.isVipProp then
                return true
            -- elseif a.isVipProp == b.isVipProp then
            --     return a.hddjId < b.hddjId
            elseif a.isVipProp == b.isVipProp then
                return a.index < b.index
            else
                return false
            end
        end)
    else
        table.sort(temp,function(a,b)
            if a.isVipProp > b.isVipProp then
                return false
            -- elseif a.isVipProp == b.isVipProp then
            --     return a.hddjId < b.hddjId
            elseif a.isVipProp == b.isVipProp then
                return a.index < b.index
            else
                return true
            end
        end)
    end

    return temp
end
function PersonalHDPropView:createPropsList()
    local scrollView = new(ScrollView, 0, 0, self.widthOfView, self.heightOfView, false)
    scrollView:addTo(self)
	local PropItem = require("game.userInfo.roomUserinfo.propItem")
    scrollView.m_space_v = 0
    scrollView.m_space_h = -3
    local itemScale = 0.85
    local x, y = scrollView.m_space_h, scrollView.m_space_v
    local temp = new(Image,"res/userInfo/userInfo_prop_expression_bg.png")
    local item_w, item_h = temp:getSize()
    delete(temp)
    local rowCount = 5
    local rowHeight = 4

    local hdArrTemp = self:creatHDData()


    for i,hd in ipairs(hdArrTemp) do
        local isVipOnly = (hd.isVipProp >= 1)
        local item = new(PropItem, hd.hddjId, isVipOnly)
        item:setDelegate(self, self.onPropItemCallback)
        item:addTo(scrollView)
        item:addPropScaleSolid(0, itemScale, itemScale, kCenterDrawing)
        x = (i-1)%5*item_w + scrollView.m_space_h
        y = math.floor((i-1)/5) * item_h * itemScale + scrollView.m_space_v
        item:setPos(x,y)
    end

    scrollView.m_nodeH = item_h * math.ceil(#hddjIdFormat/5)
    scrollView:update()
end

function PersonalHDPropView:onPropItemCallback(hddjId)
    local seatId = self.popup.seatInfo.seatId
    local sendNum = self.popup.sendHDPropNum
    -- FwLog("sendNum = " .. sendNum)
    if self.popup.ctx.model:isSelfInSeat() then
        local pnid = 2001 --互动表情道具
        if sendNum == 3 then
            nk.AnalyticsManager:report("New_Gaple_expr_x3", "expr_x3")
        elseif sendNum == 5 then
            nk.AnalyticsManager:report("New_Gaple_expr_x5", "expr_x5")
        end
        if self.expCost == 0 then
            nk.SocketController:sendProp(hddjId, {seatId}, pnid, sendNum)
            self.popup.ctx.animManager:playHddjAnimation(self.popup.ctx.model:selfSeatId(), seatId, hddjId, nil, sendNum)
        else
            nk.SocketController:sendRoomCostProp(self.expCost, 2, hddjId, seatId, sendNum)
        end
        self.popup:hide()
    else
        --不在座位不能发送互动道具
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_IN_SEAT"))
    end
end

return PersonalHDPropView