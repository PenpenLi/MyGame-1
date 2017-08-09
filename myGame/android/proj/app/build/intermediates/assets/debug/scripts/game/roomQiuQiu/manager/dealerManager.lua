--
-- Author: tony
-- Date: 2014-07-08 13:22:01
--
local DealerManager = class()
local RoomViewPosition = import("game.roomQiuQiu.layers.roomViewPosition")
local RoomDealer = import("game.roomQiuQiu.layers.roomDealer")

function DealerManager:ctor()
end

function DealerManager:createNodes()
    -- 加入荷官
	self.m_dealerImage = self.scene.nodes.dealerNode:getChildByName("dealerImage")
    self.m_dealerImage:setEventTouch(self, self.onDealerImageTouch)

    self.roomDealer_ = new(RoomDealer,self.scene.nodes)
    self.roomDealer_:setAlign(kAlignCenter)
    self.scene.nodes.dealerNode:addChild(self.roomDealer_)
end

function DealerManager:kissPlayer()
	self.m_dealerImage:setVisible(false)
    self.roomDealer_:kissPlayer(handler(self, function(obj)
    	if not nk.updateFunctions.checkIsNull(obj) then
			obj.m_dealerImage:setVisible(true)
		end
    end))

    return self
end

function DealerManager:tapTable()
	self.m_dealerImage:setVisible(false)
    self.roomDealer_:tapTable(handler(self, function(obj)
    	if not nk.updateFunctions.checkIsNull(obj) then
			obj.m_dealerImage:setVisible(true)
		end
    end))

    return self
end

function DealerManager:onDealerImageTouch(finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self.roomDealer_:onShowAnim_()
    end
end

function DealerManager:dtor()
end

return DealerManager