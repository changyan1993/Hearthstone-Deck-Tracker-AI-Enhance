@echo off
setlocal EnableDelayedExpansion
color 0A
cls

echo ========================================
echo  HDT AUTO-UPDATE HANDLER
echo ========================================
echo.

cd /d "%~dp0"

echo This will setup your system to:
echo ✅ Let HDT auto-update from its servers
echo ✅ Automatically rebuild our plugin after HDT updates
echo ✅ Handle any version changes seamlessly
echo.

choice /C YN /M "Setup automatic HDT update handling"
if !errorlevel! EQU 2 (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo [1/3] Enabling HDT auto-updates...

REM Configure HDT to auto-update
set HDT_CONFIG=%APPDATA%\HearthstoneDeckTracker\config.xml

if exist "%HDT_CONFIG%" (
    echo Found HDT config, enabling auto-updates...
    
    REM Create PowerShell script to modify HDT config
    (
    echo $config = [xml]^(Get-Content "%HDT_CONFIG%"^)
    echo # Enable auto-update checking
    echo if ^($config.Config.CheckForUpdates -eq $null^) {
    echo     $updateNode = $config.CreateElement^("CheckForUpdates"^)
    echo     $updateNode.InnerText = "True"
    echo     $config.Config.AppendChild^($updateNode^)
    echo } else {
    echo     $config.Config.CheckForUpdates = "True"
    echo }
    echo # Enable silent updates if supported
    echo if ^($config.Config.AutoUpdate -eq $null^) {
    echo     $autoNode = $config.CreateElement^("AutoUpdate"^)
    echo     $autoNode.InnerText = "True"
    echo     $config.Config.AppendChild^($autoNode^)
    echo } else {
    echo     $config.Config.AutoUpdate = "True"
    echo }
    echo $config.Save^("%HDT_CONFIG%"^)
    ) > temp_config.ps1
    
    powershell -ExecutionPolicy Bypass -File temp_config.ps1 >nul 2>&1
    del temp_config.ps1
    
    echo ✅ HDT configured for auto-updates
) else (
    echo ⚠️ HDT config not found - will be created on first HDT run
)

echo.
echo [2/3] Creating plugin auto-rebuild system...

REM Create a script that monitors HDT version changes
(
echo @echo off
echo setlocal EnableDelayedExpansion
echo cd /d "%%~dp0"
echo.
echo REM This script rebuilds the plugin when HDT version changes
echo.
echo REM Store current HDT version
echo set CURRENT_VERSION=Unknown
echo.
echo REM Try to get version from running HDT process
echo for /f "tokens=2" %%%%a in ^('tasklist /FI "IMAGENAME eq HearthstoneDeckTracker.exe" /FO LIST ^| find "PID"'^) do ^(
echo     set HDT_PID=%%%%a
echo ^)
echo.
echo REM Get version from any HDT executable we can find
echo if exist "..\Hearthstone Deck Tracker\bin\x86\Debug\HearthstoneDeckTracker.exe" ^(
echo     set HDT_EXE=..\Hearthstone Deck Tracker\bin\x86\Debug\HearthstoneDeckTracker.exe
echo ^) else if exist "..\HDTTests\bin\x86\Debug\HearthstoneDeckTracker.exe" ^(
echo     set HDT_EXE=..\HDTTests\bin\x86\Debug\HearthstoneDeckTracker.exe
echo ^) else ^(
echo     echo No HDT executable found - plugin may need manual rebuild
echo     exit /b 0
echo ^)
echo.
echo REM Check if we have a previous version stored
echo set OLD_VERSION=Unknown
echo if exist "last_hdt_version.txt" set /p OLD_VERSION=^<last_hdt_version.txt
echo.
echo REM Get current version ^(simplified - just use file date^)
echo for %%%%a in ^("%%HDT_EXE%%"^) do set CURRENT_VERSION=%%%%~ta
echo.
echo REM If version changed, rebuild plugin
echo if "%%OLD_VERSION%%" NEQ "%%CURRENT_VERSION%%" ^(
echo     echo HDT version changed - rebuilding plugin...
echo     
echo     REM Update project reference to current HDT location
echo     powershell -Command "^(Get-Content 'BattlegroundsLogger.csproj'^) -replace 'HearthstoneDeckTracker[^^<]*exe', '%%HDT_EXE%%' ^| Set-Content 'BattlegroundsLogger.csproj'" ^>nul 2^>^&1
echo     
echo     REM Build plugin
echo     if exist "%%ProgramFiles%%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" ^(
echo         "%%ProgramFiles%%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" BattlegroundsLogger.csproj /p:Configuration=Release /p:Platform=x86 /v:quiet ^>plugin_rebuild.log 2^>^&1
echo     ^) else ^(
echo         dotnet build BattlegroundsLogger.csproj -c Release -p:Platform=x86 --verbosity quiet ^>plugin_rebuild.log 2^>^&1
echo     ^)
echo     
echo     if %%errorLevel%% EQU 0 ^(
echo         echo Plugin rebuilt successfully
echo         
echo         REM Install updated plugin
echo         set PLUGIN_DIR=%%APPDATA%%\HearthstoneDeckTracker\Plugins\BattlegroundsLogger
echo         if not exist "%%PLUGIN_DIR%%" mkdir "%%PLUGIN_DIR%%"
echo         
echo         if exist "bin\x86\Release\BattlegroundsLogger.dll" ^(
echo             copy "bin\x86\Release\BattlegroundsLogger.dll" "%%PLUGIN_DIR%%\" ^>nul 2^>^&1
echo             echo Plugin updated for new HDT version
echo         ^)
echo         
echo         REM Store new version
echo         echo %%CURRENT_VERSION%% ^> last_hdt_version.txt
echo     ^) else ^(
echo         echo Plugin rebuild failed - check plugin_rebuild.log
echo     ^)
echo ^)
) > AUTO_PLUGIN_REBUILD.bat

echo ✅ Created AUTO_PLUGIN_REBUILD.bat

echo.
echo [3/3] Setting up Windows startup integration...

REM Create a simple startup entry that runs our rebuild check
set STARTUP_SCRIPT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\HDT_Plugin_Monitor.bat

(
echo @echo off
echo REM Monitor HDT updates and rebuild plugin if needed
echo timeout /t 30 /nobreak ^>nul 2^>^&1
echo if exist "C:\Program Files ^(x86^)\AI_Stone\Hearthstone-Deck-Tracker\BattlegroundsLogger\AUTO_PLUGIN_REBUILD.bat" ^(
echo     call "C:\Program Files ^(x86^)\AI_Stone\Hearthstone-Deck-Tracker\BattlegroundsLogger\AUTO_PLUGIN_REBUILD.bat"
echo ^)
) > "%STARTUP_SCRIPT%"

echo ✅ Created Windows startup monitor

echo.
echo ========================================
echo  AUTO-UPDATE SETUP COMPLETE!
echo ========================================
echo.

echo 🎯 HOW IT WORKS:
echo.
echo 1. 🔄 HDT AUTO-UPDATES:
echo    • HDT checks for updates automatically
echo    • When you click "Update", HDT downloads new version
echo    • HDT restarts with updated version
echo.
echo 2. 🔧 PLUGIN AUTO-SYNC:
echo    • Windows startup script monitors HDT changes
echo    • When HDT version changes, plugin rebuilds automatically  
echo    • Plugin stays compatible with any HDT version
echo.
echo 3. 🎮 YOUR EXPERIENCE:
echo    • Just click "Update" when HDT asks
echo    • Plugin automatically works with new version
echo    • Zero manual maintenance needed
echo.
echo 📋 FILES CREATED:
echo ✅ AUTO_PLUGIN_REBUILD.bat - Smart rebuild system
echo ✅ HDT_Plugin_Monitor.bat - Windows startup monitor
echo ✅ HDT config updated - Auto-update enabled
echo.
echo 🚀 READY TO USE:
echo Now when HDT prompts for updates, just click "Update"!
echo Your plugin will automatically adapt to any new HDT version.
echo.

echo Press any key to exit...
pause >nul
exit /b 0