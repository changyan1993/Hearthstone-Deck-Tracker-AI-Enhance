@echo off
setlocal EnableDelayedExpansion
color 0B
cls

echo ========================================
echo  BATTLEGROUNDS LOGGER - LOCAL UPDATE
echo ========================================
echo.

REM Get current HDT version
echo [1/4] Checking HDT version compatibility...

set HDT_VERSION=Unknown
set HDT_PLATFORM=x86

REM Try to find HDT version from project file
if exist "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" (
    for /f "tokens=2 delims=<>" %%a in ('findstr "AssemblyVersion" "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj"') do set HDT_VERSION=%%a
    for /f "tokens=2 delims=<>" %%a in ('findstr "PlatformTarget" "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj"') do set HDT_PLATFORM=%%a
)

echo [OK] HDT Version: !HDT_VERSION!
echo [OK] HDT Platform: !HDT_PLATFORM!

REM Check if our plugin references match
echo.
echo [2/4] Verifying plugin compatibility...

set REF_PATH=..\Hearthstone Deck Tracker\bin\!HDT_PLATFORM!\Release\HearthstoneDeckTracker.exe
if not exist "!REF_PATH!" (
    echo [!] HDT executable not found at: !REF_PATH!
    echo     Checking if HDT needs to be built...
    
    if exist "..\Hearthstone Deck Tracker\HearthstoneDeckTracker.exe" (
        echo [OK] Found HDT exe in root directory
    ) else (
        echo [X] HDT not built. Please build HDT first or update references
        pause
        exit /b 1
    )
)

echo [OK] HDT references verified

REM Update plugin if needed
echo.
echo [3/4] Checking for plugin updates...

set PLUGIN_DLL=%APPDATA%\HearthstoneDeckTracker\Plugins\BattlegroundsLogger\BattlegroundsLogger.dll
set SOURCE_DLL=bin\!HDT_PLATFORM!\Release\BattlegroundsLogger.dll

REM Check if plugin exists
if not exist "!PLUGIN_DLL!" (
    echo [!] Plugin not installed. Run INSTALL.bat first
    pause
    exit /b 1
)

REM Check if we have built version
if not exist "!SOURCE_DLL!" (
    echo [!] Plugin not built. Building now...
    call build.bat
    if !errorlevel! NEQ 0 (
        echo [X] Build failed
        pause
        exit /b 1
    )
)

REM Compare file dates/sizes
for %%a in ("!SOURCE_DLL!") do set SOURCE_DATE=%%~ta
for %%a in ("!PLUGIN_DLL!") do set PLUGIN_DATE=%%~ta

echo Source:    !SOURCE_DATE!
echo Installed: !PLUGIN_DATE!

echo.
echo [4/4] Updating plugin...

REM Stop HDT if running
tasklist /FI "IMAGENAME eq HearthstoneDeckTracker.exe" 2>NUL | find /I /N "HearthstoneDeckTracker.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [!] HDT is running. Please close HDT and press any key to continue...
    pause >nul
)

REM Copy updated DLL
copy "!SOURCE_DLL!" "!PLUGIN_DLL!" >nul 2>&1
if !errorlevel! NEQ 0 (
    echo [X] Failed to copy plugin DLL
    pause
    exit /b 1
)

echo [OK] Plugin updated successfully!

REM Update version info
echo.
echo Plugin Details:
echo - HDT Version: !HDT_VERSION!
echo - Platform: !HDT_PLATFORM!
echo - Updated: %DATE% %TIME%
echo - Location: %APPDATA%\HearthstoneDeckTracker\Plugins\BattlegroundsLogger\

echo.
echo ========================================
echo  UPDATE COMPLETE!
echo ========================================
echo.
echo Next steps:
echo 1. Start Hearthstone Deck Tracker
echo 2. Plugin should load automatically
echo 3. Check status indicator in game
echo.
echo Press any key to exit...
pause >nul
exit /b 0