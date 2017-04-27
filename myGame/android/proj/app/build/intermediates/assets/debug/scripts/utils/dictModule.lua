-- dictModule.lua
-- Last modification : 2016-05-20
-- Description:  order to Control dict

local DictModule = class();

-- Get DictModule Instance
function DictModule.getInstance()
	if not DictModule.s_instance then 
		DictModule.s_instance = new(DictModule);
	end
	return DictModule.s_instance;
end

-- Release DictModule Instance
function DictModule.releaseInstance()
	delete(DictModule.s_instance);
	DictModule.s_instance = nil;
end

function DictModule:ctor()
	self.dicts = {}
end

function DictModule:newDict(dictName, canClear)
	local dict
	local isExist, dict_ = false, nil
	isExist, dict_ = self:isDictExist(dictName)
	if isExist then
		dict = dict_
	else
		dict = new(Dict, dictName)

		local dictInfo = {}
		dictInfo.name = dictName
		dictInfo.canClear = canClear
		dictInfo.dict = dict

		table.insert(self.dicts,dictInfo)
		dict:load();
	end
	return dict
end

function DictModule:isDictExist(dictName)
	local isExist = false
	local dict = nil
	for k, v in pairs(self.dicts) do
		if v.name == dictName then
			isExist = true
			dict = v.dict
			break
		end
	end
	return isExist, dict
end

function DictModule:getDictByName(dictName)
	return self:newDict(dictName)
end

function DictModule:clearDict(dictName)
	for k, v in pairs(self.dicts) do
		if v.name == dictName and v.canClear then
			v.dict:delete()
			v.dict:save()
			break
		end
	end
end

function DictModule:clearAllDict(dictName)
	for k, v in pairs(self.dicts) do
		if v.canClear then
			v.dict:delete()
			v.dict:save()
		end
	end
end

function DictModule:deleteDict(dictName)
	for k, v in pairs(self.dicts) do
		if v.name == dictName then
			-- to do 
			break
		end
	end
end

function DictModule:deleteAllDict(dictName)
	for k, v in pairs(self.dicts) do
		-- to do 
	end
	self.dicts = {}
end

function DictModule:setBoolean(dictName, key, value)
	local dict = self:getDictByName(dictName)
	if dict then
		dict:setBoolean(key, value)
	end
end

function DictModule:getBoolean(dictName, key, defaultValue)
	local dict = self:getDictByName(dictName)
	if dict then
		return dict:getBoolean(key, defaultValue)
	end
end

function DictModule:setInt(dictName, key, value)
	local dict = self:getDictByName(dictName)
	if dict then
		dict:setInt(key, value)
	end
end

function DictModule:getInt(dictName, key, defaultValue)
	local dict = self:getDictByName(dictName)
	if dict then
		return dict:getInt(key, defaultValue)
	end
end

function DictModule:setDouble(dictName, key, value)
	local dict = self:getDictByName(dictName)
	if dict then
		dict:setDouble(key, value)
	end
end

function DictModule:getDouble(dictName, key, defaultValue)
	local dict = self:getDictByName(dictName)
	if dict then
		return dict:getDouble(key, defaultValue)
	end
end

function DictModule:setString(dictName, key, value)
	local dict = self:getDictByName(dictName)
	if dict then
		dict:setString(key, value)
	end
end

function DictModule:getString(dictName, key)
	local dict = self:getDictByName(dictName)
	if dict then
		return dict:getString(key)
	end
end

function DictModule:saveDict(dictName)
	local dict = self:getDictByName(dictName)
	if dict then
		dict:save()
	end
end

return DictModule