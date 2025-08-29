@echo off
color 0A
cls

echo ========================================
echo  BUILD PLUGIN ONLY - SIMPLE SOLUTION
echo ========================================
echo.

cd /d "%~dp0"

echo We'll skip building HDT and use your existing installation.
echo.

echo [1/3] Finding existing HDT executable...

REM Check multiple possible locations for HDT
set HDT_EXE=
if exist "..\Hearthstone Deck Tracker\bin\x86\Debug\HearthstoneDeckTracker.exe" (
    set "HDT_EXE=..\Hearthstone Deck Tracker\bin\x86\Debug\HearthstoneDeckTracker.exe"
    echo ✅ Found HDT at: ..\Hearthstone Deck Tracker\bin\x86\Debug\HearthstoneDeckTracker.exe
) else if exist "..\Hearthstone Deck Tracker\HearthstoneDeckTracker.exe" (
    set "HDT_EXE=..\Hearthstone Deck Tracker\HearthstoneDeckTracker.exe"
    echo ✅ Found HDT at: ..\Hearthstone Deck Tracker\HearthstoneDeckTracker.exe
) else if exist "..\Hearthstone Deck Tracker\bin\x86\Release\HearthstoneDeckTracker.exe" (
    set "HDT_EXE=..\Hearthstone Deck Tracker\bin\x86\Release\HearthstoneDeckTracker.exe"
    echo ✅ Found HDT at: ..\Hearthstone Deck Tracker\bin\x86\Release\HearthstoneDeckTracker.exe
) else if exist "..\HearthstoneDeckTracker.exe" (
    set "HDT_EXE=..\HearthstoneDeckTracker.exe"
    echo ✅ Found HDT at: ..\HearthstoneDeckTracker.exe
) else (
    echo ❌ Cannot find HDT executable
    echo.
    echo Please make sure HDT is installed and try:
    echo 1. Start HDT once to make sure it works
    echo 2. Run this script again
    echo.
    pause
    exit /b 1
)

echo.
echo [2/3] Updating plugin references...

REM Update the project file to point to the found HDT executable
powershell -Command "(Get-Content 'BattlegroundsLogger.csproj') -replace 'HearthstoneDeckTracker[^<]*exe', '%HDT_EXE%' | Set-Content 'BattlegroundsLogger.csproj'" >nul 2>&1

echo ✅ Updated project references

echo.
echo [3/3] Building plugin...

REM Build only the plugin using MSBuild (more compatible with .NET Framework)
set MSBUILD=
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
) else (
    echo ❌ MSBuild not found. Please install Visual Studio.
    pause
    exit /b 1
)

echo Using MSBuild: %MSBUILD%

"%MSBUILD%" BattlegroundsLogger.csproj /p:Configuration=Release /p:Platform=x86 /v:minimal

if %errorLevel% EQU 0 (
    echo ✅ Plugin build successful!
    
    if exist "bin\x86\Release\BattlegroundsLogger.dll" (
        echo ✅ Plugin DLL created: bin\x86\Release\BattlegroundsLogger.dll
        
        REM Copy to prebuilt folder
        if not exist "prebuilt" mkdir prebuilt
        copy "bin\x86\Release\BattlegroundsLogger.dll" "prebuilt\" >nul 2>&1
        echo ✅ Copied to prebuilt folder
        
        echo.
        echo ========================================
        echo  BUILD COMPLETE - SUCCESS!
        echo ========================================
        echo.
        echo ✅ Plugin ready for installation
        echo.
        echo Next steps:
        echo 1. Run INSTALL.bat to install the plugin
        echo 2. Enable plugin in HDT (Options → Tracker → Plugins)
        echo 3. Test in Battlegrounds
        echo.
    ) else (
        echo ❌ Plugin DLL not found after build
    )
) else (
    echo ❌ Plugin build failed
    echo.
    echo This usually means:
    echo 1. HDT reference is incorrect
    echo 2. Missing dependencies
    echo.
    echo Try running HDT once, then run this script again.
)

echo Press any key to exit...
pause >nul
exit /b 0