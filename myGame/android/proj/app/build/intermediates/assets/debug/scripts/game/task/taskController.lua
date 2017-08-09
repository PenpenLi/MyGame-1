-- taskController.lua
-- Data : 2016-07-19
-- Description:
-- task model
local taskController= class()
local CacheHelper = require("game.cache.cache")
local taskModel = require("game.task.taskmodel")


function taskController:ctor()
    self.allTaskList_ = {}
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end 

function taskController:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end 

function taskController:clean()
    self.allTaskList_ = nil
    self.allTaskList_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false  
    self.taskConfigData_ = nil
end

function taskController:loadTaskConfig(url,callback)
   if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false   
   end
    self.loadConfigCallback_ = callback
    self:loadConfig_()
end

function taskController:loadConfig_()
   if not self.isConfigLoaded_ and not self.isConfigLoading_ then
       self.isConfigLoading_ = true
       local cache = new(CacheHelper)
       cache:cacheFile(self.url_ or nk.userData.NEW_TASK_JSON, function(result,content,stype)
          self.isConfigLoading_ = false
          if result then
              self.isConfigLoaded_ = true
              if not self.taskConfigData_ then
                  self.taskConfigData_ = content
                  if self.taskConfigData_ == nil then
                      Log.printInfo("newtask 配置错误!!")
                  else
                      self:processTaskData(self.taskConfigData_)
                  end
                  if self.loadConfigCallback_ then
                     self.loadConfigCallback_(true, self.taskConfigData_)
                  end
              end
          end
       end,"newtask","data")
    elseif self.isConfigLoaded_ then
        self:processTaskData(self.taskConfigData_)
        if self.loadConfigCallback_ then
             self.loadConfigCallback_(true, self.taskConfigData_)
        end
    end
end

function taskController:processTaskData(data)
    self.allTaskList_ = nil
    self.allTaskList_ = {}
    local currentVar = nk.updateFunctions.getVersionNum(GameConfig.CUR_VERSION)
    if data then
      for k,v in pairs(data) do
          if not v.ver or nk.updateFunctions.getVersionNum(v.ver) <= currentVar then
              local task = new(taskModel)
              task:fromJSON(v)
              table.insert(self.allTaskList_,task)
          end
      end
    end
end

function taskController:requestTaskData(callback)
   self.taskDataCallBack_ = callback
   nk.HttpController:execute("Task.getNewAllTask", {game_param ={type = 3}})
end

function taskController:requestReward(task,stageNum,callback)
    self.rewardTask_ = nil
    self.rewardTask_ = task
    self.rewardCallBack_ = callback
    local param = {}
    param.tid = task.id
    if stageNum then param.num = stageNum end

    nk.HttpController:execute("Task.awardTask", {game_param= param})
end

function taskController:setTaskCanGetNum()
    local numDay = 0
    local numGrow = 0
    local num = 0
    for k, v in pairs(self.allTaskList_) do
        if v.status == taskModel.STATUS_CAN_REWARD and checkint(v.taskType) == 2 then
            numDay = numDay + 1
        end
        if v.status == taskModel.STATUS_CAN_REWARD and checkint(v.taskType) == 4 then
            numGrow = numGrow + 1
        end
        if checkint(v.taskType)==5 then
            numDay = numDay + table.nums(v.exCanGet)
        end
    end

    num = numDay + numGrow

    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}

    if numDay > 0 then       
        datas["TaskDayPoint"] = true
    else
        datas["TaskDayPoint"] = false
    end

    if numGrow > 0 then
        datas["TaskGrowPoint"] = true
    else
        datas["TaskGrowPoint"] = false
    end

    if num <= 0 then 
        datas["TaskMainPoint"] = false
    end
    
    EventDispatcher.getInstance():dispatch(EventConstants.FREE_CHIP_CAN_GET_REWARD_NUM, num)
end

function taskController:getTaskCanGetNum()
    local num = 0
    for k, v in pairs(self.allTaskList_) do
        if v.status == taskModel.STATUS_CAN_REWARD then
            num = num + 1
        end
        if checkint(v.taskType)==5 then
            num = num + table.nums(v.exCanGet) 
        end
    end
    return num
end

function taskController:onHttpProcesser(command, errorCode, content)
    if command == "Task.getNewAllTask" then
      if errorCode ~= HttpErrorType.SUCCESSED then
          return 
      end
      if not content or content.code ~= 1 then
          return
      end

      local info = content.data
      local progressData = info.progressDaily
      for i,v in ipairs(self.allTaskList_) do
           if progressData[v.id] then
               local decodeData = progressData[v.id]
               v.progress = decodeData[1][2]
               if v.progress >= v.target then
                   v.progress = v.target
                   v.status = taskModel.STATUS_CAN_REWARD
               else
                   v.status = taskModel.STATUS_UNDER_WAY
               end

               if checkint(v.taskType) == 5 then       --额外奖励，当做任务，只有一个，type固定为"5",不要问我为什么这样，因为php就是这么搞的，so.....
                   local element =  checktable(decodeData[1][4])   -- 已经领取的额外奖励
                   for j,w in ipairs(v.exReward) do                   
                      if not table.keyof(element, w) then
                          if v.progress >= w then
                              v.exCanGet[w] = true     --额外奖励的数量到达，并且还没有领取
                          end
                      end
                   end

                   for m,n in ipairs(element) do
                        if not table.keyof(v.exGetList, n) then
                            table.insert(v.exGetList, n)
                        end                        
                   end
                   
               end
           else
               v.progress = v.target
               v.status = taskModel.STATUS_FINISHED
           end
      end
      table.sort(self.allTaskList_, function(a,b) return tonumber(a.id) < tonumber(b.id) end ) 
      table.sort(self.allTaskList_, function(a,b) return a.status < b.status end )    

      if self.taskDataCallBack_ then
          self.taskDataCallBack_(true, self.allTaskList_)
      end

      self:setTaskCanGetNum()
    elseif command == "Task.awardTask" then
      if errorCode ~= HttpErrorType.SUCCESSED then
          return 
      end
      if not content or content.code ~= 1 then
          return
      end
      local info = content.data
     
      local index = -1
      for i,v in ipairs(self.allTaskList_) do
         if v.id == self.rewardTask_.id then
             index = i
             break
         end
      end
      table.remove(self.allTaskList_,index)

      if info.money and info.addMoney then
          nk.functions.setMoney(info.money)
          nk.TopTipManager:showTopTip(bm.LangUtil.getText("DAILY_TASK", "CHIP_REWARD", info.addMoney))
      end

  --    if checkint(self.rewardTask_.taskType) == 5 then
  --       -- self.rewardTask_.progress = info.num         --达到额外任务数量
  --    end
      
      self.rewardTask_.status = taskModel.STATUS_FINISHED
      table.insert(self.allTaskList_, self.rewardTask_)  

      if self.rewardCallBack_ then
          self.rewardCallBack_(true, self.allTaskList_)
      end

      self:setTaskCanGetNum()  
    end
end

return taskController