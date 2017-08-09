-- updatePopup.lua
-- Last modification : 2016-06-06
-- Description: a popup in update moudle

local UpdatePopup = class(GameBaseLayer)

-------------------------------- single function --------------------------
function UpdatePopup:exit()
    local parent = self:getParent()
    parent:removeChild(self, true)
end

-------------------------------- base function --------------------------

function UpdatePopup:ctor(viewConfig, varConfig, data)
	Log.printInfo("UpdatePopup.ctor");
    self.m_data = data
	self:init(data)
end 

function UpdatePopup:dtor()
	Log.printInfo("UpdatePopup.dtor");
end

-------------------------------- private function --------------------------

function UpdatePopup:init(data)
	Log.printInfo("UpdatePopup.init");

	self.m_titleLabel = self:getUI("titleLabel")
	self.m_titleLabel:setText(bm.LangUtil.getText("UPDATE", "TITLE"))

	self.m_msgTextView = self:getControl(self.s_controls["msgTextView"])
	self.m_msgTextView:setText(data.config.verTitle .. "\n" .. data.config.verMessage)

    self.m_tipLabel = self:getControl(self.s_controls["tipLabel"])
    self.m_tipLabel:setText(bm.LangUtil.getText("UPDATE", "AWARD_TIP"))
    
    self.m_closeButton = self:getControl(self.s_controls["closeButton"])

    self.m_awardImage_1 = self:getControl(self.s_controls["awardImage_1"])
    self.m_awardImage_2 = self:getControl(self.s_controls["awardImage_2"])
    self.m_awardImage_3 = self:getControl(self.s_controls["awardImage_3"])

    self.m_awardLabel_1 = self:getControl(self.s_controls["awardLabel_1"])
    self.m_awardLabel_2 = self:getControl(self.s_controls["awardLabel_2"])
    self.m_awardLabel_3 = self:getControl(self.s_controls["awardLabel_3"])

    self.m_twoButtonView = self:getControl(self.s_controls["twoButtonView"])
    self.m_towSureButton = self:getControl(self.s_controls["towSureButton"])
    self.m_towCancleButton = self:getControl(self.s_controls["towCancleButton"])

    self.m_oneButtonView =  self:getControl(self.s_controls["oneButtonView"])
    self.m_oneSureButton =  self:getControl(self.s_controls["oneSureButton"])

    self:getUI("twoCancelText"):setText(bm.LangUtil.getText("COMMON","CANCEL"))
    self:getUI("twoSureText"):setText(bm.LangUtil.getText("COMMON","AGREE"))
    self:getUI("oneSureText"):setText(bm.LangUtil.getText("COMMON","AGREE"))

    -- 是否强制更新
    if data.config.isForce == 1 then
    	self.m_closeButton:setVisible(false)
    	self.m_twoButtonView:setVisible(false)
    else
    	self.m_oneButtonView:setVisible(false)
    end

    if data.callFunc then
    	self.m_callFunc = data.callFunc
    end

    if data.config.prize then
    	for i=1, 3 do
            if data.config.prize[i] then
    		    UrlImage.spriteSetUrl(self["m_awardImage_" .. i], data.config.prize[i].imgUrl)
    		    self["m_awardLabel_" ..i]:setText(data.config.prize[i].name)
            end
    	end
    end
    
end 

function UpdatePopup:onCallBack(...)
	if self.m_callFunc then
		self.m_callFunc((...))
	end
end

-- 透明或半透明背景触摸响应
function UpdatePopup:onBgTouch()

end

-------------------------------- handle function --------------------------

function UpdatePopup:onOneSureButtonClick()
	Log.printInfo("UpdatePopup.onOneSureButtonClick");
	self:onCallBack(1)
    if self.m_data.config.isApk ~= 1 then
         self:exit()
    end
end 

function UpdatePopup:onTowSureButtonClick()
	Log.printInfo("UpdatePopup.onTowSureButtonClick");
	self:onCallBack(1)
    if self.m_data.config.isApk ~= 1 then
         self:exit()
    end
end 

function UpdatePopup:onTowCancleButtonClick()
	Log.printInfo("UpdatePopup.onTowCancleButtonClick");
	self:onCallBack(2)
	self:exit()
end 

function UpdatePopup:onCloseButtonClick()
	Log.printInfo("UpdatePopup.onCloseButtonClick");
	self:onCallBack(2)
	self:exit()
end

-------------------------------- table config ------------------------

-- Provide cmd handle to call
UpdatePopup.s_cmdHandleEx = 
{
    --["***"] = function
    ["updatePeriod"] = UpdatePopup.onUpdatePeriod;
};

return UpdatePopup