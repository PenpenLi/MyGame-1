
local PopupModel = import('game.popup.popupModel')

local RoomUserinfoOtherPopup = class(PopupModel)

local RoomUserinfoOtherPopupLayer = require(VIEW_PATH .. "roomUserInfo.roomUserinfo_other_pop")
local varConfigPath = VIEW_PATH .. "roomUserInfo.roomUserinfo_other_pop_layout_var"
local FriendDataManager = require("game.friend.friendDataManager") 

local PropItem = require("game.userInfo.roomUserinfo.propItem")

local WIN_RATE_HISTORY = bm.LangUtil.getText("USERINFO", "WIN_RATE_HISTORY")
local GENERAL_NUMBER = bm.LangUtil.getText("USERINFO", "GENERAL_NUMBER")

function RoomUserinfoOtherPopup.show(...)
    PopupModel.show(RoomUserinfoOtherPopup, RoomUserinfoOtherPopupLayer, varConfigPath, {name="RoomUserinfoOtherPopup"}, ...)
end

function RoomUserinfoOtherPopup.hide()
     PopupModel.hide(RoomUserinfoOtherPopup)
end

function RoomUserinfoOtherPopup:ctor(viewConfig, varConfigPath, ctx, data)
    Log.printInfo("RoomUserinfoOtherPopup.ctor");

    self.m_space_v = 5
    self.m_space_h = 10
    self.m_ceartedPropsList = false
    self.m_expCost = 0
    self.ctx = ctx

    self.m_isAddFriend = true

    self.m_friendDataManager = FriendDataManager.getInstance()

    self:initScene()
    self:createPropsList()
    self:setData(data)

    self.sendNum = nk.DictModule:getInt("gameData", nk.cookieKeys.PROP_SENT_MORE_NUM, 1)
    self:setSendMoreBtnStatus() 

    EventDispatcher.getInstance():register(EventConstants.addFriendData, self, self.addFriendBack)
    EventDispatcher.getInstance():register(EventConstants.deleteFriendData, self, self.deleteFriendBack)
    EventDispatcher.getInstance():register(EventConstants.getMemberInfoCallback, self, self.onGetMemberInfoCallback)
end 

function RoomUserinfoOtherPopup:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.addFriendData, self, self.addFriendBack)
    EventDispatcher.getInstance():unregister(EventConstants.deleteFriendData, self, self.deleteFriendBack)
    EventDispatcher.getInstance():unregister(EventConstants.getMemberInfoCallback, self, self.onGetMemberInfoCallback)
    nk.DataProxy:setData(nk.dataKeys.ROOM_GAG, self.gagData_ or {})
    nk.DataProxy:cacheData(nk.dataKeys.ROOM_GAG)
    nk.DictModule:saveDict("gameData")
end 

function RoomUserinfoOtherPopup:initScene()
	self.m_popupBg = self:getUI("popup_bg")
	self:addCloseBtn(self.m_popupBg, 30, 30)
    self:setCost() 
	self:commonInfoView()
	self:propsView()
end 

function RoomUserinfoOtherPopup:setCost()
    self.m_costTips = self:getUI("cost_tips")
    if nk.isInSingleRoom then
    else
        local roomId = tostring(self.ctx.model.roomInfo.roomType) 
        local roomCostConf = self.ctx.model.roomCostConf
        if roomCostConf ~= nil and roomCostConf[roomId] and roomCostConf[roomId][1] ~= nil then
            self.m_expCost = roomCostConf[roomId][1]
        end
    end

    self.m_costTips:setText(T("每发送一次互动道具需消耗%s金币",nk.updateFunctions.formatBigNumber(self.m_expCost)))
    if self.m_expCost == 0 then
        self.m_costTips:setVisible(false)
    end
end

function RoomUserinfoOtherPopup:commonInfoView()
	self.head_ = self:getUI("head_image")
    self.head_ = Mask.setMask(self.head_, kImageMap.common_head_mask_big)

	self.sexIcon_ = self:getUI("sex_icon")
	self.nick_ = self:getUI("name")
	self.uid_ = self:getUI("uid")
	self.chip_ = self:getUI("money")
	self.level_ = self:getUI("level")
	self.levelIcon_ = self:getUI("level_icon")
    self.winRate_ = self:getUI("winRate")
    self.generalNumber_ = self:getUI("generalNumber")

    self.m_operatorBg = self:getUI("operator_bg")
    self.m_operatorBg:setVisible(false)

    self.m_operatorNode = self:getUI("operator_node")
    self.m_operatorNode:setVisible(false)
    self.m_reportTypeNode = self:getUI("report_type_code")
    self.m_reportTypeNode:setVisible(false)

    self.m_addFriendText = self:getUI("add_friend_text")
    self.m_addBtnText = self:getUI("add_btn_text")

    self.m_reportBg = self:getUI("report_bg")
    self.m_reportBg:setVisible(false)

    self.m_reportText = self:getUI("report_text")
    self.m_reportText:setColor(255,255,255)

    self.m_chatForbidText = self:getUI("chat_forbid_text")

    self.uid_:setText(bm.LangUtil.getText("ROOM", "INFO_UID", ""))
    self.chip_:setText("--")
    self.level_:setText(bm.LangUtil.getText("ROOM", "INFO_LEVEL", 1))
    self.winRate_:setText(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", 0))
    self.generalNumber_:setText(bm.LangUtil.getText("ROOM", "INFO_GENERAL_NUMBER", 0))

    -- 3连发
    self.m_sendMoreIcon1 = self:getUI("send_more_icon1")
    -- 5连发
    self.m_sendMoreIcon2 = self:getUI("send_more_icon2")
end 

function RoomUserinfoOtherPopup:propsView()
	self.m_propsList = self:getUI("props_List")
end 

function RoomUserinfoOtherPopup:setSendMoreBtnStatus() 
    if self.sendNum <= 1 then
        self.m_sendMoreIcon1:setFile("res/userInfo/userInfo_uchosed.png")
        self.m_sendMoreIcon2:setFile("res/userInfo/userInfo_uchosed.png")
    elseif self.sendNum == 3 then
        self.m_sendMoreIcon1:setFile("res/userInfo/userInfo_choosed.png")
        self.m_sendMoreIcon2:setFile("res/userInfo/userInfo_uchosed.png")
    elseif self.sendNum == 5 then
        self.m_sendMoreIcon1:setFile("res/userInfo/userInfo_uchosed.png")
        self.m_sendMoreIcon2:setFile("res/userInfo/userInfo_choosed.png")
    end
end

function RoomUserinfoOtherPopup:onSendMoreBtn1Click()
    self.sendNum = self.sendNum == 3 and 1 or 3
    nk.DictModule:setInt("gameData", nk.cookieKeys.PROP_SENT_MORE_NUM, self.sendNum)
    self:setSendMoreBtnStatus() 
end

function RoomUserinfoOtherPopup:onSendMoreBtn2Click()
    self.sendNum = self.sendNum == 5 and 1 or 5
    nk.DictModule:setInt("gameData", nk.cookieKeys.PROP_SENT_MORE_NUM, self.sendNum)
    self:setSendMoreBtnStatus() 
end

function RoomUserinfoOtherPopup:setOperatorStatus(index)
    if index == 1 then
        self.m_operatorBg:setVisible(true)
        self.m_operatorNode:setVisible(true)
        self.m_reportTypeNode:setVisible(false)
        self.m_reportText:setColor(255,255,255)
        self.m_reportBg:setVisible(false)
    elseif index == 2 then
        self.m_operatorBg:setVisible(true)
        self.m_operatorNode:setVisible(true)
        self.m_reportTypeNode:setVisible(true)
        self.m_reportText:setColor(255,246,0)
        self.m_reportBg:setVisible(true)
    elseif index == 3 then
        self.m_operatorBg:setVisible(false)
        self.m_operatorNode:setVisible(false)
        self.m_reportTypeNode:setVisible(false)
        self.m_reportText:setColor(255,255,255)
        self.m_reportBg:setVisible(false)
    end
end

function RoomUserinfoOtherPopup:onOperatorBgTouch()
    self:setOperatorStatus(3)
end

function RoomUserinfoOtherPopup:onAddFriendBtnClick()
    self:setOperatorStatus(1)
end 

-- 添加好友
function RoomUserinfoOtherPopup:onAddBtnClick()
    self:setOperatorStatus(3)
    if self.m_isAddFriend then
        nk.AnalyticsManager:report("New_Gaple_room_addFriend", "room")
        self:onAddFriendClicked_()
    else
        self:onDelFriendClicked_()
    end
end 

-- 屏蔽
function RoomUserinfoOtherPopup:onChatForbidBtnClick()
    self:setOperatorStatus(3)
    if self.isForbid then
        self:setSpeakStatus(true)
    else
        self:setSpeakStatus(false)
    end
end 

-- 举报
function RoomUserinfoOtherPopup:onReportBtnClick()
    self:setOperatorStatus(2)
end 

-- 举报色情图像
function RoomUserinfoOtherPopup:onBtn1Click()
    self:setOperatorStatus(3)

end 

-- 举报骂人
function RoomUserinfoOtherPopup:onBtn2Click()
    self:setOperatorStatus(3)

end 

-- 举报倒币
function RoomUserinfoOtherPopup:onBtn3Click()
    self:setOperatorStatus(3)

end 

function RoomUserinfoOtherPopup:createPropsList()
    self.m_space_v = 0
    self.m_space_h = 10

    local itemScale = 0.85

    local x, y = self.m_space_h, self.m_space_v
    local maxId = 12
    local temp = new(Image,"res/userInfo/userInfo_prop_expression_bg.png")

    local item_w, item_h = temp:getSize()
    for i = 1, 2 do
        for j = 1, 6 do
            local id = (i - 1) * 6 + j
            if id <= maxId then
                local item = new(PropItem, id)
                item:setDelegate(self, self.sendHddjClicked_)
                self.m_propsList:addChild(item)
                item:addPropScaleSolid(0, itemScale, itemScale, kCenterDrawing)
                item:setPos(x,y)
                x = x + item_w + self.m_space_h
            end
        end
        x = self.m_space_h
        y = y + item_h*itemScale + self.m_space_v
    end
end 

function RoomUserinfoOtherPopup:setData(data)
    self.data_ = data
    -- self.m_friendDataManager  里边以mid为准
    self.data_.mid = self.data_.uid

    if data then
        self.nick_:setText(nk.updateFunctions.limitNickLength(data.userInfo.name, 12) or "")
        self.uid_:setText(bm.LangUtil.getText("ROOM", "INFO_UID", data.uid or ""))
        self.chip_:setText(nk.updateFunctions.formatBigNumber(data.userInfo.money or 0))

        if not nk.isInSingleRoom then 
            self.level_:setText(bm.LangUtil.getText("ROOM", "INFO_LEVEL", data.userInfo.mlevel or nk.Level:getLevelByExp(data.userInfo.mexp)))
            local levelIcon = string.format("res/level/level_%d.png",data.userInfo.mlevel or nk.Level:getLevelByExp(data.userInfo.mexp))
            self.levelIcon_:setFile(levelIcon)
        end
        self.winRate_:setText(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", data.userInfo.mwin +  data.userInfo.mlose > 0 and math.round(data.userInfo.mwin * 100 / (data.userInfo.mwin + data.userInfo.mlose)) or 0))
        self.generalNumber_:setText(bm.LangUtil.getText("ROOM", "INFO_GENERAL_NUMBER", data.userInfo.mwin +  data.userInfo.mlose))
        
        local params = {}
        local text = nil
        params.uid = data.uid
        nk.UserDataController.getMemberInfo(params)

        if tonumber(data.userInfo.msex) == 2 or tonumber(data.userInfo.msex) == 0 then
            self.sexIcon_:setFile("res/common/common_sex_woman_icon.png")
        else
            self.sexIcon_:setFile("res/common/common_sex_man_icon.png")
        end

        -- FB 头像 暂时不管
        -- local imgurl = data.userInfo.mavatar or ""
        -- if string.find(imgurl, "facebook") then
        --     if string.find(imgurl, "?") then
        --         imgurl = imgurl .. "&width=100&height=100"
        --     else
        --         imgurl = imgurl .. "?width=100&height=100"
        --     end
        -- end

        if not string.find(data.userInfo.mavatar, "http")then
            -- 默认头像 
            if data.userInfo.msex and tonumber(data.userInfo.msex) ==1 then
                self.head_:setFile(kImageMap.common_male_avatar)
            else
                self.head_:setFile(kImageMap.common_female_avatar)
            end
        else
            -- 上传的头像
            UrlImage.spriteSetUrl(self.head_, data.userInfo.mavatar)
        end
    end
    self:setAddFriendStatus()
    self:setSpeakStatus()
end

function RoomUserinfoOtherPopup:onGetMemberInfoCallback(callData)
    if not self.chip_ or not self.chip_.m_res then return end
    self.m_hasGetMemberInfo = true
    if callData then
        self.data_.chips = tonumber(callData.aUser.money) or self.data_.chips or 0
        self.data_.level = tonumber(callData.aUser.mlevel) or nk.Level:getLevelByExp(self.data_.exp)
        self.data_.win = tonumber(callData.aUser.win) or self.data_.userInfo.mwin
        self.data_.lose = tonumber(callData.aUser.lose) or self.data_.userInfo.mlose
        self.data_.ranking = tonumber(callData.aBest.rankMoney) or self.data_.ranking or 0

        self.chip_:setText(nk.updateFunctions.formatBigNumber(callData.aUser.money))
        self.level_:setText(T("Lv.%d",callData.aUser.mlevel))
        self.winRate_:setText(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", callData.aUser.win + callData.aUser.lose > 0 and math.round(callData.aUser.win * 100 / (callData.aUser.win + callData.aUser.lose)) or 0))
        self.generalNumber_:setText(bm.LangUtil.getText("ROOM", "INFO_GENERAL_NUMBER", callData.aUser.win +  callData.aUser.lose))
        
        EventDispatcher.getInstance():dispatch(EventConstants.UPDATE_SEATID_USERINFO, {data = callData, isSelf = false, seatId = self.data_.seatId})
    end
end

function RoomUserinfoOtherPopup:setAddFriendStatus()
    if self.data_ and not self.m_friendDataManager:checkHasFriend(self.data_) then
        self.m_addFriendText:setText(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
        self.m_addBtnText:setText(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
        self.m_isAddFriend = true
    else
        self.m_addFriendText:setText(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
        self.m_addBtnText:setText(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
        self.m_isAddFriend = false
    end
end

function RoomUserinfoOtherPopup:sendHddjClicked_(hddjId)
    self.sendHddjId_ = hddjId
    if self.ctx.model:isSelfInSeat() then
        self:sendHddjAndHide_()
    else
        --不在座位不能发送互动道具
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_IN_SEAT"))
    end
end

function RoomUserinfoOtherPopup:sendHddjAndHide_()
    local pnid = 2001 --互动表情道具
    -- self:doAnalytics("EC_R_Prop_Num", "EC_R_Prop_Num")
    if self.m_expCost == 0 then
        nk.SocketController:sendProp(self.sendHddjId_,{self.data_.seatId},pnid)
        self.ctx.animManager:playHddjAnimation(self.ctx.model:selfSeatId(), self.data_.seatId, self.sendHddjId_)
    else
        nk.SocketController:sendRoomCostProp(self.m_expCost,2,self.sendHddjId_,self.data_.seatId,self.sendNum or 1)
    end
    self:hide()
end

function RoomUserinfoOtherPopup:onAddFriendClicked_()
    -- self:doAnalytics("EC_R_Add_Friends_Num", "EC_R_Add_Friends_Num")
    local params = {}
    params.mid = nk.userData.uid
    params.fid = self.data_.uid
    nk.HttpController:execute("addFriend", {game_param = params})
end

function RoomUserinfoOtherPopup:addFriendBack(status, data, flag)
    self:setAddFriendStatus()
    if status and tonumber(data.mid) == tonumber(self.data_.uid) then
        if self.ctx.model:isSelfInSeat() then
            --自己在座位，广播加好友动画
            self.ctx.animManager:playAddFriendAnimation(self.ctx.model:selfSeatId(), self.data_.seatId)
        else
            --不在座位，只播放动画，别人看不到
            self.ctx.animManager:playAddFriendAnimation(-1, self.data_.seatId)
        end
        self:hide()
    elseif flag == -2 then

    end
end

function RoomUserinfoOtherPopup:onDelFriendClicked_()
    -- self:doAnalytics("EC_R_Del_Friends_Num", "EC_R_Del_Friends_Num")
    local params = {}
    params.mid = nk.userData.uid
    params.fid = self.data_.uid
    nk.HttpController:execute("deleteFriend", {game_param = params})
end

function RoomUserinfoOtherPopup:deleteFriendBack(status, mid)
    if status and tonumber(mid) == tonumber(self.data_.uid) then
        self:setAddFriendStatus()
    end
end

--设置是否可以显示说话文字
--flag true or false true为可显示
function RoomUserinfoOtherPopup:setSpeakStatus(flag)
    Log.printInfo("RoomUserinfoOtherPopup:setSpeakStatus", flag)
    if not self.gagData_ then
        self.gagData_ = nk.DataProxy:getData(nk.dataKeys.ROOM_GAG) or {}
    end

    if not self.gagUidData_ then
        for _, v in ipairs(self.gagData_) do
            if v.uid == self.data_.userId or v.uid == self.data_.uid then
                self.gagUidData_ = v
                break
            end
        end
    end

    if flag ~= nil then 
        -- 用户手动设置
        if flag then
            if self.gagUidData_ then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "GAG_CANCEL_TIPS"))
                table.removebyvalue(self.gagData_, self.gagUidData_)
                self.gagUidData_ = nil
                self:setSpeakBtnStatus(true)
            end
        else
            if not self.gagUidData_ then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "GAG_TIPS"))
                self.gagUidData_ = {}
                self.gagUidData_.uid = self.data_.userId or self.data_.uid
                table.insert(self.gagData_, self.gagUidData_)
                self:setSpeakBtnStatus(false)
            end
            self.gagUidData_.time = os.time()
        end
    else
        -- 初始化设置
        if self.gagUidData_ then
            if self.gagUidData_.time - os.time() > 24*3600 then
                table.removebyvalue(self.gagData_, self.gagUidData_)
                self.gagUidData_ = nil
                -- 取消屏蔽
                self:setSpeakBtnStatus(true)
            else
                -- 屏蔽
                self:setSpeakBtnStatus(false)
            end
        else
            -- 取消屏蔽
            self:setSpeakBtnStatus(true)
        end
    end
end

-- flag true 点击后 执行屏蔽
function RoomUserinfoOtherPopup:setSpeakBtnStatus(flag)
    if flag then
        self.isForbid = false 
        self.m_chatForbidText:setText(bm.LangUtil.getText("USERINFO", "GAG_CANCEL_TIPS1"))

    else
        self.isForbid = true 
        self.m_chatForbidText:setText(bm.LangUtil.getText("USERINFO", "GAG_TIPS1"))
    end
end

function RoomUserinfoOtherPopup:doAnalytics(eventID,eventLabel)
    -- nk.AnalyticsManager:report(eventID,eventLabel)
end

return RoomUserinfoOtherPopup

