-- updateScene.lua
-- Last modification : 2016-05-27
-- Description: a scene in update moudle

local UpdateScene = class(GameBaseScene);
-- local varConfigPath = VIEW_PATH .. "update.update_scene_layout_var"

local TIPS = bm.LangUtil.getText("UPDATE", "TIPS")

function UpdateScene:ctor(viewConfig, controller)
	Log.printInfo("UpdateScene.ctor");
	-- self:declareLayoutVar(varConfigPath)

	self.m_progressText = self:getControl(self.s_controls["progressText"])
    self.m_progressBar = self:getControl(self.s_controls["progressBar"])
    self.Text_tip_ = self:getUI("Text_tip")
    self.m_progressBarBg = self:getUI("progressBarBg")
    self.m_max_w = self.m_progressBarBg:getSize()-10
    local msg = bm.LangUtil.getText("UPDATE", "CHECKING_VERSION")
    self.m_progressText:setText(msg)

    local updateFunctions = require("game.common.updateFunctions")
    self.m_logo = self:getUI("logo")
    self.m_logo:setFile(updateFunctions.getLogoFileBySid())

    self.current_ = 0
end 

function UpdateScene:resume()
	Log.printInfo("UpdateScene.resume");
    nk.PopupManager:removeAllPopup()
    GameBaseScene.resume(self)

    self:updateTip()
    if self.schedule_ then
        self.schedule_.paused = false    --»Ö¸´
    end
end

function UpdateScene:pause()
	Log.printInfo("UpdateScene.pause");
    nk.PopupManager:removeAllPopup()
	GameBaseScene.pause(self);

    if self.schedule_ then
        self.schedule_.paused = true    --»Ö¸´
    end
end 

function UpdateScene:dtor()
	Log.printInfo("UpdateScene.dtor");
    if self.schedule_ then
        self.schedule_:cancel()
        self.schedule_ = nil
    end
end

function UpdateScene:updateTip(args)
    self.schedule_ = Clock.instance():schedule(function(dt)
        self.current_ = self.current_ + 1 
        if self.current_ > #TIPS then
             self.current_ = 1
        end
        self.Text_tip_:setText(TIPS[self.current_])
    end,2)
end

-------------------------------- handle function --------------------------

function UpdateScene:onUpdatePeriod(period, msg)
	Log.printInfo("UpdateScene.onUpdatePeriod period " .. period);
    local barWidth = self.m_max_w*period
    self.m_progressBar:setSize(barWidth);
    if msg then
    	self.m_progressText:setText(msg)
    end
end 


-- Provide cmd handle to call
UpdateScene.s_cmdHandleEx = 
{
    --["***"] = function
    ["updatePeriod"] = UpdateScene.onUpdatePeriod;
};

return UpdateScene