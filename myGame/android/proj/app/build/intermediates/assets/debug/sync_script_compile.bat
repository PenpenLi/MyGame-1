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
		rmdir /q /s scripts
	)
	mkdir scripts
	xcopy %LUA_DIR%\*.* scripts /e /s /y /q
	
	pushd %AND_ASSETS%\scripts
		%TOOLS%\bin\php.exe %TOOLS%\BinaryEncoderWrapper.php %AND_ASSETS%\scripts
		rem for /r %%i in (*.lua) do (
		rem 	rem %TOOLS_ENCODE_NEW% %%~fi
		rem 	%TOOLS%\bin\php.exe %TOOLS%\BinaryEncoderWrapper.php %%~fi
		rem 	del %%~fi
		rem 	rem echo compile %%~ni.lua
		rem 	rename %%~dpi%%~ni.bylua %%~ni.lua
		rem )
	popd

popd

pause