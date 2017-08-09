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

    local path = "game/rank/" .. data.index .. ".png"
    UrlImage.spriteSetUrl(self.m_headImage, iconUrl)
    self.m_maxscoreText:setText(maxScore)
    self.m_nameText:setText(name)
    self.m_rankImage:setFile(path)
end


return rankItemLayer