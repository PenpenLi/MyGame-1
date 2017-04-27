
local view = require(VIEW_PATH .. "chat.friend_chat_view")
local varConfigPath = VIEW_PATH .. "chat.friend_chat_view_layout_var"

local FriendDataManager = require("game.friend.friendDataManager") 
local FriendsItem = require("game.chat.layers.friendsItem")
local expressionConfig = import("game.roomGaple.config.expressionConfig")

local recordNum = 100  -- 记录最多保存100条
local intervalTime = 600

local FriendsChatItem = require("game.chat.layers.friendsChatItem")

local ExpressionsItem = require("game.roomChat.layers.expressionsItem")

local FriendsChatLayer = class(GameBaseLayer, false)

local exp_btn_image = {
    [1]  = {"res/roomChat/roomChat_exp_default_selected.png","res/roomChat/roomChat_exp_default_normal.png"},
    [2]  = {"res/roomChat/roomChat_exp_punakawan_selected.png","res/roomChat/roomChat_exp_punakawan_normal.png"},
    [3]  = {"res/roomChat/roomChat_vipBt_selected.png","res/roomChat/roomChat_vipBt_normal.png"},
}

function FriendsChatLayer:ctor(mid)
	Log.printInfo("FriendsChatLayer.ctor");
	super(self, view, varConfigPath)

	Log.printInfo("FriendsChatLayertor", self.m_root:getSize())

	self:setSize(self.m_root:getSize());

	-- 加载好友列表
    self.m_isGetFriendList_ing = false
    self.chatRecordData = {}

    self.chatContentData = {}
    self.headIconIds = {}
    self.lastChatRecordTime = 0
    self.send_id = 0
    self.m_goToMid = mid

	self:initScene()
    self.m_LoadingAnim = new(nk.LoadingAnim)
	self.m_friendDataManager = FriendDataManager.getInstance()
	-- self:loadFriendData()
end

function FriendsChatLayer:setDelegate(obj,fun)
    self.m_obj = obj
    self.m_fun = fun
end

function FriendsChatLayer:initScene()
	self:initFriendView()
	self:initChatView()
	self:initNoFriendView()
	self:initFirstChatTips()
    self:initExpressionview()
end

function FriendsChatLayer:initFriendView()
	self.m_friend_view = self:getUI("friend_view")
	self.m_friend_online_num = self:getUI("friend_online_num")
	self.m_friend_List_view = self:getUI("friend_List_view")
	self.m_friend_view:setVisible(false)
end

function FriendsChatLayer:initChatView()
	self.m_chat_view = self:getUI("chat_view")
	self.m_chat_msg_view = self:getUI("chat_msg_list_view")
	self.m_chat_view:setVisible(false)

	self.m_chat_msg = self:getUI("chat_msg")
    self.m_chat_msg:setMaxLength(50) 
	self.m_chat_msg:setOnTextChange(self,self.onEditBoxChange)
	self.m_chat_msg:setHintText(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG"),155,155,155)
end

function FriendsChatLayer:initNoFriendView()
	self.m_no_friend_view = self:getUI("no_friend_view")
	self.m_no_friend_tips = self:getUI("no_friend_tips")
    self.m_no_friend_tips:setText(bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP1"))
	self.m_no_friend_view:setVisible(false)
    self.m_fast_add_friend_btn = self:getUI("fast_add_friend_btn")
    self.m_fast_add_friend_btn:setVisible(not nk.isInRoomScene)
    self.m_fast_add = self:getUI("fast_add")
    self.m_fast_add:setText(bm.LangUtil.getText("FRIEND", "FAST_ADD"))
end

function FriendsChatLayer:initFirstChatTips()
	self.m_first_chat_tips = self:getUI("first_chat_tips")
	self.m_first_chat_tips:setVisible(false)
    self.m_first_chat_tips:setText(bm.LangUtil.getText("FRIEND", "CHOOSE_TALK"))
end

function FriendsChatLayer:initExpressionview()
    self.m_expression_view = self:getUI("expression_view")
    self.m_expression_view:setVisible(false)
    self.m_expScroller_view = self:getUI("exp_scroller_view")
    
    self.m_normalExp_btn = self:getUI("exp_btn")
    self.m_normalExp_btn:addPropScaleSolid(0, 0.8, 0.8, kCenterDrawing)
    self.m_punakawan_btn = self:getUI("punakawan_btn")
    self.m_punakawan_btn:addPropScaleSolid(0, 0.8, 0.8, kCenterDrawing)
    self.m_vip_btn = self:getUI("vip_btn")
    self.m_vip_btn:addPropScaleSolid(0, 0.8, 0.8, kCenterDrawing)

    self.m_exp_view_mask = self:getUI("exp_view_mask")
    self.m_exp_view_mask:setVisible(false)
    self.m_exp_view_mask:setEventDrag(self,function() end);
    self.m_exp_view_mask:setEventTouch(self,function() end);

    self.m_not_vip_tips = self:getUI("not_vip_tips")
    self.m_not_vip_tips:setText(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_NOTVIP_TIPS"))
    
    self.m_become_vip_text = self:getUI("become_vip_text")
    self.m_become_vip_text:setText(bm.LangUtil.getText("STORE", "VIP_BE_VIP"))

    self.m_expBtnTable = {}
    table.insert(self.m_expBtnTable,self.m_normalExp_btn)
    table.insert(self.m_expBtnTable,self.m_punakawan_btn)
    table.insert(self.m_expBtnTable,self.m_vip_btn)
end

function FriendsChatLayer:setIsVisible(visible)
    self.m_setIsVisible = visible
end

function FriendsChatLayer:loadFriendData()
	if self.m_isGetFriendList_ing then  
        return
    end
    self.m_LoadingAnim:addLoading(self.m_root)
    self.m_LoadingAnim:onLoadingStart()
    self.m_isGetFriendList_ing = true
    self.m_friendDataManager:loadFriendData(handler(self, function(obj, status, data)
    		self.m_LoadingAnim:onLoadingRelease()
            self.m_isGetFriendList_ing = false
            if status and data and #data > 0 then
                local adapter = new(CacheAdapter, FriendsItem, data);
				self.m_friend_List_view:setAdapter(adapter);
				self.m_friend_List_view:setOnItemClick(self, self.onFriendListItemClick)

                local goToIndex = self:getViewIndexByMid(adapter)
                self.m_needJump = goToIndex >= 5
                self:onFriendListItemClick(adapter,nil,goToIndex,nil,nil)

				self.m_friend_view:setVisible(true)
            else
            	self.m_no_friend_view:setVisible(true)
            end
        end))
end

function FriendsChatLayer:updataView()
	self:loadFriendData()
end

function FriendsChatLayer:getViewIndexByMid(adapter)
    local index = 1
    for i,data in ipairs(adapter.m_data) do
        if tonumber(data.mid) == tonumber(self.m_goToMid) then
            index = i
            break
        end
    end
    return index
end

function FriendsChatLayer:onFriendListItemClick(adapter,view,index,viewX,viewY)
    Log.printInfo("onFriendListItemClick", index, viewX, viewY)
    self.m_first_chat_tips:setVisible(false)
    self.m_expression_view:setVisible(false)
    self.lastChatRecordTime = 0
    local online = 0
    if not self.m_curChatData or self.m_curChatData ~= adapter.m_data[index] then
        adapter.m_data[index].isSelected = true
        self.m_curChatData = adapter.m_data[index]
        self.m_chat_view:setVisible(true)
        local mid = tonumber(self.m_curChatData.mid)
    	self.chatRecordData[mid] = {}
    	self:readChatRecord(mid)
    	self:refreshListHandler_(mid)
        for i,data in ipairs(adapter.m_data) do
            data.isSelected = (i == index)
            if data.roomid and data.roomid >= 0 then
                online = online + 1
            end
        end

        local online_str = string.format("Teman (%d/%d)",online,#adapter.m_data)
        if self.m_friend_online_num.m_res then
            self.m_friend_online_num:setText(online_str)
        end

        if self.m_needJump then
            local ad = new(CacheAdapter, FriendsItem, adapter.m_data);
            self.m_friend_List_view:setAdapter(ad)
            self.m_friend_List_view:setShowingIndex(index)
            self.m_needJump = false
        end

    end
    if self.m_curChatData then
        local mid = tonumber(self.m_curChatData.mid)
        EventDispatcher.getInstance():dispatch(EventConstants.talkingWithWho, mid)
    end

end

function FriendsChatLayer:addItemView(mid)
    if self.m_chat_msg_list_view then
        self.m_chat_msg_list_view:removeAllChildren()
        self.m_chat_msg_list_view:removeFromParent(true)
        delete(self.m_chat_msg_list_view)
        self.m_chat_msg_list_view = nil
    end

    self.m_chat_msg_list_view = new(ScrollView, 0, 0, 450, 315, false)
    self.m_chat_msg_list_view:setAlign(kAlignTop)
    self.m_chat_view:addChild(self.m_chat_msg_list_view)

    -- 未读消息
    local j = 0
    for i = 1,#nk.userData.chatRecord do
        if  i - j > 0 then
            i = i - j
        end
        local data = nk.userData.chatRecord[i]
        if data and tonumber(data.send_uid) == tonumber(self.m_curChatData.mid) then
            local record = {}
            record.msg = data.msg
            record.time = data.time
            record.msg_type = data.type
            record.kind = 2
            if #self.chatRecordData[mid] >recordNum then
                table.remove(self.chatRecordData[mid],1)
            end
            table.insert(self.chatRecordData[mid],record)
            table.removebyvalue(nk.userData.chatRecord,data)
            j = j + 1
        end
    end

    local micon = self:getFriendsMiconByMid(mid)

    local pos_x, pos_y = 0, 0
    for index, data in ipairs(self.chatRecordData[mid]) do
        local item = nil
        item = new(FriendsChatItem, data, index, micon)

        if self.lastChatRecordTime~=0 and data.time - self.lastChatRecordTime > intervalTime then
            local text_h = 30
            local text_time = new(Text, os.date("%m-%d %H:%M",data.time), 0, text_h, kAlignCenter, nil, 14, 250, 230, 255)
            text_time:setAlign(kAlignTop)
            self.m_chat_msg_list_view:addChild(text_time)
            text_time:setPos(0, pos_y)
            pos_y = pos_y + text_h
        end

    	if item then
	        local width, height = item:getSize()
	        item:setPos(pos_x, pos_y)
	        self.m_chat_msg_list_view:addChild(item)
	        pos_y = pos_y + height
	    end

        self.lastChatRecordTime = data.time
    end

    -- 暂时放在这里
    self:saveChatRecord(mid)
    -- 更新未读记录
    nk.functions.updataChatRecord()
end

function FriendsChatLayer:refreshListHandler_(mid)
    self:addItemView(mid)
    self.m_chat_msg_list_view:gotoBottom()
end

-- 点击输入框
function FriendsChatLayer:onEditBoxChange()
	local content = nk.functions.keyWordFilter(self.m_chat_msg:getText())
	if content ~= text then
        self.m_chat_msg:setText(content)
    end
    self.editbox_text = string.trim(self.m_chat_msg:getText())
end

-- 点击表情按钮
function FriendsChatLayer:onFExpressionBtnClick()
    self.m_expType = 0
    if not self.m_expression_view:getVisible() then
        self.m_expression_view:setVisible(true)
    	self:onNormalExpBtnClick()
    else
        self.m_expression_view:setVisible(false)
    end
end

function FriendsChatLayer:onNormalExpBtnClick()
    if not (self.m_expType == 1) then
        self.m_expType = 1
        self:setExpBtnStatus()
        self:createExpList(27,0,0.9,0,0)
    end
end

function FriendsChatLayer:onPunakawanBtnClick()
    if not (self.m_expType == 2) then
        self.m_expType = 2
        self:setExpBtnStatus()
        self:createExpList(18,100,1,0,0)
    end
end

function FriendsChatLayer:onVipBtnClick()
    if not (self.m_expType == 3) then
        self.m_expType = 3
        self:setExpBtnStatus()
        self:createExpList(10,200,1,0,0)
    end
end

function FriendsChatLayer:setExpBtnStatus()
    for i,btn in ipairs(self.m_expBtnTable) do
        local file = exp_btn_image[i]
        if self.m_expType == i then
            btn:setFile(file[1])
        else
            btn:setFile(file[2])
        end
    end
end

function FriendsChatLayer:createExpList(expNum,startIdIndex,expScale,offStartPosX,offStartPosY)
    local x, y = offStartPosX,offStartPosY
    local item_w, item_h = 100, 100
    self.m_expScroller_view:removeAllChildren()
    self.m_expScroller_view.m_nodeH = 0
    for i=1,expNum do
        local expItem = new(ExpressionsItem,startIdIndex,i,expScale)

        x = (i+3)%4*item_w + offStartPosX
        y = math.floor((i-1)/4)*item_h + offStartPosY

        expItem:setPos(x,y)
        self.m_expScroller_view:addChild(expItem)
        expItem:setDelege(self,self.onExpItemClicked)
    end

    self.m_exp_view_mask:setVisible(false)
    if self.m_expType == 3 and not(nk.userData.vip and tonumber(nk.userData.vip) > 0) then
        self.m_exp_view_mask:setVisible(true)
    end
end

function FriendsChatLayer:onExpItemClicked(expId)
    Log.printInfo("expId = ",expId)
    self.m_expression_view:setVisible(false)
    local ExpressionConfig = new(expressionConfig)
    local signOfExpId = ExpressionConfig:getSignById(tonumber(expId))
    self:formatMsg(signOfExpId,2)
end


-- 点击发送聊天消息按钮
function FriendsChatLayer:onFChatSendBtnClick()
	if self.editbox_text and self.editbox_text ~= "" then
        self:formatMsg(self.editbox_text,1)
	end
	self.m_chat_msg:setText("")
    self.editbox_text = ""
end

function FriendsChatLayer:formatMsg(msg,msg_type)
    self.send_id = self.send_id + 1
    local record = {}
    record.msg = msg
    record.time = os.time()
    record.kind = 1
    record.msg_type = msg_type
    local mid = tonumber(self.m_curChatData.mid)
    if #self.chatRecordData[mid] > recordNum then
        table.remove(self.chatRecordData[mid],1)
    end
    table.insert(self.chatRecordData[mid],record)
    self.chatContentData[self.send_id] = record
    self:refreshListHandler_(mid)
    nk.SocketController:sendFriendChatMsg(nk.userData.mid,self.m_curChatData.mid,msg,self.send_id,msg_type)
end

-- 收到好友消息
function FriendsChatLayer:praseReceiveFriendMsg(data)
    if data then
        if data and self.m_curChatData and tonumber(data.send_uid) == tonumber(self.m_curChatData.mid) then
        	table.removebyvalue(nk.userData.chatRecord,data)
            if tonumber(data.recv_uid) == tonumber(nk.userData.mid) then
	            local record = {}
	            record.msg = data.msg
	            record.time = data.time
	            record.kind = 2
                record.msg_type = data.type
	            local mid = tonumber(self.m_curChatData.mid)
	            if self.chatRecordData[mid] and #self.chatRecordData[mid] >recordNum then
	                table.remove(self.chatRecordData[mid],1)
	            end
	            table.insert(self.chatRecordData[mid],record)
                -- if not self.m_setIsVisible then
	               self:refreshListHandler_(mid)
                -- end
	        end
        end
    end
end

-- 点击立即添加按钮
function FriendsChatLayer:onFastAddFriendBtnClick()
    StateMachine.getInstance():pushState(States.Friend, nil, nil, 2)
end

function FriendsChatLayer:saveChatRecord(mid)
    if #self.chatRecordData[mid]<1 then
        return
    end
    local friendName = string.format("friendChatRecord_%d", mid)
    nk.DictModule:setString(friendName,nk.cookieKeys.FRIEND_CHAT_RECORD, json.encode(self.chatRecordData[mid]))
    nk.DictModule:saveDict(friendName)
end

function FriendsChatLayer:readChatRecord(mid)
    local friendName = string.format("friendChatRecord_%d", mid)
    local chatRecord = nk.DictModule:getString(friendName,nk.cookieKeys.FRIEND_CHAT_RECORD, "")
    if chatRecord ~= "" then
    	chatRecord = json.decode(chatRecord) or {}
    	for k,data in pairs(chatRecord) do
    		table.insert(self.chatRecordData[mid],data)
    	end
    end
end


function FriendsChatLayer:getFriendsMiconByMid(mid)
    self.m_friendData = self.m_friendDataManager:getFriendsData()
    local micon = ""
    for i,friendData in ipairs(self.m_friendData) do
        if tonumber(friendData.mid) == tonumber(mid) then
            micon = friendData.micon
            break
        end
    end
    return micon
end

function FriendsChatLayer:onBecomeVipBtnClick()
    local StorePopup = require("game.store.popup.storePopup")
    nk.payScene = consts.PAY_SCENE.HALL_CHAT_PAY
    nk.PopupManager:addPopup(StorePopup)
    if self.m_obj and self.m_fun then
        self.m_fun(self.m_obj)
    end
end

function FriendsChatLayer:dtor()
	-- body
end

FriendsChatLayer.s_eventHandle = 
{
    [EventConstants.recFriendMsgInChatpopup] = FriendsChatLayer.praseReceiveFriendMsg,
};

return FriendsChatLayer