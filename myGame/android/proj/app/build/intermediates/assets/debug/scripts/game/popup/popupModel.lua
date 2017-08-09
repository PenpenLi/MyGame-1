local PopupModel = class(GameBaseLayer)
local PopupAnim = require("game.anim.popupAnim")
local Z_ORDER = 1000

--
-- args
-- 弹窗的一些参数
-- @string name 弹窗的名字
-- @boolean defaultAnim 是否使用默认弹窗动画(默认true)
-- @function animFunction 弹窗动画方法

function PopupModel.show(popup, viewConfig, varConfig, args, ...)
    PopupModel.hide(popup);
    popup.s_instance = new(popup, viewConfig, varConfig, ...)
    popup.s_instance:addToRoot();
    local showOutPopup = function()
	    popup.s_instance:setFillParent(true,true);
	    if args then
		    popup.s_instance.name = args.name
		    popup.name = args.name
		    if args.animFunction then
		    	args.animFunction({root = popup.s_instance.m_root, popup = popup.s_instance})
		    elseif args.defaultAnim ~= false then
			    -- 添加默认缩放动画
			    if QUALITY_MODE == 0 then
			    	if popup.s_instance and popup.s_instance.onShow then
			    		popup.s_instance:onShow()
			    	end
			    else
				    local showCallback = function()
				    	if popup.s_instance and popup.s_instance.onShow then
				    		popup.s_instance:onShow()
				    	end
				    end
				    PopupAnim.pop({pop=popup.s_instance.m_root,callback = showCallback})
				end
			end
		end
	end
	if popup.s_instance.m_root then
		showOutPopup()
	else
		popup.s_instance.showOutPopup = showOutPopup
	end
end

function PopupModel.update(data)
	if popup.s_instance and popup.s_instance.onUpdate then
		popup.s_instance:onUpdate(data)
	end
end

function PopupModel.hide(popup)
	if popup.s_instance and not popup.s_instance.m_backNothing then
		EventDispatcher.getInstance():dispatch(EventConstants.dismissPopupByName, popup.name)
	end
end

function PopupModel.dismiss(popup)
	if popup.s_instance then
		EventDispatcher.getInstance():dispatch(EventConstants.dismissPopupByName, popup.name)
	end
end

function PopupModel:ctor(viewConfig, varConfig, ...)
	self.args = {}
  	local args = select("#", ...)
    for i = 1, args do
        local value = select(i, ...)
        table.insert(self.args,value)
    end
    self.isCanclose = true
    self:setLevel(Z_ORDER)
    self:setEventTouch(self,self.onShieldingLayerTouch)
	self:setEventDrag(self,self.onShieldingLayerTouch)
end

function PopupModel:setIsCanClose(isCanclose)
	self.isCanclose = isCanclose
end

function PopupModel:addCloseBtn(popupBg,x,y)
	local closeBtn = new(Button,"res/common/common_pop_close.png") 
	local closeBtn_x, closeBtn_y = x or 20, y or 20
	popupBg:addChild(closeBtn)
	closeBtn:setAlign(kAlignTopRight)
	closeBtn:setPos(closeBtn_x, closeBtn_y)
	closeBtn:setOnClick(self,self.onClose)
    closeBtn:setClickSound(nk.SoundManager.CLOSE_BUTTON)
end

-- 添加阴影层
function PopupModel:addShadowLayer(res)
	local shadowLayer = new(Image, res or "game/common/common_transparent.png") 
	shadowLayer:setFillParent(true, true)
	self:addChild(shadowLayer)
	shadowLayer:setLevel(-1)
	shadowLayer:setTransparency(1.1)
	shadowLayer:setEventTouch(self, self.onBgTouch)
end

-- 弹框背景触摸响应
function PopupModel:onPopupBgTouch()
	-- do nothing
	EventDispatcher.getInstance():dispatch(EventConstants.onPopBgTouch)
end

-- 屏蔽层点击
function PopupModel:onShieldingLayerTouch()
	
end

-- 透明或半透明背景触摸响应
function PopupModel:onBgTouch()
	if self.isCanclose then
	    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
		self:dismiss()
	end
end

function PopupModel:onClose()
	if self.onCloseBtnClick then
		self:onCloseBtnClick()
	end
	self:dismiss()
end

function PopupModel:dtor()

end

function PopupModel.RegisterClassFuncs(classObj, className, infoLayer, infoLayerVarPath)
	function classObj.show(...) -- 类全局方法
		PopupModel.show(classObj, infoLayer, infoLayerVarPath, {name=className}, ...)  
	end

	function classObj.hide(...) -- 类全局方法
		PopupModel.hide(classObj, ...)
	end
end

return PopupModel




