--
-- Author: tony
-- Date: 2014-07-08 14:28:57
--
local GiftShopPopup = import("game.giftShop.giftShopPopup")
local LoadGiftControl = import("game.giftShop.loadGiftControl")
local StorePopup = require("game.store.popup.storePopup")
local SeatView = class(GameBaseLayer)

local seatViewScene = require(VIEW_PATH .. "roomGaple.roomGaple_seat")
local HandCard = require("game.roomGaple.views.handCard")
local ChangeChipAnim = require("game.roomGaple.anim.changeChipAnim")

function SeatView:ctor(viewControl, viewVar, ctx, seatId)
    self.ctx = ctx
    -- self.m_root = SceneLoader.load(seatViewScene)
    -- self:declareLayoutVar(VIEW_PATH .. "roomGaple.roomGaple_seat_layout_var")

	self:setSize(self.m_root:getSize())

	self.seatId_ = seatId
    self.positionId_ = seatId + 1

	self:initScene()

    self.seatIdLabel = self:getUI("seatId")
    self.seatIdLabel:setText(seatId)

	self.pos = RoomViewPosition.SeatPosition[self.positionId_]

	--[[
	Clock.instance():schedule_once(function ( ... )
		self:dump_constraint()
		-- self.parent:print_tree()
		print("self size", self.size)
		print("self pos", self.pos)
		print("self.parent size", self.parent.size)
		print("self.parent pos", self.parent.pos)
	end)
	--]]

end

function SeatView:initScene()
    self.m_seatNode = self:getUI("seatNode")
    self.m_baseNode = self:getUI("baseNode")
	self.m_headBgBtn =self:getUI("head_bg_btn")
    self.m_headBgBtn:setOnClick(self, self.onHeadBtnClick)
    self.image_ = self:getUI("headImage")
    self.image_ = Mask.setMask(self.image_, kImageMap.common_head_mask_big)
    self.vipIcon_ = self:getUI("View_vip")
    self.m_headImageBg = self:getUI("HeadImageBg")
	--------------infoNode_ start
	self.infoNode_ = self:getUI("info_bg")
	self.chip = self:getUI("chip_icon")
    self.chip_node = self:getUI("chip_node")
	self.chips_ = self:getUI("money")
	self.state_ = self:getUI("name")
	self.privateRoomOwnerIcon_ = self:getUI("room_owner")
	self.privateRoomOwnerIcon_:setVisible(false)

    self.addGoldBtn = self:getUI("AddGoldBtn")
    self.addImage = self:getUI("AddImage")
    self.addGoldBtn:setEnable(false)
    self.addImage:setVisible(false)

	-- 购买金币按钮
	-- self.addChips_ 
	-- 邀请好友按钮
	-- self.inviteFriendBtn self.onClickInviteFriend  :hide()
	--------------infoNode_ end

    -- winner动画 
    self.winnerAnimBatch_ = self:getUI("winBorderView")
    self.winnerAnimBatch_:setVisible(false)

    -- winner 文字
    self.win_text = self:getUI("win_text")

	-- 手上剩余牌数
	self.lastCardsNode_ = self:getControl(self.s_controls["lastCards_bg"])
	self.lastCardsText_ = self:getControl(self.s_controls["lastCards_num"])

	-- 礼物
	self.giftImage_ = self:getControl(self.s_controls["gift_btn"])
    self.giftImage_:setOnClick(self,self.openGiftPopUpHandler)

    self.giftImage_big = self:getControl(self.s_controls["gift_btn_big"])
    self.giftImage_big:setOnClick(self,self.openGiftPopUpHandler)
    
    if nk.config.GIFT_SHOP_ENABLED and not nk.isInSingleRoom then
        self:setGiftIconVisible(false)
    end

	--坐下图片
	self.sitdown_ = self:getControl(self.s_controls["seatDown_btn"])

    -- pass图标
    self.passIcon_ = self:getControl(self.s_controls["passIcon"])
    self.passIcon_:setVisible(false)

    --8 手牌
    self.handCards_ = new(HandCard, self)
    self.handCards_:setVisible(false)
    self.handCards_:setPos(210,22)
    self.handCards_:setSize(462,120)
    self.m_root:addChild(self.handCards_)


    --10 等待下局开始 
    self.waitBg_ = self:getControl(self.s_controls["waitBg"])
    self.waitBg_:setVisible(false)
    self.waitText_ = self:getControl(self.s_controls["waitText"])
    self.waitText_:setText(bm.LangUtil.getText("ROOM", "WAIT_NEXT_ROUND"))

    -- 过扣费和超时出牌提示
    self.tipsNode = self:getControl(self.s_controls["tipsNode"])
    self.tipsText_ = self:getControl(self.s_controls["tipsText"])

    -- 用于确定动画位置
    self.giftCenter_node = self:getUI("giftCenter_node")
    self.seatCenter_node = self:getUI("seatCenter_node")
    self.chatNodeLeft = self:getUI("chatBubble_node_left")
    self.chatNodeRight = self:getUI("chatBubble_node_right")

    self:setPassStatus(false)

    --初始为站起状态
    self:standUpState_()

    -- 添加数据观察器
    self:addPropertyObservers_()


end

function SeatView:setDelegate(delegate, delegateFunc)
	self.delegate = delegate;
	self.delegateFunc = delegateFunc;
end

function SeatView:onHeadBtnClick()
    if self.delegate and self.delegateFunc then
        self.delegateFunc(self.delegate,self.seatId_);
    end
end

function SeatView:OnAddGoldClick()
	nk.payScene = consts.PAY_SCENE.GAPLE_ROOM_HEADICON_PAY
    nk.PopupManager:addPopup(StorePopup)
end

--设置剩余牌数
function SeatView:setLastCards(num)
    if num > 0 then
        self.lastCardsNode_:setVisible(true)
        self.lastCardsText_:setText(num)
    else
        self.lastCardsNode_:setVisible(false)
    end
end

function SeatView:getLastCards()
    return tonumber(self.lastCardsText_:getText())
end

function SeatView:setPassStatus(pass)
    if pass then
        self.passIcon_:setVisible(true)
        if ((self.positionId_ == 1) or (self.positionId_ == 2)) then
            self.passIcon_:setPos(-70, -100)
            self.passIcon_:setFile("res/room/gaple/roomG_round_pass_right.png")
        else
            self.passIcon_:setPos(70, -100)
            self.passIcon_:setFile("res/room/gaple/roomG_round_pass_left.png")
        end

        nk.GCD.PostDelay(self, function()
            if self.passIcon_ and self.passIcon_.m_res then
                self.passIcon_:setVisible(false)
            end
        end, nil, 2000)

        if self.seatData_ and self.seatData_.isSelf and self.ctx.model:isSelfInGame() and nk.functions.getPassShouldTips() and self.tipsNode then
            self.tipsNode:setVisible(true)
            nk.functions.setPassShouldTips(false)
            local text = bm.LangUtil.getText("ROOM", "CARD_TIPS3")
            self.tipsText_:setText(text)
        end
    else
        self.passIcon_:setVisible(false)
        if self.tipsNode then
            self.tipsNode:setVisible(false)
        end
    end
end

function SeatView:playSitDownAnimation(onCompleteCallback)
	-- 待实现
    -- transition.stopTarget(self.image_)
    -- transition.moveTo(self.image_:pos(0, 115):show(), {time=0.5, easing="backOut", x=0, y=0})
    -- transition.moveTo(self.sitdown_:pos(0, 0):show(), {time=0.5, easing="backOut", x=0, y=-100, onComplete=function() 
    --     self.sitdown_:setVisible(false)
    --     self.image_:pos(0,-12)
    --     if onCompleteCallback then
    --         onCompleteCallback()
    --     end
    -- end})
    
    self.image_:setVisible(true)
    self.vipIcon_:setVisible(true)
    self.sitdown_:setVisible(false)
    if onCompleteCallback then
        onCompleteCallback()
    end
end

function SeatView:playStandUpAnimation(onCompleteCallback)
	-- 待实现
    -- transition.moveTo(self.image_:pos(0, -12):show(), {time=0.5, easing="backOut", x=0, y=110})
    -- transition.moveTo(self.sitdown_:pos(0, -100):show(), {time=0.5, easing="backOut", x=0, y=0, onComplete=function() 
    --     self.image_:hide()
    --     if onCompleteCallback then
    --         onCompleteCallback()
    --     end
    -- end})

    self.image_:setVisible(false)
    self.vipIcon_:setVisible(false)
    self.vipIcon_:removeAllChildren(true)
    self.sitdown_:setVisible(true)
    if onCompleteCallback then
        onCompleteCallback()
    end
end

function SeatView:fade()
    print("------------------------SeatView:fade----------------")
    -- self.m_seatNode:setColor(80,80,80)
    self.image_:setColor(80,80,80)
    self.vipIcon_:setColor(80,80,80)
    self.chip:setColor(128,128,128)
    self.chips_:setColor(128,128,128)
    self.state_:setColor(128,128,128)
    self.giftImage_:setColor(128,128,128)
    self.giftImage_big:setColor(128,128,128)
end

function SeatView:unfade()
    -- self.m_seatNode:setColor(255,255,255)
    self.image_:setColor(255,255,255)
    self.vipIcon_:setColor(255,255,255)
    self.chip:setColor(255,255,255)
    self.chips_:setColor(255,209,0)
    if  self.seatData_ then
        if self.seatData_.userInfo.vip and self.seatData_.userInfo.vip > 0 then
            self.state_:setColor(0xa0,0xff,0x00)
        else
            self.state_:setColor(255,255,255)
        end
    end  
    self.giftImage_:setColor(255,255,255)
    self.giftImage_big:setColor(255,255,255)
end

function SeatView:sitDownState_()
	-- 待实现
    -- self.image_:stopAllActions()
    -- self.sitdown_:stopAllActions()
    -- self.image_:pos(0, -12):show()
    -- self.sitdown_:pos(0, -100):hide()

    self.image_:setVisible(true)
    self.vipIcon_:setVisible(true)
    self.sitdown_:setVisible(false)

    if self.giftImage_ then
        self:setGiftIconVisible(true)
    end
end

function SeatView:standUpState_()
    -- self.image_:stopAllActions()
    -- self.sitdown_:stopAllActions()
    -- self.image_:pos(0, 115):hide()
    -- self.sitdown_:pos(0, 0):show()
    self.image_:setVisible(false)
    self.vipIcon_:setVisible(false)
    self.vipIcon_:removeAllChildren(true)
    self.sitdown_:setVisible(true)

    if self.giftImage_ then
        self:setGiftIconVisible(false)
    end
    
end

function SeatView:isEmpty()
    return not self.seatData_
end

function SeatView:getPositionId()
    return self.positionId_
end

function SeatView:setPositionId(id)
    self.positionId_ = id
    if self.giftImage_ then
        if id then
            if ((id == 1) or (id == 2)) then
                self.giftImage_:setPos(-57,0)
                self.giftImage_big:setPos(-57,0)
            else
                self.giftImage_:setPos(57,0)
                self.giftImage_big:setPos(57,0)
            end
        end
    end
    if self.lastCardsNode_ then
        if id then
            if ((id == 1) or (id == 2)) then
                self.lastCardsNode_:setMirror(true, false)
                self.lastCardsNode_:setPos(54,0)
                self.lastCardsText_:setPos(-15,8)
            else
                self.lastCardsNode_:setMirror(false, false)
                self.lastCardsNode_:setPos(-54,0)
                self.lastCardsText_:setPos(15,8)
            end
        end
    end
end

function SeatView:resetToEmpty()
    self.seatData_ = nil
    self:updateState()
end

function SeatView:setSeatData(seatData,notSetTouch)
    self.seatData_ = seatData   
    if seatData and seatData.isSelf then
        self.handCards_:setPos(210, 22)
        -- self.handCards_:removeProp(0)
        self.handCards_:addPropScaleSolid(0, 1, 1, kCenterXY)
        if not notSetTouch then
            self.handCards_:setTouchStatus(true)
        end
        self.handCards_:setCardsUid(seatData.uid)
        if nk.isInSingleRoom then
            -- self.addChips_:setVisible(false)
        else
            -- self.addChips_:setVisible(true)
        end
    elseif seatData then
        self.handCards_:setPos(-13 + 11, 60)
        -- self.handCards_:removeProp(0)
        self.handCards_:addPropScaleSolid(0, 0.4, 0.4, kCenterXY)
        self.handCards_:setTouchStatus(false)
        self.handCards_:setCardsUid(seatData.uid)
        -- self.addChips_:setVisible(false)
    else
        -- self.addChips_:setVisible(false)
        self.chip:setVisible(false)
    end
    
    if not seatData then
        self:reset()
        self:standUpState_()
    else
        print(seatData.uid,self.ctx.model.roomInfo.ownerUid,"self.ctx.model.roomInfo.ownerUid")
        if seatData.uid == self.ctx.model.roomInfo.ownerUid then
            self.privateRoomOwnerIcon_:setVisible(true)
        else
            self.privateRoomOwnerIcon_:setVisible(false)
        end

        self:sitDownState_()
        local mavatar = seatData.userInfo.mavatar
        if seatData.isSelf then
            mavatar = nk.userData.micon
        end
        if not mavatar or not string.find(mavatar, "http")then
            -- 默认头像 
            if seatData.userInfo.msex and tonumber(seatData.userInfo.msex) ==1 then
                self.image_:setFile(kImageMap.common_male_avatar)
            else
                self.image_:setFile(kImageMap.common_female_avatar)
            end
        else
            -- 上传的头像
            UrlImage.spriteSetUrl(self.image_, mavatar)
        end
        
        if self.giftImage_ then
            if self.giftUrlReqId_ then
                LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
            end
            if seatData.userInfo.giftId then
                self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(seatData.userInfo.giftId, handler(self, function(obj,url)
                    self.giftUrlReqId_ = nil
                    if not nk.updateFunctions.checkIsNull(obj) then
                        obj:downLoadGiftIconCallback(url)
                    end
                end))
            end
        end
        if seatData.userInfo.vip  and tonumber(seatData.userInfo.vip)>0 then 
            local vipk = new(Image,"res/common/vip_head_kuang.png")
            vipk:setAlign(kAlignCenter)
            vipk:addPropScaleSolid(0, 0.93, 0.93, kCenterDrawing);
            vipk:setPos(0,0)
            self.image_:addChild(vipk)
            self:DrawVip(self.vipIcon_, seatData.userInfo.vip)
        end
    end
end
function SeatView:DrawVip(node,vipLevel)
    node:removeAllChildren(true)

    local vipbs = new(Image, kImageMap.vip_bs)
    vipbs:setAlign(kAlignCenter)
    vipbs:addPropScaleSolid(0, 0.2, 0.2, kCenterDrawing);
    vipbs:setPos(15,18)
    node:addChild(vipbs) 

    local vipIcon = new(Image,"res/common/vip_big/v.png")
    node:addChild(vipIcon)
    vipIcon:setPos(28,8)
    vipLevel = tonumber(vipLevel)

    if vipLevel >=10 then
        local num1 = math.modf(vipLevel/10)
        local num2 = vipLevel%10

        local vipNum1 = new(Image,"res/common/vip_big/" .. num1 .. ".png")
        vipNum1:setPos(38,8)
        node:addChild(vipNum1)
        local vipNum2 = new(Image,"res/common/vip_big/" .. num2 .. ".png")
        vipNum2:setPos(49,8)
        node:addChild(vipNum2)
    else
        local vipNum = new(Image,"res/common/vip_big/" .. vipLevel .. ".png")
        vipNum:setPos(38,8)
        node:addChild(vipNum)
    end   
end

function SeatView:getSeatData()
    return self.seatData_
end

function SeatView:setGiftIconVisible(visible)
    if self.giftImage_.m_res then 
        if visible then
            if self.m_giftUrl then
                self.giftImage_:setVisible(false)
                self.giftImage_big:setVisible(true)   
            else
                self.giftImage_:setVisible(true)   
                self.giftImage_big:setVisible(true)    
            end
        else
            self.giftImage_:setVisible(false)   
            self.giftImage_big:setVisible(false)
        end
    end
end

function SeatView:downLoadGiftIconCallback(url)
    if not nk.updateFunctions.checkIsNull(self) and self.giftImage_ and self.giftImage_.m_res then
        if url and string.len(url) > 5 then
            self.m_giftUrl = true
            if self.giftImage_big then
                UrlImage.spriteSetUrl(self.giftImage_big, url)
            end
        end
    end
    self:setGiftIconVisible(true)
end

function SeatView:updateGiftUrl(gift_Id)
    if self.giftImage_ then
        if self.giftUrlReqId_ then
            LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
        end
        if gift_Id then
            self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(gift_Id, handler(self, function(obj,url)
                self.giftUrlReqId_ = nil
                if not nk.updateFunctions.checkIsNull(obj) then
                    obj:downLoadGiftIconCallback(url)
                end
            end))
        end

        --更新礼物数据
        if self.seatData_ then
            self.seatData_.userInfo.giftId = gift_Id
        end
    end
end

function SeatView:updateHeadImage(imgurl)
    if not string.find(imgurl, "http")then
        -- 上传的头像
        UrlImage.spriteSetUrl(self.image_, imgurl)
    end
end

--flag 是否显示金币改变动画
function SeatView:SetSeatChipTxt(value, flag)
    if not value then
        return
    end
    self.lastAnteMoney = (self.lastAnteMoney or 0) + value
    if self.seatData_ then
        if self.seatData_.userInfo then
            self.seatData_.userInfo.money = self.lastAnteMoney
        end
        if self.seatData_.isSelf then
            nk.functions.setMoney(self.lastAnteMoney)
        end
    end
    self:setChipTxt(self.lastAnteMoney)
    self:playChangeChipAnim(value,flag)
end

function SeatView:playChangeChipAnim(value, flag)
    if flag then
        if self.changeChipAnim_ then
            self.changeChipAnim_:removeFromParent(true)
            delete(self.changeChipAnim_)
            self.changeChipAnim_ = nil
        end
        self.changeChipAnim_ = new(ChangeChipAnim,value,0,0)
        self.changeChipAnim_:setAlign(kAlignBottom)
        self.changeChipAnim_:setPos(0,0)
        self:addChild(self.changeChipAnim_)
    end
end

function SeatView:setChipTxt(value)
    if not value then
        return
    end
    value = tonumber(value)
    local moneyStr = tostring(value)
    if value < 100000 then
        moneyStr = nk.updateFunctions.formatNumberWithSplit(value)
    else
        moneyStr = nk.updateFunctions.formatBigNumber(value)
    end
    -- moneyStr = tostring(value)
    self.chips_:setText(moneyStr)
end

--每次更新携带存一下上一次的携带，为了结算的时候要按奖池分配逐步更新携带筹码(txt内容已经格式化数字了get不回来)
local lastAnteMoney = 0  

function SeatView:aboutFB()
    self.m_root:setVisible(false)
    local lastLoginType = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    if lastLoginType ==  "FACEBOOK" and self.ctx.model:roomInvite(false)==0 then
        self.ctx.model:roomInvite(true)
        -- 待实现
        -- nk.Facebook:getInvitableFriends(handler(self, self.onGetData_))
    end
end

function SeatView:onGetData_(success, friendData, filterStr)
    if success then
        if self.seatData_ == nil then
            if not self.ctx.model:isSelfInSeat() then
                self.m_root:setVisible(true)
                self.infoNode_:setVisible(false)
                self.sitdown_:setVisible(true)
                -- self.inviteFriendBtn:setVisible(false)
                self:setInviteFriendBtn(false)
                return
            end
        else
            return
        end
        -- 排除今日邀请过的
        local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")          
        if invitedNames ~= "" then
            local namesTable = string.split(invitedNames, "#")
            if namesTable[1] ~= os.date("%Y%m%d") then
                nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                nk.userDefault:flush()
            else
                table.remove(namesTable, 1)
                for _, name in pairs(namesTable) do
                    local i, max = 1, #friendData
                    while i <= max do
                        if friendData[i].name == name then
                            table.remove(friendData, i)
                            i = i - 1
                            max = max - 1
                        end
                        i = i + 1
                    end
                end
            end
        end

        if #friendData>=1 then
            self.fbFriendData=friendData[math.random(1,#friendData)]
            self.m_root:setVisible(true)
            self.infoNode_:setVisible(true)
            self.sitdown_:setVisible(false)
            self.state_:setText(nk.updateFunctions.limitNickLength(self.fbFriendData["name"],8))
            self:setInviteFriendBtn(true)
            self:updateHeadImage(self.fbFriendData["url"])
            self.image_:setVisible(true)
        else
            self.m_root:setVisible(false)
        end
        
    end
end

function SeatView:onClickInviteFriend()
    local toIds = ""
    local names = ""
    local toIdArr = {}
    local nameArr = {}
    table.insert(toIdArr, self.fbFriendData.id)
    table.insert(nameArr, self.fbFriendData.name)
    toIds = table.concat(toIdArr, ",")
    names = table.concat(nameArr, "#")
    -- 发送邀请
    if toIds ~= "" then
        nk.http.getInviteId(
            function (data)
                local retData = data;
                local requestData = ""
                requestData = retData.sk;
                nk.Facebook:sendInvites(
                    requestData, 
                    toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT",nk.updateFunctions.formatBigNumber(nk.userData["inviteForRegist"])), 
                    function (success, result)
                        if success then
                            nk.AnalyticsManager:report("EC_R_Seat_Invite_Btn","invite")
                            -- 保存邀请过的名字
                            if names ~= "" then
                                local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                                local today = os.date("%Y%m%d")
                                if invitedNames == "" or string.sub(invitedNames, 1, 8) ~= today then
                                    invitedNames = today .."#" .. names
                                else
                                    invitedNames = invitedNames .. "#" .. names
                                end
                                nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, invitedNames)
                                nk.userDefault:flush()
                            end
                            -- 去掉最后一个逗号
                            if result.toIds then
                                local idLen = string.len(result.toIds)
                                if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                                    result.toIds = string.sub(result.toIds, 1, idLen - 1)
                                end
                            end

                            local postData = {
                                data = requestData, 
                                requestid = result.requestId, 
                                toIds = result.toIds, 
                                source = "register"
                            }
                            postData.type = "register"

                            nk.http.inviteReport(
                                postData, 
                                function (data)
                                    local retData = data
                                    if retData and retData.money and retData.money > 0 then
                                        local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                                        historyVal = historyVal + retData.money
                                        nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)
                                        local getMoney = nk.functions.getMoney()
                                        nk.functions.setMoney(getMoney + retData.money)   
                                    end
                                    if retData and retData.text then
                                        -- 给出提示
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.text))
                                    end
                                end
                            )
                            --显示邀请好友前的状态
                            self.ctx.model:roomInvite(true)
                            self:updateState()
                        end
                    end
                )
            end, 
            function ()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
        )
    end
end

function SeatView:updateState()
    if self.seatData_ == nil then
        if self.ctx.model:isSelfInSeat() then
            self:aboutFB()
        else
            self.m_root:setVisible(true)
            self.infoNode_:setVisible(false)
            self.privateRoomOwnerIcon_:setVisible(false)
            self.sitdown_:setVisible(true)
            -- self.inviteFriendBtn:setVisible(false)
            self:setInviteFriendBtn(false)
        end
    else   
        -- self.inviteFriendBtn:setVisible(false)
        self:setInviteFriendBtn(false)
        self.m_root:setVisible(true)
        self.infoNode_:setVisible(true)
        self.sitdown_:setVisible(false)
        self.state_:setText(nk.updateFunctions.limitNickLength(self.seatData_.userInfo.name,8))
        if self.seatData_.isSelf then
            self.addGoldBtn:setEnable(true)
            self.addImage:setVisible(true)
        else
            self.addGoldBtn:setEnable(false)
            self.addImage:setVisible(false)
        end
        --除了结算阶段，存一下上次携带值(结算阶段的anteMoney已经是最终值，不能用来做加筹码动画)
        -- 这块原本就屏蔽
        -- if self.ctx.model.gameInfo.gameStatus ~= consts.SVR_GAME_STATUS.GAME_STOP then
            local money = self.seatData_.userInfo.money
            self.lastAnteMoney = money
            self:setChipTxt(self.lastAnteMoney)
        -- end

        -- print("self.seatData_.userStatus = ",self.seatData_.userStatus)
        -- print("self.seatData_.uid = ",self.seatData_.uid)
        -- print("consts.SVR_USER_STATE.USER_STATE_GAMEING = ",consts.SVR_USER_STATE.USER_STATE_GAMEING )
        if self.ctx.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.GAME_STOP or self.seatData_.userStatus == consts.SVR_USER_STATE.USER_STATE_GAMEING then
            self:unfade()
        else
            self:fade()
        end
    end
end

function SeatView:setInviteFriendBtn(flag)
    if flag then
        -- self.inviteFriendBtn:setVisible(true)
        self.chip:setVisible(false)
        -- self.addChips_:setVisible(false)
        self.chips_:setVisible(false)
    else
        -- self.inviteFriendBtn:setVisible(false)
        self.chip:setVisible(true)
        self.chips_:setVisible(true)
    end
end

function SeatView:setHandCardValue(cards)
    self.handCards_:setCards(cards)
end

function SeatView:findHandCardByValue(cardValue)
    return self.handCards_:findCard(cardValue)
end

function SeatView:setHandCardNum(num)
    self:setLastCards(num)
end

function SeatView:getHandCardNum()
    return self:getLastCards()
end

function SeatView:hidHandCardNum()
    self.lastCardsNode_:setVisible(false)
end

function SeatView:showHandCards()
    self.handCards_:setVisible(true)
end

function SeatView:hideHandCards()
    self.handCards_:setVisible(false)
end

function SeatView:showHandCardBackAll()
    self.handCards_:showBackAll()
end

function SeatView:showHandCardFrontAll()
    self.handCards_:showFrontAll()
end

function SeatView:flipAllHandCards()
    self.handCards_:flipAll()
end

function SeatView:hideAllHandCardsElement()
    self.handCards_:hideAllCards()
end

function SeatView:showAllHandCardsElement()
    self.handCards_:showAllCards()
end

function SeatView:showHandCardsElement(idx)
    self.handCards_:showWithIndex(idx)
end

function SeatView:flipHandCardsElement(idx)
    self.handCards_:flipWithIndex(idx)
end

function SeatView:shakeAllHandCards()
    if self.findCard_ then
        self.handCards_:shakeWithNum(7)
        self.shakeTimeHandle = nk.SoundManager:playSound(nk.SoundManager.SHAKETIME)
        if self.seatData_ and self.seatData_.isSelf and self.ctx.model:isSelfInGame() and nk.functions.getShakeShouldTips() and self.tipsNode then
            self.tipsNode:setVisible(true)
            nk.functions.setShakeShouldTips(false)
            local text = bm.LangUtil.getText("ROOM", "CARD_TIPS4")
            self.tipsText_:setText(text)
        end
    end
end

function SeatView:stopShakeAllHandCards()
    self.handCards_:stopShakeAll()
    if self.shakeTimeHandle then
        nk.SoundManager:stopSound(self.shakeTimeHandle)
    end
    if self.tipsNode then
        self.tipsNode:setVisible(false)
    end
end

function SeatView:setHandCardTouchStatus(status)
    self.handCards_:setTouchStatus(status)
end

function SeatView:checkHandCard(headValue,tailValue)
    local findCard = self.handCards_:checkCard(headValue,tailValue)
    print("SeatView:checkHandCard(headValue,tailValue)", findCard)
    if not findCard then
        self:setPassStatus(true)
    end
    self.findCard_ = findCard
    return self.findCard_
end

function SeatView:showDeadText()
    if self.handCards_ then
        self.handCards_:roundDead()
    end
end

function SeatView:showWaitText()
    self.waitBg_:setVisible(false)
end

function SeatView:hideWaitText()
    self.waitBg_:setVisible(false)
end

function SeatView:playExpChangeAnimation(expChange)
	-- 待实现 或许已经屏蔽了
    -- if expChange > 0 then
    --     local node = display.newNode()
    --     node:setCascadeOpacityEnabled(true)
    --     local exp = display.newSprite("#room_seat_exp.png"):addTo(node)
    --     local num = ui.newTTFLabel({
    --         text = "+"..expChange, 
    --         color = ccc3(0x1D, 0xBC, 0xFC), 
    --         size = 24, 
    --         align = ui.TEXT_ALIGN_CENTER
    --     }):addTo(node)
    --     local expW = exp:getContentSize().width
    --     local numW = num:getContentSize().width
    --     local w =  expW + numW
    --     exp:pos(w * -0.5 + expW * 0.5, 0)
    --     num:pos(w * 0.5 - numW * 0.5, 0)

    --     node:addTo(self, 99)
    --         :scale(0.4)
    --         :moveBy(0.8, 0, 92)
    --         :scaleTo(0.8, 1)
    --     node:runAction(transition.sequence({
    --         CCFadeIn:create(0.4),
    --         CCDelayTime:create(1.2),


    --         CCFadeOut:create(0.2),
    --         CCCallFunc:create(function()
    --             node:removeFromParent()
    --         end),
    --     }))
    -- end
end

function SeatView:playAutoBuyinAnimation(buyinChips)
	
end

function SeatView:playWinAnimation()
    if not self.seatData_ then return end

    --停止未播放完的动画
    self:stopWinAnimation_()

    --开始新的动画
    self.winnerAnimBatch_:setVisible(true)
    self.winnerAnimBatch_:fadeIn({time=0.5})

    self.win_text:moveTo({x=0,y=10,time=1 })

    self.winnerAnimBatch_:fadeOut({time=0.5, delay=2.5, onComplete=handler(self, function()
            self.winnerAnimBatch_:setVisible(false)
        end)})
end

function SeatView:stopWinAnimation_()
    self.winnerAnimBatch_:setVisible(false)
end

function SeatView:addPropertyObservers_()
    self.moneyObserverHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, function (obj, money)
        if not money then return end
        if self.chips_ and self.seatData_ and self.seatData_.isSelf and not nk.isInSingleRoom then
            print(money,"addPropertyObservers_addPropertyObservers_ money == ")
            self:setChipTxt(money)
        end
    end))

    self.miconObserverHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "micon", handler(self, function (obj, micon)
        if not nk.updateFunctions.checkIsNull(obj) and obj.seatData_ and obj.seatData_.isSelf then                    
            if not micon or not string.find(micon, "http")then
                -- 默认头像 
                local index = tonumber(micon) or 1
                obj.image_:setFile(nk.s_headFile[index])
                if nk.userData.msex and tonumber(nk.userData.msex) ==1 then
                    obj.image_:setFile(kImageMap.common_male_avatar)
                else
                    obj.image_:setFile(kImageMap.common_female_avatar)
                end
            else
                -- 上传的头像
                UrlImage.spriteSetUrl(obj.image_, micon)
            end           
        end
    end))
end

function SeatView:removePropertyObservers_()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "micon", self.miconObserverHandle_)
end

function SeatView:reset()
    print("SeatView:reset")
    self.handCards_:showAllCards()
    self.handCards_:showBackAll()
    self.handCards_:removeDarkAll()
    self.handCards_:stopShakeAll()
    self.handCards_:resetHandCards()
    self.handCards_:setVisible(false)
    self.handCards_:resetPos()
    self:hideWaitText()
    EventDispatcher.getInstance():dispatch(EventConstants.hideWaitTips)
    self:unfade()
    self:setPassStatus(false)
    nk.GCD.Cancel(self)

    self:stopWinAnimation_()
    self:setLastCards(0)

    if self:isEmpty() then
        self.lastAnteMoney = 0
    end
end

function SeatView:openGiftPopUpHandler()
    local roomUid = ""
    local roomOtherUserUidArray = ""
    local tableNum = 0
    local toUidArr = {}
    local level = self.ctx.model:roomType()
    for i=0,8  do
        if self.ctx.model.playerList[i] then
            if self.ctx.model.playerList[i].uid > 0 then
                tableNum = tableNum + 1
                roomUid = roomUid..","..self.ctx.model.playerList[i].uid
                roomOtherUserUidArray = string.sub(roomUid,2)
                table.insert(toUidArr, self.ctx.model.playerList[i].uid)
            end
        end
    end
    if self.ctx.model.playerList[self.seatId_] then
        nk.PopupManager:addPopup(GiftShopPopup,"roomGaple",1,true,self.ctx.model.playerList[self.seatId_].uid,roomOtherUserUidArray,tableNum,toUidArr,level)
    end
end


function SeatView:dtor()
    nk.GCD.Cancel(self)
    if self.handCards_ then
        self.handCards_:removeFromParent(true)
        delete(self.handCards_)
        self.handCards_ = nil
    end
    if self.changeChipAnim_ then
        self.changeChipAnim_:removeFromParent(true)
        delete(self.changeChipAnim_)
        self.changeChipAnim_ = nil
    end
    if self.giftUrlReqId_ then
        LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
    end
    self:removePropertyObservers_()
end


return SeatView


