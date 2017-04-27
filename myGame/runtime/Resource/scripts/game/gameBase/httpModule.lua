-- httpModule.lua
-- Last modification : 2016-05-09
-- Description: rewrite httpManager class in core 

HttpModule = class();

function HttpModule:ctor(defaultURL)
	-- save request index
	self.m_httpCommandMap = {};
	-- save http request object
	self.m_httpObjectMap = {};
	-- save http request time out anim
	self.m_httpObjectTimeoutAnimMap = {};
	-- save http request function config
	self.m_configMap = {}
	-- save http request callback
	self.m_httpCallBackMap = {};

	self.m_defaultURL = defaultURL

	-- http2 请求超时时间，单位秒。 
	self:setDefaultTimeout(10)
end

function HttpModule:getDefaultURL()
    return self.m_defaultURL
end

function HttpModule:setDefaultURL(url)
    self.m_defaultURL = url
end

function HttpModule:getConfigMap()
	return self.m_configMap;
end

function HttpModule:appendConfigs(configMap)
	for k,v in pairs(configMap or {}) do
		self.m_configMap[k] = v;
	end
end

function HttpModule:removeConfigs(configMap)
	for k,v in pairs(configMap or {}) do
		self.m_configMap[k] = nil;
	end
end

function HttpModule:setDefaultTimeout(time)
	self.m_timeout = time or self.m_timeout;
end

--[[]
@param int command
@param table data = {*url = "", param = ""}

@return http object
--]]
function HttpModule:execute(httpClass, command,data,url_)
	if not self:checkCommand(command) then
		return false;
	end
	if not url_ and (conifg and not config.url) and not self.m_defaultURL then
		Log.printWarn("core", "No defaultURL in http request");
		return false;
	end

	-- self:destroyHttpRequest(self.m_httpObjectMap[command]);

	local config = self.m_configMap[command];
	local httpType = config.httpType or kHttpPost;
	
	local url = url_ or config.url or self.m_defaultURL

	local httpRequest = new(httpClass, httpType, kHttpReserved, url)
	httpRequest:setEvent(self, self.onResponse);
	httpRequest:setTimeout(self.m_timeout,self.m_timeout);

	if config.httpType == kHttpGet then
		url = url .. data
	else
    	httpRequest:setData("api=" .. string.urlencode(data))-- {api = data}
    end
	Log.printInfo("HttpModule execute"," url:---------->" .. url .. " |  param:---------->" .. string.urlencode(data));
    -- Log.dump("HttpModule execute",json.encode{api = data});
	-- local timeoutAnim = self:createTimeoutAnim(command, config.timeout or self.m_timeout);

    self.m_httpCommandMap[httpRequest] = command;
    self.m_httpObjectMap[command] = httpRequest;
    self.m_httpObjectTimeoutAnimMap[command] = timeoutAnim;
    
	httpRequest:execute();
	self.httpRequest = httpRequest
	return httpRequest
end

-- 用于请求http，返回后不分发，走回调函数
function HttpModule:execute_open_type(httpClass, url, data, callback, httpType)
	url = url or self.m_defaultURL
	-- self:destroyHttpRequest(self.m_httpObjectMap[url]);

	local httpType = httpType or kHttpGet;
	print(httpType, kHttpReserved, url)
	local httpRequest = new(httpClass, httpType, kHttpReserved, self.m_defaultURL)
	httpRequest:setEvent(self, self.onResponse);
	httpRequest:setTimeout(self.m_timeout,self.m_timeout);
	if httpType == kHttpPost then
    	httpRequest:setData("api=" .. string.urlencode(data));
    end

    Log.printInfo("HttpModule execute"," url:---------->" .. url .. " |  param:---------->");
    Log.dump("HttpModule execute",data);

	-- local timeoutAnim = self:createTimeoutAnim_open_type(url, self.m_timeout);

    self.m_httpCommandMap[httpRequest] = url;
    self.m_httpCallBackMap[httpRequest] = callback
    self.m_httpObjectMap[url] = httpRequest;
    self.m_httpObjectTimeoutAnimMap[url] = timeoutAnim;
    
	httpRequest:execute();
	self.httpRequest = httpRequest
	return httpRequest
end

function HttpModule:getRequest(index)
	if self.m_httpObjectMap and self.m_httpObjectMap[index] then
		return self.m_httpObjectMap[index]
	else
		return nil
	end
end

function HttpModule:dtor()
	self:destroyAllHttpRequests();

    self.m_httpCommandMap = nil;
    self.m_httpCallBackMap = nil
    self.m_httpObjectMap = nil;
	self.m_httpObjectTimeoutAnimMap = nil;

	self.m_configMap = nil;
end

---------------------------------private functions-----------------------------------------

function HttpModule:checkCommand(command)
	local errLog = nil;

	repeat 
		if not (command or self.m_configMap[command]) then
			errLog = "There is not command like this";
			break;
		end

		local config = self.m_configMap[command];

		-- if not config.method then
		-- 	errLog = "There is not method in command";
		-- 	break;
		-- end

		local httpType = config.httpType;
		if httpType ~= nil and httpType ~= kHttpPost and  httpType ~= kHttpGet then
			errLog = "Not supported http request type";
			break;
		end
	until true

	if errLog then
		HttpModule.log(self,command,errLog);
		return false;
	end

	return true;
end

function HttpModule:log(command, str)
	local prefixStr = "HttpRequest error :";
	if config then
		prefixStr =prefixStr .. " command |" .. command;
	end

	Log.printWarn(prefixStr .. " | " .. str);
end

function HttpModule:onResponse(httpRequest)
	print("HttpModule:onResponse")
    if self.m_httpCommandMap == {} or not self.m_httpCommandMap then
        return;
    end

	local command = self.m_httpCommandMap[httpRequest];

	if not command then
		self:destroyHttpRequest(httpRequest);
		return;
	end

	self:destoryTimeoutAnim(command);
 
 	local errorCode = HttpErrorType.SUCCESSED;
 	local data = nil;
   	
   	local httpErrorCode
   	local httpErrorResponseCode

	repeat 
		-- 判断http请求的错误码,0--成功 ，非0--失败.
		-- 判断http请求的状态 , 20开头--成功 ，非20开头--失败.
		httpErrorCode = httpRequest:getError()
		httpErrorResponseCode = httpRequest:getResponseCode()
		if 0 ~= httpErrorCode or not (httpErrorResponseCode >= 200 and httpErrorResponseCode <= 209) then
			errorCode = HttpErrorType.NETWORKERROR;
			 Log.printInfo("httpRequestgetResponseCode = ", httpErrorResponseCode)
			 Log.printInfo("httpRequestgetError = ", httpErrorCode)
			break;
		end
	
		-- http 请求返回值
		local resultStr =  httpRequest:getResponse();
		
		Log.printInfo("-----------------------------------------------")
		Log.printInfo("resultStr:"..resultStr);
		Log.printInfo("-----------------------------------------------")


		-- http 请求返回值的json 格式
		local json_data = json.decode(resultStr);

		--返回错误json格式.
	    if not json_data then
	    	errorCode = HttpErrorType.JSONERROR;
			break;
	    end

	    data = json_data;
        -- dump(data)
	until true;

	if errorCode == HttpErrorType.SUCCESSED then
		Log.printInfo("HttpModule", "httpCode:" .. httpErrorCode .. " " .. httpErrorResponseCode .. " errorCode:SUCCESSED command:" .. (command or ""))
	elseif errorCode == HttpErrorType.TIMEOUT then
		Log.printInfo("HttpModule", "httpCode:" .. httpErrorCode .. " " .. httpErrorResponseCode .. " errorCode:TIMEOUT command:" .. (command or ""))
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
	elseif errorCode == HttpErrorType.NETWORKERROR  then
		Log.printInfo("HttpModule", "httpCode:" .. httpErrorCode .. " " .. httpErrorResponseCode .. " errorCode:NETWORKERROR command:" .. (command or ""))
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
	elseif errorCode == HttpErrorType.JSONERROR  then
		Log.printInfo("HttpModule", "httpCode:" .. httpErrorCode .. " " .. httpErrorResponseCode .. " errorCode:JSONERROR command:" .. (command or ""))
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "JSON_DATA_FAIL"))	
	end
	local callback = self.m_httpCallBackMap[httpRequest];

	self:destroyHttpRequest(httpRequest);

	-- 用于开发式回调
	if callback then
		callback(errorCode, data)
		return
	end
    EventDispatcher.getInstance():dispatch(EventConstants.httpModule,command,errorCode,data);
end

function HttpModule.onTimeout(callbackObj)
	Log.printInfo("[HttpModule.onTimeout]", callbackObj["command"]);

	local self = callbackObj["obj"];
	local command = callbackObj["command"];
    
    local code = self.httpRequest:getResponseCode()
	Log.printInfo("self.httpRequest:getResponseCode()", code)

	nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
	
    HttpModule.destroyHttpRequest(self, self.m_httpObjectMap[command]);

	EventDispatcher.getInstance():dispatch(EventConstants.httpModule,command,HttpErrorType.TIMEOUT);
end

function HttpModule.onTimeout_open_type(callbackObj)
	Log.printInfo("[HttpModule.onTimeout_open_type]");

	local self = callbackObj["obj"];
	local url = callbackObj["command"];
    local request = self.m_httpObjectMap[url]
    local callback = self.m_httpCallBackMap[request]
    if callback then
        callback(HttpErrorType.TIMEOUT)
    end

	HttpModule.destroyHttpRequest(self, request);
end

function HttpModule:createTimeoutAnim(command,timeoutTime)
	local timeoutAnim = new(AnimInt,kAnimRepeat,0,1,timeoutTime,-1);
	timeoutAnim:setDebugName("AnimInt | httpTimeoutAnim");
    timeoutAnim:setEvent({["obj"] = self,["command"] = command},self.onTimeout);

    return timeoutAnim;
end

function HttpModule:createTimeoutAnim_open_type(command,timeoutTime)
	local timeoutAnim = new(AnimInt,kAnimRepeat,0,1,timeoutTime,-1);
	timeoutAnim:setDebugName("AnimInt | createTimeoutAnim_open_type");
    timeoutAnim:setEvent({["obj"] = self,["command"] = command},self.onTimeout_open_type);

    return timeoutAnim;
end

function HttpModule:destoryTimeoutAnim(command)
	delete(self.m_httpObjectTimeoutAnimMap[command]);

	self.m_httpObjectTimeoutAnimMap[command] = nil;
end

function HttpModule:destroyHttpRequest(httpRequest)
	if not httpRequest then 
		return;
	end

	local command = self.m_httpCommandMap[httpRequest];
	
	if not command then
		delete(httpRequest);
	    return;
	end

	self:destoryTimeoutAnim(command);
	self.m_httpObjectMap[command] = nil;
	self.m_httpCommandMap[httpRequest] = nil;
	self.m_httpCallBackMap[httpRequest] = nil
end

function HttpModule:destroyAllHttpRequests()
	for _,v in pairs(self.m_httpObjectMap)do 
		self:destroyHttpRequest(v);
	end
end