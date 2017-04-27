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

	echo "copy audio"
	if exist audio (
		del /q audio\*
	) else (
		mkdir audio
	)
	xcopy %RES%\audio\*.* audio /e /s /y /q

	echo "copy fonts"
	if exist fonts (
		del /q fonts\*
	) else (
		mkdir fonts
	)
	xcopy %RES%\fonts\*.* fonts /e /s /y /q

	echo "copy images"
	@echo off
	if exist images (
		del /q images\*
	) else (
		mkdir images
	)
	xcopy %RES%\images\*.* images /e /s /y /q
	echo "remove images that in the atlas"
	%TOOLS%\bin\php.exe %TOOLS%\HandleAssetImages.php %AND_ASSETS%\images\res %AND_ASSETS%\..\runtime\Resource\scripts
	rem pushd %AND_ASSETS%\images
		rem for /r %%i in (*.png) do (
		rem 	if exist %%~fi (
		rem 		findstr "\"%%~ni.png\"" %RES%\scripts\view\atlas\*.lua >nul 2>&1
		rem 		if errorlevel 1 (
		rem 			rem echo %%~fi
		rem 		) else (
		rem 			echo remove %%~fi
		rem 			del %%~fi
		rem 		)
		rem 	) 
		rem )
		rem for /r %%i in (*.jpg) do (
		rem 	if exist %%~fi (
		rem 		findstr "\"%%~ni.jpg\"" %RES%\scripts\view\atlas\*.lua >nul 2>&1
		rem 		if errorlevel 1 (
		rem 			rem echo %%~fi
		rem 		) else (
		rem 			echo remove %%~fi
		rem 			del %%~fi
		rem 		)
		rem 	) 
		rem )
	rem popd

	pause

	rem echo "copy scripts"
	rem if exist scripts (
	rem 	del /q scripts\*
	rem ) else (
	rem 	mkdir scripts
	rem )
	rem xcopy %LUA_DIR%\*.* scripts /e /s /y /q
	rem pushd %AND_ASSETS%\scripts
	rem 	for /r %%i in (*.lua) do (
	rem 		%TOOLS_ENCODE% %%~fi
	rem 		del %%~fi
	rem 		echo compile %%~ni.lua
	rem 		rename %%~dpi%%~ni.bylua %%~ni.lua
	rem 	)
	rem popd

popd
