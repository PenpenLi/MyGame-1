-- activityNativeEvent.lua
-- Last modification : 2016-05-24
-- Description: a native event controller for activity normal function moudle

local ActivityNativeEvent = class(GameBaseNativeEvent)
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function ActivityNativeEvent:ctor()
    
end

function ActivityNativeEvent:dtor()
    
end

-- 活动中心初始化
function ActivityNativeEvent:activityInit(content)
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_ACTIVITY_INIT, kCallParamJsonString, content)
    if DEBUG > 0 then
        self:activityCutServer(1)  --测试服
    else
        self:activityCutServer(0)  --正式服
    end
end

-- 切换活动中心（正/测）
function ActivityNativeEvent:activityCutServer(content)
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_ACTIVITY_CUT_SERVER, kCallParamInt, content)
end

-- 打开活动中心
function ActivityNativeEvent:activityOpen()
    Log.printInfo("ActivityNativeEvent", "activityOpen")
    nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_ACTIVITY_OPEN, kCallParamNo)
end

-- 活动中心公共跳转参数 
-- {"target":"activityNumber","count":1}
-- 0 : ["大厅",'{"target":"lobby"}'],
-- 1 : ["房间",'{"target":"room","desc":"match"}'],
-- 2 : ["开始游戏",'{"target":"room","desc":"game"}'],
-- 3 : ["商城/商城",'{"target":"store"}'],
-- 4 : ["充值",'{"target":"recharge","count":"10","type":"coin"}'],
-- 5 : ["好友",'{"target":"friend"}'],
-- 6 : ["反馈/帮助",'{"target":"feedback"}'],
-- 7 : ["每日必做/任务",'{"target":"task"}'],
-- 8 : ["排行榜",'{"target":"rank"}'],
-- 9 : ["兑奖/兑换",'{"target":"propstore"}'],
-- 10 : ["用户信息",'{"target":"info"}']
function ActivityNativeEvent:aboutJSON(target,count,desc,typeActivity)
    Log.printInfo("ActivityNativeEvent","---->about activity back json target="..target.." count="..count.." desc="..desc.." typeActivity="..typeActivity)
    if target=="activityNumber" then
        if count>0 then
            if nk.userData then
                nk.userData.activityNum = count
            end
        end
    elseif target=="lobby" or target=="room" or target=="99room" then                               --到大厅 or 到房间
        -- 功能不提清楚 暂时屏蔽  jasonLi
        --广播出去 如果把登陆等独立出来，我认为会更好。
        -- bm.EventCenter:dispatchEvent({name = nk.eventNames.HALL_ACTIVITY_TO_ROOM, data ={target=target,count=count,desc=desc,typeActivity=typeActivity}})
    elseif target=="store" or target=="recharge" then                                                 --到商城
        local StorePopup = require("game.store.popup.storePopup")
        nk.PopupManager:addPopup(StorePopup, "hall")
    elseif target=="friend" then                                                --到好友
        StateMachine.getInstance():pushState(States.Friend, nil, nil, 2)
    elseif target=="feedback" then                                              --到反馈
        local FeedbackPopup = require("game.setting.feedbackLayer")
        nk.PopupManager:addPopup(FeedbackPopup,"hall")  
    elseif target=="task" then                                                  --到任务
        local TaskPopup = require("game.task.taskPopup")
        nk.PopupManager:addPopup(TaskPopup,"hall") 
    elseif target=="rank" then                                                  --到排行榜
        StateMachine.getInstance():pushState(States.Rank)
    elseif target=="propstore" then                                             --到兑奖、兑换
        local FansCodePopup = require("game.freeGold.fansCodePopup")
        nk.PopupManager:addPopup(FansCodePopup,"hall")  
    elseif target=="info" then                                              --到个人信息
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "hall")
    elseif target=="invite" then                                                --邀请界面
        local InviteScene = require("game.invite.inviteScene")
        nk.PopupManager:addPopup(InviteScene,"hall")
    elseif target=="fans" then                                                  --到粉丝页
        if nk.UpdateConfig and nk.UpdateConfig.facebookFansUrl then
            nk.GameNativeEvent:openBrowser(bm.LangUtil.getText("ABOUT", "FANS_URL"))
        end
    elseif target=="recharge" and desc=="first" then                             --首充
        -- cocos 版本也是屏蔽的
        -- if nk.userData["firstPay"] and nk.userData["firstPay"]==0 then
        --     FirstGiftBagPopup.new()
        -- else
        --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("ACTIVITY", "NO_FIRST_PAY"))
        -- end
    else
        
    end
end

---------------------------------nativeHandle-----------------------------------

function ActivityNativeEvent:onActivityResult_(status, result)
	Log.printInfo("ActivityNativeEvent", "onActivityResult_ result", result)
	if status then
        print("---->initActivity success")
        local target=""
        local count = 0
        local desc = ""
        local typeActivity =""

        local dataActivity = result
        if dataActivity["target"] then
            target=dataActivity["target"]
        end
        if dataActivity["count"] then
            count=dataActivity["count"]
        end
        if dataActivity["desc"] then
            desc=dataActivity["desc"]
        end
        if dataActivity["type"] then
            typeActivity=dataActivity["type"]
        end

        self:aboutJSON(target,count,desc,typeActivity)
    else
        print("---->ActivityCallBack fail")
        nk.TopTipManager:showTopTip(T("获取活动失败，请重试")) 
    end
end

ActivityNativeEvent.s_nativeHandle = {
    -- ["***"] = function
    [NativeEventConfig.NATIVE_ACTIVITY_CALLBACK] = ActivityNativeEvent.onActivityResult_,
}

return ActivityNativeEvent