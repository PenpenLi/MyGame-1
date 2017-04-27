
local PopupModel = import('game.popup.popupModel')
local RoomChatPopupLayer = require(VIEW_PATH .. "roomChat.roomChat_pop")
local varConfigPath = VIEW_PATH .. "roomChat.roomChat_pop_layout_var"
local Gzip = require('core/gzip')
local WAndFChatPopup = require("game.chat.wAndFChatPopup")

local ChatMsgShortcutListItem = require("game.roomChat.layers.chatMsgShortcutListItem")
local ExpressionsItem = require("game.roomChat.layers.expressionsItem")

local PropManager = require("game.store.prop.propManager")

local expCost = 0

local roomCostConf

local exp_btn_image = {
    [1]  = {"res/roomChat/roomChat_exp_default_selected.png","res/roomChat/roomChat_exp_default_normal.png"},
    [2]  = {"res/roomChat/roomChat_exp_punakawan_selected.png","res/roomChat/roomChat_exp_punakawan_normal.png"},
    [3]  = {"res/roomChat/roomChat_vipBt_selected.png","res/roomChat/roomChat_vipBt_normal.png"},
}

local RoomChatPopup = class(PopupModel)

function RoomChatPopup.show(...)
	PopupModel.show(RoomChatPopup, RoomChatPopupLayer, varConfigPath, {name="RoomChatPopup", defaultAnim=false}, ...)
end

function RoomChatPopup.hide()
	PopupModel.hide(RoomChatPopup)
end

function RoomChatPopup:ctor(viewConfig, varConfigPath, ctx, roomType)
	self.m_leftViewIndex = 0  -- 1,表情 2,常用语 3,好友 4,聊天记录
	self.m_TopViewIndex = 0   -- 1,普通表情 2，本土表情 3，vip表情
	self.m_talkMode = 1  --1普通聊天，2喇叭
    self.laBaUseNumber_ = 0
	self.m_ctx = ctx
    self.m_roomType = roomType
    self:addShadowLayer()
	self:initScene()
	self:onFaceBtnClick()
	self:updateLaBaData()
    self:onOpTypeBtnClick()

	local roomId = tostring(self.m_ctx.model.roomInfo.roomType) 
    roomCostConf = self.m_ctx.model.roomCostConf
    if roomCostConf ~= nil and roomCostConf[roomId] and roomCostConf[roomId][2] ~= nil then
        expCost = roomCostConf[roomId][2]
    end
    self:addPropertyObservers()
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)

    self:showAnim()
    TextureCache.instance():clean_unused()
end

function RoomChatPopup:dtor()
	self:removePropertyObservers()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end 

function RoomChatPopup:initScene()
	self:leftBtnView()
	self:bottomView()
	self:faceView()
	self.m_normalChatList = self:getUI("normal_chat_list")
	self.m_recordChatList = self:getUI("record_chat_list")
	self:formatView()
end

function RoomChatPopup:leftBtnView()
    self.m_popup_bg = self:getUI("popup_bg")
	self.m_faceSelect = self:getUI("face_select")
	self.m_faceUnSelect = self:getUI("face_unSelect")
	self.m_chatSelect = self:getUI("chat_select")
	self.m_chatUnSelect = self:getUI("chat_unSelect")
	self.m_friendSelect = self:getUI("friend_select")
	self.m_friendUnSelect = self:getUI("friend_unSelect")
	self.m_recordSelect = self:getUI("record_select")
	self.m_recordUnSelect = self:getUI("record_unSelect")
	self.m_newFriendMsgTips = self:getUI("newFriend_msg_tips")
	self.m_newFriendMsgTips:setVisible(false)
	if #nk.userData.chatRecord >0 then
        self.m_newFriendMsgTips:setVisible(true)
    end 
end 

function RoomChatPopup:bottomView()
	self.m_hornIcon = self:getUI("horn_icon")
	self.m_chatIcon = self:getUI("chat_icon")
	self.m_editBox = self:getUI("msg")
	self.m_editBox:setMaxLength(50) 
	self.m_editBox:setOnTextChange(self,self.onEditBoxChange)

	self.m_tipsView = self:getUI("tips_view") 
	self.m_tipsBg = self:getUI("tips_bg")

end 

function RoomChatPopup:faceView()
    self.m_faceView = self:getUI("face_view")
    self.m_expBtn = self:getUI("exp_btn")
    self.m_punakawanBtn = self:getUI("punakawan_btn")
    self.m_vipBtn = self:getUI("Button_vip")
    
    self.m_topArrowexp = self:getUI("top_arrow_exp")
    self.m_topArrowpun = self:getUI("top_arrow_pun")
    self.m_topArrowVip = self:getUI("top_arrow_vip")

    self.m_expBtnTable = {}
    table.insert(self.m_expBtnTable,self.m_expBtn)
    table.insert(self.m_expBtnTable,self.m_punakawanBtn)
    table.insert(self.m_expBtnTable,self.m_vipBtn)

    self.m_arrowTable = {}
    table.insert(self.m_arrowTable,self.m_topArrowexp)
    table.insert(self.m_arrowTable,self.m_topArrowpun)
    table.insert(self.m_arrowTable,self.m_topArrowVip)

    self.m_expListView = self:getUI("exp_list_view")
    self.m_expViewMask = self:getUI("exp_view_mask")
    self.m_expViewMask:setEventDrag(self,function() end);
    self.m_expViewMask:setEventTouch(self,function() end);
    self.m_expViewMask:setVisible(false)

    self.m_not_vip_tips = self:getUI("not_vip_tips")
    self.m_not_vip_tips:setText(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_NOTVIP_TIPS"))
    
    self.m_become_vip_text = self:getUI("become_vip_text")
    self.m_become_vip_text:setText(bm.LangUtil.getText("STORE", "VIP_BE_VIP"))
end 

function RoomChatPopup:formatView()
	self.m_mainView = {
		[1] = self.m_faceView,
		[2] = self.m_normalChatList,
		[4] = self.m_recordChatList,
	}
	self.m_leftBtn = {
		[1] = {self.m_faceSelect,self.m_faceUnSelect},
		[2] = {self.m_chatSelect,self.m_chatUnSelect},
		[3] = {self.m_friendSelect,self.m_friendUnSelect},
		[4] = {self.m_recordSelect,self.m_recordUnSelect},
	}
end

--更新界面显示
function RoomChatPopup:updataViewVisible()
	if self.m_leftViewIndex ~= 3 then
		for k,view in pairs(self.m_mainView) do
			view:setVisible(k == self.m_leftViewIndex)
		end
	end
	self:updataLeftBtnView()
	self:updataTopBtnView()
end 

function RoomChatPopup:updataLeftBtnView()
	for k,btn in pairs(self.m_leftBtn) do
		btn[1]:setVisible(k == self.m_leftViewIndex)
	end
end

function RoomChatPopup:updataTopBtnView()
	for i,btn in ipairs(self.m_expBtnTable) do
        local file = exp_btn_image[i]
        if self.m_TopViewIndex == i then
            btn:setFile(file[1])
        else
            btn:setFile(file[2])
        end
    end

    for i,arrow in ipairs(self.m_arrowTable) do
        arrow:setVisible(i == self.m_TopViewIndex)
    end
end

-- 点击表情按钮
function RoomChatPopup:onFaceBtnClick()
	if self.m_leftViewIndex ~= 1 then
		self.m_leftViewIndex = 1
		self:updataViewVisible()
		self:onExpBtnClick()
	end
end 

-- 点击常用语按钮
function RoomChatPopup:onChatBrnClick()
	if self.m_leftViewIndex ~= 2 then
		self.m_leftViewIndex = 2
		self:updataViewVisible()
		self:createNormalChatList()
	end
end 

-- 点击好友按钮
function RoomChatPopup:onFriendBrnClick()
	-- self.m_leftViewIndex = 3
	-- 聊天系统弹框
	self.m_newFriendMsgTips:setVisible(false)
	nk.PopupManager:addPopup(WAndFChatPopup,"hall",roomType,0)
	self:hideAnim()
end 

-- 点击聊天记录按钮
function RoomChatPopup:onRecoedBtnClick()
	if self.m_leftViewIndex ~= 4 then
		self.m_leftViewIndex = 4
		self:updataViewVisible()
	end
end 

-- 普通表情
function RoomChatPopup:onExpBtnClick()
	if self.m_TopViewIndex ~= 1 then
		self.m_TopViewIndex = 1
		self:updataViewVisible()
		self:createExpList(27,0,0.9,0,0)
	end
end

-- 本土表情
function RoomChatPopup:onPunakawanBtnClick()
	if self.m_TopViewIndex ~= 2 then
		self.m_TopViewIndex = 2
		self:updataViewVisible()
		self:createExpList(18,100,1,0,50)
	end
end

function RoomChatPopup:onVipClick()
    if self.m_TopViewIndex ~= 3 then
        self.m_TopViewIndex = 3
        self:updataViewVisible()
        self:createExpList(10,200,1,0,0)
    end
end


-- 点击消息类别按钮，喇叭或房间聊天
function RoomChatPopup:onOpTypeBtnClick()
	-- 提示 背景 比文本 宽 30
	if self.m_talkMode == 1 then
        self.m_chatIcon:setVisible(true)
        self.m_hornIcon:setVisible(false)
        self.m_talkMode = 2
        self.m_editBox:setText("")
        self.m_editBox:setHintText(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG"),155,155,155)
    else
        self.m_chatIcon:setVisible(false)
        self.m_hornIcon:setVisible(true)
        self.m_talkMode = 1
        self.m_editBox:setText("")
        self.m_editBox:setHintText(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG_LABA"),155,155,155)
    end
    self:updateLabaTips()
end 

-- 点击发送按钮
function RoomChatPopup:onSendBtnClick()
	if self.editbox_text and self.editbox_text ~= "" then
		if self.m_talkMode == 2 then
	        if nk.userData.silenced == 1 then
	            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_SILENCED_MSG"))
	            return
	        end

	        -- self.MessageType 不知道是什么意思
	        -- local text = string.trim(self.editBox_:getText())
	        -- if self.MessageType == 2 then
	        --     if text ~= "" then
	        --         self.laBaUserRequestId_ = bm.HttpService.POST({mod="user", act="useprops",id = 32,message = text,key = crypto.md5("boomegg!@#$%"..text..os.time()),time = os.time() ,nick = nk.userData.nick},
	        --             function(data) 
	        --                 self.laBaUserRequestId_ = nil
	        --                 local callData = json.decode(data)
	        --                 self:hideAnim()
	        --             end, function()
	        --                 self.laBaUserRequestId_ = nil
	        --                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_BIG_LABA_MESSAGE_FAIL"))
	        --             end)
	        --     end
	        -- else
	        	nk.SocketController:sendRoomChat(self.editbox_text)
	            self:hideAnim()
	        -- end
	    else
	        self:useLabaProps()
	    end
	end
end

function RoomChatPopup:useLabaProps()
    if self.editbox_text ~= "" then
        local function refreshMoney(money)
            if money then
                local money = checkint(money)
                if money and money>=0 then
                    nk.functions.setMoney(money)
                    nk.SocketController:synchroUserInfo()
                end
            end
        end
        local msg = Gzip.encodeBase64(string.format("%s%s%s",nk.userData.name,": ",self.editbox_text))
        msg = string.gsub(msg,"+","%%2B")
        local params = {}
        params.mid = nk.userData.uid
        params.pnid = consts.PROPS_ID.LABA_PROP
        params.msg = msg
       	if self.laBaUseNumber_ and self.laBaUseNumber_ <= 0 then
            if self:checkMoneyisEnough() then
                nk.HttpController:execute("usePropsByGold", {game_param = params})
                self:hideAnim()
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "NOT_ENOUGH_CHIPS"))
            end
        else
           	nk.HttpController:execute("useProps", {game_param = params})
           	self:hideAnim()
        end
    end
end

function RoomChatPopup:checkMoneyisEnough()
    local broadcastPrice = nk.userData["broadcastPrice"] or 0
    local roomType_ = self.m_ctx.model:roomType()
    return nk.functions.checkMoneyisEnough(1,true,roomType_,tonumber(broadcastPrice))
end

function RoomChatPopup:onEditBoxChange(text)
	local content = nk.functions.keyWordFilter(self.m_editBox:getText())
	if content ~= text then
        self.m_editBox:setText(content)
    end

    if self.m_talkMode == 1 then
        -- content = nk.updateFunctions.replaceEmojiTest(content)
        self.m_editBox:setText(content)
    end

    self.editbox_text = string.trim(self.m_editBox:getText())
end

function RoomChatPopup:updateLaBaData()
    local params = {}
    params.pcid = 3
   	nk.HttpController:execute("getUserProps", {game_param = params})
end

function RoomChatPopup:onHttpProcesser(command, errorCode, data)
    if command == "getUserProps" then
        if errorCode == 1 and data and data.code == 1 then
            if self.refreshProp and data.data then
                self:refreshProp(data.data)
            end
        end
    elseif command == "useProps" then
        if errorCode == 1 and data and data.code == 1 then
            if self.refreshProp and data.data and data.data.prop then
               self:refreshProp(data.data.prop)
            end
        end
    elseif command == "usePropsByGold" then
        if errorCode == 1 and data and data.code == 1 then
            if self.refreshProp and data.data and data.data.prop then
                self:refreshProp(data.data.prop)
            end
            refreshMoney(data.data.money) 
        end
    end
end

function RoomChatPopup:refreshProp(data)
    local callData = data
    if callData and #callData > 0 then
        for k,v in pairs(callData) do
            if tonumber(v.pnid) == consts.PROPS_ID.LABA_PROP then
                self.laBaUseNumber_ = tonumber(v.pcnter) or 0
                break
            end
        end
    end
    self:updateLabaTips()
end

function RoomChatPopup:updateLabaTips()
	local str = ""
    if self.m_talkMode == 1 then
        if self.laBaUseNumber_ and self.laBaUseNumber_ > 0 then
            str = bm.LangUtil.getText("USERINFO","PROP_COUNT",self.laBaUseNumber_)
        else
            local moneystr = ""
            if nk.userData["broadcastPrice"] and tonumber(nk.userData["broadcastPrice"]) > 0 then
                print("broadcastPricebroadcastPricebroadcastPrice = ", nk.userData["broadcastPrice"])
                moneystr = bm.LangUtil.getText("USERINFO","PROP_BUY_AND_USE", nk.updateFunctions.formatBigNumber(nk.userData["broadcastPrice"]))
            else
                moneystr = bm.LangUtil.getText("USERINFO","PROP_BUY_AND_USE", "")
            end
            local tempStr = bm.LangUtil.getText("USERINFO","PROP_COUNT",self.laBaUseNumber_ or 0)
            str = tempStr..moneystr
        end
    else
        str = bm.LangUtil.getText("USERINFO","SEND_BROADCAST")..","..bm.LangUtil.getText("USERINFO","PROP_COUNT",self.laBaUseNumber_ or 0)
    end

    self.m_tipsBg:removeAllChildren(true)
    self.tipsText_ = new(Text,str,0,0,kAlignLeft,nil,20,155,155,155) 
    self.m_tipsBg:addChild(self.tipsText_)
    self.tipsText_:setPos(15,10)

    local tipsText_w, _ = self.tipsText_:getSize()
    self.m_tipsBg:setSize(tipsText_w + 30,50)

    if not nk.isInSingleRoom then
        self.m_tipsBg:setVisible(true)
        self.m_tipsView:setVisible(true)
    else
        self.m_tipsBg:setVisible(false)
        self.m_tipsView:setVisible(false)
    end
end

function RoomChatPopup:createNormalChatList()
	if self.m_roomType and self.m_roomType == 2 then
        self.m_shortcutMsgStringArr = bm.LangUtil.getText("ROOM", "CHAT_SHORTCUT_99")
    else
        self.m_shortcutMsgStringArr = bm.LangUtil.getText("ROOM", "CHAT_SHORTCUT")
    end
    local item_h = 65
    local x, y = 0, 5
    for i, msg in ipairs(self.m_shortcutMsgStringArr) do
    	local item = new(ChatMsgShortcutListItem,msg)
    	item:setPos(x,y)
    	self.m_normalChatList:addChild(item)
    	item:setDelege(self,self.onChatShortItemClicked)
    	y = y + item_h
    end
end

function RoomChatPopup:onChatShortItemClicked(msg)
	if nk.userData.silenced and nk.userData.silenced == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_SILENCED_MSG"))
        return
    end
    nk.SocketController:sendRoomChat(msg)
    self:hideAnim()
end

function RoomChatPopup:createExpList(expNum,startIdIndex,expScale,offStartPosX,offStartPosY)
	offStartPosY = expCost > 0 and offStartPosY or 0
	local x, y = offStartPosX,offStartPosY
	local item_w, item_h = 100, 100
    self.m_expListView:removeAllChildren()
    self.m_expListView.m_nodeH = 0
	for i=1,expNum do
		local expItem = new(ExpressionsItem,startIdIndex,i,expScale)

		x = (i+3)%4*item_w + offStartPosX
		y = math.floor((i-1)/4)*item_h + offStartPosY

		expItem:setPos(x,y)
    	self.m_expListView:addChild(expItem)
    	expItem:setDelege(self,self.onExpItemClicked)
	end

	--表情消耗籌碼提示
	if self.m_TopViewIndex == 2 and expCost > 0 then
        local text = T("发送一次该表情需消耗 %s 金币",nk.updateFunctions.formatBigNumber(expCost))
        self.costText = new(TextView,T(text),370,offStartPosY,kAlignLeft,nil,16,250,230,255) 
        self.costText:setPos(15,0)
        self.m_expListView:addChild(self.costText)
    end

    self.m_expViewMask:setVisible(false)
    local isVip = nk.userData.vip and tonumber(nk.userData.vip) > 0
    local hasExpProp = false
    PropManager.getInstance():requestUserPropList(function()
        if tolua.isnull(self) then return end
        hasExpProp = PropManager.getInstance():isPropValid(PropManager.ID_MONKEY_EXP)
        if self.m_TopViewIndex == 3 and (not isVip and not hasExpProp) then
            self.m_expViewMask:setVisible(true)
        else
            self.m_expViewMask:setVisible(false)
        end
    end, true)
    if self.m_TopViewIndex == 3 and (not isVip and not hasExpProp) then
        self.m_expViewMask:setVisible(true)
    else
        self.m_expViewMask:setVisible(false)
    end
end

function RoomChatPopup:onExpItemClicked(expId)
	Log.printInfo("expId = ",expId)
    expId = checkint(expId)
    if self.m_ctx.model:isSelfInSeat() then
        if expId / 100 < 1 then
            nk.SocketController:sendExpression(1,expId)
        elseif expId/100>=2 and expId/100<3 then
            PropManager.getInstance():requestUserPropList(function()
                local isVip = nk.userData.vip and tonumber(nk.userData.vip) > 0
                local hasExpProp = PropManager.getInstance():isPropValid(PropManager.ID_MONKEY_EXP)
                if isVip or hasExpProp then
                    nk.SocketController:sendExpression(1, expId)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_NOTVIP_TIPS"))
                end
            end, true)
        else
            if expCost ~= 0 then
                nk.SocketController:sendRoomCostProp(expCost,1,expId,0)
            else
                nk.SocketController:sendExpression(1,expId)
            end
        end

        self:hideAnim()
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_MUST_BE_IN_SEAT"))
    end
end

function RoomChatPopup:createRecordChatList()
    local mergedList = {}
    table.insertto(mergedList, nk.DataProxy:getData(nk.dataKeys.ROOM_CHAT_HISTORY) or {})
    table.sort(mergedList, function(o1, o2)
        return o1.time > o2.time
    end)

    self.m_recordChatList:removeAllChildren(true)

    local x,y = 0,0 
    for i,data in ipairs(mergedList) do
    	if data.mtype == 2 then
    		local node = new(Node)
    		node:setSize(400,85)
    		node:setPos(x,y)
    		self.m_recordChatList:addChild(node)

    		local msg = new(TextView,data.messageContent or "",370,80,kAlignLeft,nil,22,250,230,255) 
    		msg:setAlign(kAlignCenter)
    		node:addChild(msg)

    		local line = new(Image,"res/roomChat/roomChat_line.png")
    		line:setSize(400,5)
    		line:setPos(0,3)
    		line:setAlign(kAlignBottom)
    		node:addChild(line)

    		if data.sendUid == nk.userData.uid then
    			msg:setColor(160,255,0)
    		end

    		y = y + 85
    	end
    end
end

function RoomChatPopup:onBecomeVipBtnClick()
    local vipPopup = require("game.store.vip.vipPopup")
    if nk.roomSceneType == "qiuqiu" then
        nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_CHAT_PAY
    else
        nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_CHAT_PAY
    end
    nk.PopupManager:addPopup(vipPopup,"room",nil,nil,"vip")
    RoomChatPopup.hide()
end

function RoomChatPopup:showAnim()
    self.m_popup_bg:stopAllActions()

    if self.m_roomType and self.m_roomType == 2 then
        self.m_popup_bg:setAlign(kAlignBottomLeft)
    else
        self.m_popup_bg:setAlign(kAlignBottomRight)
    end

    self.m_popup_bg:setPos(-517)
    transition.moveTo(self.m_popup_bg, {time=0.3, x=0, easing="OUT"})
end

function RoomChatPopup:hideAnim()
	self:hide()
end

function RoomChatPopup:addPropertyObservers()
    self.chatRecordHandle = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", handler(self, function (obj, chatRecord)
        if not nk.updateFunctions.checkIsNull(obj) then
            if chatRecord and #chatRecord>0 then
                obj.m_newFriendMsgTips:setVisible(true)
            else
                obj.m_newFriendMsgTips:setVisible(false)
            end
        end
    end))
    self.historyWatcher = nk.DataProxy:addDataObserver(nk.dataKeys.ROOM_CHAT_HISTORY, handler(self, self.createRecordChatList))
end

function RoomChatPopup:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", self.chatRecordHandle)
    nk.DataProxy:removeDataObserver(nk.dataKeys.ROOM_CHAT_HISTORY, self.historyWatcher)
end

return RoomChatPopup


