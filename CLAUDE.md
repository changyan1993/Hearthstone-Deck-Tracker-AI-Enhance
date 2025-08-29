# Hearthstone Deck Tracker - Quick Start Guide

## How to Run the Application

### Option 1: Windows Explorer (Easiest)
1. Open Windows Explorer
2. Navigate to: `C:\Program Files (x86)\AI_Stone\Hearthstone-Deck-Tracker\Hearthstone Deck Tracker\bin\x86\Debug\`
3. Double-click `HearthstoneDeckTracker.exe`

### Option 2: From Command Line
```bash
cd "C:\Program Files (x86)\AI_Stone\Hearthstone-Deck-Tracker\Hearthstone Deck Tracker\bin\x86\Debug"
HearthstoneDeckTracker.exe
```

### Option 3: From Visual Studio
1. Open `C:\Program Files (x86)\AI_Stone\Hearthstone-Deck-Tracker\Hearthstone Deck Tracker.sln` in Visual Studio 2022
2. Press F5 to run with debugging

## Important Notes
- **Run Hearthstone first** before starting the tracker
- The tracker will overlay on top of your Hearthstone game window
- On first run, it may ask for permissions or configuration
- The app tracks your deck, shows cards remaining, and monitors opponent's plays

## Build Instructions (If Needed)
If you need to rebuild the project:

1. Open PowerShell as Administrator
2. Navigate to project directory:
   ```powershell
   cd "C:\Program Files (x86)\AI_Stone\Hearthstone-Deck-Tracker"
   ```
3. Restore packages:
   ```powershell
   .\nuget.exe restore "Hearthstone Deck Tracker.sln"
   ```
4. Build with MSBuild:
   ```powershell
   "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "Hearthstone Deck Tracker.sln" /p:Configuration=Debug /p:Platform=x86
   ```

## System Requirements
- Windows Vista or higher ✓
- .NET Framework 4.5+ ✓ (You have 4.8)
- Visual Studio 2022 Community ✓ (For development only)

## Troubleshooting
- If the overlay doesn't appear, check if Hearthstone is running in fullscreen mode (try windowed mode)
- Run as Administrator if you encounter permission issues
- Check Windows Defender/Antivirus exceptions if the app is blocked

## Project Structure
- Main executable: `HearthstoneDeckTracker.exe`
- Configuration: `HearthstoneDeckTracker.exe.config`
- Dependencies: All DLL files in the same directory

Last built: August 28, 2025