-- ImageCacheSerialize.lua
-- Last modification : 2016-06-2
-- Description: a utils for image cache, manager images cache save time

local ImageCacheSerialize = class();

ImageCacheSerialize.s_cachePath = System.getStorageDictPath();
ImageCacheSerialize.s_tab = "";

function ImageCacheSerialize:ctor(fileName, lastDays)
	self.m_name = fileName;
	self.m_lastDays = lastDays;
	self.m_cache = self:load(fileName, lastDays) or {};
end 

function ImageCacheSerialize:dtor()
	self:save();
	self.m_cache = nil;
	self.m_lastDays = 7;
	self.m_name = nil;
end 

function ImageCacheSerialize:get(url)
	local name = self.m_cache[url] or "";
	local path = System.getStorageImagePath()..name;
	local fp = io.open(path, "r");
	if name~="" and fp then
		io.close(fp);
		return name;
	end
	self.m_cache[url] = nil;
	return nil; 
end

function ImageCacheSerialize:set(url, fileName)
	self.m_cache[url] = fileName;
end

function ImageCacheSerialize:load()
	local filePath = ImageCacheSerialize.s_cachePath..self.m_name;
	local file = io.open(filePath,"r");
	if not file then 
		return;
	else 
		file:close()
		local isSuccess, content = pcall(dofile, filePath);
		if isSuccess then 
			return self:clearCache( content, self.m_lastDays);
		else 
			return;
		end 
	end 
end

function ImageCacheSerialize:save()
	local fileName = ImageCacheSerialize.s_cachePath..self.m_name;
	local file = io.open(fileName,"w");
	if not file then 
		return;
	end 

	file:write("return ");
	self:writeValue(file, self.m_cache);
	file:close();
end 

function ImageCacheSerialize:clearAll()
	self.m_cache = {};
end

function ImageCacheSerialize:clearFile(url)
	self.m_cache[url] = nil;
	self:save();
end

-------------------------------------------------------
--清除day天之前的数据,但图片不删除
function ImageCacheSerialize:clearCache(cache, day)
	local ret = {};
	local now = os.time();
	local lastTime = now-day*24*60*60;--seconds
	if cache and day then
		local time,pos,len;
		for k, v in pairs(cache) do
			pos,len = string.find(v,".png");
			time = tonumber(string.sub(v, 1, 10));
            if time and lastTime then 
			    if time>=lastTime then
				    ret[k] = v;
			    end 
            end
		end
		
		return ret;
	end
	return cache;
end

function ImageCacheSerialize:writeTable(fileName,src)
	if type(src) ~= "table" then 
		return;
	end 

	local tab = ImageCacheSerialize.s_tab;
	ImageCacheSerialize.s_tab = ImageCacheSerialize.s_tab .. "	";

	fileName:write("{\n");
	for k,v in pairs(src) do 
		if type(k) == "string" or type(k) == "number" then
			fileName:write(ImageCacheSerialize.s_tab);
			self:writeKey(fileName,k);
			self:writeValue(fileName,v);			
		end 
	end 
	fileName:write(tab.."}");
	ImageCacheSerialize.s_tab = tab;
end

function ImageCacheSerialize:writeString(fileName,value)
	fileName:write("\"");
	fileName:write(value);
	fileName:write("\"");
end 

function ImageCacheSerialize:writeBoolean(fileName,value)
	fileName:write(tostring(value));
end

function ImageCacheSerialize:writeNumber(fileName,value)
	fileName:write(value);
end

function ImageCacheSerialize:writeKey(fileName,key)
	fileName:write("[");
	if type(key) == "string" then 
		self:writeString(fileName,key);
	else 
		self:writeNumber(fileName,key);
	end
	fileName:write("] = ");
end 

function ImageCacheSerialize:writeValue(fileName,v)
	if type(v) == "table" then 
		self:writeTable(fileName,v);
	elseif type(v) == "string" then
		self:writeString(fileName,v);
	elseif type(v) == "boolean" then
		self:writeBoolean(fileName,v);	
	else 	
		fileName:write(v);
	end
	fileName:write(";\n");
end

return ImageCacheSerialize