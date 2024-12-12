@echo off

set VERSION=1.6.5-test

7z a -r "..\dist\Stalker 2 Ultra Plus v%VERSION%.zip" .\build_release\*
7z a -r "..\dist\Stalker 2 Ultra Plus v%VERSION%-gp.zip" .\build_release-gp\*
7z a -r "..\dist\Stalker 2 FSR3-FG Addon v%VERSION%.zip" .\build_fsr3-fg\*
7z a -r "..\dist\Stalker 2 FSR3-FG Addon v%VERSION%-gp.zip" .\build_fsr3-fg-gp\*

echo.

::pause