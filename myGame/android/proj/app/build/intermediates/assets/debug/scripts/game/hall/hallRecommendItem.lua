
local varConfigPath = VIEW_PATH .. "hall.hall_player_item_layout_var"
local itemView = require(VIEW_PATH .. "hall.hall_player_item")

local HallRecommendItem = class(GameBaseLayer,false)

function HallRecommendItem:ctor(data,index)
	super(self, itemView);
    self:declareLayoutVar(varConfigPath)
    self.data = data
    self:setSize(self.m_root:getSize());
    self:init()

end

function HallRecommendItem:dtor()
	
end


function HallRecommendItem:init()
    self.m_playerBg = self:getUI("player_bg")
    self.m_playerBg:setSrollOnClick()
    self.m_head = self:getUI("head")
    self.m_head = Mask.setMask(self.m_head, kImageMap.common_head_mask_min)
    self.m_name = self:getUI("name")
    self.m_money = self:getUI("money")
    self.m_operatorBtn = self:getUI("trace_btn")
    self.m_operatorBtn:setSrollOnClick()
    self.m_operatorBtn:setVisible(false)
    self.m_name:setText(nk.updateFunctions.limitNickLength(self.data.name,8))
    if self.data.mid and self.data.mid == nk.userData.uid then
        self.m_playerBg:setFile("res/hall/hall_ownItem_bg.png")
    else
        self.m_playerBg:setFile("res/hall/hall_playerItem_bg.png")
    end
    self.m_money:setText(nk.updateFunctions.formatBigNumber(self.data.money))

    if not string.find(self.data.micon, "http")then
        -- 默认头像 
        if self.data.msex and tonumber(self.data.msex) ==1 then
            self.m_head:setFile(kImageMap.common_male_avatar)
        else
            self.m_head:setFile(kImageMap.common_female_avatar)
        end
    else
        -- 上传的头像
        UrlImage.spriteSetUrl(self.m_head, self.data.micon)
    end  
    self.m_sex = self:getUI("SexIcon")
    if tonumber(self.data.msex) ==1 then
        self.m_sex:setFile(kImageMap.common_sex_man_icon)
    else
        self.m_sex:setFile(kImageMap.common_sex_woman_icon)
    end
    if self.data.vip  and tonumber(self.data.vip)>0 then
        local vipk = new(Image,"res/common/vip_head_kuang.png")
        vipk:setAlign(kAlignCenter)
        vipk:addPropScaleSolid(0, 0.5, 0.5, kCenterDrawing);
        vipk:setPos(-80,0)
        self:addChild(vipk)
        local vipbs = new(Image, kImageMap.vip_bs)
        vipbs:setAlign(kAlignCenter)
        vipbs:addPropScaleSolid(0, 0.2, 0.2, kCenterDrawing);
        vipbs:setPos(-100,-20)
        self:addChild(vipbs)
        self.m_name:setColor(0xa0,0xff,0x00)
    end
end

function HallRecommendItem:onPlayerBgClick()
    if self.data.mid and self.data.mid == nk.UserDataController.getUid() then
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Hall")
    else
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Friend", self.data)
    end 
end

function HallRecommendItem:onOperatorBtnClick()
    if self.data.roomid and self.data.roomid > 0 and self.data.mid then
        nk.AnalyticsManager:report("New_Gaple_profit_track", "profit")
        nk.SocketController:trackFriend(self.data.mid)
        EnterRoomManager.getInstance():enterRoomLoading() 
    end
end


return HallRecommendItem