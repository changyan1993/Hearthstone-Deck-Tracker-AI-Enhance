# Battlegrounds Logger Plugin for HDT

## Description

A read-only Hearthstone Deck Tracker plugin that records Battlegrounds game state to JSON files for analysis and personal use.

## Disclaimer

**This plugin records Battlegrounds state locally for analysis and personal use only. It does not automate gameplay.**

This plugin:
- ✅ Reads game state information
- ✅ Saves data locally to your computer
- ✅ Helps with post-game analysis
- ❌ Does NOT automate any gameplay
- ❌ Does NOT make decisions for you
- ❌ Does NOT interact with the game client
- ❌ Does NOT send data over the network

## Features

- Records one JSON snapshot per shop phase turn during Battlegrounds games
- Saves data permanently for later analysis and training
- Configurable output directory
- Atomic file writes to prevent corruption
- Session summary with metadata and error tracking

## Installation

### 🚀 Ultimate Setup (Recommended)
```bash
1. Right-click ULTIMATE_SETUP.bat → Run as administrator
2. Follow the prompts (fully automated)
3. Done! HDT and plugin auto-update forever
```

### 🔧 Manual Setup
```bash
1. Right-click INSTALL.bat → Run as administrator  
2. Enable plugin in HDT: Options → Tracker → Plugins
3. Optional: Run ENABLE_AUTO_UPDATES.bat for auto-sync
```

## Configuration

Click the "Settings" button in the HDT plugins menu to configure:
- **Output Directory**: Where to save the JSON files (default: `Documents\BG-AI-Logs`)
- **Enable Logging**: Toggle logging on/off
- **Verbose Logging**: Enable detailed debug logging
- **Max Sessions**: Number of sessions to keep (0 = unlimited)

## Output Format

### Directory Structure
```
BG-AI-Logs/
├── BG-2024-01-15_14-30-00_abc12345/
│   ├── turn_01.json
│   ├── turn_02.json
│   ├── ...
│   └── session_summary.json
```

### JSON Schema

Each turn snapshot includes:
- Basic info: turn, phase, timestamp, session ID
- Player state: health, armor, gold, tavern tier
- Heroes: player and opponent hero information
- Economy: reroll cost, freeze state, triples
- Shop minions: ordered list with stats and keywords
- Board minions: ordered list with stats and keywords
- Available tribes in the game

## Requirements

- Hearthstone Deck Tracker 1.20.0 or higher
- .NET Framework 4.7.2 or higher
- Windows 10/11

## Building from Source

1. Clone this repository
2. Open `BattlegroundsLogger.csproj` in Visual Studio
3. Restore NuGet packages
4. Build in Release mode
5. Copy the output DLL to your HDT Plugins folder

## License

This plugin is for personal use only. Recording game state is intended solely for analysis and learning purposes.

## Support

This plugin is provided as-is for personal use. No support is guaranteed.

## Privacy

- All data is stored locally on your computer
- No data is transmitted over the network
- No personal information is collected beyond game state