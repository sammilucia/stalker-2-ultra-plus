@echo off

set VERSION=0.4.0

unrealpak .\~UltraPlus_Stalker2_P.pak -create=.\responsefile.txt
unrealpak .\~UltraPlus_FSR3-FG_P.pak -create=.\responsefile-fsr3-fg.txt

echo.

::pause