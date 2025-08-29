# 🔄 Local HDT Plugin Update Guide

## ✅ Updated for Your HDT Version

**Your HDT Setup:**
- Version: **1.46.11**
- Framework: **.NET 4.7.2**
- Platform: **x86**
- Status: ✅ **Compatible**

## 🛠️ Available Scripts

### 1. **CHECK_COMPATIBILITY.bat** 
   - Verifies your HDT version and dependencies
   - Checks if plugin will work with your setup
   - **Run this first** before any installation

### 2. **INSTALL.bat** (Updated)
   - Auto-detects your HDT version
   - Builds plugin for x86 platform
   - Installs to correct plugin directory
   - **Use for first-time installation**

### 3. **UPDATE.bat** (New)
   - Updates existing plugin installation
   - Checks HDT version compatibility
   - Preserves your settings
   - **Use when you modify the code**

### 4. **build.bat** (Updated)
   - Manual build for x86 platform
   - Matches your HDT architecture
   - **Use for development testing**

## 🚀 Quick Update Process

```bash
1. Run CHECK_COMPATIBILITY.bat    # Verify everything is ready
2. Make your code changes         # Edit plugin files
3. Run UPDATE.bat                 # Build and install updates
4. Test in HDT                    # Verify it works
```

## 📁 Updated File Structure

```
BattlegroundsLogger/
├── CHECK_COMPATIBILITY.bat   # ✅ Version checker
├── INSTALL.bat               # ✅ Updated for x86
├── UPDATE.bat                # 🆕 Local updater  
├── build.bat                 # ✅ Updated for x86
├── BattlegroundsLogger.csproj # ✅ x86 platform
└── [source files]           # ✅ HDT v1.46.11 compatible
```

## 🔧 What Was Updated

### Project Configuration:
- **Platform**: Changed from AnyCPU to x86
- **Output**: Now builds to `bin\x86\Release\`
- **References**: Points to your HDT x86 build
- **Version**: Updated to v1.0.1 for HDT v1.46.11

### Build Scripts:
- All build commands now use x86 platform
- Paths updated to match HDT structure
- Version detection added

### Dependencies:
- HearthstoneDeckTracker.exe (your build)
- HearthDb.dll (from lib folder)
- HearthMirror.dll (added reference)
- Newtonsoft.Json.dll (from lib folder)

## ⚡ Development Workflow

### Making Changes:
1. Edit your plugin code
2. Run `UPDATE.bat` 
3. Restart HDT
4. Test changes

### Version Updates:
When HDT updates:
1. Run `CHECK_COMPATIBILITY.bat`
2. Update project references if needed
3. Run `UPDATE.bat`

## 🎯 Benefits of Local Updates

✅ **No Internet Required** - Everything builds locally  
✅ **Version Matched** - Perfectly compatible with your HDT  
✅ **Fast Updates** - Just run UPDATE.bat  
✅ **Preserves Settings** - Your config stays intact  
✅ **Debug Friendly** - Easy to test changes  

## 🆘 Troubleshooting

### Plugin Won't Load:
```bash
1. Run CHECK_COMPATIBILITY.bat
2. Check HDT logs: %AppData%\HearthstoneDeckTracker\Logs\
3. Verify platform matches (x86)
4. Rebuild with UPDATE.bat
```

### Build Failures:
```bash
1. Check Visual Studio is installed
2. Verify HDT built successfully  
3. Check references in .csproj file
4. Run CHECK_COMPATIBILITY.bat
```

### Version Mismatches:
```bash
1. Check HDT version in project file
2. Update plugin references
3. Rebuild everything
```

## 🎮 Ready to Use!

Your plugin is now fully compatible with **HDT v1.46.11** and can be easily updated locally whenever you make changes. The update process is now as simple as running a single batch file!