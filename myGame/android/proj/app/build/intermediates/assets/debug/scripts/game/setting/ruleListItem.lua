-- Listview.lua
-- Date: 2016-07-06

local ListItem = require("game/uiex/listView/listItem")
local RuleListItem = class(ListItem)

function RuleListItem:custom()
  --分割线
  self.line_ = new(Image,"res/setting/setting_rule_line.png")
  local w,h = self.line_:getSize()
  self.line_height = h
  self.line_:setSize(620,h)
  self.line_:setPos(ListItem.MARGIN_LEFT,0)
  self.clip_:addChild(self.line_)
end

function RuleListItem:setItemData(dataChanged, data)
    if dataChanged then
        self.text_title_:setText(data[1])

        if self.index_ == 1 then 
            --游戏规则图片
            local rulePic = new(Image,"res/setting/help_rule_pic.png")
           -- rulePic:addPropScaleSolid(1,0.8,0.8,kCenterXY,0,0)

            local w,h = rulePic:getSize()
            rulePic:setSize(w*0.73,h*0.73)
            w,h = rulePic:getSize()
            rulePic:setPos(RuleListItem.MARGIN_LEFT, 0 ) 
            self.clip_:addChild(rulePic)

            self.bg_height_ = h +  self.line_height       
        end
    end
end

function RuleListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
    else
        self.isFolded_ = true
    end

    if self.index_  > 1 and not self.initItem then
        self.initItem = true
        self:createItem(self.data_)
    end   

    self:unscheduleUpdate()
    self:scheduleUpdate()
end

return RuleListItem