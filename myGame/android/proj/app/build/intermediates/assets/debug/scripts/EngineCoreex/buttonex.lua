-- buttonex.lua
-- Date: 2016-07-07
-- Last modification : 2016-07-07
-- Description: Implemented Button

-- 默认按钮点击时需要动画
local oldCtor = Button.ctor
Button.ctor = function(self, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
    self.m_isNeed = true
    oldCtor(self, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
end

Button.setClickSound = function(self,sound)
    self.clickSound = sound or nk.SoundManager.CLICK_BUTTON 
end

-- 增加按钮点击音效
local oldOnClick = Button.onClick
Button.onClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	oldOnClick(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not self.m_enable then
        return
    end


	if self.m_isNeed then
		if finger_action == kFingerDown then
			self:removeClickProp()
			self.m_animSequence = transition.getSequence()
			self:addPropScaleSolid(self.m_animSequence, 1.1, 1.1, kCenterDrawing)
			nk.SoundManager:playSound(self.clickSound or nk.SoundManager.CLICK_BUTTON)

	    elseif finger_action == kFingerMove then
	        if not (self.m_responseType == kButtonUpInside and drawing_id_first ~= drawing_id_current) then
	        else
				self:removeClickProp()
	        end
	    elseif finger_action == kFingerUp then
			self:removeClickProp()

			------------------------------------------------------------------------------------
			-- Log.dump("<<<<<<<<<<<<<<<<<<   self.name", self.name)
			EventDispatcher.getInstance():dispatch(EventConstants.btn_event_upload, self.name or "")
			------------------------------------------------------------------------------------
	    elseif finger_action==kFingerCancel then

	    end
	end
end

Button.removeClickProp = function(self)
	if self.m_animSequence then
		self:doRemoveProp(self.m_animSequence)
		self.m_animSequence = nil
	end
end

---
-- 用于设置按钮点击时是否需要动画
-- 
Button.setIsNeedClickAnim = function(self, isNeed)
	self.m_isNeed = isNeed
end

---
-- 一般用于按钮在scrollview中，当按钮的触摸事件距离大于一定值，就不触发点击事件
-- 
-- 取自老引擎，象棋项目组
Button.setSrollOnClick = function(self)
	Button.setEventTouch(self,self,self.onClick2);
end

---
-- Override @{core.button#Button.onClick}.
-- 当按钮的触摸事件距离大于一定值，就不触发点击事件
-- 
-- 取自老引擎，象棋项目组
Button.onClick2 = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not self.m_enable then
		return;
	end
	
	if finger_action == kFingerDown then
	   self.m_showEnbaleFunc(self,false);
       self.m_downX = x;
       self.m_downY = y;
	elseif finger_action == kFingerMove then
		if not (self.m_responseType == kButtonUpInside and drawing_id_first ~= drawing_id_current) then
			self.m_showEnbaleFunc(self,false);
		else
			self.m_showEnbaleFunc(self,true);
		end
	elseif finger_action == kFingerUp then
		self.m_showEnbaleFunc(self,true);
		
        local dw = math.abs(self.m_downX - x);
        local dh = math.abs(self.m_downY - y);
        if dw > 20 or dh > 20 then
            return 
        end

		local responseCallback = function()
			if self.m_eventCallback.func then
                self.m_eventCallback.func(self.m_eventCallback.obj,finger_action,x,y,
                	drawing_id_first,drawing_id_current);
            end	
		end

		if self.m_responseType == kButtonUpInside then
			if drawing_id_first == drawing_id_current then
				responseCallback();
			end
	    elseif self.m_responseType == kButtonUpOutside then
	    	if drawing_id_first ~= drawing_id_current then
				responseCallback();
			end
		else
			responseCallback();
		end
	elseif finger_action == kFingerCancel then
		self.m_showEnbaleFunc(self,true);
	end
end



 -- "data" = {
 --     "data" = {
	--     "btnInfoList" = {
	-- 	     "BtnConfigCancelNum"  = "0"
	--          "BtnConfigSubmitNum"  = "0"
	--          "BtnCrazyNum"         = "0"
	--          "BtnExitCancelNum"    = "0"
	--          "BtnGentleNum"        = "0"
	--          "BtnHeadOpenAlbumNum" = "0"
	--          "BtnMusicNum"         = "0"
	--          "BtnOpenAlbumNum"     = "0"
	--          "BtnTakePictureNum"   = "0"
	--          "EditNameNum"         = "0"

 --             "crazy" = {
 --           		"modeId"       = 2
 --                 "btnTips"     = 0
 --                 "btnRestart"  = 0
 --                 "btnContinue" = 0
 --                 "breakRecord" = 0
 --             }
 --             "gentle" = {
 --                 "modeId"      = 1
 --                 "btnTips"     = 0
 --                 "btnRestart"  = 0
 --                 "btnContinue" = 0
 --                 "breakRecord" = 0
 --             }
 --         }
 --         "gameInfolist" = {
 --             "crazy" = {
 --                 "gameCoins" = 40
 --                 "gid"       = 2
 --                 "maxScore"  = 0
 --                 "modeId"    = 2
 --             }
 --             "gentle" = {
 --                 "gameCoins" = 80
 --                 "gid"       = 2
 --                 "maxScore"  = 0
 --                 "modeId"    = 1
 --             }
 --         }
 --         "iconUrl"             = "http://192.168.96.152/jeffhas_dev/jdcomb/icon/2/default.png"
 --         "loginType"           = 1
 --         "mid"                 = "42"
 --         "nick"                = "WindCao"
 --         "sex"                 = "0"
 --         "status"              = 1
 --         "updateTime"          = "1492393817"
 --     }
 --     "flag" = 10000
 --     "time" = 1492420088
 -- }


