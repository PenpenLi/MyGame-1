-- urlImage.lua
-- Last modification : 2016-06-08
-- Description: a image for url
-- 用法有两种：
-- 1、直接new(UrlImage, defaultFile, url)
-- 2、UrlImage.spriteSetUrl(sprite, url)

local Serialize = require("game.common.imageCacheSerialize")

UrlImage = class(Image,false)

-- 保存文件补后缀
UrlImage.s_index = 1
-- 下载重试次数
UrlImage.s_maxDownloadTimes = 3
-- 图片缓存记录
UrlImage.s_cacheFileName = "urlImageCaches.lua"
-- 缓存保存时限（天）
UrlImage.s_cacheDuring = 7
UrlImage.s_cacheFiles = new(Serialize, UrlImage.s_cacheFileName, UrlImage.s_cacheDuring)

-- 同时最大下载任务数量
UrlImage.s_downloadNum = 5
-- 正在下载的url任务,对应的多个图片控件
UrlImage.s_downloading = {}
-- 等待下载的url任务
UrlImage.s_downloadWaiting = {}

function UrlImage:ctor(defaultFile,url,fmt,filter)
	super(self,defaultFile,fmt,filter)
	self.m_isDownloading = false
	self.m_downloadTry = 0
	self:beginDownload(url)
end

-- 设置url路径
function UrlImage:setUrl(url)
	self:beginDownload(url)
end

function UrlImage:beginDownload(url)
	self.m_url = url or ""
	if not url or url == "" then 
		return
	end
	
	local temp = string.sub(url, 1,4) 
	if temp and temp ~= "http" then
		self:setFile(url)
		return
	end

	local cacheName = UrlImage.s_cacheFiles:get(self.m_url)
	if cacheName then
		self:setFile(cacheName)
		return
	end

	local downloadName = "" .. os.time() .. UrlImage.s_index .. ".png"
	local fileName = System.getStorageImagePath() .. downloadName	

	-- 判断url是否正在下载
	local isDownloading = UrlImage.saveInfo(url,downloadName,self)

	if not isDownloading then 	
		UrlImage.s_index = UrlImage.s_index + 1
		local params = {
			url = url,
	        savePath = fileName,
	        callback = UrlImage.onDownloaded,
		}
		nk.HttpDownloadManager:addTask(params)
	end 
end

function UrlImage:dtor()
	for k,v in pairs(UrlImage.s_downloading) do 
		if self.m_url == k then 
			for kk,_ in pairs(v.obj) do 
   				v.obj[kk] = nil
			end
		end 
	end 
end

-------------------------------------public function----------------------
-- 设置图片的下载路径，下载完图片后会自动替换
-- @param sprite 图片控件
-- @param url 图片路径 
function UrlImage.spriteSetUrl(sprite, url,callback)
	if not url or url == "" then 
		return
	end
	if sprite and url then
		local cacheName = UrlImage.s_cacheFiles:get(url)
		if cacheName then
			if sprite.m_res and sprite.setFile then
				sprite:setFile(cacheName)
				if type(callback)=="function" then
					callback()
				end
			end
			return
		end
		local downloadName = "" .. os.time() .. UrlImage.s_index .. ".png"
		local fileName = System.getStorageImagePath() .. downloadName

		if not sprite.m_downloadTry then
			sprite.m_downloadTry = 0
		end
		local isDownloading = UrlImage.saveInfo(url, downloadName, sprite,callback)

		if not isDownloading then 	
			UrlImage.s_index = UrlImage.s_index + 1
			local params = {
				url = url,
		        savePath = fileName,
		        callback = UrlImage.onDownloaded,
			}
			-- nk.UpdateHttpFile:downloadFile(params)
            nk.HttpDownloadManager:addTask(params)
		end 
	end
end

-- 保存下载任务
function UrlImage.saveInfo(url, fileName, obj, callback)
	if obj.m_isDownloading then
        Log.printInfo("UrlImage.saveInfo", "url:" .. url )
		-- 删掉正在下载的图片控件，下面重新保存
		for _, v in pairs(UrlImage.s_downloading) do
			if v.obj and #v.obj > 0 then
				for k, vv in pairs(v.obj) do
					if vv == obj then
						v.obj[k] = nil
					end
				end
			end
		end
	end
	obj.m_isDownloading = true
	if UrlImage.s_downloading[url] then 
		-- 多个image控件下载同一个url图片
		local temp = UrlImage.s_downloading[url].obj
		local callbacks = UrlImage.s_downloading[url].callback
		local len = #temp + 1
		temp[len] = obj
		callbacks[len] = callback
		return true
	else
		if table.nums(UrlImage.s_downloading) > UrlImage.s_downloadNum - 1 then
			UrlImage.s_downloadWaiting[url] = {["name"] = fileName, ["obj"] = {obj}, ["callback"] = {callback} }
			return true
		else
			UrlImage.s_downloading[url] = {["name"] = fileName, ["obj"] = {obj} , ["callback"] = {callback} }
			return false
		end
	end
end

-- 下载完回调，根据具体任务处理
function UrlImage.onDownloaded(isSucessed, data)
	local downloadTask = UrlImage.s_downloading[data.url]
	UrlImage.s_downloading[data.url] = nil

	if not isSucessed then
		if downloadTask then 
			local objs = downloadTask.obj
			for k,v in pairs(objs) do
				v.m_isDownloading = false
				if v.m_downloadTry <= UrlImage.s_maxDownloadTimes - 1 then
					v.m_downloadTry = v.m_downloadTry + 1
					UrlImage.spriteSetUrl(v, data.url, downloadTask.callback[k])
				end
			end 
			return
		end
	else
		if downloadTask then 
			local objs = downloadTask.obj	
			local name = downloadTask.name
			local callback = downloadTask.callback
			for k,v in pairs(objs) do
				if not tolua.isnull(v) then 
					v:setFile(name)
					if type(callback[k])=="function" then
						callback[k]()
					end
					v.m_isDownloading = false
				end
			end 		
			UrlImage.s_cacheFiles:set(data.url, name)
			UrlImage.s_cacheFiles:save()
		end

		local url, task = _G.next(UrlImage.s_downloadWaiting)
		if task then
			UrlImage.s_downloadWaiting[url] = nil
			for k, v in ipairs(task.obj) do
				UrlImage.spriteSetUrl(v, url, task.callback[k])
			end
		end
	end	
end

--[[
function UrlImage.spriteSetUrl(sprite, url, callBack)
callBack 
 和 obj 的处理类似，一个url 一个callback

--]]