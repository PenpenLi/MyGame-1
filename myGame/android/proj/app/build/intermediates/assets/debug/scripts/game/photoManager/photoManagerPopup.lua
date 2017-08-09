--
-- Author: melon
-- Date: 2016-10-19 17:45:25
--
local PopupModel = require('game.popup.popupModel')
local PhotoItem = require('game.photoManager.photoItem')
local PhotoManagerView = require(VIEW_PATH .. "photoManager/photoManager")
local PhotoManagerVar = VIEW_PATH .. "photoManager/photoManager_layout_var"
local PhotoManagerPopup= class(PopupModel)

function PhotoManagerPopup.show(data)
    if not nk.userData.photos then
        return
    end
    PopupModel.show(PhotoManagerPopup, PhotoManagerView, PhotoManagerVar, {name="PhotoManagerPopup"}, data)
end

function PhotoManagerPopup.hide()
    PopupModel.hide(PhotoManagerPopup)
end

function PhotoManagerPopup:ctor()
    self:addShadowLayer()
    self:initVar()
    self:initPanel()
    nk.AnalyticsManager:report("New_Gaple_open_photomgr")
end 

function PhotoManagerPopup:dtor()
    local tempData = nk.userData.photos[nk.userData.headIconIndex]
    table.remove(nk.userData.photos,nk.userData.headIconIndex)
    table.insert(nk.userData.photos,1,tempData)
end 

function PhotoManagerPopup:initVar()
    nk.userData.headIconIndex = 1
    for i,v in ipairs(nk.userData.photos) do
        if (string.find(v.url,"http") and v.url==nk.userData.micon)  or 
        (not string.find(v.url,"http") and nk.userData.iconurl..v.url==nk.userData.micon) then
            nk.userData.headIconIndex = i
            break
        end
    end
end 

function PhotoManagerPopup:initPanel()
    self.bg = self:getUI("Image3")
    self:addCloseBtn(self.bg,16,25)
    self.title = self:getUI("Title")
    self.tips = self:getUI("tips")
    self.tips:setText(bm.LangUtil.getText("PHOTO_MANAGER", "TIPS"))
    self.photoListView = self:getUI("PhotoListView")
    self.title:setText(bm.LangUtil.getText("PHOTO_MANAGER", "TITLE"))
    self.photoListView:setDirection(kHorizontal)
    local adapter = new(CacheAdapter, PhotoItem,nk.userData.photos)
    self.photoListView:setAdapter(adapter)
    self:changeHeadIcon(nk.userData.headIconIndex)
end 

function PhotoManagerPopup:changeHeadIcon(index)
    local adapter = self.photoListView:getAdapter()
    for i=1,adapter:getCount() do
        local item = adapter:getView(i)
        item:setHeadIcon(index)
    end
end 

function PhotoManagerPopup:onListItemClick(adapter,view,index,viewX,viewY)
    Log.printInfo("onListItemClick", index, viewX, viewY)
   
end

return PhotoManagerPopup