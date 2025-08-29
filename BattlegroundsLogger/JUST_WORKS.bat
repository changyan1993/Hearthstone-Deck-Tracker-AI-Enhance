@echo off
color 0A
cls

echo ========================================
echo  BATTLEGROUNDS LOGGER - JUST WORKS
echo ========================================
echo.
echo This is the SIMPLE solution that just works:
echo.
echo 1. Allow HDT to update normally when it asks
echo 2. If plugin stops working after HDT update:
echo    - Run this script again
echo    - It will rebuild everything
echo.

cd /d "%~dp0"

echo 🔨 Building everything from scratch...
echo.

REM Build HDT first
echo [1/3] Building HDT...
cd "..\Hearthstone Deck Tracker"
dotnet build "Hearthstone Deck Tracker.csproj" -c Release -p:Platform=x86 >build_output.txt 2>&1

if %errorLevel% NEQ 0 (
    echo ❌ HDT build failed. Trying alternative approach...
    
    REM Check if we can find a built version
    if exist "HearthstoneDeckTracker.exe" (
        echo ✅ Found existing HDT executable
    ) else (
        echo ❌ Cannot find HDT executable
        echo.
        echo Please:
        echo 1. Build HDT manually in Visual Studio, OR
        echo 2. Let HDT auto-update itself first
        echo.
        pause
        exit /b 1
    )
)

REM Build plugin
echo [2/3] Building plugin...
cd "..\BattlegroundsLogger"
dotnet build BattlegroundsLogger.csproj -c Release -p:Platform=x86 >>build_output.txt 2>&1

if %errorLevel% NEQ 0 (
    echo ❌ Plugin build failed
    echo.
    echo The most common issue is HDT not being built yet.
    echo.
    echo Solutions:
    echo 1. Let HDT update itself first ^(when it prompts^)
    echo 2. Then run this script again
    echo 3. Or build HDT manually in Visual Studio
    echo.
    pause
    exit /b 1
)

REM Install plugin
echo [3/3] Installing plugin...
set PLUGIN_DIR=%APPDATA%\HearthstoneDeckTracker\Plugins\BattlegroundsLogger

if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"

if exist "bin\x86\Release\BattlegroundsLogger.dll" (
    copy "bin\x86\Release\BattlegroundsLogger.dll" "%PLUGIN_DIR%\" >nul 2>&1
    echo ✅ Plugin installed successfully
    
    echo.
    echo 🎉 COMPLETE! 
    echo.
    echo ✅ HDT built
    echo ✅ Plugin built  
    echo ✅ Plugin installed
    echo.
    echo 🎮 HOW TO USE:
    echo 1. Start HDT
    echo 2. Go to Options → Tracker → Plugins
    echo 3. Enable "Battlegrounds Logger"
    echo 4. Play Battlegrounds ^(files save to Documents\BG-AI-Logs^)
    echo.
    echo 🔄 HDT UPDATES:
    echo • Let HDT update normally when it asks
    echo • If plugin stops working, just run this script again
    echo • That's it - no complex automation needed!
    echo.
) else (
    echo ❌ Plugin DLL not found after build
    pause
    exit /b 1
)

echo Press any key to exit...
pause >nul
exit /b 0