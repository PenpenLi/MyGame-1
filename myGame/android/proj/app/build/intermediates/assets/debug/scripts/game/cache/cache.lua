-- cache.lua
-- Last modification : 2016-05-10
-- Description: a cache to cache file.

local Cache = class()

Cache.dir = "cacheFile/"

-- -- Get Cache Instance
-- function Cache.getInstance()
--     if not Cache.s_instance then
--         if os.isexist(System.getStorageDictPath() .. Cache.dir) == false then
--             os.mkdir(System.getStorageDictPath() .. Cache.dir)
--         end
--         Cache.s_instance = new(Cache);
--     end
--     return Cache.s_instance;
-- end

-- -- Release Cache Instance
-- function Cache.releaseInstance()
--     delete(Cache.s_instance);
--     Cache.s_instance = nil;
-- end

function Cache:ctor()
    if os.isexist(System.getStorageDictPath() .. Cache.dir) == false then
        os.mkdir(System.getStorageDictPath() .. Cache.dir)
    end
end

function Cache:dtor()
    -- if self.m_url then
        -- nk.HttpController:cancleRequest(self.m_url)
    -- end
    self.m_url = nil
end

--[[--

根据URL缓存文件

@param string url 请求的url路径

@param function callback 回调函数，使用handler

@param string dictName dict文件名

@return boolean 是否成功
        data 一般是table
        string 加载类型（网络下载还是本地缓存）
]]
function Cache:cacheFile(url, callback, dictName, dictKey)
    self.m_url = url
    self.m_callback = callback
    self.m_md5 = md5_string(url)
    if not self.m_md5 then return end
    self.m_savePath = System.getStorageDictPath() .. Cache.dir .. self.m_md5

    -- http2下载
    local params = {
            url = self.m_url,
            savePath = self.m_savePath,
            callback = handler(self, self.downFileCallBack),
        }
    nk.HttpDownloadManager:addTask(params)
end

function Cache:downFileCallBack(status, data, dataType)
    if status then
        -- isSucessed = true
        if self.m_callback then
            info = io.readfile(data.savePath)
            local newData = json.decode(info)
            if type(newData) == "table" then
                self.m_callback(true, newData, dataType or "downLoad")
            else
                if dataType == "exists" then --数据需要重新下载
                    Clock.instance():schedule_once(function() -- 滞后一帧
                        System.removeFile(self.m_savePath)
                        self:cacheFile(self.m_url, self.m_callback)
                    end)
                else
                    self.m_callback(false) -- 下载下来的数据有问题
                end
            end
        end
    else
        if self.m_callback then
            self.m_callback(false)
        end
    end
end

return Cache

