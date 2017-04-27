local PopupModel = import('game.popup.popupModel')
local NativeEventConfig = require("game.nativeEvent.nativeEventConfig")
local aboutView = require(VIEW_PATH .. "demo/setHeadPopup")
local aboutInfo = VIEW_PATH .. "demo/setHeadPopup_layout_var"
local setHeadPopup = class(PopupModel);


function setHeadPopup.show(...)
	Clock.instance():schedule_once(function()
		PopupModel.show(setHeadPopup, aboutView, aboutInfo, {name="setHeadPopup", animFunction = function(args)
		local root = args.root
		local popup = args.popup
		local _, originalY = root:getPos()
		root:setPos(nil, originalY - System.getScreenScaleHeight())
		root:runAction(Action.Move({
			time = 0.8,
			y = originalY,
			onComplete = function()
				if popup.onShow then popup:onShow() end
			end,
			ease = Action.easeInOutBack,
			}))
		end})
    end, 0)
	
end

function setHeadPopup.hide()
	PopupModel.hide(setHeadPopup)
end


function setHeadPopup:ctor(viewConfig, viewVar, data1, data2)
	Log.printInfo("setHeadPopup.ctor"); 
    EventDispatcher.getInstance():register(EventConstants.changeHeadSuccess, self, self.updateHead);
    EventDispatcher.getInstance():register(EventConstants.onEventCallBack, self, self.onNativeCall);
	
    self:addShadowLayer()
    self:setIsCanClose(false)


    self.bgSetHead = self:getUI("bgSetHead")
	self.imagePerson = self:getUI("imagePerson")
	self.btnTakePhoto = self:getUI("btnTakePhoto")
	self.btnOpenAlbm = self:getUI("btnOpenAlbm")
	self.btnCancel = self:getUI("btnCancel")
	self.btnOk = self:getUI("btnOk")
	self.imageHead = Mask.setMask(self:getUI("imageHead"), "game/common/headframe1.png", {scale = 1, align = 0, x = -1.5, y = -1})
	self.editTextName = self:getUI("editTextName")
	self.imageEdit = self:getUI("imageEdit")
	self.imageLine = self:getUI("imageLine")
	self.editTextName:setMaxLength(10)
	self.editTextName:setOnTextChange(self, self.onEditText)
	
	-------------------------------------------------
	self.btnTakePhoto.name = "BtnTakePictureNum"
	self.btnOpenAlbm.name = "BtnOpenAlbumNum"
	self.imageHead.name = "imageHeadOpenAlbumNum"
	self.btnCancel.name = "BtnConfigCancelNum"
	self.btnOk.name = "BtnConfigSubmitNum"
	self.editTextName.name = "EditNameNum"
    -------------------------------------------------

	self:getHeadPhotoAndName()

	self.btnTakePhoto:setOnClick(self, self.onTakePhoto)
	self.btnOpenAlbm:setOnClick(self, self.onOpenAlbm)
	self.imageHead:setEventTouch(self, self.onOpenAlbmTouch)

	self.btnCancel:setOnClick(self, self.onCancel)
	self.btnOk:setOnClick(self, self.onSubmit)

end 

function setHeadPopup:onOpenAlbmTouch(finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
	Log.dump("onOpenAlbmTouch")
	if finger_action == kFingerUp then
		Log.dump("onOpenAlbmTouch",finger_action)
		self:onGetPhoto(1)
	end
end

function setHeadPopup:dtor()
    Log.printInfo("setHeadPopup.dtor");  
    EventDispatcher.getInstance():unregister(EventConstants.onEventCallBack, self, self.onNativeCall);
    EventDispatcher.getInstance():unregister(EventConstants.changeHeadSuccess, self, self.updateHead);
end

function setHeadPopup:updateHead()
	local iconUrl = nk.DictModule:getString("playerAvatar", "iconUrl")
	UrlImage.spriteSetUrl(self.imageHead, iconUrl)
end

function setHeadPopup:getHeadPhotoAndName()	

	local headPhotoPath = nk.DictModule:getString("playerAvatar", "photo")
	local playerName = nk.DictModule:getString("playerName", "name")
	Log.dump(ICON_URL, "ICON_URL>>>")
	if headPhotoPath ~= "" and headPhotoPath ~= nil then
		-- 找到以时间戳命名的头像图片名字
		local i, j = string.find(headPhotoPath, "[^/\\]-$")
		local tempName = string.sub(headPhotoPath, i, j)
		Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>> tempName", tempName)
		self.imageHead:setFile(tempName)
	else
		self.imageHead:setFile("game/common/headframe.png")
	end
	UrlImage.spriteSetUrl(self.imageHead, ICON_URL)

	
	if playerName ~= "" and playerName ~= nil then
		self.editTextName:setText(playerName)
	else
		self.editTextName:setText("WindCao")
	end

	if LASTNAME ~= nil then
		Log.dump(LASTNAME," asdas<<<<<<<")
		self.editTextName:setText(LASTNAME)
	end

	
end

function setHeadPopup:onEditText()
	local name = self.editTextName:getText()
	name = string.trim(name)
	if name == "" then
		name = "WindCao"
	end
	self.editTextName:setText(name)
	nk.DictModule:setString("playerName", "name", name)
	nk.DictModule:saveDict("playerName")

	BUTTON_CLICK_EVENT.EditNameNum = BUTTON_CLICK_EVENT.EditNameNum + 1

end

function setHeadPopup:onNativeCall(key, status, data, ...)
	Log.printInfo(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> setHeadPopup:onNativeCall")
    if key == NativeEventConfig.NATIVE_GAME_PICKIMAGE_CALLBACK then
        self:pickImageCallBack(status,data)
    end
end


function setHeadPopup:onOpenAlbm()
	self:onGetPhoto(1)
end

function setHeadPopup:onTakePhoto()
	self:onGetPhoto(2)
end



function setHeadPopup:onGetPhoto(mode)

	if System.getPlatform() == kPlatformWin32 then  
        if not self.inputPath then
            self.inputPath = new(EditText, "输入你要上传的图片", 10, 50, kAlignCenter, "", 25,0,0,0);
            self.inputPath:setPos(0,0);
            self:addChild(self.inputPath)

            local function doEnd(obj, path)
                -- nk.functions.uploadPhoto(true, path, self.posIndex, self.imgIndex)
                nk.functions.uploadPhoto(path)
                self.inputPath:removeFromParent(true)
                self.inputPath = nil
            end
            self.inputPath:setOnTextChange(self, doEnd)
        end
    elseif System.getPlatform() == kPlatformAndroid or System.getPlatform() == kPlatformIOS then    
        local data = {}
        data.imagePath = System.getStorageImagePath()
        data.mode = mode
        nk.GameNativeEvent:pickImage(data, self.posIndex, self.imgIndex)
    end
end

function setHeadPopup:onCancel()
	nk.PopupManager:removePopupByName("setHeadPopup")
end

function setHeadPopup:onSubmit()
	Log.printInfo("点击确认按钮")
	-------------------------------------------
	nk.functions.uploadPhoto(self.newpath)
	-------------------------------------------
	PopupModel.hide(setHeadPopup)
	EventDispatcher.getInstance():dispatch(EventConstants.setHeadDemoScene)
end

function setHeadPopup:pickImageCallBack(status, data)
	Log.printInfo("setHeadPopup pickImageCallBack path", data)
	Log.printInfo("setHeadPopup pickImageCallBack status", status)
	
	if status then

     	local tempName = "temp" .. os.time() .. ".png"
     	self.newpath = System.getStorageImagePath() .. tempName
		System.copyFile(data, self.newpath)

     	nk.DictModule:setString("playerAvatar", "photo", self.newpath)
  		nk.DictModule:saveDict("playerAvatar")

     	self.imageHead:setFile(tempName)
	--	self:countDownPhoto()		
		
  		if System.getPlatform() == kPlatformAndroid then
	        System.removeFile(data)
	    end
 	end
end

function setHeadPopup:countDownPhoto()
	-- self.imageHead = Mask.setMask(self.imageHead, "game/common/headframe1.png", {scale = 1, align = 0, x = -1.5, y = -1})
end

return setHeadPopup