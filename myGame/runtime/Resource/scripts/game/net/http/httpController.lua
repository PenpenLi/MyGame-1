-- httpController.lua
-- Last modification : 2016-05-10
-- Description: a controller to finish all http request.

local HttpProcesser = require("game.net.http.httpProcesser")
local HttpController = class();

-- Get HttpController Instance
function HttpController.getInstance()
	if not HttpController.s_instance then 
		HttpController.s_instance = new(HttpController);
	end
    return HttpController.s_instance;
end

-- Release HttpController Instance
function HttpController.releaseInstance()
	delete(HttpController.s_instance);
	HttpController.s_instance = nil;
end

function HttpController:ctor()
	self.m_httpModule = new(HttpModule, HttpConfig.BASE_URL);
    self.m_httpModule:appendConfigs(HttpConfig.s_request)
	self.m_httpProcesser = new(HttpProcesser, self.m_httpModule)

    self.m_defaultParams = {}
    self.m_defaultParams["gid"] = 2
    self.m_defaultParams["uuid"] = nk.GameNativeEvent:read_getUUID()

	EventDispatcher.getInstance():register(EventConstants.httpModule, self, self.onHttpResponse);
end

function HttpController:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpModule, self, self.onHttpResponse);
	delete(self.m_httpModule);
	self.m_httpModule = nil;
end

-- do http request
-- callback need use handler
function HttpController:execute(command, data, url, callback)
    if not self.m_httpModule:checkCommand(command) then
        return false;
    end
    local config = self:getConfigMap()[command]

    local method = config.method
    data.param.method = method
    local addDefaultParams = config.addDefaultParams
    if addDefaultParams == nil then
        addDefaultParams = true
    end

    local paramData
    local httpClass
    -- 判断是否可使用socket_http请求
    -- if HttpConfig.SOCKET_REQUEST == 1 and not config.isHttp then
    if HttpConfig.SOCKET_REQUEST == 1 and  config.isHttp then
        -- TODO 当socket断掉的时候，使用http直接请求
        -- if nk.SocketController and nk.SocketController:getSocketStatus() == nk.SocketController.s_status.CONNECTED then
        -- end
        httpClass = SocketHttp
        if config.httpType == kHttpGet then
            paramData = ""
        else
            paramData = self:postDataOrganizerSocket(method, data, addDefaultParams)
        end
    else
        httpClass = Http
        if config.httpType == kHttpGet then
            paramData = ""
        else
            paramData = self:postDataOrganizer(method, data, addDefaultParams)
        end
    end

    Log.dump(paramData,">>>>>>>>>>>>>>>>>>>>>>>>> paramData")
    if callback then
        self.m_httpModule:execute_open_type(httpClass, data.param.url, paramData, callback, config.httpType or kHttpPost)
    else
        self.m_httpModule:execute(httpClass, command, paramData, (url or config.url))
    end
end

-- do http request by open type
-- callback need use handler
function HttpController:executeOpenType(url, data, callback, httpType)
    self.m_httpModule:execute_open_type(url, data, callback, httpType)
end

-- 组织post数据
function HttpController:postDataOrganizer(method,params,addDefaultParams)  -- post 数据
    local allParams = params
     local defaultParams = {}
    if addDefaultParams then
        defaultParams = self:getDefaultParameter()
        -- allParams.sig = md5_string(nk.functions.shJoins(params.game_param,0))
    end

    table.merge(allParams, defaultParams)
    -- allParams.method = method
    
    -- local paramString = ""
    -- -- allParams = {gid, uuid, param}
    -- for i, v in pairs(allParams) do
    --     if type(v) == "table" then
    --         paramString = paramString .. i .. "=" .. json.encode(v) .. "&"
    --     else
    --         paramString = paramString .. i .. "=" .. v .. "&"
    --     end
    -- end


    -- return paramString
    return json.encode(allParams);
    -- return allParams;
end

-- 组织post数据 for SocketHttp
function HttpController:postDataOrganizerSocket(method,params,addDefaultParams)  -- post 数据
    local allParams = params
     local defaultParams = {}
    if addDefaultParams then
        defaultParams = self:getDefaultParameter()
        allParams.sig = md5_string(nk.functions.shJoins(params.game_param,0))
    end

    table.merge(allParams, defaultParams)
    allParams.method = method

    return allParams
end

function HttpController:getDataOrganizer( ... )
    -- body
end

function HttpController:getDefaultParameter()
    return clone(self.m_defaultParams)
end

function HttpController:cleanDefaultParameter()
    self.m_defaultParams = {}
end

function HttpController:setLoginType_(loginType)
    local lid = 0
    if loginType == "GUEST" then
        lid = 2
    elseif loginType == "FACEBOOK" then
        lid = 1      
    end
    self.m_defaultParams["lid"] = lid
    return lid
end

function HttpController:setSessionKey(key)
    self.m_defaultParams["sesskey"] = key
end

function HttpController:joins(t,mtkey)
    return Joins(t,mtkey);
end

function HttpController:urlOrganizer(url,method,httpType)  -- get url 拼接
	if httpType == kHttpPost then
		return url;
	end
	return url;
end

function HttpController:onHttpResponse(command,errorCode,data)
	local config = self:getConfigMap()[command];
	local callback = config.callback or command .. "CallBack";
	local flag = false
    if errorCode == HttpErrorType.SUCCESSED then
        flag = true
    else
        flag = false
    end
    if self.m_httpProcesser[callback] then
    	self.m_httpProcesser[callback](self.m_httpProcesser, command, errorCode, data)
    else
    	Log.printWarn("gameBase", "GameData, no such cmd but dispatch ~");
        EventDispatcher.getInstance():dispatch(EventConstants.httpProcesser,command,errorCode,data);
    end
end

function HttpController:getConfigMap()
	return self.m_httpModule:getConfigMap();
end

function HttpController:setConfigMap(configMap)
	self.m_httpModule:setConfigMap(configMap);
end

function HttpController:appendConfigs(configMap)
    self.m_httpModule:appendConfigs(configMap)
end

function HttpController:removeConfigs(configMap)
    self.m_httpModule:removeConfigs(configMap)
end

function HttpController.explainPHPFlag(message)

end

-- 取消http请求
-- @param index execute为commond; execute_open_type为url
function HttpController:cancleRequest(index)
    local request = self.m_httpModule:getRequest(index)
    if request then
        self.m_httpModule:destroyHttpRequest(request)
    end
end

return HttpController
