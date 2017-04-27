
local function profile()
	local node = new(Text, "Test", 0, 20, kAlignLeft,"", 18, 255, 255, 255);
	node:addToRoot()
	node:setLevel(10000)
	local frameIndex = 0
	local timePast = 0
	local timeStart = os.clock()
	Clock.instance():schedule(function(dt)
		frameIndex = frameIndex + 1
		timePast = timePast + dt
		-- timePast = os.clock() - timeStart
		-- FwLog("timePast = " .. timePast .. ",frameIndex = " .. frameIndex .. ",dt = " .. dt .. ", Clock.delta = " .. (Clock.instance().delta or 0))
		if timePast > 1 then
			frameIndex = math.floor(frameIndex / timePast)
			local tm = math.floor(MemoryMonitor.instance().texture_size/(1024*1024) * 100)/100
			node:setText("FPS:" .. frameIndex .. "(" .. math.floor(Clock.instance().fps) .. ")" .. ", Memory:" .. tm .. "MB")
			timeStart = os.clock()
			timePast = 0
			frameIndex = 0
		end
	end) 
end

return {profile = profile}