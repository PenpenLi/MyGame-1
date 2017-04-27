
package.preload[ "editorRT/sceneLoader" ] = function( ... )

SceneLoader = class();

SceneLoader.preloadDict = {}

SceneLoader.registLoadFunc = function(name, func)
	SceneLoader.loadFuncMap[name] = func;
end

SceneLoader.setPreload = function(t, root)
	SceneLoader.preloadDict[t] = SceneLoader.preloadDict[t] or {}
	root:setVisible(false)
	table.insert(SceneLoader.preloadDict[t], root)
end

SceneLoader.getPreload = function(t)
	local preloadDictArr = SceneLoader.preloadDict[t]
	if preloadDictArr and #preloadDictArr > 0 then
		local root = preloadDictArr[#preloadDictArr]
		preloadDictArr[#preloadDictArr] = nil
		root:setVisible(true)
		return root
	end
end

SceneLoader.load = function(t)
	if type(t) ~= "table" then
		return;
	end
	local root = SceneLoader.getPreload(t);
	if root then 
		root:addToRoot()
		return root 
	end
	local isPreset = t.isPreset;
	root = SceneLoader.loadUI(t);
	if isPreset ~= 1 then
		for _,v in ipairs(t) do
			local node = SceneLoader.privateload(v);
			root:addChild(node);
		end
	end
	root:addToRoot();
	return root;
end

SceneLoader.privateload = function(t)
	if type(t) ~= "table" then
		return;
	end
	local root;
	local isPreset = t.isPreset;
	root = SceneLoader.loadUI(t);
	if isPreset ~= 1 then
		for _,v in ipairs(t) do
			local node = SceneLoader.privateload(v);
			root:addChild(node);
		end
	end
	root:addToRoot();
	-- root:addToRoot();
	return root;
end

-- private static function
local function loadWithCoroutine(t, threadInfo)
	if type(t) ~= "table" then
		return;
	end
	local root;
	local isPreset = t.isPreset;
	root = SceneLoader.loadUI(t);
	if not threadInfo.root then threadInfo.root = root end
	local past = (os.clock() - threadInfo.clock) * 1000
	if(past > threadInfo.threshold) then
		FwLog("past in loadWithCoroutine before yield " .. past .. " and t.name = " .. t.typeName .. ":" .. (t.file or t.string or "None"))
		coroutine.yield("suspend", past, t)
	else
		FwLog("past in loadWithCoroutine = " .. past)
	end
	if isPreset ~= 1 then
		for _,v in ipairs(t) do
			local node = loadWithCoroutine(v, threadInfo)
			root:addChild(node);
		end
	end
	
	-- root:addToRoot();
	return root;
end

SceneLoader.loadAsync = function(config, func)
	local threadInfo = {clock = os.clock(), threshold = 5}
	Clock.instance():schedule_once(function()
		SceneLoader.loadAsyncDelay(config, func, threadInfo)
	end)
	return threadInfo
end

SceneLoader.loadAsyncDelay = function(config, func, threadInfo)
	local thread = coroutine.create(loadWithCoroutine)
	local threadInfo = threadInfo or {clock = os.clock(), threshold = 5}
	local status, ret, past = coroutine.resume(thread, config, threadInfo)
	if ret == "suspend" then
		-- FwLog("past = " .. past)
		Clock.instance():schedule(function()
			if threadInfo.killed then 
				thread = nil
				delete(threadInfo.root)
				return true 
			end
			threadInfo.clock = os.clock()
			local status, ret, past = coroutine.resume(thread)
			if ret ~= "suspend" then
				if ret then
					ret:addToRoot()
				end
				func(ret)
				return true
			end
		end)
	elseif ret then
		ret:addToRoot()
		func(ret)
	else
		func(ret)
	end
	return threadInfo
end

SceneLoader.killLoader = function(info)
	if info then
		info.killed = true
	end
end


----------------------------private functions, don't use these functions in your code ------------------------

SceneLoader.loadUI = function(t)
	if t.isPreset == 1 then
		return SceneLoader.loadFuncMap["Preset"](t);
	end
	local node = SceneLoader.loadFuncMap[t.typeName](t);
	if node ~= nil and t.effect ~= nil and typeof(node, DrawingImage) then
		if t.effect["shader"] == "mirror" then
			if t.effect["mirrorType"] == 0 then
				node:setMirror(true,true);
			elseif t.effect["mirrorType"] == 1 then
				node:setMirror(true,false);
			elseif t.effect["mirrorType"] == 2 then
				node:setMirror(false,true);
			end
		elseif t.effect["shader"] == "gray" then
			local grayScale = require("libEffect.shaders.grayScale");
			grayScale.applyToDrawing(node,{intensity = 0});
		end
	end
	if CostTimeList then
		local time = os.clock()
		table.insert(CostTimeList, {t.typeName .. ":" .. (t.file or t.string or "None"), time - CostTimeList[#CostTimeList][3], time})
	end
	return node;
end

SceneLoader.loadButton = function(t)
	local node = new(Button,SceneLoader.getResPath(t,t.file),SceneLoader.getResPath(t,t.file2),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadImage = function(t)
	local node = new(Image,SceneLoader.getResPath(t,t.file),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadText = function(t)
	local node = new(Text,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadTextView = function(t)
	local node = new(TextView,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadEditText = function(t)
	local node = new(EditText,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadEditTextView = function(t)
	local node = new(EditTextView,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadNilNode = function(t)
	local node = new(Node);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadCheckBoxGroup = function(t)
	local node = new(CheckBoxGroup);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadCheckBox = function(t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(CheckBox,param);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadRadioButtonGroup = function(t)
	local node = new(RadioButtonGroup);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadRadioButton = function(t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(RadioButton,param);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadAutoScrollView = function(t)
	local node = new(ScrollView,t.x,t.y,t.width,t.height,true);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadScrollView = function(t)
	local node = new(ScrollView,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSlider = function(t)
	local node = new(Slider,t.width,t.height,t.bgFile,t.fgFile,t.buttonFile);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSwitch = function(t)
	local node = new(Switch,t.width,t.height,t.onFile,t.offFile,t.buttonFile);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadListView = function(t)
	local node = new(ListView,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadViewPager = function(t)
	local node = new(ViewPager,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSwf = function(t)
	local swfInfoLua = require(t.swfInfoLua);
	local swfPinLua = require(t.swfPinLua);
	local node = new(SwfPlayer,swfInfoLua,swfPinLua);
	if t.swfAuto==1 then
		node:play(t.swfFrame,t.swfKeep == 1,t.swfRepeat,t.swfDelay,t.swfAutoClean==1);
	end
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadPreset = function(t)
	t.isPreset = 0;
	local node;
	local success, fn = pcall(function () 
    	return require(t.preLuaPath)
	end)
	if success == true then
		node = fn(t);
	elseif t.preLuaPath ~= nil then
		t.isPreset = 1;
		error("get error at require "..t.preLuaPath)
	else
		node = SceneLoader.load(t);
	end
	t.isPreset = 1;
	return node;
end

SceneLoader.getResPath = function(t, filename)
	if not filename then
		return filename;
	end

	if type(filename) == "table" then
		return filename;
	end

	if not t.packFile then
		return filename;
	end

	local findName = function(str)
		local pos;
		local found = 0;
		while found do
			pos = found;
			found = string.find(str,"/",pos+1,true);
		end

		if not pos then
			pos = 0;
		end
		return string.sub(str,pos+1);
	end

	local tb = require(t.packFile);
	if type(tb) == "boolean" then
		local packFile = string.sub(t.packFile,1,string.find(t.packFile,".",1,true)-1);
		require(packFile);
		local pitchName = findName(filename);
		local packName = findName(packFile);
		return _G[string.format("%s_map",packName)][pitchName];
	end

	return tb[findName(filename)];
end

SceneLoader.getWH = function(t)
	local w = t.width and t.width>0 and t.width or nil;
	local h = t.height and t.height>0 and t.height or nil;
	return w,h;
end

SceneLoader.setBaseInfo = function(node, t)
	node:setDebugName(t.typeName .. "|" .. t.name);
	node:setName(t.name or "");
	node:setFillParent(t.fillParentWidth==1 and true or false,
						t.fillParentHeight==1 and true or false);
	if t.fillTopLeftX or t.fillTopLeftY 
		or t.fillBottomRightX or t.fillBottomRightY then
		node:setFillRegion(true,t.fillTopLeftX or 0,t.fillTopLeftY or 0,
			t.fillBottomRightX or 0,t.fillBottomRightY or 0);
	end
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setSize(SceneLoader.getWH(t));
	node:setVisible(t.visible==1 and true or false);
end

SceneLoader.loadFuncMap = {
	["View"]				= SceneLoader.loadNilNode;
	["Button"]				= SceneLoader.loadButton;
	["Image"]				= SceneLoader.loadImage;
	["Text"]				= SceneLoader.loadText;
	["TextView"]			= SceneLoader.loadTextView;
	["EditText"]			= SceneLoader.loadEditText;
	["EditTextView"]		= SceneLoader.loadEditTextView;
	["CheckBoxGroup"]		= SceneLoader.loadCheckBoxGroup;
	["CheckBox"]			= SceneLoader.loadCheckBox;
	["RadioButtonGroup"]	= SceneLoader.loadRadioButtonGroup;
	["RadioButton"]			= SceneLoader.loadRadioButton;
	["AutoScrollView"]		= SceneLoader.loadAutoScrollView;
	["ScrollView"]			= SceneLoader.loadScrollView;
	["Slider"]				= SceneLoader.loadSlider;
	["Switch"]				= SceneLoader.loadSwitch;
	["ListView"]			= SceneLoader.loadListView;
	["ViewPager"]			= SceneLoader.loadViewPager;
	["Swf"]					= SceneLoader.loadSwf;
	-- ["Swf"]					= SceneLoader.loadNilNode;
	["Preset"]              = SceneLoader.loadPreset;
};


end
        

package.preload[ "editorRT.sceneLoader" ] = function( ... )
    return require('editorRT/sceneLoader')
end
            

package.preload[ "editorRT/version" ] = function( ... )
--返回EditorRT版本号

return '3.0(e421c8be28f73c9d801a79b23e9dafdad99ac0d8)'

end
        

package.preload[ "editorRT.version" ] = function( ... )
    return require('editorRT/version')
end
            
require("editorRT.sceneLoader");
require("editorRT.version");