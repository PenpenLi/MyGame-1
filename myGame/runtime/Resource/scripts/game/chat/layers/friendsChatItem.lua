local varConfigPath_r = VIEW_PATH .. "chat.friend_chat_msg_item_r_view_layout_var"
local itemView_r = require(VIEW_PATH .. "chat.friend_chat_msg_item_r_view")

local varConfigPath_l = VIEW_PATH .. "chat.friend_chat_msg_item_l_view_layout_var"
local itemView_l = require(VIEW_PATH .. "chat.friend_chat_msg_item_l_view")

local WAndFChatConfig = import('game.chat.wAndFChatConfig')
local expressionConfig = import("game.roomGaple.config.expressionConfig")
local ExpressionConfig = new(expressionConfig)

local FriendsChatItem = class(GameBaseLayer,false)

function FriendsChatItem:ctor(data,index,micon)
    self.data = data
    self.micon = micon

	if self.data.kind == 1 then
        super(self, itemView_r);
    	self:declareLayoutVar(varConfigPath_r)
    else
        super(self, itemView_l);
    	self:declareLayoutVar(varConfigPath_l)
    end

    self:setSize(self.m_root:getSize());
    self:init()

    if self.data.msg_type and tonumber(self.data.msg_type) == 2 then
        self.data.msg_type = tonumber(self.data.msg_type)
    	self:setExpressionData()
    else
    	self:setTextData()
    end
    self:setHeadImage()
end

function FriendsChatItem:init()
	self.m_head = self:getUI("player_head")
	self.m_head = Mask.setMask(self.m_head, kImageMap.common_head_mask_min)
	self.m_msg_bg = self:getUI("msg_bg")
	self.m_chat_msg = self:getUI("chat_msg")
	self.m_exp_node = self:getUI("exp_node")
end

function FriendsChatItem:setTextData()
	self.m_exp_node:setVisible(false)
	if self.data.msg then
		local flag = nil
		local textTemp = new(Text, self.data.msg, 0, 25, kAlignLeft, nil, 20, 255, 255, 255)
		local textTemp_w, _ = textTemp:getSize()
		if textTemp_w <= WAndFChatConfig.DEFAULT_CHAT_MSG_MAX_W then
			-- 单行
			self.m_chat_msg:setSize(textTemp_w,0)
			flag = 1
		else
			-- 多行
			self.m_chat_msg:setSize(WAndFChatConfig.DEFAULT_CHAT_MSG_MAX_W,0)
			flag = 2
		end 

		self.m_chat_msg.m_height = 0
		self.m_chat_msg:setText(self.data.msg)
		local w,h  = self.m_chat_msg:getSize() 

		local msgBg_w, msgBg_h = self.m_msg_bg:getSize()
		local root_w, _  = self.m_root:getSize()
		if flag == 1 then
			local mainW = 65
			self.m_msg_bg:setSize((w + 47) > mainW and w + 47 or  mainW, msgBg_h)
		elseif flag == 2 then
			self.m_root:setSize(root_w, h + 40)
			self:setSize(self.m_root:getSize())
			self.m_msg_bg:setSize(msgBg_w, h + 30)
		end
	end
end

function FriendsChatItem:setExpressionData()
	self.m_chat_msg:setVisible(false)
	if self.data.msg then
        local expressionId = ExpressionConfig:getIdBySign(self.data.msg)
		-- local expressionId = tonumber(self.data.msg)
        local isNewExp = math.floor(expressionId / 100 )
		local config = ExpressionConfig:getConfig(expressionId)
        if config then
            local imagesList, name = nk.functions.getExpImagesList(expressionId,config.frameNum,isNewExp);
            self.m_drawing = new(Images,imagesList);
            self.m_drawing:addPropScaleSolid(0, scale or 1, scale or 1, kCenterDrawing);
            self.m_drawing:setPos(0,0)
            self.m_drawing:setAlign(kAlignCenter)
            self.m_exp_node:addChild(self.m_drawing);

            local eachImageTime = 300
            if isNewExp == 1 then
                eachImageTime = 100
            elseif isNewExp == 2 then
                eachImageTime = 100
            end

            self.m_animIndex = new(AnimInt,kAnimRepeat ,0,config.frameNum -1,config.frameNum*eachImageTime,-1)
            self.m_animIndex:setDebugName("playExpressionAnim_.animIndex");
            local propIndex = new(PropImageIndex,self.m_animIndex);
            propIndex:setDebugName("playExpressionAnim_.propIndex");
            self.m_drawing:doAddProp(propIndex,1);      
   
            local image = new(Image,name)
            image:addPropScaleSolid(0, scale or 1, scale or 1, kCenterDrawing);
            local image_w,image_h = image:getSize()

            self.m_msg_bg:setSize(image_w+60 ,image_h+40)
            local root_w, _  = self.m_root:getSize()
            self.m_root:setSize(root_w, image_h+60)
            self:setSize(self.m_root:getSize())
        end
	end
end

function FriendsChatItem:setHeadImage()
    local icon = ""
    if self.data.kind == 1 then
    	icon = nk.userData.micon
    else
    	icon = self.micon
    end

    if self.data.msex and tonumber(self.data.msex) ==1 then
        self.m_head:setFile(kImageMap.common_male_avatar)
    else
        self.m_head:setFile(kImageMap.common_female_avatar)
    end
        
    if string.find(icon, "http")then
        UrlImage.spriteSetUrl(self.m_head, icon)
    end
end

function FriendsChatItem:dtor()
	if self.m_animIndex then
		delete(self.m_animIndex)
		self.m_animIndex = nil
	end
	if self.m_drawing then
		self.m_drawing:removeAllProp()
	    nk.functions.removeFromParent(self.m_drawing,true)
	end
end

return FriendsChatItem
