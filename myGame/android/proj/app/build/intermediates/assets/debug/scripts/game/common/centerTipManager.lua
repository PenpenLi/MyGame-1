
-- Date: 2016-07-19 16:47:47
--

--[[
    用法：
    nk.CenterTipManager:setParent(xxxxxx)
    1. 纯文本：nk.CenterTipManager:show("我就是我，不一样的烟火",{offset = 0})
]]

local CenterTipManager = class()

local DEFAULT_STAY_TIME = 3000 -- 停留时间
local DEFAULT_DU_TIME = 500 -- 下拉和回收时间
local TIP_HEIGHT = 57
local TIP_WIDTH = 900
local Z_ORDER = 1002

function CenterTipManager:ctor()
    -- 等待队列
    self.waitQueue_ = {}
    self.isPlaying_ = false
end

function CenterTipManager:show(tipData, params)
    assert(type(tipData) == "table" or type(tipData) == "string", "tipData should be a table")
    if params and params.offset then
        self.offset_ = params.offset
    end
    if not self.tipsNode then
        self.tipsNode = new(Node) 
        self.tipsNode:setAlign(kAlignCenter)
        self.tipsNode:setPos(0, self.offset_ or 0)

        -- 背景
        self.tipBg_ = new(Image, "res/common/common_top_tip_bg.png", nil, nil, 70, 70, 25, 25)
        self.tipBg_:setSize(TIP_WIDTH, TIP_HEIGHT)
        self.tipBg_:setTransparency(0.5)
        local tipBg_w, tipBg_h = TIP_WIDTH, TIP_HEIGHT
        self.tipBg_:setAlign(kAlignCenter)
        self.tipsNode:setSize(tipBg_w, tipBg_h)
        self.tipsNode:addChild(self.tipBg_)

        -- 可见区域
        self.clipView = new(Image, "res/common/common_blank.png")
        self.tipBg_:addChild(self.clipView)
        self.clipView:setAlign(kAlignCenter)
        self.clipView:setSize(tipBg_w - 50, tipBg_h - 10)
        self.clipView:setClip2(true, 0, 0, tipBg_w - 50, tipBg_h - 10)

        -- 文本
        -- self.label_ = new(Text, "", 0, 0, kAlignLeft, nil, 28, 255, 95, 130)
        -- self.label_:setAlign(kAlignLeft)
        -- self.clipView:addChild(self.label_)
    end

    nk.functions.removeFromParent(self.tipsNode,false)
    self.tipsNode:addToRoot();
    self.tipsNode:setLevel(Z_ORDER)

    if type(tipData) == "string" then
        -- 过滤重复的消息
        for _, v in pairs(self.waitQueue_) do
            if v.text == tipData then
                return
            end
        end
        table.insert(self.waitQueue_, {text = tipData})
    else
        -- 过滤重复的消息
        for _, v in pairs(self.waitQueue_) do
            if v.text == tipData.text then
                return
            end
        end
        table.insert(self.waitQueue_, tipData)
    end
    
    if not self.isPlaying_ then
        self:playNext_()
    end
end

function CenterTipManager:playNext_()
    if self.waitQueue_[1] then
        self.currentData_ = self.waitQueue_[1]
    else
        -- 播放完毕
        self.isPlaying_ = false
        nk.functions.removeFromParent(self.tipsNode,false)
        self.tipsNode:setVisible(false)
        return
    end
    
    self.tipsNode:setVisible(true)
    -- 设置文本和图标
    local tipData = self.currentData_
    local scrollTime = 0
    if tipData.text then
        -- Log.printInfo(tipData.text)
        -- self.label_:setSize(0,0)
        -- self.label_:setText("")
        -- self.label_:setText(tipData.text)
        -- self.label_:setPos(0,0)
        -- tips：self.label_的大小一直是最长的tipData.text对应的长度

        -- 文本
        self.clipView:removeAllChildren(true)
        self.label_ = nil
        self.label_ = new(Text, tipData.text, 0, 0, kAlignLeft, nil, 28, 255, 95, 130)
        local clip_w, _ = self.clipView:getSize()
        local text_w, _ = self.label_:getSize()
        local distence = text_w - clip_w
        if distence > 0 then
            self.label_:setAlign(kAlignLeft)
        else
            self.label_:setAlign(kAlignCenter)
        end
        self.clipView:addChild(self.label_)
    end

    self.isPlaying_ = true
    self:textDelay()
end

function CenterTipManager:textDelay()
    nk.GCD.PostDelay(self, function()
        self:startTextAnim()
        Log.printInfo("textDelay  startTextAnim")
    end, nil, 1000)
end

function CenterTipManager:startTextAnim()
    self:stopTextAnim()

    local clip_w, _ = self.clipView:getSize()
    local text_w, _ = self.label_:getSize()
    local distence = text_w - clip_w

    if distence > 0 then
        local moveTime = distence * 6 / 1
        self.moveXanim = self.label_:addPropTranslate(0, kAnimNormal, moveTime, -1, 0, -distence, 0, 0)
        self.moveXanim:setDebugName("TopTipManager.moveXanim")
        self.moveXanim:setEvent(self,self.complete)
    else
        nk.GCD.PostDelay(self, function()
            self:complete()
        end, nil, 1000)
    end
end

function CenterTipManager:stopTextAnim()
    if self.moveXanim then
        self.label_:doRemoveProp(0)
        delete(self.moveXanim)
        self.moveXanim = nil
    end
end

function CenterTipManager:complete()
    if not self.tipsNode then return end
    self:stopTextAnim()
    nk.GCD.PostDelay(self, function()
        table.remove(self.waitQueue_, 1)
        self.label_:setText("")
        self:playNext_()
    end, nil, 1000)
end



return CenterTipManager