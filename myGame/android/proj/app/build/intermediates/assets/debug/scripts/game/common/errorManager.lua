--
-- Author: Your Name
-- Date: 2015-08-24 14:29:00
--
local ErrorManager = class()

ErrorManager.Error_Code_Maps = {}
local codes = ErrorManager.Error_Code_Maps

codes.SYSTEM_ERROR              = 0x0100    --系统错误

--坐下错误
codes.CHIPS_LOW_ERROR           = 0x0101 	--携带的金币不足
codes.CHIPS_HIGH_ERROR          = 0x0102 	--携带的金币超过上限
codes.SEAT_FULL        			= 0x0103 	--全部满座了
codes.SEAT_NOT_EMPTY        	= 0x0105 	--座位上已经有人了
codes.BUYIN_OVER_OWN   			= 0x0106   	--携带超过自己金币总数
codes.SEAT_NOT_EXIST   			= 0x0107   	--座位不存在

--登陆房间
codes.LOGIN_ROOM_FAIL           = 0x0104    --登陆失败，服务器维护中
codes.INFO_NOT_COMPLETE         = 0x0108    --信息缺失，请重启游戏                      
codes.ROOM_LOOKERS_FULL         = 0x0109    --围观人数超过房间上限

codes.DOUBLE_LOGIN              = 0x010A    --重复登陆
codes.NOT_ENOUGHT_FOR_TIP       = 0x010B    --打赏金额不足

codes.NOT_ENOUGHT_FOR_ROOM_PROP = 0x010C    --付費道具不足

codes.EXECUTE_GAME_OPERATION_FIRST = 0x010D  --请先进行游戏操作

codes.ERROR_PRI_NOT_FIND_GAMESERVER = 0x0110    --找不到GAMESERVER

--加入私人房
codes.ERROR_ROOM_PASSWORD_ERROR = 0x0111        --密码错误
codes.ERROR_JOIN_SEARCH_ROOM_NOT_EXIST = 0x0112 --房间不存在
codes.ERROR_ROOM_USER_MAX_COUNT = 0x0113        --房间人数已满


function ErrorManager:ctor(topTipsManager)
	self.topTipsManager = topTipsManager
end

function ErrorManager:ShowErrorTips(errorCode,args)
    local msg = self:getErrorTips(errorCode,args)
	if self.topTipsManager then
		self.topTipsManager:showTopTip(msg)
	end
end

function ErrorManager:getErrorTips(errorCode,args)
    print(">>>>>> errorCode ==> %x", errorCode)

    local flag = false

    local msg = T("服务器繁忙,请稍后再试[%s]", string.format("%#x",errorCode))
    
    if errorCode == codes.SYSTEM_ERROR then
        msg = T("系统错误")
        flag = true
    elseif errorCode == codes.CHIPS_LOW_ERROR then
        msg = T("金币不足")
    elseif errorCode == codes.CHIPS_HIGH_ERROR then
        msg = T("金币超过上限")
    elseif errorCode == codes.SEAT_FULL then
        msg = T("没有空座位")
    elseif errorCode == codes.SEAT_NOT_EMPTY then
        msg = T("该位置有人")
    elseif errorCode == codes.BUYIN_OVER_OWN then
        msg = T("携带超过自己的金币总数")
    elseif errorCode == codes.SEAT_NOT_EXIST then
        msg = T("该位置不存在")
    elseif errorCode == codes.LOGIN_ROOM_FAIL then
        msg = T("登陆失败，服务器维护中")
    elseif errorCode == codes.INFO_NOT_COMPLETE then
        msg = T("信息缺失，请重启游戏")
    elseif errorCode == codes.ROOM_LOOKERS_FULL then
        msg = T("围观人数超过房间上限")

    elseif errorCode == codes.NOT_ENOUGHT_FOR_TIP then
        msg = bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR")

    elseif errorCode == codes.NOT_ENOUGHT_FOR_ROOM_PROP then
        msg = T("金币不足，无法发送该表情")
        if args ~= nil and args == 2 then
            msg = T("金币不足，无法发送互动道具")
        end

    elseif errorCode == codes.EXECUTE_GAME_OPERATION_FIRST then
        msg = T("请先进行游戏操作")
    elseif errorCode == codes.ERROR_ROOM_PASSWORD_ERROR then
        msg = T("密码错误")
    elseif errorCode == codes.ERROR_JOIN_SEARCH_ROOM_NOT_EXIST then
        msg = T("房间不存在,请稍后再试")
    elseif errorCode == codes.ERROR_ROOM_USER_MAX_COUNT then
        msg = T("房间人数已满")
    end

    if flag then
        EventDispatcher.getInstance():dispatch(EventConstants.socketError)
        nk.AnalyticsManager:report("New_Test_System_Error", "Room")
    end

    return msg
end

return ErrorManager