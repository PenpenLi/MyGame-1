-- httpProcesser.lua
-- Last modification : 2016-05-10
-- Description: a httpProcesser to finish all http request callback.

local HttpProcesser = class();

function HttpProcesser:ctor(httpModule)

end

function HttpProcesser:dtor()

end

function HttpProcesser:loginCallBack(command,errorCode,data)
    Log.printInfo("HttpProcesser", "loginCallBack")
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:loadCallBack(command,errorCode,data)
    Log.printInfo("HttpProcesser", "loadCallBack")
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:getLoginRewardConfigCallBack(command,errorCode,data)
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:getRoomConfigCallBack(command,errorCode,data)
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:getLevelConfigCallBack(command,errorCode,data)
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:getExpConfigCallBack(command,errorCode,data)
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:getUmengConfigCallBack(command,errorCode,data)
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:getLogoutConfigCallBack(command,errorCode,data)
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:getMemberInfoCallBack(command,errorCode,data)
    Log.printInfo("HttpProcesser", "getMemberInfoCallBack")
end

function HttpProcesser:Http_checkVersionCallBack(command,errorCode,data)
    Log.printInfo("HttpProcesser", "Http_checkVersionCallBack")
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:GetPayTypeConfigCallBack(command, errorCode, data)
    Log.printInfo("HttpProcesser", "GetPayTypeConfigCallBack")
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

--修完人物信息
function HttpProcesser:getEditFinishInfo(command, errorCode, data)
        Log.dump(data,">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getEditFinishInfo")
        if not data or data.code ~= 1 then
            return
        end

        local temp = data.data
        --名字
        if temp.name then
            nk.userData["name"] = temp.name           
        end    
        
        --改性别      
        if temp.msex then
            nk.userData["msex"] = checkint(temp.msex)      
        end      
        --fb主页
        if temp.FBindex then
           nk.userData["FBindex"] = checkint(temp.FBindex)
        end
        

        EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
end

function HttpProcesser:inviteReportCallBack(command, errorCode, data)
    if errorCode == HttpErrorType.SUCCESSED then
        local retData = data.data
        if data.code == 1 and retData then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP"))

            --ºìµãÌáÊ¾
            nk.userData.inviteIsGet = 1
            EventDispatcher.getInstance():dispatch(EventConstants.update_invite_award)
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_FAIL_TIP"))
        end
    end
end

function HttpProcesser:onGetLimitTimeGiftbag(command, errorCode, data)
    if errorCode ==HttpErrorType.SUCCESSED then
        if data and data.code == 1 then
            local data = data.data
            if data then
                if data.ver then
                    nk.DictModule:setString("gameData", "limitTimeVer",data.ver)
                    nk.updateFunctions.cacheTable("LIMIT_TIME_GIFTBAG",data)
                    nk.DictModule:saveDict("gameData")
                else
                    data = nk.updateFunctions.cacheTable("LIMIT_TIME_GIFTBAG")
                end
                EventDispatcher.getInstance():dispatch(EventConstants.getLimitTimeGift,data)
            end
        end
    end
end

function HttpProcesser:usePropsCallBack(command, errorCode, data)
    EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser, command, errorCode, data);
    local PropManager = require("game.store.prop.propManager")
    PropManager.getInstance():requestUserPropListWithEvent()
end

return HttpProcesser


