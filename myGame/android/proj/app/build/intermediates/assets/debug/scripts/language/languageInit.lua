
bm = {}

--语言包函数
local appconfig = require("language.appconfig")

T = require("language.lang.Gettext").gettextFromFile(System.getStorageInnerRoot() .."/scripts/language/lang/".. appconfig.LANG .. ".mo")
-- T = require("language.lang.Gettext").gettextFromFile(appconfig.LANG..".mo")

bm.LangUtil         = require("language.lang.LangUtil")

