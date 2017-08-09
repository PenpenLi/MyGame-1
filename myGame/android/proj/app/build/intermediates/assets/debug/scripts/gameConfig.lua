-- gameConfig.lua
-- Last modification : 2016-05-30
-- Description: a config of this game
-- 配置游戏中的各种关键KEY

GameConfig = {}

GameConfig.CUR_VERSION = "1.5.5.1"

-- 邀请好友每个多少钱
GameConfig.INVITE_FRIEND_MONEY 	= 500

-- SID (gaple:1; 99:2)
GameConfig.ROOT_CGI_SID          = "2"

-- 反馈相关配置
GameConfig.FEEDBACK_GID = 3
GameConfig.FEEDBACK_GAEM_TYPE = 0

-- 粉丝页配置 
if GameConfig.ROOT_CGI_SID == "2" then
	GameConfig.FANS_URL = "https://www.facebook.com/Domino-QiuQiu-OnlineKiuKiu-99-Community-1912685698958123/"
else
	GameConfig.FANS_URL = "https://www.facebook.com/BoyaaDominoGaple/"
end

-- 活动中心相关配置
GameConfig.ACTIVITY_URL = "http://mvlpiddn01.boyaagame.com"
GameConfig.ACTIVITY_APPID = "9007"
GameConfig.ACTIVITY_SECRETKEY = "boyaa&&@9007"