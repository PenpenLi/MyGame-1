
local view = require(VIEW_PATH .. "chat.world_chat_view")
local varConfigPath = VIEW_PATH .. "chat.world_chat_view_layout_var"
local Gzip = require('core/gzip')

local WorldChatItem = require("game.chat.layers.worldChatItem")

local WorldChatLayer = class(GameBaseLayer, false)

function WorldChatLayer:ctor(roomType)
	Log.printInfo("WorldChatLayer.ctor");
	super(self, view, varConfigPath)

    self.broadCast = {}
    self.laBaUseNumber_ = 0
    self.roomType_ = roomType or 0
    
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)

    self:initScene()
    self:updateLaBaData()
end

function WorldChatLayer:initScene()
	self.m_chatMsgView = self:getUI("chat_msg_view") 
	self.labaNum_ = self:getUI("hron_num")
	self.editBox_ = self:getUI("horn_input")
    self.editBox_:setMaxLength(50) 
	self.editBox_:setOnTextChange(self,self.onEditBoxChange)
	self.editBox_:setHintText(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG_LABA"),155,155,155)
end

function WorldChatLayer:updataView()
	self:loadBroadCastHistory()
	self:updataListView()
end

function WorldChatLayer:onEditBoxChange(text)
	local content = nk.functions.keyWordFilter(self.editBox_:getText())
	if content ~= text then
        self.editBox_:setText(content)
    end

    -- content = nk.updateFunctions.replaceEmojiTest(content)
    self.editBox_:setText(content)

    self.editbox_text = string.trim(self.editBox_:getText())

end

function WorldChatLayer:onHornSendBtnClick()
	if self.editbox_text and self.editbox_text ~= "" then
		if not self.isForbidTime then
			self.isForbidTime = true

	        self.forbidTime_id = nk.GCD.PostDelay(self, function()
		        self.isForbidTime = nil
		    end, nil, 3000)

	        local msg = Gzip.encodeBase64(string.format("%s%s%s",nk.userData.name,": ",self.editbox_text))
            msg = string.gsub(msg,"+","%%2B")
	        local params = {}
            params.mid = nk.userData.uid
            params.pnid = consts.PROPS_ID.LABA_PROP
            params.msg = msg
           	if self.laBaUseNumber_ and self.laBaUseNumber_ <= 0 then
	            if self:checkMoneyisEnough() then
	                nk.HttpController:execute("usePropsByGold", {game_param = params})
	            else
	                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "NOT_ENOUGH_CHIPS"))
	            end
	        else
               	nk.HttpController:execute("useProps", {game_param = params})
	        end
	      	self.editBox_:setText("")
    		self.editbox_text = ""
		else
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "BROADCAST_TOO_FAST"))
		end
	else
		-- print("kong kong kong kong kong kong kong kong ")
    end
end

function WorldChatLayer:checkMoneyisEnough()
    local labaPrice = nk.userData["broadcastPrice"] or 0
    return nk.functions.checkMoneyisEnough(1,nk.isInRoomScene,self.roomType_,tonumber(labaPrice))
end

function WorldChatLayer:updateLaBaData()
    local params = {}
    params.pcid = 3
   	nk.HttpController:execute("getUserProps", {game_param = params})
end

function WorldChatLayer:onHttpProcesser(command, errorCode, data)
    if command == "usePropsByGold" then
        if errorCode == 1 and data and data.code == 1 then
            if self.refreshProp and data.data and data.data.prop then
                self:refreshProp(data.data.prop)
            end
            local money = data.data.money
            if money then
                local money = tonumber(money)
                if money and money>=0 then
                    nk.functions.setMoney(money)
                    if nk.isInRoomScene then
                        nk.SocketController:synchroUserInfo()
                    end
                end
            end
        end
    elseif command == "useProps" then
        if errorCode == 1 and data and data.code == 1 then
            if self.refreshProp and data.data and data.data.prop then
               self:refreshProp(data.data.prop)
            end
        end
    elseif command == "getUserProps" then
        if errorCode == 1 and data and data.code == 1 then
            if self.refreshProp and data.data then
                self:refreshProp(data.data)
            end
        end
    end
end

function WorldChatLayer:refreshProp(data)
    if self.labaNum_.m_res then
        local callData = data
        if callData and #callData > 0 then
            for k,v in pairs(callData) do
                if tonumber(v.pnid) == consts.PROPS_ID.LABA_PROP then
                    self.labaNum_:setText(v.pcnter)
                    self.laBaUseNumber_ = tonumber(v.pcnter)
                    break
                end
            end
        else
            self.labaNum_:setText("0")
        end
        self:updateLabaTips()
    end
end

function WorldChatLayer:updateLabaTips()
    if self.laBaUseNumber_ and self.laBaUseNumber_ > 0 then
        self.editBox_:setHintText(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG_LABA"),155,155,155)
    else
        local moneystr = ""
        if nk.userData["broadcastPrice"] and tonumber(nk.userData["broadcastPrice"]) > 0 then
            moneystr = bm.LangUtil.getText("USERINFO","PROP_BUY_AND_USE", nk.updateFunctions.formatBigNumber(nk.userData["broadcastPrice"]))
        else
            moneystr = bm.LangUtil.getText("USERINFO","PROP_BUY_AND_USE", "")
        end
        self.editBox_:setHintText(string.sub(moneystr,2),155,155,155)
    end
end

function WorldChatLayer:loadBroadCastHistory()
	self.broadCast = nk.GameBroadCastHistoryManager:getBroadCastData()
end

function WorldChatLayer:updataListView()
	self:addItemView()
end

function WorldChatLayer:refreshListHandler_(evt)
    self.broadCast = evt
    self:addItemView()
end

function WorldChatLayer:addItemView()
    self.m_chatMsgView:removeAllChildren()
    local pos_x, pos_y = 0, 0
    for index, data in ipairs(self.broadCast) do
        local item = new(WorldChatItem, data, index)
        local width, height = item:getSize()
        item:setPos(pos_x, pos_y)
        self.m_chatMsgView:addChild(item)
        pos_y = pos_y + height
    end
    self.m_chatMsgView:update()
    self.m_chatMsgView:gotoBottom()
end

function WorldChatLayer:dtor()
	if self.forbidTime_id then
        nk.GCD.CancelById(self,self.forbidTime_id)
        self.forbidTime_id = nil
    end
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

WorldChatLayer.s_eventHandle = 
{
    [EventConstants.refreshBroadcastList] = WorldChatLayer.refreshListHandler_,
};

return WorldChatLayer