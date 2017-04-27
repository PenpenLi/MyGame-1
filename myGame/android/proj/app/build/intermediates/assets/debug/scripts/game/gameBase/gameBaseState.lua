-- gameBaseState.lua
-- Last modification : 2016-05-11
-- Description: extend gameState class in core 

GameBaseState = class(GameState);

function GameBaseState:ctor()
    Log.printInfo("GameBaseState.ctor");
end

-- @Override 
function GameBaseState:gobackLastState()
	if nk.ignoreBack then
		return
	end
	if not nk.PopupManager:dismissDialog() then  
	    if self.m_controller and self.m_controller.onBack then
	        self.m_controller.onBack(self.m_controller);
	    end
	end
end

-- @Override 
function GameBaseState:getController()
    return self.m_controller;
end

function GameBaseState:dtor()
	delete(self.m_controller)
	self.m_controller = nil
end


