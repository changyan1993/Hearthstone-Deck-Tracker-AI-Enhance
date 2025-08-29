@echo off
setlocal EnableDelayedExpansion
color 0A
cls

echo ========================================
echo  BATTLEGROUNDS LOGGER - AUTO INSTALLER
echo ========================================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [!] This installer needs to run as Administrator
    echo     Right-click INSTALL.bat and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [1/5] Checking Hearthstone Deck Tracker installation...

REM Find HDT installation
set HDT_PLUGIN_DIR=%APPDATA%\HearthstoneDeckTracker\Plugins
if not exist "%HDT_PLUGIN_DIR%" (
    echo [X] HDT plugins folder not found!
    echo     Please install Hearthstone Deck Tracker first
    echo     Download from: https://hsreplay.net/downloads/
    echo.
    pause
    exit /b 1
)
echo [OK] Found HDT plugins folder

echo.
echo [2/5] Checking for existing installation...

set PLUGIN_INSTALL_DIR=%HDT_PLUGIN_DIR%\BattlegroundsLogger
if exist "%PLUGIN_INSTALL_DIR%\BattlegroundsLogger.dll" (
    echo [!] Previous version found
    choice /C YN /M "Remove old version and continue"
    if !errorlevel! EQU 2 (
        echo Installation cancelled.
        pause
        exit /b 0
    )
    echo Removing old version...
    rmdir /S /Q "%PLUGIN_INSTALL_DIR%" 2>nul
)

echo.
echo [3/5] Creating plugin directory...

mkdir "%PLUGIN_INSTALL_DIR%" 2>nul
if %errorLevel% NEQ 0 (
    echo [X] Failed to create plugin directory
    pause
    exit /b 1
)
echo [OK] Created: %PLUGIN_INSTALL_DIR%

echo.
echo [4/5] Building plugin (this may take a moment)...

REM Try to find MSBuild
set MSBUILD=
set BUILD_TOOL=

REM Check for .NET SDK first (simpler)
where dotnet >nul 2>&1
if %errorLevel% EQU 0 (
    set BUILD_TOOL=dotnet
    echo [OK] Found .NET SDK
    goto :build
)

REM Check for MSBuild in VS 2022
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    set BUILD_TOOL=msbuild
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    set BUILD_TOOL=msbuild
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    set BUILD_TOOL=msbuild
)

if "%BUILD_TOOL%"=="" (
    echo [!] No build tools found
    echo.
    echo Do you want to use a pre-built version instead?
    choice /C YN /M "Use pre-built plugin"
    if !errorlevel! EQU 1 (
        goto :use_prebuilt
    ) else (
        echo.
        echo Please install one of the following:
        echo - .NET SDK: https://dotnet.microsoft.com/download
        echo - Visual Studio: https://visualstudio.microsoft.com/
        pause
        exit /b 1
    )
)

:build
if "%BUILD_TOOL%"=="dotnet" (
    echo Building with .NET SDK...
    dotnet build BattlegroundsLogger.csproj -c Release -p:Platform=x86 >build.log 2>&1
) else (
    echo Building with MSBuild...
    "%MSBUILD%" BattlegroundsLogger.csproj /p:Configuration=Release /p:Platform=x86 /v:quiet >build.log 2>&1
)

if %errorLevel% NEQ 0 (
    echo [X] Build failed! Check build.log for details
    echo.
    echo Do you want to use a pre-built version instead?
    choice /C YN /M "Use pre-built plugin"
    if !errorlevel! EQU 1 (
        goto :use_prebuilt
    ) else (
        pause
        exit /b 1
    )
)

if not exist "bin\x86\Release\BattlegroundsLogger.dll" (
    echo [X] Build succeeded but DLL not found
    goto :use_prebuilt
)

echo [OK] Build successful

REM Copy the built DLL
copy "bin\x86\Release\BattlegroundsLogger.dll" "%PLUGIN_INSTALL_DIR%\" >nul 2>&1
goto :configure

:use_prebuilt
echo.
echo [4/5] Installing pre-built version...

REM Check if prebuilt exists
if exist "prebuilt\BattlegroundsLogger.dll" (
    copy "prebuilt\BattlegroundsLogger.dll" "%PLUGIN_INSTALL_DIR%\" >nul 2>&1
    echo [OK] Pre-built version installed
) else (
    echo [X] Pre-built DLL not found
    echo     Please build the plugin manually or download a release
    pause
    exit /b 1
)

:configure
echo.
echo [5/5] Creating default configuration...

REM Create default config
set CONFIG_FILE=%PLUGIN_INSTALL_DIR%\config.json
(
echo {
echo   "OutputDirectory": "%USERPROFILE%\\Documents\\BG-AI-Logs",
echo   "EnableLogging": true,
echo   "VerboseLogging": false,
echo   "MaxSessionsToKeep": 0
echo }
) > "%CONFIG_FILE%"

REM Create output directory
set OUTPUT_DIR=%USERPROFILE%\Documents\BG-AI-Logs
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%" 2>nul
    echo [OK] Created output directory: %OUTPUT_DIR%
)

echo.
echo ========================================
echo  INSTALLATION COMPLETE!
echo ========================================
echo.
echo Next steps:
echo 1. Start Hearthstone Deck Tracker
echo 2. Go to: Options -^> Tracker -^> Plugins
echo 3. Enable "Battlegrounds Logger"
echo 4. Start a Battlegrounds game
echo.
echo JSON files will be saved to:
echo %OUTPUT_DIR%
echo.
echo Press any key to open HDT Plugins folder...
pause >nul
explorer "%HDT_PLUGIN_DIR%"
exit /b 0