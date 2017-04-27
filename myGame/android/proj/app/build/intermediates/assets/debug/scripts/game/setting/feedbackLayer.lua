-- feedbackLayer.lua
-- Author: john leo
-- Date: 2016-07-12
-- Last modification : 2016-08-6
local PopupModel = import('game.popup.popupModel')
local feedbackView = require(VIEW_PATH .. "setting/setting_feedback")
local feedbackInfo = VIEW_PATH .. "setting/setting_feedback_layout_var"
local http2 = require('network.http2')
local FeedbackPopup= class(PopupModel)

FeedbackPopup.Type = {"PAY","LOGIN","ACCOUNT","BUG","SUGGEST","COMPLAIN","OTHER"}

function FeedbackPopup.show(data)
	PopupModel.show(FeedbackPopup, feedbackView, feedbackInfo, {name="FeedbackPopup"}, data)
end

function FeedbackPopup.hide()
	PopupModel.hide(FeedbackPopup)
end

function FeedbackPopup:ctor(viewConfig)
    nk.FeedbackController:register()
    self.beforeScene = nk.HornTextRotateAnim.getScene()
    nk.HornTextRotateAnim.setupScene("")
	Log.printInfo("FeedbackPopup.ctor")
    self.uploadPicWidth_ = 109
    self.uploadPicHeight_ = 89
    self.historyList_ = {}
    self:initLayer()
    EventDispatcher.getInstance():register(EventConstants.PickPictureCallBack, self, self.pickPictureCallBack)

    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE)
    if datas then
        --去掉大厅红点
        datas["settingPoint"] = false
        --去掉设置界面的红点
        datas["feedbackPoint"] = false
    end
    
    --反馈tab的红点
    self.feedbackObserver_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "fbTabPoint", handler(self, self.feedbackPoint))
end 

function FeedbackPopup:initLayer()
     self:initWidget()
     self:service_text_click()
end

function FeedbackPopup:initWidget()

    self.bt_close_ = self:getControl(self.s_controls["Button_close"])
    self.bt_close_:setOnClick(self,self.close_bt_click)

    self.text_self_service_ = self:getControl(self.s_controls["Text_self_service"])
    self.text_self_service_:setText(bm.LangUtil.getText("SETTING", "SELF_SERVICE"))
    self.text_self_service_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:service_text_click()
                                          end
                                          end) 

   self.text_msg_board_ = self:getControl(self.s_controls["Text_msg_board"])
   self.text_msg_board_:setText(bm.LangUtil.getText("SETTING", "MSG_BOARD"))
   self.text_msg_board_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:board_text_click()
                                          end
                                          end) 
   
    self.view_self_service_ = self:getControl(self.s_controls["View_self_service"])
    self.view_msg_board_ = self:getControl(self.s_controls["View_msg_board"])

    self.scrollview_chat_ = self:getUI("ScrollView_chat")
    self.scrollview_chat_.m_autoPositionChildren = true

    self.bg_ = self:getUI("Image_bg")
    self.bg_:setEventTouch(self,function()
                                  Log:printInfo("feecback_bg click do noting")
                                end)
    self.bg_h_ = self.bg_:getSize()  

    self.bt_commit_ = self:getUI("Button_commit")
    self.bt_commit_:setOnClick(self,self.bt_commit_click)
    self.bt_commit_:setEnable(true)
    self.text_commit_ = self:getUI("Text_commit")
    self.text_commit_:setText(bm.LangUtil.getText("SETTING","COMMIT"))

    self.bt_addpic_ = self:getUI("Button_addpic")
    self.bt_addpic_:setOnClick(self,self.addPic)
    self:getUI("Text_addpic"):setText(bm.LangUtil.getText("SETTING","UPLOAD_PIC"))

    self.text_type_ = self:getUI("Text_type")
    self.text_type_:setText(bm.LangUtil.getText("SETTING", "TYPE"))
    self.showType_ = false
    self.text_type_:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:type_text_click()
                                          end
                                          end) 

    self.editText_ = self:getUI("EditTextView_content")
    self.editText_:setHintText(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
    self.editText_:setMaxLength(200)

    self.text_history_ = self:getUI("Text_history")
    self.text_history_:setText(bm.LangUtil.getText("SETTING","HISTORY"))

    self.scrollview_history_ = self:getUI("ScrollView_history")
    self.scrollview_history_.m_autoPositionChildren = true

    self.iamge_fb_pic_ = self:getUI("Image_fb_pic")

    self.image_type_ = self:getUI("Image_zhankai")
    self.image_type_:setEventTouch(self,function()  end)

    self.radio_bt_type_ = self:getUI("RadioButtonGroup_type")
    self.radio_bt_type_:setOnChange(self,self.radio_bt_click)

    self.text_type_list_={}
    for i = 1,7  do
        table.insert(self.text_type_list_,self:getUI("Text_type_" .. i))
    end
    for i,v in ipairs(self.text_type_list_) do
        v:setText(bm.LangUtil.getText("SETTING",FeedbackPopup.Type[i]))
    end

    self.image_fb_redPoint_ = self:getUI("Image_fb_redPoint")
    self.image_fb_redPoint_:setVisible(false)
end



function FeedbackPopup:history_list(data)
    local info = data
    self.scrollview_history_:removeAllChildren(true)
    for i,v in ipairs(info) do
      local item = self:history_item(v)
      self.scrollview_history_:addChild(item)
    end   
end

function FeedbackPopup:history_item(data)
    local node = new(Node)
    local left = 30
    local space = 20
    local top = 20
    local h_node = top
    
    --反馈
    local fb_title = new(Text,bm.LangUtil.getText("SETTING","FB_TITLE"),nil,nil,kAlignLeft,nil,18,28,27,28)
    local _,h_title = fb_title:getSize()
    node:addChild(fb_title)
    fb_title:setPos(lelf,h_node)

    local fb_time = new(Text,os.date("%Y-%m-%d", data.time),nil,nil,kAlignLeft,nil,18,41,96,37)
    local _,h_time = fb_time:getSize()
    node:addChild(fb_time)
    fb_time:setPos(600,h_node)

    h_node = h_node + h_title + space

    local fb_content = new(TextView,data.content,620,nil,kAlignLeft,nil,18,28,27,28)
    local _,h_content = fb_content:getSize()
    node:addChild(fb_content)
    fb_content:setPos(left,h_node)
    h_node = h_node +h_content + space


    --回复
    if checkint(data.isreply) == 1 then 
        local re_title = new(Text,bm.LangUtil.getText("SETTING","RE_TITLE"),nil,nil,kAlignLeft,nil,18,64,84,121)
        local _,h_title = re_title:getSize()
        node:addChild(re_title)
        re_title:setPos(lelf,h_node)

        local re_time = new(Text,os.date("%Y-%m-%d", data.rtime),nil,nil,kAlignLeft,nil,18,41,96,37)
        local _,h_time = re_time:getSize()
        node:addChild(re_time)
        re_time:setPos(600,h_node)

        h_node = h_node + h_title + space

        local re_content = new(TextView,data.reply,620,nil,kAlignLeft,nil,18,64,84,121)
        local _,h_content = re_content:getSize()
        node:addChild(re_content)
        re_content:setPos(left,h_node)
        h_node = h_node + h_content + space
    end

    --分割线
    local line = new(Image,"res/setting/setting_rule_line.png")
    node:addChild(line)
    local _,h_line = line:getSize()
    line:setSize(860,h)
    line:setPos(10,h_node)
    h_node = h_node + h_line 
    
    node:setSize(650,h_node)
    return node
end

-- @ param iType 1.一级标题  2.二级标题  3. 答案＆提示  4. 解决&未解决  5. 留言回复
function FeedbackPopup:chat_item(data,iType,name)
    local info = data
    local num = #info
    local chat_node = new(Node)
    local space = 30
    local left = 45
    local top = 20

    --头像
    local image_head = new(Image,"res/head/common_female_avatar.png")
    chat_node:addChild(image_head)
    image_head:setSize(66,66)
    image_head:setPos(0,5)

    --聊天背景
    local image_bg = new(Image,"res/setting/setting_otherbg.png",nil,nil,30,30,50,15)
    local _, image_bg_h = image_bg:getSize()
    chat_node:addChild(image_bg)
    image_bg:setPos(76,0)

    if  iType == 1 then
         local text_title = new(Text,"you can choose question:",nil,nil,kAlignLeft,nil,18,28,27,28)   
         --标题
         local _,title_h = text_title:getSize()
         image_bg:addChild(text_title)
         text_title:setPos(left,top)

         for i,v in ipairs(info) do
            -- 一级问题
            local text_q = new(Text,i .. "." .. v.name,nil,nil,kAlignLeft,nil,18,7,65,255)
            image_bg:addChild(text_q)
            text_q:setPos(left, i*(space + title_h) + 10 )
            text_q:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:text_first_click(text_q,v)
                                          end
                                 end)
         end
        
         local text_content_h = (#info+1) * (title_h+space) + top
         image_bg_h =  text_content_h > image_bg_h and text_content_h or image_bg_h
         image_bg:setSize(850, image_bg_h)
         chat_node:setSize(self.bg_h_, image_bg_h )

    elseif iType == 2 then
         local text_title = new(Text,"you can choose question:" .. name,nil,nil,kAlignLeft,nil,18,28,27,28)   
         --标题
         local _,title_h = text_title:getSize()
         image_bg:addChild(text_title)
         text_title:setPos(left,top)

         for i,v in ipairs(info) do
            -- 二级问题
            local text_q = new(Text,i .. "." .. v.name,nil,nil,kAlignLeft,nil,18,7,65,255)
            image_bg:addChild(text_q)
            text_q:setPos(left, i*(space + title_h) + 10 )
            text_q:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:text_second_click(text_q,v)
                                          end
                                 end)
         end
        
         local text_content_h = (#info+1) * (title_h+space) + top
         image_bg_h =  text_content_h > image_bg_h and text_content_h or image_bg_h
         image_bg:setSize(850, image_bg_h)
         chat_node:setSize(self.bg_h_, image_bg_h )

    elseif iType == 3 then
         local text_title = new(TextView,info,760,nil,kAlignLeft,nil,18,28,27,28)   
         --答案
         local _,title_h = text_title:getSize()
         image_bg:addChild(text_title)
         text_title:setPos(left,top)
         
         if  (title_h + top) >= image_bg_h then
             image_bg:setSize(850, title_h + 2*top)
             chat_node:setSize(self.bg_h_, title_h + 2*top )
         else
            image_bg:setSize(850, image_bg_h)
            chat_node:setSize(self.bg_h_, image_bg_h )
         end
    elseif iType == 4 then
         local text_title = new(Text,"is solved you question:",nil,nil,kAlignLeft,nil,18,28,27,28)   
         --解决&未解决
         local _,title_h = text_title:getSize()
         image_bg:addChild(text_title)
         text_title:setPos(left,top)

         local image_sov = new(Image,"res/setting/setting_sov.png")
         image_bg:addChild(image_sov)
         image_sov:setPos(left ,title_h + top + 20)

         local text_sov = new(Text,"solved",nil,nil,kAlignLeft,nil,18,7,65,255)
         image_bg:addChild(text_sov)
         text_sov:setPos(left+40,title_h + top + 25)
         text_sov:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:text_sov_click(text_sov)
                                          end
                                 end)

         local image_unsov = new(Image,"res/setting/setting_unsov.png")
         image_bg:addChild(image_unsov)
         image_unsov:setPos(left+140,title_h + top + 20)

         local text_unsov = new(Text,"unsolved",nil,nil,kAlignLeft,nil,18,7,65,255)
         image_bg:addChild(text_unsov)
         text_unsov:setPos(left+180,title_h + top + 25)
         text_unsov:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:text_unsov_click(text_unsov)
                                          end
                                 end)

         image_bg:setSize(850, 120)
         chat_node:setSize(self.bg_h_, 120 )

    elseif iType == 5 then
         local text_title = new(Text,"this answers can't solved you question ,you can use:",nil,nil,kAlignLeft,nil,18,28,27,28)   
         --留言回复
         local title_w,title_h = text_title:getSize()
         image_bg:addChild(text_title)
         text_title:setPos(left,top)

         local text_msg = new(Text,"message board",nil,nil,kAlignLeft,nil,18,7,65,255)   
         image_bg:addChild(text_msg)
         text_msg:setPos(left + title_w + space*0.5,top)
         text_msg:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerDown and drawing_id_first == drawing_id_current then
                                               self:text_msg_click(text_msg)
                                          end
                                 end)

         image_bg:setSize(850, image_bg_h)
         chat_node:setSize(self.bg_h_, image_bg_h )
    end

    return chat_node

end

--获取反馈历史
function FeedbackPopup:init_board_data()
   self:setLoading(true)
    nk.FeedbackController:getFeedbackData(function(result,content)
          self:setLoading(false)
          if result then
              self.historyList_ = nil 
              self.historyList_ = {}
              self.historyList_ = content
              if #self.historyList_ <= 0 then return end
              nk.DictModule:setInt("gameData", tostring(self.historyList_[1].time), 1)
              self:history_list(self.historyList_)
          end
    end)

end

--提交反馈文字
function FeedbackPopup:feedback(itype,text)
    local params = {}
    params.username = nk.UserDataController.getUserName()
    params.contact = "cell - phone number"
    params.category = itype
    params.title = ""
    params.content = text 
    params.level = nk.UserDataController.getMlevel()

    local noEncode = clone(params)
    --添加到历史记录
    table.insert(self.historyList_, 1, noEncode)

    self:setLoading(true)
    nk.FeedbackController:sendFeedback(params,function(result,content)
         self:setLoading(false)
         self.bt_commit_:setEnable(true)
         local info = content
         if result then
              if info.flag ~= 1 then
                  Log.printInfo("commit feedback faild.")
                  nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                  table.remove(self.historyList_, 1)
              else 
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                self.historyList_[1].time = nk.FeedbackController.time_
                self:history_list(self.historyList_)
                self.editText_:setText("")
                self.text_type_:setText(bm.LangUtil.getText("SETTING", "TYPE"))
                self.type_fb_ = nil
                self.radio_bt_type_:clear()
                if self.picSuccess then
                    self:uploadpic(info.data.fid)
                else
                    self:sendFeedbackSucc()
                end
              end
         end
    end)
end

function FeedbackPopup:sendFeedbackSucc()
    self.iamge_fb_pic_:setVisible(false)
    self.bt_addpic_:setVisible(true)
end

function FeedbackPopup:bt_commit_click()
    local text = self.editText_:getText()
    local filteredText = string.gsub(self.editText_:getText()," ","");
    local len  = string.len(filteredText) 
    if len <= 0 then  
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
        return  
    elseif not self.type_fb_ then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEEDBACK_TYPE"))
        return
    end
    self.bt_commit_:setEnable(false)
    self:feedback(self.type_fb_,self.editText_:getText())
end

--添加图片
function FeedbackPopup:addPic(data)
     if System.getPlatform() == kPlatformWin32  then  return end
     
     self:setLoading(true)
     nk.GameNativeEvent:pickPic(System.getStorageImagePath())
end

--上传反馈图片
function FeedbackPopup:uploadpic(fid)
    local filePath = System.getStorageImagePath()
    local srcFile = filePath .. self.picFilePath

    local method = "attach.upload"
    local gid = GameConfig.FEEDBACK_GID
    local version = GameConfig.CUR_VERSION
    local time = os.time()
    local gkey = "fa09e016e0cc3afebd78952c53b46820"
    local mtkey = gkey
    local sig = md5_string(tostring(gid) .. method .. version .. time .. gkey)
    local params = {}
    params.fid = fid

    local post_data = {}
    post_data.method = method
    post_data.api = 2
    post_data.gid = gid 
    post_data.version = version
    post_data.time = time
    post_data.mtkey = mtkey
    post_data.param = params

    local signature = nk.functions.Joins(post_data, post_data.mtkey)
    post_data.sig = string.lower(md5_string(signature))

    local api = json.encode(post_data)

      http2.request_async({
         url = HttpConfig.FEEDBACK_RUL,
         post = {
                  {
                    type = 'file',
                    filepath = srcFile,
                    name = "icon",
                    file_type = "image/png",
                  },
                  {
                    type = "content",
                    name = "api",
                    contents = api,
                  },
         }
       },
         function(rsp)
            if rsp.errmsg then              
                Log.printInfo("FeedbackPopup", "upload picture faild !")
                Log.dump(rsp)
            else
                Log.printInfo("FeedbackPopup", "upload picture success !")
                self:sendFeedbackSucc()
            end
         end
        )
end

--添加图片返回
function FeedbackPopup:pickPictureCallBack(status, data)
    self:setLoading(false)
    if status then
        Log.printInfo("FeedbackPopup","filepath = " .. data )

        self.picSuccess = true
        self.picFilePath = data

        if self.image_uploadPic_ then
             self.iamge_fb_pic_:removeChild(self.image_uploadPic_)
             self.image_uploadPic_ = nil
        end

        local setImageSize = function(width, height, image)
            local w,h = image:getSize()
            local sX = width / w
            local sY = height/ h
            local scale = math.min(sX, sY)
            image:addPropScaleSolid(1,scale,scale,kCenterDrawing)
        end
        self.image_uploadPic_ = new(Image, self.picFilePath)
        setImageSize(self.uploadPicWidth_, self.uploadPicHeight_, self.image_uploadPic_)
        self.image_uploadPic_:setAlign(kAlignCenter)
        self.iamge_fb_pic_:addChild(self.image_uploadPic_)
        self.iamge_fb_pic_:setVisible(true)
        self.bt_addpic_:setVisible(false)
    end
end


function FeedbackPopup:show_table()
    self.view_self_service_:setVisible(self.page_index_ == 1)
    self.view_msg_board_:setVisible(self.page_index_ == 2)
end

function FeedbackPopup:type_text_click()
    self.showType_ = not self.showType_

    self.image_type_:setVisible(self.showType_)
end

function FeedbackPopup:radio_bt_click(index)
    self.showType_ = false
    self.image_type_:setVisible(false)
    self.text_type_:setText(self.text_type_list_[index]:getText())
    self.type_fb_ = index
end

function FeedbackPopup:text_first_click(node, data)
   local info = data

   if node.bfirst_ then return  end
      
   node.bfirst_ = true
   node:setColor(255,0,0)

   if info.question then
      local node = self:chat_item(info.question,2,info.name)
      self.scrollview_chat_:addChild(node)
   else
      local node1 = self:chat_item(info.answers, 3)
      self.scrollview_chat_:addChild(node1)

      local node2 = self:chat_item("", 4)
      self.scrollview_chat_:addChild(node2)
    end
    self.scrollview_chat_:gotoBottom()
end

function FeedbackPopup:text_second_click(node, data)
   local info = data

   if node.bsecond_ then return  end
      
   node.bsecond_ = true
   node:setColor(255,0,0)

   local node1 = self:chat_item(info.answers, 3)
   self.scrollview_chat_:addChild(node1)

   local node2 = self:chat_item("", 4)
   self.scrollview_chat_:addChild(node2)
   self.scrollview_chat_:gotoBottom()
end

function FeedbackPopup:text_sov_click(node, data)
    if node.bsov_ then return end
    node.bsov_ = true
    node:setColor(255,0,0)

    local node = self:chat_item("very happy", 3)
    self.scrollview_chat_:addChild(node)
    self.scrollview_chat_:gotoBottom()
end

function FeedbackPopup:text_unsov_click(node, data)
   if node.bunsov_ then return end
   node.bunsov_ = true
   node:setColor(255,0,0)

   local node = self:chat_item("", 5)
   self.scrollview_chat_:addChild(node)
   self.scrollview_chat_:gotoBottom()
end

function FeedbackPopup:text_msg_click(node, data)
   if node.bmsg_ then return end
   node.bmsg_ = true
   node:setColor(255,0,0)

   self:board_text_click()
end

function FeedbackPopup:service_text_click()
    if self.page_index_ == 1 then return end

    if not self.serviceInit then
       self.serviceInit = true
       self:init_qustion_data()
    end
    
    self.page_index_ = 1
    nk.FeedbackController.tab_ = 1
    self.text_self_service_:setColor(255,255,255)
    self.text_msg_board_:setColor(42,86,174)

    self:show_table()
end

function FeedbackPopup:init_qustion_data()
  local data = nk.FeedbackController:getQuestionConfig()
  if data then
     local node = self:chat_item(data,1)
     self.scrollview_chat_:addChild(node)
  end
end

function FeedbackPopup:board_text_click()
    if self.page_index_ == 2 then return end

    self:init_board_data()

    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
    datas["fbTabPoint"] = false

    self.page_index_ = 2
    nk.FeedbackController.tab_ = 2
    self.text_self_service_:setColor(42,86,174)
    self.text_msg_board_:setColor(255,255,255)
    
   self:show_table()
end

function FeedbackPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function FeedbackPopup:feedbackPoint(flag)
    if flag then
        if self.page_index_ ~= 2 then
            self.image_fb_redPoint_:setVisible(flag)
        else
            self:init_board_data()
            local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
            datas["fbTabPoint"] = false
        end
    else
        self.image_fb_redPoint_:setVisible(flag)
    end
end

function FeedbackPopup:close_bt_click()
    self:hide()
end

function FeedbackPopup:dtor()
    Log.printInfo("FeedbackPopup.dtor");
    nk.HornTextRotateAnim.setupScene(self.beforeScene)
    EventDispatcher.getInstance():unregister(EventConstants.PickPictureCallBack, self, self.pickPictureCallBack)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "fbTabPoint", self.feedbackObserver_)
    nk.FeedbackController:unregister()
end 




return FeedbackPopup