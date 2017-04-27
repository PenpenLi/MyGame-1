--
-- Author: tony
-- Date: 2014-07-10 15:04:44
--
local RoomQiuQiuStateMachine = class()
local StateMachine = require("game.common.component.stateMachine")

--事件
RoomQiuQiuStateMachine.Evt_GAME_START = "tra_gamestart" --游戏开始
RoomQiuQiuStateMachine.Evt_SIT_DOWN = "tra_sitdown"
RoomQiuQiuStateMachine.Evt_STAND_UP = "tra_standup"
RoomQiuQiuStateMachine.Evt_CALL = "tra_call"   --跟注
RoomQiuQiuStateMachine.Evt_CEK = "tra_cek"    --看牌
RoomQiuQiuStateMachine.Evt_RAISE = "tra_raise"   --加注，第一个下注的人也是加注
RoomQiuQiuStateMachine.Evt_ALL_IN = "tra_allin" --all in
RoomQiuQiuStateMachine.Evt_GIVE_UP = "tra_give_up"  --弃牌
RoomQiuQiuStateMachine.Evt_TURN_TO = "tra_turnto"         --轮到该玩家操作
RoomQiuQiuStateMachine.Evt_CONFIRM_CARD = "tra_confirm_card" --确认牌型阶段
RoomQiuQiuStateMachine.Evt_GAME_OVER = "tra_gameover"     --游戏结束

--状态机
RoomQiuQiuStateMachine.STATE_EMPTY        = "st_empty"        --空座     --无人物
RoomQiuQiuStateMachine.STATE_WAIT_START    = "st_waitstart"    --等待开始      --头像灰
RoomQiuQiuStateMachine.STATE_WAITING    = "st_waitingOther"    --等待他人操作  --头像亮，如果是刚操作完就显示加注等等，否则显示名字
RoomQiuQiuStateMachine.STATE_BETTING         = "st_betting"        --下注中    --头像亮,显示自己的名字
RoomQiuQiuStateMachine.STATE_ALL_IN         = "st_allin_waitget"        --AllIn  --头像亮,显示allin
RoomQiuQiuStateMachine.STATE_FOLD           = "st_give_up"        --弃牌         --头像灰，显示弃牌
RoomQiuQiuStateMachine.STATE_CONFIRM  = "st_confirmcard"  -- 确认牌型阶段      --头像亮,显示自己的名字

-- states.USER_STATE_READY             = 0         --准备,等待状态,(坐下，其他人在玩牌)
-- states.USER_STATE_CEKPOKER          = 1         --已经选择看牌 
-- states.USER_STATE_CALL              = 2         --已经选择跟注 
-- states.USER_STATE_LKUT              = 3         --已经选择加注 
-- states.USER_STATE_GIVEUP            = 4         --已经选择弃牌
-- states.USER_STATE_ALLIN             = 5         --已经allin 
-- states.USER_STATE_CHOICE            = 6         --正在选择 
-- states.USER_STATE_WAITOTHER         = 7         --等待其它人选择
-- states.USER_STATE_STAND             = 8         --站立围观状态(服务器用)

-- states.TABLE_CLOSE              = 0     --关闭状态, 桌子上无人
-- states.TABLE_OPEN               = 1    --桌子上有人，但人数不够开局，比如说一个人
-- states.TABLE_READY              = 2 --满开局人数条件后，2s后开始游戏
-- states.TABLE_BET_ROUND          = 3 --三张牌加注状态
-- states.TABLE_BET_ROUND_4card    = 4 --四张牌加注状态
-- states.TABLE_CHECK              = 5     --确认点数组合状态,结算前玩家调整牌组合
-- states.TABLE_GAME_OVER              = 6     --结算状态 , 结算时，更新金币信息，此状态前端用不上
-- states.TABLE_GAME_OVER_SHARE_BONUS  = 7     --结算时，亮牌，分奖池

function RoomQiuQiuStateMachine:ctor(seatData , gameStatus)
    seatData.userInfo.name = string.trim(seatData.userInfo.name)
    --默认状态写名字
    self.stateDefault_ = nk.updateFunctions.limitNickLength(seatData.userInfo.name,8)
    self.statetext_ = self.stateDefault_
    self.seatId_ = seatData.seatId

    local initialState = RoomQiuQiuStateMachine.STATE_EMPTY

    self.statemachine_ = {}
    nk.GameObject.extend(self.statemachine_)
        :addComponent("game.common.component.stateMachine")
        :exportMethods()
    self.statemachine_:setupState({
        initial = initialState,
        events = {
            --收到游戏开始包，从等待游戏开始状态到等待他人状态
            {name=RoomQiuQiuStateMachine.Evt_GAME_START, from="*", to=RoomQiuQiuStateMachine.STATE_WAITING},
            --设置新坐下的人，从空位置状态到等待游戏开始状态
            {name=RoomQiuQiuStateMachine.Evt_SIT_DOWN, from="*", to=RoomQiuQiuStateMachine.STATE_WAIT_START},
            --任何时候站起，都设置空位置
            {name=RoomQiuQiuStateMachine.Evt_STAND_UP, from="*", to=RoomQiuQiuStateMachine.STATE_EMPTY},           
            --跟注，从下注状态到等待状态 (有可能不是下注状态，重连进来或者坐下等待，没有turnto这个包，状态不是betting)
            {name=RoomQiuQiuStateMachine.Evt_CALL, from="*", to=RoomQiuQiuStateMachine.STATE_WAITING},
            --看牌，从下注状态到等待状态
            {name=RoomQiuQiuStateMachine.Evt_CEK, from="*", to=RoomQiuQiuStateMachine.STATE_WAITING},
            --加注，从下注状态到等待状态
            {name=RoomQiuQiuStateMachine.Evt_RAISE, from="*", to=RoomQiuQiuStateMachine.STATE_WAITING},
            --allin所有钱，从下注状态到allin状态
            {name=RoomQiuQiuStateMachine.Evt_ALL_IN, from="*", to=RoomQiuQiuStateMachine.STATE_ALL_IN},
            --弃牌，从下注状态到弃牌
            {name=RoomQiuQiuStateMachine.Evt_GIVE_UP, from="*", to=RoomQiuQiuStateMachine.STATE_FOLD},
            --轮到该玩家，从等待状态到下注状态,或者从allin状态到下注状态(此时会直接发包看牌)---有可能从下注状态到下注状态，登陆进来server指定了当前行动者，且已经广播过了，我没收到此包，此时betting未能转waiting(广播操作和广播下个人有时间差)
            {name=RoomQiuQiuStateMachine.Evt_TURN_TO, from="*", to=RoomQiuQiuStateMachine.STATE_BETTING}, 
            --确认牌型阶段,下注或者等待他人或者allin都可以转到确认牌型状态
            {name=RoomQiuQiuStateMachine.Evt_CONFIRM_CARD, from="*", to=RoomQiuQiuStateMachine.STATE_CONFIRM}, 
            
            {name=RoomQiuQiuStateMachine.Evt_GAME_OVER, from="*", to=RoomQiuQiuStateMachine.STATE_WAITING},
            
            {name="reset", from="*", to=RoomQiuQiuStateMachine.STATE_EMPTY}
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState_)
        }
    })

    --doEvent设置当前状态名
    --桌子状态还没开始，用人物名字
    if gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_OPEN or gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_READY 
        or gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_CLOSE
        then
        self:doEvent(RoomQiuQiuStateMachine.Evt_SIT_DOWN)
    --若桌子状态为游戏过程阶段
    elseif gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_BET_ROUND or gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_BET_ROUND_4card then
        
        if seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_CEKPOKER then
            self:doEvent(RoomQiuQiuStateMachine.Evt_CEK)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_CALL then
            self:doEvent(RoomQiuQiuStateMachine.Evt_CALL)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_LKUT then
            self:doEvent(RoomQiuQiuStateMachine.Evt_RAISE)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_ALLIN then
            self:doEvent(RoomQiuQiuStateMachine.Evt_ALL_IN)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_GIVEUP then
            self:doEvent(RoomQiuQiuStateMachine.Evt_GIVE_UP)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_CHOICE then
            self:doEvent(RoomQiuQiuStateMachine.Evt_TURN_TO)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_WAITOTHER then
            self:doEvent(RoomQiuQiuStateMachine.Evt_GAME_START)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_READY then
            self:doEvent(RoomQiuQiuStateMachine.Evt_SIT_DOWN)
        end

    elseif gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_CHECK then
        if seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_GIVEUP then
            self:doEvent(RoomQiuQiuStateMachine.Evt_GIVE_UP)
        elseif seatData.userStatus == consts.SVR_BET_STATE.USER_STATE_READY then
            self:doEvent(RoomQiuQiuStateMachine.Evt_SIT_DOWN)
        else
            self:doEvent(RoomQiuQiuStateMachine.Evt_CONFIRM_CARD)
        end
    --桌子状态结束，用人物名字
    elseif gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_GAME_OVER or gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_GAME_OVER_SHARE_BONUS then   --结算
        self:doEvent(RoomQiuQiuStateMachine.Evt_GAME_OVER)
    end
    
end

function RoomQiuQiuStateMachine:getStateText()
    return self.statetext_
end

function RoomQiuQiuStateMachine:getStateTextColor()
    if self.statetext_==self.stateDefault_ then
        return 255,255,0
    else
        return 0,255,35
    end
end

function RoomQiuQiuStateMachine:getStateDefaultText()
    return self.stateDefault_
end

function RoomQiuQiuStateMachine:setStateText(txt)
    self.statetext_ = txt
end

function RoomQiuQiuStateMachine:getState()
    return self.statemachine_:getState()
end

function RoomQiuQiuStateMachine:doEvent(name, ...)

    if self.statemachine_:canDoEvent(name) then
        self.statemachine_:doEvent(name, ...)
    else
        Log.printInfo("%s Can't do event %s on state %s", self.seatId_, name, self.statemachine_:getState())
        self.statemachine_:doEventForce(name, ...)
    end
end

function RoomQiuQiuStateMachine:onChangeState_(evt)
    Log.printInfo("onChangeState_onChangeState_onChangeState_onChangeState_")
    Log.printInfo("seat%s %s do event %s from %s to %s", self.seatId_,self.stateDefault_, evt.name, evt.from, evt.to)
    
    local st = evt.to
    local evt = evt.name

    self.statetext_ = self.stateDefault_
    if st == RoomQiuQiuStateMachine.STATE_EMPTY then
        self.statetext_ = ""
    elseif st == RoomQiuQiuStateMachine.STATE_FOLD then
        self.statetext_ = T("弃牌")
    elseif st == RoomQiuQiuStateMachine.STATE_ALL_IN then
        self.statetext_ = T("ALL IN")
    elseif st == RoomQiuQiuStateMachine.STATE_WAITING then
        if evt == RoomQiuQiuStateMachine.Evt_CEK then
            self.statetext_ = T("看牌")
        elseif evt == RoomQiuQiuStateMachine.Evt_CALL then
            self.statetext_ = T("跟注")
        elseif evt == RoomQiuQiuStateMachine.Evt_RAISE then
            self.statetext_ = T("加注")
        else
            self.statetext_ = self.stateDefault_
        end
    end
end

return RoomQiuQiuStateMachine
