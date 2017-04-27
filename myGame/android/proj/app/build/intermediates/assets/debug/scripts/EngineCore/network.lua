
package.preload[ "network/http" ] = function( ... )
if curl ~= nil then
    return require('network.http_compat')
else
    return require('network.http_old')
end

end
        

package.preload[ "network.http" ] = function( ... )
    return require('network/http')
end
            

package.preload[ "network/http2" ] = function( ... )
require("core.object");
require("core.system");
require("core.constants");
require("core.global");

---
-- 新http库
-- @module network.http2
-- @usage local Http = require('network.http2')
local M = class();
local _pool
local function pool()
    if not _pool then
        _pool = ThreadPool(1, 10)
    end
    return _pool
end

local function http_worker(args)
    local function buffer_writer()
        local result
        return {
            open = function()
                result = {}
            end,
            write = function(buf)
                table.insert(result, buf)
            end,
            close = function()
                local s = table.concat(result)
                result = nil
                return s
            end,
        }
    end

    local function file_writer(filename,mode)
        local fp
        return {
            open = function()
                mode = mode or "wb"
                fp = io.open(filename, mode)
            end,
            write = function(buf)
                fp:write(buf)
            end,
            close = function()
                fp:close()
                fp = nil
            end,
        }
    end

    local function chan_writer(chan_id)
        local ch
        return {
            open = function()
                ch = Chan.get_by_id(chan_id)
            end,
            write = function(buf)
                ch:put(buf)
            end,
            close = function()
                ch:close()
                ch = nil
            end,
        }
    end

    local function urlencode(easy, args)
        if type(args) == 'table' then
            local buf = {}
            for k, v in pairs(args) do
                table.insert(buf, string.format('%s=%s', easy:escape(k), easy:escape(v)))
            end
            return table.concat(buf, '&')
        else
            return easy:escape(tostring(args))
        end
    end

    args = cjson.decode(args)
    local writer
    if args.writer ~= nil then
        if args.writer.type == 'file' then
            writer = file_writer(args.writer.filename, args.writer.mode)
        elseif args.writer.type == 'chan' then
            writer = chan_writer(args.writer.chan_id)
        else
            error('invalid writer argument')
        end
    else
        writer = buffer_writer()
    end
    local abort_var = MVar.get_by_id(args._abort_var_id)

    local easy = curl.easy()



    -- 设置自动跳转
    easy:setopt(curl.OPT_FOLLOWLOCATION,1)
    -- 设置最大跳转次数
    easy:setopt(curl.OPT_MAXREDIRS,10)
    local url = args.url
    if args.query then
        if not string.find(url, '?') then
            url = url .. '?'
        end
        url = url .. urlencode(easy, args.query)
    end
    if args.useragent then
        easy:setopt(curl.OPT_USERAGENT, args.useragent)
    end

    easy:setopt(curl.OPT_NOSIGNAL, 1)
    easy:setopt(curl.OPT_SSL_VERIFYPEER, 0)
    easy:setopt(curl.OPT_SSL_VERIFYHOST, 0)
    if args.connecttimeout then
        easy:setopt_connecttimeout(args.connecttimeout)
    end

    if args.timeout then
        easy:setopt_timeout(args.timeout)
    end

    easy:setopt_url(url)
        :setopt_writefunction(function(buf)
            if abort_var:take(false) then
                return false
            end
            writer.write(buf)
        end)
    local progress_var
    if args.progress_var then
        progress_var = MVar.get_by_id(args.progress_var)
        easy:setopt(curl.OPT_NOPROGRESS, 0)
        easy:setopt_progressfunction(function(total_download, current_download, total_upload, current_upload)
            if abort_var:take(false) then
                return false
            end
            progress_var:modify(cjson.encode{
                total_download, current_download, total_upload, current_upload
            })
        end)
    end
    if args.headers and #args.headers > 0 then
        easy:setopt_httpheader(args.headers)
    end
    local form 
    if args.post ~= nil then
        if type(args.post) == "string" then
            easy:setopt_postfields(args.post)
        else
            form = curl.form()
            for i,v in ipairs(args.post) do
                if type(v) == "table" then
                    if v.type == "file" then
                        form:add_file(v.name or "",
                        v.filepath or "",
                        v.file_type or "text/plain",
                        v.filename,
                        v.headers)
                    elseif v.type == "content" then
                        form:add_content(v.name or "",v.contents or "",
                                v.content_type or nil,v.headers)
                    elseif v.type == "buffer" then
                        form:add_buffer(v.name or "",v.filename ,
                                v.content or "",
                                v.buffer_type ,v.headers)
                    end
                end
            end
            easy:setopt_httppost(form)
        end
    end

    writer.open()
    local ok, msg = pcall(function()
        easy:perform()
    end)
    if progress_var then
        progress_var:close()
    end
    local result = writer.close()
    if ok then
        local rsp = {
            code = easy:getinfo(curl.INFO_RESPONSE_CODE),
            content = result,
            tags = args.tags
        }
        easy:close()
        if form then
            form:free()
        end
        return cjson.encode(rsp)
    else
        easy:close()
        if form then
            form:free()
        end
        return cjson.encode{
            errmsg = msg,
        }
    end
end

---
-- 发起http请求，异步接口，通过回调函数获取结果。
-- @function [parent=#network.http2] request_async
-- @param #table args 参数
-- @param #function callback 接受rsp的回调, 成功时rsp为``{code=#number, content=#string}``，失败时rsp为``{errmsg=#string}``
-- @return #table 该返回table现只有一个字段 'abort' 为function类型，可以用于取消一个http连接。
-- 
--
--
-- #args有以下可选字段。
--
-- args.url 
-----------------
-- 
-- 类型: #string
--
-- 请求需要的url地址。 此参数必须有。
--
-- args.query 
-----------------
-- 
-- 类型: #string 或 #table
-- 
-- 可选参数。<br>
-- HTTP 查询字符串 (HTTP query string) 是由问号 (?) 之后的值规定的。
-- 例如:http://www.w3school.com.cn/test/names.asp?a=John&b=Susan
-- 其中a=John&b=Susan就是查询字符串，你可以用 query = 'a=John&b=Susan' 方式来传递，
-- 也可以用table的格式来传递，例如:query = {a='John',b='Susan'} 的方式来传递。
--
--
-- args.useragent 
-----------------
-- 
-- 类型: #string 
-- 
-- 可选参数。<br>
-- userAgent 属性是一个只读的字符串，是一个特殊字符串头，被广泛用来标示浏览器客户端的信息，使得服务器能识别客户机使用的操作系统和版本，CPU类型，浏览器及版本，浏览器的渲染引擎，浏览器语言等。
-- 例如：useragent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322)'。
-- 
--
-- args.headers 
-----------------
-- 
-- 类型: #table 
-- 
-- 可选参数。<br>
-- headers 包含了客户端环境与请求实体的一些有用的信息。你可以在此处填写你想要的请求头信息，例如'Content-Type','Accept-Charset'等。
--
-- 使用的方式为每一个请求头信息都是一个字符串 'Content-Type:application/json',你可以在table中添加多个请求信息.
--
-- <pre> 
-- <p>headers = 
--     {'Content-Type:application/json',
--      'Accept:application/json',
--      'charset:utf-8'
--      }
-- </p>
-- </pre> 
--
--
--
--
--
--
-- args.timeout 
-----------------
-- 
-- 类型: #number 
-- 
-- 可选参数。<br>
-- timeout表示此次连接的总超时时间，单位s。例如:timeout = 20。
-- 
--
-- args.connecttimeout 
-----------------
-- 
-- 类型: #number 
-- 
-- 可选参数。<br>
-- connecttimeout表示此次连接请求的超时时间，单位s。例如:connecttimeout = 10。
--
--
-- args.post 
-----------------
-- 
-- 类型: #string 
-- 
-- 可选参数。<br>
-- 你可以将一个http post请求完整的数据通过给定的string进行发送，需要用户来保证此数据是服务器端希望接受的格式。此时的默认的'Content-Type' 为'application/x-www-form-urlencoded',
-- 如果你需要传递不同的类型，那么你需要在headers中去显示的表示。例如传递json，你需要显示的指定'Content-Type' 为'application/json'。
-- 
-- <pre> 
-- <p>headers = {
--             'Content-Type:application/json',
--             'Accept:application/json',
--             'charset:utf-8'
--         },
--   post = cjson.encode({a=1,b=2}),
-- </p>
-- </pre> 
-- 
--
-- args.post 
-----------------
-- 
-- 类型: #table 
-- 
-- 可选参数。<br>
-- 如果你需要multipart/formdata HTTP POST 的方式进行请求，那么你可以用table的方式进行传参。
-- 
-- post的每一个元素都是一个table,每一个table表示一个服务器希望接受的类似 ‘name=value’的键值对。有三种不同的键值对的传递方式.
--
-- <pre> 
-- <p>
--  {
--      type = "file",            -- post 发送的数据类型 有'file' (表示文件)，'content'(表示变量)，'buffer' (表示二进制流)。
--      name = "file",             -- 后台对应接受此数据的变量名称
--      filepath = "./sprite.png",  -- 需要上传的文件全路径
--      file_type = "image/png",   -- 上传的文件类型
--   -- filename = "xxx.png",      -- 服务器上存储的名字，可不填，则采用服务器的默认策略
--  },
-- </p>
-- </pre> 
--
-- <pre> 
-- <p>
--  {
--      type = "content",      -- post 发送的变量
--      name = "name",             -- 服务器接受此内容的变量名称
--      contents = "upload",   -- 发送的内容
--      content_type = ""       -- 发送的类型,按照服务器端的要求来填写
--  },
-- </p>
-- </pre> 
-- <pre> 
-- <p>
--  {
--      type = "buffer",      -- post 发送的二进制流
--      name = "name",         -- 服务器接受此内容的变量名称
--      filename = "1321321321",   -- 发送的内容
--      buffer_type = ""       -- 发送类型,按照服务器端的要求来填写
--  },
-- </p>
-- </pre> 
--
-- args.writer  
-----------------
-- 
-- 类型: #table 
-- 
-- 可选参数。<br>
-- 如果需要http下载的功能，那么你需要要有此字段。如果没有，将在请求完成后的content中以字符串的方式返回。<br>
-- 有两种不同的下载方式:写入到文件和写入到管道。
-- 
-- <pre> 
-- <p>
--  writer = {                    
--          type = 'file',              -- 以文件的形式保存, rsp.content would be empty.
--          filename = './log.txt',     -- 文件本地保存的路径
--          mode = 'wb',                -- 文件写入的模式
--       },
-- </p>
-- </pre> 
-- <pre> 
-- <p>
--   writer = {                     -- optional, override writer behaviour.
--      type = 'chan',              -- 以chan来保存流, rsp.content would be empty.
--      chan_id = chan.id,          -- 保存二进制流的chan的id。
--   },
-- </p>
-- </pre> 
--
--
-- args.progress_var 
-----------------
-- 
-- 类型: #number 
-- 
-- 可选参数。<br>
-- 通过传入一个Mvar的id，你可以通过此id得到当前的下载进度。
--
--
-- @usage
-- --取消一个http连接
-- Http = require('network.http2')
-- local event = Http.request_async({
--         url = 'http://127.0.0.1:8000/log.txt',  -- required
--     }, function(rsp) end)
--  event.abort()    -- 取消一个连接
--
--
--
--
-- @usage 
-- -- 下载文件并读取下载进度
-- local var = MVar.create()
--     Http = require('network.http2')
--     Http.request_async({
--         url = 'http://127.0.0.1:8000/log.txt',  -- required
--         timeout = 10,                    -- optional, seconds
--         connecttimeout = 20,             -- optional, seconds
--         writer = {                     -- optional, override writer behaviour.
--          type = 'file',              -- save to file, rsp.content would be empty.
--          filename = './log.txt',
--          mode = 'wb',
--       },
--       progress_var = var.id,         -- optional, id of mvar used to receive progress infomation.
--     }, function(rsp)
--       if rsp.errmsg then
--         print_string('failed', rsp.errmsg)
--       else
--         print_string('success', rsp.code, rsp.content)
--       end
--     end)
--     Clock.instance():schedule(function()
--         -- query without blocking.
--         local value = var:take(false)
--         if value then
--             local total_download, current_download, total_upload, current_upload = unpack(cjson.decode(value))
--             print('download progress:', current_download / total_download)
--         end
--         if var.closed then
--             -- stop when MVar is closed.
--             return true
--         end
--     end)
--
--
-- @usage
-- -- 表单上传文件
-- local var = MVar.create()
--   Http = require('network.http2')
--   Http.request_async({
--       url = 'http://127.0.0.1:8000',  -- required
--       headers = {
--           'referer:hello'             -- 需要填写的header
--       },
--       post = {                       -- optional, set upload data
--           {
--               type = "file",            -- post 发送的数据类型 有'file' (表示文件)，'content'(表示变量)，'buffer' (表示二进制流)。
--               name = "file",             -- 后台对应接受此数据的变量名称
--               filepath = "./sprite.png",  -- 需要上传的文件全路径
--               file_type = "image/png",   -- 上传的文件类型
--            -- filename = "xxx.png",      -- 服务器上存储的名字，可不填，则采用服务器的默认策略
--           },
--           {
--               type = "content",      -- post 发送的变量
--               name = "name",             -- 服务器接受此内容的变量名称
--               contents = "upload",   -- 发送的内容
--               content_type = ""       -- 发送的类型
--           },
--       }
--   }, function(rsp)
--     if rsp.errmsg then
--       print_string('failed', rsp.errmsg)
--     else
--       print_string('success', rsp.code, rsp.content)
--     end
--   end)
-- @usage
-- -- 普通的post请求
--   Http = require('network.http2')
--   Http.request_async({
--       url = 'http://127.0.0.1:8000',  -- required
--       headers = {
--           'referer:hello'             -- 需要填写的header
--       },
--       post = "a=1"
--   }, function(rsp)
--     if rsp.errmsg then
--       print_string('failed', rsp.errmsg)
--     else
--       print_string('success', rsp.code, rsp.content)
--     end
--   end)
-- @usage
-- -- 更多参数
-- Http = require('network.http2')
-- Http.request_async({
--   url = 'http://www.boyaa.com',  -- required
--   query = {                      -- optional, query_string
--      a = 1,
--   },
--   useragent = '',                -- optional
--   headers = {                    -- optional, http headers,
--      'XX-Header: xxx',
--   },
--   timeout = ,                    -- optional, seconds
--   connecttimeout = ,             -- optional, seconds
--   post = 'a=1&b=2',              -- optional, set post data, and change http method to post.
--   post = {                       -- optional, set upload data
--     {
--         type = "file",
--         name = "file",
--         filepath = "./blurWidget_before.png",
--         file_type = "image/png",
--         -- filename = "xxx.png",
--     },
--     {
--         type = "file",
--         name = "file",
--         filepath = "./log.txt",
--     },
--     {
--         type = "content",
--         name = "",
--         contents = "upload",
--         content_type = ""
--     },
--     {
--         type = "buffer",
--         name = "",
--         filename = "log.txt",
--         contents = "1321313213132",
--         buffer_type = "text/plain"
--     },
--   },
--   writer = {                     -- optional, override writer behaviour.
--      type = 'file',              -- save to file, rsp.content would be empty.
--      filename = '/path/to/file',
--      mode = 'wb',
--   },
--   writer = {                     -- optional, override writer behaviour.
--      type = 'chan',              -- send response content stream through Chan, rsp.content would be empty.
--      chan_id = chan.id,
--   },
--   progress_var = var.id,         -- optional, id of mvar used to receive progress infomation.
-- }, function(rsp)
--   if rsp.errmsg then
--     print_string('failed', rsp.errmsg)
--   else
--     print_string('success', rsp.code, rsp.content)
--   end
-- end)
--
function M.request_async(args, callback)
    local abort_var = MVar.create()
    args._abort_var_id = abort_var.id
    pool():lua_task(http_worker, function(rsp)
        callback(cjson.decode(rsp))
    end, cjson.encode(args))
    return {
        abort = function()
            abort_var:put('abort', false)
        end,
    }
end

---
-- http同步请求，在``tasklet``中执行，详细的参数描述见``request_async``。
-- @function [parent=#network.http2] request
-- @param #table args
-- @return #table rsp 成功时rsp为``{code=#number, content=#string}``，失败时rsp为``{errmsg=#string}``
-- @usage
-- local rsp = Http.request({
--     url = 'http://www.boyaa.com'
-- })
-- if rsp.errmsg then
--     print('request failed', rsp.errmsg)
-- else
--     print('response', rsp.code, rsp.content)
-- end
function M.request(args)
    return coroutine.yield(function(callback)
        M.request_async(args, callback)
    end)
end






return M

end
        

package.preload[ "network.http2" ] = function( ... )
    return require('network/http2')
end
            

package.preload[ "network/http_compat" ] = function( ... )
-- http.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for http functions

--------------------------------------------------------------------------------
-- 用于简单的http请求。
-- **规范请参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)。**
-- @module network.http
-- @return #nil
-- @usage require("network.http")


require("core.object");
require("core.system");
require("core.constants");
require("core.global");
local Http2 = require('network.http2')

--- http请求类型：get
kHttpGet    = 0;
--- http请求类型：post
kHttpPost   = 1;
--- http返回类型(这是唯一可用的类型)
kHttpReserved = 0;

---
--@type Http
Http = class();
Http.s_platform = System.getPlatform();

---
-- 构造方法.
-- 
-- @param self
-- @param #number requestType http请求类型（未使用）。 取值[```kHttpGet```](network.http.html#kHttpGet)、
-- [```kHttpPost```](network.http.html#kHttpPost)。Android、win32平台目前只支持post方式，win10、ios平台均支持Get和Post两种方式。
-- @param #number responseType （未使用）。目前仅能取值[```kHttpReserved```](network.http.html#kHttpReserved)。
-- @param #string url 请求的url。
Http.ctor = function(self, requestType, responseType, url)
    self.m_url = url
    self.m_headers = {}
    self.m_requestType = requestType
    self.m_data = ''
    self.m_eventCallback = {}
end


---  
-- 析构方法.
-- 
-- @param self
Http.dtor = function(self)
    if self.m_response == nil then
        -- not finished, abort
        self:abortRequest()
    end
end


---
-- 设置请求超时时间.  
-- 若多次设置，则取最后一次的值。在@{#Http.execute}前设置才有效 。
-- 
-- @param self
-- @param #number connectTimeout 请求超时时间，单位毫秒。  
-- Android平台：若设置小于1000，则默认为1000；  
-- win32、ios平台：超时时间参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)；  
-- win10平台：默认为10000。
-- @param #number timeout Android、win32、win10平台未使用；ios平台表示[请求过程的最长耗时](https://curl.haxx.se/libcurl/c/CURLOPT_TIMEOUT.html)。
Http.setTimeout = function(self, connectTimeout, timeout)
    self.m_connecttimeout = connectTimeout
    self.m_timeout = timeout
end

---
-- 设置请求消息的User-Agent.
-- 
-- 在@{#Http.execute}前设置才有效。
-- Android未实现；    
-- win32平台：若未调用@{#Http.setAgent}，将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`；  
-- win10平台：已实现，无默认值。  
-- ios平台:若未调用@{#Http.setAgent},将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`。
-- @param self
-- @param #string str 请求消息的userAgent。
Http.setAgent = function(self, str)
    self.m_userAgent = str
end

---
-- 请求消息添加Header.
--   
-- Android平台未实现；  
-- win32平台:首个header为“Accept-Encoding:UTF-8”；用户多次调用@{#Http.addHeader}之后,win32平台上将依次添加header到请求消息中；  
-- win10：用户调用@{#Http.addHeader}之后,平台添加header到请求消息中。每个请求添加多次header时，取最后一次的header；  
-- ios平台：用户多次调用@{#Http.addHeader}之后,平台依次添加header到请求消息中。
-- @param self
-- @param #string str 请求消息的Header。
Http.addHeader = function(self, str)
    table.insert(self.m_headers, str)
end


---
-- 设置请求消息的body.  
-- 
-- 仅支持post请求。
-- Android、win32、win10、ios平台均已实现:请求的消息body默认为空；调用@{#Http.setData}后，更新请求消息的body。
--
-- @param self
-- @param #string str 请求消息的body。
Http.setData = function(self, str)
    self.m_data = str
end

---
-- 发送请求.
--   
-- Android、win32、ios平台请求完成后首先回调[```event_http_response_httpEvent```](network.http.html#event_http_response_httpEvent)方法，然后回调@{#Http.setEvent}方法；  
-- win10平台请求完成后，回调@{#Http.setEvent}方法。
-- 
-- @param self
Http.execute = function(self)
    self.m_req = Http2.request_async({
        url = self.m_url,
        headers = self.m_headers,
        post = self.m_requestType == kHttpPost and self.m_data or nil,
        connecttimeout = self.m_connecttimeout,
        timeout = self.m_timeout,
        useragent = self.m_userAgent,
    }, function(rsp)
        self.m_response = rsp
        if self.m_aborted then
            return
        end
        if not rsp.errmsg and self.m_eventCallback.func then
            self.m_eventCallback.func(self.m_eventCallback.obj, self)
        end
    end)
end

---
-- 取消请求，在@{#Http.execute}之后执行有效.
-- 注：此方法并没有真正取消请求，而是改变了一个变量的值供各平台调度，以达到真正意义上取消请求的目的。
-- 
-- Android、win32平台未实现；    
-- win10、ios平台已实现:调用各自平台的取消方法来达到取消请求的目的。
--
-- @param self
Http.abortRequest = function(self)
    self.m_aborted = true
    if self.m_req then
        self.m_req:abort()
    end
end

---
-- 请求是否被取消.
-- 
-- Android、win32平台未实现；  
-- win10、ios平台已实现：若已调用过@{#Http.abortRequest}，且平台成功取消请求，则返回true；否则，返回false。
--
-- @param self
-- @return #boolean 若成功取消请求，则返回true；否则，返回false。
Http.isAbort = function(self)
    return self.m_aborted == true
end

---
-- 获得响应的状态码.
-- 
-- Android、win32、win10、ios平台：已实现。返回HTTP状态代码。
--  
-- @param self
-- @return #number 如果请求未完成，返回0；若请求完成，则返回相应的状态码。
Http.getResponseCode = function(self)
    return self.m_response and self.m_response.code or 0
end

---
-- 获得响应的内容.
-- 
-- Android、win32、win10平台:返回全部相应内容。
-- ios平台：返回响应内容（不一定是全部内容）。
--
-- @param self
-- @return #string 响应结果。如果请求未完成，则返回空字符串；否则返回响应结果。
Http.getResponse = function(self)
    return self.m_response and self.m_response.content or ''
end

---
-- 获得错误码.
-- 
-- Android、win32、ios平台，若出现异常返回1；否则返回0。  
-- win10平台：当请求不存在或在请求过程中获取错误码返回-1；未发送请求而去获取错误码，返回0；其他情况返回错误码的整数值。参考[win10平台错误码类型](https://curl.haxx.se/libcurl/c/libcurl-errors.html)。
-- 
-- @param self
-- @return #number 返回错误码。
Http.getError = function(self)
    return self.m_response and self.m_response.errmsg or 0
end

---
-- 设置请求完成后的回调函数.
-- 
-- @param self
-- @param obj 任意类型，当做回调函数func的第一个参数传入。
-- @param #function func 回调函数。
-- 传入参数为:(obj, http),其中obj为任意类型；
-- http即为当前的Http对象。
Http.setEvent = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

end
        

package.preload[ "network.http_compat" ] = function( ... )
    return require('network/http_compat')
end
            

package.preload[ "network/http_old" ] = function( ... )
-- http.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for http functions

--------------------------------------------------------------------------------
-- 用于简单的http请求。
-- **规范请参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)。**
-- @module network.http
-- @return #nil
-- @usage require("network.http")


require("core.object");
require("core.system");
require("core.constants");
require("core.global");


--- http请求类型：get
kHttpGet    = 0;
--- http请求类型：post
kHttpPost   = 1;
--- http返回类型(这是唯一可用的类型)
kHttpReserved = 0;

---
--@type Http
Http = class();
Http.s_objs = CreateTable("v");
Http.s_platform = System.getPlatform();

if Http.s_platform == kPlatformAndroid then
    require("network.httpRequest");
end


---
-- 构造方法.
-- 
-- @param self
-- @param #number requestType http请求类型（未使用）。 取值[```kHttpGet```](network.http.html#kHttpGet)、
-- [```kHttpPost```](network.http.html#kHttpPost)。Android、win32平台目前只支持post方式，win10、ios平台均支持Get和Post两种方式。
-- @param #number responseType （未使用）。目前仅能取值[```kHttpReserved```](network.http.html#kHttpReserved)。
-- @param #string url 请求的url。
Http.ctor = function(self, requestType, responseType, url)
    self.m_requestID = http_request_create(requestType, responseType, url);
    Http.s_objs[self.m_requestID] = self;
    self.m_eventCallback = { };
end


---  
-- 析构方法.
-- 
-- @param self
Http.dtor = function(self)
    http_request_destroy(self.m_requestID);
    self.m_requestID = nil;
end


---
-- 设置请求超时时间.  
-- 若多次设置，则取最后一次的值。在@{#Http.execute}前设置才有效 。
-- 
-- @param self
-- @param #number connectTimeout 请求超时时间，单位毫秒。  
-- Android平台：若设置小于1000，则默认为1000；  
-- win32、ios平台：超时时间参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)；  
-- win10平台：默认为10000。
-- @param #number timeout Android、win32、win10平台未使用；ios平台表示[请求过程的最长耗时](https://curl.haxx.se/libcurl/c/CURLOPT_TIMEOUT.html)。
Http.setTimeout = function(self, connectTimeout, timeout)
    http_set_timeout(self.m_requestID, connectTimeout, timeout)
end

---
-- 设置请求消息的User-Agent.
-- 
-- 在@{#Http.execute}前设置才有效。
-- Android未实现；    
-- win32平台：若未调用@{#Http.setAgent}，将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`；  
-- win10平台：已实现，无默认值。  
-- ios平台:若未调用@{#Http.setAgent},将使用默认值`Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3`。
-- @param self
-- @param #string str 请求消息的userAgent。
Http.setAgent = function(self, str)
    http_request_set_agent(self.m_requestID, str);
end

---
-- 请求消息添加Header.
--   
-- Android平台未实现；  
-- win32平台:首个header为“Accept-Encoding:UTF-8”；用户多次调用@{#Http.addHeader}之后,win32平台上将依次添加header到请求消息中；  
-- win10：用户调用@{#Http.addHeader}之后,平台添加header到请求消息中。每个请求添加多次header时，取最后一次的header；  
-- ios平台：用户多次调用@{#Http.addHeader}之后,平台依次添加header到请求消息中。
-- @param self
-- @param #string str 请求消息的Header。
Http.addHeader = function(self, str)
    http_request_add_header(self.m_requestID, str);
end


---
-- 设置请求消息的body.  
-- 
-- 仅支持post请求。
-- Android、win32、win10、ios平台均已实现:请求的消息body默认为空；调用@{#Http.setData}后，更新请求消息的body。
--
-- @param self
-- @param #string str 请求消息的body。
Http.setData = function(self, str)
    http_request_set_data(self.m_requestID, str);
end

---
-- 发送请求.
--   
-- Android、win32、ios平台请求完成后首先回调[```event_http_response_httpEvent```](network.http.html#event_http_response_httpEvent)方法，然后回调@{#Http.setEvent}方法；  
-- win10平台请求完成后，回调@{#Http.setEvent}方法。
-- 
-- @param self
Http.execute = function(self)
    local eventName = "httpEvent";
    http_request_execute(self.m_requestID, eventName);
end

---
-- 取消请求，在@{#Http.execute}之后执行有效.
-- 注：此方法并没有真正取消请求，而是改变了一个变量的值供各平台调度，以达到真正意义上取消请求的目的。
-- 
-- Android、win32平台未实现；    
-- win10、ios平台已实现:调用各自平台的取消方法来达到取消请求的目的。
--
-- @param self
Http.abortRequest = function(self)
    http_request_abort(self.m_requestID);
end

---
-- 请求是否被取消.
-- 
-- Android、win32平台未实现；  
-- win10、ios平台已实现：若已调用过@{#Http.abortRequest}，且平台成功取消请求，则返回true；否则，返回false。
--
-- @param self
-- @return #boolean 若成功取消请求，则返回true；否则，返回false。
Http.isAbort = function(self)
    return(http_request_get_abort(self.m_requestID) == kTrue);
end

---
-- 获得响应的状态码.
-- 
-- Android、win32、win10、ios平台：已实现。返回HTTP状态代码。
--  
-- @param self
-- @return #number 如果请求未完成，返回0；若请求完成，则返回相应的状态码。
Http.getResponseCode = function(self)
    return http_request_get_response_code(self.m_requestID);
end

---
-- 获得响应的内容.
-- 
-- Android、win32、win10平台:返回全部相应内容。
-- ios平台：返回响应内容（不一定是全部内容）。
--
-- @param self
-- @return #string 响应结果。如果请求未完成，则返回空字符串；否则返回响应结果。
Http.getResponse = function(self)
    return http_request_get_response(self.m_requestID);
end

---
-- 获得错误码.
-- 
-- Android、win32、ios平台，若出现异常返回1；否则返回0。  
-- win10平台：当请求不存在或在请求过程中获取错误码返回-1；未发送请求而去获取错误码，返回0；其他情况返回错误码的整数值。参考[win10平台错误码类型](https://curl.haxx.se/libcurl/c/libcurl-errors.html)。
-- 
-- @param self
-- @return #number 返回错误码。
Http.getError = function(self)
    return http_request_get_error(self.m_requestID);
end

---
-- 设置请求完成后的回调函数.
-- 
-- @param self
-- @param obj 任意类型，当做回调函数func的第一个参数传入。
-- @param #function func 回调函数。
-- 传入参数为:(obj, http),其中obj为任意类型；
-- http即为当前的Http对象。
Http.setEvent = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

---
-- Android、win32、ios平台在请求消息后执行的回调函数，win10平台未执行。
-- **开发者不应主动调用此函数**
-- @param #number  requestID 请求的id。
function event_http_response_httpEvent(requestID)
    requestID = requestID or http_request_get_current_id();
    local http = Http.s_objs[requestID];
    if http and http.m_eventCallback.func then
        http.m_eventCallback.func(http.m_eventCallback.obj, http);
    end
end

end
        

package.preload[ "network.http_old" ] = function( ... )
    return require('network/http_old')
end
            

package.preload[ "network/httpRequest" ] = function( ... )

--------------------------------------------------------------------------------
-- Http类与java(或c#)层通信传递数据的桥梁.
-- 此文件里的方法均只在http.lua内部使用，开发者应使用@{core.http}，而不应直接使用此文件。
--
-- @module network.httpRequest
-- @return #nil 
-- @usage require("network.httpRequest")

kHttpRequestNone=0;
kHttpRequestCreate=1;
kHttpRequestRuning=2;
kHttpRequestFinish=3;

HttpRequestNS = {};
HttpRequestNS.http_request_id=0;
HttpRequestNS.kHttpRequestExecute="http_request_execute";
HttpRequestNS.kHttpResponse="http_response";
HttpRequestNS.kId="id";
HttpRequestNS.kStep="step";
HttpRequestNS.kUrl="url";
HttpRequestNS.kData="data";
HttpRequestNS.kTimeout="timeout";
HttpRequestNS.kEvent="event";
HttpRequestNS.kAbort="abort";
HttpRequestNS.kError="error";
HttpRequestNS.kCode="code";
HttpRequestNS.kRet="ret";
HttpRequestNS.kMethod="method";

HttpRequestNS.allocId = function ()
	HttpRequestNS.http_request_id = HttpRequestNS.http_request_id + 1;
	return HttpRequestNS.http_request_id;
end
HttpRequestNS.getKey = function ( iRequestId )
	local key = string.format("http_request_%d",iRequestId);
	return key;
end

---
-- 创建一个http请求.
--
-- @param #number iTypePost http method
-- @param #number iResponseType 未使用
-- @param #string strUrl 请求网址
-- @return #number iRequestId 此请求的唯一id
function http_request_create( iTypePost, iResponseType, strUrl )
	local iRequestId = HttpRequestNS.allocId();
	local key = HttpRequestNS.getKey(iRequestId);
	dict_set_int(key,HttpRequestNS.kStep,kHttpRequestCreate);
	dict_set_int(key,HttpRequestNS.kMethod,iTypePost);
	dict_set_string(key,HttpRequestNS.kUrl,strUrl);
	return iRequestId;
end

---
-- 取消一个http请求.
-- 请求一旦开始就无法取消
--
-- @param #number iRequestId 请求id
function http_request_destroy(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_request_destroy failed %d, not create",iRequestId));
		return
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_request_destroy failed %d, can't destroy while execute ",iRequestId));
		return
	end
	
	dict_delete(key);

end

---
-- 设置请求超时时间.
--
-- @param #number iRequestId 请求id
-- @param #number timeout1 超时时间
-- @param #number timeout2 未使用
function http_set_timeout ( iRequestId, timeout1, timeout2 )
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_set_timeout failed %d, not create",iRequestId));
		return
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_set_timeout failed %d, can't set timeout while execute ",iRequestId));
		return
	end

	dict_set_int(key,HttpRequestNS.kTimeout,timeout1);

end

---
-- 设置请求体.
--
-- @param #number iRequestId 请求id
-- @param #string strValue 请求体.使用key1=value1&key2=value2的格式
function http_request_set_data (iRequestId, strValue )
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_request_set_data failed %d, not create",iRequestId));
		return
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_request_set_data failed %d, can't set data while execute ",iRequestId));
		return
	end

	dict_set_string(key,HttpRequestNS.kData,strValue);

end

---
-- 未使用
function http_request_set_agent(iRequestId,strValue)
	FwLog("not support on android platform");
end

---
-- 未使用
function http_request_add_header(iRequestId,strValue)
	FwLog("not support on android platform");
end

---
-- 开始发送请求.
--
-- @param #number iRequestId 请求id
-- @param #string strEventName 事件名. 
-- 如果传nil,则请求完成后会回调lua里的`event_http_response`方法，
-- 如果传abc，则请求完成后会回调lua里的`event_http_response_abc`方法。
function http_request_execute(iRequestId,strEventName )
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestCreate then
		FwLog(string.format("http_request_execute failed %d",iRequestId));
		return
	end
	
	dict_set_int(HttpRequestNS.kHttpRequestExecute,HttpRequestNS.kId,iRequestId);
	dict_set_int(key,HttpRequestNS.kStep,kHttpRequestRuning);
	dict_set_string(key,HttpRequestNS.kEvent,strEventName);

	if dict_get_int(key,HttpRequestNS.kMethod, kHttpGet) == kHttpGet then
        call_native("HttpGet");
    else
        call_native("HttpPost");
    end

end

---
-- 取消某个请求.
-- 如果已经开始，则无法取消.
--
-- @param #number iRequestId 请求id
function http_request_abort(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestRuning then
		FwLog(string.format("http_request_abort failed %d",iRequestId));
		return
	end
	dict_set_int(key,HttpRequestNS.kAbort,1);
end

---
-- 获得请求结果.
--
-- @param #number iRequestId 请求id
-- @return #string 请求结果
function http_request_get_response(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_response failed %d",iRequestId));
		return "";
	end

	local str = dict_get_string(key,HttpRequestNS.kRet);
	if nil == str then
		return "";
	end
	return str;
end

---
-- 检查某个请求是否被取消.
-- 
-- @param #number iRequestId 请求id
-- @return #number 1表示已取消
function http_request_get_abort(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_abort failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kAbort,0);
	
end

---
-- 获得请求的错误码.
-- 0表示成功，1表示失败
-- 
-- @param #number iRequestId 请求id
-- @return #number 错误码
function http_request_get_error(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_error failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kError,0);

end

---
-- 获得请求返回的状态码 status code.
--
-- @param #number iRequestId 请求id
-- @return #number http status code
function http_request_get_response_code(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_response_code failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kCode,0);
end

---
-- 获得当前被回调的请求Id.
--
-- @param #number id 未使用
-- @return #number requestId
function http_request_get_current_id ( id )
	return dict_get_int(HttpRequestNS.kHttpResponse,HttpRequestNS.kId,0);
end

end
        

package.preload[ "network.httpRequest" ] = function( ... )
    return require('network/httpRequest')
end
            

package.preload[ "network/manager" ] = function( ... )
require('core.object')

local MainThreadSocketManager = class()
MainThreadSocketManager.ctor = function(self)
    self._handler = nil
    self._sockets = {}
end

MainThreadSocketManager.started = function(self)
    return self._handler ~= nil
end
MainThreadSocketManager.start = function(self)
    self._uv = require_uv()
    if not self._handler then
        self._handler = Clock.instance():schedule(function()
            self._uv.run('nowait')
        end)
    end
end
MainThreadSocketManager.stop = function(self)
    if self._handler then
        self._handler:cancel()
        self._handler = nil
    end
end
MainThreadSocketManager.set_protocol = function(self, name, offset, size, initsize, endianess)
    local socket = self._sockets[name]
    local function create_stream()
        return PacketStream(offset, size, initsize, endianess)
    end
    if socket ~= nil then
        socket.create_stream = create_stream
    else
        self._sockets[name] = {
            create_stream = create_stream
        }
    end
end
MainThreadSocketManager.connect = function(self, name, ip, port, callback)
    assert(self._sockets[name] ~= nil and self._sockets[name].sock == nil, 'socket already exists.')
    local socket = self._uv.new_tcp()
    socket:connect(ip, port, function(err)
        if err then
            socket:close()
            self._sockets[name].sock = nil
            callback(err)
        else
            self._sockets[name].sock = socket
            callback()
        end
    end)
end
MainThreadSocketManager.close = function(self, name, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    assert(socket.sock, 'socket not opened')
    socket.sock:close(callback)
    self._sockets[name] = nil
end
MainThreadSocketManager.read_start = function(self, name, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    assert(socket.sock, 'socket not opened')
    local stream = socket.create_stream()
    socket.sock:read_start(function(err, chunk)
        if err or not chunk then
            if err then
                print_string('read error:' .. err)
            else
                print_string('connection closed')
            end
            -- closed by remote.
            socket.sock:close()
            self._sockets[name] = nil
            callback()
            return
        end
        for _, packet in ipairs{stream:feed(chunk)} do
            callback(packet)
        end
    end)
end
MainThreadSocketManager.write = function(self, name, buffer, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    assert(socket.sock, 'socket not opened')
    socket.sock:write(buffer, function(err)
        if err then
            print_string('write error:' .. err)
            socket.sock:close()
            self._sockets[name] = nil
        end
        callback(err)
    end)
end

local MultiThreadSocketManager = class(MainThreadSocketManager)
MultiThreadSocketManager.start = function(self)
    if not self._started then
        self:_start()
        self._started = true
        function event_close()
            self:stop()
        end

    end
end
MultiThreadSocketManager._start = function(self)
    self.m_request_chan = Chan.create()
    self.m_response_chan = Chan.create()
    local async_id_mvar = MVar.create()
    ThreadPool.instance():lua_task(function(request_chan_id, response_chan_id, async_id_mvar_id)
        local sockets = {}
        local request_chan = Chan.get_by_id(request_chan_id)
        local response_chan = Chan.get_by_id(response_chan_id)
        local async_id_mvar = MVar.get_by_id(async_id_mvar_id)
        local uv = require_uv()
        local function handle_request(type, name, ...)
            if type == 'stop' then
                uv.stop()
            elseif type == 'set_protocol' then
                local socket = sockets[name]
                local args = {...}
                local create_stream = function()
                    return PacketStream(unpack(args))
                end
                if socket ~= nil then
                    socket.create_stream = create_stream
                else
                    sockets[name] = {
                        create_stream = create_stream
                    }
                end
            elseif type == 'connect' then
                assert(sockets[name], 'socket ' .. name .. ' has no protocol')
                assert(sockets[name].sock == nil, 'socket ' .. name .. ' already exists.')
                local sock = uv.new_tcp()
                local ip, port = ...
                sock:connect(ip, port, function(status)
                    if not status then
                        -- success
                        sockets[name].sock = sock
                    else
                        sock:close()
                    end
                    response_chan:put(name, 'connect', status)
                end)
            elseif type == 'close' then
                local socket = sockets[name]
                if socket.sock then
                    socket.sock:close()
                    socket.sock = nil
                end
            elseif type == 'read_start' then
                local socket = sockets[name]
                assert(socket and socket.sock, 'socket ' .. name .. ' not opened')
                local stream = socket.create_stream()
                socket.sock:read_start(function(err, chunk)
                    if err or not chunk then
                        if err then
                        end
                        -- closed
                        socket.sock:close()
                        socket.sock = nil
                        response_chan:put(name, 'read', nil)
                        return
                    end
                    for _, packet in ipairs{stream:feed(chunk)} do
                        response_chan:put(name, 'read', packet)
                    end
                end)
            elseif type == 'write' then
                local socket = sockets[name]
                assert(socket and socket.sock, 'socket ' .. name .. ' not opened')
                local data, callback = ...
                if socket and socket.sock then
                    socket.sock:write(data, function(err)
                        if err then
                            socket.sock:close()
                            socket.sock = nil
                        end
                        response_chan:put(name, callback, err)
                    end)
                end
            end
        end
        local async_id = UVAsync.create(function()
            while true do
                local req = {request_chan:take(false)}
                if not req or not req[1] then
                    break
                end
                -- handle requests
                local err, msg = pcall(handle_request, unpack(req))
                if err then
                    print_string('handle request error:' .. msg)
                end
            end
        end)
        async_id_mvar:put(async_id)
        uv.run()
    end, nil, self.m_request_chan.id, self.m_response_chan.id, async_id_mvar.id)

    -- block waiting for async.
    self.m_async_id = async_id_mvar:take()
end

MultiThreadSocketManager.send_request = function(self, ...)
    self.m_request_chan:put(...)
    UVAsync.send(self.m_async_id)
end

MultiThreadSocketManager.set_protocol = function(self, name, offset, size, initsize, endianess)
    self:send_request('set_protocol', name, offset, size, initsize, endianess)
end

MultiThreadSocketManager.stop = function(self)
    if self._started then
        self:send_request('stop')
    end
end
MultiThreadSocketManager.started = function(self)
    return self._started
end
MultiThreadSocketManager.connect = function(self, name, ip, port, callback)
    assert(self._sockets[name] == nil, 'socket already exists.');
    -- notify
    self._sockets[name] = {
        write_callback_id = 0,
        connect = callback,
        close = nil,
        read = nil,
    }

    self:send_request('connect', name, ip, port)
    self:_ensure_scheduler()
end
MultiThreadSocketManager.close = function(self, name, callback)
    self._sockets[name] = nil
    self:send_request('close', name)
end
MultiThreadSocketManager._ensure_scheduler = function(self)
    if not self._scheduler then
        self._scheduler = Clock.instance():schedule(function()
            -- check response
            while true do
                local name, callback, arg = self.m_response_chan:take(false)
                if not name then
                    break
                end
                local callback = self._sockets[name][callback]
                if (callback == 'read' and not arg) or (callback == 'write' and arg) then
                    self._sockets[name] = nil
                elseif callback ~= 'read' then
                    self._sockets[name][callback] = nil
                end
                if callback == nil then
                    print_string('callback is nil ' .. callback)
                end
                callback(arg)
            end
        end)
    end
end

MultiThreadSocketManager.read_start = function(self, name, callback)
    assert(self._sockets[name].read == nil, 'duplicate read request')
    self._sockets[name].read = callback
    self:send_request('read_start', name)
end

MultiThreadSocketManager.write = function(self, name, buffer, callback)
    local socket = assert(self._sockets[name], 'socket not exists')
    socket.write_callback_id = socket.write_callback_id + 1
    socket[socket.write_callback_id] = callback
    self:send_request('write', name, buffer, socket.write_callback_id)
end

return {
    singleThread = new(MainThreadSocketManager),
    multiThread = new(MultiThreadSocketManager),
}

end
        

package.preload[ "network.manager" ] = function( ... )
    return require('network/manager')
end
            

package.preload[ "network/protocols" ] = function( ... )
require('core.object')

local function encrypt_buffer(buffer)
    if #buffer ~= 1 then
        buffer = table.concat(buffer)
    else
        buffer = buffer[1]
    end
    return PacketStream.encrypt_buffer(buffer, 0)
end

local Packet = class()

Packet.ctor = function(self, headformat, index_of_size, endian)
    self.headformat = endian .. headformat
    self.headsize = struct.size(self.headformat)
    self.index_of_size = index_of_size
    self.endian = endian
    self.buffer = {}
    self.headvalue = {}
end

Packet.readBegin = function(endian, packet)
    error('not implementated')
    -- return position, {cmd=, subcmd=,}
end

Packet.writeBegin = function(self, ...)
    self.headvalue = {...}
end

Packet.preWrite = function(self)
    -- update body size
    local len = 0
    for _, buf in ipairs(self.buffer) do
        len = len + #buf
    end
    self.headvalue[self.index_of_size] = len
end

Packet.writeEnd = function(self)
    self:preWrite()
    local head = struct.pack(self.headformat, unpack(self.headvalue))
    local buf = self.buffer
    self.buffer = {}
    table.insert(buf, 1, head)
    return table.concat(buf)
end

Packet.write = function(self, buf)
    table.insert(self.buffer, buf)
end

local Packet_BY9 = class(Packet, false)
Packet_BY9.headformat = 'HBBBBHB'
Packet_BY9.ctor = function(self, endian)
    super(self, Packet_BY9.headformat, 1, endian)
end
Packet_BY9.readBegin = function(endian, packet)
    packet.position = struct.size(Packet_BY9.headformat)+1
    packet.data = PacketStream.decrypt_buffer(packet.data, packet.position-1)
    packet.head = {
        size = struct.unpack(endian .. 'H', packet.data, 1),
        cmd = struct.unpack(endian .. 'H', packet.data, 7),
    }
end
Packet_BY9.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, 0, string.byte('B'), string.byte('Y'), ver, subver, cmd, 0)
end
Packet_BY9.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 2
    -- encrypt
    local buffer, check = encrypt_buffer(self.buffer)
    self.headvalue[7] = check
    self.buffer = {buffer}
end

local Packet_BY7 = class(Packet, false)
Packet_BY7.headformat = 'HBBBH'
Packet_BY7.ctor = function(endian)
    super(Packet_BY7.headformat, 1, endian)
end
Packet_BY7.writeBegin = function(self, cmd, ver)
    Packet.writeBegin(self, 0, string.byte('B'), string.byte('Y'), ver, cmd)
end
Packet_BY7.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 2
    -- encrypt
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
end
Packet_BY7.readBegin = function(endian, buffer)
    packet.position = struct.size(Packet_BY9.headformat)+1
    packet.data = decrypt_buffer(packet.data, packet.position-1)
    packet.head = {
        size = struct.unpack(endian .. 'H', buffer, 1),
        cmd = struct.unpack(endian .. 'H', buffer, 6),
    }
end

local Packet_BY14 = class(Packet, false)
Packet_BY14.headformat = 'HBBBBHBHHB'
Packet_BY14.ctor = function(endian)
    super(Packet_BY14.headformat, 1, endian)
end
Packet_BY14.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, 0, string.byte('B'), string.byte('Y'), ver, subver, cmd, 0, subCmd, 0, dev)
end
Packet_BY14.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 2
    -- set sequeuce
    self.headvalue[9] = 0
    local buffer, check = encrypt_buffer(self.buffer)
    self.headvalue[7] = check
    self.buffer = {buffer}
end

local Packet_TEXAS = class(Packet, false)
Packet_TEXAS.headformat = 'BBHBBHBI4'
Packet_TEXAS.ctor = function(endian)
    super(Packet_TEXAS.headformat, 6, endian)
end
Packet_TEXAS.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, string.byte('I'), string.byte('C'), cmd, ver, subver, 0, 0, 0)
end
Packet_TEXAS.preWrite = function(self)
    Packet.preWrite(self)
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
    self.headvalue[7] = check
    --self.headvalue[8] = sequence
end

local Packet_VOICE = class(Packet, false)
Packet_VOICE.headformat = 'BBHBBI4BI4'
Packet_VOICE.ctor = function(endian)
    super(Packet_VOICE.headformat, 6, endian)
end
Packet_VOICE.writeBegin = function(self, cmd, ver, subver, dev)
    Packet.writeBegin(self, string.byte('I'), string.byte('C'), cmd, ver, subver, 0, 0, 0)
end
Packet_VOICE.preWrite = function(self)
    Packet.preWrite(self)
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
    self.headvalue[7] = check
    --self.headvalue[8] = sequence
end

local Packet_QE = class(Packet, false)
Packet_QE.headformat = 'I4BBBBI4HB'
Packet_QE.ctor = function(endian)
    super(Packet_QE.headformat, 1, endian)
end
Packet_QE.writeBegin = function(self, ver, cmd, gameId)
    Packet.writeBegin(self, 0, string.byte('Q'), string.byte('E'), ver, 0, cmd, gameId, 0)
end
Packet_QE.preWrite = function(self)
    Packet.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 4
    local buffer, check = encrypt_buffer(self.buffer)
    self.buffer = {buffer}
    self.headvalue[8] = check
end

local Packet_IPOKER = class(Packet, false)
Packet_IPOKER.headformat = 'BBHHH'
Packet_IPOKER.ctor = function(endian)
    super(Packet_IPOKER.headformat, 5, endian)
end
Packet_IPOKER.writeBegin = function(self, cmd, ver)
    Packet.writeBegin(self, string.byte('E'), string.byte('S'), cmd, ver, 0)
end

return {
    IPOKER = Packet_IPOKER,
    TEXAS = Packet_TEXAS,
    BY9 = Packet_BY9,
    BY7 = Packet_BY7,
    BY14 = Packet_BY14,
    QE = Packet_QE,
    VOICE = Packet_VOICE,
}

end
        

package.preload[ "network.protocols" ] = function( ... )
    return require('network/protocols')
end
            

package.preload[ "network/socket" ] = function( ... )
if require_uv ~= nil then
    require('network.socket2')
else
    require('network.socket_old')
end

end
        

package.preload[ "network.socket" ] = function( ... )
    return require('network/socket')
end
            

package.preload[ "network/socket2" ] = function( ... )
require("core.object");
local Packets = require('network.protocols')
local manager = require('network.manager').singleThread
manager:start()

--- socket连接成功
kSocketConnected        = 1;
--- socket连接失败
kSocketConnectFailed    = 4;
--- socket关闭成功
kSocketUserClose        = 5;
--- socket收到数据包
kSocketRecvPacket       = 9;

Socket = class();

Socket.s_sockets = {};
Socket.ctor = function(self,sockName,sockHeader,netEndian, gameId, deviceType, ver, subVer)
    if Socket.s_sockets[sockName] then
        error("Already have a " .. sockName .. " socket");
        return
    end
    self.m_name = sockName
    self.m_socketType = sockName; 
    Socket.s_sockets[sockName] = self;

    self:setProtocol(sockHeader, netEndian)
    self.m_packet_id = 0
    self.m_packets = {}

    self.m_gameId = gameId
    self.m_deviceType = deviceType
    self.m_ver = ver
    self.m_subVer = subVer
end

Socket.setProtocol = function(self, protocol, netEndian)
    self.m_endian = netEndian and '>' or '<'
    self.m_protocol = protocol
    -- for stream reader, { offset, size, initsize }.
    local size_field = {
        TEXAS = {6, 2, struct.size(Packets.TEXAS.headformat)},
        VOICE = {6, 2, struct.size(Packets.VOICE.headformat)},
        BY9 = {0, 2, 2},
        BY14 = {0, 2, 2},
        QE = {0, 4, 4},
        BY7 = {0, 2, 2},
        IPOKER = {6, 2, struct.size(Packets.IPOKER.headformat)},
    }
    local args = size_field[protocol]
    table.insert(args, self.m_endian)
    table.insert(args, 1, self.m_name)
    manager:set_protocol(unpack(args))
end

Socket.setConnTimeout = function (self,timeOut)
end

Socket.setEvent = function(self,obj,func)
    self.m_cbObj = obj;
    self.m_cbFunc = func;
end

Socket.onSocketEvent = function(self,eventType, param)
    if self.m_cbFunc then
        self.m_cbFunc(self.m_cbObj,eventType, param);
    end
end

Socket.open = function(self, ip, port)
    manager:connect(self.m_name, ip, port, function(status)
        if not status then
            -- success
            self:onSocketEvent(kSocketConnected)
            manager:read_start(self.m_name, function(packet)
                if packet == nil then
                    -- connection lost
                    self:onSocketEvent(kSocketUserClose)
                    return
                end
                local packetId = self:_addPacket(packet)
                self:onSocketEvent(kSocketRecvPacket, packetId)
            end)
        else
            self:onSocketEvent(kSocketConnectFailed, status)
        end
    end)
end

Socket._addPacket = function(self, packet)
    self.m_packet_id = self.m_packet_id + 1
    self.m_packets[self.m_packet_id] = {
        data = packet,
        position = 1
    }
    return self.m_packet_id
end

Socket.close = function(self, callback)
    manager:close(self.m_name, callback)
end
Socket.readBegin = function(self, packetId)
    local packet = self.m_packets[packetId]
    Packets[self.m_protocol].readBegin(self.m_endian, packet)
    return packet.head.cmd
end
Socket.readEnd = function(self, packetId)
    self.m_packets[packetId] = nil
end

Socket.readInt = function(self, packetId, defaultValue)
    local packet = self.m_packets[packetId]
    if #packet.data + 1 < packet.position + 4 then
        return defaultValue
    end
    local n
    n, packet.position = struct.unpack(self.m_endian .. 'I4', packet.data, packet.position)
    return n
end

Socket.writeBegin = function(self, ...)
    local packet = new(Packets[self.m_protocol], self.m_endian)
    packet:writeBegin(...)

    self.m_packet_id = self.m_packet_id + 1
    self.m_packets[self.m_packet_id] = packet
    return self.m_packet_id
end

Socket.writeBegin2 = function(self, ...)
    return self:writeBegin(...)
end

Socket.writeBegin3 = function(self, ...)
    return self:writeBegin(...)
end

Socket.writeBegin4 = function(self, ...)
    return self:writeBegin(...)
end

Socket.writeInt = function(self, packetId, n)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'I4', n))
end

Socket.writeEnd = function(self, packetId)
    local packet = self.m_packets[packetId]
    local buffer = packet:writeEnd()
    manager:write(self.m_name, buffer, function(err)
        if err then
            self:onSocketEvent(kSocketUserClose)
        end
    end)
    self.m_packets[packetId] = nil
end

Socket.readBinary = function(self, packetId)
    local n1 = self:readInt(packetId, 0)
    local len = self:readInt(packetId, 0)
    local str
    str, packet.position = struct.unpack('c' .. tostring(len), packet.data, packet.position)
    if n1 == 0 then
        return str
    else
        return gzip_decompress(str)
    end
end

Socket.writeBinary = function(self, packetId, string, compress)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack('I4', compress))
    self:writeString(packetId, compress and gzip_compress(string) or string)
end

Socket.readString = function(self, packetId)
    local packet = self.m_packets[packetId]
    local len = self:readInt(packetId, 0)
    local str
    str, packet.position = struct.unpack('c' .. tostring(len-1), packet.data, packet.position)
    assert(string.sub(packet.data, packet.position, packet.position) == '\0', 'not zero terminated.')
    packet.position = packet.position + 1
    return str
end

Socket.writeString = function(self, packetId, str)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'I4s', #str + 1, str))
end

Socket.readByte = function(self, packetId, defaultValue)
    local packet = self.m_packets[packetId]
    if #packet.data + 1 < packet.position + 1 then
        return defaultValue
    end
    local n
    n, packet.position = struct.unpack(self.m_endian .. 'B', packet.data, packet.position)
    return n
end

Socket.writeByte = function(self, packetId, b)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'B', b))
end

Socket.readShort = function(self, packetId, defaultValue)
    local packet = self.m_packets[packetId]
    if #packet.data + 1 < packet.position + 2 then
        return defaultValue
    end
    local n
    n, packet.position = struct.unpack(self.m_endian .. 'H', packet.data, packet.position)
    return n
end

Socket.writeShort = function(self, packetId, b)
    local packet = self.m_packets[packetId]
    packet:write(struct.pack(self.m_endian .. 'H', b))
end

Socket.writeBuffer = function(self, buffer)
    manager:write(self.m_name, buffer, function(err)
        if err then
            self:onSocketEvent(kSocketUserClose)
        end
    end)
end

end
        

package.preload[ "network.socket2" ] = function( ... )
    return require('network/socket2')
end
            

package.preload[ "network/socket_old" ] = function( ... )

--------------------------------------------------------------------------------
-- socket，用于和游戏服务器通信.
-- 只支持博雅游戏的各种协议，数据加密与解密已经内置在引擎中。
-- 
-- @module network.socket
-- @return #nil 
-- @usage     require("network.socket")
--     local PROTOCOL_TYPE_QE="QE"                           -- 注：具体协议应与server确定
--     -- 创建一个socket，socketName为"DOUDIZHU",此名称唯一
--     -- socketHeader为PROTOCOL_TYPE_QE，netEndian网络字节序设为1， gameId为10010
--     -- deviceType为192，ver主版本号为20.5，subVer子版本号为0.08
--     local socket = new(Socket,"DOUDIZHU",PROTOCOL_TYPE_QE,1, 10010, 192, 20.5, 0.08)
--     -- 设置10s内连接有效
--     socket:setConnTimeout(10*1000) 
--     -- 服务器的地址为192.168.1.1 端口号为80   
--     socket:open("192.168.1.1",80) 
--      
--     -- socket成功连接后，可以发送数据。
--     -- cmd的值此处为1，应与server确认。由于ver，subVer，deviceType已经在构造函数中设置，所以这里传nil；也可以传其他值覆盖。
--     -- 返回packetId,收到消息、设置回调会用到
--     local packetId=socket:writeBegin (1, nil, nil, nil)   --先写入包头
--     socket:writeString(packetId,"发送的内容")              -- 写入数据
--     socket:writeEnd(packetId)                             -- 数据写入完成，可以发送了 
--   
--     -- 设置回调函数。设置事件kSocketRecvPacket，那么每次收到消息时即触发。
--     socket:setEvent(packetId,function(kSocketRecvPacket,packetId)
--          socket:readString(packetId)                        -- 读取消息。 调用readString或readInt等，应与server确认。
--     end
--     )
--     
--     -- 关闭连接
--     socket:close()

-- socket.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2015-12-15 by DengXuanYing
-- Description: provide basic wrapper for socket functions


require("core.object");

--- socket连接成功
kSocketConnected        = 1;
--- socket连接失败
kSocketConnectFailed    = 4;
--- socket关闭成功
kSocketUserClose        = 5;
--- socket收到数据包
kSocketRecvPacket       = 9;

---
--
-- @type Socket
Socket = class();

---
-- 保存所有的socket实例.
Socket.s_sockets = {};

---
-- 构造函数.
--
-- @param self
-- @param #string sockName socket名字，同名的socket只能同时存在一个。
-- @param #number sockHeader 包头类型，请联系游戏server来确定。
-- @param #number netEndian 网络字节序， 目前固定传1。 
-- @param #number gameId 游戏的id，此值是游戏server确定的。
-- @param #number deviceType 设备类型，此值是游戏server确定的。
-- @param #number ver 协议版本号，此值是游戏server确定的。
-- @param #number subVer 协议子版本号，此值是游戏server确定的。
Socket.ctor = function(self,sockName,sockHeader,netEndian, gameId, deviceType, ver, subVer)

  if Socket.s_sockets[sockName] then
    error("Already have a " .. sockName .. " socket");
    return
  end

  self.m_socketType = sockName; 
  Socket.s_sockets[sockName] = self;
  self:setProtocol ( sockHeader, netEndian ); 

  self.m_gameId = gameId;
  self.m_deviceType = deviceType;
  self.m_ver = ver;
  self.m_subVer = subVer;
  
end

---
-- 析构函数.
--
-- @param self
Socket.dtor = function(self)
  Socket.s_sockets[self.m_socketType] = nil;
end


---
-- 设置协议类型.
-- 此方法仅在构造方法内调用。
--
-- @param self
-- @param #number sockHeader 包头类型，请联系游戏server来确定。
-- @param #number netEndian 网络字节序，目前固定传1。 
Socket.setProtocol = function ( self,sockHeader,netEndian )
  socket_set_protocol ( self.m_socketType, sockHeader, netEndian );
end

---
-- 设置连接超时时间.
--
-- @param self
-- @param #number timeOut 超时时间(毫秒)。
Socket.setConnTimeout = function ( self,timeOut )
  socket_set_conn_timeout ( self.m_socketType, timeOut );
end

---
-- 设置QE协议的扩展包头长度.
--
-- @param self
-- @param #number sizeExt 扩展包头大小，单位为字节。
Socket.setHeaderExtSize = function ( self,sizeExt )
  socket_set_header_extend ( self.m_socketType, sizeExt );
end

---
-- 该接口已废除.
--
Socket.setReconnectParam = function(self, reconnectTimes, interval)
  --return Socket.callFunc(self,"reconnect",reconnectTimes,interval);
end

---
-- 设置事件回调函数.
-- 
-- @param self
-- @param obj 任意类型，回调时传回。
-- @param #function func 回调函数，传入参数为：(obj, eventType, param)。
-- eventType: 事件类型。  
-- 取值[```kSocketConnected```](network.socket.html#kSocketConnected)(连接成功)，
-- [```kSocketConnectFailed```](network.socket.html#kSocketConnectFailed)(连接失败)，
-- [```kSocketUserClose```](network.socket.html#kSocketUserClose)(关闭连接)，
-- [```kSocketRecvPacket```](network.socket.html#kSocketRecvPacket)(收到数据包)。  
-- param: 辅助参数，任意类型。当eventType取值kSocketRecvPacket时，param应传数据包的id。
Socket.setEvent = function(self,obj,func)
  self.m_cbObj = obj;
  self.m_cbFunc = func;
end

---
-- 用于接收事件回调.
-- **开发者不应主动调用此函数。**
--
-- @param self
-- @param #number eventType 事件类型。
-- @param #number param 额外参数。
Socket.onSocketEvent = function(self,eventType, param)
  if self.m_cbFunc then
    self.m_cbFunc(self.m_cbObj,eventType, param);
  end
end

--- 
-- 该函数已经废除.
Socket.reconnect = function(self,num,interval)
  
end

---
-- 开始连接socket.
-- 成功仅表示开始连接，并不代表已经连上。
--
-- @param self
-- @param #string ip 连接ip。
-- @param #number port 端口号。
-- @return #number 返回0表示连接成功，-1表示连接失败。
Socket.open = function(self, ip, port)
  return socket_open(self.m_socketType,ip,port);
end

---
-- 关闭socket.
-- 关闭是异步的，关闭完成后会收到kSocketUserClose事件。
--
-- @param self
-- @param #number param 保留，目前未使用。
Socket.close = function(self, param)
  return socket_close(self.m_socketType,param or -1);
end

---
-- 生成一个数据包，并写入包头信息.
-- 
-- @param self
-- @param #number cmd 命令号。
-- @param #number ver 协议版本号。
-- @param #number subVer 协议子版本号。
-- @param #number deviceType 设备类型。
-- @return #number 该数据包的packetId。
Socket.writeBegin = function(self, cmd, ver, subVer, deviceType)
  return socket_write_begin(self.m_socketType,cmd,
    ver or self.m_ver,
    subVer or self.m_subVer,
    deviceType or self.m_deviceType);
end

---
-- 生成一个数据包，并写入包头信息.
-- 
-- @param self
-- @param #number cmd 命令号。
-- @param #number subCmd 子命令号。
-- @param #number ver 协议版本号。
-- @param #number subVer 协议子版本号。
-- @param #number deviceType 设备类型。
-- @return #number 该数据包的packetId。
Socket.writeBegin2 = function(self, cmd, subCmd, ver, subVer, deviceType)
  return socket_write_begin2(self.m_socketType,cmd,subCmd,
    ver or self.m_ver,
    subVer or self.m_subVer,
    deviceType or self.m_deviceType);
end

---
-- 生成一个数据包，并写入包头信息.
-- 
-- @param self
-- @param #number cmd 命令号。
-- @param #number ver 协议版本号。
-- @param #number gameId 游戏类型id。
-- @return #number 该数据包的packetId。
Socket.writeBegin3 = function(self, cmd, ver, gameId)
  return socket_write_begin3(self.m_socketType,
      ver or self.m_ver,
      cmd,
      gameId or self.m_gameId);
end

---
-- 生成一个数据包，并写入包头信息.
--
-- @param self
-- @param #number cmd 命令号。
-- @param #number ver 协议版本号。
-- @return #number 该数据包的packetId。
Socket.writeBegin4 = function(self,cmd,ver)
  return socket_write_begin4(self.m_socketType,ver or self.m_ver,cmd);
end

---
-- 写入一个byte.
-- 向指定的数据包末尾位置写入一个byte数据。
--
-- @param self
-- @param #number packetId 数据包id, 由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的byte数据。
Socket.writeByte = function(self, packetId, value)
  return socket_write_byte(packetId,value);
end

---
-- 写入一个short.
-- 向指定的数据包末尾位置写入一个short数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的short数据。
Socket.writeShort = function(self, packetId, value)
  return socket_write_short(packetId,value);
end

---
-- 写入一个int.
-- 向指定的数据包末尾位置写入一个int数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的int数据。
Socket.writeInt = function(self, packetId, value)
  return socket_write_int(packetId,value);
end


---
-- 写入一个int64.
-- 向指定的数据包末尾位置写入一个int64数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #number value 写入的int64数据。
Socket.writeInt64 = function(self,packetId,value)
  return socket_write_int64(packetId,value);
end

---
-- 写入一个string.
-- 向指定的数据包末尾位置写入一个字符串数据。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
-- @param #string value 写入的字符串数据。
Socket.writeString = function(self, packetId, value)
  return socket_write_string(packetId,value);
end

---
-- 直接发送字符串.
-- 创建一个包，向包里写入一个字符串，覆盖包的全部内容（包括包头），然后发送该包。
--
-- @param self
-- @param #string value 要发送的字符串，最大32k。
Socket.writeBuffer = function(self,value)
  return socket_write_buffer(self.m_socketType,value);
end

---
-- 数据包内容写入完成.
-- 调用该函数后代表数据包已经完成，并开始发送数据包给服务器。
--
-- @param self
-- @param #number packetId packetId 数据包id,由@{#Socket.writeBegin}或类似的接口返回。
Socket.writeEnd = function(self, packetId)
  return socket_write_end(packetId);
end

---
-- 开始读取一个数据包.
--
-- @param self
-- @param #number packetId 数据包的id。
Socket.readBegin = function(self, packetId)
  return socket_read_begin(packetId);
end

---
-- 读取子命令号.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @return #number subCmd 返回子命令号。
Socket.readSubCmd = function(self, packetId)
  return socket_read_sub_cmd(packetId);
end

---
-- 读取一个byte.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个byte数据。
Socket.readByte = function(self, packetId, defaultValue)
  return socket_read_byte(packetId,defaultValue);
end


---
-- 读取一个short.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个short数据。
Socket.readShort = function(self, packetId, defaultValue)
  return socket_read_short(packetId,defaultValue);
end


---
-- 读取一个int.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个int数据。
Socket.readInt = function(self, packetId, defaultValue)
  return socket_read_int(packetId,defaultValue);
end

---
-- 读取一个int64.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @param #number defaultValue 默认值，如果读取失败，返回该值。
-- @return #number 返回一个int64数据。
Socket.readInt64 = function(self, packetId, defaultValue)
  return socket_read_int64(packetId,defaultValue);
end

---
-- 读取一个string.
--
-- @param self
-- @param #number packetId 数据包的id。
-- @return #string 读到的string。
Socket.readString = function(self,packetId)
  return socket_read_string(packetId);
end


---
-- 读取结束后调用此方法释放数据包所占内存.
--
-- @param self
-- @param #number packetId 数据包的id。
Socket.readEnd = function(self, packetId)
  return socket_read_end(packetId);
end

Socket.writeBinary = function(self, packetId, string, compress)
  return socket_write_string_compress(packetId, string, compress)
end

Socket.readBinary = function(self, packetId)
  return socket_read_string_compress(packetId)
end

---
-- 用于接收c++的socket事件通知.
-- **开发者不应直接调用此方法。**
--
-- @param #string sockName socket的名称。
-- @param #number eventType 事件类型，取值：[```kSocketConnected```](network.socket.html#kSocketConnected)(连接成功)，
-- [```kSocketConnectFailed```](network.socket.html#kSocketConnectFailed)(连接失败)，
-- [```kSocketUserClose```](network.socket.html#kSocketUserClose)(关闭连接)，
-- [```kSocketRecvPacket```](network.socket.html#kSocketRecvPacket)(收到数据包)。
-- @param #number param1 eventType为kSocketRecvPacket时是packetId。
-- @param #number param2 eventType为kSocketRecvPacket时是接收包队列里数据包的数量。
function event_socket(sockName, eventType, param1, param2)
  if Socket.s_sockets[sockName] then
    Socket.s_sockets[sockName]:onSocketEvent(eventType, param1);
  end
end

end
        

package.preload[ "network.socket_old" ] = function( ... )
    return require('network/socket_old')
end
            

package.preload[ "network/version" ] = function( ... )

--返回版本号
return '3.0(1dbb0846961c5470b830b89e3570302436005dd6)'

end
        

package.preload[ "network.version" ] = function( ... )
    return require('network/version')
end
            
require("network.http");
require("network.http2");
require("network.socket");
require("network.version");

