@echo off
echo 🔍 HDT ↔ Hearthstone Connection Verification
echo ==========================================

echo.
echo 📋 Step 1: Check if both processes are running
echo -----------------------------------------------
tasklist /fi "imagename eq Hearthstone.exe" 2>nul | findstr /i "Hearthstone" && (
    echo ✅ Hearthstone process is running
) || (
    echo ❌ Hearthstone is NOT running
)

tasklist /fi "imagename eq HearthstoneDeckTracker.exe" 2>nul | findstr /i "HearthstoneDeckTracker" && (
    echo ✅ HDT process is running
) || (
    echo ❌ HDT is NOT running
)

echo.
echo 📁 Step 2: Check HDT logs directory
echo ------------------------------------
if exist "%APPDATA%\HearthstoneDeckTracker\Logs\*.log" (
    echo ✅ HDT logs directory found
    echo 📊 Recent log files:
    for /f %%i in ('dir /b /o-d "%APPDATA%\HearthstoneDeckTracker\Logs\*.log" 2^>nul') do (
        echo    📄 %%i
        goto :done_logs
    )
    :done_logs
) else (
    echo ❌ No HDT logs found
)

echo.
echo 📋 Step 3: Check recent HDT log for connection messages
echo --------------------------------------------------------
for /f %%i in ('dir /b /o-d "%APPDATA%\HearthstoneDeckTracker\Logs\*.log" 2^>nul') do (
    echo Checking latest log: %%i
    findstr /C:"Starting HDT LogWatcherManager" /C:"HEARTHSTONE PROCESS DETECTED" /C:"HDT successfully connected" "%APPDATA%\HearthstoneDeckTracker\Logs\%%i" 2>nul && (
        echo ✅ Found connection success messages in logs!
    ) || (
        echo ⚠️ No connection messages found in latest log
    )
    goto :done_check
)
:done_check

echo.
echo 💡 QUICK TEST: Navigate Hearthstone menus or enter Practice mode
echo    Then check HDT logs for new activity!
echo.
echo 📖 For detailed logs, check: %APPDATA%\HearthstoneDeckTracker\Logs\
pause