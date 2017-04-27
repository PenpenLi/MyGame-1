
-- 用法
-- local args = {
--     titleText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_TITLE"),
--     hasCloseButton = true,
--     hasFirstButton = false,
--     messageText = "onLoginHelpBtnClick onLoginHelpBtnClick", 
--     firstBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CONFIRM"),
--     secondBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CANCEL"), 
--     callback = function (type)
--         if type == nk.Dialog.FIRST_BTN_CLICK then
--             Log.printInfo("LoginScene onLoginHelpBtnClick", "FIRST_BTN_CLICK")
--         elseif type == nk.Dialog.SECOND_BTN_CLICK then
--             Log.printInfo("LoginScene onLoginHelpBtnClick", "SECOND_BTN_CLICK")
--         elseif type == nk.Dialog.CLOSE_BTN_CLICK then
--             Log.printInfo("LoginScene onLoginHelpBtnClick", "CLOSE_BTN_CLICK")
--         end
--     end
-- }
-- nk.PopupManager:addPopup(nk.Dialog,"login",args)


local PopupModel = require('game.popup.popupModel')

local DialogLayer = require(VIEW_PATH .. "popup.dialog_pop_layer")
local varConfigPath = VIEW_PATH .. "popup.dialog_pop_layer_layout_var"

local Dialog = class(PopupModel)

Dialog.FIRST_BTN_CLICK  = 1
Dialog.SECOND_BTN_CLICK = 2
Dialog.CLOSE_BTN_CLICK  = 3

function Dialog.show(args)
	PopupModel.show(Dialog, DialogLayer, varConfigPath, {name="Dialog"}, args, true)
end

function Dialog.hide()
	PopupModel.hide(Dialog)
end

function Dialog:ctor(viewConfig, varConfigPath, args)
    self:addShadowLayer()
	if type(args) == "string" then
        self.messageText_ = args
        self.firstBtnText_ = bm.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = bm.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = bm.LangUtil.getText("COMMON", "NOTICE")
    elseif type(args) == "table" then
        self.messageText_ = args.messageText
        self.callback_ = args.callback
        self.firstBtnText_ = args.firstBtnText or bm.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = args.secondBtnText or bm.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = args.titleText or bm.LangUtil.getText("COMMON", "NOTICE")
        self.noCloseBtn_ = (args.hasCloseButton == false)
        self.noFristBtn_ = (args.hasFirstButton == false)
        self.notCloseWhenTouchModel_ = (args.closeWhenTouchModel == false)
    end
    self:initScene(args)
end

function Dialog:initScene(args)
	self.popupBg = self:getUI("popup_bg")

	self.title = self:getUI("title")
	self.message = self:getUI("message")

	self.title:setText(self.titleText_)
	self.message:setText(self.messageText_)

	self.firstBtn = self:getUI("firstBtn")
	self.secondBtn = self:getUI("secondBtn")

    self.firstBtn_text = self:getUI("firstBtn_text")
    self.firstBtn_text:setText(self.firstBtnText_)
    self.secondBtn_text = self:getUI("secondBtn_text")
    self.secondBtn_text:setText(self.secondBtnText_)

	local _, secondBtn_y = self.secondBtn:getPos()

	if not self.noCloseBtn_ then
        self:addCloseBtn_()
    end

    local showFirstBtn = false
    if not self.noFristBtn_ then
        if self.firstBtnText_ then
            showFirstBtn = true
        end
    end
    if showFirstBtn then
    	self.firstBtn:setVisible(true)
    else
    	self.firstBtn:setVisible(false)
    	self.secondBtn:setPos(0,secondBtn_y)
    end
end

function Dialog:addCloseBtn_()
	self:addCloseBtn(self.popupBg)
end

function Dialog:onFirstBtnClick()
	if self.callback_ then
        self.callback_(Dialog.FIRST_BTN_CLICK)
    end
    self.callback_ = nil
    Dialog.hide()
end

-- 透明或半透明背景触摸响应
function Dialog:onBgTouch()
    if self.notCloseWhenTouchModel_ then
        return
    end
    self:dismiss()
end

function Dialog:onSecondBtnClick()
	if self.callback_ then
        self.callback_(Dialog.SECOND_BTN_CLICK)
    end
    self.callback_ = nil
    Dialog.hide()
end

function Dialog:onCloseBtnClick()
	if self.callback_ then
        self.callback_(Dialog.CLOSE_BTN_CLICK)
    end
    self.callback_ = nil
end

return Dialog


