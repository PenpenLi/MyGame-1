-- messageController.lua
-- Last modification : 2016-07-16
-- Description:
-- message model
local messageController= class()
local CacheHelper = require("game.cache.cache")
messageController.modelData = nil
messageController.noticeData = nil

function messageController:ctor()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
    self.friendMsgTip_ = 0
    self.sysMsgTip_ = 0
end 

function messageController:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function messageController:clean()
    messageController.modelData = nil
    messageController.noticeData = nil
    self.messageData = nil
end

function messageController:request_system_notice(callback)
    self.system_notice_callback_ = callback
    if messageController.noticeData then
        if self.system_notice_callback_ then
             self.system_notice_callback_(true, messageController.noticeData)
        end
    else
        local url = nk.userData.NOTICE_JSON 
        local cacheHelper_ = new(CacheHelper) 
        cacheHelper_:cacheFile(url,function(result, content, stype)
            if result then
                if stype == "downLoad" then
                    if self.selectedTab ~= 2 then
                        -- 标记系统公告未读
                        local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE)
                        nk.DictModule:setInt("gameData", nk.cookieKeys.SYSTEM_NOTICE_READ, 0)
                        datas["sysNoticePoint"] = true
                    end
                end
                messageController.noticeData = content
                if messageController.noticeData  then
                     if self.system_notice_callback_ then
                          self.system_notice_callback_(true, messageController.noticeData)
                     end
                end
                Log:printInfo("success loading notice")
            else
                Log:printInfo("error loading notice")
            end
        end,"notice","data")
    end
end

function messageController:request_message_model(callback)
   self.system_message_callback_ = callback
   if messageController.modelData then
       self:request_message_data()
   else
       local url = nk.userData.MSGTPL_ROOT
       local cacheHelper = new(CacheHelper)
       cacheHelper:cacheFile(url,function(result, content, stype)
           if result then
               messageController.modelData = content
               self:request_message_data()
               Log:printInfo("success loading msgModel")
           else
               Log:printInfo("error loading msgModel")
           end
       end,"message","data")
   end
end

function messageController:request_message_data()
    if self.messageData then
        self:parse_message_data(self.messageData)
        return
    end

    if self.requesting_ then
        return
    end
    self.requesting_ = true
    nk.HttpController:execute("Message.getUserMessage", {})
end

function messageController:delete_message(param,callback)
    self.delete_message_callback_ = callback
    self.deleteParams_ = param.id
    nk.HttpController:execute("Message.deleteUserMessage", {game_param = param})
end

function messageController:onHttpProcesser(command, errorCode, data)
    if command == "Message.getUserMessage" then  
    --获取消息    
        self.requesting_ = false
        if errorCode ~=1 then                   
            return
        end

        self.messageData = data.data
        self:parse_message_data(self.messageData)
     elseif command == "Message.deleteUserMessage" then 
     --删除消息
        if errorCode ~=1 then
            return
        end
        local code = data.code
        if code == 1 then
           if self.delete_message_callback_ then
               for i,v in ipairs(self.deleteParams_) do
                   if self.messageData then
                       for j = #self.messageData, 1,-1 do
                          if v == self.messageData[j].a then
                              table.remove(self.messageData,j)
                          end
                       end                  
                   end
               end
               self.delete_message_callback_(true)
           end
        end
    end
end

-- "a" = "id" "b" = "type" "c" = "status" "d" = "time" "e" = "content" "f" = "tplid"消息模板id
-- "g"点击领取按钮提交到php的参数  "h"按钮的状态<为了兼容老版本额外新增 0 领取 1 已领取 2 已自动领取>
function messageController:parse_message_data(data)
    if data then
        self.friendData = {}
        self.systemData = {}

        local friendMsgTip = self.friendMsgTip_
        local sysMsgTip = self.sysMsgTip_

        for i=1, #data, 1 do
            local keyTable = {} 
            local i1 = 0
            local j1 = 0
            local str = data[i].e
            while true do
                -- print("str:" .. str)
                i1, j1 = string.find(str, "<#.-#>", j1) 
                if j1 == nil then break end
                -- print("sub:" .. string.sub(str, i1, j1))
                table.insert(keyTable, string.sub(str, i1, j1))
            end

            --从模板配置用获取图片Url
            if messageController.modelData then
                local imgIndex = messageController.modelData.pic[data[i].b .. ""][data[i].f .. ""]
                data[i].img = messageController.modelData.piclist[imgIndex] or "";

                data[i].msg = messageController.modelData.msg[data[i].b .. ""][data[i].f .. ""]
            else
                data[i].img = ""
                data[i].msg = ""
            end
            for m=1, #keyTable, 1 do
                -- print(keyTable[m])
                local i2, j2 = string.find(keyTable[m], "<#.-#")  
                local key = string.sub(keyTable[m], (i2 + 2), (j2 - 1))
                -- print("key:" .. key)      
                local i3, j3 =     string.find(keyTable[m], "#.-#>", (j2 + 1))
                local value = string.sub(keyTable[m], (i3 + 1), (j3 - 2))
                -- print("value:" .. value)

                data[i].msg = string.gsub(data[i].msg, (key), value)
                -- print(data[i].msg .. " ====================== msg")
            end

            --button
            data[i].bt_status = data[i].h
            data[i].bt_info = data[i].g
            
            if checkint(data[i].b) <= 200 then
                -- friend message
                if checkint(data[i].h) == 0 then
                    friendMsgTip = 1
                end
                self.friendData[#self.friendData + 1] = data[i]
            else
                -- system message
                if checkint(data[i].h) == 0 then
                    sysMsgTip = 1
                end
                self.systemData[#self.systemData + 1] = data[i]
            end
        end

        local content = nil
        if self.selectedTab == 1 then
            content = self.systemData
        else
            content = self.friendData
        end

        if self.system_message_callback_ then
            self.system_message_callback_(true,content)
        end

        if friendMsgTip == 1 then
            self.friendMsgTip_ = self.friendMsgTip_ + 1
        end
        if sysMsgTip == 1 then
            self.sysMsgTip_ = self.sysMsgTip_ + 1
        end

        if self.selectedTab ~= 1 then
            if self.sysMsgTip_ == 1 then
                self.noNeedClear_ = true
                local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE)
                datas["sysMsgPoint"] = true
            end
        end
        if self.selectedTab ~= 3 then
            if self.friendMsgTip_ == 1 then
                self.noNeedClear_ = true
                local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE)
                datas["friendMsgPoint"] = true
            end
        end
    end
end

function messageController:set_tab(index)
     self.selectedTab = index
end

return messageController