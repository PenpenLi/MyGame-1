-- AboutPopup.lua
-- Date : 2016-06-01
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local freeShareView = require(VIEW_PATH .. "free/share_layer")
local freeShareInfo = VIEW_PATH .. "free/share_layer_layout_var"
local FreeSharePopup= class(PopupModel);

function FreeSharePopup.show(data)
	PopupModel.show(FreeSharePopup, freeShareView, freeShareInfo, {name="FreeSharePopup"}, data)
end

function FreeSharePopup.hide()
	PopupModel.hide(FreeSharePopup)
end

function FreeSharePopup:ctor(viewConfig, varConfigPath, data)
	  Log.printInfo("FreeSharePopup.ctor");
    self:addShadowLayer()
    self.data_ = data
    self:initLayer()
end 

function FreeSharePopup:initLayer()
     self:initWidget()
end

function FreeSharePopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)   

    self:getUI("Text_title"):setText(bm.LangUtil.getText("COMMON", "NOTICE"))
    self:getUI("Text_bt_share"):setText(bm.LangUtil.getText("COMMON", "SHARE"))

    local content = ""
    if self.data_.isGet then
        content = bm.LangUtil.getText("ECODE", "SUCCESS",self.data_.name)
    else
        content = bm.LangUtil.getText("ECODE", "ERROR_USED",self.data_.name)
    end
    self:getUI("TextView_content"):setText(content)

end

function FreeSharePopup:bt_share_click()
    local feedData = clone(bm.LangUtil.getText("FEED", "EXCHANGE_CODE"))
    feedData.name = bm.LangUtil.formatString(feedData.name, self.data_.name or "")
    nk.FacebookNativeEvent:shareFeed(feedData, function(success, result)
       if success then
           self:hide()
           nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
       else
           nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))       
       end
    end) 
end

function FreeSharePopup:dtor()
    Log.printInfo("FreeSharePopup.dtor");
end 


return FreeSharePopup