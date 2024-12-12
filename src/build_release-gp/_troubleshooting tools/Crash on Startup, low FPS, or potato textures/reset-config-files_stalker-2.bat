@echo off
title S.T.A.L.K.E.R. 2 reset-config v0.2

echo [1mReset S.T.A.L.K.E.R. 2 Config v0.2 by SammiLucia[0m
echo.
echo.
echo This script will reset the config files in [1m%LOCALAPPDATA%\Stalker2[0m.
echo.
echo This fixes most common causes of:
echo    - Crashing at game launch
echo    - Crashing loading saved games
echo    - Low quality textures
echo    - Low FPS after installing Ultra+ or modifying Engine.ini
echo.
echo.
echo For convenience the [1mWindows[0m config file folder will be renamed to [1mWindows.old[0m.
echo.
echo After the script has finished [4mstart the game to recreate this folder[0m.
echo.
echo.
echo [4mNOTE: You will also need to copy the Ultra+ Engine.ini after this script has run.[0m
echo.
echo.
echo.

timeout /T 1 >nul

set CHOICE=
set /p CHOICE="Proceed? [y/n] "

if not '%CHOICE%'=='' set CHOICE=%CHOICE:~0,1%
if '%CHOICE%'=='y' goto :resetConfig
if '%CHOICE%'=='n' goto :noChange

echo.
echo.
echo.
echo Invalid selection.
goto :endScript 

:resetConfig
    echo.
    echo.
    echo.
    echo Resetting config files:
    echo.

    echo|set /p="Moving INI files..."
    if not exist "%LOCALAPPDATA%\Stalker2\Saved\Config\Windows" (  
        echo ..............Error: Folder not found.
        echo.
        echo.
        echo Folder [7m%LOCALAPPDATA%\Stalker2\Saved\Config\Windows\[0m was not found.
        echo Please check the location manually.
        echo.
        echo.
        echo Press any key to close...
        pause >nul
        goto :EOF
    ) 
    rename "%LOCALAPPDATA%\Stalker2\Saved\Config\Windows" Windows.old
    echo ............Done

    echo.
    echo.
    echo Completed without issue! :)
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
    setlocal enableextensions enabledelayedexpansion

    for /F "tokens=1 delims=# " %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do set "BSPACE=%%a"
    echo.
    echo.
    echo.
    echo|set /p="Closing in (3)..."
    timeout /T 1 >nul
    echo|set /p=%BSPACE%%BSPACE%%BSPACE%%BSPACE%%BSPACE%%BSPACE%(2)...
    timeout /T 1 >nul
    echo|set /p=%BSPACE%%BSPACE%%BSPACE%%BSPACE%%BSPACE%%BSPACE%(1)...
    timeout /T 1 >nul
