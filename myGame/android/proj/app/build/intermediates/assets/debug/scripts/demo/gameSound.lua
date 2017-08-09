local gameSound = class()

gameSound.bgMusicFileMap = {

    [1] = "bg1",
    [2] = "bg2",
    [3] = "bg3" ,
    [4] = "bgMusic"

}

gameSound.effectsFileMap = {

    ["deathZombie"] = "deathZombie", 
    ["deathJump"] = "deathJump",
    ["deathKick"] = "deathKick",
    ["deathLong"] = "deathLong",
    ["victory"] = "victory",
    ["hit"] = "hit",
    ["bomb"] = "Bomb" 
}

function gameSound:ctor()
    FwLog(">>>>>>>>>>>>>>>>>>>>>>> gameSound")
	self.m_musicPlayer = GameMusic.getInstance();
	self.m_musicPlayer:setPathPrefixAndExtName("",".mp3")
    self.m_musicPlayer:setSoundFileMap(gameSound.bgMusicFileMap)

    self.m_effectPlayer = GameEffect.getInstance();
    self.m_effectPlayer:setPathPrefixAndExtName("",".mp3")
    self.m_effectPlayer:setSoundFileMap(gameSound.effectsFileMap)

    EventDispatcher.getInstance():register(Event.Resume, self, self.resumeMusic)
    EventDispatcher.getInstance():register(Event.Pause, self, self.pauseMusic)
end

function gameSound:dtor( ... )

    EventDispatcher.getInstance():unregister(Event.Resume, self, self.resumeMusic)
    EventDispatcher.getInstance():unregister(Event.Pause, self, self.pauseMusic)

end

-- 音乐
function gameSound:playMusic(soundName, loop)
    return self.m_musicPlayer:play(soundName, loop or false)
end

function gameSound:stopMusic()
    return self.m_musicPlayer:stop()
end

function gameSound:pauseMusic()
    return self.m_musicPlayer:pause()
end

function gameSound:resumeMusic()
    if nk.DictModule:getBoolean("gameSound", "playMusic", true) then
        return self.m_musicPlayer:resume()
    end  
end




function gameSound:playEffect( soundName, loop )
    if nk.DictModule:getBoolean("gameSound", "playEffect", true) then
	   return self.m_effectPlayer:play(soundName, loop or false)
    end
end


function gameSound:stopEffect()
    return self.m_effectPlayer:stop()
end

function gameSound:pauseEffect()
    return self.m_effectPlayer:stop() 
end

function gameSound:resumeEffect()
    if nk.DictModule:getBoolean("gameSound", "playEffect", true) then
       return self.m_effectPlayer:play(soundName, loop or false)
    end
end



return gameSound