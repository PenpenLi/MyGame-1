-- FeedbackController.lua
-- Author: john leo
-- Date: 2016-07-13
-- Last modification : 2016-07-13


local FeedbackController= class()
local CacheHelper = require("game.cache.cache")


function FeedbackController:ctor()
  print("FeedbackController.ctor()")
  self.tab_ = 1
  self:register()
end 

function FeedbackController:register()
    -- body
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function FeedbackController:unregister()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function FeedbackController:loadQConfig(url,callback)
   if self.url_ ~= url then
        self.url_ = url
        self.isQConfigLoaded_ = false
        self.isQConfigLoading_ = false   
   end
    self.loadQConfigCallback_ = callback
    self:loadQConfig_()
end

function FeedbackController:loadQConfig_()
    if not self.isQConfigLoaded_ and not self.isQConfigLoading_ then
        self.isQConfigLoading_ = true
        local cacheHelper_ = new(CacheHelper)
        cacheHelper_:cacheFile(self.url_ or nk.userData.SELF_SERVICE_JSON ,function(result,content,stype)
            self.isQConfigLoading_ = false
            if result then
                self.isQConfigLoaded_ = true
                if not self.QConfigData_ then
                    self.QConfigData_ = content
                    if self.QConfigData_ == nil then
                        print("question 配置错误!!")
                    end
                end
                if self.loadExpConfigCallback_ then
                     self.loadExpConfigCallback_(true, self.QConfigData_)
                end
            else
                if self.loadExpConfigCallback_ then
                    self.loadExpConfigCallback_(false)
                end
            end
        end,"question","data")
    elseif self.isQConfigLoaded_ then
        if self.loadQConfigCallback_ then
             self.loadQConfigCallback_(true, self.QConfigData_)
        end
    end
end

function FeedbackController:getQuestionConfig()
   return self.QConfigData_
end

function FeedbackController:getFeedbackData(callback)
    self.feedbackListCallback_ = callback
    if self.feedbackData_ then
        if self.feedbackListCallback_ then
             self.feedbackListCallback_(true, self.feedbackData_)
             return
        end
    end

    if self.requesting_ then
         return
    end
    self.requesting_ = true
   
    local params = {}
    params.device = nk.GameNativeEvent:read_getSystemInfo().mac
    params.mid = nk.UserDataController.getUid()
    local method = "feedback.getList"

    local post_data = {api = self:getParams(method,params)}
    nk.HttpController:execute(method, post_data, HttpConfig.FEEDBACK_RUL)
end

function FeedbackController:sendFeedback(params,callback)
    self.feedbackCallback_ = callback
    params.device = nk.GameNativeEvent:read_getSystemInfo().mac
    params.mid = nk.userData["mid"]
    params.gametype = GameConfig.FEEDBACK_GAEM_TYPE 
    local method = "feedback.send"

    local post_data = {api = self:getParams(method,params)}

    nk.HttpController:execute(method, post_data, HttpConfig.FEEDBACK_RUL)
end

function FeedbackController:onHttpProcesser(command, errorCode, data)
    if command == "feedback.getList" then
        --反馈历史
        self.requesting_ = false
        if errorCode ~=1 then
            return
        end

        local flag = data.flag
        if flag ~= 1  then return end
        self.feedbackData_ = data.data.list
        local num = #self.feedbackData_ 
        if num <= 0 then return end

        --按反馈时间排序
        table.sort(self.feedbackData_,function(a,b) return a.time > b.time end)

        --本地保存一个key(时间戳)和value(标志: 0未读 )
        if checkint(self.feedbackData_[1].isreply) == 1 then
            --有回复
            local read = nk.DictModule:getInt("gameData", tostring(self.feedbackData_[1].time), 0)
            if read == 0 then
                --未读 
                local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE)
                
                if not nk.PopupManager:hasPopup(nil,"FeedbackPopup") then
                     datas["settingPoint"] = true
                     datas["feedbackPoint"] = true
                     datas["fbTabPoint"] = true
                else
                    if self.tab_ ~= 2 then
                        datas["fbTabPoint"] = true
                    end
                end
             end
        end

        if self.feedbackListCallback_ then
            self.feedbackListCallback_(true,self.feedbackData_)
        end
     elseif command == "feedback.send" then 
        --提交反馈
        if errorCode ~=1 or not data then
            Log:printInfo("FeedbackController","feedback.send  json error!")
        end
        if self.feedbackCallback_ then
              self.feedbackCallback_(true, data)
        end
    end
end

function FeedbackController:getParams(method,params)
    local method = method
    local gid = GameConfig.FEEDBACK_GID
    local version = GameConfig.CUR_VERSION
    self.time_ = os.time()
    local gkey = "fa09e016e0cc3afebd78952c53b46820"
    local mtkey = gkey

    local post_data = {}
    post_data.method = method
    post_data.gid = gid
    post_data.version = version
    post_data.time = self.time_
    post_data.mtkey = mtkey
    post_data.param = params
    post_data.api = 2

    local signature =nk.functions.Joins(post_data, post_data.mtkey)
    post_data.sig = string.lower(md5_string(signature)) 

    if params.content then
         params.content = self:encodeURI(params.content)
    end

    local api = json.encode(post_data)
    return api
end

function FeedbackController:decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function FeedbackController:encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


return FeedbackController