-- Listview.lua
-- Date: 2016-07-06
local BaseItem = require("game/uiex/listView/baseItem")
local ListItem = class(BaseItem,false)

ListItem.WIDTH = 660
ListItem.HEIGHT = 60
ListItem.MARGIN_MID = 15
ListItem.MARGIN_LEFT = 20

--  Tip: --------默认 TopLeft 对齐---------
function ListItem:ctor()
   super(self,ListItem.WIDTH ,ListItem.HEIGHT)
  self.isFolded_ = true

  --触摸层
  self.touch_ = new(Image,"res/common/common_blank.png")
  self.touch_:setSize(ListItem.WIDTH,ListItem.HEIGHT)
  self.touch_:setPos(0,0)
  local y1,y2
  self.touch_:setEventTouch(self,function(self, finger_action, x, y, drawing_id_first, drawing_id_current) 
            if finger_action == kFingerDown then
               y1 = y
            end
            if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
                y2 = y
                if math.abs(y2-y1) < 5 then
                   self:foldContent()
                end   
            end 
            end )
  self:addChild(self.touch_)

  --容器节点
  self.container_ = new(Node)
  self:addChild(self.container_)
  self.container_:setPos(0,0)

  --背景
  self.bg_ = new(Image,"res/setting/setting_rules_bg.png",nil,nil,18,18,20,20)
  self.bg_:setSize(ListItem.WIDTH,ListItem.HEIGHT)
  self.bg_:setPos(0,0)
  self.container_:addChild(self.bg_)

  --移动的高度
  self.heightEx_ = 0

  --折叠按钮
  self.foldIcon_ = new(Image,"res/setting/setting_list_arrow.png")
  self.foldIcon_:addPropRotateSolid(1,90,kCenterDrawing)
  local w_icon,h_icon = self.foldIcon_:getSize()
  self.foldIcon_:setPos(20, ListItem.HEIGHT*0.5 - h_icon*0.5 )
  self.bg_:addChild(self.foldIcon_)

  --标题
  self.title_margin_left_ = ListItem.MARGIN_LEFT *2 + w_icon
  self.text_title_ = new(Text,nil,nil,nil,kAlignLeft,nil,24,250,230,255)
  self.text_title_:setPos(self.title_margin_left_,ListItem.HEIGHT*0.5 - ListItem.MARGIN_MID)
  self.bg_:addChild(self.text_title_)

  --裁剪区
  self.clip_ = new(Node)
  self.clip_:setClip(0,0,ListItem.WIDTH,ListItem.HEIGHT)
  self.clip_:setPos(0,ListItem.HEIGHT)
  self.clip_:setSize(0,0)
  self.container_:addChild(self.clip_)
  self:custom()
end

function ListItem:custom()
end

function ListItem:setItemData(dataChanged, data)
    if dataChanged then
        self.text_title_:setText(data[1])
    end
end

function ListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
    else
        self.isFolded_ = true
    end
    if not self.initItem then
        self.initItem = true
        self:createItem(self.data_)
    end   
    self:unscheduleUpdate()
    self:scheduleUpdate()
--    -- test
--   if self.isFolded_ then
--        self:setSize(RuleListItem.WIDTH, RuleListItem.HEIGHT )
--        self.bg_:setSize(RuleListItem.WIDTH, RuleListItem.HEIGHT)
--        self.clip_:setClip(0,0,RuleListItem.WIDTH, RuleListItem.HEIGHT)
--        self.touch_:setSize(RuleListItem.WIDTH, RuleListItem.HEIGHT)
--        self:getOwner():Resize()
--   else
--        self:setSize(RuleListItem.WIDTH, RuleListItem.HEIGHT + self.bg_height_)
--        self.bg_:setSize(RuleListItem.WIDTH, RuleListItem.HEIGHT + self.bg_height_)
--        self.clip_:setClip(0,0,RuleListItem.WIDTH, RuleListItem.HEIGHT + self.bg_height_)
--        self.touch_:setSize(RuleListItem.WIDTH, RuleListItem.HEIGHT + self.bg_height_)
--        self:getOwner():Resize()
--   end
end

function ListItem:createItem(data)
    self.text_answer = new(TextView,data[2],620,nil,kAlignLeft,nil,18,250,230,255)
    self.text_answer:setPickable(false)
    self.clip_:addChild(self.text_answer)
    local w,h = self.text_answer:getSize()  
    self.text_answer:setPos(ListItem.MARGIN_LEFT,ListItem.MARGIN_MID)
    self.bg_height_ = h +  ListItem.MARGIN_MID *2 
end

function ListItem:updateListItem()
    local bottomHeight = self.bg_height_
    local dest,direction
    if self.isFolded_ then
       dest = 0      
       direction = -1     --收缩
    else
       dest = bottomHeight
       direction = 1      --展开
    end
    if self.heightEx_ == dest then
       self:unscheduleUpdate()
    else
       self.heightEx_ = self.heightEx_ + direction * math.max(1, math.abs(self.heightEx_ - dest)*0.08)
       if direction>0 and self.heightEx_>dest or direction<0 and self.heightEx_<dest then
          self.heightEx_ = dest
       end
    end
    
    -- self.foldIcon_:removeProp(2)
    self.foldIcon_:addPropRotateSolid(2,90*(self.heightEx_/bottomHeight),kCenterDrawing)
    self:setSize(ListItem.WIDTH, ListItem.HEIGHT + self.heightEx_)
    self.bg_:setSize(ListItem.WIDTH, ListItem.HEIGHT + self.heightEx_)
    self.clip_:setClip(0,0,ListItem.WIDTH, ListItem.HEIGHT + self.heightEx_)
    self.touch_:setSize(ListItem.WIDTH, ListItem.HEIGHT + self.heightEx_)
    self:getOwner():Resize()
end

function ListItem:unscheduleUpdate()
    if self.anim_frame_ then
       delete(self.anim_frame_)
       anim_frame_ = nil
    end
end

function ListItem:scheduleUpdate()
    self.anim_frame_ = new(AnimInt,kAnimLoop,0,1,1000/60,-1)
    self.anim_frame_:setEvent(self,self.updateListItem)
end

return ListItem