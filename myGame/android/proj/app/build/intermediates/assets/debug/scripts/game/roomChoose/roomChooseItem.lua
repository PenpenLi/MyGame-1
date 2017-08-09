-- hallScene.lua
-- Last modification : 2016-05-11
-- Description: a scene in Hall moudle
local varConfigPath = VIEW_PATH .. "roomChoose.roomChoose_item_layout_var"
local itemView = require(VIEW_PATH .. "roomChoose.roomChoose_item")


local RoomChooseItem = class(GameBaseLayer,false);

-- roomType 1:gaple  2:qiuqiu
function RoomChooseItem:ctor(data,index,roomType)
    super(self, itemView);
    self:declareLayoutVar(varConfigPath)

    self.data = data
    self.roomType = roomType

    -- self:addChild(self.m_root);
    self:setSize(self.m_root:getSize());

    self.m_roomStep = self:getControl(self.s_controls["roomStep"])
    self.m_roomStep:setOnClick(self, self.onRoomStepClick)

    self.m_onlineNum = self:getUI("onlineNum")
    self.m_clockIcon = self:getUI("clock_icon")
    self.m_clockIcon:setVisible(false)

    local name = string.format("res/roomChoose/roomC_step_%d.png",index)
    if index > 6 then
        name = "res/roomChoose/roomC_step_6.png"
    end
    self.m_roomStep:setFile(name)

    self:setItemData()

    EventDispatcher.getInstance():register(EventConstants.UPDATE_ONLINE_NUM, self, self.updataOnLineNum)
end

function RoomChooseItem:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.UPDATE_ONLINE_NUM, self, self.updataOnLineNum)
end

function RoomChooseItem:setItemData()
    local betsNode = self:getControl(self.s_controls["betsNode"])
    self:createBetsNode(self.data.bets,betsNode)

    local minOrMax = self:getControl(self.s_controls["minOrMax"])
    local minOrMaxStr = ""

    if self.roomType == 1 then
        minOrMaxStr = bm.LangUtil.getText("HALL", "MIN_LIMIT_TEXT", nk.updateFunctions.formatBigNumber(self.data.minmoney))
    elseif self.roomType == 2 then
        minOrMaxStr = bm.LangUtil.getText("HALL", "MIN_BUY_IN_TEXT", nk.updateFunctions.formatBigNumber(self.data.minmoney))
        if self.data.levellimit then
            local lv = nk.Level:getLevelByExp(nk.userData.exp);
            if checkint(self.data.levellimit) > checkint(lv) then
                self.data.isLevellimit = true
                self.data.levellimitStr = bm.LangUtil.getText("HALL", "MIN_LEVEL_TIP", self.data.levellimit)
                self.m_clockIcon:setVisible(true)
                self:setColor(128,128,128)
            else
                self.data.isLevellimit = false
                self.m_clockIcon:setVisible(false)
                self:setColor(255,255,255)
            end
        end
    end 
    minOrMax:setText(minOrMaxStr)
end

function RoomChooseItem:createBetsNode(bets,node)
    local betsNode = new(Node)
    local betsStr = nk.updateFunctions.formatBigNumber(bets)
    local len = string.len(betsStr)
    local offsetX = 0

    -- len = 10

    local x = 0
    local letterOff = 0
    for i=1,len,1 do
        local char = string.sub(betsStr,i,i)
        --[[
        if i <= 8 then
            char = i - 1
        elseif i == 9 then
            char = "k"
        elseif i == 10 then
            char = "M"
        end
        --]]

        if char == "K" or char == "k" then
            char = "k"
        elseif char == "M" or char == "m" then
            char = "m"
        end
        
        local gotoImg = new(Image,"res/roomChoose/roomC_" .. char .. ".png")
        local width, height = gotoImg:getSize()
        betsNode:addChild(gotoImg)
        if i ~= 1 then
            if char == "K" or char == "k" then
                x = x + 26
                letterOff = width
            elseif char == "M" or char == "m" then
                x = x + 28
                letterOff = width
            else
                x = x + 24
            end
        end
        gotoImg:setPos(x,0)
    end
    offsetX = x + letterOff
    node:addChild(betsNode);
    betsNode:setPos(-offsetX/2,0)
end

function RoomChooseItem:onRoomStepClick()
    if self.roomType == 2 and self.data.isLevellimit then
        nk.CenterTipManager:show(self.data.levellimitStr)
        return
    end

    if self.m_obj and self.m_func then
        self.m_func(self.m_obj, self.data)
    end
end

function RoomChooseItem:setDelegate(obj, func)
    self.m_obj = obj;
    self.m_func = func;
end

function RoomChooseItem:updataOnLineNum(onLineData)
    self.m_onlineNum:setText("0")
    if onLineData and onLineData[self.data.bets] then
        self.m_onlineNum:setText(onLineData[self.data.bets])
    end
end

return RoomChooseItem
