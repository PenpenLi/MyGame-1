--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PopupModel = import('game.popup.popupModel')
local personDynamicView = require(VIEW_PATH .. "dynamic/person_dynamic")
local personDynamicInfo = VIEW_PATH .. "dynamic/person_dynamic_layout_var"

local DynamicItem = require("game.dynamic.dynamicItem") 

local PersonDynamicPopup = class(PopupModel);

function PersonDynamicPopup.show(data)
	PopupModel.show(PersonDynamicPopup, personDynamicView, personDynamicInfo, {name="PersonDynamicPopup"}, data)
end

function PersonDynamicPopup.hide()
	PopupModel.hide(PersonDynamicPopup)
end

function PersonDynamicPopup:ctor(viewConfig, varConfigPath, data)
    self.data_ = data;
    self:addShadowLayer()
	self:initLayer()
	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)

	
	self:requestPersonDynamic()
end

function PersonDynamicPopup:initLayer()
     self:initWidget()
end

function PersonDynamicPopup:initWidget()
	self.image_bg_ = self:getUI("Image_bg")
	self:addCloseBtn(self.image_bg_)

    if self.data_ == nk.userData.mid then
        self:getUI("Text_title"):setText(bm.LangUtil.getText("DYNAMIC", "MY_DYNAMIC_TITLE"))
        self:getUI("text_tips"):setText(bm.LangUtil.getText("DYNAMIC", "MY_DYNAMIC_TIPS"))
    else
        self:getUI("Text_title"):setText(bm.LangUtil.getText("DYNAMIC", "OTHER_DYNAMIC_TITLE"))
        self:getUI("text_tips"):setText(bm.LangUtil.getText("DYNAMIC", "OTHER_DYNAMIC_TIPS"))
    end

    self.text_total_dynamics = self:getUI("text_total_dynamics")
    self.text_total_dynamics:setVisible(false)

    self.text_no_dynamic = self:getUI("text_no_dynamic")
    self.text_no_dynamic:setVisible(false)

    self.m_dynamicScrollView = self:getUI("ScrollView_dynamic")
end

function PersonDynamicPopup:requestPersonDynamic()
	self:setLoading(true)

	local params = {}
    params.mid = nk.userData.mid -- 操作人的id
    params.uid = self.data_      -- 获取谁的动态
    params.num = 10
	nk.HttpController:execute("Social.getDynamic", {game_param = params})

    if params.mid == params.uid then
        nk.AnalyticsManager:report("New_Gaple_open_my_dynas")
    else
        nk.AnalyticsManager:report("New_Gaple_open_other_dynas")
    end
end


function PersonDynamicPopup:onHttpProcesser(command, code, content)
	if command == "Social.getDynamic" then
		self:setLoading(false)

		if code ~= 1 then
			return
		end

		self.m_retData = content.data

        if self.m_retData and type(self.m_retData) == "table" and #self.m_retData > 0 then
            for i, data in ipairs(self.m_retData) do
                data.msg_owerid = self.data_
            end
        end

        -- self.m_retData = {   {content = "内容1", msgid = 21, time = 1477475377, thumbs = 11, isthumb = 1, msg_owerid = self.data_},
        --                      {content = "内容2", msgid = 22, time = 1476465377, thumbs = 12, isthumb = 1, msg_owerid = self.data_},
        --                      {content = "内容3", msgid = 23, time = 1475455377, thumbs = 13, isthumb = 1, msg_owerid = self.data_},
        --                      {content = "内容4", msgid = 24, time = 1474445377, thumbs = 14, isthumb = 1, msg_owerid = self.data_},
        --                      {content = "内容5", msgid = 25, time = 1473435377, thumbs = 15, isthumb = 1, msg_owerid = self.data_},
        --                      {content = "内容6", msgid = 26, time = 1472425377, thumbs = 16, isthumb = 1, msg_owerid = self.data_},
        --                      {content = "内容7", msgid = 27, time = 1471415377, thumbs = 17, isthumb = 1, msg_owerid = self.data_},
        --                      }

        self:fillList()

    elseif command == "Social.delDynamic" then -- 删除item的放到popup里面了，方便操作
        if content.data > 0 then --大于零成功返回msgid  0失败
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "DEL_SUCCESS"))

            local iDel;
            for i,v in ipairs(self.m_retData) do
                if v.msgid == content.data then
                    iDel = i
                    break
                end
            end
            nk.userData.tdyna = (tonumber(nk.userData.tdyna) or 1) - 1

            table.remove(self.m_retData, iDel)

            if iDel == 1 then -- 如果删除第一条
                if #self.m_retData > 0 then
                    -- 设置新的最近动态
                    nk.UserDataController.setUserDyna(self.m_retData[1].content, self.m_retData[1].msgid, self.m_retData[1].time, self.m_retData[1].thumbs)
                else
                    -- 设置新的最近动态 空
                    nk.UserDataController.setUserDyna("",0, 0, 0)
                end
            end

            self:fillList()  -- fillList 里面重新创建了一个adapter，直接在老得adapter里面删除一项显示有问题
            
        elseif content.data == 0 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "DEL_FAIL"))
        end

	end
end

function PersonDynamicPopup:fillList()
    if self.m_retData and type(self.m_retData) == "table" and #self.m_retData > 0 then

        self.m_dynamicScrollView:removeAllChildren()

        local pos_x, pos_y = 0, 0
        for i,v in ipairs(self.m_retData) do
            local item = new(DynamicItem, v)
            local width, height = item:getSize()
            item:setPos(pos_x, pos_y)

            self.m_dynamicScrollView:addChild(item)

            pos_y = pos_y + height
        end

        self.text_total_dynamics:setVisible(true)
        self.text_total_dynamics:setText(bm.LangUtil.getText("DYNAMIC", "TOTAL_DYNAMIC", table.getn(self.m_retData)))

        self.text_no_dynamic:setVisible(false)

    else
        self.m_dynamicScrollView:removeAllChildren()
        self.text_total_dynamics:setVisible(false)

        self.text_no_dynamic:setVisible(true)
        self.text_no_dynamic:setText(bm.LangUtil.getText("DYNAMIC", "NO_DYNAMIC"))

    end
end

function PersonDynamicPopup:setLoading(isLoading)
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

function PersonDynamicPopup:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

return PersonDynamicPopup
--endregion
