@echo off
cd /d "%~dp0"

echo Building plugin with MSBuild...
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" BattlegroundsLogger.csproj /p:Configuration=Release /p:Platform=x86 /v:minimal

if %errorLevel% EQU 0 (
    echo Build successful!
    if exist "bin\x86\Release\BattlegroundsLogger.dll" (
        echo Plugin DLL created successfully.
        
        REM Install the plugin
        set PLUGIN_DIR=%APPDATA%\HearthstoneDeckTracker\Plugins\BattlegroundsLogger
        if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"
        copy "bin\x86\Release\BattlegroundsLogger.dll" "%PLUGIN_DIR%\" >nul 2>&1
        echo Plugin installed to HDT.
        echo.
        echo SUCCESS! Plugin is ready to use in HDT.
        echo Enable it in HDT: Options -> Tracker -> Plugins
    ) else (
        echo ERROR: Plugin DLL was not created
    )
) else (
    echo Build failed with error level %errorLevel%
)

pause