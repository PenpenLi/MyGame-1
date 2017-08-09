
-- Date: 2016-07-19 16:47:47
--

--[[
    用法：
    1. 纯文本：nk.TopTipManager:showTopTip("我就是我，不一样的烟火")
]]

local TopTipManager = class()

local DEFAULT_STAY_TIME = 3000 -- 停留时间
local DEFAULT_DU_TIME = 500 -- 下拉和回收时间
local TIP_HEIGHT = 57
local TIP_WIDTH = 900
local Z_ORDER = 1002

function TopTipManager:ctor()
    -- 等待队列
    self.waitQueue_ = {}
    self.isPlaying_ = false
end

function TopTipManager:showTopTip(topTipData, instant)
    if (type(topTipData) == "string" and topTipData=="") or (type(topTipData) ~= "string" and type(topTipData) ~= "table") then
        return 
    end
    if not self.tipsNode then
        self.tipsNode = new(Node) 
        self.tipsNode:setAlign(kAlignTop)
        -- 背景
        self.tipBg_ = new(Image, "res/common/common_top_tip_bg.png", nil, nil, 70, 70, 25, 25)
        self.tipBg_:setSize(TIP_WIDTH, TIP_HEIGHT)
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
        -- self.label_ = new(Text, "", 0, 0, kAlignLeft, nil, 28, 255, 255, 255)
        -- self.label_:setAlign(kAlignLeft)
        -- self.clipView:addChild(self.label_)
    end

    nk.functions.removeFromParent(self.tipsNode,false)
    self.tipsNode:addToRoot();
    self.tipsNode:setLevel(Z_ORDER)

    if type(topTipData) == "string" then
        -- 过滤重复的消息
        for _, v in pairs(self.waitQueue_) do
            if v.text == topTipData then
                return
            end
        end
        table.insert(self.waitQueue_, {text = topTipData})
    elseif type(topTipData) == "table" then
        -- 过滤重复的消息
        for _, v in pairs(self.waitQueue_) do
            if v.text == topTipData.text then
                return
            end
        end
        table.insert(self.waitQueue_, topTipData)
    end
    
    if not self.isPlaying_ then
        self:playNext_()
    elseif instant then
        nk.GCD.Cancel(self)
        table.remove(self.waitQueue_, 1)
        self.label_:setText("")
        self:stopTextAnim()
        self:playNext_()
    end
end

function TopTipManager:playNext_()
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
    local topTipData = self.currentData_
    local scrollTime = 0
    if topTipData.text then
        -- Log.printInfo(topTipData.text)
        -- self.label_.m_width = 0
        -- self.label_:setText("")
        -- self.label_:setSize(0,0)
        
        -- self.label_:setText(topTipData.text)
        -- self.label_:setPos(0,0)
        -- tips：self.label_的大小一直是最长的topTipData.text对应的长度

        -- 文本
        self.clipView:removeAllChildren(true)
        self.label_ = nil
        self.label_ = new(Text, topTipData.text, 0, 0, kAlignLeft, nil, 28, 255, 255, 255)
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
    self:startDownAnim()

end

function TopTipManager:startDownAnim()
    self:stopDownAnim()
    self.moveYanim = self.tipsNode:addPropTranslate(0, kAnimNormal, DEFAULT_DU_TIME, -1, 0, 0, -TIP_HEIGHT, 0)
    if self.moveYanim then
        self.moveYanim:setDebugName("TopTipManager.moveYanim")
        self.moveYanim:setEvent(self,self.textDelay)
    else
        self:textDelay()
    end
end

function TopTipManager:stopDownAnim()
    if not self.tipsNode then return end
    self.tipsNode:doRemoveProp(0)
    -- delete(self.moveYanim)
    -- self.moveYanim = nil
end

function TopTipManager:textDelay()
    nk.GCD.PostDelay(self, function()
        self:startTextAnim()
    end, nil, 1000)
end

function TopTipManager:startTextAnim()
    self:stopDownAnim()
    self:stopTextAnim()

    local clip_w, _ = self.clipView:getSize()
    local text_w, _ = self.label_:getSize()
    local distance = text_w - clip_w
    if distance > 0 then
        local moveTime = distance * 20
        self.moveXanim = self.label_:addPropTranslate(0, kAnimNormal, moveTime, -1, 0, -distance, 0, 0)
        self.moveXanim:setDebugName("TopTipManager.moveXanim")
        self.moveXanim:setEvent(self,self.complete)
    else
        nk.GCD.PostDelay(self, function()
            self:complete()
        end, nil, 1000)
    end

end

function TopTipManager:stopTextAnim()
    if self.moveXanim then
        self.label_:doRemoveProp(0)
        delete(self.moveXanim)
        self.moveXanim = nil
    end
end

function TopTipManager:complete()
    if not self.tipsNode then return end
    self:stopDownAnim()
    nk.GCD.PostDelay(self, function()
        table.remove(self.waitQueue_, 1)
        self.label_:setText("")
        self:stopTextAnim()
        self:playNext_()
    end, nil, 1000)
end



return TopTipManager