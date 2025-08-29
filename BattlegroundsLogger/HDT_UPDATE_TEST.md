# HDT Update Compatibility Test

## 🧪 How to Test HDT Updates with Our Plugin

### **Before HDT Updates:**
1. Run `JUST_WORKS.bat` to build and install plugin
2. Verify plugin works in Battlegrounds 
3. Note current HDT version (visible in HDT title bar)

### **During HDT Update:**
1. Start HDT normally
2. When prompted "Update Available" → Click **Update**
3. Let HDT download and restart automatically
4. Note new HDT version

### **After HDT Update:**
1. Start HDT with new version
2. Check if plugin still loads (Options → Tracker → Plugins)
3. Test in Battlegrounds game

**If plugin still works:** ✅ Update was compatible - no action needed

**If plugin doesn't work:** 🔧 Run `JUST_WORKS.bat` again to rebuild against new HDT

## 🔍 What We Expect:

### **Most HDT Updates (90%+):**
- Plugin continues working without changes
- HDT maintains backward compatibility
- No rebuild needed

### **Major HDT Updates (rare):**
- Plugin might need rebuilding
- Internal APIs might change
- Run `JUST_WORKS.bat` to fix

### **Breaking Changes (very rare):**
- Plugin code might need updates
- You'd need to modify C# code
- But this almost never happens

## 📋 Compatibility Strategy:

Instead of complex auto-update systems, we use:

1. **Simple approach:** Let HDT update normally
2. **Manual fix:** Run `JUST_WORKS.bat` if needed
3. **Code updates:** Only if HDT makes breaking changes (rare)

This is much simpler and more reliable than automatic systems!