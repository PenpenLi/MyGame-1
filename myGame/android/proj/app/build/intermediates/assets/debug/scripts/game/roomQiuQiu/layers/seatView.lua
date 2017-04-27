--
-- Author: tony
-- Date: 2014-07-08 14:28:57
--
local SeatView = class(GameBaseLayer, false)
local viewConfig = require(VIEW_PATH .. "roomQiuQiu.roomQiuQiu_seat_layer")
local varConfigPath = VIEW_PATH .. "roomQiuQiu.roomQiuQiu_seat_layer_layout_var"

local HandCard = import("game.roomQiuQiu.layers.handCard")
local CardPointBoard = import("game.roomQiuQiu.layers.cardPointBoard")
local RoomQiuQiuStateMachine = import("game.roomQiuQiu.roomQiuQiuStateMachine")
local GiftShopPopup = import("game.giftShop.giftShopPopup")
local LoadGiftControl = import("game.giftShop.loadGiftControl")
local StorePopup = require("game.store.popup.storePopup")
local ModifyCardIndexAni = require("game.roomQiuQiu.layers.ModifyCardIndexAni")

EventConstants.seatViewClicked = EventDispatcher.getInstance():getUserEvent();

SeatView.WIDTH = 108
SeatView.HEIGHT = 166

function SeatView:ctor(ctx, seatId)
    super(self, viewConfig, varConfigPath)
    local w, h = self.m_root:getSize()
    self:setSize(w, h)

    self.inviteState=false
    self.seatId_ = seatId
    self.positionId_ = seatId + 1

    self.m_baseNode = self:getUI("baseNode")
    self.m_imageNode = self:getUI("imageNode")
    
    -- self:setScale(0.8)
    self.seatIdLabel = self:getUI("seatId")
    self.seatIdLabel:setText(seatId)
    self.ctx = ctx
    -- 坐下按钮btn
    self.sitdown_ = self:getUI("sitdownImage")
    -- 用户头像Image
    self.image_ = self:getUI("headImage")
    -- vip icon
    self.vipIcon_ = self:getUI("View_vip")
    -- 用户头像剪裁
    self.image_ = Mask.setMask(self.image_, kImageMap.qiuqiu_seat_head_mask)
    self.image_:setVisible(false)
    -- 个人信息层（名字、状态、金币等）
    self.infoNode_ = self:getUI("infoNode")
    -- 状态文字
    self.state_ = self:getUI("stateLabel")
    -- 座位筹码文字
    self.chips_ = self:getUI("moneyLabel")
    -- 金币图标
    self.goldIcon_ = self:getUI("gold_icon")

    self.addGoldBtn = self:getUI("AddGoldBtn")
    self.addImage = self:getUI("AddImage")
    self.addGoldBtn:setEnable(false)
    self.addImage:setVisible(false)

    -- TODO 邀请玩家
    -- self.inviteFriendBtn=cc.ui.UIPushButton.new({normal= "#common_B_green_btn_up.png", pressed = "#common_B_green_btn_down.png"},{scale9 = true})
    --     :setButtonSize(110, 40)
    --     :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("LOGINREWARD", "INVITE_FRIEND"), size=14, color=ccc3(255,255,255), align=ui.TEXT_ALIGN_CENTER}))
    --     :onButtonClicked(handler(self, self.onClickInviteFriend))
    --     :setPos(0, -66)
    --     :addTo(self, 6, 6)
    --     :setVisible(false)

    -- 礼物
    self.giftImage_ = self:getUI("giftButton")
    self.giftImage_:setVisible(false)
    self.giftImage_:setOnClick(self,self.openGiftPopUpHandler)

    self.giftImage_big = self:getUI("gift_btn_big")
    self.giftImage_big:setOnClick(self,self.openGiftPopUpHandler)
    self.giftImage_big:setVisible(false)

    self.pokerNode_ = self:getUI("poker_node")


    -- 手牌
    self.handCards_ = new(HandCard, 0.8, handler(self, self.onCardsOrderChange))
    self.handCards_:setPos(115, 38)
    self.handCards_:addTo(self)
    -- 手牌点数
    self.pointBorad_ = new(CardPointBoard)
    self.pointBorad_:setPos(155, 0)
    self.pointBorad_:addTo(self.pokerNode_)
    self.pointBorad_:setVisible(false)

    --牌型确认动画
    self.modifyCardIndexAni = new(ModifyCardIndexAni)
    self.modifyCardIndexAni:addTo(self)
    self.modifyCardIndexAni:setLevel(3)

    -- winner动画
    self.winnerAnimBatch_ = self:getUI("winBorderView")
    self.winnerAnimBatch_:setVisible(false)
    self.winnerAnimBatch_:setLevel(100)
    
    -- winner文字 
    self.winner_ = self:getUI("winnerText")
    _, self.winnerY_ = self.winner_:getPos()
    -- 星星1
    self.winnerStar1_ = self:getUI("starImage1")
    -- 星星2
    self.winnerStar2_ = self:getUI("starImage2")
    -- 星星3
    self.winnerStar3_ = new(Image, kImageMap.qiuqiu_you_win_star)
    self.winnerStar3_:addTo(self.winnerAnimBatch_)
    -- 星星4
    self.winnerStar4_ = new(Image, kImageMap.qiuqiu_you_win_star)
    self.winnerStar4_:addTo(self.winnerAnimBatch_)

    -- 用于确定动画位置
    self.giftCenter_node = self:getUI("giftCenter_node")
    self.seatCenter_node = self:getUI("seatCenter_node")
    self.chatNodeLeft = self:getUI("chatBubble_node_left")
    self.chatNodeRight = self:getUI("chatBubble_node_right")
    -- 小牌堆节点
    self.small_poker_node = self:getUI("small_poker_node")

    -- 初始为站起状态
    self:standUpState_()

    -- 添加数据观察器
    self:addPropertyObservers_()
end

function SeatView:OnAddGoldClick()
    nk.payScene = consts.PAY_SCENE.QIUQIU_ROOM_HEADICON_PAY
    nk.PopupManager:addPopup(StorePopup)
end

--finish
function SeatView:showConfirmCardsIcon(isSelf)
    self.modifyCardIndexAni:setVisible(true)
    self.modifyCardIndexAni:onModifyFinish(self:getConfirmCardsIconPos(isSelf))
end
--waitting
function SeatView:showConfirmCardsIcon2(isSelf)
    self.modifyCardIndexAni:setVisible(true)
    self.modifyCardIndexAni:onModifyWaitting(isSelf,self:getConfirmCardsIconPos(isSelf))
end

function SeatView:getConfirmCardsIconPos(isSelf)
    local posX,posY = 0,0
    if isSelf then
        posX,posY = 157,20
    else
        local middleSeatId = 4
        if self.positionId_ > middleSeatId then
            posX,posY = 170,15
        else
            posX,posY = 18,15
        end
    end
    return posX,posY
end
function SeatView:hideConfirmCardsIcon()
    self.modifyCardIndexAni:setVisible(false)
    self.modifyCardIndexAni:reset()
end


function SeatView:playSitDownAnimation(onCompleteCallback)
    self.image_:setPos(0, -100)
    self.image_:setVisible(true)
    self.vipIcon_:setPos(50, -61)
    self.vipIcon_:setVisible(true)
    self.image_:fadeIn({time=0.5})
    self.vipIcon_:fadeIn({time=0.5})
    self.image_:moveTo({x=0, y=0, time=0.5, easing="backOut", onComplete=function() 
        self.sitdown_:setVisible(false)
        if onCompleteCallback then
            onCompleteCallback()
        end
    end})
    self.vipIcon_:moveTo({x=50, y=39, time=0.5, easing="backOut"})
end

function SeatView:playStandUpAnimation(onCompleteCallback)
    self.image_:setVisible(false)
    self.vipIcon_:setVisible(false)
    self.vipIcon_:removeAllChildren(true)

    self.sitdown_:setVisible(true)

    if self.ctx.model:getRoomInvite()==self.seatId_ then
        self.sitdown_:setVisible(false)
        self.image_:setPos(0, 0)
        self.image_:setVisible(true)
        self.vipIcon_:setPos(50,39)
        self.vipIcon_:setVisible(true)
        self.state_:setVisible(true)
    end
    if onCompleteCallback then
        onCompleteCallback()
    end
end

function SeatView:fade()
    -- self.m_baseNode:setColor(80,80,80)
    -- self.image_:setGray(true)
    self.image_:setColor(80,80,80)
    self.vipIcon_:setColor(80,80,80)
    self.giftImage_:setColor(128,128,128)
    self.giftImage_big:setColor(128,128,128)
end

function SeatView:unfade()
    -- self.m_baseNode:setColor(255,255,255)
    -- self.image_:setGray(false)
    self.image_:setColor(255,255,255)
    self.vipIcon_:setColor(255,255,255)
    self.giftImage_:setColor(255,255,255)
    self.giftImage_big:setColor(255,255,255)
end

function SeatView:sitDownState_()
    self.image_:stopAllActions()
    self.sitdown_:stopAllActions()
    self.vipIcon_:stopAllActions()
    self.image_:setPos(0, 0)
    self.image_:setVisible(true)
    self.vipIcon_:setPos(50,39)
    self.vipIcon_:setVisible(true)
    self.sitdown_:setVisible(false)
    if (nk.config.GIFT_SHOP_ENABLED) then
        self:setGiftIconVisible(true)
    end
end

function SeatView:standUpState_()
    self.image_:stopAllActions()
    self.vipIcon_:stopAllActions()
    self.sitdown_:stopAllActions()
    if self.inviteState then
        self.image_:setPos(0, 0)
        self.image_:setVisible(true)
        self.vipIcon_:setPos(50,39)
        self.vipIcon_:setVisible(true)
        self.sitdown_:setVisible(false)
        self.state_:setVisible(true)
    else
        self.image_:setPos(0, -100)
        self.image_:setVisible(false)
        self.vipIcon_:setPos(50,-61)
        self.vipIcon_:setVisible(false)
        self.vipIcon_:removeAllChildren(true)
        self.sitdown_:setVisible(true)
    end
    
    if (nk.config.GIFT_SHOP_ENABLED) then
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
    if (nk.config.GIFT_SHOP_ENABLED) then
        if id then
            if id==1 then
                self.giftImage_:setPos(-55, 10)
                self.giftImage_big:setPos(-55, 10)
                self.small_poker_node:setPos(45, 0)
            elseif id==2 then
                self.giftImage_:setPos(-55, 10)
                self.giftImage_big:setPos(-55, 10)
                self.small_poker_node:setPos(-60, 0)
            elseif id==3 then
                self.giftImage_:setPos(-55, 10)
                self.giftImage_big:setPos(-55, 10)
                self.small_poker_node:setPos(-60, 0)
            elseif id==4 then
                self.giftImage_:setPos(-55, 10)
                self.giftImage_big:setPos(-55, 10)
                self.small_poker_node:setPos(45, 0)
            elseif id==5 then
                self.giftImage_:setPos(55, 10)
                self.giftImage_big:setPos(55, 10)
                self.small_poker_node:setPos(45, 0)
            elseif id==6 then
                self.giftImage_:setPos(55, 10)
                self.giftImage_big:setPos(55, 10)
                self.small_poker_node:setPos(45, 0)
            elseif id==7 then
                self.giftImage_:setPos(55, 10)
                self.giftImage_big:setPos(55, 10)
                self.small_poker_node:setPos(-60, 0)
            else
                self.giftImage_:setPos(-55, 10)
                self.giftImage_big:setPos(-55, 10)
                self.small_poker_node:setPos(45, 0)
            end
        end
    end

end

function SeatView:resetToEmpty()
    self.seatData_ = nil
    self:updateState()
end

function SeatView:setSeatData(seatData)
    self.seatData_ = seatData   
    if seatData and seatData.isSelf then
        self.handCards_:setPos(115, 38)
        self.pointBorad_:setPos(155, 0)
    else
        self.handCards_:setPos(-26, 40)
        self.pointBorad_:setPos(16, -6)
    end
    
    if not seatData then
        self:reset()
        self:standUpState_()
    else
        if self.inviteState then
            print("---->getRoomInvite="..self.ctx.model:getRoomInvite().." self.seatId_="..self.seatId_)
            self.ctx.model:setRoomInvite(-2) 
            self.inviteState=false  
            self.fbFriendData=nil
        end

        self:sitDownState_()

        local mavatar = seatData.userInfo.mavatar
        if seatData.isSelf then
            mavatar = nk.userData.micon
        end
        if not mavatar or not string.find(mavatar, "http") then
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
        
        if nk.config.GIFT_SHOP_ENABLED and self.giftImage_ then
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
            vipk:addPropScaleSolid(0, 0.7, 0.7, kCenterDrawing);
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
    vipbs:addPropScaleSolid(0, 0.15, 0.15, kCenterDrawing);
    vipbs:setPos(15,18)
    node:addChild(vipbs) 

    local vipIcon = new(Image,"res/common/vip_big/v.png")
    node:addChild(vipIcon)
    vipIcon:addPropScaleSolid(0,0.8,0.8, kCenterDrawing)
    vipIcon:setPos(22,8)
    vipLevel = tonumber(vipLevel)

    if vipLevel >=10 then
        local num1 = math.modf(vipLevel/10)
        local num2 = vipLevel%10

        local vipNum1 = new(Image,"res/common/vip_big/" .. num1 .. ".png")
        vipNum1:setPos(32,8)
        vipNum1:addPropScaleSolid(0,0.8,0.8, kCenterDrawing)
        node:addChild(vipNum1)
        local vipNum2 = new(Image,"res/common/vip_big/" .. num2 .. ".png")
        vipNum2:setPos(41,8)
        vipNum2:addPropScaleSolid(0,0.8,0.8, kCenterDrawing)
        node:addChild(vipNum2)
    else
        local vipNum = new(Image,"res/common/vip_big/" .. vipLevel .. ".png")
        vipNum:setPos(32,8)
        vipNum:addPropScaleSolid(0,0.8,0.8, kCenterDrawing)
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
    if nk.config.GIFT_SHOP_ENABLED and self.giftImage_ then
        self.giftImage_:setFile(kImageMap.common_gift_icon)
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
    if string.find(imgurl, "http")then
        -- 上传的头像
        UrlImage.spriteSetUrl(self.image_, imgurl)
    end
end

--结算分池动画专用
--每次更新携带存一下上一次的携带，为了结算的时候要按奖池分配逐步更新携带筹码(txt内容已经格式化数字了get不回来)
local lastAnteMoney = 0
function SeatView:SetAniSeatChipTxt(value)
    if not value then
        return
    end
    --站起了这里会置空
    if not self.lastAnteMoney then
        return
    end

    self.lastAnteMoney = self.lastAnteMoney + value

    if self.lastAnteMoney < 100000 then
        self.chips_:setText(nk.updateFunctions.formatNumberWithSplit(self.lastAnteMoney))
    else
        self.chips_:setText(nk.updateFunctions.formatBigNumber(self.lastAnteMoney))
    end
end

function SeatView:SetSeatChipTxt(value)
    if not value then
        return
    end
    
    if value < 100000 then
        self.chips_:setText(nk.updateFunctions.formatNumberWithSplit(value))
    else
        self.chips_:setText(nk.updateFunctions.formatBigNumber(value))
    end
end
 
--处理站起来重置FB邀请
function SeatView:initFBInvite()
    print("---->initFBInvite")
    self.ctx.model:setRoomInvite(-1)
    self.inviteState=false
    self.fbFriendData=nil
end

function SeatView:aboutFB()
    -- TODO
    -- local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if self.ctx.model:getRoomInvite()==-1 and lastLoginType ==  "FACEBOOK" then
        self.inviteState=true
        self.ctx.model:setRoomInvite(self.seatId_)
        -- nk.Facebook:getInvitableFriends(handler(self, self.onGetData_))
    else
        if self.inviteState then
            self:setVisible(true)
            self.state_:setVisible(true)
            self.chips_:setVisible(false)
            self.infoNode_:setVisible(false)
            self.sitdown_:setVisible(false)
        else
            self:setVisible(false)
        end
    end
end

function SeatView:onGetData_(success, friendData, filterStr)
    if success then
        if self.seatData_ == nil then
            if self.ctx.model:isSelfInSeat()==false then
                self:setVisible(true)
                self.state_:setVisible(false)
                self.chips_:setVisible(false)
                self.infoNode_:setVisible(false)
                self.sitdown_:setVisible(true)
                -- self.inviteFriendBtn:setVisible(false)
                return
            end
        else
            return
        end
        -- 排除今日邀请过的
        -- local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")          
        if invitedNames ~= "" then
            local namesTable = string.split(invitedNames, "#")
            if namesTable[1] ~= os.date("%Y%m%d") then
                nk.userDefault:setTextForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
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
            self:setVisible(true)
            self.state_:setVisible(true)
            self.chips_:setVisible(false)
            self.infoNode_:setVisible(false)
            self.sitdown_:setVisible(false)       
            self.state_:setText(nk.updateFunctions.limitNickLength(self.fbFriendData["name"],8))
            self.state_:setColor(200,200,200)
            -- self.inviteFriendBtn:setVisible(true)
            
            self.image_:setFile(kImageMap.common_female_avatar)
            self:updateHeadImage(self.fbFriendData["url"])
            self.image_:setPos(0, 0)
            self.image_:setVisible(true)
        else
            self:setVisible(false)
        end
        
    end
end

function SeatView:onClickInviteFriend()
    print("---->onClickInviteFriend")
    if not self.fbFriendData then
        return
    end
    self:setVisible(false)
    self.inviteState=false

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
        nk.HttpController:execute("getInviteId", {game_param = {}}, nil, handler(self, function(obj, errorCode, data)
            if errorCode == HttpErrorType.SUCCESSED then
                local retData = data.data
                local requestData = ""
                requestData = retData.sk;

                nk.FacebookNativeEvent:invite(
                    requestData, 
                    toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT",nk.updateFunctions.formatBigNumber(nk.userData["inviteForRegist"])), 
                    function (success, result)
                        if success then
                            nk.AnalyticsManager:report("EC_R_Seat_Invite_Btn","invite")
                            -- 保存邀请过的名字
                            if names ~= "" then
                                local invitedNames = nk.DictModule:getString("inviteName", "data")
                                local inviteTable = {}
                                if invitedNames ~= "" then
                                    inviteTable= json.decode(invitedNames)
                                end
                                if inviteTable.time == os.date("%Y%m%d") then
                                    inviteTable.name = MegerTables(inviteTable.name or {}, nameArr)
                                else
                                    inviteTable.time = os.date("%Y%m%d")
                                    inviteTable.name = nameArr
                                end
                                nk.DictModule:setString("inviteName", "data", json.encode(inviteTable))
                                nk.DictModule:saveDict("inviteName")
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
                                requestid = result and result.requestId or "", 
                                toIds = result and result.toIds or "", 
                                source = "register"
                            }
                            postData.type = "register"

                            nk.HttpController:execute("inviteReport", {game_param = postData})

                            --显示邀请好友前的状态
                            self.ctx.model:setRoomInvite(self.seatId_)
                            self:updateState()
                        end
                    end)
            end
        end)
        )
    end
end

function SeatView:updateState()
    if self.seatData_ == nil then
        if self.ctx.model:isSelfInSeat() then
            self:aboutFB()
        else
            self.fbFriendData=nil
            self:setVisible(true)
            self.state_:setVisible(false)
            self.chips_:setVisible(false)
            self.infoNode_:setVisible(false)
            self.sitdown_:setVisible(true)
            -- self.inviteFriendBtn:setVisible(false)
            -- bm.EventCenter:dispatchEvent({name = nk.eventNames.ROOM_HIDE_SEAT_TIPS, data =false})
        end
        self.lastAnteMoney = nil
    else
        -- self.inviteFriendBtn:setVisible(false)
        self:setVisible(true)
        self.state_:setVisible(true)
        self.chips_:setVisible(true)
        self.chips_:setColor(255,209,0)
        self.goldIcon_:setColor(255,255,255)
        self.infoNode_:setVisible(true)
        self.sitdown_:setVisible(false)       
        if self.seatData_.isSelf then
            self.addGoldBtn:setEnable(true)
            self.addImage:setVisible(true)
        else
            self.addGoldBtn:setEnable(false)
            self.addImage:setVisible(false)
        end
        self.state_:setText(nk.updateFunctions.limitNickLength(self.seatData_.statemachine:getStateText(),8))
        self.state_:setColor(self.seatData_.statemachine:getStateTextColor())
        --除了结算阶段，存一下上次携带值(结算阶段的anteMoney已经是最终值，不能用来做加筹码动画)
        if self.ctx.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS_QIUQIU.TABLE_GAME_OVER_SHARE_BONUS then
            --站起了这里会置空
            if not self.lastAnteMoney then
                if self.seatData_.anteMoney < 100000 then
                    self.chips_:setText(nk.updateFunctions.formatNumberWithSplit(self.seatData_.anteMoney))
                else
                    self.chips_:setText(nk.updateFunctions.formatBigNumber(self.seatData_.anteMoney))
                end
            end
        else
            self.lastAnteMoney = self.seatData_.anteMoney

            if self.seatData_.anteMoney < 100000 then
                self.chips_:setText(nk.updateFunctions.formatNumberWithSplit(self.seatData_.anteMoney))
            else
                self.chips_:setText(nk.updateFunctions.formatBigNumber(self.seatData_.anteMoney))
            end
        end

        local sm = self.seatData_.statemachine
        local st = sm:getState()

        if st ~= RoomQiuQiuStateMachine.STATE_BETTING then
            self.handCards_:stopShakeAll()
        end

        if st == RoomQiuQiuStateMachine.STATE_WAIT_START or st == RoomQiuQiuStateMachine.STATE_FOLD then
            self:fade()
            -- self.image_:setGray(true)
            self.state_:setColor(128,128,128) 
            self.chips_:setColor(128,128,128)
            self.goldIcon_:setColor(128,128,128)
            
            --如果弃牌，点数置灰
            if st == RoomQiuQiuStateMachine.STATE_FOLD then
                self.pointBorad_:setFade(true)
            end
            --如果是自己，隐藏切牌提示
            if self.ctx.model:selfSeatId()==self.seatId_ then
                -- bm.EventCenter:dispatchEvent({name = nk.eventNames.ROOM_HIDE_SEAT_TIPS, data =false})
            end
            --如果是自己弃牌，则手牌变灰，不可点击
            if st == RoomQiuQiuStateMachine.STATE_FOLD and self.ctx.model:selfSeatId()==self.seatId_ then
                self.handCards_:addDarkWithNum(self.seatData_.cardsCount)
            end
        else
            -- self.image_:setGray(false)
            self:unfade()
            self.pointBorad_:setFade(false)
        end
    end
end

function SeatView:setCardPointBoardDard()
    self.pointBorad_:setFade(true)
end

function SeatView:setHandCardValue(cards)
    if cards then
        self.handCards_:setCards(cards)
    end
end

function SeatView:disableCardsTouch()
    self.handCards_:DisableCardsTouch()
    -- bm.EventCenter:dispatchEvent({name = nk.eventNames.ROOM_HIDE_SEAT_TIPS, data =false})
end

function SeatView:enableCardsTouch()
    self.handCards_:EnableCardsTouch()
    -- bm.EventCenter:dispatchEvent({name = nk.eventNames.ROOM_HIDE_SEAT_TIPS, data =true})
end

function SeatView:setHandCardNum(num)
    self.handCards_:setCardNum(num, self.ctx.model:selfSeatId() ~= self.seatId_)
end

function SeatView:showHandCards()
    self.handCards_:setVisible(true)
end

function SeatView:hideHandCards()
    self.handCards_:setVisible(false)
end

-- 显示正面牌
function SeatView:showHandCardBackAll()
    self.handCards_:showBackAll()
end

-- 显示背面牌
function SeatView:showHandCardFrontAll()
    self.handCards_:showFrontAll()
end

function SeatView:flipAllHandCards()
    self.handCards_:flipAll()
end

-- 隐藏所有牌
function SeatView:hideAllHandCardsElement()
    self.handCards_:hideAllCards()
end

-- 显示所有牌
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
    self.handCards_:shakeWithNum(4)
end

function SeatView:showCardTypeIf(cardType)
    if self.seatData_ then
	    self.pointBorad_:setVisible(true)
	    self.pointBorad_:setFade(false)
        
    	if cardType and cardType ~= consts.CARD_TYPE_QIUQIU.SPECIAL_NONE then
        	self.pointBorad_:setSpecialCard(cardType)
    	else 
        	self.pointBorad_:setPoint(self.handCards_:getLeftPoint(), self.handCards_:getRightPoint())
        end
    end
end

-- 卡牌顺序随机回调
-- 3张牌客户端随机， 4张牌请求server随机
function SeatView:onCardsOrderChange(cardNum)
    if not self.seatData_ or not self.seatData_.isSelf then
        return
    end

    if cardNum == 3 then
        self:showCardTypeIf(consts.CARD_TYPE_QIUQIU.SPECIAL_NONE)
    else
        --request server   
        local cardsUint = self.handCards_:getCardsUint()
        nk.SocketController:playerChangeCard(cardsUint[1],cardsUint[2],cardsUint[3],cardsUint[4])
    end
end

function SeatView:playAutoBuyinAnimation(buyinChips)
    -- local buyInBg = display.newSprite("#buyin-action-yellowbackground.png")
    --     :addTo(self, 6)
    -- local buyInBgSize = buyInBg:getContentSize()
    -- buyInBg:setPos(0, -SeatView.HEIGHT/2 + buyInBgSize.height/2)
    -- local buyInSequence = transition.sequence({
    --         CCFadeIn:create(0.5),
    --         CCFadeOut:create(0.5),
    --         CCCallFunc:create(function()
    --             buyInBg:removeFromParent()
    --         end),
    --     })
    -- buyInBg:runAction(buyInSequence)

    -- local buyInLabelPaddding = 20
    -- local buyInLabel = ui.newTTFLabel({
    --         text = "+"..buyinChips, 
    --         color = ccc3(0xf4, 0xcd, 0x56), 
    --         size = 32, 
    --         align = ui.TEXT_ALIGN_CENTER
    --     }):addTo(self, 6):setPos(0, -SeatView.HEIGHT/2 + buyInBgSize.height/2 + buyInLabelPaddding)

    -- local function spawn(actions)
    --     if #actions < 1 then return end
    --     if #actions < 2 then return actions[1] end

    --     local prev = actions[1]
    --     for i = 2, #actions do
    --         prev = CCSpawn:createWithTwoActions(prev, actions[i])
    --     end
    --     return prev
    -- end

    -- local buyInLabelSequence = transition.sequence({
    --         spawn({
    --             CCFadeTo:create(1, 0.7 * 255),
    --             CCMoveTo:create(1, ccp(0, SeatView.HEIGHT/2 - buyInBgSize.height/2 - buyInLabelPaddding)),
    --         }),
    --         CCCallFunc:create(function()
    --             buyInLabel:removeFromParent()
    --         end),
    --     })
    -- buyInLabel:runAction(buyInLabelSequence)
end

function SeatView:playWinAnimation()
    if not self.seatData_ then return end

    --停止未播放完的动画
    self:stopWinAnimation_()

    --开始新的动画
    self.winnerAnimBatch_:setVisible(true)
    self.winnerAnimBatch_:fadeIn({time=0.5})

    self.winner_:setPos(nil, self.winnerY_)
    self.winner_:moveTo({time=0.7, y=self.winnerY_-70})

    self.winnerAnimBatch_:fadeOut({time=0.5, delay=2.5, onComplete=handler(self, function()
            self.winnerAnimBatch_:setVisible(false)
        end)})
end

function SeatView:stopWinAnimation_()
    self.winnerAnimBatch_:setVisible(false)
    self.winnerStar1_:stopAllActions()
    self.winnerStar2_:stopAllActions()
    self.winnerStar3_:stopAllActions()
    self.winnerStar4_:stopAllActions()
end

function SeatView:getStateTextGlobalPos()
    -- return self:convertToWorldSpace(CCPoint(self.state_:getPositionX(),self.state_:getPositionY() ))
end

function SeatView:addPropertyObservers_()
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
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "micon", self.miconObserverHandle_)
end

function SeatView:reset()
    self.handCards_:showAllCards()
    self.handCards_:showBackAll()
    self.handCards_:removeDarkAll()
    self.handCards_:stopShakeAll()
    self.handCards_:resetHandCards()
    self.handCards_:setVisible(false)
    self:unfade()
    self.pointBorad_:setVisible(false)
    self.pointBorad_:reset()

    self:stopWinAnimation_()
    self.lastAnteMoney = nil
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
        nk.PopupManager:addPopup(GiftShopPopup,"roomQiuQiu",1,true,self.ctx.model.playerList[self.seatId_].uid,roomOtherUserUidArray,tableNum,toUidArr,level)
    end
end


function SeatView:dtor()
    delete(self.handCards_)
    self.handCards_ = nil
    if self.giftUrlReqId_ then
        LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
    end
    self:removePropertyObservers_()
end

------------------------------- UI function ------------------------------

function SeatView:onBgButtonClick()
    --nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    EventDispatcher.getInstance():dispatch(EventConstants.seatViewClicked, {seatId=self.seatId_, target=self,forInvite=self.fbFriendData});
end

return SeatView