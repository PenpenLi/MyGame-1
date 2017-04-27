-- taskListItem.lua
-- Date: 2016-07-20
local PhotoManagerPopup  = require("game.photoManager.photoManagerPopup") 
local WAndFChatPopup = require("game.chat.wAndFChatPopup")
local GiftShopPopup = require("game.giftShop.giftShopPopup")
local taskModel = require("game/task/taskmodel")
local taskItemView = require(VIEW_PATH .. "task.task_item")
local taskItemConfig = VIEW_PATH .. "task.task_item_layout_var"
local taskListItem = class(GameBaseLayer,false)

taskListItem.WIDTH = 650
taskListItem.HEIGHT = 98

function taskListItem:ctor(data)
  super(self,taskItemView ,taskItemConfig)
  self.image_bg = self:getUI("Image_bg")

  local w,h = self.image_bg:getSize();
  self:setSize(w,h+6)

  self.icon_= self:getUI("Image_icon")

  self.text_content_ = self:getUI("Text_content")

  self.text_reward_ = self:getUI("Text_reward")
  self.text_reward_:setText(bm.LangUtil.getText("DAILY_TASK","REWARD"))

  self.text_num_ = self:getUI("Text_num")

  self.bt_get_ = self:getUI("Button_get")
  self.text_bt_get_ = self:getUI("Text_bt_get")
  self.text_bt_get_:setText(bm.LangUtil.getText("DAILY_TASK","HAD_FINISH"))

  self.bt_reward_ = self:getUI("Button_reward")
  self.bt_reward_:setOnClick(self, self.bt_reward_click)
   self.text_bt_reward_ = self:getUI("Text_bt_reward")
   self.text_bt_reward_:setText(bm.LangUtil.getText("DAILY_TASK","GET_REWARD"))

   self.bt_goto_ = self:getUI("Button_goto")
   self.bt_goto_:setOnClick(self, self.bt_goto_click)
   self.text_bt_goto_ = self:getUI("Text_bt_goto")
   self.text_bt_goto_:setText(bm.LangUtil.getText("DAILY_TASK","TO_DO"))

   self.data_ = data
   self:setItemData(self.data_)
end

function taskListItem:setItemData(data)
  if string.find(data.iconUrl,"http") then
    local function callback( ... )
      self.icon_:getChildByName("Word"):setVisible(false)
    end
    UrlImage.spriteSetUrl(self.icon_, data.iconUrl,callback)
  end
  self.text_content_:setDirection(kHorizontal)
  self.text_reward_:setDirection(kHorizontal)
  self.text_content_:setMultiLines(kTextSingleLine)
  self.text_reward_:setMultiLines(kTextSingleLine)
  self.text_content_:setText(data.desc)
  self.text_reward_:setText(bm.LangUtil.getText("DAILY_TASK","REWARD") .. ":" .. data.rewardDesc)
  self.text_content_:autoMove()
  self.text_reward_:autoMove()
  if data.status ==  taskModel.STATUS_UNDER_WAY then
      self.bt_goto_:setVisible(true)
      self.bt_get_:setVisible(false)
      self.bt_reward_:setVisible(false)
      if data.actType >= 5 and data.actType <=10 then
          if nk.isInRoomScene then
              self.bt_goto_:setEnable(false)
              self.text_bt_goto_:setText(bm.LangUtil.getText("DAILY_TASK", "NOT_FINISH"))
          else
              self.bt_goto_:setEnable(true)
              self.text_bt_goto_:setText(bm.LangUtil.getText("DAILY_TASK", "TO_DO"))
          end
      end
      if data.actType == 19 or data.actType == 20 then
          if nk.isInRoomScene then
              self.bt_goto_:setEnable(false)
              self.text_bt_goto_:setText(bm.LangUtil.getText("DAILY_TASK", "NOT_FINISH"))
          else
              self.bt_goto_:setEnable(true)
              self.text_bt_goto_:setText(bm.LangUtil.getText("DAILY_TASK", "TO_DO"))
          end
      end
      self.text_num_:setText(data.progress .. "/" .. data.target)
  elseif data.status ==  taskModel.STATUS_CAN_REWARD then
      self.bt_reward_:setVisible(true)
      self.bt_get_:setVisible(false)
      self.bt_goto_:setVisible(false)
      self.text_num_:setText(data.progress .. "/" .. data.target)
  elseif data.status ==  taskModel.STATUS_FINISHED then
      self.bt_get_:setVisible(true)
      self.bt_get_:setEnable(false)
      self.bt_reward_:setVisible(false)
      self.bt_goto_:setVisible(false)
      self.text_num_:setText(data.progress .. "/" .. data.target)
  end

  if data.actType >= 5 and data.actType <=10 then
      self.onGoToType_ = data.actType
      self.onGoToLevel_ = data.actLevel
      self.onGoToGameType_ = data.gameType
  else
      self.onGoToType_ = data.actType
  end
end

function taskListItem:bt_reward_click()
  EventDispatcher.getInstance():dispatch(EventConstants.messageGetRward,true)
  nk.taskController:requestReward(self.data_,nil, function(result, content)
     EventDispatcher.getInstance():dispatch(EventConstants.messageGetRward,false)
     if result then
          local info = content
          local listdata = {}
          local exReward = nil
          for i,v in ipairs(info) do
            if v.taskType == self.data_.taskType then
                table.insert(listdata, v)
            elseif checkint(v.taskType)  == 5 then
                if checkint(self.data_.taskType) == 2 then     -- 2 日常任务才有额外的奖励
                    v.progress = v.progress + 1
                    for j,w in ipairs(v.exReward) do      
                      if not table.keyof(v.exGetList, w) then
                          if v.progress >= w then
                              v.exCanGet[w] = true    --额外奖励的数量到达，并且还没有领取
                          end
                      end  
                    end
                    exReward = v                  
                end
            end
          end
          EventDispatcher.getInstance():dispatch(EventConstants.taskChangeData, checkint(self.data_.taskType), listdata)
          if checkint(self.data_.taskType) ~= 4 then
              EventDispatcher.getInstance():dispatch(EventConstants.getreward, exReward)
          end     
          nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"TaskPopup",{{name=self.data_.rewardDesc,icon =kImageMap.common_coin_107}}) 
     end
  end)
end

-- php约定好的 5-10 打牌， 11,12 邀请好友， 13 修改一次头像，14 使用喇叭， 15 购买礼物， 16 赠送礼物， 17 创建私人房， 18 充值,  19接龙，  20 qiuqiu

function taskListItem:bt_goto_click()
  nk.AnalyticsManager:report("New_Gaple_task_todo", "task")

  if self.onGoToType_ >= 5 and self.onGoToType_ <=10 then
      EventDispatcher.getInstance():dispatch(EventConstants.CloseTaskPopup, exReward)    
      if self.onGoToLevel_ > 0 then
           nk.SocketController:getRoomAndLogin(self.onGoToLevel_, 0)
      else
           nk.SocketController:quickPlayGaple()
      end          
  elseif self.onGoToType_ == 11 or self.onGoToType_ == 12 then
      EventDispatcher.getInstance():dispatch(EventConstants.CloseTaskPopup, exReward) 
      local InviteScene = require("game.invite.inviteScene")
      nk.PopupManager:addPopup(InviteScene)
  elseif self.onGoToType_ == 13 then 
      if nk.userData.photos then
          nk.PopupManager:addPopup(PhotoManagerPopup) 
      end
  elseif self.onGoToType_ == 14 then 
      nk.PopupManager:addPopup(WAndFChatPopup,"hall",0)
  elseif self.onGoToType_ == 15 then 
      nk.PopupManager:addPopup(GiftShopPopup,"hall",1,false,nk.userData.uid) 
  elseif self.onGoToType_ == 16 then 
      nk.PopupManager:addPopup(GiftShopPopup,"hall",2,false,nk.userData.uid) 
  elseif self.onGoToType_ == 17 then 
  elseif self.onGoToType_ == 18 then 
      local StorePopup = require("game.store.popup.storePopup")
      nk.PopupManager:addPopup(StorePopup)
  elseif self.onGoToType_ == 19 then 
      nk.SocketController:quickPlayGaple()
  elseif self.onGoToType_ == 20 then 
      nk.SocketController:quickPlayQiuQiu()
  elseif self.onGoToType_ == 21 then 
      local fbBindingPopup = require("game.userInfo.fbBindingPopup")
      nk.PopupManager:addPopup(fbBindingPopup) 
  end
end

return taskListItem