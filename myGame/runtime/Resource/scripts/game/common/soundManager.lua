-- SoundManager.lua
-- Create Date : 2016-08-10
-- Last modification : 2016-08-10
-- Description: a manager for music and effects

local SoundManager = class()

-- 音乐配置
SoundManager.musics = {
    BG_MUSIC = 1,
}

SoundManager.musicFileMap = {
    [SoundManager.musics.BG_MUSIC] = "bgMusic";
}

-- 音效配置
SoundManager.effects = {
    -- 公共音效
    CLICK_BUTTON = 1;
    CLOSE_BUTTON = 2;
    REPLACE_SCENE = 3;
    GEAR_TICK = 4;
    BOX_OPEN_REWARD = 5;
    CHIP_DROP = 6;
    NOTICE = 7;
    PASS_WOMAN = 8;
    PASS_MAN = 9;
    CHIPSFLAY = 10;
    SHAKETIME = 11;
    SHOW_HAND_CARD = 12;
    BOX_OPEN_NORMAL = 13;
    call = 14;
    RAISE = 15;
    DEAL_CARD = 16;
    FLIP_CARD = 17;
    MOVE_CHIP_NEW_LONG = 18;

    --互动道具
    HDDJ_1 = 19;
    HDDJ_2 = 20;
    HDDJ_3 = 21;
    HDDJ_4 = 22;
    HDDJ_5 = 23;
    HDDJ_6 = 24;
    HDDJ_7 = 25;
    HDDJ_8 = 26;
    HDDJ_9 = 27;
    HDDJ_10 = 28;
    HDDJ_11 = 29;
    HDDJ_12 = 30;
    HDDJ_13 = 31;
    HDDJ_14 = 32;   
    HDDJ_15 = 33;   
 	HDDJ_16 = 34; 	
    HDDJ_17 = 35;   
    HDDJ_18 = 36;  
    HDDJ_19 = 37;   
    GAPLE_GAME_OVER = 100;

    LOTTERY = 50;
    GET_LOTTERY = 51;
    
    GEAR_FULL = 150;
}

SoundManager.effectsFileMap = {
    -- 公共音效
    [SoundManager.effects.CLICK_BUTTON] = "clickButton";
    [SoundManager.effects.CLOSE_BUTTON] = "closeButton";
    [SoundManager.effects.REPLACE_SCENE] = "replaceScene";
    [SoundManager.effects.GEAR_TICK] = "gearTick";
    [SoundManager.effects.BOX_OPEN_REWARD] = "box_open_reward";
    [SoundManager.effects.CHIP_DROP] = "chipDropping";
    [SoundManager.effects.NOTICE] = "notice";
    [SoundManager.effects.PASS_WOMAN] = "pass_woman";
    [SoundManager.effects.PASS_MAN] = "pass_man";
    [SoundManager.effects.CHIPSFLAY] = "chipsFlay";
    [SoundManager.effects.SHAKETIME] = "effectCountDown";
    [SoundManager.effects.SHOW_HAND_CARD] = "ShowHandCard";
    [SoundManager.effects.BOX_OPEN_NORMAL] = "box_open_normal";
    [SoundManager.effects.call] = "call";
    [SoundManager.effects.RAISE] = "raise";
    [SoundManager.effects.DEAL_CARD] = "dealCard";
    [SoundManager.effects.FLIP_CARD] = "flipCard";
    [SoundManager.effects.MOVE_CHIP_NEW_LONG] = "moveChip_new_long";
    [SoundManager.effects.GEAR_FULL] = "gearFull";

    --互动道具
    [SoundManager.effects.HDDJ_1] = "Egg";
    [SoundManager.effects.HDDJ_2] = "PourWater";
    [SoundManager.effects.HDDJ_3] = "Flower";
    [SoundManager.effects.HDDJ_4] = "Kiss";
    [SoundManager.effects.HDDJ_5] = "Toast";
    [SoundManager.effects.HDDJ_6] = "Tomato";
    [SoundManager.effects.HDDJ_7] = "Dog";
    [SoundManager.effects.HDDJ_8] = "Hammer";
    [SoundManager.effects.HDDJ_9] = "Bomb";
    [SoundManager.effects.HDDJ_10] = "tissure";
    [SoundManager.effects.HDDJ_11] = "drink";
    [SoundManager.effects.HDDJ_12] = "brick";
    [SoundManager.effects.HDDJ_13] = "bone";
    [SoundManager.effects.HDDJ_14] = "love";
    [SoundManager.effects.HDDJ_15] = "fire";
	[SoundManager.effects.HDDJ_16] = "durian";
    [SoundManager.effects.HDDJ_17] = "cake";
    [SoundManager.effects.HDDJ_18] = "dragonfly"; 
    [SoundManager.effects.HDDJ_19] = "shield";
    [SoundManager.effects.GAPLE_GAME_OVER] = "gapleGameOver";
    [SoundManager.effects.LOTTERY] = "lottery";
	[SoundManager.effects.GET_LOTTERY] = "lottery1";
}

SoundManager.hddjSounds = {
    [1]     = SoundManager.effects.HDDJ_1,
    [2]     = SoundManager.effects.HDDJ_2,
    [3]     = SoundManager.effects.HDDJ_3,
    [4]     = SoundManager.effects.HDDJ_4,
    [5]     = SoundManager.effects.HDDJ_5,
    [6]     = SoundManager.effects.HDDJ_6,
    [7]     = SoundManager.effects.HDDJ_7,
    [8]     = SoundManager.effects.HDDJ_8,
    [9]     = SoundManager.effects.HDDJ_9,
    [10]     = SoundManager.effects.HDDJ_10,
    [11]     = SoundManager.effects.HDDJ_11,
    [12]     = SoundManager.effects.HDDJ_12,
    [13]     = SoundManager.effects.HDDJ_13,
    [14]     = SoundManager.effects.HDDJ_14,
    [15]     = SoundManager.effects.HDDJ_15,
    [16]     = SoundManager.effects.HDDJ_16,
    [17]     = SoundManager.effects.HDDJ_17,
    [18]     = SoundManager.effects.HDDJ_18,
    [19]     = SoundManager.effects.HDDJ_19,
}

function SoundManager:ctor()
    for k, v in pairs(SoundManager.musics) do
        self[k] = v
    end

    for k, v in pairs(SoundManager.effects) do
        self[k] = v
    end

    self.m_musicPlayer  = GameMusic.getInstance();
    self.m_effectPlayer = GameEffect.getInstance();

    local prefix, extName
    -- if System.getPlatform() == kPlatformAndroid then
        prefix = "";
    --     extName = ".ogg";
    -- else
        -- prefix = "mp3/";
        extName = ".mp3";
    -- end
    self.m_musicPlayer:setPathPrefixAndExtName(prefix,extName)
    self.m_musicPlayer:setSoundFileMap(SoundManager.musicFileMap)
    self.m_effectPlayer:setPathPrefixAndExtName(prefix,extName)
    self.m_effectPlayer:setSoundFileMap(SoundManager.effectsFileMap)

    EventDispatcher.getInstance():register(Event.Resume, self, self.resumeMusic)
    EventDispatcher.getInstance():register(Event.Pause, self, self.pauseMusic)
end

function SoundManager:dtor()
    EventDispatcher.getInstance():unregister(Event.Resume, self, self.resumeMusic)
    EventDispatcher.getInstance():unregister(Event.Pause, self, self.pauseMusic)
end

-- 音效
function SoundManager:playSound(soundName, loop)
    if nk.DictModule:getBoolean("gameData", nk.cookieKeys.VOLUME, true) then
        return self.m_effectPlayer:play(soundName, loop or false)
    end
end


function SoundManager:playHddjSound(id)
    if nk.DictModule:getBoolean("gameData", nk.cookieKeys.VOLUME, true) then
        return self.m_effectPlayer:play(SoundManager.hddjSounds[id], false)
    end
end

function SoundManager:stopSound(id)
    if nk.DictModule:getBoolean("gameData", nk.cookieKeys.VOLUME, true) then
        self.m_effectPlayer:stop(id)
    end
end

-- 音乐
function SoundManager:playMusic(soundName, loop)
    if nk.DictModule:getBoolean("gameData", nk.cookieKeys.MUSIC, true) then
        return self.m_musicPlayer:play(soundName, loop or false)
    end
end

function SoundManager:stopMusic()
    return self.m_musicPlayer:stop()
end

function SoundManager:pauseMusic()
    return self.m_musicPlayer:pause()
end

function SoundManager:resumeMusic()
    if nk.DictModule:getBoolean("gameData", nk.cookieKeys.MUSIC, true) then
        return self.m_musicPlayer:resume()
    end    
end

return SoundManager