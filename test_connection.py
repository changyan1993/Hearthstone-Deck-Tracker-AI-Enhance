#!/usr/bin/env python3
"""
Simple script to monitor HDT log activity in real-time
Run this while HDT and Hearthstone are both running
"""
import os
import time
import glob
from pathlib import Path

def find_latest_hdt_log():
    """Find the most recent HDT log file"""
    appdata = os.environ.get('APPDATA', '')
    log_path = Path(appdata) / "HearthstoneDeckTracker" / "Logs"
    
    if not log_path.exists():
        print(f"❌ HDT logs directory not found at: {log_path}")
        return None
    
    log_files = list(log_path.glob("*.log"))
    if not log_files:
        print("❌ No HDT log files found")
        return None
    
    latest = max(log_files, key=os.path.getmtime)
    print(f"📁 Monitoring HDT log: {latest}")
    return latest

def monitor_log_activity(log_file, duration_seconds=30):
    """Monitor log file for new lines"""
    print(f"🔄 Monitoring for {duration_seconds} seconds...")
    print("💡 Now perform some action in Hearthstone (navigate menus, enter practice mode, etc.)")
    print("-" * 50)
    
    with open(log_file, 'r', encoding='utf-8') as f:
        f.seek(0, 2)  # Go to end of file
        start_time = time.time()
        line_count = 0
        
        while time.time() - start_time < duration_seconds:
            line = f.readline()
            if line:
                line_count += 1
                # Show connection-related messages
                if any(indicator in line for indicator in ['🔄', '📋', '✅', '🎯', '⚠️']):
                    print(f"🎯 {line.strip()}")
                elif 'Power.log' in line or 'LoadingScreen' in line:
                    print(f"📋 {line.strip()}")
                elif line_count % 10 == 0:  # Show every 10th line to indicate activity
                    print(f"📊 Activity detected... (line {line_count})")
            time.sleep(0.1)
    
    print(f"\n📈 Total new log lines detected: {line_count}")
    if line_count > 0:
        print("✅ SUCCESS: HDT is actively receiving data from Hearthstone!")
    else:
        print("⚠️  No new log activity detected. Try performing actions in Hearthstone.")

if __name__ == "__main__":
    print("🔍 HDT ↔ Hearthstone Connection Test")
    print("=" * 40)
    
    log_file = find_latest_hdt_log()
    if log_file:
        monitor_log_activity(log_file)
    else:
        print("\n❌ Cannot find HDT logs. Make sure HDT is running and has been started at least once.")
        print("💡 HDT logs are typically in: %APPDATA%\\HearthstoneDeckTracker\\Logs\\")