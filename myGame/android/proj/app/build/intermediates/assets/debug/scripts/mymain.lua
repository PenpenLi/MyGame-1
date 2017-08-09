-- 用于保存已require的文件
FILE_RE_LIST = {}
-- old_require = require
error_text = nil
-- function require(filename, ...)
--     if filename == "string" or filename == "table" or 
--        filename == "debug" or filename == "getsize" or 
--        filename == "io" or filename == "coroutine" then
--        	return old_require(filename, ...)
--     end
-- 	FILE_RE_LIST[#FILE_RE_LIST+1] = filename
-- 	return old_require(filename, ...)
-- end

function event_load ( width, height )
	require("init")
	require("error")
	System.onInit()
	event_init()
	if not IS_RELEASE then
		require("profile").profile()
	end
	nk.NativeEventController:callNativeEvent("closeLaunchScreen")
end

function print_to_screen(screenMsg)
	Log.printInfo("screenMsg :", screenMsg)
	-- to_lua('error.lua')
	local size_x, size_y = 0,0
	local str = screenMsg
    if not IS_RELEASE then
    	if error_text then
			nk.functions.removeFromParent(error_text,true)
			delete(error_text)
			error_text = nil 
		end
      	error_text = new(TextView, "", 900, 640, kAlignTopLeft, nil, 22, 255, 255, 255)
      	error_text:setPos(10,50)
      	error_text:setColor(255,160,0)
      	error_text:setText(str)
      	error_text:setLevel(1100)
      	error_text:addToRoot()
      	-- error_text:setFillParent(true,true)
      	error_text:setEventTouch(self,self,function()end);
      	size_x, size_y = error_text:getSize() 
  	end
end

function event_lua_error(errorMessage)
	Log.printInfo("errorMessage :", errorMessage)
	-- to_lua('error.lua')

	local size_x, size_y = 0,0
	local str = System.getLuaError();
    if not IS_RELEASE then
    	if error_text then
			nk.functions.removeFromParent(error_text,true)
			delete(error_text)
			error_text = nil 
		end
      	error_text = new(TextView, "", 900, 640, kAlignTopLeft, nil, 22, 255, 255, 255)
      	error_text:setPos(10,50)
      	error_text:setColor(160,255,0)
      	error_text:setText(str)
      	error_text:setLevel(1100)
      	error_text:addToRoot()
      	-- error_text:setFillParent(true,true)
      	error_text:setEventTouch(self,self,function()end);
      	size_x, size_y = error_text:getSize()

      	-- nk.GCD.PostDelay(self,function()
       --      nk.functions.removeFromParent(error_text,true)
       --      delete(error_text)
       --      error_text = nil
       --  end, nil, 3000)   
  	end
    report_lua_error(str)
end

local function init_game()
	-- StateMachine.getInstance():registerStyle("AsyncStyle", function(newState, lastState, releaseFlag, callbackInstance, callback)
	-- 	if newState.stateObj.m_controller.m_view.m_isLoaded then
	-- 		if callback then callback(callbackInstance, newState, lastState, releaseFlag) end -- remove the old scene and call the new scene resume
	-- 	else
	-- 		newState.stateObj.m_controller.m_view.m_loadedCallback = function()
	-- 			if callback then callback(callbackInstance, newState, lastState, releaseFlag) end
	-- 		end
	-- 	end
	-- end)
end

function event_init()
	-- 设置图片的默认纹理像素格式.
	Window.instance().root.fbo.need_stencil = true
	System.setImageFilterPicker(function(filename) return kFilterLinear end)
	System.setLayoutWidth(960)
	System.setLayoutHeight(640)
	START_TIME = os.time()
	-- init_game()
	Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> init_game")

	-- require("demoEntry")
	StateMachine.getInstance():changeState(States.Demo)
end
