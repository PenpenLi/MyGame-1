local AtlasManager = {}

local s_atlasConfig = {
	hall = require("view.atlas.hall"),
	common = require("view.atlas.common"),
	freeGold = require("view.atlas.freeGold"),
	login = require("view.atlas.login"),
	common2 = require("view.atlas.common2"),
	hddj1 = require("view.atlas.hddj1"),
	hddj2 = require("view.atlas.hddj2"),
	hddj3 = require("view.atlas.hddj3"),
	hddj5 = require("view.atlas.hddj5"),
	hddj6 = require("view.atlas.hddj6"),
	hddj7 = require("view.atlas.hddj7"),
	hddj8 = require("view.atlas.hddj8"),
	hddj9 = require("view.atlas.hddj9"),
	hddj12 = require("view.atlas.hddj12"),
	hddj13 = require("view.atlas.hddj13"),
	hddj14 = require("view.atlas.hddj14"),
	hddj15 = require("view.atlas.hddj15"),
	hddj16 = require("view.atlas.hddj16"),
	hddj17 = require("view.atlas.hddj17"),
	hddj18 = require("view.atlas.hddj18"),
	hddj19 = require("view.atlas.hddj19"),
	expNormal = require("view.atlas.expNormal"),
	expPunakawan = require("view.atlas.expPunakawan"),
	expPunakawan2 = require("view.atlas.expPunakawan2"),
	expression = require("view.atlas.expression"),
	expVip = require("view.atlas.expVip"),
	qiuqiu = require("view.atlas.qiuqiu"),
	roomRs = require("view.atlas.roomRs"),
	-- userInfo = require("view.atlas.userInfo"),
}

local s_cache = {}

function AtlasManager.SearchFileTable(fileName)
	if type(fileName) == "string" then 
		-- FwLog("fileName = " .. fileName)
		local onlyFileName = string.gmatch(fileName,"[^/\\]+$")()
		local prefix = string.gmatch(onlyFileName,"[^_]+")() --前缀，如果文件名中含有'_'
		if s_atlasConfig[prefix] and s_atlasConfig[prefix][onlyFileName] then
			-- FwLog("onlyFileName = " .. onlyFileName)
			-- if prefix == "hall" then
			-- 	FwLog(debug.traceback())
			-- end
			return s_atlasConfig[prefix][onlyFileName]
		end
		return nil
	end
	return nil
end


function AtlasManager.CacheFile(file)
	if not s_cache[file] then
		s_cache[file] = new(ResImage, file)
	end
end

function AtlasManager.RemoveFile(file)
	if s_cache[file] then
		delete(s_cache[file])
		s_cache[file] = nil
	end
end

return AtlasManager

--[[

common_blank打成大图后有问题，所以去掉了。
common_transparent同上
]]