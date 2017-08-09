sys_set_int("win32_console_color",0x008000)
FILE_RE_LIST = {}
error_text = nil


function event_load( width, height )
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


function event_init()
	print("main event_init!!!!!!!!!")
	-- 设置默认像素格式
	Window.instance().root.fbo.need_stencil = true
	System.setImageFilterPicker(function(filename) return kFilterLinear end)
	System.setLayoutWidth(960)
	System.setLayoutHeight(640)
	START_TIME = os.time()
	--init_game()

	
	
	StateMachine.getInstance():changeState(States.Demo)

	-- local scene = new(ClassName)
	-- scene:addToRoot()

	-- new(DemoController, self, DemoScene, DemoLayer, DemoData, DemoLayerVar);

end
