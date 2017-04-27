-- MessagePopup.lua
-- Last modification : 2016-07-16
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local ListViewEx = require("game/uiex/listView/listViewEx")
local MessageListItem = require("game/message/messageListItem")
local messageView = require(VIEW_PATH .. "message/message_layer")
local messageInfo = VIEW_PATH .. "message/message_layer_layout_var"
local MessagePopup= class(PopupModel);

-- message model
MessagePopup.modelData = nil
-- system notice data
MessagePopup.noticeData = nil

MessagePopup.SYS_MESSAGE     = 1
MessagePopup.SYS_NOTICE      = 2
MessagePopup.FRIEND          = 3

function MessagePopup.show(data)
	PopupModel.show(MessagePopup, messageView, messageInfo, {name="MessagePopup"}, data)
end

function MessagePopup.hide()
	PopupModel.hide(MessagePopup)
end

function MessagePopup:ctor(viewConfig)
	Log.printInfo("MessagePopup.ctor")
    self:addShadowLayer()
    self.selectMsg_ = {}

    --隐藏大厅红点
    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE)
    if datas then
        datas["MsgMainPoint"] = false
    end

    self:init_widget()   
end 

function MessagePopup:onShow()
    self:EventAndObserver()
    self:init_data()  
end

function MessagePopup:EventAndObserver()
    EventDispatcher.getInstance():register(EventConstants.messageCheckbox, self, self.messageCheckbox)
    EventDispatcher.getInstance():register(EventConstants.messageGetRward, self, self.setLoading)
    self.SysMsgPointDataObserver_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "sysMsgPoint", handler(self, self.onSysMsgPoint))
    self.SysNoticePointDataObserver_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "sysNoticePoint", handler(self, self.onSysNoticePoint))
    self.FriendMsgPointDataObserver_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.NEW_MESSAGE, "friendMsgPoint", handler(self, self.onFriendMsgPoint))
end

function MessagePopup:init_widget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)
    self.radio_bt_group_ = self:getUI("RadioButtonGroup")
    self.radio_bt_group_:setOnChange(self,self.radio_bt_click) 

    self.text_l = self:getUI("Text_l")
    self.text_l:setText(bm.LangUtil.getText("MESSAGE","TAB_TEXT")[1])
    self.text_m = self:getUI("Text_m")
    self.text_m:setText(bm.LangUtil.getText("MESSAGE","TAB_TEXT")[2])
    self.text_r = self:getUI("Text_r")
    self.text_r:setText(bm.LangUtil.getText("MESSAGE","TAB_TEXT")[3])

    self.listview_sys_ = new(ListViewEx,{x = 0,y =0,w= 680,h = 320},MessageListItem)
    self.listview_sys_:setPos(15,90)
    self.image_bg_:addChild(self.listview_sys_)

    self.listview_friend_ = new(ListViewEx,{x = 0,y =0,w= 680,h = 320},MessageListItem)
    self.listview_friend_:setPos(15,90)
    self.image_bg_:addChild(self.listview_friend_)

    self.scrollview_notice_ = new(ScrollView,0,0,680,400,true)
    self.scrollview_notice_:setPos(15,90)
    self.image_bg_:addChild(self.scrollview_notice_)  

    self.view_delete_ = self:getUI("Image_delete")
    self.view_delete_:setVisible(false)
    self:getUI("Text_tip"):setText(bm.LangUtil.getText("MESSAGE","NUM"))

    self.checkbox_all_ = new(CheckBox,{"res/userInfo/userInfo_uchosed.png","res/userInfo/userInfo_choosed.png"})
    self.image_bg_:addChild(self.checkbox_all_)
    self.checkbox_all_:setOnChange(self,self.checkbox_click)
    self.checkbox_all_:setPos(30,30)
    self.checkbox_all_:setVisible(false)

    self.bt_delete_ = self:getUI("Button_delete")
    self.bt_delete_:setOnClick(self,self.bt_delete_click)
    self.text_delete_ = self:getUI("Text_delete")
    self.text_delete_:setText(bm.LangUtil.getText("COMMON","DELETE"))
    
    self.bt_cancel_ = self:getUI("Button_cancel")
    self.bt_cancel_:setOnClick(self,self.bt_cancel_click)
    self.text_cancel_ = self:getUI("Text_cancel")
    self.text_cancel_:setText(bm.LangUtil.getText("COMMON","CANCEL"))

    self.bt_sure_ = self:getUI("Button_sure")
    self.bt_sure_:setOnClick(self,self.bt_sure_click)
    self.text_sure_ = self:getUI("Text_sure")
    self.text_sure_:setText(bm.LangUtil.getText("COMMON","DELETE_SURE"))

    self.text_none_tip_ = self:getUI("Text_none")
    self.text_none_tip_:setVisible(false) 

    self.image_sysMsg_point_ = self:getUI("Image_sysMsg_point")
    self.image_sysNotice_point_ = self:getUI("Image_sysNotice_point")
    self.image_friend_point_ = self:getUI("Image_friend_point")

end

function MessagePopup:init_data()
    self.tabIndex_ = 1
    nk.messageController:set_tab(self.tabIndex_)
    local data= nk.DataProxy:getData(nk.dataKeys.USER_DATA)

    if data and data.MessageShowTap then
        if data.MessageShowTap ~= 0 then
            if data.MessageShowTap == 1 then
                self.tabIndex_ = 2
                self:request_message_model()
            elseif data.MessageShowTap == 2 then
                self.tabIndex_ = 1
                self:request_system_notice()
            elseif data.MessageShowTap == 3 then
                self.tabIndex_ = 1
                self:request_system_notice()
            end
        end
    end
    self.radio_bt_group_:setSelected(self.tabIndex_)
    self:table_change(self.tabIndex_)
end

function MessagePopup:table_change(selectedTab)
    local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
    if selectedTab == MessagePopup.SYS_MESSAGE then
        --系统消息
        datas["sysMsgPoint"] = false
        self:request_message_model()
    elseif selectedTab == MessagePopup.SYS_NOTICE then
        --系统公告
         datas["sysNoticePoint"] = false
         nk.DictModule:setInt("gameData", nk.cookieKeys.SYSTEM_NOTICE_READ, 1)
        self:request_system_notice()
    elseif selectedTab == MessagePopup.FRIEND then
        --好友消息
        datas["friendMsgPoint"] = false
        self:request_message_model()
    end

    self:show_view(selectedTab)
end

function MessagePopup:show_view(selectedTab)
    if self.listview_sys_ then self.listview_sys_:setVisible(selectedTab == MessagePopup.SYS_MESSAGE) end
    if self.listview_friend_ then self.listview_friend_:setVisible(selectedTab == MessagePopup.FRIEND) end
    if self.scrollview_notice_ then self.scrollview_notice_:setVisible( selectedTab == MessagePopup.SYS_NOTICE) end
    self.view_delete_:setVisible(not(selectedTab == 2))
    self:resetBt()
    self.text_none_tip_:setVisible(false)
end

function MessagePopup:onSysMsgPoint(flag)
    if flag then
        if nk.messageController.noNeedClear_ then
            nk.messageController.noNeedClear_ = nil
        else
            nk.messageController.messageData = nil
        end
        if self.tabIndex_ ~= 1 then
            self.image_sysMsg_point_:setVisible(flag)
        else
            self:request_message_model()
            local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
            datas["sysMsgPoint"] = false
        end
    else
        self.image_sysMsg_point_:setVisible(flag)
    end
end

function MessagePopup:onSysNoticePoint(flag)
    if flag then
        if self.tabIndex_ ~= 2 then
            self.image_sysNotice_point_:setVisible(flag)
        else
            local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
            datas["sysNoticePoint"] = false
        end
    else
        self.image_sysNotice_point_:setVisible(flag)
    end
end

function MessagePopup:onFriendMsgPoint(flag)
    if flag then
        if nk.messageController.noNeedClear_ then
            nk.messageController.noNeedClear_ = nil
        else
            nk.messageController.messageData = nil
        end
        if self.tabIndex_ ~= 3 then
            self.image_friend_point_:setVisible(flag)
        else
            self:request_message_model()
            local datas = nk.DataProxy:getData(nk.dataKeys.NEW_MESSAGE) or {}
            datas["friendMsgPoint"] = false
        end
    else
        self.image_friend_point_:setVisible(flag)
    end
end

function MessagePopup:request_system_notice()
    self:setLoading(true)
    nk.messageController:request_system_notice(function(result,content)
       self:setLoading(false)
       if result then
           self.text_none_tip_:setVisible(false)
           local info = content
           if #info <=0 then
               self.text_none_tip_:setVisible(true)
               self.text_none_tip_:setText(bm.LangUtil.getText("MESSAGE","NONE_NOTICE"))
           else
               self.scrollview_notice_:removeAllChildren()
               for i=1,#info do
                   self.scrollview_notice_:addChild(self:noticeItem(info[i]))
               end
           end
       end
    end)

end

function MessagePopup:noticeItem(info)
    local node = new(Node)
    
    local text_title = new(Text,info.title,nil,nil,nil,nil,22,255,255,255)
    node:addChild(text_title)
    text_title:setAlign(kAlignTop)
    text_title:setPos(0,15)
    local _,h_title = text_title:getSize()

    local text_content = new(TextView,info.content,600,nil,kAlignTopLeft,"",22,255,255,255)
    node:addChild(text_content)
    text_content:setPos(30,h_title+30)
    local _,h_content = text_content:getSize()

    node:setSize(680, h_title+h_content +60 )

    return node
end

function MessagePopup:request_message_model()
   self:setLoading(true)
   nk.messageController:request_message_model(handler(self,function(obj,result, content)
       self:setLoading(false)
       if result then
           local info = content
           self:setView(info)
       end
   end))         
end

function MessagePopup:radio_bt_click(index)
    self.selectMsg_ = nil
    self.selectMsg_ = {}
    self.tabIndex_ = index
    nk.messageController:set_tab(self.tabIndex_)
    self:table_change(index)   
end

function MessagePopup:setView(info)
    if not self.text_none_tip_.m_res or not info then return end
    
     if self.tabIndex_ == 1 then
     --系统消息
        if #info <=0 then
            self.text_none_tip_:setVisible(true)
            self.text_none_tip_:setText(bm.LangUtil.getText("MESSAGE","NONE_SYS_MSG"))
            self.listview_sys_:setData(nil)
        else
            self.text_none_tip_:setVisible(false)
            self.listview_sys_:setData(nil)
            self.listview_sys_:setData(info)
        end  
     else
     --好友消息
        if #info <=0 then
            self.text_none_tip_:setVisible(true)
            self.text_none_tip_:setText(bm.LangUtil.getText("MESSAGE","NONE_FRIEND"))
            self.listview_friend_:setData(nil)
        else
            self.text_none_tip_:setVisible(false)
            self.listview_friend_:setData(nil)
            self.listview_friend_:setData(info)
        end  
     end
end

function MessagePopup:bt_delete_click()
    if self.tabIndex_ == 1 then
        if not self.listview_sys_:getData() or #self.listview_sys_:getData() <= 0 then return end
    else
        if not self.listview_friend_:getData() or #self.listview_friend_:getData() <=0 then return end
    end
    self.bt_delete_:setVisible(false)
    self.bt_sure_:setVisible(true)
    self.bt_cancel_:setVisible(true)
    self.checkbox_all_:setVisible(true)
    self.checkbox_all_:setChecked(false)
    if self.tabIndex_ == 1 then
        self.listview_sys_:changeItem(2)
    else
        self.listview_friend_:changeItem(2)
    end
end

function MessagePopup:bt_cancel_click()
    self:resetBt()
    if self.tabIndex_ == 1 then
        self.listview_sys_:changeItem(1)
    else
        self.listview_friend_:changeItem(1)
    end
end

function MessagePopup:resetBt()
    self.bt_delete_:setVisible(true)
    self.bt_sure_:setVisible(false)
    self.bt_cancel_:setVisible(false)
    self.checkbox_all_:setChecked(false)
    self.checkbox_all_:setVisible(false)
end

function MessagePopup:bt_sure_click()
    local num = #self.selectMsg_
    if num <=0 then return end

    local param = {}
    param.id = self.selectMsg_
    param.flag = 1
    self:setLoading(true)
    nk.messageController:delete_message(param,function(result,content)
       self:setLoading(false)
       if result then
           local  listData = nil
           if self.tabIndex_ == 1 then
               listData = self.listview_sys_:getData()
           else
               listData = self.listview_friend_:getData()
           end

           for i,v in ipairs(self.selectMsg_) do
               for j = #listData, 1,-1 do
                   if v == listData[j].a then
                       table.remove(listData,j)
                   end
               end
           end
           self:setView(listData)
           self.selectMsg_ = nil
           self.selectMsg_ = {}
           self:resetBt()
       end
    end)
end

function MessagePopup:checkbox_click(check)
    self.selectMsg_ = nil
    self.selectMsg_ = {}
    if self.tabIndex_ == 1 then
        self.listview_sys_:setCheck(check)
        if check then
            for i,v in ipairs(self.listview_sys_:getData()) do
               table.insert(self.selectMsg_, v.a)
            end        
        end
    else
        self.listview_friend_:setCheck(check)
        if check then
            for i,v in ipairs(self.listview_friend_:getData()) do
               table.insert(self.selectMsg_, v.a)
            end        
        end
    end
end

function MessagePopup:messageCheckbox(check,id)
    if check then
        table.insert(self.selectMsg_,id)
    else
        for i,v in ipairs(self.selectMsg_) do
           if v == id then table.remove(self.selectMsg_,i) end
        end  
    end
end

function MessagePopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.image_bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function MessagePopup:DisEventAndObserver()
    EventDispatcher.getInstance():unregister(EventConstants.messageCheckbox, self, self.messageCheckbox)
    EventDispatcher.getInstance():unregister(EventConstants.messageGetRward, self, self.setLoading)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "sysMsgPoint", self.SysMsgPointDataObserver_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "sysNoticePoint", self.SysNoticePointDataObserver_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.NEW_MESSAGE, "friendMsgPoint", self.FriendMsgPointDataObserver_)
end

function MessagePopup:dtor()
    Log.printInfo("MessagePopup.dtor");
    self:DisEventAndObserver()
    nk.messageController.friendMsgTip_ = 0
    nk.messageController.sysMsgTip_ = 0
    nk.messageController.messageData = nil
end 


return MessagePopup