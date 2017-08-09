-- Author: Fred Zeng
-- Date: 2016-03-25
-- Version 3.0.0
-- Description: 适配新版引擎的遮罩
local Image2dMask_Shader = require("shaders.image2dMask")
local colorTransform = require('libEffect.shaders.colorTransform')
SwfPlayer = class(Node)

SwfPlayer.ctor = function(self,swfInfo,pinMap)
	self.m_swfInfo = swfInfo;
	self.m_perTime = 1/swfInfo["fps"];
	self.m_currframe = 0;
	self.m_playTimes = 0;
	self.m_passTime = 0;
	self.m_repeatCount = -1;
	self.m_spriteMap = {};
	self.m_spriteDepthMap = {};
	self.m_imgMap = {};
	self.m_maskDepthMap = {};
	self:setSize(swfInfo["width"],swfInfo["height"]);
	self.m_startFrame = 1;
	self.m_endFrame = swfInfo["fnum"];
	self.m_imgPinMap = pinMap or _G[swfInfo["imagePinMapName"]];
	-- assert(self.m_imgPinMap ~= nil,swfInfo["imagePinMapName"]);
	self.m_imgCache = nil;
end

-- 获取某两帧之间的时间
SwfPlayer.getTimeBetween = function(self,startFrame,endFrame)
	endFrame = endFrame or self.m_swfInfo["fnum"];
	assert(startFrame < endFrame,"the startFrame must small then endFrame")
	return (endFrame - startFrame + 1) * self.m_perTime;
end

-- 设置完成事件回调
SwfPlayer.setCompleteEvent = function(self, obj, func)
    self.m_completeCallback = self.m_completeCallback or {};
	self.m_completeCallback.obj = obj;
	self.m_completeCallback.func = func;
end
--设置帧事件，到第frame帧会调用
SwfPlayer.setFrameEvent = function(self,obj,func,frame)
	self.m_frameCallback = self.m_frameCallback or {};
	self.m_frameCallback[frame] = {};
	self.m_frameCallback[frame].obj = obj;
	self.m_frameCallback[frame].func = func;
end

SwfPlayer.processFrameEvent = function(self,frame)
	if self.m_frameCallback and self.m_frameCallback[frame] then
		if self.m_frameCallback[frame].obj and self.m_frameCallback[frame].func then
            self.m_frameCallback[frame].func(self.m_frameCallback[frame].obj,frame);
        end
	end
end

SwfPlayer.setNodeCallback = function(self,nodeName,obj,func)
	self.m_nodeCallback = self.m_nodeCallback or {};
	self.m_nodeCallback[nodeName] = {};
	self.m_nodeCallback[nodeName].obj = obj;
	self.m_nodeCallback[nodeName].func = func;
end

SwfPlayer.processNodeCallback = function(self,nodeName,node)
	if self.m_nodeCallback and self.m_nodeCallback[nodeName] then
		if self.m_nodeCallback[nodeName].func then
            self.m_nodeCallback[nodeName].func(self.m_nodeCallback[nodeName].obj,nodeName,node);
        end
	end
end

--暂停。frame为停在第几帧，默认为当前帧
SwfPlayer.pause = function(self,frame)
	self:stopTimer();
	local f = frame or self.m_currframe or 1;
	self:gotoAndStop(f);
end


SwfPlayer.resetSprites = function(self)
	for k,v in pairs(self.m_spriteMap) do
		delete(v);
		self.m_spriteMap[k] = nil;
	end
	self.m_spriteMap = {};

	for k,v in pairs(self.m_spriteDepthMap) do
		-- delete(v);
		self.m_spriteDepthMap[k] = nil
	end
	self.m_spriteDepthMap = {};
	for k,v in pairs(self.m_maskDepthMap) do
		delete(v)
		self.m_maskDepthMap[k] = nil
	end
	self.m_maskDepthMap = {};
	self.m_imgMap = {};
end

--跳到并停留在某一帧
SwfPlayer.gotoAndStop = function(self,frame)
	assert(frame <= tonumber(self.m_swfInfo["fnum"]),"the frame can not be more than the total frame:" .. self.m_swfInfo["fnum"])
	self:setVisible(false)
	frame = math.floor(frame);
	if self.m_currframe > frame then
		self.m_currframe = 0;
		self:resetSprites();
		for i = 1,frame do
			self:onTimer();
		end
		return;
	elseif self.m_currframe == frame  then
		return;
	else 
		for i = 1, frame - self.m_currframe do
			self:onTimer();
		end
	end
	self:setVisible(true)
end
-- 播放过程中修改播放参数
SwfPlayer.resetPlayInfo = function(self,startFrame,endFrame,repeatCount)
	self.m_startFrame = startFrame or self.m_startFrame;
	self.m_endFrame = endFrame or self.m_endFrame;
	self.m_repeatCount = repeatCount or self.m_repeatCount;
end
-- 在某两帧之间循环播放
SwfPlayer.playBetween = function(self,startFrame,endFrame,repeatCount)
	assert(startFrame <= endFrame,"the startFrame must small then endFrame")
	self:resetSprites();
	self.m_currframe = 0;
	self:gotoAndStop(startFrame);
	self.m_currframe = startFrame - 1;
	self.m_startFrame = startFrame;
	self.m_endFrame = endFrame;
	self.m_repeatCount = repeatCount or -1;
	self.m_playTimes = 0;
	if startFrame < endFrame then
		self:statrTimer();
	end
end

SwfPlayer.setAnimParams = function(self,startFrame,endFrame,repeatCount)
	self.m_startFrame = startFrame;
	self.m_endFrame = endFrame;
	self.m_repeatCount = repeatCount or -1;
end

--parent   		  父节点
--frame    		  第几帧开始播放
--isKeep          播放完是否停留在最后一帧
--repeatCount 	  重复播放次数，-1或0为无限循环播放，默认1次
--delay           延迟播放
SwfPlayer.play = function(self,frame,isKeep,repeatCount,delay,autoClean)	
	self:resetSprites();
	if frame and frame > 1 then
		self:gotoAndStop(frame);
	end
	if not frame then frame = 1 end;
	self.m_currframe = frame - 1 or 0;
	self.m_startFrame = 1;
	self.m_endFrame = self.m_swfInfo["fnum"];
	self.m_repeatCount = repeatCount or 1;
	self.m_isKeep = isKeep;
	self.m_delay = delay or -1;
	self.m_autoClean = autoClean;
	self:statrTimer();
	self.m_playTimes = 0;
end

SwfPlayer.stop = function(self)
	self:stopTimer();
	self.m_passTime = 0;
	if self.m_completeCallback then
        if self.m_completeCallback.obj and self.m_completeCallback.func then
            self.m_completeCallback.func(self.m_completeCallback.obj);
        end
    end
    if self.m_isKeep ~= true and self.m_autoClean ~= false then
		delete(self)
	end
end

SwfPlayer.statrTimer = function(self)
	self:stopTimer();
 	self.m_passTime = 0;
 	self.m_clock = Clock.instance():schedule(function(dt)
 			self:update(dt);
 		end);
end

SwfPlayer.stopTimer = function(self)
	if self.m_clock then
		self.m_clock:cancel();
		self.m_clock = nil;
	end
end

SwfPlayer.isNeedRepeat = function(self)
	return self.m_repeatCount <= 0 or self.m_playTimes < self.m_repeatCount;
end


SwfPlayer.update = function(self,dt)
	if dt then
		self.m_passTime = self.m_passTime + dt;
		if self.m_passTime < self.m_perTime then
			return;
		end
		self.m_passTime = 0;
	end
	self:onTimer();
end

SwfPlayer.onTimer = function(self)
	if self.m_isReleased == true then
		return
	end

	-- if true then return end;

	
	self.m_currframe = self.m_currframe + 1;
	if self.m_currframe > self.m_endFrame then
		
		self.m_playTimes = self.m_playTimes + 1;
		local isRepeat = self:isNeedRepeat();
		if self.m_isKeep ~= true or isRepeat then
			self:resetSprites();
			self.m_currframe = 0;
			self:gotoAndStop(self.m_startFrame);
	   	end
	   	self.m_currframe = self.m_startFrame;
	   	if isRepeat ~= true then
			self:stop();
			return;
		end
	end
	local frameInfo = self.m_swfInfo["frames"][self.m_currframe];

	if not frameInfo then
		self:stop();
		return;
	end

	for i = 1,#frameInfo do
		local info = frameInfo[i];
		if info[1] == 1 then
			self.m_imgMap[info[2]] = info[3];
		elseif info[1] == 2 then
			local node;
			if info[7] and info[7] ~= 0 then
				if info[3] ~= 0 then
					node = new(SwfNode,self.m_imgPinMap);
					node:setLevel(info[2]);
					self:addChild(node);
					self.m_spriteMap[info[3].. "_"..info[2]] = node;
					self.m_spriteDepthMap[info[2]] = node;
					self:processNodeCallback(info[7],node)
				else
					node = self.m_spriteDepthMap[info[2]]
				end
			else
				local isMaskLayer = info[6] ~= 0;
				if isMaskLayer then
					if info[3] ~= 0 then
						local imgName = self.m_swfInfo["imageName"] .. "_" .. self.m_imgMap[info[3]] .. ".png"
						node = self.m_maskDepthMap[info[2]]
						if node then
							node:changeImg(imgName);
							node:setVisible(true);
						else
							node = new(SwfMask,info[2],info[6],imgName,self.m_imgPinMap);
							node:setLevel(info[2]);
							self.m_maskDepthMap[info[2]] = node;
							self:addChild(node);
						end
					else 
						node = self.m_maskDepthMap[info[2]]
					end
					if node then
						for i = info[2] + 1,info[6] do
							local sprite = self.m_spriteDepthMap[i]
							if sprite then
								node:addContent(sprite,i);
							end
						end
					end
				else
					if info[3] ~= 0 then
						node = self.m_spriteDepthMap[info[2]]
						if node then
							local imgName = self.m_swfInfo["imageName"] .. "_" .. self.m_imgMap[info[3]] .. ".png"
							node:changeImg(imgName);
							node:setVisible(true);
						else
							node = self:createSprite(info[3],info[2]);
							node:setLevel(info[2]);
							self.m_spriteDepthMap[info[2]] = node;
							local maskLayer = self:findMaskLayer(info[2]);
							if maskLayer then
								maskLayer:addContent(node,info[2]);
							else
								self:addChild(node);
							end
						end
					else 
						node = self.m_spriteDepthMap[info[2]]
						if node == nil then
							node = self.m_maskDepthMap[info[2]]
						end
					end
				end
			end

			if info[4] ~= 0 and node then
				node:setMatrix(info[4][1],info[4][2],info[4][3],info[4][4],info[4][5],info[4][6]);
			end

			if info[5] ~= 0 and node then
				colorTransform.setUniform(node,{r = info[5][1], g = info[5][2], b = info[5][3],a = info[5][4],
										oR = info[5][5]/255,oG = info[5][6]/255,oB = info[5][7]/255,oA = info[5][8]/255})
			end
		elseif info[1] == 3 then
			local lastSprite = self.m_spriteDepthMap[info[2]]
			if lastSprite then
				
				local maskLayer = self:findMaskLayer(info[2]);
				if maskLayer then
					maskLayer:removeContent(info[2]);
				else
					self:removeChild(lastSprite);
				end
				lastSprite:setVisible(false);
				self.m_spriteDepthMap[info[2]] = nil;
			end
			local lastMask = self.m_maskDepthMap[info[2]];
			if lastMask then
				local contents = lastMask:getContents();
				for k,v in pairs(contents) do
					self:addChild(v);
				end
				delete(lastMask);
				self.m_maskDepthMap[info[2]] = nil;
			end
		end
	end

	self:processFrameEvent(self.m_currframe);
end

SwfPlayer.findMaskLayer = function(self,depth)
	for k,v in pairs(self.m_maskDepthMap) do
		if v:isContent(depth) then
			return v;
		end
	end
	return nil;
end

SwfPlayer.createSprite = function(self,cid,depth)
	if self.m_spriteMap[cid.. "_"..depth] then
		self.m_spriteMap[cid.. "_"..depth]:setVisible(true);
		return self.m_spriteMap[cid.. "_"..depth];
	end
	local imgName = self.m_swfInfo["imageName"] .. "_" .. self.m_imgMap[cid] .. ".png";
	local sprite = new(SwfSprite,imgName,self.m_imgPinMap);
	self.m_spriteMap[cid.. "_"..depth] = sprite;

	if self.m_imgCache == nil then
		self.m_imgCache = new(Image,self.m_imgPinMap[imgName]);
	end
	return sprite;
end

SwfPlayer.dtor = function(self)
	self:stopTimer();

	if self.m_spriteMap then
	   	for k,v in pairs(self.m_spriteMap) do
	   		delete(v);
	   		self.m_spriteMap[k] = nil;
	   	end
	end
   	self.m_spriteMap = nil;
   	self.m_spriteDepthMap = nil;

   	self.m_completeCallback = nil;
   	self.m_frameCallback = nil;
   	if self.m_imgCache then
   		delete(self.m_imgCache)
   	end
   	self.m_imgCache = nil;
   	self.m_imgPinMap = nil;
   	self.m_isReleased = true;
end

--

SwfMask = class(LuaNode)

SwfMask.ctor = function(self,maskDepth,clipDepth,maskImgName,imgPinMap)
	self.m_mask = new(Image,imgPinMap[maskImgName]);
	self.m_mask:getWidget().double_sided = true;
	self.m_contentNode = new(Node);

	local contentNodeWg = self.m_contentNode:getWidget();
	local maskWg = self.m_mask:getWidget();
	self:getWidget():add(contentNodeWg);
	self:getWidget():add(maskWg);
	local rc = RenderContext(Image2dMask_Shader)
    self:getWidget().lua_do_draw = function (_, canvas)
    --画模板
        canvas:add(PushStencil())
        canvas:begin_rc(rc)
        maskWg:draw(canvas)            
        canvas:end_rc(rc)
       
    --画Drawing    
        canvas:add(UseStencil(gl.GL_EQUAL))
        contentNodeWg:draw(canvas);
        canvas:add(UnUseStencil())
        canvas:add(PopStencil())
        
        return true
    end
    self.m_imgPinMap = imgPinMap;
	self.m_contents = {};
	self.m_maskDepth = maskDepth;
	self.m_clipDepth = clipDepth;
end

SwfMask.isContent = function(self,depth)
	return depth > self.m_maskDepth and depth <= self.m_clipDepth;
end

SwfMask.changeImg = function(self,imgName)
	self.m_mask:setFile(self.m_imgPinMap[imgName]);
	self.m_mask:setSize(self.m_mask.m_res.m_width,self.m_mask.m_res.m_height);
end
--给mask层设置矩阵
SwfMask.setMatrix = function(self,a,b,c,d,sx,sy)
	sx = sx * System.getLayoutScale();
	sy = sy * System.getLayoutScale();
    drawing_set_force_matrix(self.m_mask.m_drawingID,1,unpack({a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,0,1}));
end

SwfMask.setContentMatrix = function(self,depth,a,b,c,d,sx,sy)
	local sprite = self:getContentByDepth(self,depth);
	if sprite then
		sx = sx * System.getLayoutScale();
		sy = sy * System.getLayoutScale();
        drawing_set_force_matrix(sprite.m_drawingID,1,unpack({a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,0,1}));
	end
end

SwfMask.addContent = function(self,sprite,depth)
	self.m_contentNode:addChild(sprite);
	sprite:setName("n_" .. depth);
	sprite:setLevel(depth);
	self.m_contents[depth] = sprite;
end

SwfMask.getContentByDepth = function(self,depth)
	return self.m_contentNode:getChildByName("n_" .. depth);
end

SwfMask.removeContent = function(self,depth)
	local sprite = self.m_contentNode:getChildByName("n_"..depth);
	if sprite then
		self.m_contentNode:removeChild(sprite);
	end
	self.m_contents[depth] = nil;
	return sprite;
end

SwfMask.getContents = function(self)
	return self.m_contents;
end

SwfMask.dtor = function(self)
	if self.m_mask then
		delete(self.m_mask);
	end
	self.m_mask = nil;
	if self.m_contentNode then
		delete(self.m_contentNode);
	end
	self.m_imgMap = {};
	self.m_contents = nil;
	self.m_contentNode = nil;
	self:getWidget():remove_all()
end

---/////////SwfSprite class////////////
SwfSprite = class(Image,false)

SwfSprite.ctor = function(self,imgName,imgPinMap)
	self.m_imgName = imgName;
	self.m_imgPinMap = imgPinMap;
	super(self,self.m_imgPinMap[imgName])
	self:getWidget().double_sided = true;
end

SwfSprite.changeImg = function(self,imgName)
	self.m_imgName = imgName;
	self:setFile(self.m_imgPinMap[imgName]);
	self:setSize(self.m_res.m_width,self.m_res.m_height);
end

SwfSprite.setMatrix = function(self,a,b,c,d,sx,sy)
	sx = sx * System.getLayoutScale();
	sy = sy * System.getLayoutScale();
    drawing_set_force_matrix(self.m_drawingID,1,unpack({a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,0,1}));
end
--//SwfNode
SwfNode = class(Node,false);
SwfNode.ctor = function(self,imgPinMap)
	self.m_imgPinMap = imgPinMap;
	super(self)
	self:getWidget().double_sided = true;
end

SwfNode.setMatrix = function(self,a,b,c,d,sx,sy)
	sx = sx * System.getLayoutScale();
	sy = sy * System.getLayoutScale();
	drawing_set_force_matrix(self.m_drawingID,1,unpack({a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,0,1}));
end

