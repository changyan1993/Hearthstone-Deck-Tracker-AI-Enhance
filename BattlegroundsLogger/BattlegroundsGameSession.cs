using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Hearthstone_Deck_Tracker.Utility.Logging;
using Newtonsoft.Json;

namespace BattlegroundsLogger
{
    public class BattlegroundsGameSession
    {
        private readonly string _baseDirectory;
        private string _sessionDirectory;
        private string _sessionId;
        private DateTime _startTime;
        private List<string> _savedFiles;
        private List<string> _errors;
        private readonly object _fileLock = new object();

        public BattlegroundsGameSession(string baseDirectory)
        {
            _baseDirectory = baseDirectory;
            _savedFiles = new List<string>();
            _errors = new List<string>();
        }

        public void StartSession()
        {
            _startTime = DateTime.UtcNow;
            _sessionId = Guid.NewGuid().ToString("N").Substring(0, 8);
            
            var timestamp = _startTime.ToString("yyyy-MM-dd_HH-mm-ss");
            var folderName = $"BG-{timestamp}_{_sessionId}";
            _sessionDirectory = Path.Combine(_baseDirectory, folderName);

            try
            {
                if (!Directory.Exists(_baseDirectory))
                {
                    Directory.CreateDirectory(_baseDirectory);
                }

                Directory.CreateDirectory(_sessionDirectory);
                Log.Info($"[BG-Logger] Created session directory: {_sessionDirectory}");
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Failed to create session directory: {ex}");
                _errors.Add($"Session start: {ex.Message}");
            }
        }

        public void SaveTurnSnapshot(int turn, BattlegroundsSnapshot snapshot)
        {
            if (string.IsNullOrEmpty(_sessionDirectory))
            {
                Log.Warn("[BG-Logger] Cannot save snapshot - no session directory");
                return;
            }

            var fileName = $"turn_{turn:D2}.json";
            var filePath = Path.Combine(_sessionDirectory, fileName);

            try
            {
                lock (_fileLock)
                {
                    if (_savedFiles.Any(f => f.EndsWith(fileName)))
                    {
                        Log.Warn($"[BG-Logger] Turn {turn} already recorded, skipping duplicate write");
                        return;
                    }

                    snapshot.SessionId = _sessionId;
                    snapshot.TimestampUtc = DateTime.UtcNow;

                    var json = JsonConvert.SerializeObject(snapshot, Formatting.Indented, new JsonSerializerSettings
                    {
                        NullValueHandling = NullValueHandling.Include,
                        DefaultValueHandling = DefaultValueHandling.Include
                    });

                    var tempPath = filePath + ".tmp";
                    File.WriteAllText(tempPath, json);
                    
                    if (File.Exists(filePath))
                        File.Delete(filePath);
                    
                    File.Move(tempPath, filePath);

                    _savedFiles.Add(filePath);
                    Log.Info($"[BG-Logger] Saved turn {turn} snapshot to {fileName}");
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Failed to save turn {turn} snapshot: {ex}");
                _errors.Add($"Turn {turn}: {ex.Message}");
            }
        }

        public void EndSession()
        {
            if (string.IsNullOrEmpty(_sessionDirectory))
                return;

            try
            {
                var summary = new SessionSummary
                {
                    SessionId = _sessionId,
                    StartTime = _startTime,
                    EndTime = DateTime.UtcNow,
                    TurnCount = _savedFiles.Count(f => f.Contains("turn_")),
                    SavedFiles = _savedFiles.Select(Path.GetFileName).ToList(),
                    Errors = _errors
                };

                var summaryPath = Path.Combine(_sessionDirectory, "session_summary.json");
                var json = JsonConvert.SerializeObject(summary, Formatting.Indented);
                
                File.WriteAllText(summaryPath, json);
                
                Log.Info($"[BG-Logger] Session ended. Saved {summary.TurnCount} turns with {_errors.Count} errors");
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Failed to save session summary: {ex}");
            }
        }

        public void AddError(string error)
        {
            _errors.Add($"[{DateTime.UtcNow:HH:mm:ss}] {error}");
        }
    }

    public class SessionSummary
    {
        [JsonProperty("session_id")]
        public string SessionId { get; set; }

        [JsonProperty("start_time")]
        public DateTime StartTime { get; set; }

        [JsonProperty("end_time")]
        public DateTime EndTime { get; set; }

        [JsonProperty("turn_count")]
        public int TurnCount { get; set; }

        [JsonProperty("saved_files")]
        public List<string> SavedFiles { get; set; }

        [JsonProperty("errors")]
        public List<string> Errors { get; set; }
    }
}