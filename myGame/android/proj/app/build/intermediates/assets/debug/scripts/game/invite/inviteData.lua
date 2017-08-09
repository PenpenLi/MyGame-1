-- inviteData.lua
-- Last modification : 2016-06-30
-- Description: a data in Invite moudle

local InviteData = class(GameBaseData);

function InviteData:ctor(controller)
	Log.printInfo("InviteData.ctor");
end

function InviteData:dtor()
	Log.printInfo("InviteData.dtor");
end

-- 好友列表数据
function InviteData:setInviteFriendList(data)
	if data then
		for i, v in pairs(data) do
			v.chips =  nk.userData.inviteSendChips
		end
	end
	self.m_inviteList = data
end

function InviteData:getInviteFriendList(data)
	return self.m_inviteList
end

----------------------------http-------------------------

function InviteData:onGetRecommendInviteListBack(errorCode,data)
	Log.printInfo("InviteData.onGetRecommendInviteListBack");
	Log.dump(data);
    self:requestCtrlCmd("getRecommendInviteListBack", errorCode, data)
end

function InviteData:onSearchInviteByIdBack(errorCode,data)
	Log.printInfo("InviteData.onSearchInviteByIdBack");
	Log.dump(data);
    self:requestCtrlCmd("searchInviteByIdBack", errorCode, data)
end

-- Event to register and unregister
InviteData.s_eventHandle = {
    -- [Event ] = function
    [EventConstants.httpProcesser] = InviteData.onHttpPorcesser,
};

InviteData.s_httpRequestsCallBack = {
	-- ["Http.load"] = InviteData.loadCallBack,
	["getRecommendInviteList"] = InviteData.onGetRecommendInviteListBack,
	["searchInviteById"] = InviteData.onSearchInviteByIdBack,
}

-- Provide handle to call
InviteData.s_cmdConfig = 
{
	--["***"] = function
};

return InviteData