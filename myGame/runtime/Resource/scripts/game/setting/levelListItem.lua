-- Listview.lua
-- Date: 2016-07-06

local ListItem = require("game/uiex/listView/listItem")
local LevelListItem = class(ListItem)

function LevelListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
    else
        self.isFolded_ = true
    end

    if self.index_  == 1 and not self.initItem then
        self.initItem = true
        self:createItem2(self.data_)
    elseif self.index_ == 2 and not self.initItem2 then
        self.initItem2 = true
        self:createItem2(self.data_)
    elseif self.index_ == 3 and not self.initItem3 then
        self.initItem3 = true
        self:createItem2(self.data_)
    end   

    self:unscheduleUpdate()
    self:scheduleUpdate()
end

function LevelListItem:createItem2(data)
    local levelList = data[2]

    local startPosX = LevelListItem.MARGIN_LEFT
    local startPosY = 0
    local items = {}

    local lineWidth = 620
    local lineHeight = 3
    local padding = 10
    local perHeight = 0
    local TitleMarginLeft = 110
    local sumExpMarginLeft = 350
    local bottomContainer = new(Node)
    self.clip_:addChild(bottomContainer)
    for i = 1, #levelList do
        local levelArray = levelList[i]

        --等级
        local level_text = new(Text,levelArray[1],nil,nil,kAlignLeft,nil,18,250,230,255)
        bottomContainer:addChild(level_text)

        local w_text,h_text = level_text:getSize()
        perHeight = h_text + padding + lineHeight
        local height = startPosY + (i-1)*perHeight
                
        level_text:setPos(startPosX, height)

        --称号
        local title_text = new(Text,levelArray[2],nil,nil,kAlignLeft,nil,18,250,230,255)
        bottomContainer:addChild(title_text)    
        title_text:setPos(startPosX + TitleMarginLeft, height) 

        --总经验
       local sumExp_text = new(Text,levelArray[3],nil,nil,kAlignLeft,nil,18,250,230,255)
       bottomContainer:addChild(sumExp_text)  
       sumExp_text:setPos(startPosX + sumExpMarginLeft, height) 

        --等级奖励
        local levelReward_text = new(Text,levelArray[4],nil,nil,kAlignRight,nil,18,250,230,255)
        levelReward_text:setAlign(kAlignTopRight)
        bottomContainer:addChild(levelReward_text) 
        levelReward_text:setPos(-lineWidth - startPosX, height)

        --分割线
        local line = new(Image,"res/setting/setting_rule_line.png")
        bottomContainer:addChild(line)
        line:setSize(lineWidth,lineHeight)
        line:setPos(startPosX, height + h_text + padding)


    end
    self.bg_height_ = startPosY*2 + #levelList * perHeight + padding
end

return LevelListItem