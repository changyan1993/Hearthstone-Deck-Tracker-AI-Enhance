@echo off
setlocal EnableDelayedExpansion
color 0B
cls

echo ========================================
echo  BUILD HDT + PLUGIN - COMPLETE SOLUTION
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Checking HDT source...
if not exist "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" (
    echo [X] HDT project file not found
    echo     Expected: ..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj
    pause
    exit /b 1
)
echo [OK] HDT project found

echo.
echo [2/4] Building HDT first (this creates the references our plugin needs)...

cd "..\Hearthstone Deck Tracker"
echo Current directory: %CD%

REM Try to build HDT with .NET SDK
dotnet build "Hearthstone Deck Tracker.csproj" -c Release -p:Platform=x86 >hdt_build.log 2>&1

if %errorLevel% NEQ 0 (
    echo [!] .NET SDK build failed, trying MSBuild...
    
    REM Find MSBuild
    set MSBUILD=
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
        set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    ) else if exist "%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
        set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    if "!MSBUILD!"=="" (
        echo [X] No build tools found. Please install Visual Studio or .NET SDK
        echo.
        echo Check hdt_build.log for details:
        type hdt_build.log
        pause
        exit /b 1
    )
    
    echo Using MSBuild: !MSBUILD!
    "!MSBUILD!" "Hearthstone Deck Tracker.csproj" /p:Configuration=Release /p:Platform=x86 >>hdt_build.log 2>&1
    
    if !errorLevel! NEQ 0 (
        echo [X] HDT build failed
        echo.
        echo Check hdt_build.log for details:
        type hdt_build.log
        pause
        exit /b 1
    )
)

echo [OK] HDT built successfully

echo.
echo [3/4] Verifying HDT output...
if exist "bin\x86\Release\HearthstoneDeckTracker.exe" (
    echo [OK] HDT executable found: bin\x86\Release\HearthstoneDeckTracker.exe
) else (
    echo [X] HDT executable not found after build
    echo Expected: bin\x86\Release\HearthstoneDeckTracker.exe
    
    echo.
    echo Available files in bin directory:
    dir bin /s /b
    pause
    exit /b 1
)

echo.
echo [4/4] Building plugin...
cd "..\BattlegroundsLogger"
echo Current directory: %CD%

REM Now try building the plugin
dotnet build BattlegroundsLogger.csproj -c Release -p:Platform=x86 >plugin_build.log 2>&1

if %errorLevel% EQU 0 (
    echo [OK] Plugin built successfully
    
    if exist "bin\x86\Release\BattlegroundsLogger.dll" (
        echo [OK] Plugin DLL created: bin\x86\Release\BattlegroundsLogger.dll
        
        REM Copy to prebuilt folder so INSTALL.bat can find it
        if not exist "prebuilt" mkdir prebuilt
        copy "bin\x86\Release\BattlegroundsLogger.dll" "prebuilt\" >nul 2>&1
        echo [OK] Copied to prebuilt folder for easy installation
        
    ) else (
        echo [!] Plugin DLL not found after successful build
    )
) else (
    echo [X] Plugin build failed
    echo.
    echo Check plugin_build.log for details:
    type plugin_build.log
    pause
    exit /b 1
)

echo.
echo ========================================
echo  BUILD COMPLETE - SUCCESS!
echo ========================================
echo.
echo Files created:
echo ✅ HDT: ..\Hearthstone Deck Tracker\bin\x86\Release\HearthstoneDeckTracker.exe
echo ✅ Plugin: bin\x86\Release\BattlegroundsLogger.dll
echo ✅ Prebuilt: prebuilt\BattlegroundsLogger.dll
echo.
echo Next steps:
echo 1. Run INSTALL.bat (will use the prebuilt version)
echo 2. Enable plugin in HDT
echo 3. Test in Battlegrounds
echo.
echo Press any key to continue...
pause >nul
exit /b 0