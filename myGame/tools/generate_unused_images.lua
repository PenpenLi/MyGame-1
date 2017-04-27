----[[
require("lfs")

function collectFileNamesInDirectory (path, wefind, r_table, intofolder, fileType)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local fname = file
            if string.find(f, wefind) ~= nil then
                table.insert(r_table, f)
            end
            local attr = lfs.attributes(f)
            assert (type(attr) == "table")
            if attr.mode == "directory" and intofolder then
                collectFileNamesInDirectory (f, wefind, r_table, intofolder, fileType)
            end
        end
    end
end

function checkIsUsedInFile( file, name )
	for line in file:lines() do
		if string.find(line, name) then
			return 1
        elseif string.gmatch(name, "%d")() then
            local pattern = string.gsub(name, "%d+", ".+")
            if string.gmatch(line, pattern)() then
                return 1
            end
		end
	end
	return 0
end

--]]


----[[
local currentFolder = "E:/dominogaple_engine/dominogaple/runtime/Resource/images/res"
local input_table_png = {}
collectFileNamesInDirectory(currentFolder, "%.png", input_table_png, true, "png")    -- "%.png$"
print("asset sum up to " .. #input_table_png);
--]]

----[[
local currentFolder = "E:/dominogaple_engine/dominogaple/runtime/Resource/scripts"
local input_table_lua = {}
collectFileNamesInDirectory(currentFolder, "%.lua", input_table_lua, true, "lua")    -- "%.lua$"
print("lua sum up to " .. #input_table_lua);
--]]

----[[
local count = 0;
for _, imageFile in pairs(input_table_png) do
    local imageName = string.gmatch(imageFile,"[^/\\]+$")()
	local flag = 0
	for _,fileName in pairs(input_table_lua) do
		local fileInfo = io.open(fileName, "r")
		flag = checkIsUsedInFile(fileInfo, imageName)
        io.close(fileInfo)
        if flag == 1 then break end
	end
	if flag == 0 then
		print(imageFile)
		count = count + 1
	end
end
print("total unused image sum up to " .. count)
--]]

-- t = {}
--      s = "from=world, to=Lua"
-- 	 local cd = string.gmatch(s, "(%w+)=(%w+)")
--      for k, x, v,c in string.gmatch(s, "(%w+)=(%w+)") do
--        t[k] = v
-- 	   print("v = ", x,v, c)
--      end



