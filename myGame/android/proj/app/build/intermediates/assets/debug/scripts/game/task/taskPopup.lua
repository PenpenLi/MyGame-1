-- TaskPopup.lua
-- Data : 2016-07-19
-- Last modification : 
-- Description:
local PopupModel = import('game.popup.popupModel')
local taskView = require(VIEW_PATH .. "task.task_layer")
local taskInfo = VIEW_PATH .. "task.task_layer_layout_var"
local taskListItem = require("game.task.taskListItem")
local taskModel = require("game.task.taskmodel")
local TaskPopup= class(PopupModel);

function TaskPopup.show(data)
	PopupModel.show(TaskPopup, taskView, taskInfo, {name="TaskPopup"}, data)
end

function TaskPopup.hide()
	PopupModel.hide(TaskPopup)
end

function TaskPopup:ctor(viewConfig)
	Log.printInfo("TaskPopup.ctor")
    self:addShadowLayer()
    --隐藏大厅红点
--    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE)
--    if datas then
--        datas["TaskMainPoint"] = false
--    end
    
    self.currTab_ = 1
    self:init_widget()
    self.listData_ = {}

    --先弹框，再请求数据
    self.forbidTime_id = nk.GCD.PostDelay(self, function()
                self:EventAndObserver()
                self:onTabChange(self.currTab_)  
    end, nil, 500)
 
 end

function TaskPopup:init_widget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)

    self.radio_bt_group_ = self:getUI("RadioButtonGroup")
    self.radio_bt_group_:setOnChange(self,self.radio_bt_click) 
    self.text_l_ = self:getUI("Text_l")
    self.text_l_:setText(bm.LangUtil.getText("DAILY_TASK","DAILY_TASK"))
    self.text_r_ = self:getUI("Text_r")
    self.text_r_:setText(bm.LangUtil.getText("DAILY_TASK","GROW_TASK"))
    self.radio_bt_group_:setSelected(1)

    self.listview_day_ = self:getUI("ListView_day")
    self.listview_grow_ = self:getUI("ListView_grow")

    self.image_ex_reward_ = self:getUI("Image_ex_reward")
    self.image_ex_reward_:setLevel(2)

    self.text_tip_ = self:getUI("Text_tip")
    self.text_tip_:setText(bm.LangUtil.getText("DAILY_TASK","REWARD_TIP"))

    self.image_progress_bg_ = self:getUI("Image_progress_bg")
    self.width_max_ = self.image_progress_bg_:getSize()     

    self.view_day_redPoint_ = self:getUI("Image_day_redPoint")
    self.view_day_redPoint_:setVisible(false)
    self.view_grow_redPoint_ = self:getUI("Image_grow_redPoint")
    self.view_grow_redPoint_:setVisible(false)
end

function TaskPopup:EventAndObserver()
     EventDispatcher.getInstance():register(EventConstants.getreward, self, self.setExReward)
     EventDispatcher.getInstance():register(EventConstants.messageGetRward, self, self.setLoading)
     EventDispatcher.getInstance():register(EventConstants.CloseTaskPopup, self, self.hide)
     EventDispatcher.getInstance():register(EventConstants.taskChangeData, self,self.changeData)
     self.TaskDayObserver_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "TaskDayPoint", handler(self, function(obj, visible)
            if not nk.updateFunctions.checkIsNull(obj) then
                self.view_day_redPoint_:setVisible(visible)
            end
     end))
     self.TaskGrowObserver_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "TaskGrowPoint", handler(self, function(obj, visible)
            if not nk.updateFunctions.checkIsNull(obj) then
                self.view_grow_redPoint_:setVisible(visible)
            end
     end))
end


function TaskPopup:radio_bt_click(index)
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self.currTab_ = index
    self:onTabChange(index)
end

function TaskPopup:onTabChange(index)
    self:requestListData()
    self:showListview(index)
end

function TaskPopup:showListview(index)
   local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
   if index == 1 then
     -- datas["TaskDayPoint"] = false
      self.listview_day_:setVisible(true)
      self.listview_grow_:setVisible(false)
      self.image_ex_reward_:setVisible(true)
      self.text_l_:setColor(255,255,255)
      self.text_r_:setColor(199,127,241)
   else
    --  datas["TaskGrowPoint"] = false
      self.listview_day_:setVisible(false)
      self.listview_grow_:setVisible(true)
      self.image_ex_reward_:setVisible(false)
      self.text_l_:setColor(199,127,241)
      self.text_r_:setColor(255,255,255)
   end
end

function TaskPopup:requestListData()
    self:setLoading(true)
    if #self.listData_ <= 0 then
        nk.taskController:requestTaskData(function(result, content)
            if result then
                self.listData_ = content
                self:setListData(self.listData_)
            end
        end)
    else
        self:setListData(self.listData_)
    end
end

function TaskPopup:setListData(content) 
    self:setLoading(false)
    if content then
        local info = content
        local listdata = {}
        local exReward = nil
        if self.currTab_ == 1 then
            local showPoint = false
            for i,v in ipairs(info) do
                    if checkint(v.taskType)  == 2 then   -- 2 日常任务
                        table.insert(listdata, v)
                    elseif checkint(v.taskType)  == 5 then -- 5 额外任务
                        exReward = v
                    else
                    if  v.status ==  taskModel.STATUS_CAN_REWARD then  --如果成长可以领取则显示红点
                            showPoint = true
                    end
                    end
            end
            if showPoint then
                local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
                datas["TaskGrowPoint"] = true
            end
                
            if #listdata > 0 then
                local adapter = new(CacheAdapter, taskListItem, listdata)
                self.listview_day_:setAdapter(adapter)
                self:setExReward(exReward)
            end
        elseif self.currTab_ == 2 then
            for i,v in ipairs(info) do
                    if checkint(v.taskType) == 4 then   -- 4 成长任务
                        table.insert(listdata, v)
                    end
            end
            if #listdata > 0 then
                local adapter = new(CacheAdapter, taskListItem, listdata)
                self.listview_grow_:setAdapter(adapter)
            end                                
        end
    end
end

function TaskPopup:setExReward(data)
    if not data then return end
    self.image_progress_bg_:removeAllChildren(true)

    local total_num = data.target     
    local down_num = data.progress
    if down_num >= total_num then
        down_num = total_num
    end
    self.stage_content =data.rewardDesc
    self.stage_num =data.exReward
    self.task =data

    --完成进度
    local width = (down_num/total_num)*self.width_max_
    if width>0 then
        local image_progress = new(Image,"res/common/common_progress_bar_orange_1.png",nil,nil,20,20,0,0)
        self.image_progress_bg_:addChild(image_progress)
        local _,h = image_progress:getSize()
        image_progress:setVisible(true)
        image_progress:setSize(width, h)
    end
    --领奖按钮
    for i,v in ipairs(self.stage_num) do
        local bt_tip = new(Image,"res/setting/setting_gift.png") 
        bt_tip:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                              nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                                              if data.exCanGet[v] then   --可以领取,隐藏提示
                                                  self:getReward(v, bt_tip)                                                 
                                              else
                                                  self:showTip(bt_tip, self.stage_content[tostring(v)])
                                              end 
                                          end
                                   end)  
        if data.exCanGet[v] then 
            bt_tip:addPropScale(1,kAnimLoop,200,-1,1,0.9,1,0.9,kCenterDrawing)
        else
            bt_tip:setGray(true)
        end 
        self.image_progress_bg_:addChild(bt_tip)
        bt_tip:setPos((v/total_num)*self.width_max_ - 15, -20)
        local text_stage_num = new(Text,v,nil,nil,nil,nil,20,255,255,255)
        self.image_progress_bg_:addChild(text_stage_num)
        text_stage_num:setPos((v/total_num)*self.width_max_ - 5, 23)
    end  
end

function TaskPopup:showTip(node, content)
    nk.AnalyticsManager:report("New_Gaple_task_reward", "task")

   if self.image_tip_ then
        if self.image_tip_:getParent() then
          self.image_tip_:getParent():removeChild(self.image_tip_,true)
          self.image_tip_ = nil 
        end
   end
  
   self.image_tip_ = new(Image,"res/common/common_tip.png",nil,nil,10,33,10,25)
   self.image_tip_:setAlign(kAlignBottomRight)
   self.image_tip_:setPos(0,50)
   node:addChild(self.image_tip_)
   self.image_tip_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                              nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                                              self.image_tip_:getParent():removeChild(self.image_tip_,true)
                                              self.image_tip_ = nil
                                          end
                                end) 
   local filteredText = string.gsub(content,"\\n","");
   local text_tip = new(TextView,filteredText,100,nil,kAlignCenter,"",16,255,255,255)
   text_tip:setAlign(kAlignCenter)
   text_tip:setPickable(false)
   self.image_tip_:addChild(text_tip)
   text_tip:setPos(0,-5)
   local w,h = text_tip:getSize()

   self.image_tip_:setSize(w,h+30)
end 

function TaskPopup:getReward(stageNum, node)
   local stage = stageNum
   local tip = node
   self:setLoading(true)
   nk.taskController:requestReward(self.task,stageNum, function(result, content)
       self:setLoading(false)
       if result then
            if tip then
                tip:doRemoveProp(1)
                tip:setGray(true)
            end
            nk.PopupManager:addPopup(require("game.popup.rewardPopup"),"TaskPopup",{{name=self.stage_content[tostring(stageNum)],icon =kImageMap.common_coin_107}}) 
            local info = content
            for i,v in ipairs(info) do
                if checkint(v.taskType) == 5 then
                    v.exCanGet[stage] = nil
                    table.insert(v.exGetList, stage)
                    self:setExReward(v)
                end
            end
       end
    end)
end

function TaskPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.image_bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function TaskPopup:changeData(iType, data)
    if iType == 2 then
        self.listview_day_:getAdapter():changeData(data)
    elseif iType == 4 then
        self.listview_grow_:getAdapter():changeData(data)
    end
end

function TaskPopup:DisEventAndObserver()
    EventDispatcher.getInstance():unregister(EventConstants.getreward, self, self.setExReward)
    EventDispatcher.getInstance():unregister(EventConstants.messageGetRward, self, self.setLoading)
    EventDispatcher.getInstance():unregister(EventConstants.CloseTaskPopup, self, self.hide)
    EventDispatcher.getInstance():unregister(EventConstants.taskChangeData, self,self.changeData)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "TaskDayPoint", self.TaskDayObserver_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "TaskGrowPoint", self.TaskGrowObserver_)
end

function TaskPopup:dtor()
    Log.printInfo("TaskPopup.dtor")
    self.listData_ = {}
    self:DisEventAndObserver()
    if self.forbidTime_id then
        nk.GCD.CancelById(self,self.forbidTime_id)
        self.forbidTime_id = nil
    end
    nk.taskController.taskDataCallBack_ = nil
    nk.taskController.rewardCallBack_ = nil
end 


return TaskPopup