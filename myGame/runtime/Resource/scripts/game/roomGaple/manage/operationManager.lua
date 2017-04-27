--
-- Author: tony
-- Date: 2014-07-17 15:20:01
--

local RoomChatPopup = require("game.roomChat.roomChatPopup")

local OperationManager = class()

function OperationManager:ctor()
    
end

function OperationManager:createNodes()
    --聊天按钮
    self.chatBtn = self.scene.nodes.oprNode:getChildByName("chatBtn")
    self.chatBtn:setOnClick(self,self.onChatBtnClick)
    self.chatMsgNoReadTip = self.scene.nodes.oprNode:getChildByName("chatMsgNoRead")
    self.chatMsgNoReadTip:setVisible(false)
    
    if nk.userData and nk.userData.chatRecord and #nk.userData.chatRecord >0 then
        self.chatMsgNoReadTip:setVisible(true)
    end 

    self:addPropertyObservers()
end

function OperationManager:onChatBtnClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if not self.clicked then
        self.clicked = true
        if nk.loginRoomSuccess then
            nk.PopupManager:addPopup(RoomChatPopup,"RoomGaple",self.ctx,1)
            self.chatMsgNoReadTip:setVisible(false)
        end
    end
    nk.GCD.PostDelay(self, function()
        self.clicked = false
    end, nil, 500)
end

function OperationManager:dtor()
    nk.GCD.Cancel(self)
    self:removePropertyObservers()
end

function OperationManager:addPropertyObservers()
    self.chatRecordHandle = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", handler(self, function (obj, chatRecord)
        if not nk.updateFunctions.checkIsNull(obj) then
            if chatRecord and #chatRecord>0 then
                local isHave = nk.PopupManager:hasPopup(nil,"WAndFChatPopup")
                if not isHave then
                    obj.chatMsgNoReadTip:setVisible(true)  
                end
            else
                obj.chatMsgNoReadTip:setVisible(false)  
            end
        end
    end))
end

function OperationManager:removePropertyObservers()
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "chatRecord", self.chatRecordHandle)
end

return OperationManager