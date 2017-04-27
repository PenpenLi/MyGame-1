require("game.uiex.uiexInit")

local gameModelPopup = require("demo.gameModelPopup")
local victoryPopup = require("demo.victoryPopup")
local gameTipPopup = require("demo.gameTipPopup") 
local coinTipPopup = require("demo.coinTipPopup") 
local setHeadPopup = require("demo.setHeadPopup")
local onRankPopup = require("demo.onRankPopup")
local exitPopup = require("demo.exitPopup")
local failPopup = require("demo.failPopup")
local gameSound = require("demo.gameSound")

local DemoScene = class(GameBaseSceneAsync)

function DemoScene:ctor(viewConfig, controller)
	EventDispatcher.getInstance():register(Event.KeyDown, self, self.onKeyDown)
	EventDispatcher.getInstance():register(Event.Back, self, self.onExitPopup)
	EventDispatcher.getInstance():register(EventConstants.restartDomoScene, self, self.reStart)
	EventDispatcher.getInstance():register(EventConstants.continueDomoScene, self, self.continue)
	EventDispatcher.getInstance():register(EventConstants.reviveDomoScene, self, self.revive)
	EventDispatcher.getInstance():register(EventConstants.cancelDomoScene, self, self.cancel)
	EventDispatcher.getInstance():register(EventConstants.tipDemoScene, self, self.gameTip)
	EventDispatcher.getInstance():register(EventConstants.setHeadDemoScene, self, self.setHeadAndName)
	EventDispatcher.getInstance():register(EventConstants.failDemoScene, self, self.gameOver)
	EventDispatcher.getInstance():register(EventConstants.btn_event_upload, self, self.btn_event_upload)
	EventDispatcher.getInstance():register(EventConstants.backHomeDomoScene, self, self.backHome)
end

function DemoScene:dtor(viewConfig, controller)
	EventDispatcher.getInstance():unregister(Event.KeyDown, self, self.onKeyDown)
	EventDispatcher.getInstance():unregister(Event.Back, self, self.onExitPopup)
	EventDispatcher.getInstance():unregister(EventConstants.restartDomoScene, self, self.reStart)
	EventDispatcher.getInstance():urregister(EventConstants.continueDomoScene, self, self.continue)
	EventDispatcher.getInstance():urregister(EventConstants.reviveDomoScene, self, self.revive)
	EventDispatcher.getInstance():urregister(EventConstants.cancelDomoScene, self, self.cancel)
	EventDispatcher.getInstance():urregister(EventConstants.tipDemoScene, self, self.gameTip)
	EventDispatcher.getInstance():urregister(EventConstants.setHeadDemoScene, self, self.setHeadAndName)
	EventDispatcher.getInstance():urregister(EventConstants.failDemoScene, self, self.gameOver)
	EventDispatcher.getInstance():urregister(EventConstants.btn_event_upload, self, self.btn_event_upload)
	EventDispatcher.getInstance():urregister(EventConstants.backHomeDomoScene, self, self.backHome)
end

BUTTON_CLICK_EVENT = {
	
	BtnOpenAlbumNum = 0,
	BtnHeadOpenAlbumNum = 0,
	BtnTakePictureNum = 0,
	BtnConfigCancelNum = 0,
	BtnConfigSubmitNum = 0,
	
	BtnCrazyNum = 0,
	BtnGentleNum = 0,
	BtnExitCancelNum = 0,
	BtnMusicNum = 0,

	EditNameNum = 0,

	crazy = {
		modeId = 2,
		breakRecord = 0,
		btnContinue = 0,
		btnRestart = 0,
		btnTips = 0,
	},
	gentle = {
		modeId = 1,
		breakRecord = 0,
		btnContinue = 0,
		btnRestart = 0,
		btnTips = 0,
	},

}

local GAME_INFO_LIST = {
	crazy = {
		modeId = 2,
		gameCoins = 80,
		maxScore = 0,
	},
	gentle = {
		modeId = 1,
		gameCoins = 40,
		maxScore = 0,
	},
}


function DemoScene:checkStation()
	if self.station == "Normal" then
		EventDispatcher.getInstance():register(Event.KeyDown, self, self.onKeyDown)
		self.personbutton:setEventTouch(self, self.hitMoster)
		self:EventTouch()
	elseif self.station == "Stop" or self.station == "Victory" then
		EventDispatcher.getInstance():unregister(Event.KeyDown, self, self.onKeyDown)
		if self.personbutton then
			self.personbutton:setEventTouch(self, function() end)
		end
		self.background:setEventTouch(self, function () end)
	end
end


function DemoScene:start()
    --	self.barimage_tsble = {}
    --  self.brickArr = {}
    self.station = "Init"
	self:initGame()


	local nextStep = function()
		self:setHeadPopup()
		self:getLastNameAndHeadFromHttp()
	end

	self:userLogin(nextStep)

	-- self:setHeadPopup()
	self.first = true
end

function DemoScene:userLogin(nextCallback)

	nk.HttpController:execute("Login.userLogin", {param = {loginType = 1}}, nil, function(errCode, data)

		Log.dump(data, "data")
		if data and data.flag == 10000 then
			local ret = data.data

			-- 接取btnInfoList中的对应数据到BUTTON_CLICK_EVENT
			local btnInfo = ret.btnInfoList
			for k, v in pairs(btnInfo) do
				if BUTTON_CLICK_EVENT[k] then
					if type(v) == "number" then
						BUTTON_CLICK_EVENT[k] = checkint(v)
					else
						for m, n in pairs(v) do
							BUTTON_CLICK_EVENT[k][m] = checkint(n)
						end
					end
				end
			end
			--Log.dump(BUTTON_CLICK_EVENT, "<<<<<<<<<BUTTON_CLICK_EVENT")
		
			-- 接取gameInfolist中的数据到GAME_INFO_LIST
			local gameInfo = ret.gameInfolist
			for k, v in pairs(gameInfo) do
				if GAME_INFO_LIST[k] then
					for m, n in pairs(v) do
						GAME_INFO_LIST[k][m] = checkint(n)
					end
				end
			end
			--GAME_INFO_LIST.gentle.gameCoins = 9999999

			-- Log.dump(GAME_INFO_LIST, "<<<<<<<<<<< GAME_INFO_LIST")

			MID = ret.mid
			LASTNAME = ret.nick
			ICON_URL = ret.iconUrl

			if ret.loginType == 1 then
				Log.dump("-----Visitor login", ret.loginType)
			elseif ret.loginType == 2 then
				Log.dump("-----Platform account login", ret.loginType)
			elseif ret.loginType == 3 then
				Log.dump("-----The third-party payment platform", ret.loginType)
			end
			if nextCallback and type(nextCallback) == "function" then
				nextCallback()
			end
		end 
	end)

end


function DemoScene:initGame()

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
	ScreenWidth  = System.getScreenScaleWidth()
	Screenheight = System.getScreenScaleHeight()

	self.bar = self:getUI("bar")
	self.titleImage = self:getUI("btntitle")
	self.background = self:getUI("bg")
	self.btnMusic = self:getUI("btnmusic")
	self.btnMusic:addToRoot()
    self.btnMusic:setLevel(1001)

	self.bg_bar = self:getUI("bg_bar") 
	self.coinImage = self:getUI("coin")
	self.imageScore = self:getUI("imageScore")
	self.imageMaxScore = self:getUI("imageMaxScore")
    self.personbutton = self:getUI("btnperson")
    self.textviewcoin = self:getUI("tvcoin")
    self.textviewscore = self:getUI("tvscore")
    self.textviewmaxscore = self:getUI("tvmaxscore")
    self.textName = self:getUI("textName")
    self.imagehead = self:getUI("headframe")
 
    self.btnRank = self:getUI("btnRankList")
    self.btnSetConfig = self:getUI("btnSetConfig")

    self.btnHome = self:getUI("btnHome")
    self.btnHome:addToRoot()
    self.btnHome:setLevel(1001)

    self.bgModel = self:getUI("bgModel")

    self.btnGentleModel = self:getUI("gentleModel")
    self.btnCrazyModel = self:getUI("carzyModel")

    -----------------------------------------
    self.btnCrazyModel.name = "BtnCrazyNum"
    self.btnGentleModel.name = "BtnGentleNum"
    self.btnMusic.name = "BtnMusicNum"
    ------------------------------------------

 	self.bgModel:setPickable(false)
 	self.coinImage:setPickable(false)
 	self.imageScore:setPickable(false)
 	self.imageMaxScore:setPickable(false)
 	self.textviewcoin:setPickable(false)
    self.textviewscore:setPickable(false)
    self.textviewmaxscore:setPickable(false)
    self.titleImage:setPickable(false)
    self.bar:setPickable(false) 
    self.bg_bar:setPickable(false)

	self.inPopup = false


	self.btnSetConfig:setOnClick(self, self.setConfigHeadAndName)
	self.btnHome:setOnClick(self, self.backHome)
	self.btnMusic:setOnClick(self, self.setMusic)
	self.btnRank:setOnClick(self, self.showRank)

   	self.btnGentleModel:setOnClick(self, function()
   		self:onButtonClick("gentle")
   	end) 
    self.btnCrazyModel:setOnClick(self, function()
    	self:onButtonClick("crazy")
    end)



    self.bg_bar:setSize(ScreenWidth + 960)

    self.m_gameSound = new(gameSound)

    

 
    Log.printInfo("The first initialization is complete.")
end

function DemoScene:setConfigHeadAndName()
	local nextStep = function()
		self:setHeadPopup()
		self:getLastNameAndHeadFromHttp()
	end

	self:userLogin(nextStep)
end
function DemoScene:initScene()
	self.bar:setVisible(false)
	self.titleImage:setVisible(false)
	self.btnCrazyModel:setVisible(false)
	self.btnGentleModel:setVisible(false)
	self.bgModel:setVisible(false)

	self.imageScore:setVisible(true)
	self.imageMaxScore:setVisible(true)
	self.coinImage:setVisible(true)
	self.textviewcoin:setVisible(true)
	self.textviewscore:setVisible(true)
	self.textviewmaxscore:setVisible(true)
	self.btnHome:setVisible(true)
	self.btnMusic:setVisible(true)
	self:setConfig()
end


function DemoScene:cleanScene()
	
	if self.barimage then
		delete(self.barimage)
	end

	if self.boom then
		delete(self.boom)
	end

	self.btnMusic:setVisible(false)
	self.imageScore:setVisible(false)
	self.imageMaxScore:setVisible(false)
	self.coinImage:setVisible(false)
	self.textviewcoin:setVisible(false)
	self.textviewscore:setVisible(false)
	self.textviewmaxscore:setVisible(false)
	self.btnHome:setVisible(false)
	self.bar:setVisible(true)

	self.btnRank:setVisible(true)
	self.titleImage:setVisible(true)
	self.btnCrazyModel:setVisible(true)
	self.btnGentleModel:setVisible(true)
	self.bgModel:setVisible(true)
	self.btnSetConfig:setVisible(true)

	
	nk.PopupManager:removeAllPopup() 
end

function DemoScene:backHome()

	self.station = "Stop"
	
	self:checkStation()
	self:removeAllMyProp()   --停止????????????
	self:removeAllHandle()   --停止??????
	self:cleanScene()

	Log.printInfo("Back Home")
end

function DemoScene:stationInit()

	self.barimage_number = 0
	self.barimage_state = "alive"
	self.person_state = "running"
	self.station = "Normal"
  	

   
	self.onkeyDown_E = false
	self.onkeyDown_R = false
	self.E = true
	self.R = true
	self.inPopup = false

	--self.maxscore = self:getMaxData()
	-- self.maxscore = 0
	-- self.coin = 0
	if self.name == "" or self.name == nil then
	 	self.name = "WindCao"
	end
	if self.personbutton then
		self.personbutton:setPos(100, 110)
		self.personbutton:setSize(200, 200)
		if self.flag == true then
			self.imagehead:addPropRotateSolid(1, 0, kCenterDrawing)
		end
	end
	if self.boom then 
		delete(self.boom)
	end
	if self.barimage then
		self.barimage:setPos(-20, 100)
	end
	
	self.bg_bar:addPropTranslate(1, kAnimRepeat, 3000, 0, 0, -960, 0, 0)
	self.textviewscore:setText("" .. self.score, 90, 50, 0, 0, 0)

	self.textviewmaxscore:setText("" .. self.maxscore, 90, 50, 0, 0, 0)
	
	self:checkStation()

end


function DemoScene:onButtonClick(mode)

	self.station = "Normal"


	self.btnRank:setVisible(false)
	self.btnSetConfig:setVisible(false)

	self.gameModel = mode
	self.score = 0

	local data = GAME_INFO_LIST[mode]
	Log.dump(data,">>>>>>>>>>>>>>>>>>>>>>>>>>>>> onButtonClick " .. mode)

	self.maxscore = data.maxScore
	self.coin = data.gameCoins

	self.textviewcoin:setText("" .. self.coin, 150, 50, 0, 0, 0)
	self.textviewmaxscore:setText("" .. self.maxscore, 90, 50, 0, 0, 0)

	-------------------------------------------
	if self.first == true then
		self:playMusic()
		self.first = false
	end
	self:initScene()
	self:stationInit()

	self:EventTouch()
	self:createPerson()


	self:createMonster()
	self:cartonMonster()

	Log.printInfo("Press the start key.")

	-- self:createBrick()
	-- self.runHandler = Clock.instance():schedule(function(dt)
	-- 	if #self.brickArr > 0 then
	-- 		local temp = self.brickArr[#self.brickArr][1]
	-- 		if temp:getPos() < 960 * 2 then
	-- 			self:createBrick()
	-- 		end
	-- 	end
	-- end)
	-- Log.printInfo("---?????莸?)

	-- end
end

function DemoScene:playMusic()


	self.m_gameSound:stopMusic()
	self.m_gameSound:playMusic(math.random(1, 3), true)

--  Sound.preloadMusic("bgMusic.mp3")
--  Sound.playMusic("bgMusic.mp3")
end

function DemoScene:reStart()
	Log.printInfo("restart-----------------------------")
	self.station = "Normal"
	
	self.score = 0
	self:stationInit()
	
	self:createMonster()
	self:cartonMonster()
	Log.printInfo("Start my game again")

end

function DemoScene:cancel()

	if self.inPopup == true then
		nk.PopupManager:removePopupByName("exitPopup")
	else

		self:stationInit()
		self:createMonster()
		self:cartonMonster()
		nk.PopupManager:removeAllPopup()

		Log.printInfo("Continue my game again!!!!!!!!!!!!!!!!!!!!!")
	end
end


-- 复活
function DemoScene:revive()

	if self.coin >= 20 then
	
		-- self.Curstr = "亲，复活需要20金币\n\n需要复活吗？"
		self.Curstr = "You need 20 coins to continue the game , \n\ndo you need to continue?"
		self:coinTipPopup()
	
	else
		
		-- self.Curstr = "亲，你的金币不足20\n\n不能 复活 哦\n\n慢慢攒着吧！"
		self.Curstr = "Dear, your coin less than 20, \n\ncan't continue??"
		self:onFailPopup()
  	end
	
end

function DemoScene:continue()

	self.station = "Normal"
	self:consumeCoin()	
	self:stationInit()

	self:setConfig()
 --	self:createMonster()
 	self:cartonMonster()
 	Log.printInfo("Continue my game again")
end


function DemoScene:setMusic() 
	local musicStation = nk.DictModule:getBoolean("gameSound", "playMusic")

	Log.printInfo("<<<<<<<<<<<<<<<<<<<<<<   musicStation", musicStation)
		--关闭音乐和音效
	if musicStation then   
		self.m_gameSound:stopMusic()
		nk.DictModule:setBoolean("gameSound", "playMusic", false)
		nk.DictModule:setBoolean("gameSound", "playEffect", false)
		self.btnMusic:setFile("game/button/btnmusic2.png")
 		
 		nk.DictModule:setBoolean("gameSound", "lastSound", false)
	else
		self.m_gameSound:playMusic(1, true)
		nk.DictModule:setBoolean("gameSound", "playMusic", true)
		nk.DictModule:setBoolean("gameSound", "playEffect", true)
		self.btnMusic:setFile("game/button/btnmusic.png")

 		nk.DictModule:setBoolean("gameSound", "lastSound", true)
	end

end


-- function DemoScene:createBrick()
	
-- 	local im = new(Image,"game/bg_bar0_960_110.png")
-- 	im:setAlign(kAlignTopLeft)
-- 	im:addTo(self)
-- 	local rw = math.random(200,700)
-- 	im:setSize(rw)

-- 	local lastX , lastW = 0,rw
-- 	if #self.brickArr ~= 0 then
-- 		local temp = self.brickArr[#self.brickArr][1]
-- 		local x,y = temp:getPos()
-- 		local w,h = temp:getSize()

-- 		lastX = x
-- 		lastW = w
-- 	end
-- 	if lastX ~= 0 then
-- 		im:setPos( lastX + lastW + math.random(50,150),530)
-- 	else
-- 		im:setPos(0,530)
-- 	end

-- 	local p = {}
-- 	table.insert(self.brickArr,p)

-- 	table.insert(p,im)

-- 	local handler = Clock.instance():schedule(function(dt)
-- 		local x,y = im:getPos()
-- 	   	im:setPos(x - 6, y)

-- 	   	if x < -rw then
-- 	   		self:cleanBrick(p)
-- 	   	end
-- 	end)
-- 	table.insert(p,handler)
-- 	return rw
-- end

-- function DemoScene:cleanBrick(data)
-- 	data[1]:removeAllProp()
-- 	data[1]:removeFromParent(true)

-- 	data[2]:cancel()
-- 	table.removebyvalue(self.brickArr,data)
-- end


function DemoScene:createPerson()
	-- 小人初始化
	if not self.anim_frame then
		self.anim_frame = new(AnimInt, kAnimRepeat, 0, 1, 100)
	end
	self.anim_frame:setEvent(self, self.cartonPerson)
	self.index = 0
	self.personbutton:setEventTouch(self, self.hitMoster)
end

function DemoScene:cartonPerson()

	local files = {"game/person/run1.png", "game/person/run2.png", "game/person/run3.png", "game/person/kicking.png", "game/person/kneeling.png", "game/person/sliping.png", "game/person/death.png"}
	self.index = self.index + 1
	self.flag = false
	if self.person_state == "running"  and self.index > 3 then
		self.index = 1
		self.imagehead:setPos(55, 120)
	elseif self.person_state == "kneel" then
		self.index = 5
		self.imagehead:setPos(60, 108)
	elseif self.person_state == "sliping" then
		self.index = 6
		self.imagehead:setPos(20, 100)
	elseif self.person_state == "death" then
		self.index = 7
		self.imagehead:setPos(-18, 20)
		self.imagehead:addPropRotateSolid(1, -100, kCenterDrawing)
		self.flag = true
	elseif self.person_state == "kicking" and self.index > 4 then
		self.index = 4
		self.imagehead:setPos(45, 120)
		self.imagehead:setSize(110, 90)
	end

   -- Log.printInfo("self.index = " .. self.index)

	self.personbutton:setFile(files[self.index])

end


function DemoScene:createMonster()
	    
	    local barimages = {
	    				   "game/bar/low1_80_100.png", "game/bar/low2_80_100.png",    --直接跳


	    				   "game/bar/low3_150_100.png", "game/bar/low4_250_100.png",   --跳起右滑
	    				  
	    				   "game/bar/low5_161_150.png", "game/bar/low6_206_150.png",    --较高难跳

	    				   "game/bar/zombie.png",                                  --下蹲击飞

						   "game/bar/mid1_300_250.png", "game/bar/mid2_180_250.png",     --跳不过只能踢
						   "game/bar/mid3_251_250.png", "game/bar/mid4_245_250.png",


						   "game/bar/tall1_320_530.png", "game/bar/tall2_320_530.png"     --跳不过抬起来


						  
						  }
		local index = 1

		if self.gameModel == "crazy" then
			if self.score < 100 then
			 	index = math.random(7, 11)
			end

			Log.dump("<<<<<<<<<<<<<<<<<<<    index",index)
		elseif self.gameModel == "gentle" then
			if self.score <= 2 then
				index = math.random(1, 4)

			elseif self.score <= 7 then
				index = math.random(1, 8)

			elseif self.score <= 15 then
				index = math.random(1, 10)

			elseif self.score <= 20 then
				index = math.random(1, 10)

			elseif self.score <= 25 then
				index = math.random(4, 12)

			elseif self.score <= 100 then
				index = math.random(1, #barimages)
			end
		end


		if self.barimage then
			delete(self.barimage)
	    end

		self.barimage = new(Image, barimages[index])	
		self.barimage:setAlign(kAlignBottomRight)
		self.barimage:addTo(self.personbutton:getParent())

		Log.printInfo("I am monster No." .. index)

		self.barimage:setPos(-20, 100)
		self.barimage:setEventTouch(self, self.upBar)
		
		self.person_state = "running"
		self.barimage_state  = "alive"
		self.barimage_number = self.barimage_number + 1
		
		self.bar_index = index
		self.onkeyDown_E = false    --人和怪距离较近时才可以踢怪(E)，默认为不可踢(false)
		self.onkeyDown_R = false    --人和怪距离较近时才可以铲怪(R)，默认为不可铲(false)
		self.check = false          --人和怪距离较近时碰撞检测，默认为不检测(false)
		self.E = true               --标记唯一一次按下踢怪(E)，默认为可按下(true)
		self.R = true               --标记唯一一次按下铲怪(R)，默认为可按下(true)


		-- local teble = {}
		-- teble.bar_index = self.bar_index
		-- teble.image = self.barimage
		-- teble.x = 50
		-- table.insert(self.barimage_table,teble)
		
end

function DemoScene:upBar(finger_action, ...)
	if finger_action == kFingerDown then
		self:onKeyDown(87)
	end
	Log.printInfo("Uping the monster")
 end

function DemoScene:hitMoster( ... )
	self:onKeyDown(69)	
	self.person_state = "kicking"

	-- self.kickHandle = Clock.instance():schedule_once(function()

	-- 	self.person_state = "running"
	-- 	-- if self.flag == true then
	-- 	-- 	self.imagehead:addPropRotateSolid(1, 0, kCenterDrawing)
	-- 	-- end
	       		
	-- end, 0.3)    
	Log.printInfo("Hitting the monster")
 end

function DemoScene:adjustBarSpeed( ... )
	local v_bar_a = 5
	self.v_bar = self.v_bar + v_bar_a
	Log.printInfo("The monster has been accelerated")
end

function DemoScene:setTextColor( ... )

	self.textviewscore:setText("" .. self.score, 90, 50, 248, 248, 255)
	self.textviewmaxscore:setText("" .. self.maxscore, 90, 50, 248, 248, 255)
	self.textviewcoin:setText("" .. self.coin, 150, 50, 248, 248, 255)
end

function DemoScene:getScore( ... )
	-- ?????	

	if self.barimage_state == "alive" or self.barimage_state == "flying" or self.barimage_state == "shoveling" then
		self.score = self.score + 1
		self.textviewscore:setText("" .. self.score)
	end 

	self:setConfig()

end

function DemoScene:getCoin( ... )

	local monsterStyle = self:classifyMonster()

	if monsterStyle == "Little" then
		self.coin = self.coin + 1
	elseif monsterStyle == "Long" then
		self.coin = self.coin + 2
	elseif monsterStyle == "Mid" then
		self.coin = self.coin + 3
	elseif monsterStyle == "Tall" then
		self.coin = self.coin + 3
	elseif monsterStyle == "ZOMBIE" then
		self.coin = self.coin + 3
	end

	Log.dump("self.gameModel<<<<<<<<<<<<<<<<<<<<<<", self.gameModel)
	Log.dump("self.gameModel<<<<<<<<<<<<<<<<<<<<<<", GAME_INFO_LIST[self.gameModel][gameCoins])

	GAME_INFO_LIST[self.gameModel].gameCoins = self.coin
	
	self.textviewcoin:setText("" .. self.coin)

end

function DemoScene:consumeCoin( ... )
	self.coin = self.coin - 20
	self.textviewcoin:setText("" .. self.coin, 150, 50, 0, 0, 0)
	GAME_INFO_LIST[self.gameModel].gameCoins = self.coin
end


function DemoScene:setConfig()
	--local config = require("config")
	local config

	if self.gameModel == "gentle" then
		config =	{
			{score = 1,  v_bar = 10, v0_person = 25, background = "game/backgroud/bg.png"},
			{score = 2,  v_bar = 10, v0_person = 25, background = "game/backgroud/bg.png"},
			{score = 4,  v_bar = 10, v0_person = 25, background = "game/backgroud/bg.png"},
			{score = 7,  v_bar = 10, v0_person = 25, background = "game/backgroud/bg1.png"},
			{score = 11, v_bar = {10, 12}, v0_person = 25, background = "game/backgroud/bg1.png"},
			{score = 16, v_bar = {10, 12}, v0_person = 25, background = "game/backgroud/bg1.png"},
			{score = 22, v_bar = {10, 12}, v0_person = 25, background = "game/backgroud/bg1.png"},
			{score = 29, v_bar = {10, 12}, v0_person = 25, background = "game/backgroud/bg2.png"},
			{score = 37, v_bar = {12, 15}, v0_person = 25, background = "game/backgroud/bg2.png"},
			{score = 48, v_bar = {12, 15}, v0_person = 24, background = "game/backgroud/bg2.png"},
			{score = 58, v_bar = {15, 20}, v0_person = 24, background = "game/backgroud/bg3.png"},
			{score = 69, v_bar = {15, 20}, v0_person = 24, background = "game/backgroud/bg3.png"},
			{score = 81, v_bar = {17, 25}, v0_person = 24, background = "game/backgroud/bg4.png"},
			{score = 99, v_bar = {17, 25}, v0_person = 24, background = "game/backgroud/bg4.png"},
		}
	elseif self.gameModel == "crazy" then
		config =	{
			{score = 5,  v_bar = 15, v0_person = 25, background = "game/backgroud/bg.png"},
			{score = 10, v_bar = 16, v0_person = 20, background = "game/backgroud/bg1.png"},
			{score = 15, v_bar = 18, v0_person = 25, background = "game/backgroud/bg2.png"},
			{score = 40, v_bar = 20, v0_person = 24, background = "game/backgroud/bg3.png"},
			{score = 999999, v_bar = 25 , v0_person = 24, background = "game/backgroud/bg4.png"},
		}
	end




	local curConfigUnit = nil

	for k, v in pairs(config) do
		if self.score <= v.score then
			curConfigUnit = v
			break
		end
	end


	if not curConfigUnit then
		self:victory()
		self:checkStation()
	else
		if type(curConfigUnit.v_bar) == "number" then
			self.v_bar = curConfigUnit.v_bar
		else
			self.v_bar = math.random(unpack(curConfigUnit.v_bar))
		end
		self.v0_person = curConfigUnit.v0_person
		self.background:setFile(curConfigUnit.background)
		if curConfigUnit.background == "game/backgroud/bg4.png" then
			self:setTextColor()
		end
	end


end


function DemoScene:cartonMonster( ... )

	-- local xramd = {50,50,50}
	-- local xSpeed = {1,2,3,4,5}
	-- self.barimage = {}
	
	local x = -20
	self.handle = nil

	self:setConfig()

	self.handle = Clock.instance():schedule(function( ... )	

	-- local num = 3
	-- for i=1,#self.barimage_tsble  do
    -- if self.barimage_tsble[i].x > ScreenWidth + 20 then
			
	-- 	    self.barimage_tsble[i].x = 50
	-- 		delete(self.barimage_tsble[i])
	-- 			self:createMonster()
	-- 		    self:getScore()
	--  	end	 
	-- end

	-- self.bar_index = 1
		

		if x > ScreenWidth + 20 then
			
		    x = -20
			self:getScore()
			self:getCoin()
			self:createMonster()	
	
		end	

		local x1, y1 = self.barimage:getPos()
		x = x + self.v_bar * 1	

		
		self.barimage:setPos(x, y1)

		local bx = ScreenWidth - x
		local by = y1
		local bw, bh = self.barimage:getSize()
		local pw, ph = self.personbutton:getSize()
		local px, py = self.personbutton:getPos()
	
		local rb_w =  bw/2
		local rb_h =  bh/2
		local rp_w =  pw/2
		local rp_h =  ph/2

		local rb = math.sqrt((rb_w)*(rb_w) + (rb_h)*(rb_h))
		local rp = math.sqrt((rp_w)*(rp_w) + (rp_h)*(rp_h)) - 80

		local rb_x = bx - bw/2
		local rb_y = by + bh/2
		local rp_x = px + pw/2
		local rp_y = py + ph/2

		local rx = rp_x - rb_x
		local ry = rp_y - rb_y

		local distance = math.sqrt((rb_x-rp_x)*(rb_x-rp_x)+(rb_y-rp_y)*(rb_y-rp_y))
		local apple = distance - (rp + rb_w) 
		
		
		if apple < 100 then
			self.onkeyDown_E = true
			
		end

		if apple < 300 then
			self.onkeyDown_R = true
		end

		if distance < 400 then
			self.check = true
		end
		

		if self:ComputeCollision(bw, bh, rp, rx, ry) and self.barimage_state == "alive" and self.check then	
			Log.printInfo("<<<<<<<<<<<<<<<<<<   distance", distance)
			Log.printInfo("<<<<<<<<<<<<<<<<<<   apple", apple)
			Log.printInfo("I hit it")
			
			self.person_state = "death"
		
			self:removeAllHandle()
			self:gameOver()


		end
				
	end)

end

function DemoScene:EventTouch()

	self.background:setEventTouch(self,function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)

		local px, py = self.personbutton:getPos()

		Log.dump(ScreenWidth, "ScreenWidth>>>")

        if finger_action == kFingerDown then   
            clickPos = {x = x, y = y}
            isAction = 0
        elseif finger_action == kFingerMove then

            if clickPos.y - y > 40 then                           --上滑
                isAction = 1
                self:onKeyDown(32) 
            elseif clickPos.x - x > 40 then                       --左滑
            	isAction = 2
            	
            elseif x - clickPos.x > 40 then                       --左滑
            	isAction = 3
 
            elseif y - clickPos.y > 30 then                       --下滑
           		isAction = 4
           		self:onKeyDown(82)	

            end
        elseif finger_action == kFingerUp then

            if isAction == 0 then 
				self:onKeyDown(83)                
            elseif isAction == 1 then 
			--	self:onKeyDown(32) 
			elseif isAction == 2 then 
				if px >= 0 then
					self:onKeyDown(37)
				end
			elseif isAction == 3 then 
				if px <= ScreenWidth then
					self:onKeyDown(39)
				end
			elseif isAction == 4 then 
				-- self:onKeyDown(82)	
			end
		end
    end)
end

function DemoScene:onKeyDown(key)

	if self.personbutton then
 		local x, y = self.personbutton:getPos()  
 		Log.printInfo("DemoScene","key = " .. key)
 	end

 	-- 获取怪物种类

    local monsterStyle = self:classifyMonster()
 	
    --Log.printInfo("MonsterStyle = ", monsterStyle)

	if key == 32 and not self.handle2 then    

		
		--self.person_state = "running"

		local t = 1
		Log.dump(self.v0_person, "起跳初始速度 >>>>>>>>>>>>>>>>>")
		self.handle2 = Clock.instance():schedule(function( ... )
			local px, py = self.personbutton:getPos()

			self.v_person = self.v0_person - 1.3 * t
			
			py = py + self.v_person * 1
			self.personbutton:setPos(px, py)
			t = t + 1
		
			if py <= 110 then
				self.personbutton:setPos(px, 110)
				self.handle2:cancel()
				self.handle2 = nil
			end
			
			
		end)



		
    elseif key == 37 then         --按下左键

    	if self.handle3 then
 			self.handle3:cancel()
 			self.handle3 = nil
     	end

     	self.handle3 = Clock.instance():schedule(function( ... )
 
     		local px, py = self.personbutton:getPos()

     		self.personbutton:setPos(px - 150, py)    	
     		if self.handle3 then
     			self.handle3:cancel()
     			self.handle3 = nil
     		end
     	end)
	    
     	
    elseif key == 39 then         --按下右键
    	if self.handle5 then
     		self.handle5:cancel()
     		self.handle5 = nil
     	end

        self.handle5 = Clock.instance():schedule(function( ... )
 
     		local px, py = self.personbutton:getPos()

     		self.personbutton:setPos(px + 200, py)
     		
     		if self.handle5 then
     			self.handle5:cancel()
     			self.handle5 = nil
     		end
     	end)


    elseif key == 87 and monsterStyle == "Tall" then         --按下W

    	if self.handle4 then
			self.handle4:cancel()
			self.handle4 = nil
		end

		self.handle4 = Clock.instance():schedule(function( ... )
			local bx, by = self.barimage:getPos()
			self.barimage:setPos(bx, by + 120)

			if self.handle4 then
				self.handle4:cancel()
				self.handle4 = nil
			end

		end)

	elseif key == 82 and monsterStyle == "ZOMBIE" and self.R and self.onkeyDown_R then       --按下R

		self.barimage_state = "shoveling"

		self.person_state = "sliping"

		local x, y = self.personbutton:getPos()
	
		self.personbutton:setPos(x, 85)
		

        self.barimage:addPropTranslate(1, kAnimNormal, 5000, 0, 0, 60, 0, -900)
        self.barimage:addPropRotate(2, kAnimRepeat, 2000, 0, 0, 1440, kCenterDrawing)
        self.barimage:addPropScale(3, kAnimNormal, 2000, 0, 1, 0, 1, 0, kCenterDrawing)

        self.R = false


	elseif key == 69 and self.onkeyDown_E and monsterStyle == "Mid" and self.E then           --按下E
		

		-- local w, h = self.barimage:getSize()
		-- local x = w/2
		-- local y = h/2

		self.barimage_state = "flying"


		--self.person_state = "kicking"

        self.barimage:addPropTranslate(1, kAnimNormal, 2000, 0, 0, 1960, 0, -600)
        self.barimage:addPropRotate(2, kAnimRepeat, 2000, 0, 0, 1440, kCenterDrawing)
        self.barimage:addPropScale(3, kAnimNormal, 2000, 0, 1, 0, 1, 0, kCenterDrawing)

        self.E = false


        -- handle6 = Clock.instance():schedule_once(function( ... )
        -- 	local bx, by = self.barimage:getPos()
        -- 	self.barimage:setPos(bx + 960, by - 500)
        -- 	-- local originSetPos = self.barimage.setPos
        -- 	-- self.barimage.setPos = function(self, ...)
        -- 	-- 	originSetPos(self, ...)
        -- 	-- 	FwLog(debug.traceback())
        -- 	-- end
        -- 	handle6:cancel()
        -- end, 2000)
        

	elseif key == 83 then         --按下S
			-- 跪下标志
		self.person_state = "kneel"
		local px, py = self.personbutton:getPos()
		self.personbutton:setPos(px, py - 10)
		
		self:adjustBarSpeed()
		if py <= 0 then
		 	self.person_state = "death"
		 	self:onFailPopup()
		end


	
	elseif key == 81 then

		self:onExitPopup()

	end
   
end

-- 圆和矩形
function DemoScene:ComputeCollision(w, h, r, rx, ry)
	local dx  = math.min(rx, w *0.5)
	local dx1 = math.max(dx, -w*0.5)
	local dy  = math.min(ry, h *0.5)
	local dy1 = math.max(dy, -h*0.5)

	if (dx1 - rx)*(dx1 - rx) + (dy1 - ry)*(dy1 - ry) <= r * r then
		return true
	else
		return false
	end
end

-- 点和矩形碰撞
function DemoScene:isCollsion1(x1, y1, x2, y2, w, h)
	if x1 > x2 and x1 <= x2 + w and y1 >= y2 and y1 <= y2 + h then
		return true
	end
	return false
end

-- 点和圆碰撞
function DemoScene:isCollsion2(x1, y1, x2, y2, r)
	if math.sqrt(math.pow((x1 - x2), 2) +  math.pow((y1 - y2), 2)) <= r then
		return true
	end
	return false
end

-- 矩形和矩形碰撞
function DemoScene:isCollsionWithRect(x1, y1, w1, h1, x2, y2, w2, h2)
	
	if  x1 >= x2 and x1 >= x2 + w2 then   
            return false
    elseif x1 <= x2 and x1 + w1 <= x2 then   	   
            return false
    elseif y1 >= y2 and y1 >= y2 + h2 then  
            return false
    elseif y1 <= y2 and y1 + h1 <= y2 then 
			return false
    end 
    return true
end

-- 圆和圆碰撞
function DemoScene:isCollisionWithCircle(x1, y1, x2, y2, r1, r2)
	if math.sqrt(math.pow((x1 - x2), 2) + math.pow((y1 - y2), 2)) <= r1 + r2 then
		return true
	end
	return false
end

function DemoScene:gameOver()

	Log.dump("<<<<<<<<<<<<<<     11self.person_state", self.person_state)
	self.station = "Stop"
	self:checkStation()
	-- 播放死亡音效
	local style1, style2 = self:classifyMonster()
	self:playEffect(style1, style2)
	
	local px, py = self.personbutton:getPos()
	local pw, ph = self.personbutton:getSize()
	Log.dump("<<<<<<<<<<    py", py)
	
	self.personbutton:setPos(px - 50, 60)
	self.personbutton:setSize(300, 150)
    

    -- 分类提醒
	self:classifyCue()
	self:removeAllMyProp()
	self:removeAllHandle() 


	-- 更新最高分
	if self.score > tonumber(self.maxscore) then
		self:updateMaxData(self.score)
		self:breakRecord()
	else
	self.failPopupHandle = Clock.instance():schedule_once(function()
			self:onFailPopup()
		end, 0.5)
	end


    ---------------------------------------------------------------------------------------------
	local table = {method = "User.updateGameInfo", mid = MID, gameInfolist = GAME_INFO_LIST, btnInfoList = BUTTON_CLICK_EVENT}
	Log.dump(table,">    PostData,gameOver")	
	self:httpUpdate("User.updateGameInfo", table)
	---------------------------------------------------------------------------------------------

    Log.printInfo("gameOver")
end

function DemoScene:removeAllHandle( ... )
	if self.handle then
		self.handle:cancel()      --停怪物移动
		self.handle = nil
	end
	if self.handle2 then
		self.handle2:cancel()     --停跳动操作
		self.handle2 = nil
	end
	if self.handle3 then
		self.handle3:cancel()     --停左键操作
		self.handle3 = nil
	end
	if self.handle4 then
		self.handle4:cancel()     --停抬起怪物
		self.handle4 = nil
	end
	if self.handle5 then
		self.handle5:cancel()     --停右键操作
		self.handle5 = nil
	end
	if self.failPopupHandle then       --停止失败弹窗
		self.failPopupHandle:cancel()
		self.failPopupHandle = nil
	end
	if self.kickHandle then
		self.kickHandle:cancel()
		self.kickHandle = nil
	end
end

function DemoScene:removeAllMyProp( ... )

	Log.printInfo("clean All prop.")
	if self.barimage then
		self.barimage:removeAllProp()
	end
	-- if self.personbutton then
	-- 	self.personbutton:removeAllProp()
	-- end
	if self.bg_bar then
		self.bg_bar:removeAllProp()
	end
end

function DemoScene:victory()

	self.station = "Victory"
	self.m_gameSound:playEffect("victory")		
	self:removeAllMyProp()
	self:removeAllHandle() 

	self:onVictoryPopup()
end

function DemoScene:onVictoryPopup()
	nk.PopupManager:addPopup(victoryPopup, "DemoScene", self.score, self.Curstr) 
end

function DemoScene:onFailPopup()

	
	self.inPopup = true

	self:removeAllMyProp()
	self:removeAllHandle() 
	nk.PopupManager:addPopup(failPopup, "DemoScene", self.score, self.Curstr, self.gameModel) 

end

function DemoScene:coinTipPopup()

	self.inPopup = true

	self:removeAllMyProp()
	self:removeAllHandle() 
 	
	nk.PopupManager:addPopup(coinTipPopup, "DemoScene", self.score, self.Curstr) 
end

function DemoScene:breakRecord()
	self.inPopup = true
	self:removeAllMyProp()
	self:removeAllHandle() 
	nk.PopupManager:addPopup(failPopup, "DemoScene", style, self.Curstr) 
end

function DemoScene:gameTipPopup()
	
	if self.coin < 20 then
		-- self.Curstr = "亲，你的金币不足20\n\n不能获得 提示 哦\n\n慢慢攒着吧！"
		self.Curstr = "Dear, your coin less than 20, \n\ncan't get the tips!"
		self:onFailPopup()
	else
		local style = self:classifyMonster()
		self:consumeCoin()

		self.inPopup = true

		self:removeAllMyProp()
		self:removeAllHandle() 

		nk.PopupManager:addPopup(gameTipPopup, "DemoScene", style, self.Curstr) 
	end
end

function DemoScene:onConfirmPopup( ... )
	
	self.station = "Stop"
	self.inPopup = true
	self:removeAllMyProp()
	self:removeAllHandle() 
	nk.PopupManager:addPopup(failPopup, "DemoScene", self.score, self.Curstr) 
end

function DemoScene:onExitPopup( ... )

	if self.station == "Init" or self.station == "Victory" then
		nk.PopupManager:addPopup(exitPopup, "DemoScene", self.station)
	else
		self.station = "Stop"
	    self:checkStation()
		self:removeAllMyProp()
		self:removeAllHandle() 
		nk.PopupManager:addPopup(exitPopup, "DemoScene", self.station)
	end
end

function DemoScene:onRankPopup( RANK )
	nk.PopupManager:addPopup(onRankPopup, "DemoScene", RANK)
end

function DemoScene:setHeadPopup( ... )
	nk.PopupManager:addPopup(setHeadPopup, "DemoScene")
end


function DemoScene:gameTip( ... )
	local monsterStyle = self:classifyMonster()
	Log.printInfo(">>>>>>>>>>>  monsterStyle", monsterStyle)
	Log.printInfo(">>>>>>>>>>>  self.bar_index", self.bar_index)

	local str = nil
	if monsterStyle == "Little" then
		-- str = "试试\n\n上滑就会跳起来"
		str = "Try to slide up \n\nUse your finger to slide up on the screen."
	elseif monsterStyle == "Long" then
		-- str = "试试\n\n上滑跳起来\n\n再右滑"
		str = "Jump up and \n\nthen slide right"
	elseif monsterStyle == "Mid" then
		-- str = "点击小人有惊喜哦\n\n悄悄告诉你，你会踢飞怪物哦！"
		str = "Click this person \n\nYou can kick!"
	elseif monsterStyle == "Tall" then
		-- str = "点击怪物\n\n它就会飞起来"
		str = "Click the monster \n\nThere is something unexpected!"
	elseif monsterStyle == "ZOMBIE" then
		-- str = "碰到这个运气不错，这个操作不告诉你\n\n自己慢慢试吧！"
		str = "Since I have given you so much tips, try to figure out this by yourself"
	end
	self.Curstr = str
	self:gameTipPopup()
end

--?????
function DemoScene:classifyCue( ... )

	local str = nil
	local score = self.score
	local result = tostring(score/13000000)
	local surplusScore = 100 - score

	Log.dump("<<<<<<<<<<<<  self.name", self.name)
	result = string.format("%.8f", result)

	str0 = {
		     [1 ] = "加油, " .. self.name .. "!\n\n这是一个考验想象力的游戏.\n\n不要轻易认输哦!",
		     [2 ] = self.name .. ",小朋友.\n\n不如先把牛奶喝完？", 
		     [3 ] = self.name .. ",小朋友.\n\n为什么不把作业写完？", 
		     [4 ] = "恭喜" .. self.name .. "打败了\n\n" .. result .. "% 的菜鸟，\n\n成为了闪闪发光的菜鸟！",
		     [5 ] = "恭喜" .. self.name .. "打败了\n\n" .. result .. "% 的菜鸟，\n\n堪称菜鸟中的战斗机!",
		     [6 ] = self.name .. "已经成为了菜鸟中的王者.",
		     [7 ] = self.name .. "的想象力已经突破天际了!",
		     [8 ] = "哎哟，有进步！\n\n" .. self.name .. ",真是上帝的宠儿！",
		     [9 ] = "Dear, " .. self.name .. ", \n\n天啊，真想不到你能玩到这里！\n\n堪称神话！",
		     [10] = "Dear, " .. self.name .. ", \n\n你的想象力已经图破地球的阻碍了！",
		     [11] = "天呐，为什么没有人提议研究\n\n" .. self.name .. "的大脑？",
		     [12] = "Dear, " .. self.name .. ",\n\n真让我感觉春心荡漾.",
		     [13] = "辣妹在等你哦！\n\n" .. self.name .. "再坚持一会会儿.",
		     [14] = self.name .. "还差一点点\n\n就能看到终点的辣妹了!",
			 [15] = self.name .. "剩下 " .. surplusScore .. " 米，\n\n辣妹就是你的了!",
		}


	str  = {
			 [1 ] = "Come on, " .. self.name .. "!\n\nThis is a game for imagination.\n\nDon't give up that easily! ",
		     [2 ] = "Kids.\n\nWhy not finish your milk first?",
		     [3 ] = "Kids.\n\nwhy not finish your homework first?",
		     [4 ] = "Congrats to " .. self.name .. " for beating\n\n" .. result .."% rubbish, \n\nand becoming the sparkling rubbish.",
		     [5 ] = "Congrats to " .. self.name .. " for beating\n\n" .. result .."% rubbish, \n\nand becoming the captain of rubbish.",
		     [6 ] = self.name .. " has become the king of rubbish!",
		     [7 ] = "Being here is almost to\n\n" .. self.name .. "'s limit.",
		     [8 ] = "Progressed!\n\n" .. self.name .. " is god's favorite.",
		     [9 ] = "Gosh, I can't expect that you\n\ncan be here! Incredible. ",
			 [10] = "Dear, " .. self.name .. ", \n\nYour imagination can already get rid\n\nof the earth gravity! ",
			 [11] = "Why there is no one to give a \n\nproposal about researching on\n\n" ..self.name .."' brain? ",
			 [12] = "Dear, " .. self.name .. ",\n\nyou makes me feel amorous.",
		     [13] = self.name .. ",\n\n Hold on a moment,\n\nThe beauty is waiting for you.",
		     [14] = self.name .. ",\n\n There is a short\n\ndistance you can see the beauty of\n\nthe destination!",
		     [15] = self.name .. ",\n\n The remaining " .. surplusScore .. " meters, \n\nbeauty is yours.",
		}


	if score <= 0 then
		self.Curstr = str[1]
	elseif score <= 5 then
		self.Curstr = str[2]
	elseif score <= 10 then
		self.Curstr = str[3]
	elseif score <= 20 then
		self.Curstr = str[4]
	elseif score <= 30 then
		self.Curstr = str[5]
	elseif score <= 40 then
		self.Curstr = str[6]
	elseif score <= 45 then
		self.Curstr = str[7]
	elseif score <= 50 then
		self.Curstr = str[8]
	elseif score <= 55 then
		self.Curstr = str[9]
	elseif score <= 60 then
		self.Curstr = str[10]
	elseif score <= 65 then
		self.Curstr = str[11]
	elseif score <= 70 then	
		self.Curstr = str[12]
	elseif score <= 80 then
		self.Curstr = str[13]
	elseif score <= 90 then
		self.Curstr = str[14]
	elseif score <= 100 then
		self.Curstr = str[15]
	end

end




--???
function DemoScene:classifyMonster( ... )
	
	
	local index = self.bar_index
	local monsterStyle = nil

	local switch = {
		[1] = function( ... )
			return "Little"
		end,
		[2] = function( ... )
			return "Little"
		end,
		[3] = function( ... )
			return "Little","Boom"
		end,
		[4] = function( ... )
			return "Long"
		end,
		[5] = function( ... )
			return "Long"
		end,
		[6] = function( ... )
			return "Long"
		end,

		[7] = function( ... )
			return "ZOMBIE"
		end,

		[8] = function( ... )
			return "Mid"
		end,
		[9] = function( ... )
			return "Mid","Boom"
		end,
		[10] = function( ... )
			return "Mid"
		end,
		[11] = function( ... )
			return "Mid"
		end,
		[12] = function( ... )
			return "Tall"
		end,
		[13] = function( ... )
			return "Tall"
		end
	
	}

	if self.bar_index ~= nil then
		monsterStyle1, monsterStyle2 = switch[index]()
	--	Log.printInfo("monsterStyle1 = ", monsterStyle1)
	--	Log.printInfo("monsterStyle2 = ", monsterStyle2)
	end

	return monsterStyle1, monsterStyle2
end



function DemoScene:playBoom()
	local x, y = self.barimage:getPos()
	self.boom = new(Image, "game/common/boom.png")
	self.boom:setAlign(kAlignBottomRight)
	self.boom:setPos(x - 200, y - 100)
	self.boom:setSize(400, 300)
	self.boom:addTo(self)
end

function DemoScene:playEffect(style1, style2)

	--Log.dump("<<<<<<<<<<<<<<<<   style", style1, style2)
	
	if style1 == "Little" and style2 == nil then
		self.m_gameSound:playEffect("deathJump")
	elseif style1 == "Little" and style2 == "Boom" then
		self.m_gameSound:playEffect("bomb")	
		self:playBoom()
	elseif style1 == "Long" and style2 == nil then
		self.m_gameSound:playEffect("deathLong")
	elseif style1 == "ZOMBIE" and style2 == nil then
		self.m_gameSound:playEffect("deathZombie")
	elseif style1 == "Mid" and style2 == nil then
		self.m_gameSound:playEffect("deathKick")
	elseif style1 == "Mid" and style2 == "Boom" then
		self.m_gameSound:playEffect("bomb")
		self:playBoom()
	elseif style1 == "Tall" and style2 == nil then
		self.m_gameSound:playEffect("hit")
	end
end

function DemoScene:updateMaxData(value)

	-- self.Curstr = "哇哦！\n\n" .. self.name .."您打破了世界记录\n\n获得了奥斯卡最高 " .. value .. " 分！"
	self.Curstr = "Wow! " .. self.name ..".\n\nYou have broken the world record,\n\nand won an Oscar for the highest\n\nscore " .. value .. "!"
 	
	self.maxscore = value


	nk.DictModule:setString("DemoScene","MaxScore", value)
	nk.DictModule:saveDict("DemoScene")	

	GAME_INFO_LIST[self.gameModel].maxScore = value

	BUTTON_CLICK_EVENT[self.gameModel].breakRecord = BUTTON_CLICK_EVENT[self.gameModel].breakRecord + 1 


	----------------------------------------------------------------------------------------
	local table = {method = "User.updateGameInfo", mid = MID, gameInfolist = GAME_INFO_LIST}
	Log.dump(table, ">   PostData,updateMaxData")
	self:httpUpdate("User.updateGameInfo", table)
	----------------------------------------------------------------------------------------

end

function DemoScene:getMaxData()

	local MaxScore = nk.DictModule:getString("DemoScene", "MaxScore")

	if MaxScore == "" then
		MaxScore = 0
		Log.printInfo("??ling")
	end
	return MaxScore
end

function DemoScene:setHeadAndName()
	local headPhotoPath = nk.DictModule:getString("playerAvatar", "photo")
	local playerName = nk.DictModule:getString("playerName", "name")
	local httpHeadUrl = nk.DictModule:getString("playerAvatar", "iconUrl")

	if headPhotoPath ~= "" and headPhotoPath ~= nil then
		local i, j = string.find(headPhotoPath, "[^\\/]-$")
		local FileName = string.sub(headPhotoPath, i, j)
		self.imagehead:setFile(FileName)
		self.imagehead = Mask.setMask(self.imagehead, "game/common/headframe1.png", {scale = 1, align = 0, x = -1.5, y = -1})
		self.imagehead:setVisible(true)
	else
		self.imagehead:setVisible(false)
	end

	self.imagehead = Mask.setMask(self.imagehead, "game/common/headframe1.png", {scale = 1, align = 0, x = -1.5, y = -1})
	self.imagehead:setVisible(true)
	UrlImage.spriteSetUrl(self.imagehead, httpHeadUrl)

	if playerName ~= "" and playerName ~= nil then
		self.textName:setText(playerName)
		self.name = playerName
	else
		self.textName:setVisible(false)
		self.name = "WindCao"
	end

	local headUrl = httpHeadUrl
	------------------------------------------------------------------------------
	local table = {method = "User.updateGameInfo", mid = MID, iconUrl = headUrl, nick = self.name}
	Log.dump(table, "<<<<<<<<<<<<<<     PostData,submit")
	self:httpUpdate("User.updateGameInfo", table)
	------------------------------------------------------------------------------
end

function DemoScene:getLastNameAndHeadFromHttp( ... )
	if LASTNAME ~= "" and LASTNAME ~= nil then
		self.textName:setVisible(true)
		self.textName:setText(LASTNAME)
		self.name = LASTNAME
	else
		self.textName:setVisible(false)
		self.name = "Child"
	end

	self.imagehead = Mask.setMask(self.imagehead, "game/common/headframe1.png", {scale = 1, align = 0, x = -1.5, y = -1})
	self.imagehead:setVisible(true)
	UrlImage.spriteSetUrl(self.imagehead, ICON_URL)
end


function DemoScene:btn_event_upload(name)

	if name and name ~= "" then
    	if BUTTON_CLICK_EVENT and BUTTON_CLICK_EVENT[name] then
    		BUTTON_CLICK_EVENT[name] = BUTTON_CLICK_EVENT[name] + 1
    	elseif BUTTON_CLICK_EVENT[self.gameModel] and BUTTON_CLICK_EVENT[self.gameModel][name] then
    		BUTTON_CLICK_EVENT[self.gameModel][name] = BUTTON_CLICK_EVENT[self.gameModel][name] + 1
		    -- Log.dump("<<<<<<<<<<<<<<<<<<<<<< self.gameModel", self.gameModel)
		    -- Log.dump("<<<<<<<<<<<<<<<<<<<<<< self.name", name)
		    -- Log.dump("<<<<<<<<<<<<<<<<<<<<<< BUTTON_CLICK_EVENT[self.gameModel][name]", BUTTON_CLICK_EVENT[self.gameModel][name])
    	end
    end

 --    ----------------------------------------------------------------------------------------
 --    local table = {method = "User.updateGameInfo", mid = MID, btnInfoList = BUTTON_CLICK_EVENT}
	-- Log.dump(table, ">>>>>>>>>>>    PostData,btn_event_upload")
 --   	self:httpUpdate("User.updateGameInfo", table)
 --   	----------------------------------------------------------------------------------
		   
end

function DemoScene:httpUpdate(method, table)
	nk.HttpController:execute(method, {param = table})
end


local RANK = {
	personalRankList = {
		mid = "",
		nick = LASTNAME,
		iconUrl = "",
		crazy = {
			rank = 0,
			maxscore = 0,
		},
		gentle = {
			rank = 0,
			maxscore = 0,
		},
	},

	gentleRankList = {},
	crazyRankList = {},

	-- gentleRankList = {
	--     [1] = {nick = "", maxscore = 0, iconUrl = ""},
	-- },
	-- carzyRankList = {
	--     [1] = {nick = "", maxscore = 0, iconUrl = ""},
	-- },

}

function DemoScene:showRank()
	nk.HttpController:execute("Rank.getRankList", {mid = MID, param = {method = "Rank.getRankList"}}, nil, function(errCode, data)

		Log.dump(data, "data")
		if data and data.flag == 10000 then
			local HttpCarzyRankList = data.data.gModelRankList.crazy
			local HttpGentleRankList = data.data.gModelRankList.gentle
			local HttpPersonalRankList = data.data.personalRankList

			RANK.personalRankList.crazy.rank = HttpPersonalRankList.crazy.rank
			RANK.personalRankList.gentle.rank = HttpPersonalRankList.gentle.rank
			RANK.personalRankList.crazy.maxscore = HttpPersonalRankList.crazy.maxScore
			RANK.personalRankList.gentle.maxscore = HttpPersonalRankList.gentle.maxScore
			RANK.personalRankList.iconUrl = data.data.iconUrl
			RANK.personalRankList.mid = data.data.mid
			RANK.personalRankList.nick = self.name


			for k,v in pairs(HttpCarzyRankList) do
				RANK.crazyRankList[k] = {}
				RANK.crazyRankList[k].nick = v.nick
				RANK.crazyRankList[k].maxscore = v.maxScore
				RANK.crazyRankList[k].iconUrl = v.iconUrl
				RANK.crazyRankList[k].mid = v.mid
				RANK.crazyRankList[k].index = k
				if RANK.crazyRankList[k].mid == RANK.personalRankList.mid then
					RANK.crazyRankList[k].isSelf = true
				else
					RANK.crazyRankList[k].isSelf = false
				end
			end

			for k,v in pairs(HttpGentleRankList) do
				RANK.gentleRankList[k] = {}
				RANK.gentleRankList[k].nick = v.nick
				RANK.gentleRankList[k].maxscore = v.maxScore
				RANK.gentleRankList[k].iconUrl = v.iconUrl
				RANK.gentleRankList[k].mid = v.mid
				RANK.gentleRankList[k].index = k
				if RANK.gentleRankList[k].mid == RANK.personalRankList.mid then
					RANK.gentleRankList[k].isSelf = true
				else
					RANK.gentleRankList[k].isSelf = false
				end
			end

			Log.dump(RANK, "<<<<<<   my,Rank")
			self:onRankPopup(RANK)
		end

	end)
end

function DemoScene:uploadHead()
	nk.HttpController:execute("User.uploadIcon", {param = {method = "User.uploadIcon"}})
end

return DemoScene












