--
-- Author: melon
-- Date: 2016-10-24 15:20:24
--
local PopupModel = require('game.popup.popupModel')
local photoView = require(VIEW_PATH .. "photoManager/photoView")
local photoViewVar = VIEW_PATH .. "photoManager/photoView_layout_var"
local PhotoViewPopup= class(PopupModel)
local scale = System.getLayoutScaleWidth() > System.getLayoutScaleHeight() and System.getLayoutScaleHeight()  or System.getLayoutScaleWidth()
local PhotoViewItem = class(Node)
function PhotoViewItem:ctor(url,index)
    self.url = url
    self.index = index
    self:setSize(System.getScreenWidth()/scale,System.getScreenHeight()/scale)
    local bg = new(Image,kImageMap.common_transparent)
    bg:setSize(System.getScreenWidth()/scale,System.getScreenHeight()/scale)
    self:addChild(bg)
    bg:setEventTouch(self,self.onCloseClick)  
    self.headIcon = new(Image, kImageMap.userInfo_nophoto)
    local w, h = self.headIcon:getSize()
    self.headIcon:setSize(w*System.getScreenHeight()/h/scale,System.getScreenHeight()/scale)
    self.headIcon:setAlign(kAlignCenter)
    self.headIcon:setPos(0,0)
    self:addChild(self.headIcon)
    if url and url~="" then
        UrlImage.spriteSetUrl(self.headIcon, url)
        UrlImage.spriteSetUrl(self.headIcon, string.gsub(url, ".png", "_big.png"))  
    end
end

local startX = 0
function PhotoViewItem:onCloseClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
    if  kFingerDown== finger_action then  
        startX = x
    elseif kFingerUp== finger_action then
        if math.abs(startX-x)<12 then
            PhotoViewPopup.hide()
        end
    end
end

function PhotoViewPopup.show(...)
    PopupModel.show(PhotoViewPopup, photoView, photoViewVar, {name="PhotoViewPopup"}, ...)
end

function PhotoViewPopup.hide()
    PopupModel.hide(PhotoViewPopup)
end

function PhotoViewPopup:ctor()
    self:addShadowLayer()
    self:initVar()
    self:initPanel()
    nk.AnalyticsManager:report("New_Gaple_info_view_photo")
end 

function PhotoViewPopup:dtor()
   
end 

function PhotoViewPopup:initVar()
    self.photoDataList = self.args[1]
    self.index = self.args[2]
end 

function PhotoViewPopup:initPanel()
    self.photoViewPager = self:getUI("ViewPager")
    self.photoViewPager:setSize(System.getScreenWidth()/scale,System.getScreenHeight()/scale)
    local adapter = new(CacheAdapter, PhotoViewItem,self.photoDataList)
    self.photoViewPager:setAdapter(adapter)
    self.photoViewPager:setPage(self.index)
    local scoller = self.photoViewPager:getScroller()
    if scoller then
        scoller:setUnitTurningFactor(0.12)
    end    
end 

return PhotoViewPopup