require("game.gameBase.socketHttp");
require("game.common.eventConstants")

require("game.gameBase.httpModule");

require("game.net.socket.socketConfig")
require("game.gameBase.gameBaseSocket");
require("game.gameBase.gameBaseSocketProcesser");
require("game.gameBase.gameBaseSocketReader");
require("game.gameBase.gameBaseSocketWriter");

require("game.gameBase.gameBaseData");
require("game.gameBase.gameBaseLayer");
require("game.gameBase.gameBaseScene");
require("game.gameBase.gameBaseSceneAsync");
require("game.gameBase.gameBaseController");
require("game.gameBase.gameBaseState");
require("game.gameBase.gameBaseNativeEvent");
print("before init statesConfig")
require("game.statesConfig")
require("game.net.http.httpConfig")
print("after init statesConfig")

nk = nk or {}

consts = import("game.keys.consts")

nk.GCD = import("game.common.gcd")

nk.functions = require("game.common.functions")

kImageMap = require("qnRes.qn_res_alias_map")

-- data keys
nk.dataKeys = import("game.keys.DATA_KEYS")
nk.cookieKeys = import("game.keys.COOKIE_KEYS")
nk.gameStateKeys = import("game.keys.GAMESTATE_KEYS")

nk.config = import("game.keys.config")

local DictModule = require("utils.dictModule")
nk.DictModule = DictModule.getInstance()

local NativeEventController = require("game.nativeEvent.nativeEventController")
nk.NativeEventController = NativeEventController.getInstance()

local GameNativeEvent = require("game.nativeEvent.gameNativeEvent")
nk.GameNativeEvent = new(GameNativeEvent)

local HttpController = require("game.net.http.httpController")
nk.HttpController = HttpController.getInstance()

local SocketController = require("game.net.socket.socketController")
nk.SocketController = SocketController.getInstance()

local UpdateHttpFile = require("game.update.updateHttpFile")
nk.UpdateHttpFile = UpdateHttpFile.getInstance()

local updateConfig = require("game.update.updateConfig")
nk.UpdateConfig = updateConfig

local PopupManager = require("game.popup.popupManager")
nk.PopupManager = new(PopupManager)

nk.Dialog = require("game.popup.dialog")

local CenterTipManager = require("game.common.centerTipManager")
nk.CenterTipManager = new(CenterTipManager)

-- lua call 相关


--上报统计管理类
local AnalyticsManager = require("game.common.analyticsManager")
nk.AnalyticsManager = new(AnalyticsManager)

local UmengNativeEvent = require("game.nativeEvent.umengNativeEvent")
nk.UmengNativeEvent = new(UmengNativeEvent)



local AdPlugin = require("game.nativeEvent.adStatsNativeEvent")
nk.AdPlugin = new(AdPlugin)

local UnityAdsNativeEvent = require("game.nativeEvent.unityAdsNativeEvent")
nk.UnityAdsNativeEvent = new(UnityAdsNativeEvent)

-- http下载管理
local HttpDownloadManager = require("game.common.httpDownloadManager")
nk.HttpDownloadManager = new(HttpDownloadManager)

local SoundManager = require("game.common.soundManager")
nk.SoundManager = new(SoundManager)

local TopTipManager = require("game.common.topTipManager")
nk.TopTipManager = new(TopTipManager)

local DataCenterManager = require("game.common.dataCenterManager")
nk.DataCenterManager = new(DataCenterManager)