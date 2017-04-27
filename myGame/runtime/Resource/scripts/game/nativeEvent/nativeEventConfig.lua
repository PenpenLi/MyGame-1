kLuaCallNavite = "OnLuaCall";

kLuaCallFuc = "LuaCallFuc";	-- lua调用java, java端获取function key
kLuaEventCall = "LuaEventCall";	-- java调用lua, lua端获取function key

-- // 结果返回 [-1、调用失败; 0、处理失败; >1、成功
kCallResult = "CallResult"
kResultCancle = -3;
kResultFail = -2;
kResultSucess = 1;

-- // 参数类型 [0、无参数; 1、int; 2、double; 3、string; 4、jsonString; 5、boolean]，
kCallParamType = "CallParamType";
kCallParamNo = 0
kCallParamInt = 1
kCallParamDouble = 2
kCallParamString = 3
kCallParamJsonString = 4
kCallParamBoolean = 5

kResultPostfix = "_result"; --返回结果后缀  与call_native(key) 中key 连接(key.._result)组成返回结果key

kParmPostfix = "_parm"; --参数后缀 


local NativeEventConfig = {}
local N = NativeEventConfig

-- 带有  _READ_ 后缀，可直接读取数值，没有回调

-- game --
N.NATIVE_GAME_PICKIMAGE = "gamePickImage" -- 选择头像
N.NATIVE_GAME_PICKIMAGE_CALLBACK = "gamePickImageCallBack" -- 选择头像返回
N.NATIVE_SHARE_APK = "shareApk"  --分享apk
N.NATIVE_GAME_PICKPICTURE = "gamePickPicture" -- 选择图片
N.NATIVE_GAME_PICKPICTURE_CALLBACK = "gamePickPictureCallBack" -- 选择图片返回

N.NATIVE_GAME_MERGE_APK = "mergeNewApk" -- 合并差分包

N.NATIVE_GAME_APK_INSTALL = "apkInstall" -- 安装apk

N.NATIVE_GAME_UNZIP = "unzip" -- 解压缩

N.NATIVE_GAME_OPEN_BROWSER = "openBrowser" -- 打开浏览器

N.NATIVE_GAME_SYSTEMINFO_READ_ = "readSystemInfo" -- 获取系统信息

N.NATIVE_GAME_CHANNEL_READ_ = "readChannel" -- 获取渠道号

N.NATIVE_GAME_UUID_READ_ = "readUUID" -- 获取UUID

N.NATIVE_GAME_VIBRATE = "vibrate" -- 震动
N.NATIVE_DELETE_UPDATE = "deleteUpdate"  -- 删除update文件夹
-- game end --

-- facebook --
N.NATIVE_FACEBOOK_LOGIN = "facebookLogin" -- facebook登陆
N.NATIVE_FACEBOOK_LOGIN_CALLBACK = "facebookLoginResult" -- facebook登陆返回
N.NATIVE_FACEBOOK_DELETE_REQUEST = "facebookDeleteRequestId" -- 删除邀请id

N.NATIVE_FACEBOOK_LOGOUT = "facebookLogout" -- facebook登出
N.NATIVE_FACEBOOK_LOGOUT_CALLBACK = "facebookLogoutResult" -- facebook登出返回

N.NATIVE_FACEBOOK_GETINVITABLEFRIENDS = "facebookGetInvitableFriends" -- facebook获取可邀请的好友列表
N.NATIVE_FACEBOOK_GETINVITABLEFRIENDS_CALLBACK = "facebookGetInvitableFriendsResult" -- facebook获取可邀请的好友列表返回

N.NATIVE_FACEBOOK_GETREQUESTID = "facebookGetRequestId" -- facebook获取邀请id
N.NATIVE_FACEBOOK_GETREQUESTID_CALLBACK = "facebookGetRequestIdResult" -- facebook获取邀请id返回

N.NATIVE_FACEBOOK_SHAREFEED = "facebookShareFeed" -- facebook分享
N.NATIVE_FACEBOOK_SHAREFEED_CALLBACK = "facebookShareFeedResult" --facebook分享返回

N.NATIVE_FACEBOOK_INVITE = "facebookInvite" -- facebook邀请
N.NATIVE_FACEBOOK_INVITE_CALLBACK = "facebookInviteResult" -- facebook邀请返回

N.NATIVE_FACEBOOK_UPLOAD = "facebookUpload" -- facebook 上传照片
N.NATIVE_FACEBOOK_UPLOAD_CALLBACK = "facebookUploadPhotoResult" -- facebook 上传照片

N.NATIVE_FACEBOOK_OPEN_PAGE = "facebookOpenPage" -- facebook 上传照片

N.NATIVE_FACEBOOK_BINDING = "facebookBinding" -- facebook 绑定
N.NATIVE_FACEBOOK_BINDING_CLLBACK = "facebookBindingResult" -- facebook 绑定返回

-- facebook end --

-- umeng --
N.NATIVE_UMENG_EVENT_COUNT = "umengEventCount"	--计数统计

N.NATIVE_UMENG_EVENT_COUNT_VALUE = "umengEventCountValue" --计算统计

N.NATIVE_UMENG_ERROR = "umengError" --友盟错误上报
-- umeng end --

-- facebook ad statistics --
N.NATIVE_AD_STATISTICS_START = "adStatisticsStart" -- 上报启动

N.NATIVE_AD_STATISTICS_REG = "adStatisticsReg"

N.NATIVE_AD_STATISTICS_LOGIN = "adStatisticsLogin" -- 上报登陆

N.NATIVE_AD_STATISTICS_PLAY = "adStatisticsPlay" -- 上报玩

N.NATIVE_AD_STATISTICS_PAY = "adStatisticsPay" -- 上报支付

N.NATIVE_AD_STATISTICS_RECALL = "adStatisticsRecall"

N.NATIVE_AD_STATISTICS_LOGOUT = "adStatisticsLogout"

N.NATIVE_AD_STATISTICS_CUSTOM = "adStatisticsCustom"
-- facebook ad statistics end--

-- activity --
N.NATIVE_ACTIVITY_INIT = "activityInt" -- 活动中心初始化

N.NATIVE_ACTIVITY_OPEN = "activityOpen" -- 打开活动中心

N.NATIVE_ACTIVITY_CUT_SERVER = "activityCutServer" -- 切换活动中心地址(正\测试服)

N.NATIVE_ACTIVITY_CALLBACK = "activityCallBack" -- 活动中心回调
-- activity end--

-- godsdk --
N.NATIVE_GODSDK_PAY = "godsdkPay" -- 调起godsdk支付

N.NATIVE_GODSDK_PAY_CALLBACK = "godsdkPayCallBack" -- godsdk支付回调
-- godsdk end --

-- gooogle --
N.NATIVE_GOOGLE_PAY = "googlePay" -- 调起google支付

N.NATIVE_GOOGLE_PAY_CALLBACK = "googlePayCallBack" -- google支付回调

N.NATIVE_GOOGLE_GET_TOKEN = "googleToken"

N.NATIVE_GOOGLE_TOKEN_CALLBACK = "googleTokenCallBack"


N.NATIVE_UNITY_ADS_IS_READY = "unityAdsIsReady" -- unity 广告
N.NATIVE_UNITY_ADS_SHOW = "unityAdsShow" -- unity 广告
N.NATIVE_UNITY_ADS_CALLBACK = "unityAdsCallBack" -- unity 广告返回

-- gooogle end --

return NativeEventConfig