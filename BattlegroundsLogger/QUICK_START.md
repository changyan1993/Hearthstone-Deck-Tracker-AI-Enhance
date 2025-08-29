# 🚀 QUICK START - Battlegrounds Logger

## 1-Minute Setup

### Step 1: Install (30 seconds)
1. **Right-click** → `INSTALL.bat` → **Run as administrator**
2. Wait for "INSTALLATION COMPLETE!"
3. Press any key when prompted

### Step 2: Enable in HDT (20 seconds)
1. Open **Hearthstone Deck Tracker**
2. Click **Options** → **Tracker** → **Plugins**
3. ✅ Check **"Battlegrounds Logger"**
4. Click **OK**

### Step 3: Play! (10 seconds)
1. Start a **Battlegrounds** game
2. Look for green indicator: "BG Logger: Recording" (top-left corner)
3. That's it! Files save automatically

---

## 📁 Where are my files?

```
Documents\BG-AI-Logs\
  └── BG-2024-01-15_14-30-00_abc12345\
      ├── turn_01.json
      ├── turn_02.json
      └── session_summary.json
```

---

## 🎯 Visual Indicators

| Color | Status | Meaning |
|-------|--------|---------|
| 🟢 Green (pulsing) | Recording | Actively logging game data |
| 🟡 Yellow | Ready | Waiting for Battlegrounds game |
| 🟠 Orange | Saving | Writing data to disk |
| 🔴 Red | Error | Check logs folder |
| ⚫ Gray | Idle | Plugin inactive |

---

## ⚙️ Optional: Change Save Location

1. In HDT: **Options** → **Tracker** → **Plugins**
2. Click **"Settings"** next to Battlegrounds Logger
3. Browse to your preferred folder
4. Click **Save**

---

## ❓ Troubleshooting

### HDT asks to update when starting?
This is **normal HDT behavior** - you have 3 options:
- **Click "Update"** → HDT updates itself (plugin usually still works)
- **Click "Skip"** → Keep current version (plugin works fine)  
- **Run `DISABLE_HDT_UPDATES.bat`** → Stop update prompts forever

### Plugin not showing up?
- Make sure you ran INSTALL.bat **as administrator**
- Restart HDT completely

### No files being created?
- Check the status indicator (top-left in game)
- Must be in **Battlegrounds** mode (not regular/arena)
- Check folder permissions for Documents\BG-AI-Logs

### After HDT updates?
- Run `HANDLE_HDT_UPDATE.bat` to check compatibility
- Most HDT updates don't break plugins
- If needed, run `UPDATE.bat` to rebuild

### Build failed during install?
- The installer will offer to use a pre-built version
- Or install Visual Studio Community (free) and try again

---

## 📝 What does it record?

✅ **Records:**
- Shop minions and their stats
- Your board composition
- Gold, health, tavern tier
- Available tribes
- Turn-by-turn snapshots

❌ **Does NOT:**
- Automate gameplay
- Make decisions for you
- Send data online
- Affect game performance

---

## 🆘 Need Help?

1. Check HDT logs: `%AppData%\HearthstoneDeckTracker\Logs\`
2. Verify installation: Plugin folder should contain `BattlegroundsLogger.dll`
3. Try reinstalling: Delete plugin folder and run INSTALL.bat again

---

**Remember:** This tool is for personal analysis only. Happy tracking! 🎮