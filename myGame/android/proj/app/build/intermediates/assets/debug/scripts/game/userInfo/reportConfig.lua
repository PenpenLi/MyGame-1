-- reportConfig.lua  举报配置文件

local ReportConfig = class()

function ReportConfig:ctor()
	self.m_isloaded = false
	self.m_isLoading = false
	self.m_reportConfig = {}
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function ReportConfig:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function ReportConfig:loadReportConfig()
	if not self.m_isloaded and not self.m_isLoading then
		self.m_isLoading = true
		local params = {}
		nk.HttpController:execute("Feedback.getExposeConfig", {game_param = params})
	elseif self.m_isloaded then

	end
end

function ReportConfig:report(personalUid, reportType, reportContent)
	local params = {}
    params.mid = nk.userData.mid
    params.emid = personalUid
    params.type = reportType
    params.desc = reportContent
    nk.HttpController:execute("Feedback.expose", {game_param = params})
end

function ReportConfig:getReportConfig()
	return self.m_reportConfig
end

function ReportConfig:onHttpProcesser(command, errorCode, content)
	if command == "Feedback.getExposeConfig" then
		self.m_isLoading = false
        if errorCode ~= HttpErrorType.SUCCESSED then
            return 
        end

		Log.dump(content, "onHttpProcesserReportConfig")
		if content.code and content.code ~= 1 then
			return
		end

		self.m_reportConfig = content.data

		if self.m_reportConfig.list and not table_is_empty(self.m_reportConfig.list) then
			self.m_isloaded= true
		end
	elseif command == "Feedback.expose" then
		if errorCode == HttpErrorType.SUCCESSED and content and content.code then
			if content.code == 1 then
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "REPORT_TIPS1"))
			elseif content.code == -1 then
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "REPORT_TIPS3"))
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "REPORT_TIPS2"))
			end
		end
	end
end

return ReportConfig
