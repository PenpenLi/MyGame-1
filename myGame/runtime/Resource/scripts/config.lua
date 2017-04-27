--
--
--

-- true - release apk
-- false - debug apk
IS_RELEASE = false

-- 0 - disable debug info, 
-- 1 - less debug info,
-- 2 - verbose debug info
DEBUG = 2

if IS_RELEASE then
    DEBUG = 0
end

-- lua Log 是否生成文件
DEBUG_LOG = false

if System.getPlatform() == kPlatformWin32 then
	DEBUG_LOG = true
end

-- 是否开高效
QUALITY_MODE = 1

DETECT_MEM_LEAK = true