-- httpConfig.lua
-- Last modification : 2016-05-10
-- Description: a config include all http request config.
-- http的相关配置

HttpConfig = {}

if IS_RELEASE then
	-- 检查更新，正式服
	HttpConfig.VERSION_CHECK_URL 	= "https://mvlpiddn.boyaagame.com/dominogaple/platform/androidid/updateapi.php"
	-- 游戏登陆的url ，正试服
	HttpConfig.LOGIN_URL = "http://mvlpiddn.boyaagame.com/dominogaple/platform/androidid/index.php"
	-- 游戏内请求的url ，正试服
	HttpConfig.BASE_URL = "http://mvlpiddn.boyaagame.com/dominogaple/api/gateway.php"
    -- 游戏反馈的url, 正式服
    HttpConfig.FEEDBACK_RUL = "http://ifeedback.boyaagame.com/api.php"
else
	-- 检查更新，测试服
	HttpConfig.VERSION_CHECK_URL 	= "http://192.168.204.153/gaple/platform/androidid/updateapi.php"
	-- 游戏登陆的url ，测试服
	HttpConfig.LOGIN_URL = "http://192.168.204.153/gaple/platform/androidid/index.php"
	-- 游戏内请求的url ，测试服
	-- HttpConfig.BASE_URL = "http://192.168.204.153/gaple/api/gateway.php"
	HttpConfig.BASE_URL = "http://192.168.96.152/jeffhas_dev/jdcomb/"
	-- HttpConfig.BASE_URL = "http://caofei.ilovehai.com/"
	-- HttpConfig.BASE_URL = "http://jdcomb.by.com/"
    -- 游戏反馈的url, 测试服
    HttpConfig.FEEDBACK_RUL = "http://192.168.204.153/jdc/_feedback/api.php"
end






-- 是否通过socket请求http(0不要，1要)，在请求版本检查后php回调重设
HttpConfig.SOCKET_REQUEST = 0


--登录地址，本来是在检查更新VERSION_CHECK_URL这个接口返回的，现在加上默认地址
HttpConfig.INDEX_DEFAULT_URL_LOCAL = "http://192.168.204.153/gaple/api/gateway.php"
HttpConfig.INDEX_DEFAULT_URL_ONLINE = "http://mvlpiddn.boyaagame.com/dominogaple/platform/androidid/index.php"

HttpConfig.platform = (System.getPlatform() == kPlatformWin32 and kPlatformAndroid or System.getPlatform())
-- Http request config struct
--[[
	indexStr = { (## indexStr is the sign of http request)
		table game_param (## http request need params)
		function string callback (## http request callback in httpProcesser)
		[
		string mod
		string act
		] or [
		string method
		] (## 2 ways to define method in http request)
		*string url (## http request url , if no, will use default url that define after login)
		*int httpType (## http request type , if no, will use default type that define in HttpModule)
		*int timeout (## http request timeout , if no, will use default timeout that define in HttpModule)
		*boolean addDefaultParams (## need add defaultParams or not. if zhe url is new, awalys no need add defaultParams)
		*string callback (## function name, when http response will call this function in processer)
	}	
]]



HttpConfig.s_request = 
{	
	["Login.userLogin"] = {
		method = "Login.userLogin",
		game_param = {"method","loginType"},
	},


	["User.updateGameInfo"] = {
		method = "User.updateGameInfo",
		game_param = {"method","mid","nick","iconUrl","gameInfolist","btnInfoList"},
	},


	["User.uploadIcon"] = {
		method = "User.uploadIcon",
		mid = MID,
		game_param = {"method"},
	},

	["Rank.getRankList"] = {
		method = "Rank.getRankList",
		mid = MID,
		game_param = {"method"},
	},



	["Http_checkVersion"] = {
		-- osVersion 全版本 ；  version 大版本
		game_parm = {"device", "pay", "noticeVersion", "osVersion", "version", "sid"},
		url = HttpConfig.VERSION_CHECK_URL,
		addDefaultParams = false,
		-- isHttp = true,
	},

	["login"] = {
		method = "",
		game_param = {"mid"},
		url = HttpConfig.LOGIN_URL,
		callback = "loginCallBack",
		-- isHttp = true,
	},

	["Http.load"] = {
		method = "GameServer.load",
		game_param = {"mid"},
		callback = "loadCallBack",
		-- isHttp = true,
	},

	["loginReward"] = {
		method = "",
		game_param = {"mid"},
		url = nil,
		callback = "getLoginRewardConfigCallBack",
		httpType = kHttpGet,
	},

	["roomConfig"] = {
		method = "Config.roomList",
		game_param = {"mid"},
		url = nil,
		callback = "getRoomConfigCallBack",
		-- httpType = kHttpGet,
	},

	["levelConfig"] = {
		method = "",
		game_param = {"mid"},
		url = nil,
		callback = "getLevelConfigCallBack",
		httpType = kHttpGet,
	},

	["expConfig"] = {
		method = "",
		game_param = {"mid"},
		url = nil,
		callback = "getExpConfigCallBack",
		httpType = kHttpGet,
	},

	["umengConfig"] = {
		method = "",
		game_param = {"mid"},
		url = nil,
		callback = "getUmengConfigCallBack",
		httpType = kHttpGet,
	},

	["logoutConfig"] = {
		method = "",
		game_param = {"mid"},
		url = nil,
		callback = "getLogoutConfigCallBack",
		httpType = kHttpGet,
	},

	getMemberInfo = {
		method = "Member.getMemberByMid",
		game_param = {},
		callback = "getMemberInfoCallBack",
	},

	-- 接龙在线人数
	["GameServer.getRoomSitNumber"] = {
		method = "GameServer.getRoomSitNumber",
		game_param = {},
	},

	-- 99在线人数
	["GameServer.get99RoomSiteNumber"] = {
		method = "GameServer.get99RoomSiteNumber",
		game_param = {},
	},

	["Invite.inviteAddMoney"] = {
		method = "Invite.inviteAddMoney",
		game_param = {"data","requestid"},
	},

	--更新用户最佳记录 maxmoney,maxwmoney,maxwcard,bankruptcy,dayplaynum,invite,ispay,mwin
	updateMemberBest = {
		method = "Best.updateMemberBest",
		game_param = {},
	},

	--获取道具列表
	getUserProps = {
		method = "Props.getPropsList",
		game_param = {},
	},

	-- 使用道具统一接口
	useProps = {
		method = "Props.useProp",
		game_param = {},
	},

	-- 使用道具统一接口 话费金币
	usePropsByGold = {
		method = "Props.directUseBroadcast",
		game_param = {},
	},

	--获取支付渠道配置
	getPayTypeConfig = {
		method = "Pmode.getPmodeList",
		game_param = {},
	},

	--获取道具类型配置
	getPropTypeConfig = {
		method = "Payment.getPropGroupList",
		game_param = {},
	},

	-- 获取购买历史
	getStoreHistory = {
		method = "Payment.getUserPayList",
		game_param = {},
	},
	
	-- 创建订单
	createOrder = {
		method = "Payment.callPayOrder",
		game_param = {"apkVer"},
	},

	-- google check out 支付成功后通知php
	googlePaySuccess = {
		method = "Payment.callClientPayment",
		game_param = {"signedData", "signature", "pmode"},
	},

	-- 购买道具
	buyProp = {
		method = "Props.buyProp",
		game_param = {"mid", "pnid", "num"},
	},

	-- 获取好友列表
	getFriendList = {
		method = "Friends.getFriendsList",
		game_param = {"mid"},
	},

	-- 获取好友推荐列表
	getRecommendFriendList = {
		method = "Friends.recommendFriend",
		game_param = {},
	},
	
	-- 查找玩家根据ID
	searchFriendById = {
		method = "Friends.searchFriend",
		game_param = {"smid"},
	},

	-- 获取自己一周内的牌局记录（排行榜中使用）
	getMyGameData = {
		method = "Ranking.getUserRank",
		game_param = {},
	},

	-- 获取对应类型的排行榜
	getRankData = {
		method = "Ranking.getServerRank",
		game_param = {"mid", "type", "page"},
	},

	--自助服务
    ["self_service_info"] = {
        httpType = kHttpGet,
    },

    -- 获取配置文件信息
	getConfigData = {
		method = "Config.getDataFile",
		game_param = {"name"},
	},

	-- 获取邀请模块，我的奖励数据 
	getInviteAwardData = {
		method = "Invite.getPrizeList",
		game_param = {"mid", "day"},
	},

	-- 领取邀请奖励 
	getInviteAward = {
		method = "Invite.sendPrize",
		game_param = {"mid", "id", "isAll"},
	},

	--获取倒计时宝箱信息
	getChest = {
		method = "Chest.getChest",
		game_param = {},
	},

	--领取宝箱奖励信息
	getCountDownBoxReward = {
		method = "Chest.receiveChest",
		game_param = {},
	},

    --feedback history
    ["feedback.getList"] ={
        method = "feedback.getList",
        game_param = {{"mid","device"}},
        addDefaultParams = false,
        -- isHttp = true,
    },
    --feedback send
    ["feedback.send"] ={
        method = "feedback.send",
        game_param = {{"mid","device","gametype","username","contact","category","title","content","level"}},
        addDefaultParams = false,
        -- isHttp = true,
    },
    --feedback expose
    ["Feedback.expose"] ={
        method = "Feedback.expose",
        game_param = {},
    },
    --feedback getExposeConfig
    ["Feedback.getExposeConfig"] ={
        method = "Feedback.getExposeConfig",
        game_param = {},
    },
    
    --feedback uploadpic
    ["attach.upload"] ={
        method = "attach.upload",
        game_param = {{"fid"}},
        addDefaultParams = false,
    },
    --get message
    ["Message.getUserMessage"] ={
        method = "Message.getUserMessage",
    },
    --message getprize
    ["MsgPrize.getPrize"] ={
        method = "MsgPrize.getPrize",
        httpType = kHttpPost,
    },
    --message delete
    ["Message.deleteUserMessage"] ={
        method = "Message.deleteUserMessage",
        httpType = kHttpPost,
    },
    --message read
    ["Message.readedMessage"] ={
        method = "Message.readedMessage",
        httpType = kHttpPost,
    },

    --get task
    ["Task.getNewAllTask"] ={
        method = "Task.getNewAllTask",
        httpType = kHttpPost,
    },

    --task reward
    ["Task.awardTask"] ={
        method = "Task.awardTask",
        httpType = kHttpPost,
    },

    --code
    ["Invite.checkConversionCode"] ={
        method = "Invite.checkConversionCode",
        httpType = kHttpPost,
    },

    --Upgrade
    ["Level.upGrade"] ={
        method = "Level.upGrade",
        httpType = kHttpPost,
    },
    --bankrupt
    ["Bankruptcy.receiveBankruptcy"] ={
        method = "Bankruptcy.receiveBankruptcy",
        httpType = kHttpPost,
    },    
    --firstRecharge
    ["Monthfirstpay.getFirstPayInfo2"] ={
        method = "Monthfirstpay.getFirstPayInfo2",
        httpType = kHttpPost,
    }, 

    getMonthFirstPayLast ={
        method = "Monthfirstpay.getMonthFirstPayLast",
        game_param = {"mid"},
    }, 

    postSignOrDynamics = {
    	method = "Social.saveTxt",
        game_param = {"mid","type","content"},
	},

    -- 添加好友
    addFriend = {
        method = "Friends.newAddFriendsNew",
        game_param = {"mid", "fid"},
    },

    -- 删除好友
    deleteFriend = {
        method = "Friends.newDeleteFriends",
        game_param = {"mid", "fid"},
    },

    -- 赠送金币
    sendMoneyToFriend = {
        method = "Friends.giveChouma",
        game_param = {"mid", "fid"},
    },

    -- 获取自己的礼物
    getMyGiftInfo = {
        method = "Props.getGiftList",
        game_param = {},
    },

    -- 设置礼物
    useGift = {
    	method = "Props.setGift",
    	game_param = {},
    },

    -- 购买礼物
    buyGift = {
    	method = "Props.buyGift",
    	game_param = {pnid,fid},
    },

    --modify  name and sex
    ["Member.updateMinfo"] = {
        method = "Member.updateMinfo",
        httpType = kHttpPost,
        callback = "getEditFinishInfo",
    },
    --updata headpic call php
    ["Member.updateUserIcon"] = {
        method = "Member.updateUserIcon",
        httpType = kHttpPost,
    },
    -- 获取邀请Id
    getInviteId = {
        method = "Invite.getInviteID",
    },

    -- 邀请上报，以便领奖
    inviteReport = {
        method = "Invite.inviteReport",
        callback = "inviteReportCallBack",
    },

    -- 谷歌推送Token上报
    googleTokenReport = {
        method = "Member.setClientid",
        game_param = {type, clientid}, --type:2（google）
    },
      -- 购买礼物
    getLimitTimeGiftbag  = {
        method = "Pmode.getLimGiftConf",
        game_param = {pnid,fid},
        callback = "onGetLimitTimeGiftbag"
    },
    -- 设置头像
    setHeadIcon  = {
        method = "Social.setDefautIcon",
        game_param = {mid,index},
    },

    -- 获取个人动态
    ["Social.getDynamic"] ={
        method = "Social.getDynamic",
        game_param = {{"mid", "uid", "num"}},
        -- httpType = kHttpPost,
        -- addDefaultParams = false,
    },
     
    -- 点赞相册 & 动态
    ["Social.thumbsUp"] ={
        method = "Social.thumbsUp",
        game_param = {{"mid", "uid", "type", "msgid"}},
    },

    -- 删除动态
    ["Social.delDynamic"] ={
        method = "Social.delDynamic",
        game_param = {{"mid", "msgid", "isinfo"}},
    },
  -- 获取全服和个人活动数据
    ["AllServerActivity.getConfig"] = {
    	method = "AllServerActivity.getConfig",
        game_param = {"mid"},
    },

    -- 获取全服活动当前进度
    ["AllServerActivity.getActivityCounts"] = {
    	method = "AllServerActivity.getActivityCounts",
    	game_param = {"sid"},
    },

    -- 全服活动领奖
    ["AllServerActivity.getPrize"] = {
    	method = "AllServerActivity.getPrize",
    	game_param = {"mid","type","num"},
    },


    ["Props.syntConf"] = {
    	method = "Props.syntConf",
    	game_param = {{"mid",}},
	},

	["Props.syntProp"] = {
		method = "Props.syntProp",
		game_param = {{"mid", "pnid"}},
	}, -- 领取奖励
    ["Login.getLoginReward"] ={
        method = "Login.getLoginReward",
        game_param = {{"mid"}},
    },
      -- 领取累积登录奖励
    ["Login.getAttachAward"] ={
        method = "Login.getAttachAward",
        game_param = {{"mid","day"}},
    },
    ["WinLottery.getConfig"] ={
        method = "WinLottery.getConfig",
        game_param = {{"mid"}},
    },
    ["WinLottery.runLottery"] ={
        method = "WinLottery.runLottery",
        game_param = {{"mid"}},
    },
    ["Props.syntProp"] = {
    	method = "Props.syntProp",
    	game_param = {{"mid","pnid"}},
	},
	["Props.exchProp"] = {
    	method = "Props.exchProp",
    	game_param = {{"mid","pnid","info"}},
	},
	["Props.sendProp"] = {
		method = "Props.sendProp",
		game_param = {{"mid", "pnid", "to"}}
	},

	-- 广告配置
	["Advert.getAdList"] = {
		method = "Advert.getAdList",
		game_param = {{"mid"}}
	},
	["Advert.sendAward"] = {  -- 广告领奖
		method = "Advert.sendAward",
		game_param = {{"mid"}}
	},
	["Advert.getList"] = {  -- 换量配置
		method = "Advert.getList",
		game_param = {{"mid"}}
	},
	["Advert.getAward"] = {  -- 换量领奖
		method = "Advert.getAward",
		game_param = {{"mid", "cekuid", "game"}}
	},

    ["FiveStarGrade.getReward"] = {  -- 五星好评
        method = "FiveStarGrade.getReward",
        game_param = {{"mid", "star"}}
    },

    ["Member.FBBind"] = {  -- FB绑定
        method = "Member.FBBind",
        game_param = {},
    },

    ["Member.checkFBBind"] = {
    	method = "Member.checkFBBind",
    	game_param = {},
    },
    -- report  data center
    ["Login.sendData"] ={
        method = "Login.sendData",
        httpType = kHttpPost,
    },


}

return HttpConfig