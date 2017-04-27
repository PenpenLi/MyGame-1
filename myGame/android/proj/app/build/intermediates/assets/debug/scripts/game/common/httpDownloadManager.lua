-- httpDownload.lua
-- Create date: 2016-08-05
-- Last modification : 2016-08-05
-- Description: 管理HttpDownload

local HttpDownloadManager = class()
local HttpDownload = require("game.common.httpDownload")

local s_BindArgsCallbackFactory = function(callback, obj, args)
	return function(...)
		callback(obj, args, ...)
	end
end

function HttpDownloadManager.getInstance()
    if not HttpDownloadManager.s_instance then
        HttpDownloadManager.s_instance = new(HttpDownloadManager)
    end
    return HttpDownloadManager.s_instance
end

function HttpDownloadManager:ctor()
	self.m_downloadList = {}
end

function HttpDownloadManager:dtor()

end

function HttpDownloadManager:addTask(args)
	if args and args.url then
		if self.m_downloadList[args.url] then
			table.insert(self.m_downloadList[args.url], args)
			return
		end
		local httpDownloadArgs = clone(args)
		httpDownloadArgs.callback = s_BindArgsCallbackFactory(self.onCallback, self, httpDownloadArgs)
		-- httpDownloadArgs.periodFunc -- didnt override this function, so only the first periodFunc will be called
		local httpDownload = new(HttpDownload, httpDownloadArgs)
		self.m_downloadList[args.url] = {httpDownload, args}
		httpDownload:download()
	end
end

function HttpDownloadManager:onCallback(args, ...)
	if self.m_downloadList[args.url] then
		for i = 2, #self.m_downloadList[args.url] do
			local otherArgs = self.m_downloadList[args.url][i]
			if otherArgs.callback then
				otherArgs.callback(...)
			end
		end
	end
end

function HttpDownloadManager:removeTask(args)
	if args and args.url then
		if not self.m_downloadList[args.url] then
			return
		end
		local httpDownload = self.m_downloadList[args.url][1]
		if httpDownload.m_httpModel then
			httpDownload.m_httpModel.abort()
		end
		delete(httpDownload)
		self.m_downloadList[args.url] = nil
	end
end

return HttpDownloadManager

