PREBUILT BINARY PLACEHOLDER
===========================

This folder should contain a pre-compiled BattlegroundsLogger.dll for users who don't have build tools installed.

To create the prebuilt DLL:
1. Build the project in Release mode using Visual Studio
2. Copy bin\Release\BattlegroundsLogger.dll to this folder
3. The INSTALL.bat script will automatically use it if building fails

The prebuilt DLL allows users to install the plugin without needing:
- Visual Studio
- .NET SDK
- MSBuild

This makes the plugin accessible to all users regardless of their development environment.