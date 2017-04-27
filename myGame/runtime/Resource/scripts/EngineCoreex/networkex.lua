
local Http2 = require('network.http2')

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
        if self.m_eventCallback.func then
            self.m_eventCallback.func(self.m_eventCallback.obj, self)
        end

    end)
end