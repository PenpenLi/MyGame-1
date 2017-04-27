--region userDataController.lua
--endregion

local UserDataController = {};

local propertyConfig = {
    ["aUser.cache"] = "cache";        
    ["aUser.exp"] = "exp";          
    ["aUser.gift"] = "gift";         
    ["aUser.lid"] = "lid";          
    ["aUser.lose"] = "lose";         
    ["aUser.mavatar"] = "mavatar";      
    ["aUser.memail"] = "memail";       
    ["aUser.micon"] = "micon";        
    ["aUser.mid"] = "mid";          
    ["aUser.minv"] = "minv";         
    ["aUser.mlevel"] = "mlevel";       
    ["aUser.mltime"] = "mltime";       
    ["aUser.money"] = "money";        
    ["aUser.msex"] = "msex";         
    ["aUser.msta"] = "msta";        
    ["aUser.mtime"] = "mtime";        
    ["aUser.name"] = "name";        
    ["aUser.sid"] = "sid";          
    ["aUser.sitemid"] = "sitemid";      
    ["aUser.version"] = "version"; 
    ["aUser.win"] = "win"; 
    ["aUser.FBindex"] = "FBindex"; 
    ["aUser.vip"] = "vip";
    ["aUser.score"] = "score";
    ["aUser.expiry_time"] = "expiry_time";
}

UserDataController.formatProperty = function(data)
    for k, v in pairs(propertyConfig) do
        if data[k] then
            data[v] = data[k]
            data[k] = nil
        end
    end
end

------------------------------------存取数据接口---------------------------------
-- 设置用户ID
UserDataController.setUid = function(user_id)
    nk.userData.uid = tonumber(user_id);
end

-- 获取用户ID
UserDataController.getUid = function()
    return nk.userData.uid or 0;
end

-- 设置用户uuid
UserDataController.setUUID = function( user_uuid)
    nk.userData.uuid = user_uuid;
end

-- 获取用户uuid
UserDataController.getUUID = function()
    return nk.userData.uuid or "";
end

-- 设置用户类型
UserDataController.setUserType = function( user_type)
    nk.userData.usertype = user_type;
end

-- 获取用户类型 
UserDataController.getUserType = function()
    return nk.userData.usertype;
end

-- 设置用户Name
UserDataController.setUserName = function(user_name)
    nk.userData.name = user_name;
end

-- 获取用户Name
UserDataController.getUserName = function()
    return nk.userData.name or "guest";
end

-- 设置用户身上金币数量
UserDataController.setUserMoney = function(user_money)
    nk.userData.money = checkint(user_money)
end

-- 获取用户身上金币数量
UserDataController.getUserMoney = function()
    return nk.userData.money or 0;
end

-- 设置单机金币数量
UserDataController.setSingleMoney = function(user_singleMoney)
    nk.userData.singleMoney = tonumber(user_singleMoney)
end

-- 获取单机金币数量
UserDataController.getSingleMoney = function()
    return nk.userData.singleMoney or 0;
end

-- 设置用户性别
UserDataController.setUserSex = function(user_msex)
    nk.userData.msex = tonumber(user_msex);
end

-- 获取用户性别
UserDataController.getUserSex = function()
    return nk.userData.msex or 1;
end

-- 设置用户图像
UserDataController.setMicon = function(user_micon)
    nk.userData.micon = user_micon;
end

-- 获取用户图像
UserDataController.getMicon = function()
    return nk.userData.micon or "";
end

--玩家签名
UserDataController.setUserSign = function(content,etime)
    local t = {}
    t[1] = content
    t[2] = etime
    
    nk.userData.sign = t
end
UserDataController.getUserSign = function()
     return nk.userData.sign or {"",0}
end
--玩家最新动态
UserDataController.setUserDyna = function(content, msgid, etime, thumbs)
    if type(content) == "table" then
        nk.userData.dyna = content
    else
        local t = {}
        t[1] = content
        t[2] = etime
        t[3] = thumbs
        t[4] = msgid
        t[5] = 1
        nk.userData.dyna = t
    end
end
UserDataController.getUserDyna = function()
     return nk.userData.dyna or {"",0}
end
--玩家fb主页是否公开,1关闭，2开
UserDataController.setFBindex = function(isOpen)
    nk.userData.FBindex = isOpen
end
UserDataController.getFBindex = function()
     return nk.userData.FBindex or 1
end





-- 设置用户等级
UserDataController.setMlevel = function( user_mlevel)
    nk.userData.mlevel = tonumber(user_mlevel);
end

-- 获取用户等级
UserDataController.getMlevel = function()
    return nk.userData.mlevel or 1;
end

-- 设置用户经验
UserDataController.setExp = function( user_exp)
    nk.userData.exp = tonumber(user_exp);
end

-- 获取用户经验
UserDataController.getExp = function()
    return nk.userData.exp or 1;
end

-- 设置用户礼物
UserDataController.setGift = function( user_gift)
    nk.userData.gift = tonumber(user_gift);
end

-- 获取用户礼物
UserDataController.getGift = function()
    return nk.userData.gift;
end

-- 设置用户赢次数
UserDataController.setWinNum = function( user_win)
    nk.userData.win = tonumber(user_win);
end
-- 获取用户赢次数
UserDataController.getWinNum = function()
    return nk.userData.win;
end

-- 设置用户输次数
UserDataController.setLoseNum = function( user_lose)
    nk.userData.lose = tonumber(user_lose);
end

-- 获取用户输次数
UserDataController.getLoseNum = function()
    return nk.userData.lose;
end

-- 设置历史最高资产
UserDataController.setMaxmoney = function( user_maxmoney)
    nk.userData.maxmoney = tonumber(user_maxmoney);
end

-- 获取历史最高资产
UserDataController.getMaxmoney = function()
    return nk.userData.maxmoney;
end

-- 设置历史最高赢取
UserDataController.setMaxwmoney = function( user_maxwmoney)
    nk.userData.maxwmoney = tonumber(user_maxwmoney);
end

-- 获取历史最高赢取
UserDataController.getMaxwmoney = function()
    return nk.userData.maxwmoney;
end

-- 设置历史最大牌
UserDataController.setMaxwcard = function( user_maxwcard)
    nk.userData.maxwcard = tonumber(user_maxwcard);
end

-- 获取历史最大牌
UserDataController.getMaxwcard = function()
    return nk.userData.maxwcard;
end

-- 设置历史最大牌型
UserDataController.setMaxwcardvalue = function( user_maxwcardvalue)
    nk.userData.maxwcardvalue = tonumber(user_maxwcardvalue);
end

-- 获取历史最大牌型
UserDataController.getMaxwcardvalue = function()
    return nk.userData.maxwcardvalue;
end

-- 设置历史破产相关
UserDataController.setBankruptcyGrant = function(user_bankruptcyGrant)
    nk.userData.bankruptcyGrant = user_bankruptcyGrant
end

-- 获取历史破产相关
UserDataController.getBankruptcyGrant = function()
    return nk.userData.bankruptcyGrant;
end

-- 设置是否禁言
UserDataController.setSilenced = function(user_silenced)
    nk.userData.silenced = tonumber(user_silenced);
end

-- 获取是否禁言
UserDataController.getSilenced = function()
    return nk.userData.silenced;
end


-- 设置是否禁言
UserDataController.setBest = function(user_best)
    nk.userData.best = tonumber(user_best);
end

-- 获取是否禁言
UserDataController.getBest = function()
    return nk.userData.best;
end

-- 设置是否第一次创建，如果是第一次创建，拉取FB邀请数据，判断是谁拉的
UserDataController.setIsCreate = function(isCreate)
    nk.userData.isCreate = tonumber(isCreate);
end

-- 获取是否第一次创建
UserDataController.getIsCreate = function()
    return nk.userData.isCreate;
end

-- 设置是否在线
UserDataController.setIsOnline = function(isOnline)
    nk.userData.isOnline = isOnline;
end

-- 获取是否在线
UserDataController.getIsOnline = function()
    return nk.userData.isOnline;
end






-- 设置注册奖励
UserDataController.setRegisterReward = function(registerReward)
    nk.userData.registerRewardAward = registerReward;
end

-- 获取注册奖励
UserDataController.getRegisterReward = function()
    return nk.userData.registerRewardAward;
end

-- 设置加载友盟开关配置
UserDataController.setSwitchData = function(switchData)
    nk.userData.switchData = switchData;
end

-- 获取加载友盟开关配置
UserDataController.getSwitchData = function()
    return nk.userData.switchData;
end

-- 获取礼物配置Json
UserDataController.getGiftJson = function()
    return nk.userData.GIFT_JSON;
end

-- 获取商城道具列表配置Json
UserDataController.getPropsJson = function()
    return nk.userData.PROPS_JSON;
end

-- 获取消息模板配置Json
UserDataController.getMsgtplRootJson = function()
    return nk.userData.MSGTPL_ROOT;
end

-- 获取等级配置Json
UserDataController.getLevelJson = function()
    return nk.userData.LEVEL_JSON;
end

-- 获取不同场次对应经验配置json
UserDataController.getExpJson = function()
    return nk.userData.EXP_JSON;
end

-- 获取等级配置Json
UserDataController.getUploadPicJson = function()
    return nk.userData.UPLOAD_PIC;
end

-- 获取幸运转盘配置Json
UserDataController.getWheelConfJson = function()
    return nk.userData.WHEEL_CONF;
end

-- 获取fb显示好友数
UserDataController.getFbInviteNumCfg = function()
    return nk.userData.fbInviteNumCfg;
end

-- 获取任务模板配置Json
UserDataController.getTaskJson = function()
    return nk.userData.TASK_JSON;
end

-- 获取友盟上报开关配置Json
UserDataController.getStatswitchJson = function()
    return nk.userData.STATSWITCH_JSON;
end

-- 获取退出弹窗的配置Json
UserDataController.getLogoutJsson = function()
    return nk.userData.LOGOUT_JSON;
end

-- 获取边注玩法配置Json
UserDataController.getSampinganJson = function()
    return nk.userData.SAMPINGAN_JSON;
end

-- 获取房间功能配置Json
UserDataController.getRoomfunctionJson = function()
    return nk.userData.ROOMFUNCTION_JSON;
end

-- 获取公告配置Json
UserDataController.getNoticeJson = function()
    return nk.userData.NOTICE_JSON;
end

-- 获取登陆奖励配置Json
UserDataController.getLoginrewardJson = function()
    return nk.userData.LOGINREWARD_JSON;
end

-- 获取排行榜奖励配置Json
UserDataController.getRankrewardJson = function()
    return nk.userData.RANKREWARD_JSON;
end

-- 获取单机奖励配置Json
UserDataController.getSinglerewardJson = function()
    return nk.userData.SINGLEREWARD_JSON;
end

--获取自助服务的问题配置
UserDataController.getSelfServiceJson = function()
    return nk.userData.SELF_SERVICE_JSON;
end

-- 获取ip,port
UserDataController.getHallip = function()
    local ip,port = string.match(nk.userData.hallip[1], "([%d%.]+):(%d+)")   
    return ip,port;
end

-- 设置活动中心活动个数
UserDataController.setActivityNum = function(activityNum)
    nk.userData.activityNum = tonumber(activityNum);
end

-- 获取活动中心活动个数
UserDataController.getActivityNum = function()
    return nk.userData.activityNum;
end




-- 设置好友uid列表
UserDataController.setFriendUidList = function(friendUidList)
    nk.userData.friendUidList = friendUidList;
end

-- 获取好友uid列表
UserDataController.getFriendUidList = function()
    return nk.userData.friendUidList;
end

-- 设置好友聊天记录
UserDataController.setChatRecord = function(chatRecord)
    nk.userData.chatRecord = chatRecord;
end

-- 获取好友聊天记录
UserDataController.getChatRecord = function()
    return nk.userData.chatRecord or {};
end

-- 设置是否赠送过好友金币
UserDataController.setIsSendChips = function(isSendChips)
    nk.userData.isSendChips = tonumber(isSendChips);
end

-- 获取是否赠送过好友金币
UserDataController.getIsSendChips = function()
    return nk.userData.isSendChips;
end

-- 设置邀请发送奖励
UserDataController.setInviteSendChips = function(inviteSendChips)
    nk.userData.inviteSendChips = tonumber(inviteSendChips);
end

-- 获取邀请发送奖励
UserDataController.getInviteSendChips = function()
    return nk.userData.inviteSendChips;
end

-- 设置邀请回来奖励
UserDataController.setInviteBackChips = function(inviteBackChips)
    nk.userData.inviteBackChips = tonumber(inviteBackChips);
end

-- 获取邀请回来奖励
UserDataController.getInviteBackChips = function()
    return nk.userData.inviteBackChips;
end

-- 设置召回发送奖励
UserDataController.setRecallSendChips = function(recallSendChips)
    nk.userData.recallSendChips = tonumber(recallSendChips);
end

-- 获取召回发送奖励
UserDataController.getRecallSendChips = function()
    return nk.userData.recallSendChips;
end

-- 设置召回奖励
UserDataController.setRecallBackChips = function(recallBackChips)
    nk.userData.recallBackChips = tonumber(recallBackChips);
end

-- 获取召回奖励
UserDataController.getRecallBackChips = function()
    return nk.userData.recallBackChips;
end

-- 设置买入
UserDataController.setRoomBuyIn = function(roomBuyIn)
    nk.userData.roomBuyIn = tonumber(roomBuyIn);
end

-- 获取买入
UserDataController.getRoomBuyIn = function()
    return nk.userData.roomBuyIn;
end 

-- 设置下个奖励等级
UserDataController.setNextRwdLevel = function(nextRwdLevel)
    nk.userData.nextRwdLevel = tonumber(nextRwdLevel);
end

-- 获取下个奖励等级
UserDataController.getNextRwdLevel = function()
    return nk.userData.nextRwdLevel;
end 

-- 设置当前在线人数
UserDataController.setUserOnline = function(userOnline)
    nk.userData.userOnline = tonumber(userOnline);
end

-- 获取当前在线人数
UserDataController.getUserOnline = function()
    return nk.userData.userOnline;
end 

-- 设置商品折扣配置
UserDataController.setItemDiscount = function(itemDiscount)
    nk.userData.itemDiscount = itemDiscount;
end

-- 获取商品折扣配置
UserDataController.getItemDiscount = function()
    return nk.userData.itemDiscount;
end 

-- 设置升级奖励
UserDataController.setInvitableLevel = function(invitableLevel)
    nk.userData.invitableLevel = invitableLevel;
end

-- 获取升级奖励
UserDataController.getInvitableLevel = function()
    return nk.userData.invitableLevel or {};
end 

-- 设置喇叭广播费用
UserDataController.setBroadcastPrice = function(broadcastPrice)
    nk.userData.broadcastPrice = tonumber(broadcastPrice);
end

-- 获取喇叭广播费用
UserDataController.getBroadcastPrice = function()
    return nk.userData.broadcastPrice;
end 

-- 设置短信邀请送多少
UserDataController.setSmsInviteAward = function(smsInviteAward)
    nk.userData.smsInviteAward = tonumber(smsInviteAward);
end

-- 获取短信邀请送多少
UserDataController.getSmsInviteAward = function()
    return nk.userData.smsInviteAward;
end 

-- 设置email邀请送多少
UserDataController.setEmailInviteAward = function(emailInviteAward)
    nk.userData.emailInviteAward = tonumber(emailInviteAward);
end

-- 获取email邀请送多少
UserDataController.getEmailInviteAward = function()
    return nk.userData.emailInviteAward;
end 

-- 设置fb显示好友数
UserDataController.setFbInviteNumCfg = function(fbInviteNumCfg)
    nk.userData.fbInviteNumCfg = tonumber(fbInviteNumCfg);
end

-- 获取fb显示好友数
UserDataController.getFbInviteNumCfg = function()
    return nk.userData.fbInviteNumCfg;
end 

-- 设置邀请注册送多少
UserDataController.setInviteForRegist = function(inviteForRegist)
    nk.userData.inviteForRegist = tonumber(inviteForRegist);
end

-- 获取邀请注册送多少
UserDataController.getInviteForRegist = function()
    return nk.userData.inviteForRegist;
end 

-- 设置登录奖励
UserDataController.setLoginReward = function(loginReward)
    nk.userData.loginReward = loginReward;
end

-- 获取登录奖励
UserDataController.getLoginReward = function()
    return nk.userData.loginReward;
end 

-- 设置用fb登录额外送多少
UserDataController.setLoginWithFBOtherAward = function(loginWithFBOtherAward)
    nk.userData.loginWithFBOtherAward = tonumber(loginWithFBOtherAward);
end

-- 获取用fb登录额外送多少
UserDataController.getLoginWithFBOtherAward = function()
    return nk.userData.loginWithFBOtherAward;
end 

-- 设置私人房【刷新间隔、列表数量】
UserDataController.setPrivateRoom = function(privateRoom)
    nk.userData.privateRoom = privateRoom;
end

-- 获取私人房【刷新间隔、列表数量】
UserDataController.getPrivateRoom = function()
    return nk.userData.privateRoom;
end 

-- 设置消息中心显示页码
UserDataController.setMessageShowTap = function(MessageShowTap)
    nk.userData.MessageShowTap = MessageShowTap;
end

-- 获取消息中心显示页码
UserDataController.getMessageShowTap = function()
    return nk.userData.MessageShowTap;
end 

-- 设置二维码图片地址
UserDataController.setGpqrCode = function(gpqrCode)
    nk.userData.gpqrCode = gpqrCode;
end

-- 获取二维码图片地址
UserDataController.getGpqrCode = function()
    return nk.userData.gpqrCode;
end 

-- 设置首充配置信息
UserDataController.setFirstRechargeConfig = function(firstRechargeConfig)
    nk.userData.firstRechargeConfig = firstRechargeConfig;
end

-- 获取首充配置信息
UserDataController.getFirstRechargeConfig = function()
    return nk.userData.firstRechargeConfig;
end 

-- 设置是否首充的标识
UserDataController.setFirstRechargeStatus = function(firstRechargeStatus)
    nk.userData.firstRechargeStatus = firstRechargeStatus;
end

-- 获取是否首充的标识
UserDataController.getFirstRechargeStatus = function()
    return nk.userData.firstRechargeStatus;
end 

-- 设置fb能否更改个人信息
UserDataController.setCanEditAvatar = function(canEditAvatar)
    nk.userData.canEditAvatar = canEditAvatar;
end

-- 获取fb能否更改个人信息
UserDataController.getCanEditAvatar = function()
    return nk.userData.canEditAvatar;
end 











UserDataController.setSitemid = function(user_sitemid)
    nk.userData.sitemid = tonumber(user_sitemid);
end

UserDataController.getSitemid = function()
    return nk.userData.sitemid;
end

UserDataController.setMcity = function(user_mcity)
    nk.userData.mcity = tonumber(user_mcity);
end

UserDataController.getMcity = function()
    return nk.userData.mcity;
end

UserDataController.setSid = function(user_sid)
    nk.userData.sid = tonumber(user_sid);
end

UserDataController.getSid = function()
    return nk.userData.sid;
end

UserDataController.setLid = function(user_lid)
    nk.userData.lid = tonumber(user_lid);
end

UserDataController.getLid = function()
    return nk.userData.lid;
end

UserDataController.setMtkey = function(user_mtkey)
    nk.userData.mtkey = tonumber(user_mtkey);
end

UserDataController.getMtkey = function()
    return nk.userData.mtkey;
end

UserDataController.setSkey = function(user_skey)
    nk.userData.skey = tonumber(user_skey);
end

UserDataController.getSkey = function()
    return nk.userData.skey;
end

UserDataController.setRegAges = function(user_regAges)
    nk.userData.regAges = tonumber(user_regAges);
end

UserDataController.getRegAges = function()
    return nk.userData.regAges;
end

UserDataController.setChannel = function(user_channel)
    nk.userData.channel = tonumber(user_channel);
end

UserDataController.getChannel = function()
    return nk.userData.channel;
end

UserDataController.setNewerStatis = function(newerStatis)
    nk.userData.newerStatis = newerStatis;
end

UserDataController.getNewerStatis = function()
    return nk.userData.newerStatis;
end

UserDataController.setDropMessageFlag = function(DropMessageFlag)
    nk.userData.DropMessageFlag = DropMessageFlag;
end

UserDataController.getDropMessageFlag = function()
    return nk.userData.DropMessageFlag;
end

UserDataController.setCommentUrl = function(commentUrl)
    nk.userData.commentUrl = commentUrl;
end

UserDataController.getCommentUrl = function()
    return nk.userData.commentUrl;
end

UserDataController.setFreeMoneyModTips = function(FreeMoneyModTips)
    nk.userData.FreeMoneyModTips = FreeMoneyModTips;
end

UserDataController.getFreeMoneyModTips = function()
    return nk.userData.FreeMoneyModTips or {};
end

UserDataController.setGiftShop = function(GIFT_SHOP)
    nk.userData.GIFT_SHOP = GIFT_SHOP;
end

UserDataController.getGiftShop = function()
    return nk.userData.GIFT_SHOP;
end

UserDataController.getPhotos = function()
    return nk.userData.photos;
end

UserDataController.getMemberInfo = function(params)
    nk.HttpController:execute("getMemberInfo", {game_param = params}, nil, function (errorCode, data)
        if errorCode == 1 and data.code == 1  then
            local retData = data.data
            if params.uid == nk.userData.mid then
                nk.functions.formatMemberInfo(retData)
                if retData then
                    Log.dump(retData, "getMemberInfo...")
                    nk.userData.name = retData.aUser.name or nk.userData.name or 0
                    nk.functions.setMoney(retData.aUser.money or nk.functions.getMoney() or 0 )
                    nk.userData.mlevel = retData.aUser.mlevel or nk.userData.mlevel or 1
                    nk.userData.exp = retData.aUser.exp or nk.userData.exp or 0
                    nk.userData.win = retData.aUser.win or nk.userData.win or 0
                    nk.userData.lose = retData.aUser.lose or nk.userData.lose or 0
                    nk.userData.msex = retData.aUser.msex or nk.userData.msex or 0
                    nk.userData.micon = retData.aUser.micon or nk.userData.micon or 0
                    nk.userData.mcity = retData.aUser.mcity or nk.userData.mcity or 0
                    nk.userData.photos = retData.aUser.images 
                    nk.userData.iconurl = retData.aUser.iconurl
                    nk.userData.sign = retData.aUser.sign or {"",0}
                    nk.userData.dyna = retData.aUser.dyna or {"",0}
                    nk.userData.FBindex = retData.aUser.FBindex or 1
                    nk.userData["aBest.maxmoney"] = retData.aBest.maxmoney or nk.userData["aBest.maxmoney"] or 0
                    nk.userData["aBest.maxwmoney"] = retData.aBest.maxwmoney or nk.userData["aBest.maxwmoney"] or 0
                    nk.userData["aBest.maxwcard"] = retData.aBest.maxwcard or nk.userData["aBest.maxwcard"] or 0
                    nk.userData["aBest.maxwcardvalue"] = retData.aBest.maxwcardvalue or nk.userData["aBest.maxwcardvalue"] or 0
                end
            end
            EventDispatcher.getInstance():dispatch(EventConstants.getMemberInfoCallback, retData)
        end
    end)
end






return UserDataController




