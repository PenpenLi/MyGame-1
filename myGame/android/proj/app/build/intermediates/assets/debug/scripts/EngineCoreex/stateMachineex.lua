-- stateMachineex.lua
-- Last modification : 2016-05-25
-- Description: a ex recover stateMachine some function in core

StateMachine.getNewState = function(self, state, ...)
	local nextStateIndex;
	for i,v in ipairs(self.m_states) do 
		if v.state == state then
			nextStateIndex = i;
			break;
		end
	end
	
	local nextState;
	if nextStateIndex then
		nextState = table.remove(self.m_states,nextStateIndex);
	else
		nextState = {};
		nextState.state = state;
		if StatesMap[state] then
				local stateObj = require(StatesMap[state]);
				nextState.stateObj = new(stateObj,...);
			end			
		end
		
	return nextState,(not nextStateIndex);
end

StateMachine.getRunningState = function(self)
    return self.m_states[#self.m_states]
end

local changeState= StateMachine.changeState
StateMachine.changeState = function(self, state, style, ...)
	if error_text then
		nk.functions.removeFromParent(error_text,true)
		delete(error_text)
		error_text = nil 
	end
	TextureCache.instance():clean_unused()
	return changeState(self, state, style, ...)
end


local pushState= StateMachine.pushState
StateMachine.pushState = function(self, state, style, isPopupState, ...)
	if error_text then
		nk.functions.removeFromParent(error_text,true)
		delete(error_text)
		error_text = nil 
	end
	TextureCache.instance():clean_unused()
	pushState(self, state, style, isPopupState, ...)
end