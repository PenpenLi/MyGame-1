--
-- Author: ziway
-- Date: 2016-12-12 17:25:47
--
local limitTimeEventModel = class()


function limitTimeEventModel:ctor()
end

function limitTimeEventModel:dtor()
end

function limitTimeEventModel:setModel(obj)
	if obj == nil then
		obj = {}
	end
	self.image = obj.image or ""                 --图片地址
    self.desc = obj.desc or ""                   --规则说明
    self.btn_name = obj.btn_name or ""           --按钮名称
    self.btn_url = obj.btn_url or ""             --按钮跳转
    self.ext = obj.ext or ""                 	 --活动开展字段
    self.num = checkint(obj.num)                 --任务目标数量
    self.prize = obj.prize or ""                 --奖励名称
    self.prize_icon = obj.prize_icon or ""       --奖励奖品图片

    self.etime = obj.etime or 0   --结束时间戳
    self.stime = obj.stime or 0   --开始时间时间戳
    self.task_type = obj.task_type or "friend"  --任务类型
    self.unit = obj.unit or ""   --奖品单位

    --要从接口拿的数据，这里先自己初始化
    self.curNum = 0								 --当前数量
    self.prizeStatus = 0                         --“领取状态”  0未达成，1可领取，2 已领取
end

function limitTimeEventModel:setData(obj)
    if obj == nil then
        obj = {}
    end
    self.prizeStatus = checkint(obj.prizeStatus)
    self.curNum = checkint(obj.counts)
end

return limitTimeEventModel