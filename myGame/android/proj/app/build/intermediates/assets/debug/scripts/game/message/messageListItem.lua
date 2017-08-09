-- MessageListItem.lua
-- Date: 2016-07-16
local BaseItem = require("game/uiex/listView/baseItem")
local MessageListItem = class(BaseItem,false)

MessageListItem.WIDTH = 680
MessageListItem.HEIGHT = 80
MessageListItem.MARGIN_MID = 15
MessageListItem.MARGIN_LEFT = 20

function MessageListItem:ctor()
   super(self,MessageListItem.WIDTH ,MessageListItem.HEIGHT)

  --图标
  self.icon_ = new(Image,"res/setting/setting_unread_e.png")
  local w_icon, h_icon = self.icon_:getSize()
  self:addChild(self.icon_)
  self.icon_:setPos(MessageListItem.MARGIN_LEFT,MessageListItem.HEIGHT*0.5 -h_icon*0.5 )

  
  --描述
  self.content_ = new(TextView,"",370,50,kAlignTopLeft,"",22,255,255,255)
  self.content_:setScrollBarWidth(0)
  -- self.content_:setPickable(false)
  self:addChild(self.content_)
  self.content_:setPos(MessageListItem.MARGIN_LEFT + w_icon + MessageListItem.MARGIN_MID +20,
                       MessageListItem.HEIGHT*0.5 - 25)

  --时间
  self.time_ = new(Text,"",nil,nil,nil,nil,22,255,255,255)
  self:addChild(self.time_)
  self.time_:setAlign(kAlignRight)
  self.time_:setPos(155,0)

  --按钮 
  self.button_ = new(Button,"res/common/common_btn_yellow_m.png")
  local w_bt,h_bt = self.button_:getSize()
  self.button_:setVisible(false)
  self.button_:setOnClick(self,self.bt_click)
  self:addChild(self.button_)
  self.button_:setAlign(kAlignRight)
  self.button_:setPos(0,0)

  --按钮text
  self.bt_text_ = new(Text,"",nil,nil,kAlignCenter,nil,22,255,255,255)
  self.button_:addChild(self.bt_text_)
  self.bt_text_:setAlign(kAlignCenter)
  self.bt_text_:setPos(0, 0)

    --分割线
  self.line_ = new(Image,"res/setting/setting_rule_line.png")
  self:addChild(self.line_)
  local w,h = self.line_:getSize()
  self.line_height = h
  self.line_:setSize(620,h)
  self.line_:setPos(MessageListItem.MARGIN_LEFT,MessageListItem.HEIGHT)

  local y1
  self:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown then
                                                y1 = y
                                          end
                                          if finger_action == kFingerUp then
                                               if math.abs(y1-y) < 5 then
                                                    self:touch()
                                               end
                                               
                                          end
                                         end)

  EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function MessageListItem:dtor()
  EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function MessageListItem:setItemData(dataChanged, data)
    if dataChanged then
        self.content_:setText(data.msg)
        local temp = os.date("*t", data.d)
        self.time_:setText(temp.month .. "-" .. temp.day)

        if checkint(data.b) <= 200  then
        --好友消息
            self.icon_:setFile("res/setting/setting_read_f.png")
            self.content_:setColor(128,128,128)
            self.time_:setColor(128,128,128)
            if checkint(data.c) == 0 then
                self.icon_:setFile("res/setting/setteing_unread_f.png") 
                self.content_:setColor(255,255,255)
                self.time_:setColor(255,255,255)
            end
            if data.h then
               self.button_:setVisible(true)
               if data.h == 0 then
               --未领取    
                        
                   self.button_:setEnable(true)
                   self.bt_text_:setText(bm.LangUtil.getText("DAILY_TASK","GET_REWARD"))
               elseif data.h == 1 then
               --已领取
                   self.button_:setEnable(false)
                   self.bt_text_:setText(bm.LangUtil.getText("DAILY_TASK","HAD_FINISH"))
               elseif data.h == 2 then
               --已自动领取
                   self.button_:setEnable(false)
                   self.bt_text_:setText(bm.LangUtil.getText("DAILY_TASK","AUTO_GET_REWARD"))
               end
            end
        else
        --系统消息
            self.icon_:setFile("res/setting/setting_read_e.png")
            self.content_:setColor(128,128,128)
            self.time_:setColor(128,128,128)
            if checkint(data.c) == 0 then
                self.icon_:setFile("res/setting/setting_unread_e.png")
                self.content_:setColor(255,255,255)
                self.time_:setColor(255,255,255)
            end
            if data.h then
               self.button_:setVisible(true)
               if data.h == 0 then
               --未领取          
                   self.button_:setEnable(true)
                   self.bt_text_:setText(bm.LangUtil.getText("DAILY_TASK","GET_REWARD"))
               elseif data.h == 1 then
               --已领取
                   self.button_:setEnable(false)
                   self.bt_text_:setText(bm.LangUtil.getText("DAILY_TASK","HAD_FINISH"))
               elseif data.h == 2 then
               --已自动领取
                   self.button_:setEnable(false)
                   self.bt_text_:setText(bm.LangUtil.getText("DAILY_TASK","AUTO_GET_REWARD"))
               end
            end
        end
    end
end

function MessageListItem:changeStyle(itype)
   if not self.checkbox_ then
      self.checkbox_ = new(CheckBox,{"res/userInfo/userInfo_uchosed.png","res/userInfo/userInfo_choosed.png"})
      self.checkbox_:setSize(30,30)
      local w,h = self.checkbox_:getSize()
      self:addChild(self.checkbox_)
      self.checkbox_:setOnChange(self,self.checkbox)
      self.checkbox_:setPos(w*0.5,MessageListItem.HEIGHT*0.5 - h*0.5)
   end

   if itype == 1 then
      self.checkbox_:setVisible(false)
      local x,y = self.icon_:getPos()
      self.icon_:setPos(x - 25,y)
   else
      local x,y = self.icon_:getPos()
      self.icon_:setPos(x + 25,y)
      self.checkbox_:setVisible(true)
      self.checkbox_:setChecked(false)
   end
end

function MessageListItem:checkbox(check)
     EventDispatcher.getInstance():dispatch(EventConstants.messageCheckbox, check, self.data_.a)
end

function MessageListItem:setCheck(check)
    self.checkbox_:setChecked(check)
end

function MessageListItem:bt_click()
   self.button_:setEnable(false)
   local param = {}
   param.param = self.data_.g 

   EventDispatcher.getInstance():dispatch(EventConstants.messageGetRward,true)
   self.isgetPrize = true
   nk.HttpController:execute("MsgPrize.getPrize", {game_param = param})
end

function MessageListItem:touch()
    if checkint(self.data_.c) ~= 0 then return end

    if checkint(self.data_.h) == 0 then
        self:bt_click()
    else
        self.istouch = true
        nk.HttpController:execute("Message.readedMessage", {game_param = {id = self.data_.a}})
    end    
end

function MessageListItem:onHttpProcesser(command, code, content)
    if command == "MsgPrize.getPrize" and self.isgetPrize then
      EventDispatcher.getInstance():dispatch(EventConstants.messageGetRward, false)
      self.isgetPrize = nil
      if code ~= 1 then
          return
      end
      local data = content.data
      if data.code == 1 then
      --领取成功
          self.bt_text_:setText(bm.LangUtil.getText("DAILY_TASK","HAD_FINISH"))
          local file = nil
          if checkint(self.data_.b) <= 200 then
              file = "res/setting/setting_read_f.png"
          else
              file = "res/setting/setting_read_e.png"
          end
          self.content_:setColor(128,128,128)
          self.time_:setColor(128,128,128)
          self.icon_:setFile(file)
          self.data_.c = 1
          self.data_.h = 1
      else
          self.button_:setEnable(true)
      end
    elseif command == "Message.readedMessage" and self.istouch then
      self.istouch = nil
      if code ~= 1 then
        return
      end

      self.data_.c = 1
      self.content_:setColor(128,128,128)
      self.time_:setColor(128,128,128)
      if checkint(self.data_.b) <= 200 then
          file = "res/setting/setting_read_f.png"
      else
          file = "res/setting/setting_read_e.png"
      end
      self.icon_:setFile(file)
    end
end


return MessageListItem