-- facebookNativeEvent.lua
-- Last modification : 2016-05-24
-- Description: a native event controller for facebook event moudle

local FacebookNativeEvent = class(GameBaseNativeEvent)

local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")

function FacebookNativeEvent:ctor()
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function FacebookNativeEvent:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

-- 绑定
function FacebookNativeEvent:facebookBinding()
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_BINDING, nil, nil, NativeEventConfig.NATIVE_FACEBOOK_BINDING_CLLBACK)
end

-- 登陆
function FacebookNativeEvent:login(callback)
	self.m_loginCallback = callback
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_LOGIN, nil, nil, NativeEventConfig.NATIVE_FACEBOOK_LOGIN_CALLBACK)
end

-- 登出
function FacebookNativeEvent:logout()
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_LOGOUT)
end

-- 获取可要求好友
function FacebookNativeEvent:getInvitableFriends(callback, testData)
	self.m_getInviteFriendCallback = callback
	local limit = 500
	local key = NativeEventConfig.NATIVE_FACEBOOK_GETINVITABLEFRIENDS
	if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
		nk.NativeEventController:callNativeEvent(key, kCallParamInt, limit)
	elseif System.getPlatform() == kPlatformWin32 then
		nk.NativeEventController:callNativeEvent(key, nil, nil, NativeEventConfig.NATIVE_FACEBOOK_GETINVITABLEFRIENDS_CALLBACK, testData)
	end
end

-- 分享
function FacebookNativeEvent:shareFeed(params, callback)
    self.m_shareCallback = callback
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_SHAREFEED, kCallParamJsonString, params)
end

-- 获得邀请人数据,给他邀请奖励
function FacebookNativeEvent:getRequestId()
	self.updateInviteRetryTimes_ = 3
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_GETREQUESTID)
end
function FacebookNativeEvent:onHttpProcesser(command, code, content)
    if command == "Invite.inviteAddMoney" then
    	local result = self.requestIdResult or {}
        if code ~= 1 then
	      	if self.updateInviteRetryTimes_ > 0 then
	            self:onGetRequestIdResult(true,result)
	            self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
	        end
        	return
	    end
        nk.AnalyticsManager:report("EC_H_Invite_By_Other")

        -- 调用fb sdk删除requestId
        nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_DELETE_REQUEST, kCallParamString, result.requestId)
    elseif command == "Member.FBBind" then
    	if code == HttpErrorType.SUCCESSED then
    		local fbBindStatus = -5
    		local fbName = ""
	    	if content.code == 1 then --成功
	    		if content.data and content.data.fb_name then
	    			fbName = content.data.fb_name
	    			nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_SUCCESS", fbName))
	    		else
	    			nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_SUCCESS1"))
	    		end
	    		fbBindStatus = 1
	    		self:updateFBBindStatus(fbBindStatus,fbName)
	    	elseif content.code == 0 then -- 禁止FB用户绑定 
	    		nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL1"))
	    	elseif content.code == -1 then -- 已经绑定过了
	    		if content.data and content.data.fb_name then
	    			fbName = content.data.fb_name
	    			nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL4", fbName))
	    		else
	    			nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL2"))
	    		end
	    		fbBindStatus = 1
	    		self:updateFBBindStatus(fbBindStatus,fbName)
	    	elseif content.code == -2 then
	    		nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL3"))
	    	elseif content.code == -3 then
	    		nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL3"))
	    	elseif content.code == -4 then
	    		nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL6"))
	    	end
    	end
    elseif command == "Member.checkFBBind" then
    	if code == HttpErrorType.SUCCESSED then
    		local fbBindStatus = 0
    		local fbName = ""
    		if content.code == 0 then --FB用户
    			fbBindStatus = 0
    		elseif content.code == 1 then --已绑定
    			fbBindStatus = 1
    			if content.data and content.data.fb_name then
    				fbName = content.data.fb_name
    			end
    		elseif content.code == -1 then --未绑定
    			fbBindStatus = -1
    		end
    		self:updateFBBindStatus(fbBindStatus,fbName)
    	end
    end
end

function FacebookNativeEvent:updateFBBindStatus(fbBindStatus,fbName)
	nk.DictModule:setInt("gameData", nk.cookieKeys.GUEST_BIND_FB_STATUS, fbBindStatus)
	nk.DictModule:setString("gameData", nk.cookieKeys.GUEST_BIND_FB_NAME, fbName)
	nk.DictModule:saveDict("gameData")
	local fbBindInfo = {}
	fbBindInfo.fbBindStatus = fbBindStatus
	fbBindInfo.fbName = fbName
    EventDispatcher.getInstance():dispatch(EventConstants.updateFBBindStatus,fbBindInfo)
end

-- 邀请
function FacebookNativeEvent:invite(data, toID, title, message, callback)
	self.m_inviteCallback = callback
	local params = {}
	params.data = data
	params.toID = toID
	params.title = title
	params.message = message
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_INVITE, kCallParamJsonString, params)
end

function FacebookNativeEvent:uploadPhoto(path, caption, callback)
	self.m_uploadPhotoCallback = callback
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_UPLOAD, kCallParamJsonString, {path = path, caption = caption})
end

function FacebookNativeEvent:openPage(facebookId)
	nk.NativeEventController:callNativeEvent(NativeEventConfig.NATIVE_FACEBOOK_OPEN_PAGE, kCallParamString, facebookId)
end

-- 查询游客用户绑定FB账户情况
function FacebookNativeEvent:checkFBBind()
	local params = {}
    params.mid = nk.userData.mid
    nk.HttpController:execute("Member.checkFBBind", {game_param = params})
end

---------------------------------nativeHandle-----------------------------------

-- 登陆返回
function FacebookNativeEvent:onLoginResult(status, data)
	Log.printInfo("facebook", "status", status, "data", data)
	if self.m_loginCallback then
		self.m_loginCallback(status, data)
	end
end

-- 登出返回
function FacebookNativeEvent:onLogoutResult(status, data)
	Log.printInfo("facebook", "status", status, "data", data)
end

-- 获取可邀请好友返回
function FacebookNativeEvent:onGetInvitableFriendsResult(status, data)
	Log.printInfo("facebook", "status", status, "data", data)
	if status then
		if self.m_getInviteFriendCallback then
			self.m_getInviteFriendCallback(status, data)
		end
	else
		if self.m_getInviteFriendCallback then
			self.m_getInviteFriendCallback(false)
		end
	end
end

-- 分享返回
function FacebookNativeEvent:onGetRequestIdResult(status, data)
	Log.printInfo("facebook", "status", status, "data", data)

	if status then
	    -- result = json.decode(data)
		local result = data
	    if result and result.requestData and result.requestId then
	    	--存一下全局，失败的时候可以再用
	    	self.requestIdResult = result

	        if string.find(result.requestData,"oldUserRecall") ~= nil then

	        else
	            local d = {};
	            d.data = result.requestData;
	            d.requestid = result.requestId;

	            nk.HttpController:execute("Invite.inviteAddMoney", {game_param =d})
	        end
	    end
	end
end

-- 分享返回
function FacebookNativeEvent:onShareFeedResult(status, data)
	Log.printInfo("facebook", "status", status, "data", data)
    if self.m_shareCallback then
        self.m_shareCallback(status, data)
    end
end

-- 邀请返回
function FacebookNativeEvent:onInviteResult(status, data)
	Log.printInfo("facebook", "status", status, "data", data)
	if self.m_inviteCallback then
		self.m_inviteCallback(status, data)
	end
end

function FacebookNativeEvent:onUploadPhotoResult(status, data)
	Log.printInfo("facebook", "status", status, "data", data)
	if self.m_uploadPhotoCallback then
		self.m_uploadPhotoCallback(status, data)
	end
end

function FacebookNativeEvent:onFacebookBindingResult(status, data)
	if status and data and data[1] and data[1].token and data[1].name then
		Log.printInfo("onFacebookBindingResult", "status", status)
		Log.printInfo("onFacebookBindingResult", data[1].token)
		Log.printInfo("onFacebookBindingResult", data[1].name)
		local params = {}
	    params.mid = nk.userData.mid
	    params.sitemid = data[1].token
	    params.fb_name  = data[1].name
	    nk.HttpController:execute("Member.FBBind", {game_param = params})
	end
end



FacebookNativeEvent.s_nativeHandle = {
    -- ["***"] = function
    [NativeEventConfig.NATIVE_FACEBOOK_LOGIN_CALLBACK] = FacebookNativeEvent.onLoginResult,
    [NativeEventConfig.NATIVE_FACEBOOK_LOGOUT_CALLBACK] = FacebookNativeEvent.onLogoutResult,
    [NativeEventConfig.NATIVE_FACEBOOK_GETINVITABLEFRIENDS_CALLBACK] = FacebookNativeEvent.onGetInvitableFriendsResult,
    [NativeEventConfig.NATIVE_FACEBOOK_GETREQUESTID_CALLBACK] = FacebookNativeEvent.onGetRequestIdResult,
    [NativeEventConfig.NATIVE_FACEBOOK_SHAREFEED_CALLBACK] = FacebookNativeEvent.onShareFeedResult,
    [NativeEventConfig.NATIVE_FACEBOOK_INVITE_CALLBACK] = FacebookNativeEvent.onInviteResult,
    [NativeEventConfig.NATIVE_FACEBOOK_UPLOAD_CALLBACK] = FacebookNativeEvent.onUploadPhotoResult,
    [NativeEventConfig.NATIVE_FACEBOOK_BINDING_CLLBACK] = FacebookNativeEvent.onFacebookBindingResult,
}

return FacebookNativeEvent