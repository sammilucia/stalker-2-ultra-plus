@echo off

set VERSION=2.0.0

RMDIR /S /Q build
MKDIR build
xcopy /s/e/i build_release "build/build_release"

DEL ..\dist\*.zip
pause
7Z a -r "..\dist\Stalker 2 Ultra Plus v%VERSION%.zip" .\build\build_release\*

RENAME "build/build_release/Stalker2/Binaries/Win64" WinGDK

7Z a -r "..\dist\Stalker 2 Ultra Plus v%VERSION%-gp.zip" .\build\build_release\*
7Z a -r "..\dist\Stalker 2 FSR3-FG Addon v%VERSION%.zip" .\build_fsr3-fg\*

echo.

::pause