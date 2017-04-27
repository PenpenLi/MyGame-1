--
-- Author: melon
-- Date: 2016-10-20 12:03:42
--
local PhotoViewPopup = require('game.photoManager.photoViewPopup')

local PhotoItem = class(Node)

function PhotoItem:ctor(data,index)
    self.posIndex = index
    self.imgIndex = data and data.index or 0
    local itemClass = require(VIEW_PATH .. "photoManager/photoItem")
    self.m_root = SceneLoader.load(itemClass)
    self:setSize(self.m_root:getSize());
    self:addChild(self.m_root)
    self.checkBoxGroup = self.m_root:getChildByName("CheckBoxGroup")
    self.checkBox = self.checkBoxGroup:getChildByName("CheckBox")
    self.text = self.m_root:getChildByName("Text")
    self.uploadBtn = self.m_root:getChildByName("UploadBtn")
    self.text1 = self.uploadBtn:getChildByName("Text1")
    self.photo = self.m_root:getChildByName("Photo")
    self.text1:setText(bm.LangUtil.getText("PHOTO_MANAGER", "UPLOAD"))
    self.text:setText(bm.LangUtil.getText("PHOTO_MANAGER", "SET_HEAD_ICON"))

    self.uploadBtn:setOnClick(self,self.onUploadPhoto)
    self.checkBoxGroup:setOnChange(self,self.onSetHeadIcon)
    self.photo:setEventTouch(self,self.onPhotoClick)  
        
    if index>1 then
        self.photo:setFile(kImageMap.userInfo_nophoto) 
    else
        if nk.userData.msex==1 then
            self.photo:setFile("res/photoManager/avatar_big_male.png") 
        else
            self.photo:setFile("res/photoManager/avatar_big_female.png") 
        end
    end
    self:updatePhoto(index,data.url)
    EventDispatcher.getInstance():register(EventConstants.update_photo, self, self.updatePhoto)
    EventDispatcher.getInstance():register(EventConstants.change_head_icon, self, self.setHeadIcon)
end

function PhotoItem:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.update_photo, self, self.updatePhoto)
    EventDispatcher.getInstance():unregister(EventConstants.change_head_icon, self, self.setHeadIcon)
end

function PhotoItem:updatePhoto(index,url)
    if index and index ==self.posIndex and url and url~="" then
        self.url = url
        if string.find(url,"http") then
            UrlImage.spriteSetUrl(self.photo, url)
        else
            UrlImage.spriteSetUrl(self.photo, nk.userData.iconurl..url)
        end
    end
end  

function PhotoItem:onUploadPhoto()
    if System.getPlatform() == kPlatformWin32  then  
        if not self.inputPath  then
            self.inputPath = new(EditText,"输入你要上传的图片",10,50,kAlignCenter,"",25,255,255,255);
            self.inputPath:setPos(0,0);
            self:addChild(self.inputPath)
            local function doEnd(obj,path)
                nk.functions.uploadPhoto(true,path,self.posIndex,self.imgIndex)
                self.inputPath:removeFromParent(true)
                self.inputPath = nil
            end
            self.inputPath:setOnTextChange(self,doEnd)
        end
    elseif System.getPlatform() == kPlatformAndroid  then    
        local data = {}
        data.imagePath = System.getStorageImagePath()
        data.mode = 1
        nk.GameNativeEvent:pickImage(data,self.posIndex,self.imgIndex)
    end
    nk.AnalyticsManager:report("New_Gaple_click_uploadphoto")
end

--设为头像
function PhotoItem:onSetHeadIcon(index,check)
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if self.url and self.url~="" then
        EventDispatcher.getInstance():dispatch(EventConstants.change_head_icon,self.posIndex)
        nk.HttpController:execute("setHeadIcon", {game_param = {mid = nk.userData.uid,index = self.imgIndex}}, nil, handler(self, function (obj, errorCode, data)
                    if data and  data.data ==1 then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "CHANGE_HEAD_ICON_SUCCESS"))
                        if string.find(self.url,"http") then
                            nk.userData["micon"] = self.url
                        else
                            nk.userData["micon"] = nk.userData.iconurl..self.url
                        end
                    end
           end ))
    else
        self.checkBoxGroup:getCheckBox(1):setChecked(false)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("PHOTO_MANAGER", "NOT_HAVE_PHOTO"))
    end
end

function PhotoItem:setHeadIcon(index)
    if index == self.posIndex then
        nk.userData.headIconIndex = index
        self.checkBoxGroup:getCheckBox(1):setChecked(true)
    else
        self.checkBoxGroup:getCheckBox(1):setChecked(false)
    end
end

local startX = 0
function PhotoItem:onPhotoClick(finger_action, x, y, drawing_id_first, drawing_id_current,event_time)
    if kFingerDown== finger_action then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        startX = x
    elseif kFingerUp== finger_action then
        if math.abs(startX-x)<12 then
            if self.url and self.url~="" then
                local index = self.posIndex 
                local photoDataList = {}
                for i,v in ipairs(nk.userData.photos) do
                    if v and v.url~="" then
                        if string.find(v.url,"http") then
                            table.insert(photoDataList,v.url)
                        else
                            table.insert(photoDataList,nk.userData.iconurl..v.url)
                        end    
                    else
                        if i<self.posIndex then
                            index  = index - 1  
                        end
                    end
                end
                nk.PopupManager:addPopup(PhotoViewPopup,"hall",photoDataList,index) 
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("PHOTO_MANAGER", "NOT_HAVE_PHOTO"))
            end      
        end
    end
end

return PhotoItem    