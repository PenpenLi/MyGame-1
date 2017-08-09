-- loginScene.lua
-- Last modification : 2016-05-16
-- Description: a scene in login moudle
local LoginFeedbackPopup = require("game.login.loginFeedbackPopup")
local LoginScene = class(GameBaseScene);

local DOTS_NUM         = 30
local LOGO_RADIUS      = 120
local LOGIN_BTN_WIDTH  = 338
local LOGIN_BTN_HEIGHT = 92
local LOGIN_BTN_GAP    = 20

local PHPServerUrl = require("game.net.http.phpServerUrl")

function LoginScene:ctor(viewConfig,controller)
	Log.printInfo("LoginScene.ctor")
    self:initLoginScene()
    if not IS_RELEASE then
        self:initDebugView()
    end
end 

function LoginScene:resume()
    nk.PopupManager:removeAllPopup()
    GameBaseScene.resume(self);
end

function LoginScene:pause()
    nk.PopupManager:removeAllPopup()
	GameBaseScene.pause(self);
end 

function LoginScene:dtor()
    self:stopDotsAnim_()
    self.m_logo_node:stopAllActions()
    self.m_loginFBBtn:stopAllActions()
    self.m_loginGuestBtn:stopAllActions()
end 

function LoginScene:initLoginScene()
    self.m_logo = self:getUI("login_logo")
    self.m_logo:setFile(nk.updateFunctions.getLogoFileBySid())
    
    self.m_loginFBBtn = self:getControl(self.s_controls["login_FB"])
    self.m_loginGuestBtn = self:getControl(self.s_controls["login_guest"])
    self.m_guest_tips = self:getControl(self.s_controls["guest_tips"])
    self.m_guest_tips:setVisible(false)
    self.m_loginSingleBtn = self:getControl(self.s_controls["login_single"])
    self.m_girl = self:getControl(self.s_controls["login_girl"])
    self.m_logo_node = self:getControl(self.s_controls["login_logo_node"])
    self.m_copyright = self:getControl(self.s_controls["login_copyright"])
    local text = self.m_copyright:getText()
    text = text .. GameConfig.CUR_VERSION
    self.m_copyright:setText(text)

    self.m_logo_node:moveTo({time = 0.5, y=-150, onComplete=function()
            self:playDotsAnimInNormal_()
        end})
    self.m_loginFBBtn:fadeIn({time = 0.3, delay = 0.5})
    self.m_loginGuestBtn:fadeIn({time = 0.3, delay = 0.6})

    -- 登陆loading圆点
    self.dots_ = {}
    for i = 1, DOTS_NUM do
        self.dots_[i] = new(Image, kImageMap.login_rotary_dot)
        self.dots_[i]:setAlign(kAlignCenter)
        self.dots_[i]:setPos(
                math.sin((i - 1) * math.pi / 15) * LOGO_RADIUS, 
                math.cos((i - 1) * math.pi / 15) * LOGO_RADIUS
            )
        self.dots_[i]:opacity(0)
        self.dots_[i]:addTo(self.m_logo_node)
    end

    local fbBindStatus = nk.DictModule:getInt("gameData", nk.cookieKeys.GUEST_BIND_FB_STATUS, -5)
    if fbBindStatus == 1 then
        local fbName = nk.DictModule:getString("gameData", nk.cookieKeys.GUEST_BIND_FB_NAME, "")
        self.m_guest_tips:setVisible(true)
        if fbName ~= "" then
            self.m_guest_tips:setText(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL7", nk.updateFunctions.limitNickLength(fbName,8)))
        else
            self.m_guest_tips:setText(bm.LangUtil.getText("USERINFO", "FBBINDING_BTHNAME_FAIL8"))
        end
    end

    -- local RoomNewbieGuide = import("game.roomQiuQiu.layers.roomNewbieGuide")
    -- local roomNewbieGuide = new(RoomNewbieGuide)
    -- roomNewbieGuide:createNodes()
    -- roomNewbieGuide.ctx = {}
    -- roomNewbieGuide.ctx.scene = {}
    -- roomNewbieGuide.ctx.scene.nodes = {}
    -- roomNewbieGuide.ctx.scene.nodes.guideNode = self
end

-- 正在登陆动画组合
function LoginScene:playLoginAnim()
    self:playDotsAnimInLogin_()
    local animTime = 0.5
    self.m_logo_node:stopAllActions()
    self.m_loginFBBtn:stopAllActions()
    self.m_loginGuestBtn:stopAllActions()
    if self.loadingLabel_ then
        self.loadingLabel_:removeFromParent(true)
        self.loadingLabel_ = nil
    end
    transition.moveTo(self.m_logo_node, {time = animTime, y = -35})
    transition.moveTo(self.m_loginFBBtn, {time = animTime, x = -400})
    transition.moveTo(self.m_loginGuestBtn, {time = animTime, x = -400, onComplete = handler(self, function (obj)
            obj.loadingLabel_ = new(Text, bm.LangUtil.getText("LOGIN", "LOGINING_MSG"), 100, nil, kAlignCenter, "", 28, 255, 255, 255)
            obj.loadingLabel_:setAlign(kAlignBottom)
            obj.loadingLabel_:setPos(nil, -100)
            obj.loadingLabel_:addTo(obj.m_logo_node)
            self.isAnimPlayed = true
            if self.isLoginSucc then
                self:playLeaveScene()
            end
            -- self:requestCtrlCmd("LoginController.onLoginSceneAnimPlayed")
        end)
    })
end

-- 登陆失败动画组合
function LoginScene:playLoginFailAnim()
    self:playDotsAnimInNormal_()
    local animTime = 0.5
    self.m_loginFBBtn:stopAllActions()
    self.m_loginGuestBtn:stopAllActions()
    transition.moveTo(self.m_logo_node, {time = animTime, y = -150, })
    transition.moveTo(self.m_loginFBBtn, {time = animTime, x = 35, })
    transition.moveTo(self.m_loginGuestBtn, {time = animTime, x = 35, })
    if self.loadingLabel_ then
        self.loadingLabel_:removeFromParent(true)
        self.loadingLabel_ = nil 
    end
end

-- 正在登陆动画（圆圈）
function LoginScene:playDotsAnimInLogin_()
    self:stopDotsAnim_()
    self.firstDotId_ = 1
    self.dotsSchedulerHandle_ = nk.GCD.PostDelay(self, function(obj)
        -- obj.dots_[obj.firstDotId_]:removeProp(1)
        obj.dots_[obj.firstDotId_]:addPropTransparency(1, kAnimNormal, 1000, -1, 0, 1)
        local secondDotId = obj.firstDotId_ + DOTS_NUM * 0.5
        if secondDotId > DOTS_NUM then
            secondDotId = secondDotId - DOTS_NUM
        end
        -- obj.dots_[secondDotId]:removeProp(1)
        obj.dots_[secondDotId]:addPropTransparency(1, kAnimNormal, 1000, -1, 0, 1)
        obj.firstDotId_ = obj.firstDotId_ + 1
        if obj.firstDotId_ > DOTS_NUM then
            obj.firstDotId_ = 1
        end
    end, nil, 50, true)
end

-- 等待登陆动画（圆圈）
function LoginScene:playDotsAnimInNormal_()
    self:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:addPropTransparency(1, kAnimLoop, 1000, -1, 0, 0.5)
    end
end

-- 停止登陆动画（圆圈）
function LoginScene:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:opacity(0)
        dot:doRemoveProp(1)
    end
    if self.dotsSchedulerHandle_ then
        nk.GCD.CancelById(self, self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

function LoginScene:onloginFBBtnClick()
    Log.printInfo("LoginScene onloginFBBtnClick")
    self:playLoginAnim()
    self:requestCtrlCmd("LoginController.onLoginWithFacebook")
end

function LoginScene:updateViewOnLoginSucc()
    self.isLoginSucc = true
    if self.isAnimPlayed then
        self:playLeaveScene()
    end
end

function LoginScene:playLeaveScene()
    self.m_logo_node:fadeOut({time=0.5, delay=0, onComplete = function()
        self:requestCtrlCmd("LoginController.onLoginSceneAnimPlayed")
        self.m_logo_node:setVisible(false)
        self.m_girl:setVisible(false)
    end})
    self.m_girl:fadeOut({time=0.5, delay=0,})
end

function LoginScene:onLoginGuestBtnClick()
    Log.printInfo("LoginScene onLoginGuestBtnClick")
    self:playLoginAnim()
    self:requestCtrlCmd("LoginController.onLoginWithGuest")
end

function LoginScene:onLoginSingleBtnClick()
    Log.printInfo("LoginScene onLoginSingleBtnClick")
end
----[[
-- 这里是 切服 和 语言
-- 发布时不显示

function LoginScene:initDebugView()
    self.m_debug_view = self:getUI("debug_view")
    self.m_debug_view:setVisible(not IS_RELEASE)

    self.m_offline_btn = self:getUI("offline_btn")
    self.m_onLine_btn = self:getUI("onLine_btn")
    self.m_china_btn = self:getUI("china_btn")
    self.m_yinni_btn = self:getUI("yinni_btn")

    self.m_check_url = self:getUI("check_url")

    if not IS_RELEASE then
        self:setDebugBtnStatus()
    end
end

function LoginScene:onOffLineBtnClick()
    self.m_phpServerUrl_index = 1 
    nk.DictModule:setInt("changeServerData", nk.cookieKeys.CHANGE_SERVER, self.m_phpServerUrl_index)
    self:setDebugBtnStatus()
end

function LoginScene:onOnLineBtnClick()
    self.m_phpServerUrl_index = 2
    nk.DictModule:setInt("changeServerData", nk.cookieKeys.CHANGE_SERVER, self.m_phpServerUrl_index)
    self:setDebugBtnStatus()
end

function LoginScene:onChinaBtnClick()
    IS_YINNI = false
    appconfig.LANG = "zh_CN"
    self:setDebugBtnStatus()
end

function LoginScene:onYinniBtnClick()
    IS_YINNI = true
    appconfig.LANG = "th_ID"
    self:setDebugBtnStatus()
end

function LoginScene:onChangeBtnClick()
    package.loaded["init"] = nil 
    require("init")

    if not IS_RELEASE then
        local inHallIp = HttpConfig.inHallIp 
        package.loaded["game.net.http.httpConfig"]  = nil
        require("game.net.http.httpConfig")

        self.m_phpServerUrl_index = nk.DictModule:getInt("changeServerData", nk.cookieKeys.CHANGE_SERVER, 1)
        HttpConfig.s_request["Http_checkVersion"].url = PHPServerUrl[self.m_phpServerUrl_index][1]

        Log.printInfo("setDatussetDatussetDatussetDatus", HttpConfig.s_request["Http_checkVersion"].url)

        self.m_check_url:setText(HttpConfig.s_request["Http_checkVersion"].url or "123")
    end
    Log.printInfo("HttpConfig.s_request[Http_checkVersion].url = ", HttpConfig.s_request["Http_checkVersion"].url)
    StateMachine.getInstance():changeState(States.Update)
end

function LoginScene:setDebugBtnStatus()
    self.m_phpServerUrl_index = nk.DictModule:getInt("changeServerData", nk.cookieKeys.CHANGE_SERVER, 1)

    if self.m_phpServerUrl_index == 2 then
        self.m_offline_btn:setColor(128,128,128)
        self.m_onLine_btn:setColor(255,255,255)
    elseif self.m_phpServerUrl_index == 1 then
        self.m_offline_btn:setColor(255,255,255)
        self.m_onLine_btn:setColor(128,128,128)
    end

    package.loaded[appconfig.LANG_FILE_NAME] = nil   
    package.loaded["language.lang.LangUtil"]  = nil
    package.loaded["language.appconfig"]  = nil

    if appconfig.LANG == "th_ID" then
        self.m_yinni_btn:setColor(255,255,255)
        self.m_china_btn:setColor(128,128,128)
        T = require("language.lang.Gettext").gettextFromFile(System.getStorageInnerRoot() .."/scripts/language/lang/".. "th_ID" .. ".mo")
        bm.LangUtil         = require("language.lang.LangUtil")
    elseif appconfig.LANG == "zh_CN" then
        self.m_yinni_btn:setColor(128,128,128)
        self.m_china_btn:setColor(255,255,255)
        T = require("language.lang.Gettext").gettextFromFile(System.getStorageInnerRoot() .."/scripts/language/lang/".. "zh_CN" .. ".mo")
        bm.LangUtil         = require("language.lang.LangUtil")
    end
end

--]]




-----------------------------table config------------------------

-- Provide cmd handle to call
LoginScene.s_cmdHandleEx = 
{
    ["playLoginFailAnim"] = LoginScene.playLoginFailAnim,
    ["updateViewOnLoginSucc"] = LoginScene.updateViewOnLoginSucc,
};

return LoginScene