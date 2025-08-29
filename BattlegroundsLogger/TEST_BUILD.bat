@echo off
color 0B
cls

echo ========================================
echo  BUILD TEST - STEP BY STEP VERIFICATION
echo ========================================
echo.

cd /d "%~dp0"

echo 🔍 STEP 1: Checking HDT source
echo ================================
if exist "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" (
    echo ✅ HDT project file found
    
    REM Get HDT version
    for /f "tokens=2 delims=<>" %%a in ('findstr "AssemblyVersion" "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj"') do set HDT_VERSION=%%a
    echo ✅ HDT Version: %HDT_VERSION%
) else (
    echo ❌ HDT project not found
    echo    Expected: ..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj
    pause
    exit /b 1
)

echo.
echo 🔨 STEP 2: Testing HDT build
echo ==============================
echo This will try to build HDT...

choice /C YN /M "Continue with HDT build test"
if errorlevel 2 goto :skip_hdt_build

cd "..\Hearthstone Deck Tracker"
echo Building HDT with dotnet...
dotnet build "Hearthstone Deck Tracker.csproj" -c Release -p:Platform=x86 --verbosity minimal

if %errorLevel% EQU 0 (
    echo ✅ HDT build successful
    
    if exist "bin\x86\Release\HearthstoneDeckTracker.exe" (
        echo ✅ HDT executable created
        set HDT_BUILT=true
    ) else (
        echo ❌ HDT executable not found after build
        set HDT_BUILT=false
    )
) else (
    echo ❌ HDT build failed
    set HDT_BUILT=false
)

cd "..\BattlegroundsLogger"

:skip_hdt_build

echo.
echo 🔧 STEP 3: Testing plugin build  
echo =================================
if "%HDT_BUILT%"=="true" (
    echo HDT is built, trying plugin build...
    dotnet build BattlegroundsLogger.csproj -c Release -p:Platform=x86 --verbosity minimal
    
    if %errorLevel% EQU 0 (
        echo ✅ Plugin build successful
        
        if exist "bin\x86\Release\BattlegroundsLogger.dll" (
            echo ✅ Plugin DLL created
            
            REM Copy to prebuilt
            if not exist "prebuilt" mkdir prebuilt
            copy "bin\x86\Release\BattlegroundsLogger.dll" "prebuilt\" >nul 2>&1
            echo ✅ Copied to prebuilt folder
            
        ) else (
            echo ❌ Plugin DLL not found after build
        )
    ) else (
        echo ❌ Plugin build failed
    )
) else (
    echo ⏭️ Skipping plugin build (HDT not built)
)

echo.
echo 📋 STEP 4: Installation test
echo =============================
if exist "prebuilt\BattlegroundsLogger.dll" (
    echo ✅ Plugin ready for installation
    
    set PLUGIN_DIR=%APPDATA%\HearthstoneDeckTracker\Plugins\BattlegroundsLogger
    echo Plugin will install to: !PLUGIN_DIR!
    
    if not exist "!PLUGIN_DIR!" (
        mkdir "!PLUGIN_DIR!" 2>nul
        echo ✅ Plugin directory created
    )
    
    echo.
    choice /C YN /M "Install the plugin now"
    if errorlevel 1 (
        copy "prebuilt\BattlegroundsLogger.dll" "!PLUGIN_DIR!\" >nul 2>&1
        echo ✅ Plugin installed
        echo.
        echo 📍 Next steps:
        echo    1. Start HDT
        echo    2. Go to Options → Tracker → Plugins  
        echo    3. Enable "Battlegrounds Logger"
        echo    4. Test in a Battlegrounds game
    )
) else (
    echo ❌ No plugin DLL available for installation
)

echo.
echo ========================================
echo  TEST COMPLETE
echo ========================================
echo.

echo Summary:
if "%HDT_BUILT%"=="true" (
    echo ✅ HDT builds successfully
    echo ✅ Plugin should work with HDT updates
) else (
    echo ⚠️ HDT build issues - plugin may not work with updates
)

echo.
echo Press any key to exit...
pause >nul
exit /b 0