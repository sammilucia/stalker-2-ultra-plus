@echo off

set VERSION=0.4.0

unrealpak .\build\Stalker2\Content\Paks\~UltraPlus_Stalker2_P.pak -create=.\responsefile_release.txt
unrealpak .\build\Stalker2\Content\Paks\~UltraPlus_FSR3-FG_P.pak -create=.\responsefile_fsr3-fg.txt

echo.

::pause