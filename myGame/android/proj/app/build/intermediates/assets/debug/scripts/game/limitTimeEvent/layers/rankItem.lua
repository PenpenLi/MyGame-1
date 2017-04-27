-- rankItem.lua

local varConfigPath = VIEW_PATH .. "limitTimeEvent.rank_item_view_layout_var"
local itemView = require(VIEW_PATH .. "limitTimeEvent.rank_item_view")


local RankItem = class(GameBaseLayer,false)

function RankItem:ctor(data)
	super(self, itemView)
    self:declareLayoutVar(varConfigPath)

    self:setSize(self.m_root:getSize())

    self.m_data = data 

	self:initScene()
end

function RankItem:dtor()
	
end

function RankItem:initScene()
	self.m_headButton = self:getUI("headButton")
	self.m_headButton:addPropScaleSolid(0, 0.75, 0.75, kCenterDrawing)
	self.m_headImage = self:getUI("headImage")
	self.m_headImage = Mask.setMask(self.m_headImage, kImageMap.common_head_mask_min)
	self.m_vipk = self:getUI("Vipk")
	self.m_curNum = self:getUI("cur_num")
	self.m_curNum:setText(self.m_data.num or 0)
	if self.m_data.vip and self.m_data.vip > 0 then
		self.m_vipk:setFile("res/common/common_choose_small.png")
        self.m_vipk:setSize(75,75)

        self:drawVip(self.m_data.vip)
	end

	self:updataPlayerIcon()
end

function RankItem:updataPlayerIcon()
	self.m_data.micon = self.m_data.micon or ""
    if not string.find(self.m_data.micon, "http")then
        -- 默认头像 
        local index = tonumber(self.m_data.micon) or 1
        self.m_headImage:setFile(nk.s_headFile[index])
        if self.m_data.msex and tonumber(self.m_data.msex) ==1 then
            self.m_headImage:setFile(kImageMap.common_male_avatar)
        else
            self.m_headImage:setFile(kImageMap.common_female_avatar)
        end
    else
        -- 上传的头像
        UrlImage.spriteSetUrl(self.m_headImage, self.m_data.micon)
    end  
end


function RankItem:drawVip(vipLevel)
	local node = new(Node)
	self:addChild(node)
	node:addPropScaleSolid(0, 0.75, 0.75, kCenterDrawing);
    node:removeAllChildren(true)
    local vipIcon = new(Image,"res/common/vip_small/v.png")
    node:addChild(vipIcon)
    vipIcon:setPos(10,0)
    vipLevel = tonumber(vipLevel)

    if vipLevel >=10 then
        local num1 = math.modf(vipLevel/10)
        local num2 = vipLevel%10

        local vipNum1 = new(Image,"res/common/vip_small/" .. num1 .. ".png")
        vipNum1:setPos(50,4)
        node:addChild(vipNum1)
        local vipNum2 = new(Image,"res/common/vip_small/" .. num2 .. ".png")
        vipNum2:setPos(57,4)
        node:addChild(vipNum2)
    else
        local vipNum = new(Image,"res/common/vip_small/" .. vipLevel .. ".png")
        vipNum:setPos(50,4)
        node:addChild(vipNum)
    end   
end

function RankItem:onHeadButtonClick()
    if self.m_data.mid and self.m_data.mid == nk.UserDataController.getUid() then
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Hall")
    else
        nk.PopupManager:addPopup(require("game.userInfo.personalInfoPopup"), "Friend", self.m_data)
    end 
end

return RankItem