
local PopupModel = import('game.popup.popupModel')

local RoomUserinfoSelfPopup = class(PopupModel)

local RoomUserinfoSelfPopupLayer = require(VIEW_PATH .. "roomUserInfo.roomUserinfo_self_pop")
local varConfigPath = VIEW_PATH .. "roomUserInfo.roomUserinfo_self_pop_layout_var"

local ExpItem = require("game.userInfo.roomUserinfo.expItem")

local expCost = 0

local roomCostConf

function RoomUserinfoSelfPopup.show(...)
    PopupModel.show(RoomUserinfoSelfPopup, RoomUserinfoSelfPopupLayer, varConfigPath, {name="RoomUserinfoSelfPopup"}, ...)
end

function RoomUserinfoSelfPopup.hide()
     PopupModel.hide(RoomUserinfoSelfPopup)
end

function RoomUserinfoSelfPopup:ctor(viewConfig, varConfigPath, tableMessage, level, ctx)
    Log.printInfo("RoomUserinfoSelfPopup.ctor");
    self.m_ctx = ctx

    self.m_space_v = 5
    self.m_space_h = 10

    self.m_loadEdMoreUseExp = false
    self.m_ceartedExpList = false

    self.m_curViewIndex = 1

    EventDispatcher.getInstance():register(EventConstants.getMemberInfoCallback, self, self.onGetMemberInfoCallback)

    self.isInRoom_ = true
    if self.isInRoom_ and tableMessage then
        self.tableAllUid = tableMessage.tableAllUid
        self.toUidArr = tableMessage.toUidArr
        self.tableNum = tableMessage.tableNum
        self.roomLevel_ = level
    end
    nk.functions.cacheKeyWordFile()

    local roomId = tostring(self.m_ctx.model.roomInfo.roomType) 
    roomCostConf = self.m_ctx.model.roomCostConf
    if roomCostConf ~= nil and roomCostConf[roomId] and roomCostConf[roomId][2] ~= nil then
        expCost = roomCostConf[roomId][2]
    end

    self:initScene()
    if not self.m_hasGetMemberInfo then
        self:requireDeatilInfo()
    end
end 

function RoomUserinfoSelfPopup:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.getMemberInfoCallback, self, self.onGetMemberInfoCallback)
end 

function RoomUserinfoSelfPopup:initScene()
	self.m_popupBg = self:getUI("popup_bg")
	self:addCloseBtn(self.m_popupBg, 30, 30)

	self:commonInfoView()
	self:btnView()
	self:detailInfoView()
	self:expressionsView()
    self:onExpBtnClick()
end 

function RoomUserinfoSelfPopup:commonInfoView()
	self.m_head = self:getUI("head_image")
    self.m_head = Mask.setMask(self.m_head, kImageMap.common_head_mask_big)
	self.m_sexIcon = self:getUI("sex_icon")
	self.m_name = self:getUI("name")
	self.m_uid = self:getUI("uid")
	self.m_money = self:getUI("money")
	self.m_level = self:getUI("level")
	self.m_levelIcon = self:getUI("level_icon")

    self.m_money:setText(nk.updateFunctions.formatNumberWithSplit(nk.functions.getMoney()))
    self.m_uid:setText("UID:" .. nk.userData.mid)
    self.m_name:setText(nk.userData.name)
end 

function RoomUserinfoSelfPopup:btnView()
	self.m_expIcon = self:getUI("exp_icon")
	self.m_expName = self:getUI("exp_name")
	self.m_infoIcon = self:getUI("info_icon")
	self.m_infoName = self:getUI("info_name")
    self.m_expName:setText(bm.LangUtil.getText("USERINFO", "COMMON_USE"))
    self.m_infoName:setText(bm.LangUtil.getText("USERINFO", "GAME_DETEIL"))
end 

function RoomUserinfoSelfPopup:detailInfoView()
	self.m_detailInfoView = self:getUI("detail_info_view")

	self.m_winRate = self:getUI("winRate")
	self.m_ranking = self:getUI("ranking")
	self.m_generalNumber = self:getUI("generalNumber")
	self.m_historyMaxWin = self:getUI("historyMaxWin")
	self.m_historyPoperty = self:getUI("historyPoperty")

	self.m_pokerType = self:getUI("pokerType")
    local _, h = self.m_pokerType:getSize()
    self.m_pokerType:addPropScaleSolid(0, 0.6, 0.6, kCenterXY,0,h/2);
	self.m_pokerTypeView = self:getUI("poker_type_view")
	self.m_poker1 = self:getUI("poker1")
	self.m_poker2 = self:getUI("poker2")
	self.m_poker3 = self:getUI("poker3")
	self.m_poker4 = self:getUI("poker4")
    self.m_pokers = {}
    table.insert(self.m_pokers,self.m_poker1)
    table.insert(self.m_pokers,self.m_poker2)
    table.insert(self.m_pokers,self.m_poker3)
    table.insert(self.m_pokers,self.m_poker4)
end 

function RoomUserinfoSelfPopup:expressionsView()
	self.m_expressionsView = self:getUI("expressions_view")
	self.m_expressionsList = self:getUI("expressions_List")
	self.m_tips = self:getUI("tips")
	self.m_tips:setVisible(false)
    self.m_tips:setText(bm.LangUtil.getText("USERINFO", "NO_EXP_TIPS"))
end 

function RoomUserinfoSelfPopup:onExpBtnClick()
	self.m_curViewIndex = 1
	self:updataBtnStatus()
	self:cearteExpList()
end 

function RoomUserinfoSelfPopup:onInfoBtnClick()
	self.m_curViewIndex = 2
	self:updataBtnStatus()
    if not self.m_hasGetMemberInfo then
        self:requireDeatilInfo()
    end
end 

function RoomUserinfoSelfPopup:updataBtnStatus()
	self.m_expIcon:setVisible(self.m_curViewIndex == 1)
	self.m_infoIcon:setVisible(self.m_curViewIndex == 2)
	if self.m_curViewIndex == 1 then
		self.m_expName:setColor(255,255,255)
		self.m_infoName:setColor(199,127,241)
	else
		self.m_expName:setColor(199,127,241)
		self.m_infoName:setColor(255,255,255)
	end
	self.m_expressionsView:setVisible(self.m_curViewIndex == 1)
	self.m_detailInfoView:setVisible(self.m_curViewIndex == 2)
end 

function RoomUserinfoSelfPopup:cearteExpList()
    self.m_tips:setVisible(false)
	if not self.m_ceartedExpList then
		self:loadMoreUseExp()
	end
end 

function RoomUserinfoSelfPopup:loadMoreUseExp()
	if not self.m_loadEdMoreUseExp then
        self.m_space_v = 5
        self.m_space_h = 10
        local x, y = 0, 0
        local commonExp = nk.CommonExpManage.getCommonExp()
        if commonExp and type(commonExp) == "table" and #commonExp > 0 then
            self.m_expressionsList:removeAllChildren(true)
            for i,exp in ipairs(commonExp) do
                if i <= nk.CommonExpManage.MAX_NUM then
                    local item = new(ExpItem, exp)
                    item:setDelegate(self, self.sendExpClicked_)

                    local item_w, item_h = item:getSize()
                    x = (i+5)%6*item_w + ((i+5)%6+1)*self.m_space_h
                    y = math.floor((i-1)/6)*item_h + (math.floor((i-1)/6)+1)*self.m_space_v
                    
                    item:setPos(x,y)
                    self.m_expressionsList:addChild(item)
                end
            end
            self.m_loadEdMoreUseExp = true
            self.m_ceartedExpList = true
        else
            self.m_tips:setVisible(true)
            self.m_loadEdMoreUseExp = false
            self.m_ceartedExpList = false
        end
	end
end 

function RoomUserinfoSelfPopup:sendExpClicked_(expId)
    Log.printInfo("expId = ",expId)
    if self.m_ctx.model:isSelfInSeat() then
        if expId / 100 < 1 then
            nk.SocketController:sendExpression(1,expId)
        else
            if expCost ~= 0 then
                nk.SocketController:sendRoomCostProp(expCost,1,expId,0)
            else
                nk.SocketController:sendExpression(1,expId)
            end
        end

        nk.AnalyticsManager:report("New_Gaple_selfInfo_face", "selfInfo")

        self:hide()
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_MUST_BE_IN_SEAT"))
    end
end

function RoomUserinfoSelfPopup:requireDeatilInfo()
    local INFO_RANKING = bm.LangUtil.getText("USERINFO", "INFO_RANKING")
    local MAX_MONEY_HISTORY = bm.LangUtil.getText("USERINFO", "MAX_MONEY_HISTORY")
    local MAX_WIN_HISTORY = bm.LangUtil.getText("USERINFO", "MAX_WIN_HISTORY")
    local WIN_RATE_HISTORY = bm.LangUtil.getText("USERINFO", "WIN_RATE_HISTORY")
    local GENERAL_NUMBER = bm.LangUtil.getText("USERINFO", "GENERAL_NUMBER")
    self.m_ranking:setText(INFO_RANKING .. "--")
    self.m_historyPoperty:setText(MAX_MONEY_HISTORY .. "--")
    self.m_historyMaxWin:setText(MAX_WIN_HISTORY .. "--")
    self.m_winRate:setText(WIN_RATE_HISTORY .. "--")
    self.m_generalNumber:setText(GENERAL_NUMBER .. "--")

	local params = {}
    local text = nil
    params.uid = nk.userData.uid
    nk.UserDataController.getMemberInfo(params)
end

function RoomUserinfoSelfPopup:onGetMemberInfoCallback(retData)
    if not self.m_ranking or not self.m_ranking.m_res then return end
    local INFO_RANKING = bm.LangUtil.getText("USERINFO", "INFO_RANKING")
    local MAX_MONEY_HISTORY = bm.LangUtil.getText("USERINFO", "MAX_MONEY_HISTORY")
    local MAX_WIN_HISTORY = bm.LangUtil.getText("USERINFO", "MAX_WIN_HISTORY")
    local WIN_RATE_HISTORY = bm.LangUtil.getText("USERINFO", "WIN_RATE_HISTORY")
    local GENERAL_NUMBER = bm.LangUtil.getText("USERINFO", "GENERAL_NUMBER")
    self.m_hasGetMemberInfo = true
    if retData then
        local rankMoney = tonumber(retData.aBest.rankMoney or 0)
        if not nk.updateFunctions.checkIsNull(self.m_ranking) then
            if rankMoney > 10000 then
                self.m_ranking:setText(INFO_RANKING .. ">10,000")
            elseif rankMoney<=0 then
                self.m_ranking:setText(INFO_RANKING .. ">10,000")
            else
                self.m_ranking:setText(INFO_RANKING .. nk.updateFunctions.formatNumberWithSplit(rankMoney))
            end
        end

        --如果最高资产与当前资产不一致，更新
        if nk.functions.getMoney() > nk.userData["aBest.maxmoney"] then
            nk.userData["aBest.maxmoney"] = nk.functions.getMoney()
            local info = {}
            local params = {}
            params.maxmoney = nk.userData["aBest.maxmoney"]
    		info.multiValue = params
            nk.HttpController:execute("updateMemberBest", {game_param = info})
            retData.aBest.maxmoney = nk.userData["aBest.maxmoney"]
        end

        if not nk.updateFunctions.checkIsNull(self.m_historyPoperty) then
            self.m_historyPoperty:setText(MAX_MONEY_HISTORY .. nk.updateFunctions.formatBigNumber(retData.aBest.maxmoney))
            self.m_historyMaxWin:setText(MAX_WIN_HISTORY .. nk.updateFunctions.formatBigNumber(retData.aBest.maxwmoney and retData.aBest.maxwmoney>0 and retData.aBest.maxwmoney or 0))
            self.m_money:setText(nk.updateFunctions.formatNumberWithSplit(nk.functions.getMoney()))
            self.m_level:setText(T("Lv.%d",nk.Level:getLevelByExp(nk.userData.exp)))
            local levelIcon = string.format("res/level/level_%d.png",nk.Level:getLevelByExp(nk.userData.exp))
            self.m_levelIcon:setFile(levelIcon)
            self.m_winRate:setText(WIN_RATE_HISTORY .. (nk.userData.win + nk.userData.lose > 0 and math.round(nk.userData.win * 100 / (nk.userData.win + nk.userData.lose)) or 0) .."%")
            self.m_generalNumber:setText(GENERAL_NUMBER .. nk.userData.win + nk.userData.lose)
        end

        -- nk.userData["aBest.maxwcard"] = "4,5,37,102"
        -- nk.userData["aBest.maxwcardvalue"] = 154
        self.m_pokerType:setVisible(false)
        self.m_pokerTypeView:setVisible(false)
        if nk.userData["aBest.maxwcard"] ~= "" then
            self.m_pokerTypeView:setVisible(true)
            local cards = {}
            cards=string.split(nk.userData["aBest.maxwcard"], ',')
            if self.pokerCards then
                for i,v in ipairs(cards) do
                    self.pokerCards[i]:setCard(checkint(v))
                end
            else
                self.pokerCards = {}
                for i,v in ipairs(cards) do
                    self.pokerCards[i] = new(nk.pokerUI.PokerCard)
                    if self.m_pokers[i] then
                        self.m_pokers[i]:addChild(self.pokerCards[i])
                    end
                    self.pokerCards[i]:setCard(checkint(v))
                end
            end

            if nk.userData["aBest.maxwcardvalue"] ~= "" then
                local specialCardNum = checkint(nk.userData["aBest.maxwcardvalue"])-153
                if specialCardNum > 0 and specialCardNum <= 5 then
                    local typeIcon = string.format("res/room/qiuqiu/qiuqiu_card_mode_%d.png",specialCardNum)
                    self.m_pokerType:setFile(typeIcon)
                    self.m_pokerType:setVisible(true)
                end
            end
        end

        if not string.find(nk.userData.micon, "http")then
            -- 默认头像
            if nk.userData.msex and tonumber(nk.userData.msex) ==1 then
                self.m_head:setFile(kImageMap.common_male_avatar)
            else
                self.m_head:setFile(kImageMap.common_female_avatar)
            end
        else
            -- 上传的头像
            UrlImage.spriteSetUrl(self.m_head, nk.userData.micon)
        end

        EventDispatcher.getInstance():dispatch(EventConstants.UPDATE_SEATID_USERINFO, {data = retData, isSelf = true})
    end
end 

return RoomUserinfoSelfPopup

