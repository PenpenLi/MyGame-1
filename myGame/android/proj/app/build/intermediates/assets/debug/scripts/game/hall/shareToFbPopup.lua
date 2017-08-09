local PopupModel = require('game.popup.popupModel')
local LayerConfig = require(VIEW_PATH .. "hall/share_to_fb_layer")
local LayerVarPath = VIEW_PATH .. "hall/share_to_fb_layer_layout_var"

local ShareToFbPopup = class(PopupModel)
PopupModel.RegisterClassFuncs(ShareToFbPopup, "ShareToFbPopup", LayerConfig, LayerVarPath) --register show and hide

function ShareToFbPopup:ctor()
	self.fbo = ShareToFbPopup.TakeScreenShot(self:getUI("View_container"))
    self:getUI("EditTextView_caption"):setText("", nil, nil, 255, 255, 255)
    self:getUI("EditTextView_caption"):setHintText("Please input your words", 255, 255, 255)
end

function ShareToFbPopup:dtor()

end

function ShareToFbPopup:onBtnShareClicked()
	if(self:getUI("EditTextView_caption"):getText() ~= "") then
		local pathForUpload = System.getStorageImagePath() .. "upload_photo.png"
		self.fbo:save(pathForUpload)
		nk.FacebookNativeEvent:uploadPhoto(pathForUpload, self:getUI("EditTextView_caption"):getText(), function(status)
            local msg
            if status == -3 then
                msg = nil
            elseif status == -2 then
                msg = "Fail to share the photo!"
            else
                msg = "Sharing Success!"
            end
            if msg then
                nk.TopTipManager:showTopTip(msg)
            end
        end)
        self:dismiss()
	else
		nk.TopTipManager:showTopTip("Please input your owns words")
	end
end

function ShareToFbPopup.TakeScreenShot(drawingContainer)
	local sysWidth = System:getScreenWidth()
    local sysHeight = System:getScreenHeight()
	local fbo = FBO.create(Point(sysWidth,sysHeight))
	fbo:render(Window.instance().drawing_root)
    local unit = TextureUnit(fbo.texture)
    local sprite = Sprite(unit)
    local container = drawingContainer:getWidget()
    container:add(sprite)
    local scaleX = container.width/sprite.width
    local scaleY = container.height/sprite.height
    local scale = scaleX < scaleY and scaleX or scaleY
    sprite:set_attributes{ 
    	[Widget.ATTR_WIDTH] = sprite.width * scale, 
    	[Widget.ATTR_HEIGHT] = sprite.height * scale,
    	[Widget.ATTR_X] = (container.width - sprite.width * scale) * 0.5,
    	[Widget.ATTR_Y] = (container.height - sprite.height * scale) * 0.5,
    }
    return fbo
end

return ShareToFbPopup