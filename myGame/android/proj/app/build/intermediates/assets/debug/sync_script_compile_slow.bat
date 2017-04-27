@echo off
REM set var
set TRUNK=%~dp0\..\..
set RES=%TRUNK%\runtime\Resource

set TOOLS=%TRUNK%\tools
set MAKE=%TRUNK%\make

set LUA_DIR=%RES%\scripts
set TOOLS_LUAC=%TOOLS%\luac.exe
set TOOLS_ENCODE=%TOOLS%\BinaryEncoder.exe
set AND_ASSETS=%TRUNK%\assets

pushd %AND_ASSETS%

	echo "copy scripts"
	if exist scripts (
		del /q scripts\*
	) else (
		mkdir scripts
	)
	xcopy %LUA_DIR%\*.* scripts /e /s /y /q
	pushd %AND_ASSETS%\scripts
		for /r %%i in (*.lua) do (
			%TOOLS_ENCODE% %%~fi
			del %%~fi
			echo compile %%~ni.lua
			rename %%~dpi%%~ni.bylua %%~ni.lua
		)
	popd

popd

pause