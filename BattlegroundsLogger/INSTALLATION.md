# Installation Instructions for BattlegroundsLogger Plugin

## Prerequisites

1. **Hearthstone Deck Tracker** installed and working
2. **Visual Studio** or **MSBuild** (for compilation)
   - Download Visual Studio Community (free): https://visualstudio.microsoft.com/

## Building the Plugin

### Option 1: Using the build script (Recommended)
1. Open Windows Explorer
2. Navigate to: `C:\Program Files (x86)\AI_Stone\Hearthstone-Deck-Tracker\BattlegroundsLogger`
3. Double-click `build.bat`
4. If successful, the DLL will be in `bin\Release\BattlegroundsLogger.dll`

### Option 2: Using Visual Studio
1. Open Visual Studio
2. Open the project file: `BattlegroundsLogger.csproj`
3. Set configuration to "Release"
4. Build → Build Solution (or press Ctrl+Shift+B)
5. The DLL will be in `bin\Release\BattlegroundsLogger.dll`

## Installing the Plugin

1. **Locate the plugin DLL:**
   - After building: `C:\Program Files (x86)\AI_Stone\Hearthstone-Deck-Tracker\BattlegroundsLogger\bin\Release\BattlegroundsLogger.dll`

2. **Copy to HDT Plugins folder:**
   - Open Windows Explorer
   - Navigate to: `%AppData%\HearthstoneDeckTracker\Plugins\`
   - Create a folder named `BattlegroundsLogger`
   - Copy `BattlegroundsLogger.dll` into this folder

3. **Enable in HDT:**
   - Start Hearthstone Deck Tracker
   - Go to Options → Tracker → Plugins
   - Find "Battlegrounds Logger" in the list
   - Check the box to enable it
   - Click "Settings" to configure the output directory

## Verifying Installation

1. Start a Battlegrounds game
2. Check the output directory (default: `Documents\BG-AI-Logs`)
3. After a few turns, you should see a folder with JSON files

## Troubleshooting

### Plugin doesn't appear in HDT
- Make sure the DLL is in the correct folder
- Restart HDT completely
- Check HDT logs for errors

### No files are being created
- Check the plugin is enabled in HDT settings
- Verify the output directory exists and is writable
- Check HDT logs at: `%AppData%\HearthstoneDeckTracker\Logs\`

### Build fails
- Ensure Visual Studio or MSBuild is installed
- Check that HDT is installed in the expected location
- Verify all reference DLLs exist in the HDT installation