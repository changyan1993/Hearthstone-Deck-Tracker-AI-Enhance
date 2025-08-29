@echo off
setlocal EnableDelayedExpansion
color 0E
cls

echo ========================================
echo  HDT COMPATIBILITY CHECKER
echo ========================================
echo.

echo [1/5] Checking HDT Installation...

REM Check HDT folder
if not exist "..\Hearthstone Deck Tracker" (
    echo [X] HDT source folder not found
    echo     Expected: ..\Hearthstone Deck Tracker
    goto :error
)
echo [OK] HDT source folder found

REM Check HDT project file
if not exist "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" (
    echo [X] HDT project file not found
    goto :error
)
echo [OK] HDT project file found

echo.
echo [2/5] Reading HDT Version Information...

REM Extract version info
set HDT_VERSION=Unknown
set HDT_FRAMEWORK=Unknown
set HDT_PLATFORM=Unknown

for /f "tokens=2 delims=<>" %%a in ('findstr "AssemblyVersion" "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" 2^>nul') do set HDT_VERSION=%%a
for /f "tokens=2 delims=<>" %%a in ('findstr "TargetFramework" "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" 2^>nul') do set HDT_FRAMEWORK=%%a
for /f "tokens=2 delims=<>" %%a in ('findstr "PlatformTarget" "..\Hearthstone Deck Tracker\Hearthstone Deck Tracker.csproj" 2^>nul') do set HDT_PLATFORM=%%a

echo HDT Version:      !HDT_VERSION!
echo Target Framework: !HDT_FRAMEWORK!
echo Platform Target:  !HDT_PLATFORM!

echo.
echo [3/5] Checking Dependencies...

REM Check lib folder
if not exist "..\lib" (
    echo [!] Lib folder not found at ..\lib
    set LIB_STATUS=Missing
) else (
    echo [OK] Lib folder found
    set LIB_STATUS=OK
)

REM Check specific DLLs
set HEARTHDB_STATUS=Missing
set NEWTONSOFT_STATUS=Missing
set HEARTHMIRROR_STATUS=Missing

if exist "..\lib\HearthDb.dll" set HEARTHDB_STATUS=OK
if exist "..\lib\Newtonsoft.Json.dll" set NEWTONSOFT_STATUS=OK
if exist "..\lib\HearthMirror.dll" set HEARTHMIRROR_STATUS=OK

echo - HearthDb.dll:     !HEARTHDB_STATUS!
echo - Newtonsoft.Json:  !NEWTONSOFT_STATUS!
echo - HearthMirror.dll: !HEARTHMIRROR_STATUS!

echo.
echo [4/5] Checking HDT Build Output...

set HDT_EXE_PATH=..\Hearthstone Deck Tracker\bin\!HDT_PLATFORM!\Release\HearthstoneDeckTracker.exe
if exist "!HDT_EXE_PATH!" (
    echo [OK] HDT executable found: !HDT_EXE_PATH!
    set HDT_BUILD_STATUS=OK
) else (
    echo [!] HDT executable not found at: !HDT_EXE_PATH!
    REM Check alternative locations
    if exist "..\Hearthstone Deck Tracker\HearthstoneDeckTracker.exe" (
        echo [OK] Found HDT exe in alternative location
        set HDT_BUILD_STATUS=Alternative
    ) else (
        echo [X] HDT executable not found anywhere
        set HDT_BUILD_STATUS=Missing
    )
)

echo.
echo [5/5] Plugin Compatibility Assessment...

echo.
echo ========================================
echo  COMPATIBILITY REPORT
echo ========================================

REM Overall assessment
set COMPATIBLE=true
set WARNINGS=0
set ERRORS=0

if "!HDT_VERSION!"=="Unknown" (
    echo [X] ERROR: Cannot determine HDT version
    set COMPATIBLE=false
    set /a ERRORS+=1
)

if "!HDT_FRAMEWORK!" NEQ "net472" (
    echo [!] WARNING: Expected .NET 4.7.2, found: !HDT_FRAMEWORK!
    set /a WARNINGS+=1
)

if "!HDT_PLATFORM!" NEQ "x86" (
    echo [!] WARNING: Expected x86 platform, found: !HDT_PLATFORM!
    set /a WARNINGS+=1
)

if "!HEARTHDB_STATUS!"=="Missing" (
    echo [X] ERROR: HearthDb.dll not found
    set COMPATIBLE=false
    set /a ERRORS+=1
)

if "!NEWTONSOFT_STATUS!"=="Missing" (
    echo [X] ERROR: Newtonsoft.Json.dll not found
    set COMPATIBLE=false
    set /a ERRORS+=1
)

if "!HDT_BUILD_STATUS!"=="Missing" (
    echo [X] ERROR: HDT not built
    set COMPATIBLE=false
    set /a ERRORS+=1
)

echo.
if "!COMPATIBLE!"=="true" (
    echo [OK] ✅ PLUGIN COMPATIBLE WITH HDT !HDT_VERSION!
    echo.
    echo Recommendations:
    echo - Run INSTALL.bat to install/update
    echo - Run UPDATE.bat to update existing installation
) else (
    echo [X] ❌ COMPATIBILITY ISSUES FOUND
    echo.
    echo Errors: !ERRORS!
    echo Warnings: !WARNINGS!
    echo.
    echo Please fix the errors above before installing the plugin
)

echo.
echo Press any key to exit...
pause >nul
exit /b 0

:error
echo [X] Critical error - cannot continue
pause
exit /b 1