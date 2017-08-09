-- enterRoomManager.lua
-- Last modification : 2016-06-20
-- Description: a manager in rank moudle, to manage all rank data
-- Offer Instance

EnterRoomManager = class()
local EnterRoomLoadingAnim = require("game.anim.enterRoomLoadingAnim")
local BankruptHelpPopup = require("game.bankrupt.bankruptHelpPopup")
local BlurWidget = require("libEffect.shaders.blurWidget")

local RoomQiuqiuBlurConfig = {["bg"] = true, ["tableNode"] = {["leftTableImage"] = true, ["rightTableImage"] = true, ["tableMarkImage"] = true}, ["dealerNode"] = {["dealerImage"] = true}}
local RoomGapleBlurConfig = {["backgroundNode"] = {}}

function EnterRoomManager.getInstance()
    if not EnterRoomManager.s_instance then
        EnterRoomManager.s_instance = new(EnterRoomManager)
    end
    return EnterRoomManager.s_instance
end

function EnterRoomManager:ctor()
    self.m_isEnterRooming = false
end

function EnterRoomManager:dtor()
    if self.m_loading then
        delete(self.m_loading)
    end
end

function EnterRoomManager:enterRoomSuccess()
    self:releaseLoading()
end

function EnterRoomManager:isEnterRooming()
    return self.m_isEnterRooming
end

-- 进入gaple玩法房间
-- args = {
    -- serverid @房间等级
-- }
function EnterRoomManager:enterGapleRoom(args)
    -- TODO
    -- if not nk.SocketController:isLogin() then
    --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    --     return
    -- end
    if self.m_isEnterRooming then
        return
    end
    -- TODO 进入房间的流程应该先getRoomCofig，在获取回调中处理（此时可以显示loading动画），否则直接getData可能并没有数据

    -- nk.RoomConfigController:getRoomCofig(
    --     handler(self, function()
    --         -- 判断最小携带
            local level = nil
            if args == nil or (args and tonumber(args.serverid) == 0) then
                level = nk.functions.getRoomLevelByMoney(nk.functions.getMoney())
                if level == 0 or not level then
                    local tableConf = nk.DataProxy:getData(nk.dataKeys.TABLE_NEW_CONF)  
                    if tableConf and tableConf[1] and tableConf[1][1] and tableConf[1][1].serverid then
                        level = tableConf[1][1].serverid
                    end
                end
            else
                level = args.serverid
            end

            level = tonumber(level or 0)
            if level and level > 0 then
                local roomData = nk.functions.getRoomDataByLevel(level)
                if roomData then
                    if nk.functions.getMoney() >= roomData.minBuyIn then
                        local ret = nk.SocketController:getRoomAndLogin(level, 0)
                        if ret then
                            self:enterRoomLoading(States.RoomGaple, 1, roomData.backdrop)
                        else
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL_2"))
                        end
                    else
                        -- 破产
                        if nk.userData.bankruptcyGrant and nk.functions.getMoney() < nk.userData.bankruptcyGrant.maxBmoney then
                        -- and nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                                nk.payScene = consts.PAY_SCENE.CHOOSE_GAPLE_ROOM_BANKRUPTCY_PAY
                                nk.PopupManager:addPopup(BankruptHelpPopup, "hall")
                        -- 金币不足
                        else
                            self:noEnoughRoomEnter("gaple")
                        end
                    end
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "REQUIRE_LATER"))
            end
        -- end))
end

-- 进入99玩法房间
-- args = {
    -- serverid @房间等级
-- }
function EnterRoomManager:enter99Room(args)
    -- TODO
    -- if not nk.SocketController:isLogin() then
    --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    --     return
    -- end
    if self.m_isEnterRooming then
        return
    end
    -- 判断最小携带
    local level = nil
    if args == nil then
        level = nk.functions.getRoomQiuQiuLevelByMoney(nk.functions.getMoney())
        if level == 0 or not level then
            local tableConf = nk.DataProxy:getData(nk.dataKeys.TABLE_99_NEW_CONF)     
            if tableConf and tableConf[1] and tableConf[1][1] and tableConf[1][1].serverid then
                level = tableConf[1][1].serverid
            end
        end
    else
        level = args.serverid  --某个具体的房间配置(是个数组类型，数据结构详细见function的getRoomDataByLevel方法)，roomlevel是索引1,活动中心跳转房间那里只模拟了roomlevel
    end

    level = tonumber(level or 0)
    if level and level > 0 then
        local roomData = nk.functions.getRoomQiuQiuDataByLevel(level)
        if roomData then
            if nk.functions.getMoney() > roomData.maxEnter and roomData.maxEnter ~= 0 then
                self:overRoomMaxEnter(roomData.maxEnter, "qiuqiu")
            elseif nk.functions.getMoney() >= roomData.minEnter then
                local ret = nk.SocketController:getRoomAndLogin(level, 0)
                if ret then
                    self:enterRoomLoading(States.RoomQiuQiu, 2, roomData.backdrop)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL_2"))
                end
            else
                -- 破产
                if nk.userData.bankruptcyGrant and nk.functions.getMoney() < nk.userData.bankruptcyGrant.maxBmoney then
                  --  nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                        nk.payScene = consts.PAY_SCENE.CHOOSE_QIUQIU_ROOM_BANKRUPTCY_PAY
                        nk.PopupManager:addPopup(BankruptHelpPopup, "hall")
                
                -- 金币不足
                else
                    self:noEnoughRoomEnter("qiuqiu")
                end
            end
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "REQUIRE_LATER"))
    end
end

-- 进入房间loading动画
function EnterRoomManager:enterRoomLoading(stateId, roomType, backdrop)
    -- 添加加载loading    
    self.m_isEnterRooming = true
    local state = StateMachine.getInstance():getRunningState()
    -- Clock.instance():schedule_once(function()
        if not self.m_loading then
            -- self:blurTheScene(state)
            self.m_loading = new(EnterRoomLoadingAnim, roomType or 1)
        end
        local blurPic
        if stateId == States.RoomQiuQiu then
            local dict = {"blur_green.jpg", "blur_purple.jpg", "blur_red.jpg"}
            blurPic = dict[(checkint(backdrop) + 1)]
        else
            local dict = {"blur_purple_gaple.jpg", "blur_green_gaple.jpg", "blur_red_gaple.jpg"} 
            blurPic = dict[(checkint(backdrop) + 1)]
        end
        self.m_loading:onLoadingStart(IS_RELEASE and 9000 or 500, nil, handler(self, self.onEnterRoomCancelled), blurPic)
        if stateId then
            local state = nil
            -- Clock.instance():schedule_once(function()
                    if state == nil then
                        -- local t = os.clock()
                        state = StateMachine.getInstance():changeState(stateId)
                        -- local last = os.clock() - t
                        -- print_to_screen("it cost " .. last .. " to change state")
                    end
                    -- self.clock = Clock.instance():schedule(function()
                    --     if state and state.stateObj and state.stateObj.m_controller and state.stateObj.m_controller.m_view and state.stateObj.m_controller.m_view.m_isLoaded then
                    --         if self.blurWidget then
                    --             BlurWidget.removeBlur(self.blurWidget)
                    --         end
                    --         local blurConf 
                    --         if stateId == States.RoomQiuQiu then
                    --             blurConf = RoomQiuqiuBlurConfig
                    --         else
                    --             blurConf = RoomGapleBlurConfig
                    --         end
                    --         local changeList 
                    --         if blurConf then
                    --             changeList = {}
                    --             self:handleViewWithBlurConfig(state.stateObj.m_controller.m_view.m_root, blurConf, changeList)
                    --         end
                    --         self.blurWidget = BlurWidget.createBlurWidget(state.stateObj.m_controller.m_view, {intensity = 4, onRoot = false})
                    --         self.blurWidget.pos = Point(0, -8) 
                    --         if changeList then self:revertView(changeList) end
                    --         Window.instance().drawing_root:add(self.blurWidget) -- 刚好覆盖了 scene，但不会被loading覆盖                
                    --         self.clock = nil
                    --         return true
                    --     end
                    -- end, 0)
            -- end, 0.1)
        end
    -- end, 0.1)
end

function EnterRoomManager:blurTheScene(state)
    if self.blurWidget then BlurWidget.removeBlur(self.blurWidget) end
    self.blurWidget = BlurWidget.createBlurWidget(state.stateObj.m_controller.m_view, {intensity = 4, onRoot = false})
    -- self.blurWidget.pos = Point(0, -8) 
    Window.instance().drawing_root:add(self.blurWidget) -- 刚好覆盖了 scene，但不会被loading覆盖  
end

function EnterRoomManager:exitRoomLoading(...)
    self:connectRoomLoading(...)
end

function EnterRoomManager:connectRoomLoading(time, msg, onCancelCallback)
    if not self.m_loading then
        self.m_loading = new(EnterRoomLoadingAnim)
    end
    self.m_loading:onLoadingStart(IS_RELEASE and (time or 9000) or 500, msg, onCancelCallback)
    local stateMachine = StateMachine.getInstance()
    local currentState = stateMachine.m_states[#stateMachine.m_states]
    if currentState and currentState.stateObj.m_controller and currentState.stateObj.m_controller.m_view then
        if self.blurWidget then
            BlurWidget.removeBlur(self.blurWidget)
        end
        self.blurWidget = BlurWidget.createBlurWidget(currentState.stateObj.m_controller.m_view, {intensity = 4})
        self.blurWidget.pos = Point(0, -10) 
        Window.instance().drawing_root:add(self.blurWidget)
    end
end

function EnterRoomManager:onEnterRoomCancelled()
    self.m_isEnterRooming = false
    nk.SocketController:logoutRoomQiuQiu()
    nk.SocketController:logoutRoom()
    StateMachine.getInstance():changeState(States.Hall)
end

-- 释放loading动画
function EnterRoomManager:releaseLoading()
    -- 添加加载loading
    self.m_isEnterRooming = false
    if self.m_loading then
        -- self.m_loading:onLoadingRelease()
        delete(self.m_loading)
        self.m_loading = nil
        -- local blurEffect = require("libEffect/shaders/blur")
        -- for k, v in ipairs(self.blurList) do
        --     blurEffect.removeBlurEffect(v)
        -- end
        if self.blurWidget then
            local BlurWidget = require("libEffect.shaders.blurWidget")
            BlurWidget.removeBlur(self.blurWidget)
        end
        if self.clock then
            self.clock:cancel()
            self.clock = nil
        end
    end
end

-- 超过最大携带金币
function EnterRoomManager:overRoomMaxEnter(limit, typeStr)
    local args = {
        hasCloseButton = false,
        messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_OVER_MAX_MONEY",nk.updateFunctions.formatBigNumber(limit)), 
        firstBtnText = bm.LangUtil.getText("ROOM", "I_KNOW_ED"),
        secondBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"), 
        callback = function (type)
            if type == nk.Dialog.SECOND_BTN_CLICK then
                local ret
                local roomType
                if typeStr == "qiuqiu" then
                    ret = nk.SocketController:quickPlayQiuQiu()
                    roomType = 2
                else
                    ret = nk.SocketController:quickPlayGaple()
                    roomType = 1
                end
                if ret then
                    self:enterRoomLoading(nil,roomType)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL_2"))
                end
            end
        end
    }
    nk.PopupManager:addPopup(nk.Dialog,"enterRoomManager",args)
end

function EnterRoomManager:handleViewWithBlurConfig(view, config, changeList)
    local children = view:getChildren()
    for k, v in ipairs(children) do
        local subConf = config[v:getName()] 
        if subConf then
            if subConf ~= true then
                self:handleViewWithBlurConfig(v, config[v:getName()], changeList)
            end
        else
            if v:getVisible() then
                v:setVisible(false)
                table.insert(changeList, v)
            end
        end
    end
end

function EnterRoomManager:revertView(list)
    for k, v in ipairs(list) do
        v:setVisible(true)
    end
end

-- 金币不足进入
function EnterRoomManager:noEnoughRoomEnter(typeStr)
    Log.printError("EnterRoomManager", "icccccccccccccccccccccc")
    local args = {
        hasCloseButton = false,
        messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
        firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
        secondBtnText = bm.LangUtil.getText("LOGINREWARD", "INVITE_FRIEND"), 
        callback = function (type)
            if type == nk.Dialog.FIRST_BTN_CLICK then
                local ret
                local roomType
                if typeStr == "qiuqiu" then
                    ret = nk.SocketController:quickPlayQiuQiu()
                    roomType = 2
                else
                    ret = nk.SocketController:quickPlayGaple()
                    roomType = 1
                end
                if ret then
                    self:enterRoomLoading(nil,roomType)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL_2"))
                end
            elseif type == nk.Dialog.SECOND_BTN_CLICK then
                local InviteScene = require("game.invite.inviteScene")
                nk.PopupManager:addPopup(InviteScene, "Hall")
            end
        end
    }
    nk.PopupManager:addPopup(nk.Dialog, "enterRoomManager", args)
end
