-- socketHttp.lua
-- Create date : 2016-08-05
-- Last modification : 2016-08-05
-- Description: a http for socket
--
-- 按照http的模式，创建一个socketHttp,通过于socket进行http请求
--

SocketHttp = class()

SocketHttp.id = 1
---
-- 构造方法.
-- 
-- @param self
-- @param #number requestType http请求类型（未使用）。 取值[```kHttpGet```](network.http.html#kHttpGet)、
-- [```kHttpPost```](network.http.html#kHttpPost)。Android、win32平台目前只支持post方式，win10、ios平台均支持Get和Post两种方式。
-- @param #number responseType （未使用）。目前仅能取值[```kHttpReserved```](network.http.html#kHttpReserved)。
-- @param #string url 请求的url。
SocketHttp.ctor = function(self, requestType, responseType, url)
    self.m_requestID = self:getId()
    self.m_url = url
    self.m_requestType = requestType
    self.m_data = ''
    self.m_eventCallback = {}
    EventDispatcher.getInstance():register(EventConstants.socketProcesser, self, self.onEventBack)
end


---  
-- 析构方法.
-- 
-- @param self
SocketHttp.dtor = function(self)
    EventDispatcher.getInstance():unregister(EventConstants.socketProcesser, self, self.onEventBack)
    -- abort ?
end

---  
-- 析构方法.
-- 
-- @param self
SocketHttp.getId = function(self)
    SocketHttp.id = SocketHttp.id + 1
    return SocketHttp.id
end

---
-- 设置请求超时时间.  
-- 若多次设置，则取最后一次的值。在@{#SocketHttp.execute}前设置才有效 。
-- 
-- @param self
-- @param #number connectTimeout 请求超时时间，单位毫秒。  
-- Android平台：若设置小于1000，则默认为1000；  
-- win32、ios平台：超时时间参考 [RFC2616](http://www.ietf.org/rfc/rfc2616.txt)；  
-- win10平台：默认为10000。
-- @param #number timeout Android、win32、win10平台未使用；ios平台表示[请求过程的最长耗时](https://curl.haxx.se/libcurl/c/CURLOPT_TIMEOUT.html)。
SocketHttp.setTimeout = function(self, connectTimeout, timeout)
    self.m_connecttimeout = connectTimeout
    self.m_timeout = timeout
end

---
-- 设置请求消息的body.  
-- 
-- 仅支持post请求。
-- Android、win32、win10、ios平台均已实现:请求的消息body默认为空；调用@{#SocketHttp.setData}后，更新请求消息的body。
--
-- @param self
-- @param #string str 请求消息的body。
SocketHttp.setData = function(self, str)
    self.m_data = str
end

---
-- 发送请求.
--   
-- Android、win32、ios平台请求完成后首先回调[```event_http_response_httpEvent```](network.http.html#event_http_response_httpEvent)方法，然后回调@{#SocketHttp.setEvent}方法；  
-- win10平台请求完成后，回调@{#SocketHttp.setEvent}方法。
-- 
-- @param self
SocketHttp.execute = function(self)
    local param = {}
    param.id = self.m_requestID
    param.isCompress = 1
    param.httpType = self.m_requestType + 1
    param.url = self.m_url
    param.params = json.encode(self.m_data)
    nk.SocketController:httpRequest(param) 
end

---
-- 取消请求，在@{#SocketHttp.execute}之后执行有效.
-- 注：此方法并没有真正取消请求，而是改变了一个变量的值供各平台调度，以达到真正意义上取消请求的目的。
-- 
-- Android、win32平台未实现；    
-- win10、ios平台已实现:调用各自平台的取消方法来达到取消请求的目的。
--
-- @param self
SocketHttp.abortRequest = function(self)
    self.m_aborted = true
    --http_request_abort(self.m_requestID);
end

---
-- 请求是否被取消.
-- 
-- Android、win32平台未实现；  
-- win10、ios平台已实现：若已调用过@{#SocketHttp.abortRequest}，且平台成功取消请求，则返回true；否则，返回false。
--
-- @param self
-- @return #boolean 若成功取消请求，则返回true；否则，返回false。
SocketHttp.isAbort = function(self)
    return self.m_aborted == true
end

---
-- 获得响应的状态码.
-- 
-- Android、win32、win10、ios平台：已实现。返回HTTP状态代码。
--  
-- @param self
-- @return #number 如果请求未完成，返回0；若请求完成，则返回相应的状态码。
SocketHttp.getResponseCode = function(self)
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
SocketHttp.getResponse = function(self)
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
SocketHttp.getError = function(self)
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
SocketHttp.setEvent = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

---
-- 设置请求完成后的回调函数.
-- 
-- @param self
-- @param obj 任意类型，当做回调函数func的第一个参数传入。
-- @param #function func 回调函数。
-- 传入参数为:(obj, http),其中obj为任意类型；
-- http即为当前的Http对象。
SocketHttp.onEventBack = function(self, commond, pack)
    -- Log.dump(pack or {}, "onEventBackonEventBack")
    if commond ~= "SVR_PHP_BACK" or not pack then
        return
    end
    if pack.id == self.m_requestID then
        self.m_response = {}
        self.m_response.code = pack.responseCode
        self.m_response.content = pack.data
        if self.m_eventCallback.func then
            self.m_eventCallback.func(self.m_eventCallback.obj, self)
        end
    end
end