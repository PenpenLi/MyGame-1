-- loginData.lua
-- Last modification : 2016-05-16
-- Description: a data in login moudle
local CacheHelper = require("game.cache.cache")
local LoginData = class(GameBaseData);

function LoginData:ctor(controller)
	Log.printInfo("LoginData.ctor");
	
	-- EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, LoginData.onHttpPorcesser);
end

function LoginData:dtor()

end

function LoginData:loginCallBack(errorCode,data)
    -- nk.SocketController:close(-1, handler(data, handler(self, self.processData)))

    self:processData(data)
end

function LoginData:processData(data)
	Log.dump(data,"LoginData.loginCallBack");
    local retData = data
    if type(retData) == "table" and retData.code and retData.code == 1 then  
           --限时礼包
        local info = retData.data.islimGift
        if info then
            local time = info.time or 0
            local num = info.num or 0
            local on = info.on
            local limId = info.limId
            if on==1 then
                nk.DictModule:setString("gameData", "limitid",limId or "0")
                nk.DictModule:saveDict("gameData")
                time = 0
            end
            nk.limitInfo = info
            if num ==0 then
                time = 0
            end

            -- 限时礼包结束后延长展示
            if time>0 then
                nk.limitTimer:setTime(time)
                nk.limitTimer:startSchedule()
            else
                if limId == nk.DictModule:getString("gameData", "limitTag", "0") and on ~= 1 then
                    local nowT = os.time()
                    local logoutT = nk.DictModule:getInt("gameData", "logoutTime",  0)
                    local remainingT = nk.DictModule:getInt("gameData", "remainingTime", 0)
                    local passT =  nowT - logoutT
                    if passT < remainingT then
                        nk.limitTimer.duringDelay = true
                        nk.limitTimer:setTime(remainingT - passT)
                        nk.limitTimer:startSchedule()
                    end
                end
            end
        end
        --在toOneDimensionalTable的时候,字典aUser下的数组会丢失，所以先存下引用
        assert(retData.data.aUser, "php error at LoginData:processData: " .. json.encode(retData))
        local sign = retData.data.aUser.sign or {}
        local dyna = retData.data.aUser.dyna or {}
        local tdyna = tonumber(retData.data.social.tdyna) or 0
        local photos = retData.data.social.images
        local iconurl = retData.data.social.iconurl

        nk.functions.toOneDimensionalTable(retData.data)                
        nk.functions.typeFilter(retData.data, {
            [tostring] = {'aUser.mavatar', 'aUser.memail', 'aUser.sitemid'},
            [tonumber] = {
                'aUser.lid', 'aUser.mid', 'aUser.mlevel', 
                'aUser.mltime', 'aUser.win',  'aUser.lose','aUser.money', 'aUser.sitmoney', 
                'isCreate', 'loginInterval' , 'isFirst', 'mid', 'aUser.exp',
                'ADCLoginOn','ADCLeaveOn','DropActivity','hallShowNewSign','newerStatis','regAges',
                'FBindex'
            }
        })
        retData.data.uid = retData.data.mid
        nk.HttpController:setSessionKey(retData.data.sesskey)
        nk.HttpController.m_httpModule:setDefaultURL(retData.data.gateway)

        nk.DataProxy:setData(nk.dataKeys.USER_DATA, retData.data, true)
        nk.DataProxy:cacheData(nk.dataKeys.USER_DATA)

        HttpConfig.inHallIp = nk.userData.hallip[1]

        --存一下签名和动态
        nk.userData.sign = sign
        nk.userData.dyna = dyna
        nk.userData.photos = photos
        nk.userData.iconurl = iconurl
        nk.userData.tdyna = tdyna
        -- Log.dump(nk.userData.sign, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> nk.userData.sign")
        -- Log.dump(nk.userData.dyna, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> nk.userData.dyna")

        self:requestCtrlCmd("LoginController.loginSuccess",errorCode,data);
    else
        if not retData then
            Log.printInfo("json parse error")
            self:requestCtrlCmd("LoginController.loginFail",{errorCode = 1});
        else
            self:requestCtrlCmd("LoginController.loginFail",{errorCode = retData.code, errorMsg = retData.codemsg, data = retData.data});
        end
    end

end

function LoginData:loadCallBack(errorCode,data)
	-- Log.printInfo("LoginData.loadCallBack");
	Log.dump(data, "loadCalolBackloadCloadallBack")
    if data then
       self:formatData(data.data)
    end
    self:requestCtrlCmd("LoginController.onLoginLoaded")
end

function LoginData:formatData(retData)
	nk.functions.typeFilter(retData.bankruptcyGrant,{
                [tonumber] = {
                    'num', 'maxBmoney', 'bankruptcyTimes', 
                }
            })

    nk.functions.typeFilter(retData.best,{
                [tostring] = {'maxwcard','maxwcardvalue'},
                [tonumber] = {
                    'bankruptcy', 'dayplaynum', 'invite','ispay','maxmoney','maxwmoney','mid','mwin','raward' 
                }
                
            })

	if not nk.userData then
        return
    end     
    nk.maxDiscount = retData.maxDiscount or 0
    nk.lotteryTimes = retData.winLotteryTimes or 0

    if retData.advert then
        nk.googlead = retData.advert.googlead or 0 --unityads开关
        nk.advertdl = retData.advert.advertdl or 0 --广告换量开关
        nk.unityadsTimes = retData.advert.video or 0 -- 剩余次数
    end 
    
    nk.OnOff:init(retData)   

    if retData.bankruptcyGrant then
        nk.UserDataController.setBankruptcyGrant(retData.bankruptcyGrant)
    end

    if retData.loginAward then
        nk.UserDataController.setLoginReward(retData.loginAward)
    end
    --邀请送多少筹码
    if retData.inviteSendChips then
        nk.UserDataController.setInviteSendChips(retData.inviteSendChips)
    end
    --邀请回来送多少筹码
    if retData.inviteBackChips then
        nk.UserDataController.setInviteBackChips(retData.inviteBackChips)
    end
    --老用户请回来送多少（暂时没有）
    if retData.recallBackChips then
        nk.UserDataController.setRecallBackChips(retData.recallBackChips)
    end
    --老用户邀请送多少（暂时没有）
    if retData.recallSendChips then
        nk.UserDataController.setRecallSendChips(retData.recallSendChips)
    end
    --用fb登录额外送多少
    if retData.loginWithFBOtherAward then
        nk.UserDataController.setLoginWithFBOtherAward(retData.loginWithFBOtherAward)
    end
    --短信邀请送多少
    if retData.smsInviteAward then
        nk.UserDataController.setSmsInviteAward(retData.smsInviteAward)
    end 
    --email邀请送多少
    if retData.emailInviteAward then
        nk.UserDataController.setEmailInviteAward(retData.emailInviteAward)
    end
    --邀请注册送多少
    if retData.inviteForRegist then
        nk.UserDataController.setInviteForRegist(retData.inviteForRegist)
    end
    --
    if retData.registrationAward then
        nk.UserDataController.setRegisterReward(retData.registrationAward)
    end
    if retData.best then
        nk.UserDataController.setBest(retData.best)
    end

    if retData.broadcastPrice then
        nk.UserDataController.setBroadcastPrice(retData.broadcastPrice)
    end

    -- 私人房【刷新间隔、列表数量】
    if retData.privateRoom then
        nk.UserDataController.setPrivateRoom(retData.privateRoom)
    end

    -- nk.gameData.commentUrl=BM_UPDATE.COMMNET_URL;
    -- nk.UserDataController.setCommentUrl(BM_UPDATE.COMMNET_URL)

    nk.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}, true)
    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}

    --任务红点(设置为nk.dataKeys.NEW_MESSAGE的一个属性值)
    Log.dump(retData.tipsControl)
    if retData.tipsControl and retData.tipsControl.FreeMoneyModTips then
        for i,v in ipairs(retData.tipsControl.FreeMoneyModTips) do
              if v == 1 then
                   datas["TaskMainPoint"] = true 
                   break
              end
        end
    end

    -- 免费模块红点( 1:任务 3:兑换码 5:登陆奖励 7:升级)（php定的）  ,新增一个视屏的红点:9
    if retData.tipsControl and retData.tipsControl.FreeMoneyModTips then     
        table.foreach(retData.tipsControl.FreeMoneyModTips, function(i, v)
            if v == 1 then
                table.remove(retData.tipsControl.FreeMoneyModTips, i)  -- 每日任务单独出来了
            end
        end)
        nk.userData["FreeMoneyModTips"] = retData.tipsControl.FreeMoneyModTips
    else
        nk.userData["FreeMoneyModTips"] = {}
    end

    -- 注册奖励和登陆奖励改成了手动领取
    if (nk.userData.registerRewardAward and nk.userData.registerRewardAward.ret==0)  or 
       (nk.userData.loginReward and nk.userData.loginReward.ret == 0) then
            local arrays = clone(nk.userData["FreeMoneyModTips"])
            table.insert(arrays, 5)
            nk.userData["FreeMoneyModTips"] = arrays
    end

    -- 可领升级奖励
    if retData.tipsControl and retData.tipsControl.invitableLevel then
        nk.userData["invitableLevel"] = retData.tipsControl.invitableLevel
    else
        nk.userData["invitableLevel"] = {}
    end

    -- 控制展示哪个标签(1系统公告; 2系统消息; 3好友)
    if retData.tipsControl and retData.tipsControl.MessageShowTap then
        nk.UserDataController.setMessageShowTap(retData.tipsControl.MessageShowTap)
    end

    -- 二维码图片地址
    if retData.GPQRCode then
        nk.UserDataController.setGpqrCode(retData.GPQRCode)
    end

    -- 首充状态
    if retData.firstPayStatus then
        nk.userData["firstRechargeStatus"] = retData.firstPayStatus
    end

    --系统消息强弹框
    if retData.tipsControl and retData.tipsControl.DropMessageFlag then
        nk.userData["DropMessageFlag"] = retData.tipsControl.DropMessageFlag
        if nk.userData["DropMessageFlag"] ~= 1 then
            -- 加载公告
            if nk.userData.NOTICE_JSON then
                local cacheHelper_ = new(CacheHelper) 
                cacheHelper_:cacheFile(nk.userData.NOTICE_JSON,function(result, content, stype)
                    if result then
                        if stype == "downLoad" then
                            -- 标记系统公告未读
                            nk.DictModule:setInt("gameData", nk.cookieKeys.SYSTEM_NOTICE_READ, 0)
                            datas["sysNoticePoint"] = true
                            if not nk.PopupManager:hasPopup(nil,"MessagePopup") then
                                datas["MsgMainPoint"] = true
                            end
                        else
                            if nk.DictModule:getInt("gameData", nk.cookieKeys.SYSTEM_NOTICE_READ, 0) == 0 then
                                datas["sysNoticePoint"] = true
                                if not nk.PopupManager:hasPopup(nil,"MessagePopup") then
                                    datas["MsgMainPoint"] = true
                                end
                            end
                        end
                    end
                end,"notice","data")
            end
        end
    end 

    --消息红点
    if retData.tipsControl and retData.tipsControl.noReadMessage == 1 then
        datas["MsgMainPoint"] = true
    end

    --反馈红点
    nk.FeedbackController:getFeedbackData(function(result,content)
        Log.printInfo("LoginData","show feedback red point !")
    end)
    nk.RoomConfigController:getRoomConfig()
    nk.fiveStar = retData.fiveStar

    --上一次支付的商品信息
    if retData.fastPay then
        nk.userData.fastPay = {}
        nk.userData.fastPay.pmode = checkint(retData.fastPay[1])
        nk.userData.fastPay.id = checkint(retData.fastPay[2])
        nk.userData.fastPay.getname = ""
    end
end

-- Event to register and unregister
LoginData.s_eventHandle = {
    
};

LoginData.s_httpRequestsCallBack = {
	["login"] = LoginData.loginCallBack,
	["Http.load"] = LoginData.loadCallBack,
}

-- Provide handle to call
LoginData.s_cmdConfig = 
{
	--["***"] = function
};

return LoginData