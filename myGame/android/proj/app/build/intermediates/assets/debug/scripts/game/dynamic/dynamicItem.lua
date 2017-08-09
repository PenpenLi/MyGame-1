--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local varConfigPathMy = VIEW_PATH .. "dynamic.dynamic_item_my_layout_var"
local itemViewMy = require(VIEW_PATH .. "dynamic.dynamic_item_my")

local varConfigPathOther = VIEW_PATH .. "dynamic.dynamic_item_other_layout_var"
local itemViewOther = require(VIEW_PATH .. "dynamic.dynamic_item_other")

local PersonalInfoDelegate = require("game.userInfo.personalInfoDelegate")

local DynamicItem = class(GameBaseLayer, false)

function DynamicItem:ctor(data)
	if data.msg_owerid == nk.userData.mid then
        super(self, itemViewMy);
    	self:declareLayoutVar(varConfigPathMy)
    else
        super(self, itemViewOther);
    	self:declareLayoutVar(varConfigPathOther)
    end
	
    self.data = data
    self:setSize(self.m_root:getSize());
    self:init()

    if self.data then
	    self:setData()
	end

	EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function DynamicItem:dtor()
	EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

function DynamicItem:onHttpProcesser(command, code, content)

end

function DynamicItem:init()
	-- 判断动态是谁发的
	if self.data.msg_owerid == nk.userData.mid then
		self.m_btnDelete = self:getUI("btn_delete")
		self.m_btnDelete:setSrollOnClick()
	else
		self.m_btnLike = self:getUI("btn_like")
		self.m_btnLike:setSrollOnClick()

		if self.data.isthumb ~= 1 then -- 1可以点赞0不可以-1改动态过去太久不能点赞
			self.m_btnLike:setEnable(false)
		end
	end

	self.m_time = self:getUI("text_time")
	self.m_dynamic = self:getUI("text_dynamic")
	self.m_like_times = self:getUI("text_like_times")
end

function DynamicItem:setData()
	local today = os.date("%x")
	local msgTime = os.date("%x", self.data.time)
	local strTime
	if msgTime == today then
		strTime = os.date("%H:%M", self.data.time) -- 时分
	else
		strTime = os.date("%Y-%m-%d", self.data.time) -- 年月日
	end

	self.m_time:setText(strTime)

	local w = self.m_dynamic:getSize()
	self.m_dynamic:setSize(w, 0) -- 高度0，自动换行
	self.m_dynamic:setText(self.data.content)

	self.m_bg = self:getUI("Image_bg")
	local m_bg_width, m_bg_height = self.m_bg:getSize()

	local  dy_w, dy_h = self.m_dynamic:getSize()

	if dy_h > 40 then
		self.m_bg:setSize(m_bg_width, m_bg_height + dy_h - 40)

		local  root_w, root_h = self.m_root:getSize()
		self.m_root:setSize(root_w, root_h + dy_h - 40)
		self:setSize(self.m_root:getSize());
	end



	self.m_like_times:setText(self.data.thumbs)

end

function DynamicItem:onBtnDeleteClick()
	local args = {
		messageText = T("是否删除动态"), 
		callback = function (type)
			if type == nk.Dialog.SECOND_BTN_CLICK then
				local params = {}
				params.mid = nk.userData.mid -- 删除操作用户id
				params.msgid = self.data.msgid
				params.isinfo = 0 -- 是否为个人信息面板	1是 0否
				nk.HttpController:execute("Social.delDynamic", {game_param = params})
				nk.AnalyticsManager:report("New_Gaple_delete_dyna")
            end
	    end
	}
	nk.PopupManager:addPopup(nk.Dialog, "dynamic", args) --todo
	
end

function DynamicItem:onBtnLikeClick()
	if self.data.isthumb == 1 then -- 1可以点赞0不可以-1改动态过去太久不能点赞
		local params = {}
		params.mid = nk.userData.mid -- 点赞用户id
	    params.uid = self.data.msg_owerid   -- 动态所属用户id
	    params.type = 1 -- 1动态 2签名 3相册
	    params.msgid = self.data.msgid
	    local x, y = self.m_btnLike:getAbsolutePos()
	    self.m_btnLike:setEnable(false)
	    PersonalInfoDelegate.getInstance():thumbUp(params, function(content)
	    	-- if content.data == self.data.msgid then
				if not nk.updateFunctions.checkIsNull(self) then
					self.data.isthumb = 0 -- 点赞成功，就不可以点赞了
					self.data.thumbs = self.data.thumbs + 1
					self.m_like_times:setText(self.data.thumbs)
					self.m_btnLike:setEnable(false)
				end
			-- end
	    end,  {x = x, y = y})
	elseif self.data.isthumb == 0 then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_ALREADY_TIPS"))
	elseif self.data.isthumb == -1 then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_LONGTIME_TIPS"))
	end

end

return DynamicItem


--endregion
