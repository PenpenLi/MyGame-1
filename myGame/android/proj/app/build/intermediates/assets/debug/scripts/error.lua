local errorView = require("view/Android_960_640/error_layer")



function event_lua_error(w,h)
	nk.ignoreBack = true

	local errorMessage = "sdsad"
	Log.dump(errorMessage, "ERROR STACK")

	nk.SocketController:close()

	for i,swf in ipairs(nk.SWF) do
		swf:pause(0, false)
	end

   	--删除全部4类对象
	res_delete_group(-1);
	anim_delete_group(-1);
	prop_delete_group(-1);
	drawing_delete_all();
	audio_music_stop(1);

	local errorScene = SceneLoader.load(errorView);
	local errorLabel = errorScene:getChildByName("errorLabel");
	local str = System.getLuaError();
    sys_set_int("win32_console_color",0xff0000);
	print_string(" error str = "..str)

	local errorTips_bg = errorScene:getChildByName("error_tips_bg");
	local errorTips = errorTips_bg:getChildByName("error_tips");
	errorTips:setText(bm.LangUtil.getText("LUAERROR", "ERROR_TIP"))

	if IS_RELEASE then
		errorLabel:setText("")
	else
		errorLabel:setText(str)
	end

    report_lua_error(str)

	local errorBtn = errorScene:getChildByName("error_repair_btn");
	errorBtn:setOnClick(nil,function()
		errorBtn:setVisible(false);
		nk.ignoreBack = false
		local anim = new(AnimInt , kAnimNormal, 0, 1 ,1, -1);
		anim:setEvent(nil, function()
			delete(anim);
			delete(errorScene);

			to_lua("main.lua");
		end);
	end);
end


function report_lua_error(errStr)
	local params = 
    {
       sid         = GameConfig.ROOT_CGI_SID,
       lid         = nk.DictModule:getString("gameData", nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST"), 
       apkVer      = GameConfig.CUR_VERSION, 
    }
    local info = json.encode(params)   
	errStr = errStr .. "\n uid = " .. tostring(nk.userData.uid) .. "\n userInfo = " .. info
	nk.UmengNativeEvent:reportError(errStr)
end