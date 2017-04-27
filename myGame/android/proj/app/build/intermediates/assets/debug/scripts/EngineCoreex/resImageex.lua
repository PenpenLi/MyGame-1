-- resImage.lua
-- Date: 2016-07-07
-- Last modification : 2016-07-21
-- Description: Implemented ResImage 

local AtlasManager = require("view.atlas.atlasManager")

---
-- 获取自身的文件路径
-- @param self
-- @return string 
ResImage.getFile = function(self)
    return self.m_file;
end

-- 修改Core中的构造函数
local OldResCtorFunc = ResImage.ctor
ResImage.ctor = function(self, file, format, filter)
    if GameConfig.ROOT_CGI_SID=="1" and file == kImageMap["default_qiuqiu"] then
        file = kImageMap["default_gaple"]
    elseif GameConfig.ROOT_CGI_SID=="2" and file == kImageMap["default_gaple"] then
        file = kImageMap["default_qiuqiu"]    
    end
	self.m_file = AtlasManager.SearchFileTable(file) or file
    OldResCtorFunc(self, self.m_file, format, filter)
end

Image.setRatio = function(self,ratio)
    self.ratio = ratio
end

-- local OldSetFile = Image.setFile
-- Image.setFile = function(self, file, format, filter)
--     local bg = new(Image,file)
--     local tw,th = bg:getSize()
--     delete(bg)
--     if not self.ow and not self.oh then
--         self.ow,self.oh = self:getSize()
--     end
--     local ow,oh = self.ow,self.oh
--     if not self.ratio and tw >0 and th>0 then
--         nk.functions.updatePosAlignCenter(self)
--         local ratio = 1
--         if tw/ow >1 and th/oh>1 then
--             ratio = tw/ow < th/oh and tw/ow or th/oh
--         elseif tw/ow < 1 and th/oh<1 then
--             ratio = tw/ow > th/oh and tw/ow or th/oh    
--         end
--         self:setSize(tw/ratio,th/ratio)
--     elseif self.ratio then
--         self:setSize(tw*self.ratio,th*self.ratio) 
--     end
--     OldSetFile(self, file, format, filter)
-- end