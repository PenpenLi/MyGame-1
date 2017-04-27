local rankItemLayer = class(GameBaseLayer, false)
local itemView = require(VIEW_PATH .. "demo.rankItemLayer")
local varConfigPath = VIEW_PATH .. "demo.rankItemLayer_layout_var"

function rankItemLayer:ctor(data)
	Log.printInfo("rankItemLayer.ctor")
    super(self, itemView, varConfigPath)
    self:setSize(self.m_root:getSize())
 	self.m_bg = self:getUI("bg")
 	self.m_rankImage = self:getUI("rankImage")
 	self.m_headImage = Mask.setMask(self:getUI("headImage"), "game/common/headframe1.png", {scale = 1, align = 0, x = -1.5, y = -1})
    self.m_nameText = self:getUI("nameText")
    self.m_maxscoreText = self:getUI("maxscoreText")
    self:updateData(data)
end 

function rankItemLayer:dtor()
	Log.printInfo("rankItemLayer.dtor");
end

function rankItemLayer:updateData(data)

    if data.isSelf then
    	self.m_bg:setVisible(true)
    else
        self.m_bg:setFile("game/common/blank.png")
    end

    local iconUrl = data.iconUrl
    local name = data.nick
    local maxScore = data.maxscore
    local rankFile = {"game/rank/1.png","game/rank/2.png","game/rank/3.png","game/rank/4.png","game/rank/5.png","game/rank/6.png","game/rank/7.png","game/rank/8.png","game/rank/9.png","game/rank/10.png",
                      "game/rank/11.png","game/rank/12.png","game/rank/13.png","game/rank/14.png","game/rank/15.png","game/rank/16.png","game/rank/17.png","game/rank/18.png","game/rank/19.png","game/rank/20.png",
                      "game/rank/21.png","game/rank/22.png","game/rank/23.png","game/rank/24.png","game/rank/25.png","game/rank/26.png","game/rank/27.png","game/rank/28.png","game/rank/29.png","game/rank/30.png"}
    UrlImage.spriteSetUrl(self.m_headImage, iconUrl)
    self.m_maxscoreText:setText(maxScore)
    self.m_nameText:setText(name)
    self.m_rankImage:setFile(rankFile[data.index or 1])
end


return rankItemLayer