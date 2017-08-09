-- loginScene.lua
-- Last modification : 2016-06-01
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local changeHeadView = require(VIEW_PATH .. "userInfo/changeHead_layer")
local changeHeadInfo = VIEW_PATH .. "userInfo/changeHead_layer_layout_var"
local http2 = require('network.http2')
local ChangeHeadPopup = class(PopupModel);

function ChangeHeadPopup.show(data)
	PopupModel.show(ChangeHeadPopup, changeHeadView, changeHeadInfo, {name="ChangeHeadPopup"}, data)
end

function ChangeHeadPopup.hide()
	PopupModel.hide(ChangeHeadPopup)
end

function ChangeHeadPopup:ctor(viewConfig)
	  Log.printInfo("ChangeHeadPopup.ctor");
    self:addShadowLayer()
    EventDispatcher.getInstance():register(EventConstants.pickImageCallBack, self, self.pickImageCallBack)
    self:initLayer()
end 


function ChangeHeadPopup:initLayer()
     self:initWidget()
     self:createDefaultHeadList()
     self:initData()
end

function ChangeHeadPopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")
    self:addCloseBtn(self.image_bg_)
    self:getUI("Text_change_head"):setText(bm.LangUtil.getText("USERINFO","CHANGE_AVATAR"))
    self:getUI("Button_use"):setOnClick(self,self.bt_use_click)
    self:getUI("Button_photo"):setOnClick(self,self.bt_photo_click)
    self:getUI("Button_picture"):setOnClick(self,self.bt_picture_click)

    self:getUI("Text_use"):setText(bm.LangUtil.getText("USERINFO","USE"))
    self:getUI("Text_photo"):setText(bm.LangUtil.getText("USERINFO","PHOTO"))
    self:getUI("Text_picture"):setText(bm.LangUtil.getText("USERINFO","PICTURE"))
    self:getUI("Text_tip"):setText(bm.LangUtil.getText("USERINFO","INFO"))
    self.scrollView_head_ = self:getUI("ScrollView_headList")
    self.scrollView_head_:setDirection(kVertical)
    self.scrollView_head_:setScrollBarWidth(0)

end


function ChangeHeadPopup:createDefaultHeadList()
    self.headIcons_ = {}
    for i,v in ipairs(nk.s_headFile) do
         self.headIcons_[i] = self:createItem(i,v)
         local w,h = self.headIcons_[i]:getSize()
         
         self.headIcons_[i]:setPos(math.mod(i-1,5)*130 +5, math.floor((i-1)/5)*110 +5 )
         self.scrollView_head_:addChild(self.headIcons_[i])
    end  
end

function ChangeHeadPopup:initData()
    if not string.find(nk.userData["micon"], "http") then
        local icon = tonumber(nk.userData["micon"])  or 1
        self:change_head(icon)
    end
end

function ChangeHeadPopup:createItem(index,file)
    local node = new(Node)
    node:setSize(100,105)
    node.index = index   

    local head = new(Image,file)
     head:setSize(100,100)
   -- head:addPropScaleSolid(2,0.54,0.54,kCenterDrawing)
    head:setAlign(kAlignCenter)
    head:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
                                          if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
                                               self:change_head(node.index)
                                          end
                                          end)   
    node:addChild(head)

    --选中框
    local choose_icon = new(Image,"res/common/common_choose_big.png")
    choose_icon:setAlign(kAlignCenter)
    choose_icon:setSize(110,110)
    choose_icon:setName("choose_icon")
    choose_icon:setVisible(false)
    node:addChild(choose_icon)

 
    return node
end

function ChangeHeadPopup:change_head(index)
    for i,v in ipairs(self.headIcons_) do
         v:getChildByName("choose_icon"):setVisible(false)
         if i == index then
             v:getChildByName("choose_icon"):setVisible(true)
         end
    end
    
end

function ChangeHeadPopup:bt_use_click()
   --测试代码，暂时保留
    -- local filePath = System.getStorageImagePath()
    -- local destFile = filePath ..  'melon1.png'

    -- local iconKey = '~#kevin&^$xie$&boyaa'
    -- local time = os.time()
    -- local sig = md5_string(nk.userData.uid .. "|" .. 1 .. "|" .. time .. iconKey)

    -- http2.request_async({
    --     url = nk.userData.UPLOAD_PIC,
    --     post = { 
    --              {
    --                type = 'file',
    --                filepath = destFile,
    --                name = "upload",
    --                file_type = "image/png",
    --              },
    --              {
    --                type = "content",
    --                name = "sid",
    --                contents = "1",
    --              },
    --              {
    --                type = "content",
    --                name = "mid",
    --                contents = tostring(nk.userData.uid),
    --              },
    --              {
    --                type = "content",
    --                name = "time",
    --                contents = tostring(time),
    --              },
    --              {
    --                type = "content",
    --                name = "sig",
    --                contents = tostring(sig),
    --              },

    --     }
    --   },
    --     function(rsp)
    --        if rsp.errmsg then              
    --            Log.printInfo("ChangeHeadPopup", "upload headpic faild !")
    --        else
    --            Log.printInfo("ChangeHeadPopup", "upload headpic success !")
    --            --success
    --            nk.HttpController:execute("Member.updateUserIcon", {game_param = {iconname = nk.userData.uid}}, nil, handler(self, function (obj, errorCode, data)
		  --            if data.code ~= 1  then
    --                      Log.printInfo("updataUserIcon faild !")
    --                      nk.CenterTipManager.show("updata Icon faild !")           
    --                      return
    --                 end
    --                 nk.userData["micon"] = data.data.micon
    --                 nk.TopTipManager:showTopTip("updata Icon success !")
    --                 Log.printInfo("updataUserIcon success !")
    --            end ))
    --        end
    --     end
    --  )   

    -- do return end
   
    local ischoose = -1
    for i,v in ipairs(self.headIcons_) do
        if v:getChildByName("choose_icon"):getVisible() then
              ischoose = v.index
              break
        end
    end

    local commitHead = ""

    if ischoose ~= -1 then
        local icon = nk.userData["micon"]
        if not string.find(icon, "http") then
          icon = tonumber(icon) or 1
          if icon ~= ischoose then
              commitHead = tostring(ischoose)
          end
        else
           commitHead = tostring(ischoose) 
        end
    end

    if commitHead ~= "" then
         self:setLoading(true)
         nk.HttpController:execute("Member.updateUserIcon", {game_param = {iconname = commitHead}}, nil, handler(self, function (obj, errorCode, data)
              self:setLoading(false)
		      if not data or data.code ~= 1  then
                  Log.printInfo("updataUserIcon faild !")
                  nk.TopTipManager:showTopTip("updataUserIcon faild !")
                  return
              end
              nk.userData["micon"] = data.data.micon
              nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_SUCCESS"))
              self:hide()
         end ))    
    end

end

function ChangeHeadPopup:pickImageCallBack(status, data)
   if status then
      self.path_ = data
      Log.printInfo("ChangeHeadPopup","path =" .. self.path_)
      local iconKey = '~#kevin&^$xie$&boyaa'
      local time = os.time()
      local sig = md5_string(nk.userData.uid .. "|" .. 1 .. "|" .. time .. iconKey)

       http2.request_async({
         url = nk.userData.UPLOAD_PIC,
         post = {
                  {
                    type = 'file',
                    filepath = self.path_,
                    name = "upload",
                    file_type = "image/png",
                  },
                  {
                    type = "content",
                    name = "sid",
                    contents = "1",
                  },
                  {
                    type = "content",
                    name = "mid",
                    contents = tostring(nk.userData.uid),
                  },
                  {
                    type = "content",
                    name = "time",
                    contents = tostring(time),
                  },
                  {
                    type = "content",
                    name = "sig",
                    contents = tostring(sig),
                  },

         }
       },
         function(rsp)
            if rsp.errmsg then              
                Log.printInfo("ChangeHeadPopup", "upload headpic faild !")
                Log.dump(rsp)
            else
                Log.printInfo("ChangeHeadPopup", "upload headpic success !")
                --success
                System.removeFile(self.path_)
                nk.HttpController:execute("Member.updateUserIcon", {game_param = {iconname = nk.userData.uid}}, nil, handler(self, function (obj, errorCode, data)
                if data then
                      if data.code ~= 1  then
                          Log.printInfo("ChangeHeadPopup","updataUserIcon faild !")
                          nk.TopTipManager:showTopTip("updataUserIcon faild !")
                          return
                      end
                      Log.printInfo("ChangeHeadPopup","updataUserIcon success !")
                      nk.userData["micon"] = data.data.micon
                      nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "MOD_SUCCESS"))
                    end
                    self:hide()
                end ))
            end
         end
        )
   else
       Log.printInfo("ChangeHeadPopup","get headpic faild !")
   end
end


function ChangeHeadPopup:bt_photo_click()
    if System.getPlatform() == kPlatformWin32  then  return end
    local data = {}
    data.imagePath = System.getStorageImagePath()
    data.mode = 1
    nk.GameNativeEvent:pickImage(data)
end

function ChangeHeadPopup:bt_picture_click()
    if System.getPlatform() == kPlatformWin32  then  return end

    local data ={}
    data.imagePath = System.getStorageImagePath()
    data.mode = 2
    nk.GameNativeEvent:pickImage(data)
end

function ChangeHeadPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.image_bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function ChangeHeadPopup:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.pickImageCallBack, self, self.pickImageCallBack)
end 

return ChangeHeadPopup