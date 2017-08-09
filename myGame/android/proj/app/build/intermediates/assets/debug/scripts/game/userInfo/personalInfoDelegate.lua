local PersonalInfoDelegate = {}

local instance = PersonalInfoDelegate

PersonalInfoDelegate.getInstance = function()
	return instance
end

function PersonalInfoDelegate:thumbUp(params, func, fromPos)
	if self:checkIsThumbable(params.uid, params.type) then
		nk.HttpController:execute("Social.thumbsUp", {game_param = params}, nil, function(errorCode, content)
			if content then
				if content.data > 0 then --大于零成功返回msgid  0失败 -1已经点赞过
					PersonalInfoDelegate.UpdateThumbUpCache(params.uid, params.type)
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_SUCCESS"))
					if func then func(content) end
					EventDispatcher.getInstance():dispatch(EventConstants.THUMB_UP, params.uid, params.type, content, fromPos)
				elseif content.data == 0 then
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_FAIL"))
				elseif content.data == -1 then
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_ALREADY_TIPS"))
				end
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_FAIL"))
			end
		end)
	else
		if params.type == 3 then
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_ALREADY_TIPS"))
		else
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("DYNAMIC", "LIKE_TO_MUCH_TIPS"))
		end
	end
	if params.type == 1 then
		nk.AnalyticsManager:report("New_Gaple_thumb_up_dyna")
	else --3
		nk.AnalyticsManager:report("New_Gaple_thumb_up_photo")
	end
end

function PersonalInfoDelegate:checkIsThumbable(thumpUpUid, type)
	thumpUpUid = thumpUpUid or ""
	local uid = nk.userData.uid or ""
	local KEY_TIME = "time" .. uid
	local thumbUpRecordTimeStr = nk.DictModule:getString("thumbUpRecord", KEY_TIME, "")
	if thumbUpRecordTimeStr == os.date("%x") then -- 时间是今天
		local KEY_RECORD_LIST
		local threshold = 0
	    if type == 3 then
	    	KEY_RECORD_LIST = "thumbUpRecordList" .. uid
	    	threshold = 0
	    else
	    	KEY_RECORD_LIST = "thumbUpDynaRecordList" .. uid
	    	threshold = 19
	    end
		local thumbUpRecordListStr = nk.DictModule:getString("thumbUpRecord", KEY_RECORD_LIST, "")
		if thumbUpRecordListStr ~= "" then
			local thumbUpRecordList = json.decode(thumbUpRecordListStr)
			-- self.thumbUpRecordList = thumbUpRecordList
			if thumbUpRecordList and thumbUpRecordList["" .. thumpUpUid] and thumbUpRecordList["" .. thumpUpUid] > threshold then
				return false
			end
		end
		return true
	else
		return true
	end
end

function PersonalInfoDelegate.UpdateThumbUpCache(thumpUpUid, type)
	local uid = nk.userData.uid or ""
	local KEY_TIME = "time" .. uid
	local thumbUpRecordTimeStr = nk.DictModule:getString("thumbUpRecord", KEY_TIME, "")
    local today = os.date("%x")
    local thumbUpRecordList
    local KEY_RECORD_LIST
    if type == 3 then
    	KEY_RECORD_LIST = "thumbUpRecordList" .. uid
    else
    	KEY_RECORD_LIST = "thumbUpDynaRecordList" .. uid
    end
	if thumbUpRecordTimeStr == today then -- 时间是今天
		local thumbUpRecordListStr = nk.DictModule:getString("thumbUpRecord", KEY_RECORD_LIST, "")
		if thumbUpRecordListStr ~= "" then
			thumbUpRecordList = json.decode(thumbUpRecordListStr) or {}
		else
			thumbUpRecordList = {}
		end
		thumbUpRecordList["" .. thumpUpUid] = (tonumber(thumbUpRecordList["" .. thumpUpUid]) or 0) + 1
    else
    	nk.DictModule:setString("thumbUpRecord", "thumbUpRecordList"  .. uid, "") -- clear
    	nk.DictModule:setString("thumbUpRecord", "thumbUpDynaRecordList"  .. uid, "") -- clear
    	thumbUpRecordList = {["" .. thumpUpUid] = 1}
    end
   	local thumbUpRecordListStr = json.encode(thumbUpRecordList)
   	nk.DictModule:setString("thumbUpRecord", KEY_RECORD_LIST, thumbUpRecordListStr)
   	nk.DictModule:setString("thumbUpRecord", KEY_TIME, today)
   	nk.DictModule:saveDict("thumbUpRecord")
end

return PersonalInfoDelegate