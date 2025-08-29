@echo off
setlocal EnableDelayedExpansion
color 0A
cls

echo ========================================
echo  BATTLEGROUNDS LOGGER - STATUS DASHBOARD
echo ========================================
echo.

echo [System Status]
echo ================

REM Check HDT Version
set HDT_VERSION=Unknown
if exist "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" (
    for /f "tokens=2 delims=<>" %%a in ('findstr "AssemblyVersion" "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj"') do set HDT_VERSION=%%a
)

echo HDT Version: !HDT_VERSION!

REM Check if HDT is running
tasklist /FI "IMAGENAME eq HearthstoneDeckTracker.exe" 2>NUL | find /I /N "HearthstoneDeckTracker.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo HDT Status: 🟢 Running
) else (
    echo HDT Status: 🔴 Not Running
)

REM Check plugin installation
set PLUGIN_DLL=%APPDATA%\HearthstoneDeckTracker\Plugins\BattlegroundsLogger\BattlegroundsLogger.dll
if exist "%PLUGIN_DLL%" (
    echo Plugin Status: 🟢 Installed
    for %%a in ("%PLUGIN_DLL%") do echo Plugin Date: %%~ta
) else (
    echo Plugin Status: 🔴 Not Installed
)

REM Check auto-update system
schtasks /query /tn "BattlegroundsLogger_AutoSync" >nul 2>&1
if %errorLevel% EQU 0 (
    echo Auto-Update: 🟢 Enabled
) else (
    echo Auto-Update: 🔴 Not Setup
)

echo.
echo [Recent Activity]
echo =================

REM Check recent logs
if exist "plugin_monitor.log" (
    echo Last Monitor Check:
    for /f "tokens=*" %%a in (plugin_monitor.log) do echo   %%a
    echo.
)

if exist "auto_rebuild.log" (
    echo Last Auto-Rebuild:
    for /f "tokens=*" %%a in (auto_rebuild.log) do echo   %%a
    echo.
)

if exist "smart_rebuild.log" (
    echo Last Smart Rebuild:
    for /f "tokens=*" %%a in ('tail -3 smart_rebuild.log 2^>nul ^|^| type smart_rebuild.log') do echo   %%a
    echo.
)

REM Check for API breaking changes
if exist "API_BREAKING_CHANGES.txt" (
    echo ⚠️  API Breaking Changes Detected!
    echo    Check API_BREAKING_CHANGES.txt for details
    echo.
)

echo [Version History]
echo =================

if exist "last_hdt_version.txt" (
    set /p LAST_VERSION=<last_hdt_version.txt
    echo Tracked Version: !LAST_VERSION!
    if "!HDT_VERSION!" NEQ "!LAST_VERSION!" (
        echo Status: ⚠️  Version Change Detected (!LAST_VERSION! → !HDT_VERSION!)
    ) else (
        echo Status: ✅ Version In Sync
    )
) else (
    echo Tracked Version: None (run ENABLE_AUTO_UPDATES.bat)
)

echo.
echo [Quick Actions]
echo ===============
echo 1. Run ENABLE_AUTO_UPDATES.bat  - Setup auto-update system
echo 2. Run UPDATE.bat               - Manual plugin update  
echo 3. Run CHECK_COMPATIBILITY.bat  - Verify compatibility
echo 4. Run SMART_REBUILD.bat        - Force intelligent rebuild
echo.

echo [Output Directory]
echo ==================
if exist "%USERPROFILE%\Documents\BG-AI-Logs" (
    echo Location: %USERPROFILE%\Documents\BG-AI-Logs
    dir "%USERPROFILE%\Documents\BG-AI-Logs" /b | find /c /v "" >temp_count.txt
    set /p FOLDER_COUNT=<temp_count.txt
    del temp_count.txt
    echo Sessions: !FOLDER_COUNT! recorded
) else (
    echo Status: 🔴 Output directory not created yet
)

echo.
echo ========================================
echo Press any key to exit...
pause >nul
exit /b 0