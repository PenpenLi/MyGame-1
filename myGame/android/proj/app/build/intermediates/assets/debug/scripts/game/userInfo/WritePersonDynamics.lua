--
-- Author: ziway
-- Date: 2016-10-27 11:57:40
--
local PopupModel = import('game.popup.popupModel')
local WritePersonDynamicsView = require(VIEW_PATH .. "userInfo/writePersonDynamics_layer")
local WritePersonDynamicsVar = VIEW_PATH .. "userInfo/writePersonDynamics_layer_layout_var"
local WritePersonDynamics = class(PopupModel)

function WritePersonDynamics.show(data)
	PopupModel.show(WritePersonDynamics, WritePersonDynamicsView, WritePersonDynamicsVar, {name="WritePersonDynamics"}, data)
end

function WritePersonDynamics.hide()
	PopupModel.hide(WritePersonDynamics)
end

function WritePersonDynamics:ctor(viewConfig)
	Log.printInfo("WritePersonDynamics.ctor");
    self:addShadowLayer()
    self:initLayer()
    nk.AnalyticsManager:report("New_Gaple_open_publish_dyna")
end 


function WritePersonDynamics:initLayer()
    self:initWidget()
end

function WritePersonDynamics:bt_close_click()
    self:onBgTouch()
end

function WritePersonDynamics:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)

    self.titleTxt = self:getUI("titleTxt")
    self.titleTxt:setText(bm.LangUtil.getText("USERINFO", "WRITE_SELF_DYNA_TITLE"))

    self.contentTxt = self:getUI("contentTxt")
    self.contentTxt:setText("")
    self.contentTxt:setHintText(bm.LangUtil.getText("USERINFO", "WRITE_SELF_DYNA"),0xab,0x5f,0xec)
    self.contentTxt:setMaxLength(140)

    self.sendBtnTxt = self:getUI("sendBtnTxt")
    self.sendBtnTxt:setText(bm.LangUtil.getText("USERINFO", "WRITE_SELF_DYNA_TITLE"))

    for i = 1 ,3 do
	    local txt = self:getUI("uploadPicTxt_" .. i)
	    txt:setText(bm.LangUtil.getText("USERINFO", "UPLOAD_SELF_PIC"))
	end
end

function WritePersonDynamics:onSend()
    if self.isLoading then
        return
    end
    -- Log.dump(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WritePersonDynamics")

	local j = string.trim(self.contentTxt:getText())

	if j ~= "" then
        self.isLoading = true
	    nk.HttpController:execute("postSignOrDynamics", {game_param = {mid = nk.userData.uid,type = 1,content = j}}, nil, 
	        function (errorCode, data)
                self.isLoading = false
                if data and data.code == 1 and checkint(data.data) > 0 then
                    nk.UserDataController.setUserDyna(j, data.data, data.time, 0)
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "WRITE_DYNAMIC_SUCC"))
                    nk.userData.tdyna = (tonumber(nk.userData.tdyna) or 0) + 1  
                    
                    if not tolua.isnull(self) then
                        self:hide()
                    end
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "WRITE_DYNAMIC_FAILD"))   
                end
            end)
	else
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "WRITE_SELF_DYNA")) 
	end

end

function WritePersonDynamics:dtor()
    
end 

return WritePersonDynamics