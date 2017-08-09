--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 17:19:48
--

local taskModel = class()

--未完成
taskModel.STATUS_UNDER_WAY = 1
--可领取
taskModel.STATUS_CAN_REWARD = 0
--已领取
taskModel.STATUS_FINISHED = 2

taskModel.STATUS_BIG_VALUE = 100
taskModel.ID_DAILY_SIGN_IN = 10000

function taskModel:ctor()

end

function taskModel:fromJSON(jsonData)
    --任务类型（目前3类：2 日常任务，4 成长任务, 5 额外奖励）
    self.taskType = jsonData.type
    --任务id
    self.id = jsonData.tid
    --标题
    self.name = jsonData.tname
    --描述
    self.desc = jsonData.tdesc 
    --奖励描述
    self.rewardDesc = jsonData.adesc
    --状态
    self.status = taskModel.STATUS_UNDER_WAY
    --进度
    self.progress = 0
    self.isSpecial = jsonData.special
    --icon
    self.iconUrl = jsonData.icon or ""
    --目标
    local tcontents = json.decode(jsonData.tcontents)
    if tcontents then   
        --类型，详见任务条件列表配置
        self.actType = tonumber(tcontents[1][1])
        if checkint(self.taskType) == 5 then
           --额外任务阶段
           self.exReward = {}
           --额外任务是否领取
           self.exCanGet ={}
           --已经领取列表
           self.exGetList = {}
           for i,v in ipairs(tcontents) do
                table.insert(self.exReward, v[2])
           end   
           self.target = tcontents[#tcontents][2]      
        else
           --目标
           self.target = tonumber(tcontents[1][2])
        end
        --场次等级
        self.actLevel = tonumber(tcontents[1][3])
        --场次类型(0和1=接龙; 2=99)
        self.gameType = tonumber(tcontents[1][4])
    else
        self.target = 9999   
        self.actType = 0
        self.actLevel = 0
    end
end


return taskModel