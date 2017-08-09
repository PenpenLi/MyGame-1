
local spriteSheets = {
	require("view/spriteSheets/cardType.lua"),
	require("view/spriteSheets/hall.lua"),
}

local function processFile(file)
	-- do return file end
	if type(file) == "string" then
		-- local file = string.gsub("res/chat/chat_change_btn_bg.png", "%s.png", "")
		local fileName = string.gmatch(file, "[^/\\]+.png")()
		if fileName then
			FwLog("processFile" .. fileName)
			local len = #spriteSheets
			for i = 1, len do
				if spriteSheets[i][fileName] then
					FwLog("get the sprite sheet")
					return spriteSheets[i][fileName]
				end
			end
		end
	end
	return file
end

return {
	processFile = processFile,
}