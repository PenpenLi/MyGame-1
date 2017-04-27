-- hallScene.lua
-- Last modification : 2016-05-11
-- Description: a scene in Hall moudle
local SettingPopup = require("game.setting.settingPopup")
local RoomChoosePopup = require("game.roomChoose.roomChoosePopup")
local WAndFChatPopup = require("game.chat.wAndFChatPopup")
local MessagePopup = require("game.message.messagePopup")
local TaskPopup = require("game.task.taskPopup")
local LoginRewardPopup = require("game.loginReward.loginRewardPopup")
local FansCodePopup = require("game.freeGold.fansCodePopup")
local UpgradePopup = require("game.upgrade.upgradePopup")
local FirstRechargePopup = require("game.firstRecharge.firstRechargePopup")
local FriendDataManager = require("game.friend.friendDataManager") 
local RankDataManager = require("game.rank.rankDataManager") 
local HallPlayerItem = require("game.hall.hallPlayerItem") 
local HallRecommendItem = require("game.hall.hallRecommendItem") 
local GirlEyesAnim = require("game.anim.girlEyesAnim") 
local EaseMoveAnim = require("game.anim.easeMoveAnim") 
local StorePopup = require("game.store.popup.storePopup")
local HallGirlController = require("game.hall.hallGirlController")

local swf_typeMap = {
    [1] = {swfInfo = "qnRes/qnSwfRes/swf/hall_btn_1_swf_info",pinMap = "qnRes/qnSwfRes/swf/hall_btn_1_swf_pin"},
    [2] = {swfInfo = "qnRes/qnSwfRes/swf/hall_btn_2_swf_info",pinMap = "qnRes/qnSwfRes/swf/hall_btn_2_swf_pin"},
    [3] = {swfInfo = "qnRes/qnSwfRes/swf/hall_btn_3_swf_info",pinMap = "qnRes/qnSwfRes/swf/hall_btn_3_swf_pin"},
    [4] = {swfInfo = "qnRes/qnSwfRes/swf/hall_btn_4_swf_info",pinMap = "qnRes/qnSwfRes/swf/hall_btn_4_swf_pin"},
    [5] = {swfInfo = "qnRes/qnSwfRes/swf/hall_btn_star_swf_info",pinMap = "qnRes/qnSwfRes/swf/hall_btn_star_swf_pin"},
}

local HallScene = class(GameBaseSceneAsync);

HallScene.PrepareLoad = {
    "atlas/hall.png",
    "atlas/common.png",
    "atlas/freeGold.png",
    "atlas/common2.png",
}

function HallScene:ctor(viewConfig, controller)
end 

function HallScene:start()
    self.m_friendDataManager = FriendDataManager.getInstance()
    self.m_rankDataManager = RankDataManager.getInstance()
    self.m_LoadingAnim = new(nk.LoadingAnim)
    self:initScene()
    -- nk.HornTextRotateAnim.setup()
    self.m_eyesAnim = new(GirlEyesAnim, self.m_girl)
    self.m_easeMoveTable = {}
    -- self:showEnterAnim()
    EventDispatcher.getInstance():register(EventConstants.showHallEnterAnim, self, self.showEnterAnim)
    EventDispatcher.getInstance():register(EventConstants.showRoomChoosePopup, self, self.onShowRoomChoosePopup)
    EventDispatcher.getInstance():register(EventConstants.update_lTEvent_countDownTime, self, self.onRefreshlTEventCountdownTime)
    EventDispatcher.getInstance():register(EventConstants.freeMoney, self, self.setFreeRedPoint)
    EventDispatcher.getInstance():register(EventConstants.updateLotteryTimes, self, self.updateLotteryTimes)
end

function HallScene:resume()
    --背景音乐
    nk.SoundManager:playMusic(nk.SoundManager.BG_MUSIC, true)
    Log.printInfo("HallScene.resume");
    self.isPaused = false
    GameBaseScene.resume(self);
    nk.HornTextRotateAnim.setupScene("hall")
    self:addPropertyObservers_()
    
    if self.m_panel_free then
        self.m_panel_free:setVisible(false)
    end
    self:showEnterAnim()
    self:onRankingBtnClick()
    -- local p = {}
    -- debug.sethook(function(event)
    --     local debugInfo = debug.getinfo(2)
    --     local s = debugInfo.short_src
    --     local l = debugInfo.currentline
    --     -- FwLog(">>>>>>>>>>>>>>>>>" .. s .. ":" .. l)
    --     table.insert(p, ">>>>>>>>>>>>>>>>>" .. s .. ":" .. l)
    -- end, "c")
    -- Clock.instance():schedule_once(function()
    --     -- debug.sethook()
    --     for i = 1, 1000 do
    --         -- if p[i] then FwLog(p[i]) end
    --     end
    --     FwLog("it calls " .. #p .. " times.")
    -- end, 0.05)
    self.clockHandler = Clock.instance():schedule_once(function()
        if not self.isPaused and not tolua.isnull(self) then
            self.m_eyesAnim:startEyesAnim()
            self:resumeSwf()
            if self.updateViewFunc then
                self.updateViewFunc()
                self.updateViewFunc = nil
            end
            self.clockHandler = nil
        end
    end, 0.8)
end

function HallScene:pause()
    Log.printInfo("HallScene.pause"); 
    GameBaseScene.pause(self);
    nk.HornTextRotateAnim.setupScene("")
    self.m_eyesAnim:stopEyesAnim()
    self:removePropertyObservers()
    self:pauseSwf()
    self.isPaused = true
    if self.clockHandler then
        self.clockHandler:cancel()
        self.clockHandler = nil
    end
end 

function HallScene:dtor()
    Log.printInfo("HallScene.dtor");
    nk.limitTimer:removeTimeText(self.limitTimeText)
    self:stopEnterAnim()
    if self.m_hallGirlController then
        delete(self.m_hallGirlController)
        self.m_hallGirlController = nil
    end
    delete(self.m_eyesAnim)
    self.m_eyesAnim = nil
    if self.m_discountBg then
        self.m_discountBg:doRemoveProp(1)
    end
    EventDispatcher.getInstance():unregister(EventConstants.showHallEnterAnim, self, self.showEnterAnim)
    EventDispatcher.getInstance():unregister(EventConstants.showRoomChoosePopup, self, self.onShowRoomChoosePopup)
    EventDispatcher.getInstance():unregister(EventConstants.update_lTEvent_countDownTime, self, self.onRefreshlTEventCountdownTime)
    EventDispatcher.getInstance():unregister(EventConstants.freeMoney, self, self.setFreeRedPoint)
    EventDispatcher.getInstance():unregister(EventConstants.updateLotteryTimes, self, self.updateLotteryTimes)

    -- collectgarbage()
    -- TextureCache.instance():clean_unused()
    -- TextureCache.instance():dump()

    if self.schedule then
        self.schedule:cancel()
        self.schedule = nil
    end
    if self.fiveStarSchedule then
        self.fiveStarSchedule:cancel()
        self.fiveStarSchedule = nil
    end
end 

function HallScene:stopEnterAnim()
    if self.m_easeMoveTable then
        for i,anim in ipairs(self.m_easeMoveTable) do
            anim:stopMove()
        end
        self.m_easeMoveTable = {}
    end
end

function HallScene:initScene()
    self.m_girl = self:getUI("hall_girl")
    self.m_hallGirlController = new(HallGirlController, self.m_girl)
    self.m_message_red_point = self:getUI("red_point")
    self.m_message_red_point:setVisible(false)

    self.m_task_red_point = self:getUI("task_red_point")
    self.m_task_red_point:setVisible(false)

    self.m_setting_red_point = self:getUI("Image_setting_redPoint")
    self.m_setting_red_point:setVisible(false)

    self.m_bt_node = self:getUI("bottomBtn_node")
    self.m_bt_node:setLevel(20)

    self.m_panel_free = self:getUI("Image_free_panel")
    self.m_panel_free:setVisible(false)

    self.m_free_red_point = self:getUI("Image_free_redPoint")
    self.m_free_red_point:setVisible(false)

    self.m_free_login_red_point = self:getUI("Image_free_login_point")
    self.m_free_login_red_point:setVisible(false)

    self.m_free_fans_red_point = self:getUI("Image_free_fans_point")
    self.m_free_fans_red_point:setVisible(false)

    self.m_free_upgrade_red_point = self:getUI("Image_free_grow_point")
    self.m_free_upgrade_red_point:setVisible(false)

    self.m_inviteRedPoint = self:getUI("inviteRed")
    self.m_inviteRedPoint:setVisible(false)

    self.m_lock_99 = self:getUI("room99_lock_icon")
    self.m_lotteryNumBg = self:getUI("LotteryNumBg")
    self.m_lotteryNum = self:getUI("LotteryNum")
    self.m_lotteryNum:setText(nk.lotteryTimes or 0)
    if nk.lotteryTimes  and nk.lotteryTimes>0 then
        self.m_lotteryNumBg:setVisible(true)
    else
        self.m_lotteryNumBg:setVisible(false)
    end
    self:getUI("Text_free_login"):setText(bm.LangUtil.getText("HALL", "LOGIN_REWARD"))
    self:getUI("Text_free_fans"):setText(bm.LangUtil.getText("ECODE", "TITLE"))
    self:getUI("Text_free_upgrow"):setText(bm.LangUtil.getText("HALL", "UPLEVEL_AWARD"))

    self:initAdsAndDownloadBtn()
    

    self:initPlayerInfo()
    self:initRankingNode()
    self:initOperator()
    self:updataUserinfo()
    self:initSwf()   

    local roomConfig = nk.DataProxy:getData(nk.dataKeys.TABLE_99_NEW_CONF) or {}
    if roomConfig[1] then
        local data = roomConfig[1][1]
        if data then
            local lv = nk.Level:getLevelByExp(nk.userData.exp);
            if checkint(data.levellimit) > checkint(lv) then
                self.m_lock_99:setVisible(true)
                self.m_qiuqiuBtn:setEnable(false)
            else
                self.isQiuqiuQualified = true
                self.m_lock_99:setVisible(false)
                self.m_qiuqiuBtn:setEnable(true)
            end
        end
    end

    self.fiveStarSchedule = Clock.instance():schedule_once(function (dt)
        self:judgeFiveStar()
    end, 1)
end

--更新抽奖次数
function HallScene:updateLotteryTimes()
    self.m_lotteryNum:setText(nk.lotteryTimes or 0)
    if nk.lotteryTimes  and nk.lotteryTimes>0 then
        self.m_lotteryNumBg:setVisible(true)
    else
        self.m_lotteryNumBg:setVisible(false)
    end
end    

--是否弹出五星好评
function HallScene:judgeFiveStar()
    local time = nk.DictModule:getInt("gameData", nk.userData.uid.."fiveStarTime", 0)
    if checkint(nk.fiveStar)==0  and nk.isWin and nk.enterRoomMoney and nk.exitRoomMoney and nk.fiveStarConf and  type(nk.fiveStarConf.limitList)=="table" and os.time()-time>nk.fiveStarConf.limitDays*24*60*60  then
        if nk.isWin==1 and nk.exitRoomMoney>nk.enterRoomMoney then
            for i=#nk.fiveStarConf.limitList,1,-1 do
                if nk.userData.money>=nk.fiveStarConf.limitList[i][1] and 
                (nk.exitRoomMoney-nk.enterRoomMoney)>=nk.enterRoomMoney*nk.fiveStarConf.limitList[i][2] then
                    nk.PopupManager:addPopup(require("game.score.scorePopup"),"hall") 
                    nk.DictModule:setInt("gameData", nk.userData.uid.."fiveStarTime",os.time())
                    nk.DictModule:saveDict("gameData")
                    break
                end
            end    
        end
    end
end   

function HallScene:initAdsAndDownloadBtn() -- 广告及换量按钮初始化
    self.Button_free_video = self:getUI("Button_free_video")
    self.Text_free_video = self:getUI("Text_free_video")
    self.Text_free_video:setText(bm.LangUtil.getText("HALL", "VIDEO_AWARD"))
    self.Image_free_video_point = self:getUI("Image_free_video_point")
    self.Image_free_video_point:setVisible(false)

    self.Button_free_download = self:getUI("Button_free_download")
    self.Text_free_download = self:getUI("Text_free_download")
    self.Text_free_download:setText(bm.LangUtil.getText("HALL", "DOWNLOAD_AWARD"))
    self.Image_free_download_point = self:getUI("Image_free_download_point")
    self.Image_free_download_point:setVisible(false)

    -- 测试数据，GameServer.load 里面获取的
    -- nk.googlead = 1 --unityads开关
    -- nk.advertdl = 1 --广告换量开关
    if nk.googlead and nk.googlead == 1 then
        self.schedule = Clock.instance():schedule(function (dt) -- 更新视频按钮红点，判断视频是否加载好
                self:scheduleHandler()
            end, 1)

        if nk.advertdl and nk.advertdl == 1 then -- 两个都开，不做处理

        else -- 只有广告
            self.Button_free_download:setVisible(false)
            self.Button_free_video:setPos(self.Button_free_download:getPos())

            local x, y = self.m_panel_free:getSize()
            self.m_panel_free:setSize(x - 95, y)
        end
    else
        self.Button_free_video:setVisible(false)

        local count = 1
        if nk.advertdl and nk.advertdl == 1 then -- 只有换量          
            
        else -- 两个都没有
            self.Button_free_download:setVisible(false)

            count = 2
        end

        local x, y = self.m_panel_free:getSize()
        self.m_panel_free:setSize(x - 95 * count, y)

    end
end

function HallScene:scheduleHandler()
    local isReady = nk.UnityAdsNativeEvent:unityAdsIsReady()
    local arrays = clone(nk.userData["FreeMoneyModTips"] or {})
    if isReady == 1 and nk.unityadsTimes > 0 then
        if not table.keyof(nk.userData["FreeMoneyModTips"] or {}, 9) then           
            table.insert(arrays, 9)
            nk.userData["FreeMoneyModTips"] = arrays
            self.Image_free_video_point:setVisible(true)
        end
    end
    if nk.unityadsTimes <= 0 or isReady == 0 then
        table.removebyvalue(arrays, 9)
        nk.userData["FreeMoneyModTips"] = arrays
        self.Image_free_video_point:setVisible(false)
    end

    if nk.unityadsTimes <= 0 then
        if self.schedule then
            self.schedule:cancel()
            self.schedule = nil
        end
    end
end

function HallScene:initSwf()
    -- more 按钮的 (-2,0) (5,-7)

    local swfInfo = require(swf_typeMap[1].swfInfo)
    local pinMap = require(swf_typeMap[1].pinMap)
    self.m_quick_swf = new(SwfPlayer,swfInfo,pinMap)
    self.m_quickStartBtn:addChild(self.m_quick_swf)
    self.m_quick_swf:setPos(-1,0)
    self.m_quick_swf:play(1,false,1,0,false)

    local swfInfo = require(swf_typeMap[2].swfInfo)
    local pinMap = require(swf_typeMap[2].pinMap)
    self.m_gaple_swf = new(SwfPlayer,swfInfo,pinMap)
    self.m_gapleBtn:addChild(self.m_gaple_swf)
    self.m_gaple_swf:setPos(-1,0)
    self.m_gaple_swf:play(1,false,1,0,false)

    local swfInfo = require(swf_typeMap[3].swfInfo)
    local pinMap = require(swf_typeMap[3].pinMap)
    self.m_qiuqiu_swf = new(SwfPlayer,swfInfo,pinMap)
    self.m_qiuqiuBtn:addChild(self.m_qiuqiu_swf)
    self.m_qiuqiu_swf:setPos(3,0)
    self.m_qiuqiu_swf:play(1,false,1,0,false)

    -- table.insert(nk.SWF,self.m_quick_swf)
    -- table.insert(nk.SWF,self.m_gaple_swf)
    -- table.insert(nk.SWF,self.m_qiuqiu_swf)

    local swfInfo = require(swf_typeMap[5].swfInfo)
    local pinMap = require(swf_typeMap[5].pinMap)
    self.m_btn_star_swf = new(SwfPlayer,swfInfo,pinMap)
    self.m_quickStartBtn:addChild(self.m_btn_star_swf)
    self.m_btn_star_swf:setPos(5,-3)
    self.m_btn_star_swf:play(1,false,1,0,false)
    -- table.insert(nk.SWF,self.m_btn_star_swf)

     self.m_quick_swf:setCompleteEvent(self, function()
            self.m_quick_swf:pause(0, false)
            self.m_gaple_swf:playContinue(nil, false)
     end)
     self.m_quick_swf:setFrameEvent(self, function()
            nk.functions.removeFromParent(self.m_btn_star_swf)
            self.m_quickStartBtn:addChild(self.m_btn_star_swf)
            self.m_btn_star_swf:playContinue(nil, false)
     end, 3)

     self.m_gaple_swf:setCompleteEvent(self, function()
            self.m_gaple_swf:pause(0, false)
            if self.isQiuqiuQualified then
                self.m_qiuqiu_swf:playContinue(nil, false)
            else
                self.m_quick_swf:playContinue(nil, false)
            end
     end)
     self.m_gaple_swf:setFrameEvent(self, function()
            nk.functions.removeFromParent(self.m_btn_star_swf)
            self.m_gapleBtn:addChild(self.m_btn_star_swf)
            self.m_btn_star_swf:playContinue(nil, false)
     end, 3)

     self.m_qiuqiu_swf:setCompleteEvent(self, function()
            self.m_qiuqiu_swf:pause(0, false)
            self.m_quick_swf:playContinue(nil, false)
     end)
     self.m_qiuqiu_swf:setFrameEvent(self, function()
            nk.functions.removeFromParent(self.m_btn_star_swf)
            self.m_qiuqiuBtn:addChild(self.m_btn_star_swf)
            self.m_btn_star_swf:playContinue(nil, false)
     end, 3)

     self.m_btn_star_swf:setCompleteEvent(self, function()
            self.m_btn_star_swf:pause(0, false)
     end)
     self:pauseSwf()
end

function HallScene:resumeSwf()
   self:pauseSwf()
   self.m_quick_swf:playContinue(nil, false)
end

function HallScene:pauseSwf()
   self.m_quick_swf:pause(0, false)
   self.m_btn_star_swf:pause(0, false)
   self.m_gaple_swf:pause(0, false)
   self.m_qiuqiu_swf:pause(0, false)
end

function HallScene:initPlayerInfo()
    self.m_playerInfo_node = self:getUI("playerInfo_node")
    self.m_headBtn = self:getControl(self.s_controls["head_btn"])
    self.m_name = self:getControl(self.s_controls["playerName"])
    self.m_money = self:getControl(self.s_controls["playerMoney"])
    self.m_headBg = self:getControl(self.s_controls["head_bg"])
    self.m_view_vip = self:getUI("View_vip")
end

function HallScene:initRankingNode()
    self.m_ranking_node = self:getUI("ranking_node")
    self.m_LoadingAnim:addLoading(self.m_ranking_node)

    self.m_rankRightBtn = self:getControl(self.s_controls["rank_right_btn"])
    self.m_rankLeftBtn = self:getControl(self.s_controls["rank_left_btn"])

    self.m_leftBg = self:getUI("left_bg")
    self.m_rightBg = self:getUI("right_bg")

    self.m_leftText = self:getUI("left_text")
    self.m_rightText = self:getUI("right_text")

    self.m_rankingListView = self:getUI("ranking_list_view")
    self.m_friendsListView = self:getUI("friends_list_view")
    self.m_recommendListView = self:getUI("recommend_list_view")

    self.m_noFriendTipsView = self:getUI("noFriend_tips")
    self.m_noFriendTipsView:setVisible(false)

    self.m_noFriendTips = self:getUI("NoFriendText")
    self.m_recommendText = self:getUI("RecommendText")
    self.m_noFriendTips:setText(bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP2"))
    self.m_recommendText:setText(bm.LangUtil.getText("FRIEND", "RECOMMEND_TITLE"))
    self.m_head_ = self:getUI("Image_head")
    self.m_head_ = Mask.setMask(self.m_head_, kImageMap.common_head_mask_min)


end

function HallScene:initOperator()
    self.m_quickStartBtn = self:getControl(self.s_controls["quickStart_btn"])
    self.m_gapleBtn = self:getControl(self.s_controls["gaple_btn"])
    self.m_qiuqiuBtn = self:getControl(self.s_controls["qiuqiu_btn"])
    self.m_moreBtn = self:getControl(self.s_controls["more_btn"])
    self.m_moreBtn:setEnable(false)
    self.m_mallBtn = self:getControl(self.s_controls["mall_btn"])
    self.m_discountBg = self:getUI("DiscountBg")
    self.m_discountLabel = self:getUI("DiscountLabel")
    self.m_friendsBtn = self:getControl(self.s_controls["friend_btn"])
    self.m_msgNotReadTips = self:getUI("msg_not_read_tips")
    self.m_msgNotReadTips:setVisible(false)
    if nk.userData.chatRecord and #nk.userData.chatRecord >0 then
        self.m_msgNotReadTips:setVisible(true)
    end
    self.m_rankListBtn = self:getControl(self.s_controls["rank_btn"])
    self.m_taskBtn = self:getControl(self.s_controls["task_btn"])
    self.m_activityBtn = self:getControl(self.s_controls["activity_btn"])
    self.m_redPointActivity = self:getUI("redPointActivity")
    self.m_freeMoneyBtn = self:getControl(self.s_controls["freeMoney_btn"])
    self.m_settingBtn = self:getControl(self.s_controls["setting_btn"])
    self.m_messageBtn = self:getControl(self.s_controls["message_btn"]) 
    self.m_fbLoginReward = self:getUI("fbLoginReward")
    self.m_fbLoginReward:setText("+" .. nk.updateFunctions.formatBigNumber(nk.userData.inviteBackChips))
    self.facebookButton = self:getUI("facebookButton")
    self.quickPayBtn = self:getUI("quickPayBtn")
    self.quickPayBtn:setOnClick(self,self.onQuickPayButtonClick)
    self.firstPayBtn = self:getUI("firstPayBtn")
    self.firstPayBtn:setOnClick(self,self.onFirstPayButtonClick)
    self.limitTimeBtn = self:getUI("LimitTimeBtn")
    self.limitPos = self.limitTimeBtn:getPos()
    self.limitTimeText = self:getUI("LimitTimeText")
    self.limitTimeNumBg = self:getUI("NumBg")
    self.limitTimeNum = self:getUI("NumText")
    self.limitTimeBtn:setVisible(false)
    self:onLimitTimeOpen(nk.limitInfo)
    self.m_discountBg:setVisible(false)
    if nk.maxDiscount>0 then
        self.m_discountBg:setVisible(true)
        self.m_discountLabel:setText("+"..nk.maxDiscount.."%")
        self.m_discountBg:addPropTranslate(1, kAnimLoop, 200, -1,0,0,0,-6, kCenterDrawing)
    end
    self.discountDelayCount = 0
    self.imitTimeEventBtn = self:getUI("LimitTimeEventBtn")
    self.imitTimeEventBtn:setVisible(false)
    local lTEvent_time_bg = self:getUI("lTEvent_time_bg")
    lTEvent_time_bg:setVisible(false)
end

function HallScene:updataUserinfo()
    local text =  nk.updateFunctions.limitNickLength(nk.UserDataController.getUserName(),8)
    self.m_name:setText(text)
    text = nk.updateFunctions.formatBigNumber(nk.functions.getMoney())
    self.m_money:setText(text)
end

-- 个人信息界面
function HallScene:onHeadBtnClick()
     nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "hall")
     nk.DataCenterManager:report("btn_headPic")
end

function HallScene:onAddBtnClick()
    nk.payScene = consts.PAY_SCENE.HALL_HEADICON_PAY
    nk.PopupManager:addPopup(StorePopup)
    nk.DataCenterManager:report("btn_headPic_add")
end

function HallScene:onRankingBtnClick()
    Log.printInfo("HallScene onRankingBtnClick")
    self.m_noFriendTipsView:setVisible(false)
    if self.m_rankNode_index ~= 1 then
        nk.AnalyticsManager:report("New_Gaple_profit", "profit")

        self.m_rankNode_index = 1
        self:setRankNodeBtnStatus(self.m_rankNode_index)
        nk.rankNodeIndex = self.m_rankNode_index
    else
        return
    end
    if self.m_isGetRankList_ing or self.isGetRank then
        return 
    end
    self.m_LoadingAnim:onLoadingStart()
    self.m_isGetRankList_ing = true
    self.m_rankDataManager:loadRankData("win",1,handler(self, function(obj, status, data)
            local updateViewFunc = function()
                self.m_LoadingAnim:onLoadingRelease()
                self.m_isGetRankList_ing = false
                Log.dump(data,"HallScene:onRankingBtnClick...................")
                if status and data and data.list and #data.list > 0 then
                    self.isGetRank = true
                    local adapter = new(CacheAdapter, HallPlayerItem, data.list)
                    self.m_rankingListView:setAdapter(adapter)
                elseif data and data.userRank then
                    local adapter = new(CacheAdapter, HallPlayerItem, {data.userRank})
                    self.m_rankingListView:setAdapter(adapter)     
                end
            end
            if self.clockHandler then
                self.updateViewFunc = updateViewFunc
            else
                updateViewFunc()
            end
        end))
    nk.GCD.PostDelay(self, function()
        self.m_isGetRankList_ing = false
    end, nil, 2000)
end

function HallScene:onRankFriendsBtnClick()
    Log.printInfo("HallScene onFriendsBtnClick")
    if self.m_rankNode_index ~= 2 then
        self.m_rankNode_index = 2
        self:setRankNodeBtnStatus(self.m_rankNode_index)
        nk.rankNodeIndex = self.m_rankNode_index
    else
        return 
    end
    self:onRefreshFriendList()
    nk.DataCenterManager:report("btn_profit_friend")
end

function HallScene:setRankNodeBtnStatus(index)
    self.m_rankingListView:setVisible(index == 1)
    self.m_friendsListView:setVisible(index == 2)
    self.m_recommendListView:setVisible(index == 2)
    self.m_noFriendTipsView:setVisible(index == 2)
    self.m_leftBg:setVisible(index == 1)
    self.m_rightBg:setVisible(index == 2)
    if index == 1 then
        self.m_leftText:setColor(225,194,251)
        self.m_rightText:setColor(203,134,18)
    else
        self.m_leftText:setColor(203,134,18)
        self.m_rightText:setColor(225,194,251)
    end
end

-- 入场动画
function HallScene:showEnterAnim(delayTimeBase)
    if QUALITY_MODE == 0 then return end
    local moveTime = 600
    delayTimeBase = delayTimeBase or 0
    
    self:stopEnterAnim()

    local layoutScale = System.getLayoutScale()/1.25
    FwLog("layoutScale " .. layoutScale)

    local leftNodes = {self.m_playerInfo_node, self.m_view_vip, self.m_ranking_node}

    for i = 1, #leftNodes do
        local anim = new(EaseMoveAnim)
        anim:move(leftNodes[i], true, nil, -370 * layoutScale, 370 * layoutScale, nil, nil, moveTime, delayTimeBase, 1, "easeOutBack")
        table.insert(self.m_easeMoveTable, anim)
    end

    local anim = new(EaseMoveAnim)
    anim:move(self.m_bt_node, nil, true, nil, nil, 120 * layoutScale, -120 * layoutScale, moveTime, delayTimeBase, 1, "easeOutBack")
    table.insert(self.m_easeMoveTable,anim)

    local delayTime = 100
    local rightNodes = {self.m_quickStartBtn, self.m_gapleBtn, self.m_qiuqiuBtn, self.m_moreBtn}
    for i = 1, #rightNodes do
        local anim = new(EaseMoveAnim)
        anim:move(rightNodes[i], true, nil, 430 * layoutScale, -430 * layoutScale, nil, nil, moveTime, delayTimeBase + delayTime*(i - 1), 1, "easeOutBack")
        table.insert(self.m_easeMoveTable,anim)
    end

    rightNodes = {self.firstPayBtn, self.quickPayBtn, self.limitTimeBtn, self.facebookButton,}
    for i = 1, #rightNodes do
        local anim = new(EaseMoveAnim)
        anim:move(rightNodes[i], true, nil, 430 * layoutScale, -430 * layoutScale, nil, nil, moveTime, delayTimeBase, 1, "easeOutBack")
        table.insert(self.m_easeMoveTable,anim)
    end

    local anim = new(EaseMoveAnim)
    anim:move(self.m_girl, nil, true, nil, nil, 700 * layoutScale, -700 * layoutScale, moveTime * 1, delayTimeBase, 1, "easeOutBack")
    table.insert(self.m_easeMoveTable, anim)

    local anim = new(EaseMoveAnim)
    anim:move(nk.HornTextRotateAnim.broadCast_node, nil, true, nil, nil, -400 * layoutScale, 400 * layoutScale, moveTime * 1, delayTimeBase, 1, "easeOutBack")
    table.insert(self.m_easeMoveTable, anim)
end

-- 出场动画
function HallScene:playHideAnim()
    
end

---------------------------UI function-----------------------------------

function HallScene:onShowRoomChoosePopup(roomType)
    if nk.roomChooseType == 1 then
        self:onGapleBtnClick()
    else
        self:onQiuqiuBtnClick()
    end
end

function HallScene:onQuickStartBtnClick()
    Log.printInfo("HallScene onQuickStartBtnClick")
    nk.AnalyticsManager:report("New_Gaple_quickStart", "quickStart")
    nk.DataCenterManager:report("btn_quickStart")

    if GameConfig.ROOT_CGI_SID == "2" then
        EnterRoomManager.getInstance():enter99Room()
    else
        EnterRoomManager.getInstance():enterGapleRoom()
    end
end

function HallScene:onGapleBtnClick()
    Log.printInfo("HallScene onGapleBtnClick")
    nk.AnalyticsManager:report("New_Gaple_gaple", "gaple")
    nk.DataCenterManager:report("btn_gaple")

    nk.roomChooseType = 1
    nk.PopupManager:addPopup(RoomChoosePopup,"hall")
end

function HallScene:onQiuqiuBtnClick()
    Log.printInfo("HallScene onQiuqiuBtnClick")
    nk.AnalyticsManager:report("New_Gaple_qiuqiu", "qiuqiu")
    nk.DataCenterManager:report("btn_qiuqiu")

    nk.roomChooseType = 2
    nk.PopupManager:addPopup(RoomChoosePopup,"hall")
end

function HallScene:onMoreBtnClick()
    Log.printInfo("HallScene onMoreBtnClick")    
end

function HallScene:onReportMoreBtnClick()
    nk.DataCenterManager:report("btn_more")
end

function HallScene:onMallBtnClick()
    Log.printInfo("HallScene onMallBtnClick")
    nk.payScene = consts.PAY_SCENE.HALL_SHOP_PAY
    nk.PopupManager:addPopup(StorePopup)
    nk.DataCenterManager:report("btn_mall")
end

function HallScene:onAddFriendsBtnClick()
    StateMachine.getInstance():pushState(States.Friend, nil, nil, 2)
end

function HallScene:onFriendsBtnClick()
    Log.printInfo("HallScene onFriendsBtnClick")
    nk.AnalyticsManager:report("New_Gaple_friend_gift", "friend_gift")

    self.m_msgNotReadTips:setVisible(false)
    StateMachine.getInstance():pushState(States.Friend);
    nk.DataCenterManager:report("btn_friend")
end

function HallScene:onRankListBtnClick()
    Log.printInfo("HallScene onRankListBtnClick")
    nk.AnalyticsManager:report("New_Gaple_rank", "rank")

    StateMachine.getInstance():pushState(States.Rank);
    nk.DataCenterManager:report("btn_rank")
end

function HallScene:onTaskBtnClick()
    Log.printInfo("HallScene onTaskBtnClick")
    nk.AnalyticsManager:report("New_Gaple_task", "task")
    nk.PopupManager:addPopup(TaskPopup,"hall")
    nk.DataCenterManager:report("btn_task")
end

function HallScene:onLotteryClick()
    nk.AnalyticsManager:report("New_Gaple_lottery", "lottery")
    nk.DataCenterManager:report("btn_lottery")
    nk.PopupManager:addPopup(require("game.lottery.lotteryPopup"),"hall") 
end

function HallScene:onActivityBtnClick()
    Log.printInfo("HallScene onActivityBtnClick")
    nk.AnalyticsManager:report("New_Gaple_activity", "activity")

    nk.ActivityNativeEvent:activityOpen()
    nk.DataCenterManager:report("btn_activity")
end

function HallScene:onFreeMoneyBtnClick()
    Log.printInfo("HallScene onFreeMoneyBtnClick")

    nk.AnalyticsManager:report("New_Gaple_freeGold", "freeGold")
    nk.DataCenterManager:report("btn_freeGold")

    self.m_panel_free:setVisible(not self.m_panel_free:getVisible())
    if not self.m_panel_freeBg then
        self.m_panel_freeBg = new(Image, kImageMap.common_transparent)
        self.m_panel_freeBg:addTo(self.m_panel_free)
        self.m_panel_freeBg:setLevel(-1)
        self.m_panel_freeBg:setSize(System.getScreenWidth(), System.getScreenHeight())
        local x,y = self.m_panel_freeBg:convertSurfacePointToView(0, 0)
        self.m_panel_freeBg:setPos(x, y)
        nk.functions.registerImageTouchFunc(self.m_panel_freeBg, self, self.onFreeMoneyBtnClick)
        self.m_panel_free:getParent():setLevel(10)
    end


    --红点
    if self.m_panel_free:getVisible() then
         if nk.userData["FreeMoneyModTips"] then
            self.m_red_point_list  = {}
            table.foreach(nk.userData["FreeMoneyModTips"], function(i, v)
               if v == 3 then
                   self.m_free_fans_red_point:setVisible(true)
                   self.m_red_point_list[i] = self.m_free_fans_red_point
               elseif v == 5 then
                   self.m_free_login_red_point:setVisible(true)
                   self.m_red_point_list[i] = self.m_free_login_red_point
               elseif v == 7 then
                   self.m_free_upgrade_red_point:setVisible(true)
                   self.m_red_point_list[i] = self.m_free_upgrade_red_point
--               elseif v == 9 then
--                    self.Image_free_video_point:setVisible(true)
--                    self.m_red_point_list[i] = self.Image_free_video_point
               end
            end)
         else 
            self.m_free_red_point:setVisible(false)
         end
    end
end

function HallScene:onFreeVideoBtnClick()
    self.m_panel_free:setVisible(not self.m_panel_free:getVisible())

    nk.PopupManager:addPopup(require("game.unityAds.unityAdsPopup"), "hall")
    --self:setFreeRedPoint(9)
end

function HallScene:onFreeDownloadBtnClick()
    self.m_panel_free:setVisible(not self.m_panel_free:getVisible())
    
    nk.PopupManager:addPopup(require("game.downloadGames.downloadGamesPopup"), "hall")
end

function HallScene:onFreeFansBtnClick()
    nk.AnalyticsManager:report("New_Gaple_freeGold_fans", "freeGold") 

    self.m_panel_free:setVisible(not self.m_panel_free:getVisible())
    nk.PopupManager:addPopup(FansCodePopup, "hall")
   -- self:setFreeRedPoint(3)
end

function HallScene:onFreeLoginBtnClick()   
    nk.AnalyticsManager:report("New_Gaple_freeGold_login", "freeGold")
    self.m_panel_free:setVisible(not self.m_panel_free:getVisible())
   -- self:setFreeRedPoint(5)
    if nk.userData.registerRewardAward then
        nk.PopupManager:addPopup(require("game.popup.registerRewardPopup"),"hall")
    elseif nk.userData.loginReward and nk.LoginRewardController and nk.LoginRewardController:getLoginRewardData() then
        nk.PopupManager:addPopup(LoginRewardPopup,"hall")
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "NOT_LOAD_DATA"))
    end
end

function HallScene:onFreeGrowBtnClick()
    self.m_panel_free:setVisible(not self.m_panel_free:getVisible())
    if nk.userData["invitableLevel"] and #nk.userData["invitableLevel"] > 0 then    
        nk.PopupManager:addPopup(UpgradePopup, "hall")
    else
        local ratio, progress, all, nothing, nextLevelReward = nk.Level:getLevelUpProgress(nk.userData["exp"])
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "EXP_LACK",nextLevelReward))
    end 
    self:setFreeRedPoint(7)
end

function HallScene:setFreeRedPoint(index)
    if nk.userData["FreeMoneyModTips"] then 
        table.foreach(nk.userData["FreeMoneyModTips"], function(i, v)
        if v==index then
            if self.m_red_point_list and self.m_red_point_list[i] then
                self.m_red_point_list[i]:setVisible(false)
                table.remove(self.m_red_point_list, i)
            end
            local data = clone(nk.userData["FreeMoneyModTips"])
            table.remove(data,i)
            nk.userData["FreeMoneyModTips"] = data
        end
        end)
    end
end

function HallScene:onSettingBtnClick()
    Log.printInfo("HallScene onSettingBtnClick")
    nk.AnalyticsManager:report("New_Gaple_setting", "setting")

    nk.PopupManager:addPopup(SettingPopup,"hall")  
    nk.DataCenterManager:report("btn_setting")
end

function HallScene:onMessageBtnClick()
    Log.printInfo("HallScene onMessageBtnClick")
    nk.AnalyticsManager:report("New_Gaple_message", "message")

    nk.PopupManager:addPopup(MessagePopup,"hall")
    nk.DataCenterManager:report("btn_message")
end

function HallScene:onFacebookButtonClick()
    Log.printInfo("HallScene onFacebookButtonClick")
    nk.AnalyticsManager:report("New_Gaple_invite", "invite")

    local InviteScene = require("game.invite.inviteScene")
    nk.PopupManager:addPopup(InviteScene,"hall")
    nk.DataCenterManager:report("btn_invite")
end

function HallScene:addPropertyObservers_()
    self.moneyObserverHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, function (obj, money)
        if not nk.updateFunctions.checkIsNull(obj) and money and money>=0 and not nk.isInSingleRoom then
            Log.printInfo("addPropertyObservers money = ", money)
            obj.m_money:setText(nk.updateFunctions.formatBigNumber(money))
        end
    end))

    self.activityNumObserverHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "activityNum", handler(self, function (obj, count)
        if count and count > 0 then
            self.m_redPointActivity:setVisible(true)
        end
    end))

    self.chatRecordHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", handler(self, function (obj, chatRecord)
        if not nk.updateFunctions.checkIsNull(obj) then
            if chatRecord and #chatRecord>0 and not nk.PopupManager:hasPopup(nil,"WAndFChatPopup") then
                obj.m_msgNotReadTips:setVisible(true)
            else
                obj.m_msgNotReadTips:setVisible(false)
            end
        end
    end))

    --大厅头像
    self.miconHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "micon", handler(self, function (obj, micon)
        if not nk.updateFunctions.checkIsNull(obj) then                    
            if not micon or not string.find(micon, "http")then
                -- 默认头像 
                local index = tonumber(micon) or 1
                self.m_head_:setFile(nk.s_headFile[index])
                if nk.userData.msex and tonumber(nk.userData.msex) ==1 then
                    self.m_head_:setFile(kImageMap.common_male_avatar)
                else
                    self.m_head_:setFile(kImageMap.common_female_avatar)
                end
            else
                -- 上传的头像
                UrlImage.spriteSetUrl(obj.m_head_, micon)
            end           
        end
    end))

    --大厅性别
    self.msexHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "msex", handler(self, function (obj, msex)
        if not nk.updateFunctions.checkIsNull(obj) and nk.userData.micon and not string.find(nk.userData.micon, "http") and msex then                    
            if tonumber(msex) ==1 then
                self.m_head_:setFile(kImageMap.common_male_avatar)
            else
                self.m_head_:setFile(kImageMap.common_female_avatar)
            end         
        end
    end))

    --消息红点
    self.NewMessageDataHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "MsgMainPoint", handler(self, function(obj, visible)
       if not nk.updateFunctions.checkIsNull(obj) then
            self.m_message_red_point:setVisible(visible)
       end
    end))

    --任务红点
   self.TaskDataHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "TaskMainPoint", handler(self, function(obj, visible)
       if not nk.updateFunctions.checkIsNull(obj) then
            self.m_task_red_point:setVisible(visible)
       end
    end))

    --设置红点
    self.settingHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "settingPoint", handler(self, function(obj, visible)
           self.m_setting_red_point:setVisible(visible)
    end))

    --免费领取红点
    self.freeMoneyHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "FreeMoneyModTips", handler(self, function(obj, pointList)
        if pointList and #pointList >0 then
            self.m_free_red_point:setVisible(true)
        else   
            self.m_free_red_point:setVisible(false) 
        end
    end))

    -- 邀请奖励红点监听
    self.inviteIsGetHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "inviteIsGet", handler(self, function(obj, inviteIsGet)
        if inviteIsGet and inviteIsGet >0 then
            self.m_inviteRedPoint:setVisible(true)
        else   
            self.m_inviteRedPoint:setVisible(false) 
        end
    end))

    --名字
    self.nameHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "name", handler(self, function()
        self:updataUserinfo()
    end))

    --首冲
    self.onFirstRechargeStatusHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", handler(self, self.recharge))

    self.vipObserverHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "vip", handler(self, function (obj, vip)
        if not nk.updateFunctions.checkIsNull(obj) then
            if vip and tonumber(vip)>0 then
                self.m_headBg:setFile("res/common/vip_head_kuang.png")
                self.m_headBg:setSize(67,67)
                self:DrawVip(self.m_view_vip, vip)
                self.m_name:setColor(0xa0,0xff,0x00)
            else
                self.m_headBg:setFile("res/hall/hall_playerhead_bg.png")
                self.m_headBg:setSize(80,82)
                self.m_view_vip:removeAllChildren(true)
                if self.vipbs then
                    self.vipbs:removeFromParent(true)
                end
                self.m_name:setColor(0xff,0xff,0xff)
            end
        end
    end))

    -- 全服活动红点
    self.fullEventHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "fullEventPoint", handler(self, function(obj, visible)
        self:updataLimitTimeEventStatus()
    end))

    -- 个人活动红点
    self.singleEventHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "singleEventPoint", handler(self, function(obj, visible)
        self:updataLimitTimeEventStatus()
    end))

    -- 个人或全服活动是否打开
    self.eventIsOpenHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "eventIsOpen", handler(self, function(obj, isOpen)
        if not nk.updateFunctions.checkIsNull(obj) then
            self.imitTimeEventBtn:setVisible(isOpen)
        end
    end))
end

function HallScene:onRefreshlTEventCountdownTime(time_table)
    local lTEvent_time_bg = self:getUI("lTEvent_time_bg")
    lTEvent_time_bg:setVisible(time_table.time>0)
    local lTEvent_time = self:getUI("lTEvent_time")
    if time_table.day and time_table.day > 1 then
        lTEvent_time_bg:setVisible(false)
    elseif time_table.time_str then
        lTEvent_time:setText(time_table.time_str)
    end
end

function HallScene:updataLimitTimeEventStatus()
    if not nk.updateFunctions.checkIsNull(self) then
        local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
        local limitTimeEventIcon = self:getUI("LimitTimeEventIcon")
        if (datas["fullEventPoint"] and nk.limitTimeEventDataController:getAllEventRewardStatus() ~= -1) or datas["singleEventPoint"] then
            limitTimeEventIcon:setFile("res/limitTimeEvent/lTEvent_done.png")
        else
            limitTimeEventIcon:setFile("res/limitTimeEvent/lTEvent_time.png")
        end
    end
end

function HallScene:DrawVip(node,vipLevel)
    node:removeAllChildren(true)
    local vipIcon = new(Image,"res/common/vip_small/v.png")
    vipIcon:setAlign(kAlignCenter)
    vipIcon:setPos(40,10)
    node:addChild(vipIcon)
    vipLevel = tonumber(vipLevel)

    if vipLevel >=10 then
        local num1 = math.modf(vipLevel/10)
        local num2 = vipLevel%10

        local vipNum1 = new(Image,"res/common/vip_small/" .. num1 .. ".png")
        vipNum1:setAlign(kAlignCenter)
        vipNum1:setPos(53,9)
        node:addChild(vipNum1)
        local vipNum2 = new(Image,"res/common/vip_small/" .. num2 .. ".png")
        vipNum2:setAlign(kAlignCenter)
        vipNum2:setPos(60,9)
        node:addChild(vipNum2)
    else
        local vipNum = new(Image,"res/common/vip_small/" .. vipLevel .. ".png")
        vipNum:setAlign(kAlignCenter)
        vipNum:setPos(53,9)
        node:addChild(vipNum)
    end   
end

function HallScene:onLimitTimeOpen(pack)
    if pack then
        local num = pack.num
        local tnum = pack.tnum
        if nk.limitTimer:getTime() >0 then
            nk.limitTimer:addTimeText(self.limitTimeText)
            if tnum and  num then
                if tnum>0 then
                    self.limitTimeNumBg:setVisible(true)
                    self.limitTimeNum:setText(num.."/"..tnum)
                else
                    self.limitTimeNumBg:setVisible(false)
                end
                if num==0 then
                    self.limitTimeBtn:setVisible(false) 
                else
                    self.limitTimeBtn:setVisible(true)
                    self.firstPayBtn:setVisible(false)
                end
            end
        end
    end
end

function HallScene:onLimitTimeClose(isBuySuccess)
    if isBuySuccess then
        self.firstRechargeStatus=0
    end
    self.limitTimeBtn:setVisible(false)
    if self.firstRechargeStatus and self.firstRechargeStatus==1 then
        self.firstPayBtn:setVisible(true)
        self.quickPayBtn:setVisible(false)
    else
        self.firstPayBtn:setVisible(false)
        self.quickPayBtn:setVisible(true)
    end
end

function HallScene:onRefreshFriendList()
    if self.m_isGetFriendList_ing then
        return 
    end
    self.m_noFriendTipsView:setVisible(false)
    self.m_LoadingAnim:onLoadingStart()
    self.m_isGetFriendList_ing = true
    self.m_friendDataManager:loadFriendData(handler(self, function(obj, status, data)
            self.m_isGetFriendList_ing = false
            if status and data and #data > 0 then
                self.m_LoadingAnim:onLoadingRelease()
                local adapter = new(CacheAdapter, HallPlayerItem, data)
                self.m_friendsListView:setAdapter(adapter)
            else
                self.m_friendsListView:removeAllChildren(true)
                if self.m_recommendListView:getVisible() then
                    self.m_noFriendTipsView:setVisible(true)
                end
                local params = {}
                params.mid = nk.userData.mid
                nk.HttpController:execute("getRecommendFriendList", {game_param = params},nil,
                    handler(self, function(obj, errorCode, data)
                        self.m_LoadingAnim:onLoadingRelease()
                        if errorCode == HttpErrorType.SUCCESSED and data and data.code == 1 and #data.data>0 then
                            local adapter = new(CacheAdapter, HallRecommendItem, data.data)
                            self.m_recommendListView:setAdapter(adapter)
                        end
                    end)
                    )
            end
        end))
    nk.GCD.PostDelay(self, function()
        self.m_isGetFriendList_ing = false
    end, nil, 2000)
end

--首充和快充 限时礼包 互斥
function HallScene:recharge(firstRechargeStatus)
    if firstRechargeStatus and firstRechargeStatus == 1 then
        self.firstRechargeStatus = firstRechargeStatus
        if nk.limitTimer:getTime()>0 then
            self.quickPayBtn:setVisible(false)
            self.firstPayBtn:setVisible(false)
        else
            self.firstPayBtn:setVisible(true)
            self.quickPayBtn:setVisible(false)
        end
        local x,y = self.quickPayBtn:getPos()
        self.limitTimeBtn:setPos(x,y-11)
    else
        self.limitTimeBtn:setPos(self.limitPos)
        self.quickPayBtn:setVisible(true)
        self.firstPayBtn:setVisible(false)
    end
end
-- 快捷支付按钮点击
function HallScene:onQuickPayButtonClick()
    Log.printInfo("HallScene","onQuickPayButtonClick")
    nk.AnalyticsManager:report("New_Gaple_hall_quick_pay", "quickpPay")
    nk.payScene = consts.PAY_SCENE.HALL_FAST_PAY
    nk.updateFunctions.makeQuickPay()
    nk.DataCenterManager:report("btn_QuickPay")
end

function HallScene:onFirstPayButtonClick()
    nk.payScene = consts.PAY_SCENE.HALL_FISRT_PAY
    nk.PopupManager:addPopup(FirstRechargePopup,"hall") 
    nk.DataCenterManager:report("btn_firstPay")
end

function HallScene:onLimitTimeClick()
    nk.payScene = consts.PAY_SCENE.HALL_LIMIT_PAY
    nk.PopupManager:addPopup(require("game.limitTimeGiftbag.limitTimeGiftbagPopup"),"hall") 
    nk.DataCenterManager:report("btn_limitTimeGiftbag")
end

function HallScene:onLimitTimeEventBtnClick()
    nk.AnalyticsManager:report("New_Gaple_limitTimeEvent_hall", "limitTimeEvent")
    local LimitTimeEventPopup = require("game.limitTimeEvent.limitTimeEventPopup")
    nk.PopupManager:addPopup(LimitTimeEventPopup,"hall")
    nk.DataCenterManager:report("btn_limitTimeEvent")
end

function HallScene:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "activityNum", self.activityNumObserverHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", self.chatRecordHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "micon", self.miconHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "msex", self.msexHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "MsgMainPoint", self.NewMessageDataHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "TaskMainPoint", self.TaskDataHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "settingPoint", self.settingHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "fullEventPoint", self.fullEventHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "singleEventPoint", self.singleEventHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "eventIsOpen", self.eventIsOpenHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "FreeMoneyModTips", self.freeMoneyHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "inviteIsGet", self.inviteIsGetHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "name", self.nameHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", self.onFirstRechargeStatusHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "vip", self.vipObserverHandle_)
end
-------------------------------- table config ------------------------

-- Provide cmd handle to call
HallScene.s_cmdHandleEx = 
{
    ["refreshFriendList"] = HallScene.onRefreshFriendList,
    ["openLimitTimeGiftbag"] = HallScene.onLimitTimeOpen,
    ["closeLimitTimeGiftbag"] = HallScene.onLimitTimeClose,
}

return HallScene