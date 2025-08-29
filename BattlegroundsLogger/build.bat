@echo off
echo Building BattlegroundsLogger plugin...

REM Try to find MSBuild in various common locations
set MSBUILD=
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
) else if exist "%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe"
)

if "%MSBUILD%"=="" (
    echo ERROR: MSBuild not found. Please install Visual Studio or Build Tools.
    echo You can download Visual Studio Community from: https://visualstudio.microsoft.com/
    pause
    exit /b 1
)

echo Found MSBuild at: %MSBUILD%
echo.

"%MSBUILD%" BattlegroundsLogger.csproj /p:Configuration=Release /p:Platform=x86 /v:minimal

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Build successful!
echo.
echo The plugin DLL is located at: bin\x86\Release\BattlegroundsLogger.dll
echo.
echo To install:
echo 1. Copy BattlegroundsLogger.dll to %%AppData%%\HearthstoneDeckTracker\Plugins\
echo 2. Restart Hearthstone Deck Tracker
echo 3. Enable the plugin in Options -^> Tracker -^> Plugins
echo.
pause