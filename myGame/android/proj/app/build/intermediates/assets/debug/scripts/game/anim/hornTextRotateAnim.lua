local WAndFChatPopup = require("game.chat.wAndFChatPopup")
local Z_ORDER = 999
local HornTextRotateAnim = {}

HornTextRotateAnim.frameX = 0;
HornTextRotateAnim.frameY = 0;
HornTextRotateAnim.width = 300;
HornTextRotateAnim.height = 30;
HornTextRotateAnim.baseDuration = 2500;

function HornTextRotateAnim.setup()
	if not HornTextRotateAnim.broadCast_node then
		HornTextRotateAnim.broadCast_node = new(Button, kImageMap.common_broadcast_bg)
		HornTextRotateAnim.broadCast_node:setOnClick(HornTextRotateAnim, HornTextRotateAnim.onBroadcastBtnClick)
		HornTextRotateAnim.broadCast_node:addToRoot()
		HornTextRotateAnim.broadCast_node:setAlign(kAlignTop)
		HornTextRotateAnim.broadCast_node:setPos(-40,17)
		HornTextRotateAnim.broadCast_node:setLevel(Z_ORDER)
		HornTextRotateAnim.broadCast_node:setIsNeedClickAnim(false)

		HornTextRotateAnim.text_bg = new(Image,"res/common/common_blank.png")
		HornTextRotateAnim.text_bg:setSize(350,40)
		HornTextRotateAnim.text_bg:setPos(80,0)

		HornTextRotateAnim.width, HornTextRotateAnim.height = HornTextRotateAnim.text_bg:getSize();
		HornTextRotateAnim.text_bg:setClip2(true, 0, 0, HornTextRotateAnim.width, HornTextRotateAnim.height)

		HornTextRotateAnim.broadCast_node:addChild(HornTextRotateAnim.text_bg);
		HornTextRotateAnim.complete();

		HornTextRotateAnim.broadCast_node:setVisible(false);
	end
end

function HornTextRotateAnim.onBroadcastBtnClick()
	if HornTextRotateAnim.getHornEnable() then

	    nk.AnalyticsManager:report("New_Gaple_suona", "suona")
        nk.DataCenterManager:report("btn_suona")

		local roomType = 0
	    nk.PopupManager:addPopup(WAndFChatPopup,"hall",roomType)
	end
end

function HornTextRotateAnim.setupScene(scene)
	HornTextRotateAnim.scene = scene
	HornTextRotateAnim.setHornVisible()
end

function HornTextRotateAnim.getScene()
	return HornTextRotateAnim.scene
end

function HornTextRotateAnim.play(text)

	if not HornTextRotateAnim.text_bg then 
		return;
	end

	HornTextRotateAnim.broadCast_node:setVisible(true)

	HornTextRotateAnim.text_bg:removeAllChildren(true)
	HornTextRotateAnim.text = new(Text,text,0,HornTextRotateAnim.height,kTextAlignLeft,nil,nil,255,255,255);
	HornTextRotateAnim.text_bg:addChild(HornTextRotateAnim.text);

	HornTextRotateAnim.text:setPos(HornTextRotateAnim.width,0);

	local distance = HornTextRotateAnim.text:getSize() + HornTextRotateAnim.width + 20;
	local timeK = distance/HornTextRotateAnim.width;
	local duration = HornTextRotateAnim.baseDuration * timeK;

	HornTextRotateAnim.clean();

	HornTextRotateAnim.moving = true
	HornTextRotateAnim.moveXanim = HornTextRotateAnim.text:addPropTranslate(0, kAnimNormal, duration, -1, 0, distance*-1, 0, 0)
	HornTextRotateAnim.moveXanim:setDebugName("HornTextRotateAnim.moveXanim");
	HornTextRotateAnim.moveXanim:setEvent(HornTextRotateAnim,HornTextRotateAnim.complete);

	HornTextRotateAnim.getHornEnable()
	-- nk.GCD.PostDelay(HornTextRotateAnim,function()
	-- 	HornTextRotateAnim.getHornEnable()
 --    end, nil, 1000, true)
	
end

function HornTextRotateAnim.setPlayFinished(obj, func )
	HornTextRotateAnim.playFinished_obj = obj;
	HornTextRotateAnim.playFinished_func = func;
end

function HornTextRotateAnim.clean( ... )
	if not HornTextRotateAnim.text_bg then return end;
	if HornTextRotateAnim.moveXanim then
		HornTextRotateAnim.text:doRemoveProp(0);
		-- delete(HornTextRotateAnim.moveXanim);
		HornTextRotateAnim.moveXanim = nil;
	end
	HornTextRotateAnim.moving = false
end

function HornTextRotateAnim.complete()
	nk.GCD.Cancel(HornTextRotateAnim)
	if not HornTextRotateAnim.text_bg then return end;
	HornTextRotateAnim.moving = false
	if HornTextRotateAnim.playFinished_obj and HornTextRotateAnim.playFinished_func then 
		HornTextRotateAnim.playFinished_func(HornTextRotateAnim.playFinished_obj);
	end
end

function HornTextRotateAnim.setHornVisible()
	if HornTextRotateAnim.scene and HornTextRotateAnim.broadCast_node then
		HornTextRotateAnim.broadCast_node:setVisible(HornTextRotateAnim.scene == "hall")
	end
end

function HornTextRotateAnim.getHornEnable()
	local flag = true
	local states = StateMachine.getInstance():getRunningState()
    if states.state == States.Update or states.state == States.Login or states.state == States.Store
    	or states.state == States.Friend or states.state == States.Rank then
    	HornTextRotateAnim.broadCast_node:setVisible(false)
    	flag = false
    end
    return flag
end

return HornTextRotateAnim


