--
-- Author: HrnryChen
-- Date: 2015-11-26 16:06:20
--
--友盟统计上报管理
local AnalyticsManager = class()

function AnalyticsManager:ctor()

end

--增加了友盟开关
--type上报类型，在nk.userData.STATSWITCH_JSON中定义
--newer 新手30次点击
--ADLogout 退出弹窗
--hallBegin 大厅灰屏快速开始指引
--invite 邀请相关
--privateRoom 私人房相关
--monthfirstpay 首冲相关
--singleRoom 单机相关
function AnalyticsManager:report(id,type)
	-- dump(nk.userData.switchData, "AnalyticsManager switchData")
	if not nk.userData then
		return
	end
	if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
--		if nk.userData.switchData and (nk.userData.switchData[type] == 0 or nk.userData.switchData[type] == nil) then
--			return
--		end
--		if nk.userData.switchData and nk.userData.switchData[type] == "newer" then
--			if nk.DictModule:getInt(nk.cookieKeys.NEWER_SIGN, 0) > 30 then
--				return
--			else
--				local num = nk.DictModule:getInt(nk.cookieKeys.NEWER_SIGN, 0)
--				nk.DictModule:setInt(nk.cookieKeys.NEWER_SIGN, num + 1)
--				nk.DictModule:saveDict()
--			end
--		end
        nk.UmengNativeEvent:onEventCount(id)
    end
end

function AnalyticsManager:reportValue(id,args,value)
	if System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then
        nk.UmengNativeEvent:onEventCountValue(id, args, value)
    end
end

return AnalyticsManager