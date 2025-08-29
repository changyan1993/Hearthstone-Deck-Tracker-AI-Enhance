@echo off
color 0E
cls

echo ========================================
echo  SCRIPT AUDIT - WHAT DO I HAVE?
echo ========================================
echo.

cd /d "%~dp0"

echo Here are all the scripts I created for you:
echo.

echo 📋 ESSENTIAL SCRIPTS (what you actually need):
echo ===============================================
if exist "BUILD_EVERYTHING.bat" echo ✅ BUILD_EVERYTHING.bat    - Builds HDT then plugin ^(USE THIS FIRST^)
if exist "INSTALL.bat" echo ✅ INSTALL.bat             - Installs the plugin to HDT
if exist "STATUS.bat" echo ✅ STATUS.bat              - Shows if everything is working

echo.
echo 🔧 UTILITY SCRIPTS (helpful but optional):
echo =============================================
if exist "CHECK_COMPATIBILITY.bat" echo ⚙️  CHECK_COMPATIBILITY.bat - Verifies your HDT version
if exist "UPDATE.bat" echo ⚙️  UPDATE.bat             - Updates plugin after code changes

echo.
echo 🤯 TOO MANY SCRIPTS (confusing - ignore these):
echo =================================================
if exist "ULTIMATE_SETUP.bat" echo 😵 ULTIMATE_SETUP.bat     - Over-complicated
if exist "ENABLE_AUTO_UPDATES.bat" echo 😵 ENABLE_AUTO_UPDATES.bat - Complex auto-update system
if exist "SETUP_HDT_INTEGRATION.bat" echo 😵 SETUP_HDT_INTEGRATION.bat - Windows task scheduler stuff
if exist "SMART_REBUILD.bat" echo 😵 SMART_REBUILD.bat      - Automatic rebuilding
if exist "SIMPLE_SETUP.bat" echo 😵 SIMPLE_SETUP.bat       - Debug version
if exist "RUN_SETUP.bat" echo 😵 RUN_SETUP.bat          - Another launcher
if exist "QUICK_INSTALL.bat" echo 😵 QUICK_INSTALL.bat      - Minimal install attempt

echo.
echo 📚 DOCUMENTATION (read these):
echo ================================
if exist "README.md" echo 📖 README.md              - Main documentation
if exist "QUICK_START.md" echo 📖 QUICK_START.md         - Simple usage guide
if exist "LOCAL_UPDATE_GUIDE.md" echo 📖 LOCAL_UPDATE_GUIDE.md  - Update instructions

echo.
echo ========================================
echo  SIMPLIFIED RECOMMENDATION
echo ========================================
echo.
echo For a working plugin right now:
echo.
echo 1️⃣  Right-click BUILD_EVERYTHING.bat → Run as admin
echo     ^(This builds HDT first, then the plugin^)
echo.
echo 2️⃣  Right-click INSTALL.bat → Run as admin  
echo     ^(This installs the built plugin^)
echo.
echo 3️⃣  Start HDT → Enable plugin in settings
echo     ^(Options → Tracker → Plugins^)
echo.
echo 4️⃣  Test in Battlegrounds game
echo     ^(Look for green status indicator^)
echo.
echo ❓ If you want HDT to auto-update:
echo    Just let HDT update normally when it asks
echo    If plugin stops working, run UPDATE.bat
echo.
echo Press any key to continue...
pause >nul

echo.
echo 🧹 WANT TO CLEAN UP THE MESS?
echo ==============================
echo.
choice /C YN /M "Delete the confusing/unnecessary scripts"

if errorlevel 2 goto :keep_all
if errorlevel 1 goto :cleanup

:cleanup
echo.
echo Deleting unnecessary scripts...

del "ULTIMATE_SETUP.bat" 2>nul && echo ✅ Deleted ULTIMATE_SETUP.bat
del "ENABLE_AUTO_UPDATES.bat" 2>nul && echo ✅ Deleted ENABLE_AUTO_UPDATES.bat  
del "SETUP_HDT_INTEGRATION.bat" 2>nul && echo ✅ Deleted SETUP_HDT_INTEGRATION.bat
del "SMART_REBUILD.bat" 2>nul && echo ✅ Deleted SMART_REBUILD.bat
del "SIMPLE_SETUP.bat" 2>nul && echo ✅ Deleted SIMPLE_SETUP.bat
del "RUN_SETUP.bat" 2>nul && echo ✅ Deleted RUN_SETUP.bat
del "QUICK_INSTALL.bat" 2>nul && echo ✅ Deleted QUICK_INSTALL.bat
del "DISABLE_HDT_UPDATES.bat" 2>nul && echo ✅ Deleted DISABLE_HDT_UPDATES.bat
del "HANDLE_HDT_UPDATE.bat" 2>nul && echo ✅ Deleted HANDLE_HDT_UPDATE.bat

echo.
echo 🎉 Cleanup complete! You now have only the essential scripts:
echo    • BUILD_EVERYTHING.bat
echo    • INSTALL.bat  
echo    • STATUS.bat
echo    • CHECK_COMPATIBILITY.bat
echo    • UPDATE.bat
echo.
goto :end

:keep_all
echo.
echo Keeping all scripts. You can manually delete the ones you don't need.
echo.

:end
echo Press any key to exit...
pause >nul
exit /b 0