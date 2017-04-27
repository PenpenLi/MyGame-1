-----------------------------

Mask = class(Node);
local stencilMask = require 'libEffect.shaders.stencilMask'

--------------------------------- static function -----------------------

-- 注意，调用此静态方法后，会返回新的drawing，drawing的class为Mask
Mask.setMask = function(drawing, maskFile, args)
    if kImageMap then
        if maskFile == kImageMap.common_head_mask_min then
            args = {scale = 1, align = 0, x = -1, y = -1}
        elseif maskFile == kImageMap.common_head_mask_big then
            maskFile = kImageMap.common_head_mask_min
            args = {scale = 1, align = 0, x = -1.5, y = 1}
        end
    end
    local drParent = drawing:getParent()
    local drX, drY = drawing:getPos()
    local drW, drH = drawing:getSize()
    local drAlign = drawing:getAlign()
    local drFile = drawing.m_res:getFile()

    local mask = new(Mask, drFile, maskFile)

    mask:setAlign(drAlign)
    mask:setSize(drW, drH)
    mask:setPos(drX, drY)
    
    -- 下载url图片标志
    mask.m_isDownloading = drawing.m_isDownloading

    if args then
        if args.align then
            mask.m_maskImage:setAlign(args.align) --kAlignTopLeft
        end
        if args.w and args.h then
            mask.m_maskImage:setSize(args.w, args.h)
        end
        if args.x and args.y then
            mask.m_maskImage:setPos(args.x, args.y)
        end
        if args.scale then
            local w, h = mask.m_maskImage:getSize()
            mask.m_maskImage:setSize(w * args.scale, h * args.scale)
        end
    end
    
    if drParent then
        drawing:removeFromParent(true)
        mask:addTo(drParent)
    else
        delete(drawing)
    end

    -- return mask
    return mask

    -- drawing:removeFromParent()

    -- local mask = new(Node)
    -- mask:setSize(drW, drH)
    -- mask:setAlign(drAlign)
    -- mask:setPos(drX, drY)

    -- local maskImage = new(Image, maskFile, nil, kFilterLinear)
    

    -- drImage:setAlign(drAlign)
    -- drImage:setSize(drX, drY)
    -- drImage:setPos(drW, drH)

    -- maskImage:setAlign(drAlign)
    -- maskImage:setSize(drX, drY)
    -- maskImage:setPos(drW, drH)

    -- drImage:addTo(drParent)
    -- maskImage:addTo(drParent)

    -- maskImage:setBlend(kBlendSrcOneMinusSrcAlpha, kBlendDstOneMinusSrcColor);
    -- drImage:setBlend(kBlendSrcOneMinusDstAlpha, kBlendDstDstAlpha);
end

--------------------------------- class ---------------------------------

Mask.ctor = function (self, imageFile, imageMask)
    if not (imageFile and imageMask) then return end;
    self:loadRes(imageFile,imageMask);
    self:renderMask();
end

Mask.dtor = function (self)
    delete(self.m_prifileImage);
    delete(self.m_maskImage);

    self.m_prifileImage = nil;
    self.m_maskImage = nil;
end

Mask.setSize = function (self, w, h)  
    self.m_width = w or 0;
    self.m_height = h or 0;
          
    self.m_prifileImage:setSize(self.m_width, self.m_height);
    self.m_maskImage:setSize(self.m_width, self.m_height);
    self.super.setSize(self, self.m_width, self.m_height);
end

Mask.getRealSize =function(self)
    return self.m_width*System.getLayoutScale(), self.m_height*System.getLayoutScale()
end

Mask.setFile = function(self,file)
    if self.m_prifileImage then
        self.m_prifileImage:setFile(file);
    end
end

Mask.getFile = function(self)
    if self.m_prifileImage then
        return self.m_prifileImage:getFile();
    end
end

Mask.setUrlImage = function(self,url,defaultFile)
    UrlImage.spriteSetUrl(self.m_prifileImage, url)
end

Mask.setGray = function(self, gray)
    if self.m_prifileImage then
        self.m_prifileImage:setGray(gray)
    end
end

local s_stencilStyle = true -- s stands for static, available in this file only

-----------------------private function---------------------------------
Mask.loadRes = function (self, imageFile, imageMask)

    self.m_prifileImage = new(Image, imageFile, nil, kFilterLinear);
    self.m_res = self.m_prifileImage.m_res
    self.m_maskImage = new(Image, imageMask, nil, kFilterLinear);
    
    if s_stencilStyle then
        self:addChild(self.m_prifileImage);
        self:addChild(self.m_maskImage);
    else
        self:addChild(self.m_maskImage);
        self:addChild(self.m_prifileImage);
    end

    self.m_width, self.m_height = self.m_prifileImage:getSize();
    self:setSize(self.m_width, self.m_height);
end

Mask.renderMask= function (self)
    if self.m_prifileImage and self.m_maskImage then
        if s_stencilStyle then
            stencilMask.applyToDrawing(self, self.m_prifileImage, self.m_maskImage)
        else
            drawing_set_blend_mode(self.m_maskImage.m_drawingID, kOneMinusSrcAlpha, kOneMinusSrcAlpha)
            drawing_set_blend_mode(self.m_prifileImage.m_drawingID, kOneMinusDstAlpha, kDstAlpha)
        end
        -- self.m_maskImage:setBlend(kDefault, kOneMinusSrcAlpha);
        -- self.m_prifileImage:setBlend(kOneMinusSrcAlpha, kSrcAlpha);
    end
end

