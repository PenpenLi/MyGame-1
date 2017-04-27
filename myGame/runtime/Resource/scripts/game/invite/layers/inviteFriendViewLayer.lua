-- invitefriendViewLayer.lua
-- Last modification : 2016-06-30
-- Description: a people item layer in invite moudle

local InviteFriendViewLayer = class(GameBaseLayer, false)
local view = require(VIEW_PATH .. "invite.invite_friend_view_layer")
local varConfigPath = VIEW_PATH .. "invite.invite_friend_view_layer_layout_var"
local InviteFriendItemLayer = require("game.invite.layers.inviteFriendItemLayer")
local InviteConfig = require("game.invite.inviteConfig")
local LoadingAnim = require("game.anim.loadingAnim")

-- 更新好友列表
local update_invite_friend_scroll

function InviteFriendViewLayer:ctor()
	Log.printInfo("InviteFriendViewLayer.ctor");
	super(self, view, varConfigPath)
    -- self.size = self.m_root.size

    -----------
    -- 标记字段
    -----------

    -- 加载好友列表
    self.m_isGetInviteList_ing = false
    self.m_isGetInviteList_ed = false
    -----------
    -- 标记字段 end
    -----------

    -- 全选勾image
    self.m_checkImage = self:getControl(self.s_controls["checkImage"])
    -- 全选label
    self.m_checkAllLabel = self:getControl(self.s_controls["checkAllLabel"])
    self.m_checkAllLabel:setText(bm.LangUtil.getText("FRIEND", "SELECT_ALL"))
    -- 查询EditBox
    self.m_searchEditBox = self:getControl(self.s_controls["searchEditBox"])
    self.m_searchEditBox:setHintText(bm.LangUtil.getText("FRIEND", "SEARCH_FRIEND"), 165, 145, 120)
    self.m_searchEditBox:setOnTextChange(self, self.onEditTextChange);
	-- 查询按钮
	self.m_searchButton = self:getControl(self.s_controls["searchButton"])
    self.m_searchButton:setEnable(false)
	-- 邀请按钮
	self.m_inviteButton = self:getControl(self.s_controls["inviteButton"])
	-- 邀请按钮label
	self.m_inviteLabel = self:getControl(self.s_controls["inviteLabel"])
    self.m_inviteLabel:setText(bm.LangUtil.getText("FRIEND", "SEND_INVITE"))
    -- 好友列表ScrollView
    self.m_itemScrollView = self:getControl(self.s_controls["itemScrollView"])
    self.m_itemScrollView:setFloatLayout(true)
    -- 存储全部子项
    self.m_items = {}
    -- 赠送金币提示label
    self.m_bottomImage = self:getUI("bottomImage")
    self.m_richText = new(RichText,"", 714, 42, kAlignCenter, "", 20, 255, 255, 255, false,0);
    self.m_richText:setAlign(kAlignCenter)
    self.m_bottomImage:addChild(self.m_richText)
    -- self.m_chooseTipLabel = self:getControl(self.s_controls["chooseTipLabel"])

    -- loading控件
    self.m_loadingAnim = new(LoadingAnim)
    self.m_loadingAnim:addLoading(self:getUI("bgView"))

    EventDispatcher.getInstance():register(InviteFriendItemLayer.checkChanged, self, self.onListenChange)
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end 

function InviteFriendViewLayer:dtor()
	Log.printInfo("InviteFriendViewLayer.dtor");
    EventDispatcher.getInstance():unregister(InviteFriendItemLayer.checkChanged, self, self.onListenChange)
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
    for i, v in pairs(self.m_items) do
        delete(v)
    end
    self.m_items = {}
end

-------------------private function-----------------------

function InviteFriendViewLayer:getInviteFriendData()
    Log.printInfo("InviteFriendViewLayer", "getInviteFriendData");
    if self.m_isGetInviteList_ing then
        return
    end
    self:onShowLoading(true)
    self.m_isGetInviteList_ing = true
    nk.FacebookNativeEvent:getInvitableFriends(handler(self, self.getInviteFriendDataCallback), InviteConfig.testData)
end

function InviteFriendViewLayer:getInviteFriendDataCallback(status, data)
    Log.printInfo("InviteFriendViewLayer", "getInviteFriendDataCallback")
    Log.printInfo("InviteFriendViewLayer", status)

    self:onShowLoading(false)
    self.m_isGetInviteList_ing = false
    if status and data then
        self.m_isGetInviteList_ed = true
        self.m_data = data
        local data = self:onGetData_(self.m_data)
        self:onUpdateList(self.m_checkImage:getVisible(), data)
    else
        Log.printInfo("InviteFriendViewLayer", "faild!!!!!faild!!!!!faild!!!!!faild!!!!!faild!!!!!")
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND","INVITE_OLD_USER_TIP"))
        self.m_isGetInviteList_ed = false
    end
end

function InviteFriendViewLayer:selectAll(status)
	Log.printInfo("InviteFriendViewLayer", "selectAll");
	if status then
		self.m_checkImage:setVisible(true)
        self:onUpdateList(true)
        self.m_checkAllLabel:setText(bm.LangUtil.getText("FRIEND", "DESELECT_ALL"))
	else
        self.m_checkImage:setVisible(false)
        self:onUpdateList(false)
        self.m_checkAllLabel:setText(bm.LangUtil.getText("FRIEND", "SELECT_ALL"))
	end
end

-- 获取选中的个数
function InviteFriendViewLayer:getSelectNum()
    local num = 0
    table.foreach(self.m_items, function(i,v)
            if v.m_checkImage:getVisible() then
                num = num + 1
            end
        end)
    return num
end

-- 更新提示
function InviteFriendViewLayer:updateSelectNum(isSelectAll)
    if isSelectAll then
        self.m_selectNum = #self.m_items
    else
        self.m_selectNum = self:getSelectNum()
    end
    if self.m_selectNum == #self.m_items then
        self.m_checkImage:setVisible(true)
    else
        self.m_checkImage:setVisible(false)
    end
    if nk.userData.inviteSendChips then
        self.m_richText:setText(bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", self.m_selectNum, nk.updateFunctions.formatBigNumber(self.m_selectNum * nk.userData.inviteSendChips)))
    end
end

function InviteFriendViewLayer:onListenChange()
    Log.printInfo("InviteFriendViewLayer", "onListenChange");
    self:updateSelectNum()
end

function InviteFriendViewLayer:onShowLoading(status)  
    if status then
        Log.printInfo("InviteFriendViewLayer","onShowLoading true")
        self.m_loadingAnim:onLoadingStart()
    else
        Log.printInfo("InviteFriendViewLayer","onShowLoading false")
        self.m_loadingAnim:onLoadingRelease()
    end
end

-- editText内容改变监听
function InviteFriendViewLayer:onEditTextChange(str)
    if str == "" or str == " " or str == nil then
        self:setSendBtnStatus(false);
        self.m_itemScrollView:removeAllChildren(true)
        self.m_items = {}
        if self.m_data then
            local data = self:onGetData_(self.m_data)
            self:onUpdateList(self.m_checkImage:getVisible(), data)
        end
    else
        self:setSendBtnStatus(true);
        self.editText_ = str
        self.m_searchEditBox:setText(nk.updateFunctions.limitNickLength(str,16))
    end
end

-- 设置发送按钮呼吸效果和可否点击
function InviteFriendViewLayer:setSendBtnStatus(enable)
    if enable then
        self.m_searchButton:setEnable(true);
        -- 发送按钮呼吸动画
        self.m_searchButton:addPropTransparency(1,kAnimLoop,600,-1,1,0.7);
    else
        self.m_searchButton:setEnable(false);
        self.m_searchButton:doRemoveProp(1);
    end
end

-- 筛选好友
function InviteFriendViewLayer:onGetData_(friendData, filterStr)
    local friendDataCopy = {}
    if friendData then
        friendDataCopy = clone(friendData)
        -- 排除今日邀请过的
        local invitedNames = nk.DictModule:getString("inviteName", "data")
        if invitedNames ~= "" then
            local inviteTable = json.decode(invitedNames)
            if inviteTable.time == os.date("%Y%m%d") and inviteTable.name then
                table.foreach(inviteTable.name, function(i, v)
                        table.foreach(friendDataCopy, function(j, k)
                                if v == k.name then
                                    table.remove(friendDataCopy, j)
                                end
                            end)
                    end)
            else
                nk.DictModule:setString("inviteName", "data", "")
                nk.DictModule:saveDict("inviteName")
            end
        end

        if filterStr and filterStr ~= "" and filterStr ~= " " then
            local tmpData = {}
            for k, v in pairs(friendDataCopy) do
                if (string.find(string.lower(v.name),string.lower(filterStr)) ~= nil) then
                    table.insert(tmpData,v)
                end
            end
            friendDataCopy = tmpData
        end

        friendDataCopy = self:sortFreind_(friendDataCopy)
        
        self.maxData_ = #friendDataCopy
        -- 一次展示个数（PHP配置）
        if self.maxData_ >= nk.userData.fbInviteNumCfg then
            self.maxData_ = nk.userData.fbInviteNumCfg
        end
    end

    return friendDataCopy
end

function InviteFriendViewLayer:sortFreind_(friendData)
    -- 排序好友列表
    local count = #friendData
    --纯随机排序
    for i=1, count do
        local j,k = math.random(count), math.random(count)
        friendData[j],friendData[k] = friendData[k],friendData[j]
    end            
    return friendData
end

-------------------public function-----------------------

function InviteFriendViewLayer:onShow()
	Log.printInfo("InviteFriendViewLayer", "onShow");
	if not self.m_isGetInviteList_ed and not self.m_isGetInviteList_ing then
		self:getInviteFriendData()
	end
end

function InviteFriendViewLayer:onUpdateList(isCheckAll, data)
	Log.printInfo("InviteFriendViewLayer.onUpdateList");
	update_invite_friend_scroll(self.m_itemScrollView, data, isCheckAll, self.m_items, self.maxData_)
    self:updateSelectNum(isCheckAll)
end

-------------------UI handler---------------------------

function InviteFriendViewLayer:onSearchButtonClick()
    if self.m_isGetInviteList_ed then
        Log.printInfo("InviteFriendViewLayer", "onInviteButton")
        local idStr = self.editText_ or "";
        local data = self:onGetData_(self.m_data, idStr)
        self.m_itemScrollView:removeAllChildren(true)
        self.m_items = {}
        self:onUpdateList(self.m_checkImage:getVisible(), data)
    end
end

function InviteFriendViewLayer:onInviteButtonClick()
    Log.printInfo("InviteFriendViewLayer", "onInviteButtonClick")
    if self:getSelectNum() == 0 then return end

    local toIds = ""
    local names = ""
    local toIdArr = {}
    local nameArr = {}
    for _, item in ipairs(self.m_items) do
        if item.m_checkImage:getVisible() then
            table.insert(toIdArr, item.m_data.id)
            table.insert(nameArr, item.m_data.name)
        end
    end
    toIds = table.concat(toIdArr, ",")
    names = table.concat(nameArr, "#")

    self.m_toIds = toIds
    self.m_names = names
    self.m_nameArr = nameArr

    -- 发送邀请
    if toIds ~= "" then
        nk.HttpController:execute("getInviteId", {game_param = {}})
    end
end

function InviteFriendViewLayer:onCheckButtonClick()
    Log.printInfo("InviteFriendViewLayer", "onCheckButtonClick")
    if self.m_checkImage:getVisible() then
        self:selectAll(false)
    else
        self:selectAll(true)
    end
end

function InviteFriendViewLayer:onHttpProcesser(command, errorCode, data)
    if command == "getInviteId" then
        if errorCode == HttpErrorType.SUCCESSED then
            local retData = data.data
            local requestData = ""
            requestData = retData.sk;

            if requestData then
                nk.FacebookNativeEvent:invite(
                    requestData, 
                    self.m_toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT",nk.updateFunctions.formatBigNumber(nk.userData.inviteForRegist)), 
                    function (success, result)
                        if success and self.m_checkImage.m_res then
                            -- 保存邀请过的名字
                            if self.m_names and self.m_names ~= "" then
                                local invitedNames = nk.DictModule:getString("inviteName", "data")
                                local inviteTable = {}
                                if invitedNames ~= "" then
                                    inviteTable= json.decode(invitedNames)
                                end
                                if inviteTable.time == os.date("%Y%m%d") then
                                    inviteTable.name = MegerTables(inviteTable.name or {}, self.m_nameArr)
                                else
                                    inviteTable.time = os.date("%Y%m%d")
                                    inviteTable.name = self.m_nameArr
                                end
                                nk.DictModule:setString("inviteName", "data", json.encode(inviteTable))
                                nk.DictModule:saveDict("inviteName")
                            end

                            local data = self:onGetData_(self.m_data)
                            self.m_itemScrollView:removeAllChildren(true)
                            self.m_items = {}
                            self:onUpdateList(self.m_checkImage:getVisible(), data)

                            -- 去掉最后一个逗号
                            if result and result.toIds then
                                local idLen = string.len(result.toIds)
                                if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                                    result.toIds = string.sub(result.toIds, 1, idLen - 1)
                                end
                            end

                            local postData = {
                                data = requestData, 
                                requestid = result and result.requestId or "", 
                                toIds = result and result.toIds or "", 
                                source = "register"
                            }
                            postData.type = "register"

                            nk.HttpController:execute("inviteReport", {game_param = postData})
                        else
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "REQUIRE_LATER"))
                        end
                    end
                )
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
        end
    end
end

-------------------------------- table config -----------------------------

InviteFriendViewLayer.s_eventHandle = {
    [EventConstants.httpProcesser] = InviteFriendViewLayer.onHttpPorcesser,
}

InviteFriendViewLayer.s_httpRequestsCallBack = {
	
}

local setItemData = function(root, isCheckAll)
    UrlImage.spriteSetUrl(root.m_headImage, root.m_data.url)
    root.m_nameLabel:setText(nk.updateFunctions.limitNickLength(root.m_data.name,8))
    root.m_moneyLabel:setText("+" .. nk.updateFunctions.formatBigNumber(nk.userData.inviteSendChips))
    if isCheckAll then
        root.m_checkImage:setVisible(true)
    else
        root.m_checkImage:setVisible(false)
    end
    if tonumber(root.m_data.msex) ==1 then
        root.m_sexIcon:setFile(kImageMap.common_sex_man_icon)
    else
        root.m_sexIcon:setFile(kImageMap.common_sex_woman_icon)
    end
    if root.m_data.vip and tonumber(root.m_data.vip)>0 then 
        root.m_vipk:setFile("res/common/vip_head_kuang.png")
        root.m_vipk:setSize(67,67)
        root.vipbs = new(Image, kImageMap.vip_bs)
        root.vipbs:setAlign(kAlignCenter)
        root.vipbs:addPropScaleSolid(0, 0.2, 0.2, kCenterDrawing);
        root.vipbs:setPos(-82,-20)
        self.m_itemButton:addChild(root.vipbs)
        root.m_nameLabel:setColor(0xa0,0xff,0x00)
    end
end

update_invite_friend_scroll = function(content, data, isCheckAll, items, showNum)
	-- data.url
	-- data.name
	-- data.chips
    if not data then
        if items and not table_is_empty(items) then
            for i, v in ipairs(items) do
                v.m_checkImage:setVisible(isCheckAll)
            end
        end
        return
    end


    if items and not table_is_empty(items) then
        if #data > #items then
            for i, v in ipairs(data) do
                if not items[i] then
                    items[i] = new(InviteFriendItemLayer)
                end
                items[i].m_data = v
                setItemData(items[i], isCheckAll)
            end
        else
            local removeIds = {}
            for i, v in ipairs(items) do
                if data[i] then
                    v.m_data = data[i]
                    setItemData(v, isCheckAll)
                else
                    table.insert(removeIds, i)
                end
            end
            table.foreach(removeIds, function(i, v)
                    local item = table.remove(items, i)
                    item:removeFromParent(true)
                end)
        end
        return
    end
    
	for i, v in ipairs(data) do
        if #items >= showNum then
            return
        end
    	local item = new(InviteFriendItemLayer)
        item.m_data = v
        setItemData(item, isCheckAll)
        table.insert(items, item)
        content:addChild(item)
    end
end

return InviteFriendViewLayer