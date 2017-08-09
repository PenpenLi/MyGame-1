--
-- Author: ziway
-- Date: 2016-10-18 17:18:00
--

local varConfigPath = VIEW_PATH .. "firstRecharge.firstPayTypeItem_layout_var"
local itemView = require(VIEW_PATH .. "firstRecharge.firstPayTypeItem")

local FirstPayTypeItem = class(GameBaseLayer,false);

function FirstPayTypeItem:ctor(data)
	super(self, itemView);
    self:declareLayoutVar(varConfigPath)
    self.width_ = self.m_root:getSize()
    self:setSize(self.m_root:getSize())
    self:init()
    self:setData(data)

    self:addPropertyObservers_()
    -- EventDispatcher.getInstance():register(EventConstants.talkingWithWho, self, self.updataBg)
end

function FirstPayTypeItem:dtor()
    self:removePropertyObservers()
    -- EventDispatcher.getInstance():unregister(EventConstants.talkingWithWho, self, self.updataBg)
end

function FirstPayTypeItem:init()
    self.m_root:setPos(6,10)

	self.m_bg = self:getUI("itemBg")
	self.m_itemView = self:getUI("itemView")
end

function FirstPayTypeItem:setData(data)
	self.data = data

	local index = checkint(data.pmode)
	
    self.m_itemView:setFile("res/payType/first_recharge_"..index.."_icon.png")
    self.m_itemView:setSize(self.width_)


    if data.isSelected then
    	self.m_bg:setFile("res/common/pay_select.png")
    else
    	self.m_bg:setFile("res/common/common_blank.png")
    end
    self.m_bg:setSize(self.width_)
end

function FirstPayTypeItem:addPropertyObservers_()
    
end

function FirstPayTypeItem:removePropertyObservers()
    
end

return FirstPayTypeItem
