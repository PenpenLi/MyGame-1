-- httpDownload.lua
-- Create date: 2016-08-05
-- Last modification : 2016-08-05
-- Description: a utils to download file by http2.(include *.image , *.zip , *.patch, or others)
--http://engine.by.com:8000/doc/api/network.http2.html

local HttpDownload = class()
local MD5 = require("core/md5")

HttpDownload.id = 1

HttpDownload.timeout = 10

HttpDownload.connecttimeout = 20

--[[@param table args = {
        url:              下载URL
        savePath:         保存文件完整路径
        callback:         回调函数 (status, params) 返回状态boolean和原始params
        periodFunc:       进度回调函数(period, size, hasRead) 百分比，总大小K，已下载大小K
        needPause:        WIFI切换是否需要暂停
        tryTimes:        下载失败尝试次数
        md5:              md5校验码
    }
]]

function HttpDownload:ctor(args)
	self.m_callback = args.callback
	self.m_periodFunc = args.periodFunc
	self.m_url = args.url
	self.m_savePath = args.savePath
	self.m_savePathTemp = args.savePath .. ".temp"
	self.m_progress_var = MVar.create()
	self.m_tryTimes = args.tryTimes or 0
	self.m_md5 = args.md5
	self.m_needPause = args.needPause
	self.m_args = args
end

function HttpDownload:dtor()

end

function HttpDownload:getId()
	HttpDownload.id = HttpDownload.id + 1
	return HttpDownload.id
end

function HttpDownload:download()
	self:beforeDownload()
end

function HttpDownload:beforeDownload()
    Log.printInfo("HttpDownload",self.m_savePath)
	if os.isexist(self.m_savePath) == false then
		local fileSize = System.getFileSize(self.m_savePathTemp)
		if fileSize == -1 then
			self:startDownload(nil, 'wb')
			return
		end
		local headers = {"Range: bytes=" .. fileSize .. "-"}
		self:startDownload(headers, 'ab')
	else        
		self.m_callback(true, self.m_args, "exists")
        nk.HttpDownloadManager:removeTask(self.m_args)
	end
end

function HttpDownload:startDownload(headers, mode)
	local Http2 = require('network.http2')
    self.m_httpModel = Http2.request_async({
        url = self.m_url,
        timeout = HttpDownload.timeout,
        connecttimeout = HttpDownload.connecttimeout,
        writer = {
        type = 'file',
        filename = self.m_savePathTemp,
        mode = mode,
        headers = headers, 
      },
      progress_var = self.m_progress_var.id,
    }, function(rsp)
      if rsp.errmsg then
      	Log.printInfo('HttpDownload', "【url】:" .. self.m_url .. " fail")
        print_string('failed', rsp.errmsg)
        if self.m_tryTimes and self.m_tryTimes > 1 then
            self.m_tryTimes = self.m_tryTimes - 1
            self:download()
            return
        end
        System.removeFile(self.m_savePathTemp) -- clean the temp file
        if self.m_callback then
        	self.m_callback(false, self.m_args)
        end
      else
      	Log.printInfo('HttpDownload', "【url】:" .. self.m_url .. " 【savePath】:" .. self.m_savePath .. " success")
        print_string('success', rsp.code, rsp.content)
        if rsp.code >= 200 and rsp.code < 400 then
            System.copyFile(self.m_savePathTemp, self.m_savePath)
            System.removeFile(self.m_savePathTemp)
            if self.m_md5 then
                if MD5.md5File(self.m_savePath) == self.m_md5 then
                    Log.printInfo('HttpDownload', "【url】:" .. self.m_url .. " 【savePath】:" .. self.m_savePath .. " md5 success")
                    if self.m_callback then
                    	self.m_callback(true, self.m_args, "downLoad")
                    end
                else
                    self.m_callback(false, self.m_args, "md5 fail")
                end
            else 
                if self.m_callback then
                    self.m_callback(true, self.m_args, "downLoad")
                end
            end
        else
            System.removeFile(self.m_savePathTemp)
            if self.m_callback then
                self.m_callback(false, self.m_args)
            end
        end
        nk.HttpDownloadManager:removeTask(self.m_args)
      end
    end)
    Clock.instance():schedule(function()
        local value = self.m_progress_var:take(false)
        if value then
            local total_download, current_download, total_upload, current_upload = unpack(cjson.decode(value))
            print('download progress:', current_download / total_download)
            if self.m_periodFunc then
                self.m_periodFunc(current_download / total_download, total_download, current_download)
            end
        end
        if self.m_progress_var.closed then
            return true
        end
    end)
end

return HttpDownload
