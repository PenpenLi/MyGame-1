
local PropItem = class(Node)

function PropItem:ctor(id,isVipOnly)
    self.id = id
    self.isVipOnly = isVipOnly
    self:initScene()
end

function PropItem:initScene()
	local btn = new(Button,"res/userInfo/userInfo_prop_expression_bg.png")

	local item_w, item_h = btn:getSize()
	self:setSize(item_w, item_h)

    btn:setOnClick(self, self.onPropClick)
    btn:setSrollOnClick()

    local propIcon = nil 
    local scale = 1
    if self.id == 1 then
        propIcon = new(Image,"res/room/hddj/hddj_1.png")
        scale = 1.3
    elseif self.id == 10 then
        propIcon = new(Image,"res/room/hddj/hddj_tissue_icon.png")
        scale = 1.1
    elseif self.id == 4 then
        propIcon = new(Image,"res/room/hddj/hddj_kiss_lip_icon.png")
        scale = 1.3
    elseif self.id == 5 then
        propIcon = new(Image,"res/room/hddj/hddj_5.png")
        scale = 0.75
    elseif self.id == 6 then
        propIcon = new(Image,"res/room/hddj/hddj_6.png")
        scale = 0.5
    elseif self.id == 7 then
        propIcon = new(Image,"res/room/hddj/hddj_7.png")
        scale = 1.4
    elseif self.id == 8 then
        propIcon = new(Image,"res/room/hddj/hddj_8.png")
        scale = 0.9
    elseif self.id == 11 then
        propIcon = new(Image,"res/room/hddj/hddj_" .. self.id .. ".png")
        scale = 1.1
    elseif self.id == 12 then
        propIcon = new(Image,"res/room/hddj/hddj_" .. self.id .. ".png")
        scale = 1.1
    elseif self.id == 13 then
        propIcon = new(Image,"res/room/hddj/hddj_bone.png")
        scale = 0.9
    elseif self.id == 14 then 
        propIcon = new(Image,"res/room/hddj/hddj_14.png")
        scale = 0.6
    elseif self.id == 15 then
        propIcon = new(Image,"res/room/hddj/hddj_gun.png")
        scale = 0.6
    elseif self.id == 16 then
        propIcon = new(Image,"res/room/hddj/hddj_durian.png")
        scale = 0.7
    elseif self.id == 17 then
        propIcon = new(Image,"res/room/hddj/hddj_cake.png")
        scale = 0.7
    elseif self.id == 18 then
        propIcon = new(Image,"res/room/hddj/hddj_dragonfly.png")
        scale = 1
    elseif self.id == 19 then
        propIcon = new(Image,"res/room/hddj/hddj_shield.png")
        scale = 0.6
    else
        propIcon = new(Image,"res/room/hddj/hddj_" .. self.id .. ".png")
        scale = 0.6
    end
    
    if propIcon then
        propIcon:setAlign(kAlignCenter)
        btn:addChild(propIcon)
        propIcon:addPropScaleSolid(0, scale, scale, kCenterDrawing);
    end
    if self.isVipOnly then
        local vip = new(Image,"res/common/vip_small/v.png") 
        vip:setPos(0,-40)
        vip:setAlign(kAlignCenter)
        btn:addChild(vip)
        local num = new(Image,"res/common/vip_small/1.png") 
        num:setPos(14,-41)
        num:setAlign(kAlignCenter)
        btn:addChild(num)
    end

    self:addChild(btn)
end

function PropItem:setDelegate(obj, fun)
	self.delegate_obj = obj
	self.delegate_fun = fun
end

function PropItem:onPropClick()
    nk.AnalyticsManager:report("New_Gaple_HDDJ_"..self.id, "HDDJ")
    if not self.isVipOnly or (checkint(nk.userData.vip)>0) then
    	if self.delegate_obj and self.delegate_fun then
            nk.AnalyticsManager:report("New_Gaple_prop", "prop")
    		self.delegate_fun(self.delegate_obj, self.id)
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "NOT_VIP_TIP"))
	end
end

return PropItem