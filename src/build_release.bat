@echo off

unrealpak .\build_release\Stalker2\Content\Paks\~UltraPlus_Stalker2_P.pak -create=.\responsefile_release.txt
unrealpak .\build_release-gp\Stalker2\Content\Paks\~UltraPlus_Stalker2_P.pak -create=.\responsefile_release.txt

unrealpak .\build_fsr3-fg-gp\Stalker2\Content\Paks\~UltraPlus_FSR3-FG_P.pak -create=.\responsefile_fsr3-fg.txt
unrealpak .\build_fsr3-fg-gp\Stalker2\Content\Paks\~UltraPlus_FSR3-FG_P.pak -create=.\responsefile_fsr3-fg.txt

echo.

::pause