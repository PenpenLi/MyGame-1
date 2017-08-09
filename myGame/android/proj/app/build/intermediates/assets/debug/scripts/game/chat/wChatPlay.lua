
local WChatPlay = class()

function WChatPlay:ctor()
	-- 等待队列
    self.waitQueue_ = {}
    self.isPlaying_ = false
    self.roomType_ = 0
	nk.HornTextRotateAnim.setPlayFinished(self,self.playNext_)
end

function WChatPlay:setBroadcast(pack)
    local isPlayBroadcast = nk.DictModule:getBoolean("gameData", nk.cookieKeys.MESSAGE, true)
	if pack and not isHomeing and isPlayBroadcast and pack.content and pack.content~="" then
		local tempObj = ""
		local mtype = pack.msg_id
	    local msg =  nk.Gzip.decodeBase64(pack.content)
	    msg = string.gsub(msg,"%%2B","+")
	    local content = nk.functions.symbolFilter(nk.functions.keyWordFilter(tostring(msg)))
	    local titleStr = mtype == consts.GAME_BROADCAST_ID.SYSTEM_MSG_ID and bm.LangUtil.getText("GAMEBOARDCASTNOTICE", "SYSTEM") or bm.LangUtil.getText("GAMEBOARDCASTNOTICE", "PLAYER")

	    tempObj = titleStr .. content

	    table.insert(self.waitQueue_, tempObj)

	    local broadCast = self:formatBroadCast(mtype,content)
	    nk.GameBroadCastHistoryManager:addBroadCast(broadCast)

	    if not self.isPlaying_ then
      	   self:playNext_()
    	end
	end
end

function WChatPlay:formatBroadCast(mtype,content)
	local broadCast = {}
	broadCast.time = os.time()
	broadCast.mine = false
	local pos = string.find(content,":")
	if mtype == consts.GAME_BROADCAST_ID.SYSTEM_MSG_ID then
		broadCast.msg = content
		broadCast.title = "Berita Sistem"
	elseif mtype == consts.GAME_BROADCAST_ID.SYSTEM_USER_ID then
		if pos then
			broadCast.title = string.sub(content,1,pos-1)
			local str = string.sub(content,pos+1)
			if string.sub(str,1,1) == " " then
				broadCast.msg = string.sub(str,2)
			else
				broadCast.msg = str
			end
			if nk.userData and nk.userData.name and broadCast.title == nk.userData.name then
				broadCast.mine = true
			end
		else
			broadCast.title = "Player"
			broadCast.msg = content
		end
	end
	return broadCast
end

function WChatPlay:playNext_()
    if self.waitQueue_[1] then
    	self.isPlaying_ = true
        self.currentData_ = table.remove(self.waitQueue_, 1)
        nk.HornTextRotateAnim.setHornVisible()
    else
        -- 播放完毕
        self.isPlaying_ = false
        nk.HornTextRotateAnim.setHornVisible()
        return
    end
    
    local topTipData = self.currentData_
	if topTipData ~= nil and topTipData ~= "" then
    	nk.HornTextRotateAnim.play(topTipData)
    end

end

return WChatPlay