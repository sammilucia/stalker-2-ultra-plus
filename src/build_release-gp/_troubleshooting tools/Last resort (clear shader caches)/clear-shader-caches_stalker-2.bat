@echo off
title S.T.A.L.K.E.R. 2 (2024) cache-shader-caches v0.6

echo [1mS.T.A.L.K.E.R. 2 (2024) clear-shader-caches v0.6 by SammiLucia[0m
echo.
echo.
echo This script will reset shader caches for:
echo   - S.T.A.L.K.E.R. 2
echo   - Nvidia
echo   - AMD
echo.
echo Clearing caches can fix stability and FPS issues.
echo.
echo.
echo NOTE1: The Nvidia and AMD caches have shader caches for other games. Clearing
echo them is not harmful, games will rebuild them as needed.
echo.
echo [1mNOTE2: This is not like flush-mem: You only need to run this if you suspect a
echo problem with the shader caches.[0m
echo.
echo NOTE3: If you receive the error: [1m"The process cannot access the file because it
echo is being used"[0m, try closing programs, restarting your computer, or running this
echo script in Safe Mode.
echo.
echo.
echo.

timeout /T 1 >nul

set CHOICE=
set /p CHOICE="Would you like to clear your shader caches? [y/n] "

if not '%CHOICE%'=='' set choice=%CHOICE:~0,1%
if '%CHOICE%'=='y' goto :resetCache
if '%CHOICE%'=='n' goto :noChange

echo.
echo.
echo.
echo Invalid selection.
goto :endScript 

:resetCache
    echo.
    echo.
    echo.
    echo Resetting caches:
    echo.

    echo|set /p="Nvidia shader cache..."
    if not exist "%HOMEDRIVE%\%HOMEPATH%\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\" (  
        echo ..............Error: Folder not found.
        echo.
        echo.
        echo Folder [7mC:\%HOMEPATH%\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\[0m was not found.
        echo.
        echo [1m^>^>^>^>^> Please check this location manually.[0m
        echo.
        echo.
    ) else (
        del /F /Q "%TEMP%\..\..\LocalLow\NVIDIA\PerDriverVersion\DXCache\*"
        echo ..............Done
    )

    echo|set /p="AMD shader cache..."
    if not exist "%LOCALAPPDATA%\AMD\DXCache" (  
        echo ..............Error: Folder not found.
        echo.
        echo.
        echo Folder [7m%LOCALAPPDATA%\AMD\DXCache\[0m was not found.
        echo.
        echo [1m^>^>^>^>^> Please check this location manually.[0m
        echo.
        echo.
    ) else (
        del /F /Q "%LOCALAPPDATA%\AMD\DXCache\*"
        echo ..............Done
    )

    echo|set /p="S.T.A.L.K.E.R. 2 Unreal Engine shader caches..."
    if not exist "%LOCALAPPDATA%\Stalker2\Saved\D3D*.ushaderprecache" (  
        echo ......Error: Not found.
        echo.
        echo.
        echo The files [7m%LOCALAPPDATA%\Stalker2\Saved\D3D*.upipelinecache[0m
        echo and/or [7m%LOCALAPPDATA%\Stalker2\Saved\D3D*.ushaderprecache[0m were not found.
        echo.
        echo [1m^>^>^>^>^> Please check these locations manually.[0m
        echo.
        echo.
    ) else (
        del /F /Q "%LOCALAPPDATA%\Stalker2\Saved\*.upipelinecache"
        del /F /Q "%LOCALAPPDATA%\Stalker2\Saved\*.ushaderprecache"
        echo ......Done
    )

    echo.
    echo.
    echo Completed.
    echo.

    timeout /T 1 >nul

    goto :endScript 

:noChange
    echo.
    echo.
    echo.
    echo No changes were made.

    goto :endScript 

:endScript
    echo Press any key to exit...
    pause >nul