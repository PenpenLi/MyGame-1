@echo off

COPY /y .\diff\AndroidManifest.xml ..\proj\app\src\main\AndroidManifest.xml
COPY /y .\diff\strings.xml ..\proj\app\src\main\res\values\strings.xml
COPY /y .\diff\app\build.gradle ..\proj\app\build.gradle
COPY /y .\diff\app\google-services.json ..\proj\app\google-services.json

COPY /y .\diff\res\drawable\icon.png ..\proj\app\src\main\res\drawable\icon.png
COPY /y .\diff\res\drawable\push.png ..\proj\app\src\main\res\drawable\push.png
COPY /y .\diff\res\drawable-hdpi\icon.png ..\proj\app\src\main\res\drawable-hdpi\icon.png
COPY /y .\diff\res\drawable-hdpi\push.png ..\proj\app\src\main\res\drawable-hdpi\push.png
COPY /y .\diff\res\drawable-xhdpi\push.png ..\proj\app\src\main\res\drawable-xhdpi\push.png

..\..\tools\bin\php.exe update_project_files.php

pause
